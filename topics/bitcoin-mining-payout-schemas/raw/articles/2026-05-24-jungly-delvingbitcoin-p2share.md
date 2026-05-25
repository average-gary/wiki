---
title: "Jungly's p2poolv2 design summary on delvingbitcoin (P2share thread)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/p2share-how-to-turn-any-network-or-testnet-into-a-bitcoin-miner/2093
date: 2025-11-07
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [p2poolv2, jungly, design-summary, delvingbitcoin, primary]
---

# Jungly's p2poolv2 Design Summary (delvingbitcoin, Nov 2025)

In response to VzxPLnHqr's "P2share" proposal, Jungly (project lead) outlined the as-shipped p2poolv2 design — the most authoritative public summary outside the repo.

## Confirmed accounting model

- **Weak compact blocks as shares**: every share is a near-block carrying its own coinbase, witness commitment, full block-shape.
- **Uncle blocks for scalability**: up to 3 uncles per share, 90% weight credit.
- **Top 20 miners paid directly in the Bitcoin coinbase** (deployment-level cap; firmware/blockspace constrained).
- **Smaller miners paid via atomic swaps between sharechain shares and Bitcoin** — market makers buy small-miner shares for "virgin coins."
- **Shares expire within PPLNS windows** — creates a market-determined discount as expiry approaches.

This is the **core accounting innovation vs. classic p2pool**: shares are tradeable bearer instruments with time-decay, not just internal ledger rows.

## Issuance rule under discussion

`S = c · D_sharechain` (shares proportional to difficulty contributed), with **pseudorandom single-winner payout per sharechain block**. Single-winner = the share that satisfies sharechain difficulty becomes the payout-distributing block; previous N shares share the reward according to weighted difficulty.

## Critique surface (responded to in-thread)

- **ZmnSCPxj**: nonce-grinding attack risks at low difficulty. Open issue.
- **Share-burning debate**: VzxPLnHqr argued for unbonded perpetual shares vs. p2poolv2's expiring window. Jungly stood by expiry model: variance reduction + market-clearing pricing.

## Significance

This thread is the most concise public confirmation that p2poolv2's accounting includes:
1. Time-decay shares (window expiry)
2. Top-N coinbase + atomic-swap edge as a deployment pattern
3. Single-winner-pseudorandom-block-finder as the payout trigger

Each of these is a deliberate design decision, not an accident — Jungly defends them against alternative proposals in the thread.

## See also

- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting code]]
- [[2026-05-24-p2poolv2-critiques|Critiques of p2poolv2 accounting]]
