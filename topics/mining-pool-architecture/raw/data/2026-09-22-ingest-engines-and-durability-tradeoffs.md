---
title: "Storage engines and durability trade-offs for a share stream — benchmarks, with one correction"
source: "https://www.tigerdata.com/blog/timescaledb-vs-6a696248104e/"
related_sources:
  - "https://blog.cloudflare.com/http-analytics-for-6m-requests-per-second-using-clickhouse/"
  - "https://questdb.com/blog/2021/06/16/high-cardinality-time-series-data-performance/"
  - "https://www.postgresql.org/docs/current/populate.html"
  - "https://www.postgresql.org/docs/current/runtime-config-wal.html"
  - "https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/"
  - "https://use-the-index-luke.com/sql/dml/insert"
type: data
ingested: 2026-09-22
tags: [ingest-benchmarks, timescaledb, clickhouse, questdb, postgresql, synchronous-commit, wal-tuning, redis-aof, durability-window, batching, index-cost, compression, high-cardinality, over-engineering]
summary: "Engine benchmarks for a high-rate small-record stream, recorded with a significant correction and a significant caveat. CORRECTION: the report treats '3,000-4,000 rows/sec' as PostgreSQL's capacity, but the cited Timescale post gives that as the DELTA by which TimescaleDB exceeds PostgreSQL, not an absolute — PostgreSQL with binary COPY does far more (Miningcore's own COPY path is cited at 10-100x INSERT), so every conclusion drawn from that number understates PostgreSQL badly. CAVEAT: the whole engine ladder answers 'which database if you store one row per share', and the source-read evidence from the same round says no production pool does that. Genuinely useful content: durability windows are explicit and comparable — PostgreSQL synchronous_commit=off loses up to ~600ms (3 x wal_writer_delay) with no corruption risk, Redis AOF everysec loses up to 1s, ClickHouse async_insert batches over a 50-200ms adaptive window and with the default insert_quorum=0 acknowledges before replication, QuestDB ILP defaults to a 1s auto_flush_interval with 75,000-row HTTP batches. Measured throughput: QuestDB 640k rows/sec at 10M-device cardinality where TimescaleDB managed 50k and InfluxDB 38k (m5.8xlarge, 4 threads); Cloudflare's ClickHouse at 11M rows/sec across 36 nodes with 44x compression versus raw. And the index warning that matters most: 'number of indexes is the most dominant factor for insert performance', a single index able to raise insert time by 100x."
credibility: medium
credibility_score: 3
credibility_rationale: "Individual benchmarks are well-specified (hardware, batch sizes, cardinality) but three of the four are vendor-published about their own product. The PostgreSQL and Redis durability documentation is authoritative. One headline figure was misread by the reporting agent and is corrected here, which lowers confidence in its other derived numbers."
confidence: medium
research_round: 2
research_agent: C3
corrections_applied: true
over_engineering_warning: "This file's recommendations (QuestDB + Redis Streams at 200k shares/sec; ClickHouse + Kafka above that) are far heavier than anything any real pool runs. Read alongside raw/data/2026-09-22-production-pool-database-architectures.md and raw/repos/2026-09-22-pool-persistence-schemas-source-read.md, which show that production pools store aggregates rather than per-share rows and therefore never reach these rates in their databases."
extraction_note: "Subagent web research. Benchmark numbers transcribed with hardware. Cost estimates are the agent's AWS-pricing arithmetic and were not verified."
---

# Storage engines for a share stream

> **Read the two warnings in the frontmatter first.** The corrected PostgreSQL figure and the
> over-engineering caveat both change what this file means.

## CORRECTION: PostgreSQL's capacity was understated ~50×

The reporting agent recorded *"Ingestion rate: TimescaleDB: 3,000-4,000 rows/sec higher than
PostgreSQL"* — correctly quoting the source — and then used **3–4k rows/sec as PostgreSQL's absolute
ceiling**, concluding that 2.3k shares/sec sits at the edge of "proven PostgreSQL capability" with
modest headroom, and that 200k shares/sec is "marginal" for it.

