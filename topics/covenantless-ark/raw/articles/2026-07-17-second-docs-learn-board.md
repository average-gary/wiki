---
title: "Ark boarding (Second/Bark docs)"
source: "https://second.tech/docs/learn/board.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, boarding, board-vtxo, funding-tx, exit-tx, six-confirmations, atomicity]
summary: "Bark's boarding reference — cooperative funding+exit tx construction, both pre-sign the exit tx, board VTXO active after six confirmations, boarding is round-independent and atomic (funding tx that spends on-chain BTC also creates the VTXO tree)."
---

# Ark boarding (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

## Flow (five steps)
1. **Transaction creation** — user + server cooperatively construct a funding tx and exit tx with special spending conditions.
2. **Exit pre-signing** — both pre-sign the exit tx, enabling unilateral on-chain recovery without server cooperation.
3. **Broadcast** — user broadcasts the funding tx; stores the pre-signed exit tx off-chain.
4. **Confirmation wait** — await **six confirmations** of the funding tx.
5. **VTXO activation** — after six confirmations the board VTXO becomes active and spendable within Ark.

## Properties
- **Atomicity**: "either both the on-chain funding and VTXO creation succeed together, or both fail together." Achieved because "the funding transaction that spends the user's on-chain bitcoin also creates the VTXO tree that grants the user emergency exit rights."
- **Round independence**: boarding occurs outside the normal round schedule.

## Fees
- On-chain network fees; a future on-chain sweep fee (server covers after board VTXO expiry); Ark server operational fees.
