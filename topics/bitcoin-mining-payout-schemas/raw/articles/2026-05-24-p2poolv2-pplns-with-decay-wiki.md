---
title: "p2poolv2 wiki: Payouts PPLNS With Decay"
publication: github.com/p2poolv2/p2poolv2/wiki
url: https://github.com/p2poolv2/p2poolv2/wiki/Payouts-PPLNS-With-Decay
type: article
ingested: 2026-05-24
quality: 4
credibility: high
confidence: high
tags: [p2poolv2, PPLNS, decay, alternative-payout, small-state]
---

# p2poolv2 — PPLNS With Decay (alternative payout)

Score-based decay variant — design-doc-only, not production default. Used by the Hydrapool small-state path.

## Algorithm

- Decay constant: **`α = exp(-1/N)`** where N is effective PPLNS window size in shares.
- Per-miner score `S_miner[i]`, global total `S_total`, global multiplier `D` (starts at 1).
- On each share with weight `w`:
  - `D *= α`
  - `S_miner[i] += w / D`
  - `S_total += w / D`
- Real score = `stored_score × D`.
- **Rescale when `D < 1e-20`**: multiply every stored score by D, reset D = 1. Prevents f64 underflow. Approximately every 1e6 shares.

## Memory advantage

Inactive miners' rows never need updating; their effective score decays automatically by virtue of D shrinking. Memory cost is O(active miners), not O(window size).

## Why this exists alongside the work-bounded window

The production `sharechain_pplns/pplns_window.rs` keeps a `VecDeque<ConfirmedEntry>` of every share in the 133,056-share window. For pools with many distinct miners, this is fine because share-difficulty is high enough that share-count is bounded.

For Hydrapool (one-click home-miner pool, 256 Foundation), the workload may have many low-difficulty shares per miner. PPLNS-with-decay scales to that case.

## Numerical considerations

f64 multiplication with α < 1 underflows after ~1e6 shares. The rescale check is essential. The code comment in the wiki page is explicit: not a sanity-check, an invariant.

## See also

- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting source]]
- [[../articles/2026-05-24-hydrapool-256-foundation|Hydrapool — 256 Foundation pool]]
