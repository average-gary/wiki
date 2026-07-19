---
title: "SIGHASH_ANYPREVOUT (BIP-118)"
description: "APO/APOAS Taproot sighash flags — status, semantics, and the coinbase-outpoint presigning problem"
created: 2026-07-16
freshness_threshold: 70
---

# Wiki Configuration

- mode: topic
- created: 2026-07-16
- hub: /Users/garykrause/wiki

## Scope

BIP-118 `SIGHASH_ANYPREVOUT` (APO) and `SIGHASH_ANYPREVOUTANYSCRIPT` (APOAS) for
Taproot scripts:

- **Status**: draft/proposed BIP, activation history (`bip118` deployment), soft-fork
  bundling debates (APO alone vs. as part of a covenants package), signet availability.
- **Semantics**: what APO/APOAS omit from the sighash vs. BIP-341 default; the
  0x41/0x43 flag encoding; the `0x01` public-key prefix; interaction with
  `SIGHASH_ALL`/`SINGLE`/`NONE|ANYONECANPAY`; replay-protection considerations.
- **Motivation**: Eltoo / LN-Symmetry channels, and other rebindable-signature use cases.
- **Coinbase-presigning problem** (anchor): presigning a transaction that spends a
  coinbase output whose txid/outpoint is not yet known because the block is unmined.
  Whether APO solves it, what its limits are (100-block coinbase maturity, the
  `ANYPREVOUTANYSCRIPT` vs `ANYPREVOUT` distinction), and alternatives (CTV/BIP-119,
  `SIGHASH_ANYONECANPAY`, template-side workarounds).

## Conventions

- Bitcoin-consensus subject: prefer primary sources (the BIP text, mailing-list
  posts, Optech, signet/implementation code) over secondary explainers.
- Keep speculative activation timelines flagged `confidence: low` and `volatility: hot`.
- Cross-link the coinbase-presigning analysis to the mining-payout hub topics.
