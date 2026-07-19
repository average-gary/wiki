---
title: "Ark VTXOs (Second/Bark docs)"
source: "https://second.tech/docs/learn/vtxo.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, vtxo, quad-tree, musig2, cltv, csv, script-policy, statechain]
summary: "Bark's VTXO reference — three types (board/refresh/spend), quad-tree structure (radix 4), and exact two-path spend scripts: n-of-n MuSig2 / 2-of-2 cooperative vs CLTV (root/branch) + CSV <144> (~1 day) unilateral. Spend VTXOs follow statechain security."
---

# Ark VTXOs (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

## Definition
- "a series of pre-signed bitcoin transactions held off-chain by a user provide the ability to create an on-chain UTXO at a later time, if required." Emergency exit needs no third-party interaction.

## Three VTXO types
- **Board VTXO** — from on-chain deposits. Structure **"Root → Leaf (2 txs)"**; completely trustless recovery; user pays full on-chain fees for emergency exit.
- **Refresh VTXO** — from periodic rounds (~hourly). Structure **"Root → Branches → Leaf (3+ txs)"**; trustless like board; "users exiting earlier subsidize users exiting later" (shared branch broadcasts).
- **Spend VTXO** — instant payments via **arkoor (out-of-round)**. "Extends board and refresh VTXOs" by adding new leaf transactions. Trust: "sender + server don't collude" — follows **state chain** security principles.

## Transaction tree
- Three tx types: **Root** (only on-chain tx), **Branch** (off-chain value splits), **Leaf** (individual user exit tx).
- "**Quad trees** (each branch transaction splits into four outputs)" minimize exit costs through logarithmic scaling. (Note: radix 4, vs arkd's binary VTXO tree.)

## Spend paths (script policies)
- **Path 1 (Cooperative)**: "**n-of-n multisigs (MuSig2)** between all users sharing that branch plus the server" for branches; "**2-of-2 multisigs** between user and server" for leaf transactions.
- **Path 2 (Timelocked recovery)**: "Absolute **CLTV** timelocks (`<expiry-height> OP_CHECKLOCKTIMEVERIFY`)" for roots/branches; "relative **CSV** timelocks (`<144> OP_CHECKSEQUENCEVERIFY`)" for user exits (~1 day at 144 blocks).

## Lifecycle
- Board/refresh VTXOs expire at ~30-day lifetime. "Spending doesn't reset the lifetime, so receivers of 'old' VTXOs must refresh sooner." After expiration, users require refresh VTXOs exclusively.
