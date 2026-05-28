---
title: "Ark as a Channel Factory — Compressed Liquidity Management for Improved Payment Feasibility (Pickhardt + instagibbs, Delving Bitcoin)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
authors: [Rene Pickhardt, instagibbs (Greg Sanders)]
date: 2025-12-31
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [ark, channel-factory, capital-lockup, liveness, critique, primary]
---

# Ark as a Channel Factory — Pickhardt + instagibbs (Dec 2025)

The most quantitative public treatment of Ark's **capital-lockup and liveness costs**. Highly relevant to mining-pool payout viability.

## Pickhardt's three structural issues

1. **Capital lock-up**: VTXOs release liquidity only after timeout, binding the **ASP capital for the duration of the expiry window**. For mining payouts: the pool (acting as ASP) must front capital proportional to in-flight VTXO value × expiry window.
2. **Output multiplication**: payments create multiple outputs forcing the ASP to front substantially more capital than transaction volume.
3. **Settlement timing**: payments only settle conclusively at round boundaries. Between rounds, spent VTXOs could theoretically be **double-spent** (mitigated by tx-copy proofs, but the trust model isn't trustless).

## instagibbs's load-bearing observation

> "the ASP/LSP have to be the same identity or trust each other otherwise the LSP is on the hook for unrolling channels when the mobile client turns off their phone."

For mining payouts: a pool that runs the ASP carries the entire liquidity burden when miners go offline.

## Open question: round frequency vs expiry window

The thread surfaces but does not resolve: round cadence (minutes-to-hours) is **misaligned** with block cadence (~10 min) for share-payout granularity. A pool would have to choose: settle every block (defeats the point), every N blocks, or only on miner-initiated exits.

## Direct quotes (citable)

- Pickhardt: "VTXOs release liquidity only after their timeout, binding the ASP's capital for the duration of the expiry window"
- Pickhardt: "Payments settle conclusively only at round boundaries. Between rounds, spent VTXOs could theoretically be double-spent"
- instagibbs: "the ASP/LSP have to be the same identity or trust each other otherwise the LSP is on the hook for unrolling channels when the mobile client turns off their phone"

## Why ingestion-worthy

Most quantitative engineering critique of Ark's economics. The "ASP must front capital proportional to payment volume × expiry window" argument directly explains why an ASP-backed mining payout ladder is **more expensive in capital terms** than a Cashu mint or coinbase output. This is the structural reason to be skeptical of the "Ark > CTV" framing for mining payouts specifically.

## See also

- [[2026-05-26-ark-erik-de-smedt-ctv-csfs-delving]] — variants critique
- [[2026-05-26-vnprc-ctv-coinbase-delving]] — counterproposal
- [[../papers/2026-05-26-keer-maffei-ark-formal-arxiv]] — formal model (does not address capital cost)
