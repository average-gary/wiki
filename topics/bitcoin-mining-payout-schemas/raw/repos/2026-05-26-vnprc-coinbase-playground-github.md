---
title: "vnprc/coinbase-playground — CTV-coinbase prototype"
url: https://github.com/vnprc/coinbase-playground
created: 2025-05-14
last_push: 2025-06-28
stars: 4
type: repo
status: prototype (regtest only)
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [vnprc, ctv, op-ctv, prototype, regtest, coinbase-fanout]
---

# vnprc/coinbase-playground — CTV-Coinbase Prototype

Runnable prototype for the "Scaling Noncustodial Mining Payouts with CTV" proposal. Regtest only, depends on `average-gary/bitcoin-garrys-mod` (custom Core fork with CTV+CSFS).

## Just recipes

- `mine-ctv-coinbase` — flat 319-output fanout
- `mine-layered-ctv-coinbase` — 4-leaf layered binary tree, 500-sat fixed fees
- `parse-witness` — inspect commitments

## Why the prototype matters

Demonstrates the proposal exists as runnable code, not vapor. Confirms the 179-byte / 319-output quantitative claim is implementable in current covenant-fork code.

## README citations (cross-axis links)

- Kulpreet Singh — "Trading Shares for Bitcoin: A User Story" (https://blog.opdup.com/2025/02/26/trading-shares-for-bitcoin-user-story.html) — p2poolv2 share trading endgame
- Jason Hughes / OCEAN DATUM presentation (`youtube.com/watch?v=EKQvDfmQkt8&t=8910s`) — current non-custodial-coinbase pain CTV would eliminate
- vnprc btc++ Austin 2025 talk (Day 2 livestream `F2p_V0svDTo` @ 3h15m30s) — broader coinbase-control thesis

## Caveats

- 40 commits, dormant since June 2025 — single-author research artifact.
- No mainnet path until CTV activates.

## See also

- [[../articles/2026-05-26-vnprc-ctv-coinbase-delving]] — proposal thread
- [[2026-05-23-hashpool-vnprc]] — same author's Cashu-mint pool
