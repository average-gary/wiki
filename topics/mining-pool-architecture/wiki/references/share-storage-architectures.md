---
title: "Share Storage Architectures"
category: reference
sources:
  - raw/repos/2026-09-22-pool-persistence-schemas-source-read.md
  - raw/data/2026-09-22-production-pool-database-architectures.md
  - raw/repos/2026-09-22-share-accounting-ext-and-rust-pool-stores-source-read.md
  - raw/repos/2026-09-22-sri-pool-share-persistence-source-read.md
  - raw/data/2026-09-22-ingest-engines-and-durability-tradeoffs.md
  - raw/repos/2026-09-23-blitzpool-source-read.md
created: 2026-09-22
updated: 2026-09-23
tags: [share-storage, schema, write-amplification, batching, aggregation, retention, partitioning, kafka, postgresql-copy, rocksdb, redis, sqlite, index-cost, durability-window]
aliases: ["share database", "share schema", "pool database"]
confidence: high
volatility: warm
summary: "Every share-storage design found in nine real implementations, with the schemas. The governing result is a natural experiment: nobody in production writes one durable row per share, and the single design that does — MPOS, with a primary key plus four secondary indexes and no batching — is the only one with a documented scaling failure. Raw per-share rows are transient everywhere they exist at all: 24 hours, 7 days, or deleted at payment."
---

# Share Storage Architectures

> Round 1 could not find a single documented share schema. There are now nine implementations on
> record. The pattern across them is sharp enough to be a design rule.

## The rule

**Nobody in production writes one durable row per share.** They batch, aggregate, or keep it in memory.
And the one design that does per-share row-by-row `INSERT` is the one with a documented scaling failure.

| Implementation | Engine | Per-share row? | Mechanism | Retention | Writes/share |
|---|---|---|---|---|---|
| **ckpool** | append-only JSON log | yes (incl. rejects) | 1 synchronous `fwrite` from the stratifier | **indefinite** | 1 + open/close |
| **public-pool** | SQLite (WAL) | **no** | in-memory → **10-minute buckets** | 24 h | **0–1 UPDATE**, ≈1/min/session |
| **Blitzpool** | PostgreSQL + Redis | **no** (Redis stream entry is lossy transport) | Redis stream → Lua fold into 10k-share buckets; PG `UNNEST` upserts every 60 s | slots 14 d; **lifetime per-worker totals never pruned** | 1 `XADD` + 1 Lua call; PG ≈1/min/session |
| **BTCPool** | MySQL | **no** | Kafka → ProtoBuf disk logs → **hourly/daily aggregates** | disk logs; MySQL aggregates | ~2–3 (Kafka + log) |
| **Miningcore** | PostgreSQL | yes | **binary `COPY`**, no PRIMARY KEY on `shares` | code-driven delete | 1 per batch |
| **MPOS** | MySQL | yes | **individual `INSERT`, no batching** | archive table, 25k-row deletes | 1+ per share |
| **NOMP / open-ethereum-pool** | Redis | **no** | `hincrbyfloat` round accumulation | **deleted at payment** | 1 (in-memory) |
| **p2poolv2 / hydrapool** | RocksDB | yes | time-prefixed key, `delete_range_cf` prune | **7 days** | 1 |
| **SRI sv2-apps** | **none** | n/a | in-RAM counters, HTTP polling API | lost on restart | **0** |

**MPOS is the counterexample that makes the rule.** Its `shares` table carries a `bigint` primary key,
**four secondary indexes**, a `varchar(257)` solution column, and one `INSERT` per share. Reported to
struggle above **1–2k concurrent miners** with replication lag and index lock contention. Set against
the index warning that *"number of indexes is the most dominant factor for insert performance"* — a
single index able to raise insert time 100×, compounding per index — the mechanism is obvious.

## Aggregate, don't store

**public-pool** is the cleanest illustration. Shares accumulate in memory
(`StratumV1ClientStatistics.ts:34-116`) and land as 10-minute buckets:

```typescript
@Entity()
@Index(["address", "clientName", "sessionId"])
@Index(["address", "clientName", "sessionId", "time"])
export class ClientStatisticsEntity extends TrackedEntity {
    @PrimaryGeneratedColumn() id: number;
    @Column({ length: 62, type: 'varchar' }) address: string;
    @Column() clientName: string;
    @Column({ length: 8, type: 'varchar' }) sessionId: string;
    @Index() @Column({ type: 'integer' }) time: number;
    @Column({ type: 'real' }) shares: number;          // summed difficulty
    @Column({ default: 0, type: 'integer' }) acceptedCount: number;
}
```

One `INSERT` on the first share of a slot, one `UPDATE` per minute thereafter, one `UPDATE` + `INSERT` at
the slot boundary. **DB write load scales with active sessions, not with share rate** — the persistence
layer's restatement of this topic's central finding that connection count is the independent variable.
See [[pool-sizing-model|Pool Sizing Model]] ([Pool Sizing Model](pool-sizing-model.md)).

