---
title: "CTV, APO, CAT activity on signet — one APOAS sig spends many coinbase outputs (Delving Bitcoin)"
source: "https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257"
type: articles
ingested: 2026-07-16
tags: [anyprevout, apoas, signet, coinbase, on-chain-evidence, fee-leakage, ajtowns, jeremy-rubin, delving-bitcoin]
summary: "Real on-chain signet data (ajtowns, JeremyRubin). Most APO signet traffic were 'spends of the coinbase payout... All those spends reuse the same APOAS signature, spending multiple block rewards back to faucet addresses, generally with very large amounts lost to fees.' The strongest empirical proof that ONE APOAS signature can spend MANY distinct coinbase outputs (different txids) — and the fee leakage directly demonstrates why APOAS's dropped amount-commitment matters."
---

# CTV, APO, CAT activity on signet

Delving Bitcoin, real on-chain data (ajtowns, JeremyRubin).

## The key empirical finding

- ajtowns: most APO signet traffic were "spends of the coinbase payout... **All those
  spends reuse the same APOAS signature, spending multiple block rewards back to faucet
  addresses**, generally with very large amounts lost to fees."
- This is a live demonstration that **one APOAS signature can spend many different
  coinbase outputs** (different txids) — direct empirical support for the anchor claim
  that APO(AS) lets you (pre)sign spends of coinbase outpoints.
- It used **APOAS, not plain APO** — consistent with the amount-variance problem: each
  block reward differs, APOAS ignores amount, so one sig works across all. The "very
  large amounts lost to fees" is the direct symptom of NOT committing to amounts — the
  spend can't control how much value it moves, so surplus leaks to fees.

## Also noted

- An "APO-based spend using the IPK [internal pubkey]... that also includes an annex
  commitment that provides enough information to reconstruct the following tx script"
  (LN-symmetry testing).
