---
title: Pool Hopping
type: concept
created: 2026-05-23
confidence: high
tags: [attack, pool-hopping, proportional, PPLNS, Rosenfeld]
---

# Pool Hopping

The original miner-vs-pool attack. Motivated PPLNS in 2011.

## Mechanism (against proportional payout)

Under proportional, expected per-share payout in a round is:

`E[reward per share] = B / N(round)`

where `N(round)` is the number of shares accumulated so far. As the round goes long, expected per-share payout **drops** — eventually below the long-run mean.

A pool hopper:
- Joins early in a round (high E[per-share payout])
- Leaves once `E[per-share]` crosses below their honest baseline
- Joins another pool starting a fresh round

Rosenfeld 2011 quantified the gain: a continuous miner can lose ~**43%** of fair earnings to a hopper. Breakeven point ≈ **43.5%** of difficulty.

## Why PPLNS / geometric / TIDES kill it

Under PPLNS, payout depends on the **last N shares** at block-find time — i.e. on **future** events, not on round-position. Future blocks are i.i.d. → expected per-share payout is constant regardless of when you submit. There's no signal for the hopper to time on.

Geometric method, DGM, slush score-based, TIDES, SLICE — all of these inherit the "future-block-dependent payout" property.

## Status today

- **Vanilla proportional**: extinct in production. Still cited as the negative case.
- **Pool-hopping in the wild**: observed empirically in 2010-2012 (Rosenfeld; Tovanich et al. 2021 retrospective). Not a meaningful concern post-2014 because all major pools moved to FPPS/PPS+/PPLNS.

## Don't confuse with

- **Block withholding (BWH)**: miner finds a block but doesn't submit it. Sabotage. *See [[block-withholding]].*
- **Selfish mining**: miner mines on private chain. Rare in practice.
- **Strategic pool diversification** (Chatzigiannis et al. 2022): legit portfolio behavior, not exploitation.

## Sources

- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]]
- [[../../raw/articles/2026-05-23-rosenfeld-pplns-bitcointalk-2011|Original PPLNS proposal]]

## See also

- [[pplns]]
- [[block-withholding]]
- [[variance-and-risk-shifting]]
