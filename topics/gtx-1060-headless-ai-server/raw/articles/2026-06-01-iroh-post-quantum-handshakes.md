---
title: "Iroh post-quantum key exchange (iroh blog)"
source: https://www.iroh.computer/blog/iroh-post-quantum-handshakes
type: article
tags: [iroh, post-quantum, ml-kem, x25519mlkem768, tls13, rpk]
date: 2026-06-01
publication_date: 2026-05-19
quality: 5
confidence: high
agent: 4
summary: "Iroh now supports ML-KEM-768 and the hybrid X25519MLKEM768 KEM in TLS 1.3 over QUIC, sitting on top of raw public key (RPK) cert verification. Requires aws-lc-rs backend (the 'pluggable crypto backends' from 0.98) plus the prefer-post-quantum rustls feature. Opt-in, not default; ~1 KB per direction overhead, multi-packet handshake. Ed25519 still used for endpoint identity (no PQ signatures yet, no industry consensus). Motivated by harvest-now/decrypt-later."
---

# Iroh post-quantum key exchange

Direct answer to: "do we need user-level Noise IK on top of iroh, or is iroh's TLS-with-RPK enough?"

## Crypto stack

- Identity: **Ed25519** (unchanged) — no PQ signatures yet, no industry consensus
- Key exchange: **X25519MLKEM768** hybrid (classical X25519 + post-quantum ML-KEM-768)
- TLS 1.3 with **raw public key (RPK)** cert verification (no x509)
- Crypto backend: **aws-lc-rs** required (selected via 0.98 pluggable backends)
- Rustls feature: `prefer-post-quantum`

## Wire impact

- ~1 KB per direction added to the handshake
- Multi-packet handshake required (single QUIC packet not big enough)
- Opt-in, not default

## Threat model

Motivated by **harvest-now / decrypt-later**: an adversary records ciphertext today, hopes to decrypt with a future quantum computer. Hybrid KEM thwarts this for any session whose key derivation includes ML-KEM contribution.

## What this means for the wiki's Noise-on-iroh question

N0's effective answer:

> "RPK + (optionally) PQ KEM is enough for transport security. You don't need user-level Noise IK on top."

Defense-in-depth via Noise on top of iroh would still be valid (independent crypto layers), but is not the recommended architecture.

For the GTX 1060 AI server: enabling `prefer-post-quantum` adds ~1 KB to handshakes — negligible at homelab scale. Worth turning on if you're shipping ticket-encoded long-term identifiers (since ticket-bearing devices may be recorded today for later attack).

## See also

- [[2026-06-01-noise-protocol-framework-rev34]] — what Noise IK actually buys
- [[2026-06-01-iroh-1-0-0-rc-1]]
