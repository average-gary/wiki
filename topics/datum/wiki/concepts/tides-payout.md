---
title: "TIDES payout"
category: concept
sources:
  - raw/articles/2026-05-28-ocean-tides-technical-documentation.md
  - raw/articles/2026-05-28-ocean-origins-of-datum.md
created: 2026-05-28
updated: 2026-05-28
tags: [tides, ocean, payout, pplns, share-log, generation-transaction, non-custodial, jason-hughes]
aliases: ["TIDES", "Transparent Index of Distinct Extended Shares"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "OCEAN's reward system: a PPLNS variant that pays via the coinbase generation transaction with an 8×network-difficulty share log window. Non-custodial — rewards land directly with the miner, never in pool custody. Shares stay in the log forever (anti-pool-hop, difficulty-adjustment-friendly), giving submitted shares a 99.9665% chance of earning at least once."
---

# TIDES payout

> **TIDES** = **T**ransparent **I**ndex of **D**istinct **E**xtended **S**hares. OCEAN's reward system, designed by Jason Hughes. Lives on a different layer than [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) — TIDES answers "given that I submitted shares, what fraction of the block reward do I get?" while DATUM answers "who chooses which transactions go into the block I'm hashing on?" — but TIDES is the payout mechanism that makes DATUM's "non-custodial coinbase payouts" pitch real.

## Scope of this article

This article summarizes TIDES *as it intersects DATUM Gateway*. The full payout-math taxonomy (TIDES vs PPLNS vs FPPS vs PPS+ vs solo) lives in the sibling wiki `bitcoin-mining-payout-schemas`. Refer there for cross-pool comparison; this article focuses on the property set DATUM operators care about.

## The core mechanic

1. **Share log.** Every valid PoW share submitted to the pool is appended to a single ordered log. Shares are *never removed* — the log grows forever.
2. **Window.** When OCEAN finds a block, the pool computes a share-log window of `8 × network_difficulty` worth of work, walking from the top of the log downward.
3. **Distribution.** Each miner's share count within the window divides the block reward (subsidy + fees) pro-rata.
4. **Payout.** The pool's [[gateway-data-flow|generation transaction]] ([Gateway data flow](gateway-data-flow.md)) for the new block contains one output per eligible miner — the reward goes directly to them as part of the block being mined.

The formula, with `shares_w` total shares in the window, `shares_m[i]` miner *i*'s shares, and `r` the current block reward:

```
each miner i receives:  (shares_m[i] / shares_w) × r
```

## Why "the log is never trimmed" matters

Two consequences:

- **Anti-pool-hop.** A miner can't game the system by hopping in/out — shares stay eligible across the 8-block window regardless. This is what older PPLNS implementations using "shifts" were trying to approximate; TIDES does it directly.
- **Difficulty-adjustment friendliness.** When network difficulty rises, the window expands (in share count); previously-aged-out shares re-enter eligibility. When difficulty drops, the window contracts. For continuous miners, share-of-window stays roughly stable across adjustments — predictable rewards per unit of work.

The TIDES doc states the design principle directly:

> *"Shares are never removed from the share log."*

## Variance and the "ramp-up"

At an 8-block window, individual shares have a **99.9665%** chance of being credited at least once, and average ~8 credits each across their lifetime in the window. That's the variance-reduction property OCEAN's framing depends on.

Two consequences for new miners:

- **Ramp-up period.** Until enough shares accumulate at the top of the log to fill the miner's notional share of the window, earnings are lower than steady-state. Ramp duration is inversely proportional to the pool's hashrate — bigger pool, shorter ramp.
- **Offline tolerance.** If a miner goes offline temporarily, shares from before the outage stay in the window. Earnings don't zero out. Re-entry rebuilds share distribution gradually.

## The non-custodial property

This is where TIDES connects back to DATUM's pitch. Per the TIDES doc:

> *"Implementing TIDES with payouts from the generation [transaction] enhances security by ensuring miners' rewards are directly linked to their contributions without the need to trust pool operators."*

In a custodial PPLNS pool, the operator receives all block rewards into a pool wallet, then pays miners on a separate schedule — miners must trust the operator not to lose, abscond with, or be legally compelled to freeze their funds. With TIDES + coinbase payouts, the block being mined *is* the payout: the moment the block confirms, every eligible miner has their reward in their own UTXO, with no intermediate custody.

This is what "non-custodial coinbase payouts" means in [[datum-history-and-motivation|the DATUM motivation essay]] ([DATUM history and motivation](datum-history-and-motivation.md)) and on the OCEAN homepage.

## Pool-side implementation requirement

TIDES requires the pool to track every share with its position in the log:

> *"When work is given to a miner, that work is internally tagged with the share ID of the share currently at the top of the share log."*

At a network difficulty of ~136.6 trillion (point-in-time figure quoted in the spec), the 8-block window is about 1.09 quadrillion shares wide — must be tracked continuously without losing resolution. This is operationally non-trivial but not exotic.

## Edge cases worth knowing

- **Insufficient log** (early pool, extreme difficulty rise): if the log doesn't yet contain `8 × network_difficulty` worth of work, the entire log is used as the window.
- **Sub-satoshi rewards.** If a miner's pro-rata share rounds to less than 1 satoshi for a given block, it's forfeited. Practically excludes very-low-power miners (CPU/old ASIC).
- **Fees.** Each share carries a fee-rate flag set at submission. Different fee rates may apply per pool policy. Fee calculations are per-miner and round down to the nearest sat.

## How this relates to the gateway operator

DATUM Gateway operators don't need to implement TIDES — that's pool-side. They *do* need to make room in the template for the coinbase outputs that TIDES requires. That's why the [[node-policy-variants|node policies]] ([Node policy variants](../references/node-policy-variants.md)) all set `blockmaxweight=3985000`: leaving ~15,000 weight units for the pool's potentially-large generation transaction. The OCEAN-recommended policy and the three legacy alternates all share this number, which is the TIDES coinbase budget.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — TIDES is the payout layer; DATUM is the template layer
- [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](datum-history-and-motivation.md)) — names "non-custodial coinbase payouts" as a DATUM incentive
- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) — carries the per-miner generation-transaction outputs that TIDES computes
- [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](gateway-data-flow.md)) — the generation-transaction handshake step that fetches TIDES coinbase outputs
- [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — `blockmaxweight=3985000` is the TIDES coinbase budget
- [[lightning-payouts|Lightning payouts]] ([Lightning payouts](lightning-payouts.md)) — alternative payout rail; TIDES still computes the share, BOLT12 just changes how it's delivered

## Sources

- [TIDES Technical Documentation](../../raw/articles/2026-05-28-ocean-tides-technical-documentation.md) — Hughes' formal spec
- [The Origins of DATUM](../../raw/articles/2026-05-28-ocean-origins-of-datum.md) — frames TIDES as part of DATUM's incentive set
