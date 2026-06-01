---
title: "DEMAND pool (dmnd.work) and dmnd-easy-sv2"
source: https://dmnd.work
type: articles
tags: [demand-pool, dmnd, easy-sv2, sv2-tooling]
summary: "DEMAND markets itself as 'world's first Stratum V2 mining pool' — owns stratumv2.org redirect. Open-source repos include dmnd-easy-sv2 ('lib to build very simple sv2 proxies'), share-accounting-ext, pplns-with-job-declaration, sv2-tp (C++ template provider). DEMAND has the substrate to ship a reverse translator commercially even though they don't advertise one yet."
confidence: medium
ingested: 2026-05-28
ingested_by: path5
quality_score: 4
---

# DEMAND pool ecosystem

## Brand position

- DEMAND markets as "world's first Stratum V2 mining pool."
- Owns `stratumv2.org` (redirects to dmnd.work). This is significant brand capture — the canonical SV2 domain points to one specific pool.

## Open-source repos (github.com/dmnd-pool)

- `dmnd-easy-sv2` — "Lib to build very simple sv2 proxies."
- `dmnd-sv2-connection`
- `share-accounting-ext`
- `pplns-with-job-declaration`
- `sv2-tp` — C++ Template Provider.

## Why this matters for the reverse-translator question

- DEMAND has the proxy-building substrate to ship a reverse translator commercially. They have not advertised one.
- If you don't choose DEMAND, every other production pool is SV1 — meaning the operator with an SV2 stack who wants pool diversity (multi-pool failover, rate shopping) needs a reverse translator.
- DEMAND's incentive is *to be the SV2 pool*, not to build tooling that lets operators mine to other pools using SV2 stacks. So the reverse translator likely won't come from them.

## See also

- [[2026-05-28-path5-pool-software-landscape]]
- [[2026-05-28-path5-mempool-space-pools-snapshot]]