public-pool's only per-share table is `ExternalSharesEntity`, for shares POSTed from *other* pools, and it
accepts only **≥ 1T difficulty** — a rate limiter expressed as a threshold.

**BTCPool** does the same at scale: `slparser` sums accept/stale/reject difficulty and flushes every
**15 s** into `stats_pool_hour` / `stats_users_hour|day` / `stats_workers_hour|day`. MySQL holds no
per-share row. Its `mining_workers` table even materialises the rolling windows —
`accept_1m/5m/15m/1h`, `stale_15m/1h`, `reject_15m/1h`, `reject_detail_15m/1h` — the same multi-window
counters ckpool keeps in RAM.

**Blitzpool** is the same schema grown up: a Rust port of public-pool that keeps its TypeORM table names
(`client_statistics_entity`) and the 10-minute slot, moved to PostgreSQL 18, with Redis in front. Two
routes leave the share hot path, and neither blocks it:

- **Payout state.** Each accepted share goes into a **bounded mpsc of 8,192 that drops on overflow**, then
  one JSON `XADD` to `shares:accepted` (`MAXLEN ~1,000,000`). A failed publish is logged, never retried. A
  separate satellite process consumes the stream at-least-once, and an atomic Lua script folds each share
  into **per-address buckets of 10,000 shares**, with a 100k-entry `share_id` dedup set to absorb
  redelivery. Storage is O(buckets × miners), not O(shares).
- **Statistics.** An in-memory accumulator flushes every 60 s as `UNNEST` bulk upserts (≤1,000 rows per
  statement) with **increment** semantics into the slot rows. It uses a drain/confirm contract: a delta is
  cleared only after the write commits.

The stream entry is **not** a durable per-share record. It is capped, it can drop, and it carries no
nonce or hash, so a share cannot be re-verified from it. The rule holds.

**The one production measurement of a share-statistics table in the corpus** is in Blitzpool's migration
0015, from the authors' own prod: across **106.7M updates, only 16.7% were HOT** (in-place) updates, and
the table carried **794 MB of index on 274 MB of heap**. The fix was `fillfactor = 80`. The lesson
generalises to anything that UPDATEs a hot aggregate row every minute. PostgreSQL can update in place
only if the page has free space **and no indexed column changes**. So leave page slack, and keep
the incremented counters out of every index.

## If you do keep per-share rows

**Miningcore** is the reference for doing it properly:

```sql
CREATE TABLE shares (
  poolid TEXT NOT NULL, blockheight BIGINT NOT NULL,
  difficulty DOUBLE PRECISION NOT NULL, networkdifficulty DOUBLE PRECISION NOT NULL,
  miner TEXT NOT NULL, worker TEXT NULL, useragent TEXT NULL,
  ipaddress TEXT NOT NULL, source TEXT NULL, created TIMESTAMPTZ NOT NULL
);
CREATE INDEX IDX_SHARES_POOL_MINER on shares(poolid, miner);
CREATE INDEX IDX_SHARES_POOL_CREATED ON shares(poolid, created);
CREATE INDEX IDX_SHARES_POOL_MINER_DIFFICULTY on shares(poolid, miner, difficulty);
```

**No PRIMARY KEY** — deliberate, for append-only time-series. Loaded via **binary `COPY`** (cited at
10–100× individual `INSERT`s), optionally `PARTITION BY LIST (poolid)`.

Note what it *omits*: no nonce, no extranonce, no job id. Miningcore keeps what payout needs and discards
what block reconstruction would need. **p2poolv2 makes the opposite choice** and retains
`nonce`/`extranonce2`/`job_id` precisely so a block can be rebuilt:

```rust
pub struct SimplePplnsShare {
    pub user_id: u64, pub difficulty: u64,
    #[serde(skip)] pub btcaddress: Option<String>,   // normalised into the User CF
    #[serde(skip)] pub workername: Option<String>,
    pub n_time: u64, pub job_id: String,
    pub extranonce2: String, pub nonce: String,
}
```

with a **24-byte big-endian composite key** `(n_time, user_id, seq)` — so RocksDB's sort order *is* the
index, a PPLNS window is a range scan, and inserts pay no index cost at all. That is the most elegant
storage design in the set, and it is why p2poolv2 needs no indexes.

## Retention must be a metadata operation

Every implementation that got this right made time part of the physical layout:

| Mechanism | Cost |
|---|---|
| RocksDB **`delete_range_cf`** (p2poolv2, 7-day TTL, 24 h task) | O(1) metadata; real deletion at compaction |
| MySQL **`DROP PARTITION`** | instant, no table lock |
| TimescaleDB **drop chunk** | instant, no table scan |
| Redis: **delete the round after payment** | free |
| MPOS: `INSERT … SELECT` into archive then `DELETE … LIMIT 25000` with sleeps | expensive, lock-sensitive |

