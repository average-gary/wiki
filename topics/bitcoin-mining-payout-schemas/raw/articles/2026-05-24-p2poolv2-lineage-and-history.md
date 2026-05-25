---
title: "p2poolv2 lineage: forrestv → SChernykh → Braidpool → p2poolv2"
publication: multiple primary repos
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [history, lineage, forrestv, SChernykh, braidpool, p2poolv2, pool2win]
---

# Decentralized Share-Chain Pool Lineage

The four-generation lineage from forrestv (2011) to p2poolv2 (2024+).

## Generation 1: forrestv p2pool (2011-2017, Python, Bitcoin)

- Linear share chain (no uncles).
- Fixed PPLNS window: `min(3 × avg_work_per_block, 8640)` shares ≈ 3 days.
- Direct coinbase payouts to every miner in the window.
- 30-second share-chain block time.
- Peak ~1.5 PH/s late 2013/early 2014 (~10-15% of network).
- **Decline drivers**: orphan rate at scale, dust outputs as miners joined, hardware incompatibilities, Python codebase had no async/test harness.
- Last release v17.0 Aug 2017.

## Generation 2: SChernykh Monero p2pool (2021+, C++, Monero)

- **First public release ~March 2021** by SChernykh (also the XMRig author).
- Same direct-coinbase pattern as forrestv, but adds:
  - **Uncle blocks** for first-class orphan inclusion ("all your shares will be accounted for")
  - **2160-block (~6h) auto-adjustable PPLNS window** (vs. forrestv's fixed)
  - **Tiered sidechains** (main / mini / nano) for hashrate diversity
- v4.0 hard fork (Oct 12, 2024) added merge-mining for Tari, DarkFi, Townforge.
- **Survives because Monero economics tolerate fat coinbases** (low tx volume, RandomX CPU/GPU mining base, no ASIC concentration).
- ~2k stars, dominant Monero pool implementation by 2026.
- **Critical**: it works for Monero precisely because the constraints that killed forrestv on Bitcoin (coinbase blockspace cost, ASIC concentration) don't apply.

## Generation 3: Braidpool spec (Bob McElrath, ongoing 2022-present)

- **Theoretical leap**: full **DAG of beads** with **UHPO (Unspent Hasher Payment Output)** rolling-payout transaction.
- Beads grouped between graph cuts into "cohorts"; ~2.42 beads/cohort target via Lambert-W difficulty tuning.
- **Conflict resolution**: SSDW (Simple Sum of Descendant Work) — DAG analog to longest-chain.
- Share weight: `s = 1 / (x · (1 - P_{≥2}))` — accounts for orphan risk explicitly.
- **PPLNS-2016**: fixed window of 2016 share-chain blocks (one Bitcoin retarget).
- **Implementation**: pool2win is the impl maintainer; Bob McElrath is the original DAG/braid theorist.
- **Blocker**: UHPO requires CTV/TXHASH-class soft fork — not currently in Bitcoin.

## Generation 4: p2poolv2 (pool2win + contributors, Rust, Bitcoin, ~2024-2026)

- **Pragmatic implementation**: ships now on existing Bitcoin consensus rules, no soft fork.
- **Chain-with-up-to-3-uncles** (DAG-lite, not full braid).
- **Work-bounded PPLNS window**: 133,056 shares (~2 weeks of work). Walked newest→oldest until accumulated weighted difficulty crosses block target. Default deployment uses 7-day window.
- **Uncle weight 90%, nephew bonus +1/10 per referenced uncle**, integer-scaled (`u128`).
- **Atomic-swap small-miner payout** via P2WSH/P2TR HTLCs — addresses the coinbase blockspace cost that killed forrestv at scale.
- **Local vardiff stratum** targeting 3-second shares per miner.
- v0.10.16 released 2026-05-19. 17 total releases. Currently signet-default deployment.
- **Lead**: pool2win (Jungly) — also maintains Braidpool. Independent of 256 Foundation funding.

## p2poolv2 explicitly identifies forrestv's failures

Per the project wiki "P2Pool vs P2Poolv2":

1. High-latency orphans on linear chain → **fixed by uncles**
2. No per-miner vardiff (entire-pool difficulty in stratum, low hashrate sample rate) → **fixed by local vardiff**
3. Direct coinbase payouts consumed too much blockspace, capping pool size → **partially fixed by atomic-swap edge**
4. Python codebase had no async/test harness → **fixed by Rust rewrite**

## Sibling projects

- **Braidpool** (also pool2win + Bob McElrath) — more ambitious; needs Bitcoin soft fork
- **Frost-federation** (also pool2win) — FROST threshold-sig federation
- **Hydrapool** (256 Foundation, lead = pool2win) — depends on `p2poolv2_lib`

## Synthesis

The 4-gen lineage shows **two parallel branches** since 2021:

1. **Engineering pragmatism**: forrestv → SChernykh (Monero) → p2poolv2 (Bitcoin)
2. **Theoretical ambition**: forrestv → Braidpool spec

p2poolv2 is the engineering branch. Braidpool is the theoretical branch. **Both have the same maintainer (pool2win) on the impl side**, suggesting a shared design vision shipped in two flavors: one immediate, one soft-fork-dependent.

## See also

- [[../../wiki/concepts/p2pool-share-chain|p2pool / p2poolv2 concept article]]
- [[2026-05-24-256-foundation-overview|256 Foundation]]
- [[2026-05-24-hydrapool-256-foundation|Hydrapool]]