That is a misreading of a delta as an absolute. The cited number is the *margin* by which TimescaleDB
beat PostgreSQL in that test, not what PostgreSQL can do. For reference, from the neighbouring source
in this same round: **Miningcore loads shares via PostgreSQL binary `COPY`, cited at 10–100× individual
INSERTs**, and PostgreSQL's own bulk-loading documentation names `COPY` as the fastest path. Small
fixed-width rows over binary `COPY` on commodity hardware run in the **10⁵ rows/sec** range, not 10³.

**Consequence**: PostgreSQL is not near its limit at 2.3k shares/sec, and it is not obviously
disqualified at 200k either. The real constraints at high rates are **index maintenance, retention
mechanics, and query concurrency** — not raw ingest. Every "you need QuestDB/ClickHouse at this scale"
conclusion in the original report inherits the error.

## Durability windows — the genuinely useful table

This is the part worth keeping, because it is comparable and explicit.

| Approach | Loss window | Notes |
|---|---|---|
| PostgreSQL `synchronous_commit = on` | 0 | durable |
| **PostgreSQL `synchronous_commit = off`** | **~600 ms** (3 × `wal_writer_delay`) | **no corruption risk** — "most of the performance benefit of `fsync = off`" without it |
| Redis **AOF `everysec`** (default) | **1 s** | "likely to be as fast as snapshotting" since 2.4 |
| Redis AOF `always` | 0 (group commit) | "very slow in practice" |
| **ClickHouse `async_insert`** (default on) | **50–200 ms** adaptive batch window | and with default **`insert_quorum = 0`, inserts are acknowledged before replication** |
| QuestDB ILP | **1 s** default `auto_flush_interval` | HTTP retry gives at-least-once → needs dedup |
| Kafka `acks=1` | unacknowledged messages on leader failure | `acks=all` for zero |

**The `synchronous_commit = off` distinction is the single most practically useful item here**: it trades
a ~600 ms loss window for a large throughput gain *without* risking corruption. For share data that is a
good trade, because a share is re-derivable — the miner submitted it, and it is in the connection
handler's log.

Suggested write-heavy PostgreSQL configuration from the docs:

```
wal_buffers = 16MB
synchronous_commit = off      # ~600 ms loss window, no corruption
checkpoint_timeout = 30min
max_wal_size = 4GB
```

## Measured throughput

**QuestDB high-cardinality benchmark** (m5.8xlarge, Xeon Platinum 8259CL, 4 threads) — the most relevant
test found, because high cardinality mirrors a pool with many workers:

| Cardinality | QuestDB | ClickHouse | TimescaleDB | InfluxDB |
|---|---|---|---|---|
| 100 devices | 904k rows/s | 548k | — | — |
| **10M devices** | **640k rows/s** | 345k | **50k** | **38k** |

At 16 threads QuestDB sustained ~815k rows/sec across cardinalities; on a Ryzen 3970X at 6 threads it
peaked above 1M rows/sec at 1M devices. **The cardinality collapse is the finding**: TimescaleDB fell
from competitive to 50k and InfluxDB to 38k as distinct series grew to 10M. A pool with millions of
worker identities is a high-cardinality workload, so a benchmark at 100 series tells you nothing useful.

**Cloudflare ClickHouse in production**: **11M rows/sec average** across pipelines, 47 Gbps insertion
bandwidth, on **36 nodes** (40 cores E5-2630 v3, 256 GB RAM, 12 × 10 TB HDD each, 3× replication).
Compression: raw 1,630 B → 360 B compressed → 36.74 B aggregated (**44× vs raw**); storage cost
$28M/yr → $1.9M/yr. At 200k shares/sec a pool would be using **1.8%** of that capacity — which is the
argument *against* reaching for ClickHouse, not for it.

