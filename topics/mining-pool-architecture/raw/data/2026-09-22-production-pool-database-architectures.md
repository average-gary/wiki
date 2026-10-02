---
title: "Production pool database architectures: BTCPool (Kafka+MySQL), Miningcore (PostgreSQL COPY), MPOS, Redis pools"
source: "https://github.com/btccom/btcpool"
related_sources:
  - "https://github.com/oliverw/miningcore"
  - "https://github.com/MPOS/php-mpos"
  - "https://github.com/zone117x/node-open-mining-portal"
  - "https://github.com/sammy007/open-ethereum-pool"
  - "https://dev.mysql.com/doc/refman/8.0/en/partitioning-pruning.html"
type: data
ingested: 2026-09-22
tags: [btcpool, kafka, sharelog, protobuf, miningcore, postgresql, binary-copy, partitioning, mpos, mysql, scaling-limit, redis, nomp, write-amplification, retention, aggregation]
summary: "Closes round 1's biggest documentation gap — no source had shown a real share schema. Now there are five, with DDL. The single most useful result is a natural experiment: EVERY production design avoids row-by-row per-share INSERT, and MPOS, the one design that does it, is the only one with a documented scaling failure (reported to struggle above 1-2k concurrent miners with replication lag and index lock contention). The alternatives: BTCPool (BTC.com's open-sourced stack, tested at 100k miners) puts Kafka between validation and storage — sserver produces to a ShareLog topic buffered at 10M messages / 1s flush / 10k batch with Snappy, sharelogger writes compressed ProtoBuf files to disk by day, slparser aggregates into MySQL hourly/daily stats tables every 15s, so MySQL holds NO per-share rows; SolvedShare gets a separate 1ms-flush uncompressed topic because a block cannot wait. Miningcore keeps raw per-share rows but inserts them via PostgreSQL BINARY COPY (10-100x faster than INSERT) into a shares table with DELIBERATELY NO PRIMARY KEY, optionally LIST-partitioned by poolid. NOMP and open-ethereum-pool keep no share rows at all — Redis hincrbyfloat accumulates per-round difficulty, deleted after payment, with orphan rounds merged back via a Lua script."
credibility: medium
credibility_score: 4
credibility_rationale: "DDL and configuration are transcribed from public repositories and are primary. The scaling claims are weaker: MPOS's '1-2k miners' limit is reported without a cited benchmark, and BTCPool's '100k miners tested' is the project's own README claim. Treat schemas as fact and limits as testimony."
confidence: medium
research_round: 2
research_agent: C2
closes_gap: "Round 1 open question: 'no source documented a share database schema — no table structures, indexes, partitioning, or write-amplification handling.' Five schemas now recorded."
extraction_note: "Subagent web research with direct fetches of schema files. DDL transcribed. BTCPool is archived/abandoned upstream; its schema remains the best public record of a large pool's storage design."
---

# Production pool database architectures

## The natural experiment

**Every production design avoids row-by-row per-share INSERT. The one design that does it is the one
with a documented scaling failure.**

| Implementation | Engine | Per-share row? | Batching | Retention | Queue layer | Writes/share |
|---|---|---|---|---|---|---|
| **BTCPool** | MySQL | **No** — hourly/daily aggregates | Kafka: 10k-msg batches, 1 s flush | disk sharelogs + MySQL aggregates | **Kafka** | ~2–3 |
| **Miningcore** | PostgreSQL | Yes | **binary `COPY`** | `DeleteSharesBefore`, manual | none | 1 (per batch) |
| **MPOS** | MySQL | Yes | **none — individual INSERT** | archive table, 25k-row delete batches | none | 1+ per share |
| **NOMP** | Redis | **No** — hash accumulation | `MULTI` pipeline | delete round after payment; TTLs | none | 1 (in-memory) |
| **open-ethereum-pool** | Redis | **No** | `MULTI` pipeline | round cleanup, 7 d worker TTL | none | 1 (in-memory) |

## BTCPool — Kafka between validation and storage

BTC.com's open-sourced stack, README claims design and testing at **100k online miners**.

**Components**: `sserver` (stratum, validates, produces to Kafka) · `gbtmaker` (templates) · `jobmaker`
(jobs → `StratumJob` topic) · `sharelogger` (consumes `ShareLog` → compressed ProtoBuf files) ·
`slparser` (sharelog files → MySQL aggregates) · `blkmaker` (consumes `SolvedShare` → submits blocks) ·
`statshttpd` (HTTP API over MySQL) · `poolwatcher` · `nmcauxmaker` (merged mining).

**The Kafka tuning is the interesting part** — two topics with opposite settings:

```
producer_share_log:      queue.buffering.max.messages = 10000000   # ~480 MB
                         queue.buffering.max.ms       = 1000       # 1 s
                         batch.num.messages           = 10000
                         compression.codec            = "snappy"

producer_solved_share:   queue.buffering.max.ms       = 1          # 1 ms
                         compression.codec            = "none"
```

