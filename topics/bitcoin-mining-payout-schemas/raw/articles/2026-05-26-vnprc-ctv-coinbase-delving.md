---
title: "Scaling Noncustodial Mining Payouts with CTV (Delving Bitcoin, vnprc, Jun 2025)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/scaling-noncustodial-mining-payouts-with-ctv/1753
author: vnprc (Evan)
date: 2025-06-04
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [vnprc, ctv, op-ctv, covenants, non-custodial, antoine-poinsot, ark, primary]
---

# Scaling Noncustodial Mining Payouts with CTV — vnprc

Proposal: use OP_CTV to put a single small commitment in the coinbase that commits to a fanout transaction tree. Fanout sits in mempool during the 100-block coinbase maturity window and gets mined as fee rates allow.

## Quantitative claims

- **179-byte coinbase** committing to a **319-output fanout** (vs OCEAN's current ~2.28 KB / 62 outputs, vs custodial pools' 471-byte / 1-output coinbase).
- Upper bound = TRUC transaction size policy (10 KB).
- Two structures prototyped: flat fanout (319 outputs) and layered binary tree (stepping stone toward MuSig / off-chain consolidation).
- 1 sat/vB fee + 330-sat anchor output for crowdsourced fee-bumping.

## Real motivation

Break Bitmain firmware coinbase-size limits that killed P2Pool. CTV makes the coinbase tiny again so Antminers can mine non-custodial pool blocks. vnprc quote: *"Break Bitmain's stranglehold on the coinbase. gfy Jihan!"*

## AntoineP's pushback (3 thread posts)

- This is **congestion control, not scaling**. CTV defers settlement timing without compressing total blockspace.
- **Ark/VTXOs** are the real scalability answer because they batch many payouts into one on-chain settlement.
- Calls the proposal a revival of CTV's failed congestion-control framing.
- Warns vnprc against "unrealistic wild claims that twist reality."

## ErikDeSmedt's hybrid

Use OP_CTV in the coinbase to pay into a transaction tree of **VTXOs**. Miners hold VTXOs off-chain until they accumulate ~0.01 BTC, then settle one UTXO on-chain. Cited Second.tech's UTXO-sharing transaction tree docs.

## Status

- Pure prototype (regtest only) — see `vnprc/coinbase-playground` (40 commits, last push 2025-06-28, 4 stars).
- Depends on `bitcoin-garrys-mod` (custom Core fork by `average-gary` with CTV+CSFS).
- **No mainnet path** — CTV (BIP-119) is not active. Thread explicitly avoids activation politics.

## Stack relationship

- **Orthogonal axis to eHash/hashpool**. eHash is a Cashu-mint custodial-but-redeemable layer. CTV-coinbase scales the *on-chain* non-custodial payout tier — what TIDES and p2poolv2 want for direct-to-miner coinbase outputs.
- README cites Kulpreet Singh's "Trading Shares for Bitcoin" post — n-of-n MuSig endgame at each tree node, miners trade shares off-chain during the 100-block window to consolidate the tree.

## Caveats

- The Delving thread itself does NOT discuss eHash/hashpool/p2poolv2/TIDES by name. The connections are in the **prototype README**, not the thread.
- AntoineP has no monolithic "Ark for mining payouts" canonical source — his Ark advocacy is scattered.

## See also

- [[../repos/2026-05-26-vnprc-coinbase-playground-github]] — runnable prototype
- [[2026-05-26-braidpool-covenants-delving]] — sister covenant-payout thread (McElrath UHPO)
- [[../../wiki/concepts/ehash]] — same author's Cashu-mint payout work
