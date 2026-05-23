---
title: "Bitcoin pool concentration snapshot 2026-05-22"
source_url: https://hashrateindex.com/hashrate/pools, https://mempool.space/mining
type: data-snapshot
ingested: 2026-05-22
quality: 5
confidence: high
tags: [data, pool-concentration, hashrate, decentralization]
---

# Bitcoin pool concentration snapshot — 2026-05-22

Two independent measurements (Hashrate Index EH/s + mempool.space block counts) used for cross-validation.

## Network totals
- Hashrate: **969-973 EH/s**
- Difficulty: **136.61T**, next adjustment estimated -0.81%

## Top pools (Hashrate Index, EH/s + share)
| Pool | EH/s | Share |
|---|---:|---:|
| Foundry USA | 322 | 31.2% |
| AntPool | 172.4 | 16.7% |
| F2Pool | 118.7 | 11.5% |
| SpiderPool | 107.3 | 10.4% |
| ViaBTC | 83.6 | 8.1% |
| MARA | — | 5.8% |
| SecPool | — | 4.5% |
| Luxor | — | 2.5% |
| BraiinsPool | — | 1.7% |
| **OCEAN** | 17.5 | 1.7% |
| Binance | — | 1.5% |
| SBI | — | 1.3% |

## mempool.space (block-count, 1-week window)
- Top 5 = **77.68%** of blocks
- 22 distinct pools tracked
- Empty blocks last week: 3 (AntPool, SECPOOL, BTC.com — 1 each)

## Derived
- **Nakamoto coefficient (block production) = 3** (top-2 = 47.9%, +any third pool > 51%)
- Foundry alone is **18.4×** larger than OCEAN (322 / 17.5 EH/s)

## p2pool historical share
- 2011-06: 110 GH/s at launch
- 2012-01: 120-150 GH/s
- Today (per bitcointalk thread title): ~1.5 PH/s
- vs network ~970 EH/s: **~0.00015%** of hashrate — effectively zero
- 2013-2014 anecdotal peak: ~1-2% of network

## OCEAN intra-pool concentration
- Top miner controls **6.27 EH/s = 22.97%** of OCEAN's hashrate (significant intra-pool concentration even at decentralization-focused pool)

## Implication
The starting condition for p2poolv2 is severe: top-3 pools control >50%, decentralized alternatives are <2% combined. Variance smoothing (centralized FPPS) is winning the demand-side battle decisively.
