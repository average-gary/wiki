---
title: Block Withholding (BWH) and FAW
type: concept
created: 2026-05-23
confidence: high
tags: [BWH, FAW, attack, Eyal, Schrijvers, Nash]
---

# Block Withholding (BWH) and Fork After Withholding (FAW)

Inter-pool attack. Pools infiltrate each other; infiltrators submit shares but withhold full block solutions to sabotage the victim's payout.

## Why it works

Under PPS or FPPS, pool pays out per share regardless of block-find. An attacker infiltrator:
- Submits shares (collects per-share payout from victim pool)
- Discards any full-block solution they find (denies victim the block reward)
- Gives attacker pool a relative hashrate advantage at victim pool's expense

Net effect: attacker drains victim's reward buffer.

## Eyal "Miner's Dilemma" (IEEE S&P 2015)

- *"No attacks"* is **never** a Nash equilibrium with multiple open pools.
- Two-pool (or identical) case: equilibrium is tragedy-of-the-commons; all pools attack, all earn less than baseline.
- **Profitable BWH**: attacker shares attack revenue with own loyal miners → positive-EV under realistic parameters.

## Schrijvers et al. (FC'16)

- Proves **proportional is not IC** (incentive compatible) — miners are incentivized to withhold blocks.
- **PPS is IC** but operator bears variance.
- **PPLNS is IC only under specific parameter regimes** (large-N relative to round length).
- Constructs a novel IC reward function preserving steady-payout property.

## FAW (Kwon et al. CCS 2017)

Fork After Withholding. Strict generalization of BWH.

**Mechanism**: Attacker with hashrate α joins target pool with infiltration τ. On finding an FPoW via infiltration, **withholds it**. If an external honest miner publishes a block, attacker **immediately submits the withheld FPoW** → fork. With probability `c` the attacker's branch wins.

**Profit (Theorem 5.1)**: Always ≥ pure BWH. Equal only when `c=0`.

**Worked numbers** (α = β = 0.2):
- c = 0 (BWH-equivalent): RER 1.14%
- c = 0.5: RER 1.74%
- c = 1: RER 3.75%

Multi-pool with F2Pool-class attacker (~20%): **+56.24%** more reward than BWH (4.63% vs 2.96% RER).

**Resolution of the miner's dilemma (Theorems 7.1-7.2)**: Unlike pure BWH (symmetric prisoners' dilemma), FAW becomes a **"pool size game"** — larger pool wins extra reward at unique Nash equilibrium. **Smaller pool can be net-loser while larger pool stays profitable.** This is the paper's headline novelty and explains why a Foundry-class pool could rationally launch FAW where pure BWH would zero out via mutual sabotage.

**Mitigation**: Two-phase PoW (requires hard fork), decentralized pools (P2Pool, p2poolv2), fork-rate detection. Authors: *"finding a cheap and efficient countermeasure remains an open problem."* **No deployed mitigation as of 2026.**

## Implication for modern schemes

Reward functions cannot be analyzed in isolation. Cross-pool attacks make the system-wide equilibrium worse than any single-pool design predicts.

**The 2024-2026 decentralized schemes sidestep some BWH dynamics** by changing the trust model:

- **eHash (hashpool)**: no internal ledger to manipulate; can't profitably infiltrate a pool that doesn't track per-miner accounts.
- **PPLNS-JD / SLICE**: miners declare their own jobs; infiltrating to withhold is structurally weaker because the attacker isn't choosing the template.
- **p2poolv2**: no operator → no buffer to drain.

These don't *eliminate* BWH (an attacker can still discard solutions found on a victim's mempool), but they remove the attack's monetary surface.

## Important nuance: profit vs incidence

The BWH/FAW/selfish-mining literature is **payout-scheme-agnostic on attacker profit** — formal models assume proportional reward per share and don't differentiate FPPS / PPLNS / TIDES / SLICE. Vulnerability is a property of any scheme that pays for shares without verifying full-PoW reveal.

**But the *incidence* of damage shifts by scheme** (an open observation, not a cited result):

- **FPPS / PPS**: pool operator absorbs the loss (operator pays for shares regardless of whether real blocks land).
- **PPLNS / TIDES / SLICE**: miners absorb the loss (pool only pays when blocks confirm; sabotage = no payout for that round).
- **eHash (hashpool)**: open question — issuance is per share, but redemption is per block.

So FAW *profit to attacker* is scheme-invariant. FAW *who-gets-hurt at the victim pool* is scheme-dependent.

## Sources

- [[../../raw/papers/2026-05-23-eyal-2015-miners-dilemma|Eyal IEEE S&P 2015]] (BWH)
- [[../../raw/papers/2026-05-23-kwon-2017-faw|Kwon et al. FAW (CCS 2017)]] — primary
- [[../../raw/papers/2026-05-23-eyal-sirer-2014-selfish-mining|Eyal & Sirer 2014 — Majority is Not Enough]]
- [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers et al. FC'16]]
- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]]

## See also

- [[pool-hopping]]
- [[variance-and-risk-shifting]]
