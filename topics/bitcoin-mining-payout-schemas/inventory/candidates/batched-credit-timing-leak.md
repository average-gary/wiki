---
title: "Batched blinded crediting — how much hashrate does the batch boundary leak?"
kind: question
status: active
priority: p1
created: 2026-07-29
updated: 2026-07-29
last_checked: 2026-07-29
next_action: "Quantify hashrate recoverability from batched credit timing. Simulate against R&C's ISP-Log method: fixed batch size b vs Poisson-randomized boundaries, at b ∈ {10, 72, 1271} and share rates 6–18/min. The question is what error rate a randomized boundary forces, and what it costs in accumulator round-trips."
sources:
  - wiki/theses/blinded-share-credit-commitment.md
  - raw/papers/2026-07-29-blinded-accumulation-cost-at-real-share-rates.md
  - raw/papers/2026-07-29-recabarren-carbunar-hardening-stratum.md
  - wiki/concepts/hashrate-inference-side-channels.md
tags: [privacy, side-channel, batching, hashrate-inference, bba-plus, sv2, open-question, unquantified]
confidence: high
summary: "The 2026-07-29 thesis round dissolved every cryptographic barrier to blinded share accumulation and relocated the difficulty here. Batching is what makes the accumulator affordable — 7.2 cores at F2Pool scale — but the inter-credit interval leaks hashrate as interval = b / share_rate. No paper quantifies this for the batched case."
---

# Batched credit timing leak

## Why Track This

This is what the blinded-share-credit thesis round left standing after everything else fell over.
Cryptographically, the miner-carried accumulator is **open and affordable**: 45 ms pool-side per
`Add`, and SV2 already ships `share_batch_size = 10` plus a `new_shares_sum` U64 field that *is* the
value to credit. The barriers this topic had recorded — Canard–Gouget, a 16-bit range ceiling, "fatal"
per-share cost — were all wrong.

But batching is precisely what buys the affordability, and the batch boundary is a timing signal.

## The mechanism

```
inter-credit interval = batch_size / share_rate
```

A fixed `b` converts a per-share leak into a **lower-sampled leak of the same quantity**. The pool
still learns hashrate; it just samples it less often. And the sampling rate needed for affordability
scales *against* privacy: 16,000 miners on a single core needs `b ≥ 72`, i.e. one credit per
12 min/miner — fewer samples, but each one a cleaner estimate of a longer averaging window.

Recabarren & Carbunar make this concrete and it is the reason to take it seriously: their ISP-Log
attack reaches **0.53–34.4 % payout-prediction error from the inter-packet timestamps of the first 50
packets alone**, with no payload access. Threshold-triggered batching is self-defeating against that
method; boundaries have to be Poisson-randomized.

## Current State

**Unquantified in any paper.** BBA+ and Black-Box Wallets measure compute and bytes, never timing
privacy. R&C measure the leak for *unbatched* Stratum. Nobody has connected them.

## Close-out Condition

Either:

- a simulation giving the recoverability curve — hashrate-estimation error as a function of `b` and
  boundary randomization, benchmarked against R&C's 0.53–34.4 %; **or**
- a demonstration that randomized boundaries cost so many extra round-trips that the affordability
  argument collapses, which would close the thesis's B horn for *practical* rather than cryptographic
  reasons; **or**
- an existing treatment in the anonymous-payments literature (checked: none found in the BBA line).

## Notes

- **Poisson, not threshold.** Any boundary rule that fires on a count is a direct hashrate readout.
  The interesting question is whether a Poisson process with a rate the *miner* chooses can decouple
  the two, and what that costs.
- **This is the honest infeasibility argument** if one is wanted. The thesis round's recommendation
  was to argue blinded credit's difficulty from **interactivity** and **this side channel**, not from
  cost or impossibility.
- **Related but distinct** from the general hashrate-inference problem: here the pool is a *willing*
  participant trying not to learn, which is a different threat model than a network eavesdropper.
