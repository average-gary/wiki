---
title: PPLNS (Pay Per Last N Shares)
type: concept
created: 2026-05-23
confidence: high
tags: [PPLNS, Rosenfeld, hop-resistant]
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

## Sources

- [[../../raw/articles/2026-05-23-rosenfeld-pplns-bitcointalk-2011|Rosenfeld bitcointalk PPLNS proposal (2011)]]
- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011 paper]]
- [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers et al. FC'16]]

## See also

- [[payout-schema-taxonomy]]
- [[fpps]]
- [[pool-hopping]]
- [[variance-and-risk-shifting]]
