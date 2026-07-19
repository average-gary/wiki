---
title: "Unlocking Liquidity Before Shared Output Expiration (Ark Labs)"
source_url: https://blog.arklabs.xyz/unlock-liquidity-before-shared-output-expiration/
type: article
publisher: Ark Labs
date: 2024-11-05
ingested: 2026-07-16
research_path: evolution
credibility: high
confidence: high
quality_score: 5
tags: [ark, vtxo-tree, tree-signing, ephemeral-keys, log-n, oor, out-of-round, liquidity, early-liquidity-release]
summary: Primary account of the VTXO-tree signing optimization — from each participant signing (2n−1) txs with ephemeral keys to each user signing only ~log2(n) txs with their wallet keys — plus Out-of-Round (OOR) transactions and early server liquidity reclamation before shared-output expiry.
---

# Unlocking Liquidity Before Shared Output Expiration (Ark Labs)

Ark Labs, 2024-11-05. Clearest primary account of the VTXO-tree signing evolution.

## VTXO tree signing improvement
- OLD scheme: each participant signs **(2n−1)** transactions using ephemeral keys.
- NEW scheme: each user signs only **~log₂(n)** transactions — only those affecting their own VTXO descendants — and **eliminates ephemeral keys** (users sign with their wallet keys).

## Out-of-Round (OOR) transactions
- Users no longer must join a round to *send*; they participate mainly to settle their own VTXOs, acting as sender and receiver simultaneously. Concrete "reduced-interactivity" step for the covenantless design.

## Early liquidity release
- Server can reclaim liquidity (fully or partially) before shared-output expiry via user collaboration: when two sibling VTXOs are spent externally and receivers have settled, participants can authorize a double-spend of their shared output to release liquidity early.

## Flag
- This page did not name MuSig2/ANYPREVOUT explicitly; the log₂(n) branch-signing scheme is what other sources describe as MuSig2-based.
