---
title: "MuSig-DN: Schnorr Multi-Signatures with Verifiably Deterministic Nonces"
source: "https://eprint.iacr.org/2020/1057"
type: papers
ingested: 2026-07-16
tags: [musig-dn, deterministic-nonces, nonce-reuse, zero-knowledge-proof, multisignature, schnorr, stateless-signing]
summary: "Nick, Ruffing, Seurin, Wuille (ACM CCS 2020). Standard derandomization (RFC 6979) is NOT safe for multi-signatures: an attacker can trick an honest signer into two partial sigs with the same nonce on different challenges, revealing the key. MuSig-DN derives nonces as a PRF of message + all cosigner keys and attaches a ZK proof of correct derivation, giving stateless (non-persistent-nonce) signing."
---

# MuSig-DN: Schnorr Multi-Signatures with Verifiably Deterministic Nonces

**Authors**: Jonas Nick, Tim Ruffing, Yannick Seurin, Pieter Wuille.
**Venue**: ACM CCS 2020; IACR ePrint 2020/1057 (received 2020-09-01, revised 2020-10-15).

## Key findings

- States plainly that standard **derandomization (e.g., RFC 6979) is NOT applicable to multi-signatures**: an active adversary can trick an honest signer into producing **two partial signatures with the same nonce on different challenges**, which **directly reveals the secret key**.
- **Contrast with single-party BIP-340**: BIP-340's stateless deterministic-nonce derivation is safe for a *single* signer (no adversary can vary the challenge for a fixed message + key), but multi-party determinism must bind to *collective* key material to prevent per-signer manipulation.
- **Solution**: derive the nonce as a **PRF of the message and all cosigners' public keys**, then attach a **non-interactive zero-knowledge proof** (over an arithmetic circuit with Pedersen commitments) that the nonce was derived correctly. Cosigners verify determinism without trusting the signer's randomness.
- Trade-off: eliminates the need to persist/reuse-guard a secret nonce (stateless signing, no reuse hazard on restart/backup), at the cost of an expensive ZK proof per signature. MuSig2 takes the opposite trade: cheap, but requires fresh randomness and careful non-reuse of the secret nonce.

## What this source contributes

The authoritative primary explanation of the nonce-reuse catastrophe in multi-party signing and why deterministic nonces are dangerous there (the direct contrast with single-signer BIP-340). Also frames the design axis — stateless-deterministic (MuSig-DN, ZK-proof cost) vs. stateful-random (MuSig2, reuse-guard cost) — that governs ceremony state-machine design.
