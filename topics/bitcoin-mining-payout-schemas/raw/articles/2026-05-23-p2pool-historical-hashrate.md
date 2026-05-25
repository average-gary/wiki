---
title: "p2pool historical hashrate (forrestv 2011-2017)"
publication: bitcointalk + p2pool.org
url: https://bitcointalk.org/index.php?topic=18313.0
url2: https://p2pool.org
type: article
ingested: 2026-05-23
quality: 4
credibility: high
confidence: medium
tags: [p2pool, history, hashrate, ASIC, decline]
---

# p2pool Historical Hashrate (forrestv 2011-2017)

## Peak hashrate

**~1.5 PH/s (1500 TH/s)**, advertised in bitcointalk thread title circa **late 2013 / early 2014**. One snapshot showed 1900 TH/s with 13.7% stale rate ("Pool: 1900 TH/s, Stale rate: 13.7%, Expected time to block: 12.4 hours.").

Bitcoin network hashrate at that time: ~10 PH/s. **p2pool peak ≈ 10-15% of network hashrate at one point** (much higher than commonly remembered).

## Title progression (bitcointalk topic 18313)

The forrestv-maintained thread title tracked p2pool's growth:

- 110 GH/s (initial)
- 150 GH/s (Jan 2012)
- 700 GH/s (~mid-2012)
- 1100 GH/s (July 2013)
- **1500 TH/s** (late 2013 / early 2014, peak)

## Total blocks found

**Not retrievable from accessible sources.** Block-count history was hosted on `p2pool.in/stats` and `forre.st:9332/`, both dead. The original payout address `1Kz5QaUPDtKrj5SqW5tFkn7WZh8LmQaQi4` referenced in the thread could be queried via blockexplorer for an authoritative count — recommend follow-up.

## Decline curve

Peak Q4 2013 / Q1 2014, then **steady erosion through 2014-2017**. Forrestv's last release was **v17.0 (Aug 2017)**, marking SegWit support and effectively the project's end. p2pool.org notes: *"The original P2Pool repository has been effectively dormant since the late 2010s."*

## Why it died (per p2pool.org steward analysis + FiberPool 2025 academic paper)

Three structural failures:

1. **Variance.** Share-chain ran at higher effective difficulty than centralized pools as ASICs scaled.
2. **Coinbase bloat.** Generation tx grew very large paying thousands of miners directly.
3. **Dust economics.** As fees climbed, small-miner payouts went sub-economic.

FiberPool 2025: *"the low hashrate of the miners participating in P2Pool"* — structural complaint that intensified post-ASIC because GH/s-class FPGAs/GPUs couldn't generate shares fast enough vs the pool's share-difficulty floor.

## Important disambiguation

The "p2pool" name was later **reclaimed by SChernykh's Monero p2pool (2020+)** — a different codebase, often confused with forrestv's. The Monero p2pool succeeded; the original Bitcoin p2pool did not.

**p2poolv2 (2024+)** is the modern Bitcoin revival with formal TLA+ spec and atomic-swap support transactions — distinct from both.

## Sources

1. bitcointalk topic 18313 ("[1500 TH] p2pool") — Quality 4. 814 pages, 2.59M reads. Active 2011-2017.
2. p2pool.org steward site — Quality 3. Dormancy + structural-failure diagnosis.
3. github.com/forrestv/p2pool — Quality 3. 1.2k stars, last forrestv release v17.0 (Aug 2017).
4. FiberPool (2025) academic paper — Quality 3. Variance / share-difficulty diagnosis.

## Open gaps

- Total Bitcoin blocks found by p2pool over its lifetime — not captured here. Wayback snapshots of p2pool.in/stats remain inaccessible from this fetch profile.
- Year-by-year hashrate decline curve — qualitative only.

## See also

- [[../../wiki/concepts/p2pool-share-chain|p2pool / p2poolv2 concept article]]
