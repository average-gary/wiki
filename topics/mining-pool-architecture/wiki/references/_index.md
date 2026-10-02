# references Index

> Compiled references articles for mining-pool-architecture.

Last updated: 2026-09-23

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [pool-sizing-model.md](pool-sizing-model.md) | Citable constants with derivations shown and two commonly-quoted figures corrected. Network state 2026-09 (945.8 EH/s, difficulty 132.76 T, cross-checked). The central relation: aggregate share rate is `connections / vardiff interval` with **no hashrate term**, so pool load is set by socket count, not by hashrate behind them. Nonce exhaustion (43 µs bare, 720 s with version rolling). SV2 wire sizes including the framing and AEAD overhead usually omitted. Corrected per-share validation cost and core counts. Bandwidth lands in single-digit Mbit/s. | sizing, capacity-planning, shares-per-second, difficulty-math, nonce-exhaustion, validation-cost, derived-constants | 2026-09-21 |
| [pool-protocol-timeline.md](pool-protocol-timeline.md) | Dated lineage from `getwork` to the Core Mining IPC interface, with the forcing function behind each transition and a ✅/⚠️/❌ provenance mark on every date. The recurring pattern: the option better on the axis nobody is currently paying for loses to the option that solves the operator's present problem — BIP 23 specified miner template control in Feb 2012 and lost to Stratum six months later on deployability. Ends with a table of bug classes recurring from slush0's 2012 implementation to SRI in 2026, and a list of dates this round could not verify. | timeline, getwork, getblocktemplate, stratum-v1, stratum-v2, bip310, mining-ipc, forcing-functions | 2026-09-21 |
| [share-storage-architectures.md](share-storage-architectures.md) | **The database deliverable.** Every share-storage design found across eight implementations, with transcribed schemas. The governing result is a natural experiment: nobody in production writes one durable row per share, and the single design that does — MPOS, with a primary key plus four secondary indexes and no batching — is the only one with a documented scaling failure. Raw per-share rows are transient wherever they exist: 24 hours, 7 days, or deleted at payment. Covers aggregation, binary `COPY`, Kafka's two opposite topic configs, RocksDB time-prefixed keys, retention as a metadata operation, and durability windows. | share-storage, schema, write-amplification, batching, aggregation, retention, partitioning, kafka, postgresql-copy, rocksdb, index-cost | 2026-09-22 |

## Categories

- **capacity-planning**: pool-sizing-model, share-storage-architectures
- **history**: pool-protocol-timeline

## Recent Changes

- 2026-09-23: `share-storage-architectures` now covers nine implementations (+Blitzpool: Redis stream → Lua buckets, the PostgreSQL HOT-update measurement, never-pruned lifetime aggregates).

- 2026-09-22: Round 2 — added `share-storage-architectures`; `pool-sizing-model` gained measured SV1-vs-SV2 latency figures and retracted its no-benchmark claim.

- 2026-09-21: Two reference articles compiled from research round 1.