The last row is what retention looks like when the schema has no time-based physical layout.

**Nobody retains raw per-share history long-term.** Deleted at payment (Redis), after 24 h (public-pool),
after 7 days (p2poolv2), never written (BTCPool's MySQL, SRI, Blitzpool). **ckpool's sharelog is the only
indefinite raw record**, and nothing in-tree reads it.

**Long-horizon *aggregates* do exist.** Blitzpool never prunes `worker_shares_entity` (lifetime totals
keyed by address + worker), per-address per-block payout history, or the pool-wide 10-minute rows. But the
per-worker totals have **no time dimension**, and the per-worker time series lasts only 14 days. It is
the nearest any implementation comes to what withholding detection needs, and it still falls short.

This directly contradicts what withholding detection needs. See
[[share-accounting-and-durability|Share Accounting and Durability]] ([Share Accounting and Durability](../concepts/share-accounting-and-durability.md)).

## Buffering, and layered durability

**BTCPool's Kafka configuration is the most instructive artifact here** — two topics, opposite settings:

```
producer_share_log:     queue.buffering.max.messages = 10000000   # ~480 MB
                        queue.buffering.max.ms       = 1000       # 1 s
                        batch.num.messages           = 10000
                        compression.codec            = "snappy"

producer_solved_share:  queue.buffering.max.ms       = 1          # 1 ms
                        compression.codec            = "none"
```

**Shares wait a second and are compressed; a found block waits a millisecond and is not.** That is
[[the-two-hot-paths|the two hot paths]] ([the two hot paths](../concepts/the-two-hot-paths.md)) expressed
as broker config.

The general pattern, independently arrived at in both BTCPool's design and the engine literature:
**connection-handler log → buffer → aggregated store.** Each layer has a different durability window.

## Durability windows

| Setting | Loss window |
|---|---|
| PostgreSQL `synchronous_commit = on` | 0 |
| **PostgreSQL `synchronous_commit = off`** | **~600 ms, no corruption risk** |
| Redis AOF `everysec` (default) | 1 s |
| ClickHouse `async_insert` (default) | 50–200 ms; `insert_quorum=0` acks before replication |
| QuestDB ILP | 1 s default flush; HTTP retry is at-least-once → needs dedup |
| Kafka `acks=1` | unacknowledged messages on leader failure |

`synchronous_commit = off` is the best trade available for share data: a ~600 ms window with no
corruption risk, and a share is re-derivable from the connection handler's log anyway.

## What not to build

Engine benchmarks exist — QuestDB sustaining 640k rows/sec at 10M-series cardinality where TimescaleDB
managed 50k and InfluxDB 38k; Cloudflare's ClickHouse at 11M rows/sec across 36 nodes with 44×
compression. They are mostly irrelevant here, for two reasons:

1. **PostgreSQL's capacity is routinely understated.** A widely-cited "3–4k rows/sec" figure is the
   *margin* by which TimescaleDB beat PostgreSQL in one test, not PostgreSQL's ceiling. Binary `COPY` of
   small rows runs in the 10⁵/sec range.
2. **The share rate never reaches the database** in any production design. At the corrected rate of
   ~2,300 shares/sec for 23,000 connections — and with aggregation on top — no pool is near an engine
   limit.

So: Kafka + ClickHouse + QuestDB towers are answers to a problem this workload does not have. The two
things that *do* matter are **index discipline** (2–3 indexes maximum, or none if the key is
time-ordered) and **`PgBouncer` in transaction-pooling mode** if you genuinely have tens of thousands of
client connections against PostgreSQL.

## What a share record must contain

From the union of all nine, plus the SV2 `share-accounting-ext` extension:

**Minimum**: `user_id` (normalised, with the address in a separate table), `difficulty` (the weight),
`timestamp` (window boundaries *and* retention), `job_id`.

**For block reconstruction**: `nonce`, `extranonce2`, `ntime`.

**For Job-Declaration fee accounting**: `reference_job_id`, the share's `fee`, `merkle_path` to the slice
root, `share_index` — and per slice, the aggregate `Slice` record (share count, summed difficulty,
reference-job fees, merkle root, reference job id).

**And the gap**: *nobody stores template provenance per share*, which PPLNS-JD's fee score requires. See
[[template-sourcing-and-control|Template Sourcing and Control]] ([Template Sourcing and Control](../concepts/template-sourcing-and-control.md)).

## See Also

- [[share-accounting-and-durability|Share Accounting and Durability]] ([Share Accounting and Durability](../concepts/share-accounting-and-durability.md)) — what must persist and why.
- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](../concepts/the-two-hot-paths.md))
- [[pool-sizing-model|Pool Sizing Model]] ([Pool Sizing Model](pool-sizing-model.md))
- [[pool-implementation-survey|Pool Implementation Survey]] ([Pool Implementation Survey](../topics/pool-implementation-survey.md))
