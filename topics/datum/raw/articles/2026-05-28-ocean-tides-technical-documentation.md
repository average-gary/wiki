---
title: "TIDES Technical Documentation"
source: "https://ocean.xyz/docs/tides"
type: articles
ingested: 2026-05-28
tags: [ocean, tides, payout, pplns, share-log, generation-transaction, non-custodial, jason-hughes]
summary: "Jason Hughes' (OCEAN founder) technical specification for TIDES (Transparent Index of Distinct Extended Shares). A non-custodial PPLNS-style reward system: shares enter a share log indefinitely, the top-of-log 8×network-difficulty window is paid pro-rata at every block, payouts go directly via the generation/coinbase transaction. Includes formulas, edge cases (insufficient log, sub-satoshi rounding), variance properties (99.9665% chance of reward at 8-block window), and difficulty-adjustment behavior."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "tides"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/tides"
content_format: "html"
authors: ["Jason Hughes"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# TIDES Technical Documentation

> **TIDES** = **T**ransparent **I**ndex of **D**istinct **E**xtended **S**hares.
> A reward system designed to "reduce payout variance as low as possible
> without the pool operator needing to hold and buffer the Bitcoin rewards as
> a custodian." Goal: maximum payouts over time, auditable, non-custodial-
> capable.

## Definitions

- **Generation Transaction:** First transaction in a block, including
  coinbase and block reward.
- **Luck:** Comparison of expected work vs actual work to find blocks.
- **Network Difficulty:** Required work; adjusted every 2,016 blocks.
- **Payout Variance:** Reward fluctuation due to probabilistic block
  discovery.
- **Share / Proof:** Verified PoW with an associated target difficulty.
- **Share Log:** Record of all valid proofs submitted.
- **Share Log Window:** Latest 8 blocks worth of work
  (`8 × network_difficulty`).

## Mechanics

1. **Proof acceptance.** Valid proofs enter the share log at the top in
   submission order.
2. **Window calculation.** When a block is found, window size =
   `8 × block_difficulty`.
3. **Share tally.** Miner shares within the window are counted from the top
   downward.
4. **Proportional distribution.** Block reward (subsidy + tx fees) splits
   pro-rata by each miner's share percentage in the window.

### Formula

Let `shares_w` = total shares in window, `shares_m[i]` = miner *i*'s shares
in window, `r` = current block reward.

```
∑_i (shares_m[i] / shares_w × r) = r
```

## Core Invariant

> "Shares are never removed from the share log."

Continuous eligibility. Anti-pool-hop. Individual shares typically receive
rewards multiple times — averaging ~8 times at the 8-block window size.

## Implementation Requirements

- Must never lose resolution within the share log.
- Every valid proof preserved individually with order.
- At a network difficulty of `136,607,070,854,775` (point-in-time figure),
  the window is `~1,092,856,566,838,200` shares — must be tracked
  continuously.

## Edge Cases

1. **Insufficient share log** (initial pool launch, extreme difficulty
   increase): if fewer than 8 blocks of work exists, use `total_share_log`
   instead of the target window.
2. **Sub-satoshi rewards**: earnings below 1 sat are forfeited — effectively
   excludes very-low-power miners (CPU, outdated ASICs).

## Pool-Specific Implementation

> "When work is given to a miner, that work is internally tagged with the
> share ID of the share currently at the top of the share log."

This enables direct payment via the generation transaction without pool
intermediation — the non-custodial property.

## Variance

At an 8-block window size, "all shares submitted have a 99.9665% chance of
being rewarded at least once."

## Difficulty Adjustments

- **Increase:** Window expands; previously-expired shares re-enter.
- **Decrease:** Window contracts; recent shares exit.
- For continuous miners, "their proportion of the share log window isn't
  going to change much at a difficulty change" — consistent rewards per
  unit of work.

## Fee Handling

- Each share carries a fee-rate flag set at submission time.
- Different fee rates may apply per pool policy.
- Fees are calculated per miner and rounded down to nearest sat.

## Share Lifecycle

1. **Submission** — added at log top.
2. **Window residence** — eligible while in the top 8-block-equivalent
   window.
3. **Continued persistence** — never discarded; retained indefinitely for
   future eligibility (difficulty re-expansion).

## Earnings Patterns

- New miners go through a "ramp-up" period before earning full
  per-block-equivalent rewards.
- Ramp duration ∝ inverse of pool hash rate (faster pools ramp faster).
- Offline periods don't zero out earnings — shares remain in window.
- Re-entry rebuilds share distribution progressively.

## Non-Custodial Design

> "Implementing TIDES with payouts from the generation enhances security by
> ensuring miners' rewards are directly linked to their contributions
> without the need to trust pool operators."

## Distinguishing From PPLNS

> "TIDES is what PPLNS was originally supposed to be."

Existing PPLNS implementations use **shifts** or extremely low **N** values,
which respectively reduce reward accuracy or increase variance.

## Auditability

A miner can independently verify earnings using:

- Pool blocks discovered.
- Overall pool hash rate.
- Personally submitted shares (if tracking with own equipment).

In a non-custodial implementation, this verification works "without the
pool ever even having control over it."

## Cross-Reference

- TIDES is one of the systems catalogued in the `bitcoin-mining-payout-schemas`
  topic; this raw doc is the upstream spec for that catalog entry.
- TIDES's "payouts from the generation transaction" is what the DATUM
  Gateway / OCEAN coinbase construction has to make room for — see the
  three node-policy docs (`blockmaxweight=3985000`).
