---
title: "Intro to the Ark protocol (Second/Bark docs)"
source: "https://second.tech/docs/learn/intro.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, vtxo, asp, trust-model, overview]
summary: "Bark's overview of Ark: client-server model with an Ark Server coordinating rounds and fronting liquidity; three VTXO types; ~1h round cadence; ~30-day VTXO lifetime; the sender+server no-collude trust model."
---

# Intro to the Ark protocol (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- Ark = "a second layer on the bitcoin network"; works on Bitcoin today without new opcodes.
- **Ark Server**: coordinates protocol operations and maintains liquidity. Client-server model — users transact directly through a central server; Lightning via the server's gateway.
- **VTXO** = "a series of off-chain, pre-signed transactions that a user can broadcast at any time to retrieve their bitcoin on-chain in an emergency." Types:
  - **Board VTXOs** — initial deposits onto Ark
  - **Spend VTXOs** — created when users make Ark payments to each other
  - **Refresh VTXOs** — generated during periodic rounds when users exchange old VTXOs for new ones
- **Rounds** occur periodically, expected interval **~1 hour** (configurable). Only participating users' VTXOs are included; round tx forms a **tree** with a blockchain-committed root and per-user leaf transactions.
- **VTXO lifetime** ~30 days to let servers sweep expired rounds efficiently. Users must refresh or spend before expiry, or both user and server become able to claim them.
- **Trust model** — Ark payments: zero liquidity cost, near-instant; temporary trade-off: "the receiver assumes that the sender and Ark server don't collude to double-spend. As long as either the sender or server is honest, the payment is secure."
- **Exit**: Offboarding (cooperative, user forfeits VTXO for on-chain output) vs Emergency Exit (user unilaterally broadcasts pre-signed sequence).
- **Liquidity**: server bears capital cost during rounds while awaiting previous round timelocks; newer VTXO refreshes cost more, near-expiry ones cost less.
