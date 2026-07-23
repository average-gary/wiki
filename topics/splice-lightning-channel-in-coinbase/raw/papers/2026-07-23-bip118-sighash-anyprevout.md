---
title: "BIP-118: SIGHASH_ANYPREVOUT / ANYPREVOUTANYSCRIPT"
source: "https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki"
type: paper
subtype: bip
retrieved: 2026-07-23
tags: [bitcoin, bip118, anyprevout, apo, apoas, sighash, presigning, coinbase-outpoint]
credibility: high
evidence_strength: spec
direction: "opposes (explains why pre-signing a fresh-coinbase spend is impossible today); nuances (APO would relax it, but is not activated)"
bears_on: [A, B]
summary: "BIP-118 APO/APOAS Taproot sighash flags omit the prevout (and, for APOAS, amount/scriptPubKey/tapleaf) from the signed message, enabling a signature to be rebound to an outpoint unknown at signing time. This is the primitive that could presign a spend of an as-yet-unmined coinbase output — but it is Draft/not activated on mainnet, and plain APO still commits to the amount (collides with variable coinbase value)."
---

# BIP-118 — SIGHASH_ANYPREVOUT

## What it does

- **`SIGHASH_ANYPREVOUT`**: "the digest is calculated as if `SIGHASH_ANYONECANPAY`
  was set, **except `outpoint` is not included** in the digest." Still commits to
  `amount (8)` and `scriptPubKey (35)`.
- **`SIGHASH_ANYPREVOUTANYSCRIPT`**: "except **`outpoint`, `amount`, `scriptPubKey`
  and `tapleaf_hash` are not included**."
- Purpose: "Removing this commitment allows **dynamic rebinding** of a signed
  transaction to another previous output that requires authorisation by the same key."
- `nSequence` **is** committed in both digests. Valid `hash_type` bytes:
  `0x41, 0x42, 0x43, 0xc1, 0xc2, 0xc3`.
- **Status: Draft; deployment TODO — not activated on mainnet.**

## Why it matters to the thesis (the presigning wall)

Standard signatures **commit to the exact outpoint**, so "a new signature must be
created for every possible transaction one wishes to be able to react to." A
coinbase txid depends on the mined block (BIP-34 height + extranonce + witness
merkle root) and is unknown at signing time. Under current consensus (APO **not**
active), you cannot produce the BOLT-required commitment signature over a coinbase
funding outpoint before the coinbase exists.

- APO would omit the outpoint → presign a spend of an unmined coinbase. But plain
  APO **still commits to the amount**, and coinbase value (subsidy + fees) varies,
  so you'd need APOAS or a structurally-fixed value.
- On Bitcoin Inquisition signet, a single APOAS signature has been demonstrated
  spending multiple differently-valued coinbase outputs (fee-leakage is the direct
  symptom of dropping the amount commitment). See local prior art:
  [[../../../sighash-anyprevout-bip118/wiki/topics/coinbase-outpoint-presigning|coinbase-outpoint-presigning]].

## The no-soft-fork alternative

The unknown-txid problem also dissolves **without** APO if you defer signing to
**post-block-found**: once the block is found, the winning coinbase bytes freeze,
`coinbase_txid:0` is known, and an ordinary BIP-341/BIP-327 MuSig2 signature
suffices. See [[../../../ark-boarding-sv2-mining/wiki/concepts/post-block-found-signing|post-block-found signing]].
Neither route removes the **100-block maturity** constraint — that is an *inclusion*
constraint, not a *signing* one.
