---
title: "hArk & Erk: Evolving the Ark Protocol using CTV and CSFS (roose.io)"
source_url: https://roose.io/blog/hark-erk-evolving-the-ark-protocol-using-ctv-and-csfs/
type: article
authors: [Steven Roose, Erik De Smedt]
publisher: roose.io
date: 2025-04-15
ingested: 2026-07-16
research_path: evolution
credibility: high
confidence: high
quality_score: 5
tags: [ark, clark, hark, erk, ctv, csfs, rebindable-signatures, timelocks, T_exp, exit-delta, forfeit, offline-refresh]
summary: Steven Roose's formal treatment of clArk's recursive-multisig node policy, the dual-timelock model (absolute T_exp expiry + relative Δt exit delay), and how CTV/CSFS successors (Erk = rebindable signatures, hArk = hash-lock) remove the mandatory synchronous user participation in rounds.
---

# hArk & Erk: Evolving the Ark protocol using CTV and CSFS (roose.io)

Steven Roose (with Erik De Smedt), published 2025-04-15, updated 2025-05-09. Companion to the delving thread; the clearest treatment of timelock semantics.

## Variant definitions
- **Ark** uses `OP_CHECKTEMPLATEVERIFY` (CTV) covenants in node/leaf policies.
- **clArk** ("covenant-less Ark") replaces covenants with **recursive multisigs in the tree** — each node policy is a multisig of all leaf participants plus the server. Both share identical round mechanics with connector transactions.
- **Erk** ("Ark, by Erik"): uses **CTV+CSFS "rebindable signatures"** to eliminate synchronous user participation. Users pre-sign refund transactions with new keypairs; the server issues refreshed VTXOs asynchronously, and can unilaterally refresh expired VTXOs (chaining refreshes recursively) — i.e., "offline refresh."
- **hArk** ("hash-lock Ark"): requires **only CTV, not CSFS**. Server generates secrets for new VTXOs (initially inaccessible); users sign forfeit txs letting the server claim inputs by revealing secrets. Eliminates tree-unrolling costs and handles multiple inputs efficiently.

## clArk node policy (formal)
- `(A + B + C + ... + S) or (S + T_exp)` — the all-owners-plus-server cooperative branch, or server-alone after the absolute expiry `T_exp`. Adds an extra signing phase not present in CTV variants.

## Dual-timelock model
- The protocol uses BOTH an absolute timeout `T_exp` (VTXO expiry height) and a relative timelock `Δt` (exit delay).
- The relative `Δt` guarantees spend-clause precedence (forfeit must be spendable before the exit branch matures).
- The absolute `T_exp` bounds liveness so that subsequent VTXO owners don't inherit indefinite online obligations.

## Liveness is not improved by clArk
- All Ark variants require the user to come online before `T_exp` either to refresh the VTXO or to perform a unilateral exit if the server misbehaves. "clArk doesn't improve this fundamental requirement."

## Forfeit mechanics identical to original Ark
- Connector-based inputs ensure the round is confirmed before the server can claim a forfeited VTXO (prevents the server from grabbing forfeits from a round that never lands on-chain).

## The covenantless cost
- clArk's multisig-coordination phase "adds complexity without enabling improvements Erk and hArk provide," specifically lacking offline refresh and asynchronous rounds that CTV/CSFS enable — every refresh forces the owner online.
