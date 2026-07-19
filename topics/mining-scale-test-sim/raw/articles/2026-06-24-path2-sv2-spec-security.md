---
title: "SV2 spec §04: Noise_NX handshake — wire format & primitives"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, connections, sv2, noise, spec, primary-source]
---

# SV2 spec §04 — Protocol Security

The Stratum V2 spec section defining the handshake and transport
encryption that every SV2 pool implementation must obey. Establishes
exactly what crypto cost a SV2 pool pays per connection.

## Handshake pattern: **Noise_NX**

> "The handshake chosen for the authenticated key exchange is an
> **Noise_NX** augmented by server authentication with simple 2 level
> public key infrastructure."

Three acts:
1. `-> e` (initiator's ephemeral, plaintext, 64 B ElligatorSwift-encoded)
2. `<- e, ee, s, es, SIGNATURE_NOISE_MESSAGE` (170 B: responder eph + ECDH +
   encrypted static + encrypted cert)
3. Initiator verifies the certificate signature using a 2-level PKI.

## Cryptographic primitives

| Primitive    | Choice                                           |
|--------------|--------------------------------------------------|
| AEAD         | ChaCha20-Poly1305 (ChaChaPoly)                  |
| Hash         | SHA-256                                          |
| ECC          | secp256k1 + Schnorr signatures (BIP340)         |
| Encryption key | 32 B                                           |
| Nonce        | 8 B (LE counter padded to 12 B AEAD nonce)      |
| AEAD MAC     | 16 B / block                                     |

## Cost implication

- secp256k1 ECDH dominates handshake CPU.
- Schnorr signature verification on Act 2 dominates initiator (downstream)
  side cost; ECDH×3 dominates responder (pool) side cost.
- ChaCha20-Poly1305 transport is ~5 µs roundtrip for 64-256 B frames
  (see SRI noise-sv2 BENCHES.md, in raw/).

## What the spec does NOT prescribe

- No key rotation policy after handshake. Nonces just increment.
- No session resumption / 0-RTT path. Every reconnect is a full
  Noise_NX (~317 µs of CPU on the pool side per reconnect).
- No connection pooling between proxy and pool — each downstream gets
  its own Noise tunnel.

## Implications for scale

- A **reconnect storm** (1M miners after pool restart) needs ~317 µs × 1M
  = 317 seconds of single-threaded CPU just for handshake. On 64 cores
  with perfect parallelism: ~5 seconds — but kernel accept queue and
  TCP SYN cookies become the actual gate, not crypto.
- No 0-RTT means SV2 has **no resumption advantage** over TLS 1.3, where
  PSK-based 0-RTT would let returning miners skip the bulk of the
  handshake.
- A simulator should explicitly exercise the **reconnect-storm** scenario:
  drop 50% of connections at t=0 and measure time-to-resteady-state at
  N=1k / 10k / 100k.
