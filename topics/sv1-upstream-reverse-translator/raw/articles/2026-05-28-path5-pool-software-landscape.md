---
title: "Pool software landscape — SV2 adoption gap (2026)"
source: synthesis from mempool.space, public pool sites, GitHub READMEs
type: articles
tags: [sv2-adoption, pool-inertia, hashrate-distribution, market-context]
summary: "By hashrate, ~96%+ of Bitcoin's network hashrate is paid out by pools whose public stratum endpoint is SV1 in 2026. DEMAND is the only major pool marketed as SV2-native. The gap between SV2 stack capability and pool-side adoption is the structural reason a reverse translator exists at all."
confidence: high
ingested: 2026-05-28
ingested_by: path5
quality_score: 4
---

# Pool software landscape — the SV2 adoption gap (2026)

## The gap

- Network hashrate distribution: top-5 pools = ~77.7%; top-8 = ~90%; all paid out via SV1 stratum endpoints.
- DEMAND (`dmnd.work`, owns the canonical `stratumv2.org` redirect) is the only major pool that markets itself as "world's first Stratum V2 mining pool."
- Braiins Pool is SV2-capable but its market share is small relative to top-5.
- BraiinsOS+ firmware ships SV2 client support, but operators using it commonly downgrade to SV1 client mode to mine to Foundry/Antpool/F2Pool.

## Why pools haven't upgraded

- **Engineering cost**: SV2's protocol surface is larger (channels, JD, NewTemplate, Noise transport).
- **No marginal revenue**: pools' competitive moat is hashrate aggregation, not protocol features. Adding SV2 doesn't win them more hashrate today.
- **Job Declaration is a *cost*, not a benefit, for centralized pools**: it transfers template authority away from the pool.
- **Customer ASIC fleets are SV1**: even if a pool deploys SV2, most miners can't talk to it without SV2-capable firmware.

## Why operators want SV2 anyway (and need a reverse translator)

- **Internal hashrate hijacking resistance**: Noise-encrypted intra-network transport.
- **Hierarchical extranonce**: clean fanout to many downstream proxies / channels.
- **Async share submission**: lower-latency reporting between miner and translator.
- **Operational discipline**: SV2 stack hygiene now → smoother future migration when upstream pools eventually upgrade.

The reverse translator is the bridge over the adoption-time gap.

## See also

- [[2026-05-28-path5-mempool-space-pools-snapshot]]
- [[2026-05-28-path5-demand-pool-and-easy-sv2]]
- [[2026-05-28-path5-sjors-bio-recruiting]]