**Shares are batched for a second; a solved block waits one millisecond and is not compressed.** That is
the two-hot-paths principle expressed as broker configuration — and it makes explicit that share
*durability* is a bulk concern while a found block is a latency concern. Max message size 60 MB to carry
large templates.

**ShareLog record** (ProtoBuf), files bucketed by day (`timestamp - timestamp % 86400`), gzip level
configurable:

```protobuf
message BitcoinMsg {
  required sint32 version = 1;
  optional sint64 workerhashid = 2;   optional sint32 userid = 3;
  optional sint32 status = 4;         // accept/reject/stale
  optional sint64 timestamp = 5;      optional string ip = 6;
  optional uint64 jobid = 7;          optional uint64 sharediff = 8;
  optional uint32 blkbits = 9;        optional uint32 height = 10;
  optional uint32 nonce = 11;         optional uint32 sessionid = 12;
  optional uint32 versionmask = 13;   optional sint32 extuserid = 14;
  optional uint32 bitsreached = 15;
}
```

**MySQL holds aggregates, not shares.** `stats_pool_hour` (and `stats_users_hour/day`,
`stats_workers_hour/day` keyed `(puid, hour)` / `(puid, worker_id, hour)`):

```sql
CREATE TABLE `stats_pool_hour` (
  `hour` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale`  bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',   -- JSON {"reason":count}
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0',
  `earn`  decimal(35,0)  NOT NULL DEFAULT '0',
  UNIQUE KEY `hour` (`hour`)
) ENGINE=InnoDB;
```

`mining_workers` carries rolling counters directly on the row — `accept_1m/5m/15m/1h`,
`stale_15m/1h`, `reject_15m/1h`, `reject_detail_15m/1h`, `last_share_ip`, `last_share_time`,
`miner_agent` — i.e. the same multi-window rolling averages ckpool keeps in RAM, here materialised in a
table. `found_blocks` holds `puid`, `worker_id`, `job_id`, `height`, `is_orphaned`, `hash` (unique),
`rewards`, `size`, `prev_hash`, `bits`, `version`.

`slparser` accumulates accept/stale/reject as **sums of difficulty**, computes `score` and
`earn = score × reward`, and flushes every **15 s**. Source comments mark `score`/`earn` as "for
reference only" — **the real payout logic is not in the open-source release.**

**Writes per share ≈ 2–3**: Kafka journal + sharelog file. MySQL is not in the per-share path at all.

## Miningcore — per-share rows, but bulk-loaded

```sql
CREATE TABLE shares (
  poolid TEXT NOT NULL,
  blockheight BIGINT NOT NULL,
  difficulty DOUBLE PRECISION NOT NULL,
  networkdifficulty DOUBLE PRECISION NOT NULL,
  miner TEXT NOT NULL,
  worker TEXT NULL,
  useragent TEXT NULL,
  ipaddress TEXT NOT NULL,
  source TEXT NULL,
  created TIMESTAMPTZ NOT NULL
);
CREATE INDEX IDX_SHARES_POOL_MINER on shares(poolid, miner);
CREATE INDEX IDX_SHARES_POOL_CREATED ON shares(poolid, created);
CREATE INDEX IDX_SHARES_POOL_MINER_DIFFICULTY on shares(poolid, miner, difficulty);
```

**No PRIMARY KEY on `shares`** — a deliberate write optimisation for append-only time-series. Note also
what is *not* stored: no nonce, no extranonce, no job id. Miningcore keeps what payout needs
(`miner`, `difficulty`, `created`) and discards what block reconstruction would need — the opposite
choice from p2poolv2, which retains `nonce`/`extranonce2`/`job_id` precisely for reconstruction.

**Insertion is binary `COPY`** (`ShareRepository.cs`):

```csharp
const string query = @"COPY shares (poolid, blockheight, difficulty, networkdifficulty,
    miner, worker, useragent, ipaddress, source, created) FROM STDIN (FORMAT BINARY)";
