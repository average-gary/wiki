---
title: PPLNS (Pay Per Last N Shares)
category: concept
created: 2026-05-23
confidence: high
tags: [pplns, Rosenfeld, hop-resistant]
volatility: warm
updated: 2026-07-30
summary: "Proposed by Meni Rosenfeld on bitcointalk, 2011-08-28. Designed to fix the pool-hopping vulnerability of proportional payout."
verified: 2026-07-30
sources:
  - "raw/articles/2026-05-23-rosenfeld-pplns-bitcointalk-2011.md"
  - "raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis.md"
  - "raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility.md"
---

# PPLNS — Pay Per Last N Shares

Proposed by **Meni Rosenfeld** on bitcointalk, 2011-08-28. Designed to fix the pool-hopping vulnerability of proportional payout.

## Mechanism

- When a block is found, the **last N shares** (by cumulative score, where each share is scored `1/D`) are paid proportionally.
- Per-share expected payout is **independent of round position** (future blocks are i.i.d.) → kills the hop strategy.
- Variants:
  - Sharp 0/1 cutoff
  - Exponential decay (geometric method)
  - Linear decay

## Why it works against pool hopping

Under proportional, expected payout per share **falls** as the round goes long. Hoppers join early, leave when expectation crosses a threshold, extract ~28% above honest EV. Under PPLNS, expected payout per share is constant — there's no signal for the hopper to time on.

## Tradeoffs

- **Variance shifted to miners.** Long unlucky runs hit miners directly. PPS-style smoothing is gone.
- **Late-joiners get paid for blocks they didn't contribute to** (still in the rolling window when block found).
- **Early-leavers forfeit unmatured shares.** Some PPLNS variants soften this with maturity decay.
- **Operator reserve requirement: low.** Pool only pays out what it received; no deficit risk.

## IC parameter sensitivity (Schrijvers et al. FC'16)

PPLNS is incentive compatible *only under specific parameter regimes*. Compatibility depends on N relative to round length. **Small-N PPLNS approaches proportional and loses IC.**

## Modern derivatives

- **TIDES** (OCEAN 2024): `N = 8 × current_block_difficulty`, full-resolution share log, non-custodial. *See [[tides]].*
- **SLICE / PPLNS-JD** (DMND): PPLNS where shares are bound to SV2 JD jobs. *See [[pplns-jd]].*
- **p2pool / p2poolv2**: on-chain PPLNS, no operator. *See [[p2pool-share-chain]].*
- **eHash** (hashpool): not strictly PPLNS, but inherits the "pay per share, with variance to miner" property. *See [[ehash]].*
- **Lottery-PPLNS**: a flat bounty is carved out for the block finder, PPLNS splits the remainder. Expectation-neutral for every miner; a pure variance trade. *See [[lottery-pplns]].*

## Window units: a difficulty-denominated N is a share count, not a block count

Two rules learned while specifying share retention against a `8 × D` window
([[../../raw/notes/2026-07-30-ll-pplns-window-units-and-identity-boundaries|lessons 2026-07-30]]):

- **`N = k × D` is a quantity of accumulated share difficulty.** Converting it to wall-clock time
  requires dividing by the **pool's** hashrate, not the network's. "8 × network difficulty" is *not*
  "8 blocks" or "~80 minutes" — that holds only at 100% network share. A 10% pool takes ~13 hours to
  accumulate it, a 1% pool **~5.5 days**, a 0.1% pool ~55 days. Restating a difficulty-denominated
  window in blocks or minutes without naming the pool-hashrate assumption is a ~100× error for a small
  pool, and it lands as under-retention (shares still owed get pruned).
- **An upward difficulty retarget grows the window backwards, so retention must exceed the current
  window.** `D` moves every 2016 blocks; when it rises, walking back from the block accumulates
  further into share history than before, pulling shares that were *outside* the window back *inside*
  it. Pruning to the current edge is a correctness bug whose first symptom arrives one retarget later.
  Bitcoin clamps retargets to 4×, so `4 × N` of accumulated share difficulty is the worst-case-safe
  retention floor at the current `D`, re-evaluated each period — and expressed in difficulty, never a
  clock or a block count.

## Sources

- [[../../raw/articles/2026-05-23-rosenfeld-pplns-bitcointalk-2011|Rosenfeld bitcointalk PPLNS proposal (2011)]]
- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011 paper]]
- [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers et al. FC'16]]

## See also

- [[payout-schema-taxonomy]]
- [[fpps]]
- [[pool-hopping]]
- [[variance-and-risk-shifting]]
- [[lottery-pplns]] — finder-bonus hybrid variant
- [[p2poolv2-accounting.md|p2poolv2 Accounting (deep-dive)]]
- [[parasite-pool.md|Parasite Pool]]
- [[pplns-jd.md|PPLNS-JD / SLICE]]
- [[tides.md|TIDES (Transparent Index of Distinct Extended Shares)]]
- [[../../raw/notes/2026-07-30-ll-pplns-window-units-and-identity-boundaries|Lessons: window units, share retention, identity boundaries]] — where the two window-unit rules above came from
