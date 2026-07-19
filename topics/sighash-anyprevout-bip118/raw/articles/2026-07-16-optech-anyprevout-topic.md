---
title: "Bitcoin Optech — SIGHASH_ANYPREVOUT topic"
source: "https://bitcoinops.org/en/topics/sighash_anyprevout/"
type: articles
ingested: 2026-07-16
tags: [optech, anyprevout, sighash-noinput, rebindable-signatures, eltoo, naming-history, use-cases]
summary: "Optech's curated topic page on SIGHASH_ANYPREVOUT. Defines the rebindable-signatures concept (the UTXO identifier is not signed, so the signature works against any UTXO with a similar script/value), documents the naming lineage (NOINPUT → NOINPUT_UNSAFE → ANYPREVOUT, BIP PR #943), APOAS added for eltoo flexibility, and the accepted use-case list (eltoo/LN, payment pools/CoinPool, DLC efficiency, covenant apps, drivechains with trusted setup)."
---

# Bitcoin Optech — SIGHASH_ANYPREVOUT topic

Curated developer reference on APO.

## Definition

APO is "a sighash where the identifier for the UTXO being spent is not signed,
allowing the signature to be used with any UTXO that's protected by a similar
script" — the **rebindable signatures** concept. APOAS relaxes further to "the same
BIP 118 public key."

## Naming / safety history (the timeline reveals the safety anxiety)

- 2016: NOINPUT concept (Joseph Poon).
- 2018: proposed as `SIGHASH_NOINPUT`.
- **July 2018: renamed `SIGHASH_NOINPUT_UNSAFE`** — a deliberate flag that the
  replay footgun was serious.
- July 2021: renamed `SIGHASH_ANYPREVOUT` and rebased onto Taproot (BIP PR #943).
- Oct 2022: description simplified (PR #1367).
- APOAS added later "to improve eltoo flexibility."

## Motivation & use cases

- Primary: "a noinput-style sighash is necessary for the proposed eltoo layer for LN."
- Beyond eltoo: **payment pools (CoinPool)**, **DLC efficiency improvements**,
  **covenant-based applications**, and **drivechains with trusted setup**.
- 2024 signet testing; exploration of "covenant mashups" combining APO with OP_CTV,
  and alternatives with CSFS / OP_TXHASH (2022–2023).

Note: the coinbase-presigning use case is *not* first-class in the reference
literature itself — it is an emerging idea in the Delving Bitcoin / covenant community
(see the Braidpool and CTV-mining-payout raw sources).
