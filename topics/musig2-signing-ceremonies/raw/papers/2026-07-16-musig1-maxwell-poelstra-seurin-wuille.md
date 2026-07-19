---
title: "Simple Schnorr Multi-Signatures with Applications to Bitcoin (MuSig / MuSig1)"
source: "https://eprint.iacr.org/2018/068"
type: papers
ingested: 2026-07-16
tags: [musig, musig1, schnorr, multisignature, three-round, key-aggregation, plain-public-key-model, rogue-key-attack, nonce-commitment]
summary: "The original MuSig paper (Maxwell, Poelstra, Seurin, Wuille). Introduces key aggregation in the plain public-key model (no proof-of-knowledge needed). Documents that the originally-proposed two-round MuSig had a flawed proof, so the published scheme uses a provably-secure three-round variant with a nonce-commitment round — the round MuSig2 later removes."
---

# Simple Schnorr Multi-Signatures with Applications to Bitcoin (MuSig1)

**Authors**: Gregory Maxwell, Andrew Poelstra, Yannick Seurin, Pieter Wuille.
**Venue**: IACR ePrint 2018/068 (received 2018-01-18, revised 2018-05-20). Later published in Designs, Codes and Cryptography.

## Key findings

- Introduces **key aggregation**: the joint signature verifies as a standard Schnorr signature against a single aggregated public key; keys and signatures are the same size as plain Schnorr.
- Operates in the **plain public-key model** — signers need only publish a public key, with **no proof-of-knowledge of the secret key required**. Rogue-key attacks are defeated by per-signer aggregation coefficients `a_i = H(L, X_i)` (where `L` is the multiset of all pubkeys).
- Critically documents that the **originally proposed two-round MuSig had a flawed security proof** (the flaw is described in ePrint 2018/417, Drijvers et al.). The paper states "the security of 2-round MuSig does not appear to be provable under standard assumptions."
- The published version therefore falls back to a **provably secure three-round variant** (proof under the plain DL assumption). The three rounds are: (1) each signer commits to their nonce by broadcasting `t_i = H(R_i)`; (2) each signer reveals `R_i`; (3) each signer sends their partial signature. The **commitment round exists specifically to prevent an adversary from choosing its nonce adaptively** after seeing others' nonces.

## What this source contributes

Supplies the "why three rounds in MuSig1, and why that was a problem" context. The nonce-commitment (commit/reveal) round is the direct predecessor to MuSig2's approach — MuSig2 achieves the same adaptive-nonce protection via its two-nonce hash-binding trick instead of a separate commitment round, cutting three rounds to two.
