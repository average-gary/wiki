---
title: "MuSig2: Simple Two-Round Schnorr Multi-Signatures"
source: "https://eprint.iacr.org/2020/1261"
type: papers
ingested: 2026-07-16
tags: [musig2, schnorr, multisignature, two-round, concurrent-security, omdl, algebraic-group-model, key-aggregation]
summary: "The canonical MuSig2 paper (Nick, Ruffing, Seurin — CRYPTO 2021). Defines the two-round Schnorr multi-signature that is secure under concurrent sessions, with key aggregation and Schnorr-identical output size. The first (nonce) round is message-independent and can be preprocessed, so signing is effectively one online round."
---

# MuSig2: Simple Two-Round Schnorr Multi-Signatures

**Authors**: Jonas Nick, Tim Ruffing (Blockstream), Yannick Seurin (ANSSI).
**Venue**: CRYPTO 2021; IACR ePrint 2020/1261 (received 2020-10-14, last revised 2023-10-20).

## Key findings

- Achieves **two communication rounds** while remaining secure under **concurrent signing sessions**. The first round (public-nonce exchange) is independent of the message and can be **preprocessed**, making the interactive part effectively **non-interactive** at signing time (one online round in practice).
- All *previously proposed* two-round DL-setting multisignature schemes had been shown insecure under concurrent sessions before this work (see Drijvers et al. IEEE S&P 2019). MuSig2 is the first practical two-round scheme with a security proof, keeping key and signature sizes identical to plain Schnorr.
- **Two proof variants**: (1) a proof under a weaker variant of the **OMDL** (one-more discrete log) assumption in the **Random Oracle Model (ROM)**; (2) a more efficient variant proven in the combined **ROM + Algebraic Group Model (AGM)**. The efficient variant uses fewer nonces.
- Supports **key aggregation** as a core design goal: the joint signature verifies against a single aggregated public key exactly like a single-signer Schnorr signature.
- Core mechanism: each signer sends **ν public nonces** in round 1 (typically ν=2 for the AGM proof; ν=4 for the ROM-only proof). The effective per-signer nonce is a linear combination `R_i = Σ_j b^{j-1} · R_{i,j}` where the coefficient(s) `b` are hashes binding all signers' nonces, the aggregate key, and the message.

## Notes / caveats

- The PDF body (eprint 2020/1261.pdf, HTTP 403 to automated fetchers) contains the exact ν-nonce parameterization, the **MuSig2\*** key-aggregation optimization (removes an exception case / saves one exponentiation), and the precise **AOMDL** ("algebraic OMDL") definition. These were not fully extracted; re-fetch if a proof-level treatment is needed.

## What this source contributes

The definitional primary source for the whole topic: the two-round construction, the multi-nonce trick that yields concurrent security without a commitment round, key aggregation, and the formal security assumptions.
