---
title: "Ark Emergency/Unilateral Exit spec notes (instagibbs/boats 06-exit.md)"
source_url: https://github.com/instagibbs/boats/blob/master/06-exit.md
type: repo
authors: [Greg Sanders (instagibbs)]
publisher: GitHub (Bitcoin Core dev working notes)
ingested: 2026-07-16
research_path: dropout
credibility: high
confidence: medium
quality_score: 4
tags: [ark, exit, truc, v3, p2a, cpfp, exit-delta, exit-window, mass-exit, sweep, fees, storage-burden]
summary: Bitcoin Core dev Greg Sanders' working notes on the physical on-chain exit sequence — TRUC/v3 topology, P2A anchor CPFP, per-tx vB cost, claim-side relative timelocks (exit_delta / 2·exit_delta / htlc_expiry+exit_delta), the exit-window race vs expiry, and the covenantless client-side storage burden.
---

# Ark Emergency/Unilateral Exit spec notes (instagibbs/boats)

Greg Sanders (Bitcoin Core dev) working notes, 2024–2025. Best source for the physical on-chain exit sequence and mass-exit race.

## Broadcast order
- Presigned exit txs published "in chain order (each spends an output of the previous)"; each level enters the mempool only after the previous confirms, under TRUC/v3 "1-parent-1-child" topology.

## Fees / CPFP
- Exit txs carry no built-in fee — each level needs a CPFP child spending the P2A anchor to pay.
- A basic exit tx is **124 vB** (`EXIT_TX_WEIGHT`); deep chains accumulate CPFP + claim costs, and wallets "SHOULD expose the total cost estimate since deep chains can be expensive."

## Claim-side relative timelocks (set at claim time, relative to confirmation)
- pubkey policy = `exit_delta`
- HTLC-send recovery = `2 * exit_delta`
- HTLC-recv claim = `htlc_expiry_delta + exit_delta`
- User must wait the clause's CSV delta after confirmation before the claim input is valid.

## Exit-window / race condition (mass-exit concern)
- A VTXO is only safely exitable while "current height + exit confirmation time" leaves room before `expiry_height`.
- "Once the expiry leaves become spendable the server can race the exit" — users must start exits sufficiently before expiry; congestion during a mass exit erodes that margin.

## Server expiry-sweep
- After `expiry_height`, "every cosign/leaf-cosign output in an unbroadcast portion of the chain becomes sweepable by the server through its timelock-sign expiry leaf."
- Server watches for confirmed exits and responds via checkpoint txs within a configurable grace period.

## Covenantless storage burden
- Users must "persist all data required to construct the exit chain (the full VTXO encoding suffices) independently of the server" — because there is no covenant, the presigned branch txs/data must be held client-side or exit is impossible.