**TimescaleDB**: 1B+ rows, 4,000 devices, 10 s intervals, 4-hour chunks, m5.2xlarge; **90%+ compression**
and a claimed 1,000× query speedup on time-series queries versus vanilla PostgreSQL. Optimal batch
**10,000–15,000 rows**.

## Batching, and the index warning

**Batch sizes from the docs**: PostgreSQL/TimescaleDB 10k–15k rows per transaction, via `COPY` or
multi-row INSERT. QuestDB ILP: **75,000 rows** default over HTTP, **600** over TCP (lower latency), 1 s
flush. ClickHouse async insert: up to 10 MB or 450 queries, 50–200 ms adaptive.

*At 2,300 shares/sec, a 75,000-row batch takes 32 seconds to fill* — so the row-count trigger is the
wrong one at pool scale and the time-based flush governs. Worth noting because it is easy to configure a
batch size that silently converts into a 30-second durability window.

**The index cost**, and this is the most transferable item in the file: *"Number of indexes is the most
dominant factor for insert performance"* — a single index can raise insert time **100×**, and each
additional index compounds.

This explains two designs seen elsewhere in this round: **Miningcore's `shares` table has no PRIMARY KEY**
and carries three indexes; **MPOS's has a primary key plus four secondary indexes** and is the one with a
documented scaling failure. It also explains **p2poolv2's choice to have no indexes at all** — a
time-prefixed composite RocksDB key makes the sort order *be* the index, so range scans are free and
inserts pay nothing.

PostgreSQL bulk-loading guidance also applies: drop indexes before a large load and rebuild after, raise
`maintenance_work_mem`, raise `max_wal_size` to cut checkpoint frequency.

## The recommendations, and why to discount them

The report proposes: PostgreSQL + `async_commit` + PgBouncer at 2.3k/sec (~$140/mo); TimescaleDB with
4-hour chunks, compression after 1 day and a 90-day retention policy at 20–50k/sec (~$560–1,120/mo);
**QuestDB behind a Redis Streams buffer** at 200k/sec (~$1,400/mo); **ClickHouse 3-node + Kafka** above
500k/sec (~$2,610/mo).

Two reasons to discount most of this:

1. **The PostgreSQL correction above** removes the justification for climbing the ladder at all until far
   higher rates.
2. **No production pool stores one row per share.** BTCPool's MySQL holds only hourly/daily aggregates;
   public-pool writes 10-minute buckets at roughly one UPDATE per session per minute; NOMP/Redis
   accumulate per-round counters and delete them after payment; ckpool writes an append-only log and no
   database at all. **The share rate never reaches the database.** The engine question is mostly answered
   by not asking it.

The one architectural idea here that *is* well supported and does appear in production is **layered
durability**: connection-handler log → buffer (Redis/Kafka) → aggregated store. That is exactly BTCPool's
Kafka → sharelog → MySQL-aggregates pipeline, arrived at independently.

## Failure modes worth recording

- **PgBouncer is required, not optional, at high connection counts** — 23,000 client connections vastly
  exceeds PostgreSQL's default `max_connections`; transaction-pooling mode with ~100 backend connections
  is the documented answer.
- **Redis Streams grow unbounded** unless trimmed — `XADD MAXLEN` / `XTRIM` plus consumer-lag monitoring.
  Memory exhaustion is the failure mode.
- **ClickHouse with `insert_quorum = 0`** acknowledges inserts that are not yet replicated; set ≥ 2 if the
  data matters.
- **QuestDB HTTP retry is at-least-once** → duplicates require deduplication downstream, which for shares
  means the same replay-detection problem appears again in the storage layer.

## Retention and compression

TimescaleDB: hypertable chunks, continuous aggregates for downsampling, **90%+ compression**, and
`DROP` of old chunks as an instant operation with no table scan. ClickHouse: partition by day/month,
TTL policies, per-column codecs, 44× observed at Cloudflare.

Both point the same way as MySQL `DROP PARTITION` and RocksDB `delete_range_cf`: **retention must be a
metadata operation, not a `DELETE`.** Every implementation that got this right made the time dimension
part of the physical layout.
