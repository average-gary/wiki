---
title: "On the (in)security of ROS"
source: "https://eprint.iacr.org/2020/945"
type: papers
ingested: 2026-07-16
tags: [ros-attack, wagner-attack, concurrent-security, blind-signatures, frost, musig, schnorr, generalized-birthday]
summary: "Benhamouda et al. (Journal of Cryptology 2022). Gives a polynomial-time algorithm for the ROS problem when dimensions exceed log p, and a sub-exponential attack for any dimension via Wagner's generalized birthday. Breaks concurrently-run Schnorr/Okamoto-Schnorr blind signatures, the original FROST, CoSI, and two-round MuSig — the attack class MuSig2's design must resist."
---

# On the (in)security of ROS

**Authors**: Fabrice Benhamouda, Tancrède Lepoint, Julian Loss, Michele Orrù, Mariana Raykova.
**Venue**: Journal of Cryptology 2022; IACR ePrint 2020/945 (received 2020-07-31; 2024 revision clarifies scope).

## Key findings

- Provides a **polynomial-time** algorithm solving the **ROS** problem (Random inhomogeneities in an Overdetermined Solvable system of linear equations) when the number of dimensions **ℓ > log₂ p**.
- Combined with **Wagner's generalized-birthday attack**, this yields a **sub-exponential** solution for *any* dimension ℓ (best known complexity).
- When **concurrent executions** are permitted, the attack breaks a broad class of schemes: Schnorr and Okamoto–Schnorr **blind signatures**, the GJKR and **original FROST** threshold schemes, **CoSI**, the **two-round version of MuSig** multisignatures, and Abe–Okamoto / ZGP17 partially-blind schemes.
- A 2024 revision clarifies the attack does **not** extend to [BL13] and [CZMS06].

## What this source contributes

Explains precisely *why* naive two-round Schnorr multisig (single-nonce) is insecure under concurrency, and therefore why MuSig2 must use multiple nonces bound by a hash. This is the security-theoretic reason the ceremony is structured the way it is — the attack that the commitment round (MuSig1) and the two-nonce trick (MuSig2) both defend against.