await using(var writer = await pgCon.BeginBinaryImportAsync(query, ct)) {
    foreach(var share in shares) { await writer.StartRowAsync(ct); /* typed writes */ }
    await writer.CompleteAsync(ct);
}
```

Binary `COPY` is cited at **10–100× individual INSERTs**, respects the ambient transaction, and is
type-safe via `NpgsqlDbType`. Batch size is the caller's choice.

**PostgreSQL 11+ partitioning** (`createdb_postgresql_11_appendix.sql`) drops and recreates `shares`
`PARTITION BY LIST (poolid)`, with partitions created manually
(`CREATE TABLE shares_bitcoin PARTITION OF shares FOR VALUES IN ('bitcoin')`). Partitioning by *pool*
rather than by *time* — which suits a multi-coin operator's pool-scoped queries and per-pool retention,
but does **not** give the cheap `DROP PARTITION` retention that time partitioning would.

Other tables: `blocks` (with a `DEFERRABLE INITIALLY DEFERRED` unique constraint on
`(poolid, blockheight, type)`), `balances` / `balance_changes` (the latter with a `text[] tags` column and
a **GIN index** for audit metadata), `payments`, `poolstats`, `minerstats`. Money is
`decimal(28,12)` throughout.

Retention is code, not schema: `DeleteSharesBeforeAsync` and `DeleteSharesByMinerAsync`. **No scheduled
policy in the DDL.**

## MPOS — the counterexample

```sql
CREATE TABLE `shares` (
  `id` bigint(30) NOT NULL AUTO_INCREMENT,
  `rem_host` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `our_result` enum('Y','N') NOT NULL,
  `upstream_result` enum('Y','N') DEFAULT NULL,
  `reason` varchar(50) DEFAULT NULL,
  `solution` varchar(257) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `difficulty` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `time` (`time`), KEY `upstream_result` (`upstream_result`),
  KEY `our_result` (`our_result`), KEY `username` (`username`)
) ENGINE=InnoDB;
```

**One INSERT per share, no batching**, with four secondary indexes to maintain on every insert, plus a
`varchar(257)` `solution` column. Archival moves rows to `shares_archive` then deletes in 25k batches
with sleeps to avoid lock contention.

**Reported limit: struggles above 1–2k concurrent miners**, with replication lag, slow queries and index
lock contention. *(Reported without a cited benchmark — testimony, not measurement. But the mechanism is
entirely plausible: four indexes plus a wide row plus binlog per share.)*

## Redis pools — no share rows at all

NOMP / open-ethereum-pool (`shareProcessor.js`):

```javascript
connection.multi([
  ['hincrbyfloat', coin + ':shares:roundCurrent', workerAddress, shareValue],
  ['hincrby', coin + ':stats', 'validShares', 1],
  ['zadd', coin + ':hashrate', Date.now()/1000, [shareValue, workerAddress, Date.now()].join(':')],
  ['hincrby', coin + ':workers:' + workerAddress, 'validShares', 1],
  ['expire', coin + ':workers:' + workerAddress, 86400 * 7]
]).exec(...);
```

Hash accumulation for the round, a sorted set for the hashrate time series, `MULTI` to cut round trips,
TTLs for cleanup (hashrate 3 h, worker data 7 d). Raw round shares are **deleted immediately after
payment**, and an **orphaned round is merged back into the current round by a Lua script** —
`hgetall` the orphan, `hincrby` into `roundCurrent`, `del`. That reorg handling is notable: it is the one
place any implementation in either round shows what happens to accounting when a block is orphaned, and
the answer is "the work is not lost, it rolls forward."

Memory-bound; suited to <10k miners or high per-share difficulty.

## MySQL partitioning, for completeness

`PARTITION BY RANGE (TO_DAYS(created))` or `RANGE COLUMNS(date_column)` with **partition pruning** giving
"order of magnitude" gains when the partition key is in the `WHERE` clause (`EXPLAIN PARTITIONS` to
verify). `DROP PARTITION` is instant and takes no table lock — the correct retention primitive, and the
one Miningcore's LIST-by-pool scheme forgoes.

## Patterns worth keeping

1. **Nobody INSERTs per share.** Batch (Kafka, `COPY`), aggregate (public-pool buckets, BTCPool
   hourly), or accumulate in memory (Redis, ckpool).
2. **Separate the block path from the share path** at every layer — BTCPool's 1 ms uncompressed
   `SolvedShare` topic beside its 1 s Snappy `ShareLog`.
3. **Raw shares are transient everywhere.** Deleted after payment (Redis), after 24 h (public-pool),
   after 7 days (p2poolv2), or never written at all (BTCPool's MySQL). **Nobody retains raw per-share
   history long-term** — which is precisely what round 1 concluded withholding detection needs. That
   requirement is met by no production pool.
4. **Aggregate tables carry multi-window rolling counters** (BTCPool's `accept_1m/5m/15m/1h`), the same
   shape ckpool keeps in RAM.
5. **Time-partition for retention** if you keep raw rows; `DROP PARTITION` beats `DELETE`.

## What could not be found

- **ClickHouse or TimescaleDB in a production pool** — no examples. Possibly in analytics pipelines, not
  as primary share storage.
- **eloipool** persistence — repository 404, no archive.
- **Operator postmortems / migration writeups** — 2014–16 BitcoinTalk and Reddit threads on MPOS
  migration are no longer accessible or indexed. Operator knowledge here is largely private.
- **Sharding by worker** — not documented anywhere as a pattern.
- **BTCPool's real payout calculation** — the open release marks `score`/`earn` "for reference only".
