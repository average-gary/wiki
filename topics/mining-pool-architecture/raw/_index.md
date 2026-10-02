# Raw Sources Index

> All immutable raw source material for mining-pool-architecture.

Last updated: 2026-09-23

## Contents

| Type | Count | Index |
|------|-------|-------|
| articles | 6 | [articles/](articles/_index.md) |
| papers | 6 | [papers/](papers/_index.md) |
| repos | 9 | [repos/](repos/_index.md) |
| notes | 4 | [notes/](notes/_index.md) |
| data | 5 | [data/](data/_index.md) |

**30 raw documents**, covering ~80 distinct source URLs (several files bundle a primary source with its
`related_sources`, and the three notes files each aggregate multiple thin or secondary sources).

## Confidence distribution

Worth reading before citing anything from this corpus:

| Confidence | Count | Files |
|---|---|---|
| **high** | 15 | Hardening Stratum (PETS 2017), withholding economics, SmartPool, BIP 22/23, BIP 310, Stratum V1 announcement, Core Mining IPC, Optech #423 vardiff, adjacent-systems transfer, **+R2:** SRI persistence source read, share-accounting-ext source read, pool persistence schemas source read, stateful-TCP routing options, **+09-23:** Blitzpool source read |
| **medium** | 10 | ckpool, sv2-apps roles, SRI/sv2-apps hardening releases, public-pool + Miningcore, solo.ckpool operations, measurement study (stale window), sizing constants, **+R2:** pool anycast/failover, production pool DBs, SV2 benchmark reports |
| **low** | 5 | SRI open issues (numbers unverified), SV2 vendor performance claims (`do_not_cite_as_fact`), DMND/DATUM deployments (adoption unevidenced), failure-modes aggregate (causal claims are inference), protocol lineage (secondary/vendor), **+R2:** ingest engines (one figure misread, recommendations over-built) |

## Corrections applied during ingest

Two of the researching agents' figures did not survive checking and were corrected rather than carried:

1. **Share rate.** "~1.09M shares/sec at a top pool" assumed a uniform pool difficulty. Vardiff makes
   aggregate share rate `connections / target interval` — no hashrate term — so the realistic figure is
   ~2,300 shares/sec at 23,000 connections, three orders of magnitude lower.
2. **Validation cost.** "50–100 µs per share, ~100 cores at 1M shares/sec" wrongly included a per-share
   Schnorr verification (it is per-connection handshake work) and assumed a merkle rebuild on standard
   channels (the merkle root is fixed per job). Corrected to ~1 µs standard / ~10 µs extended, i.e.
   single-digit cores at 1M shares/sec.

Both errors and their corrections are preserved inline in
[data/2026-09-21-pool-scale-and-sizing-constants.md](data/2026-09-21-pool-scale-and-sizing-constants.md).

## Round 2 corrections and one retraction

- **RETRACTED**: "no benchmark of any pool software exists". Two empirical SV1-vs-SV2 benchmarks on real
  ASICs are published with a reusable harness. The narrower surviving gap is that nothing compares pool
  *implementations* to each other.
- **Corrected**: the 2026 SRI bounded-storage caps are **client-side only**; the pool server's `JobStore`
  HashMaps remain unbounded and `stale_jobs` are never cleared.
- **Corrected**: ckpool's `-L` sharelog is written **synchronously by the stratifier**, on the share path,
  not by a dedicated thread. And `ckdb`, its PostgreSQL companion, existed and was disabled in 2017.
- **Corrected**: a widely-cited "3–4k rows/sec" PostgreSQL figure is a *delta* against TimescaleDB, not a
  capacity — understating PostgreSQL by ~50× and invalidating the engine ladder built on it.
- **Downgraded**: round 1's claim that "many newer stratum clients ignore `client.reconnect`" was not
  substantiated by any source and is now marked unverified.
- **Agent conflict resolved**: one agent concluded GeoDNS is what pools use; another resolved the actual
  DNS and found Cloudflare anycast. The measurement wins.

## Recent Changes

- 2026-09-23: Follow-up — Blitzpool server + rental proxy source read (1 document). Covered in round 2's
  exclusion by mistake: its upstreams are public, so it was never employer-internal.

- 2026-09-22: Research round 2 — 8 agents (4 reading local public source checkouts, 4 web). 8 documents
  added, covering regional routing, share persistence, and database architecture.

- 2026-09-21: Research round 1 — 21 documents ingested from 8 parallel research agents (academic,
  technical, applied, news, contrarian, historical, adjacent, data).
- 2026-09-21: Directory created by topic init.
