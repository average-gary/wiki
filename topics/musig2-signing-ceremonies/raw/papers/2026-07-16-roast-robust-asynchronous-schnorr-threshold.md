---
title: "ROAST: Robust Asynchronous Schnorr Threshold Signatures"
source: "https://eprint.iacr.org/2022/550"
type: papers
ingested: 2026-07-16
tags: [roast, frost, threshold-signatures, robustness, identifiable-abort, asynchronous, dropout-handling, coordinator, denial-of-service]
summary: "Ruffing, Ronge, Jin, Schneider-Bensch, Schröder (ACM CCS 2022). A wrapper that turns a non-robust threshold Schnorr scheme (FROST) into a robust, asynchronous one. Defines robustness as the guarantee that t honest signers can complete even when other signers disrupt; requires the underlying scheme to have exactly one preprocessing + one signing round, identifiable aborts, and concurrent-session security. Directly addresses dropout/abort handling."
---

# ROAST: Robust Asynchronous Schnorr Threshold Signatures

**Authors**: Tim Ruffing (Blockstream), Viktoria Ronge (FAU Erlangen), Elliott Jin (Blockstream), Jonas Schneider-Bensch (CISPA), Dominique Schröder (FAU Erlangen).
**Venue**: ACM CCS 2022; IACR ePrint 2022/550 (revised 2022-09).

## Key findings

- Defines the property that MuSig2 and plain FROST **lack**: **robustness** = "the guarantee that t honest signers are able to obtain a valid signature even in the presence of other malicious signers who try to disrupt the protocol." Its absence means a single disruptive/offline signer prevents completion (a liveness / denial-of-service concern).
- ROAST is a **simple wrapper** that turns a threshold signature scheme (specifically **FROST**) into one with a **robust and asynchronous** signing protocol, tolerating arbitrarily high network latency.
- Places **three requirements** on the underlying scheme, all satisfied by FROST: (1) exactly **one preprocessing round + one signing round** (semi-interactive); (2) **identifiable aborts** — disruptive parties can be detected and attributed; (3) **unforgeability under concurrent signing sessions**.
- **Robustness mechanism** (from the authors' engineering writeup): the coordinator keeps a pool of willing signers and **cyclically assigns groups of t members** to concurrent signing attempts; as a signer returns a valid share, its name goes back in the pool. A disruptive signer "can only hold up one signing attempt at a time," so honest signers eventually complete one. Concrete result: a **67-of-100** setup with **33 malicious signers**, coordinator and signers on different continents, still produces a valid signature within a few seconds.
- Frames non-robustness as a key adoption blocker for threshold signatures in cryptocurrency. A NIST 2026 presentation echoes that identifiable aborts are "deployment-critical" because "a single misbehaving signer can stall protocol execution indefinitely" without them.

## What this source contributes

The authoritative definition of the non-robust / DoS failure mode common to MuSig2 and FROST, the identifiable-abort requirement, and the coordinator-pool pattern that fixes it. Also implies the fresh-nonce-on-retry rule: each new signing attempt is a new session with new nonces (reusing round-1 nonces on retry would be the nonce-reuse catastrophe).
