---
title: "OCEAN TIDES Payout Algorithm"
source_url: https://ocean.xyz/docs/tides
type: algorithm-spec
ingested: 2026-05-22
quality: 4
confidence: high
tags: [ocean, tides, pplns, payout, share-accounting]
---

# OCEAN TIDES Payout Algorithm

Production payout algorithm with non-trivial share-accounting mechanics. Directly comparable to Braidpool's PPLNS-N=2016 and p2poolv2's design choices.

## Pitch
> TIDES is what PPLNS was originally supposed to be.

No shifts, no aggregation; full per-share resolution.

## Mechanics
- Active window = **8× current block difficulty in shares**
- Window slides per block, so each share averages ~8 payouts over its lifetime
- `Reward = (miner_shares_in_window / total_window_shares) × block_reward`, rounded down to satoshi
- Share log is append-only and **never truncated** — only the current top window pays out

## Implication for p2poolv2 share-chain accounting
- p2poolv2 uses chain-with-uncles + direct coinbase to top-N. The "top-N" cutoff is morally similar to TIDES's 8×-difficulty window — both are sliding-window approximations of "recent contribution."
- Braidpool's PPLNS-N=2016 (one difficulty epoch) is a much wider window with stronger long-tail payouts.
- Comparing variance properties of these three windows is a follow-up research question.
