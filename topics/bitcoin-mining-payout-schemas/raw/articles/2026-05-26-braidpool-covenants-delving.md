---
title: "Challenge: Covenants for Braidpool (Delving Bitcoin, McElrath, Jan 2025)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370
author: Bob McElrath
date: 2025-01
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [braidpool, covenants, ctv, apo, uhpo, rca, frost-critique, primary]
---

# Challenge: Covenants for Braidpool — McElrath

McElrath's challenge thread on Delving Bitcoin posing the open problem: **how do you authorize payouts in a decentralized pool without trusting a federation, without n-of-n key aggregation breaking when miners disconnect, and without forcing every miner to sign every payout?**

## Design proposed

- **RCA — Rolling Coinbase Aggregation**: each new block's coinbase aggregates prior unspent payouts forward, accumulating into an evolving UHPO.
- **UHPO — Unspent Hasher Payout Object**: the live, covenant-locked output that any hasher can sweep their portion from when they're entitled.
- Requires **APO + CTV** to express the recursive forward-rolling commitment.

## FROST / ROAST critique

Direct critique of Radpool-style federations: *"51% attack (or 67% attack) on the pool... could steal all funds."* This is the load-bearing argument for why threshold-signature pools are not a substitute for covenant-based payout authorization.

## AaronZhang's solution (April 2026 reply chain)

Working three-leaf Taproot construction demoed on **signet**. Establishes proof-of-concept that the RCA→UHPO pattern is implementable today on signet (where APO + CTV are activated for testing).

## Significance

- Closes the loop on Braidpool's core open problem.
- Re-frames the entire decentralized-pool design space as gated on covenant activation: schemes that don't require covenants (Radpool, p2poolv2, eHash) re-introduce trust elsewhere; schemes that do (Braidpool, vnprc CTV-coinbase) are blocked on activation politics.

## See also

- [[../repos/2026-05-26-braidpool-github]] — main repo
- [[2026-05-26-vnprc-ctv-coinbase-delving]] — alternate covenant-based pool payout proposal
- [[2026-05-26-radpool-delvingbitcoin]] — what McElrath is critiquing
