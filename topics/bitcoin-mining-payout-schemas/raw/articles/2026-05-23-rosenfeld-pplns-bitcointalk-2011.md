---
title: "[PPLNS] Pay Per Last N Shares — full method description (original proposal)"
author: Meni Rosenfeld
publication: bitcointalk.org
date: 2011-08-28
url: https://bitcointalk.org/index.php?topic=39832.0
type: article
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [PPLNS, history, Rosenfeld, primary-source, bitcointalk]
---

# Original PPLNS Proposal (Rosenfeld 2011-08-28)

The thread where PPLNS was specified for Bitcoin pools. Primary historical artifact.

## Why PPLNS was invented

Proportional payout (Slush 2010, BTC Guild 2011) was being **exploited by pool-hoppers**. Miners would join early in a round (high expected payout per share) and leave once shares accumulated (expected per-share payout drops). PPLNS's design goal: make per-share expected payout independent of round position.

## Method (as specified)

- Each share is scored 1/D (D = difficulty at submission time).
- Payments depend only on **future** blocks (lookback): when a block is found, the last N shares (by score, not count) are paid.
- This breaks the pool-hopper's "leave when expected drops" strategy because future blocks are i.i.d. — every share has the same expected reward regardless of when it was submitted.

## Variants discussed in the thread

- **Sharp 0/1 cutoff** — share is in the window or not.
- **Exponential decay** — older shares weighted exponentially less (this becomes "Geometric method").
- **Linear decay** — older shares weighted linearly less.

These variants are the seed of:
- Slush score-based (exponential decay)
- Geometric method (Rosenfeld's later formalization)
- DGM (Double Geometric, Rosenfeld 2011 paper)
- TIDES (OCEAN 2024 — sharp cutoff with N = 8×D)

## Why it matters

Every modern PPLNS-derived scheme (TIDES, SLICE/PPLNS-JD, p2pool's on-chain PPLNS) traces to this thread. The fundamental "look back at last N shares" pattern is unchanged 13 years later — only the choice of N, the weighting function, and the custody model have evolved.
