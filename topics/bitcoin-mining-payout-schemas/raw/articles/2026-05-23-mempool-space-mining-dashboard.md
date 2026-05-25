---
title: "mempool.space mining dashboard"
publication: mempool.space
url: https://mempool.space/mining
type: article
ingested: 2026-05-23
quality: 4
credibility: high
confidence: high
tags: [data, hashrate, pool-share, centralization]
---

# Pool Hashrate Distribution (mempool.space, May 2026)

Live data — last block 950,671. Network hashrate **979.18 EH/s**, difficulty **136.61T**.

## 1-week pool share

| Pool | Blocks | % |
|---|---|---|
| Foundry USA | 311 | 30.88 |
| AntPool | 181 | 17.97 |
| F2Pool | 114 | 11.32 |
| SpiderPool | 94 | 9.33 |
| ViaBTC | 78 | 7.75 |
| MARA Pool | 58 | 5.76 |
| SECPOOL | 35 | 3.48 |
| OCEAN | 31 | 3.08 |
| Luxor | 27 | 2.68 |
| SBI Crypto | 19 | 1.89 |
| Binance Pool | 17 | 1.69 |
| Braiins Pool | 16 | 1.59 |

## Concentration

- Top 2 (Foundry + AntPool) ≈ **48.85%** — close to majority.
- Top 5 ≈ **77.25%**.

## Block-finding cadence math

At 979 EH/s and 144 blocks/day:
- 30 EH/s pool (OCEAN, ~3%) → ~**4.4 blocks/day**.
- 1 EH/s solo miner → ~**0.147 blocks/day** = one block every ~6.8 days.

## Implication for payout-scheme analysis

Variance horizon for a mid-size miner under PPLNS/TIDES/SLICE depends on the pool's block-finding cadence. OCEAN's ~4 blocks/day is enough that a miner with 0.5% of OCEAN's hashrate sees a payout-eligible block roughly daily — but TIDES's 8×D window means each share is paid across ~8 such events, smoothing the curve.

Compare to a 1% pool (Luxor 2.68%): ~3.9 blocks/day; 0.5% pool (under 5 EH/s): ~0.7 blocks/day → variance dominates short-horizon for small pools.
