---
title: "Cendyne — Ed25519 Deep Dive Addendum"
source_url: https://cendyne.dev/posts/2022-09-11-ed25519-deep-dive-addendum.html
type: critique
ingested: 2026-06-01
date_published: 2022-09-11
quality: 5
confidence: high
tags: [ed25519, library-divergence, side-channel, contrarian, security]
relevance: [single-slot-identity, signed-envelopes]
---

# Ed25519 Deep Dive Addendum (Cendyne, 2022)

Concrete, named-incident catalogue of why "just use ed25519 long-lived" is not free.

## Library-divergent verification

"RFC8032, OpenSSL, dalek, LibSodium, zebra, donna, and even the Go crypto library all behave differently." A signature one library accepts another rejects — **catastrophic for a fleet that mixes verifier implementations across server and device.**

## Real-world incidents

- **Tor**: a batch-verification bug accepted malicious signatures
- **ZCash**: had a consensus crisis after LibSodium changed validation rules, forcing them to ship `ed25519-zebra` to replicate old behavior "bug for bug"

## Side-channel attacks

Fault/glitch attacks on ed25519 are practical: keys recoverable "with a cheap software-defined radio" by inducing signing under glitched power. **Long-lived device keys in physically accessible edge boxes are the worst case** — one key extraction compromises every signature ever produced.

## Public-key confusion bug

Signing APIs that accept a separate public key parameter let an attacker provoke two valid signatures for the same message → private key recovery. **Wrap signing to derive public key internally.**

## Signature malleability

Reference impl historically lacked the L-bound check → signature malleability (not SUF-CMA secure). Matters anywhere a signature is used as an idempotency key.

## Late formal proof

Original 2011 paper had **no formal security proof until 2020** (Brendel et al. — see [[2026-06-01-ed25519-provable-security]]).

## Mitigations for fleet operators

1. Pin **one verifier impl** across server and edge (don't mix dalek-server with libsodium-edge)
2. Require RFC 8032 / Ed25519-IETF variant (SUF-CMA secure)
3. Wrap signing API to derive pubkey internally
4. Pair with hardware-backed key storage (TPM, SE, TrustZone) where possible — closes the side-channel window
5. Plan rotation cadence based on physical-access threat model, not purely cryptographic considerations

## See also

- [[2026-06-01-ed25519-provable-security]]
- [[2026-06-01-rfc-9052-cose-structures]]
