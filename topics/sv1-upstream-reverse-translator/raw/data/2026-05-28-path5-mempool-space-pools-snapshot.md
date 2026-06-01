---
title: "mempool.space mining pools — 1-week snapshot 2026-05-28"
source: https://mempool.space/mining/pools
type: data
tags: [pool-share, hashrate-distribution, sv2-adoption, mempool-space]
summary: "Top-5 pools (Foundry 30.30%, AntPool 17.64%, F2Pool 11.98%, SpiderPool 9.11%, ViaBTC 8.72%) account for ~77.7% of network hashrate. None confirmed SV2-native. Load-bearing data point for the pool-inertia hypothesis."
confidence: high
ingested: 2026-05-28
ingested_by: path5
quality_score: 5
---

# Pool hashrate snapshot (1-week, 2026-05-28)

| Pool | Share |
|------|-------|
| Foundry USA | 30.30% |
| AntPool | 17.64% |
| F2Pool | 11.98% |
| SpiderPool | 9.11% |
| ViaBTC | 8.72% |
| MARA | 4.70% |
| SECPOOL | 4.22% |
| OCEAN | 3.55% |

Network total ~1.01 ZH/s. Top-5 = ~77.7% of total hashrate.

## SV2 adoption status

Public protocol-version evidence at time of capture:
- **Foundry**: no public SV2 support announcement; stratum endpoint is SV1.
- **AntPool**: no public SV2 support.
- **F2Pool**: no public SV2 support.
- **SpiderPool**: no public SV2 support.
- **ViaBTC**: no public SV2 support.
- **MARA**: SV2 work in progress (internal pool-v4 deployment), but public stratum endpoint is SV1.
- **OCEAN**: SV2 partially supported via DATUM/template-provider variant; not the canonical SRI SV2 protocol.

## Implication for reverse-translator demand

By hashrate, ~96%+ of Bitcoin's network hashrate is paid out by pools whose public stratum endpoint is SV1 in 2026. An SV2-stack operator who wants to mine to *any* of the top-8 pools needs a reverse translator. This is the market-size argument for the tool.

## See also

- [[2026-05-28-path5-pool-software-landscape]]
- [[2026-05-28-path5-demand-pool-and-easy-sv2]]
