---
title: "Bitcoin Optech — Ark topic page"
source_url: https://bitcoinops.org/en/topics/ark/
type: article
publisher: Bitcoin Optech
ingested: 2026-07-16
research_path: foundations
credibility: high
confidence: high
quality_score: 4
tags: [ark, optech, round, vtxo, expiry, covenant, ctv, oor, double-spend, timeline]
summary: Neutral authoritative reference confirming the round = jointly-signed tree + broadcast-root model, VTXO absolute-timelock expiry, the "no consensus change needed; CTV optional for scale/fee-efficiency" positioning, the chained-payment operator-collusion double-spend risk, and the signet→mainnet timeline.
---

# Bitcoin Optech — Ark topic page

Living page; authoritative neutral Bitcoin engineering reference.

## Round / pool tx definition (verbatim)
- Rounds involve "multiple users and a counterparty (an Ark operator), who together construct and sign the transaction tree, then broadcast the root transaction onchain." Confirms presign-then-broadcast ordering and user+operator joint tree signing.

## VTXO framing
- VTXOs are "a package of offchain transactions" and "the core unit of value on Ark"; users receive "their branch and leaf transactions offchain" (matching the per-branch presigning design choice).

## Expiry / unilateral spend
- "VTXOs 'expire' according to an absolute timelock. After this timelock expires, both the Ark operator and users can unilaterally spend the bitcoin."
- "users must ensure their VTXOs are spent into a new transaction tree before expiry."

## Trust boundary of in-Ark (out-of-round) payments
- "Each payment transaction requires co-signatures from both the sender and the Ark operator, meaning receivers must trust that the sender will not collude with the operator to double-spend."
- "any sender in the chain could collude with the operator to double-spend the entire chain" — trust-model degradation specific to chained off-chain payments.

## Covenant relationship
- Ark "can be implemented on Bitcoin without requiring consensus changes, but would support significantly more users—and achieve greater fee efficiency—if covenant features like OP_CHECKTEMPLATEVERIFY were added" — covenantless Ark is the inferior efficiency fallback pending CTV.
- Current implementation "relies on presigned transactions (requiring interactivity)."

## Timeline (as summarized by the page; verify individual months against linked newsletters)
- 2023 — managed joinpool protocol proposed (Ark announcement).
- 2024 — Ark implementation demonstrated on mainnet.
- 2025-02 — Ark Wallet SDK released.
- 2025-03 — `bark` implementation available on signet.
- 2025-04 — summary of CTV+CSFS benefits for Ark.
- 2026-01 — Ark explored as a Lightning channel factory.
- 2026-06 — `bark` live on Bitcoin mainnet.
