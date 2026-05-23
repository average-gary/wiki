---
title: "SV2 Noise NX handshake"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-20-sv2-protocol-security-noise-nx.md
  - raw/articles/2026-05-20-sv2-protocol-overview-framing.md
  - raw/papers/2024-erosion-routing-attacks-mining-pools.md
tags: [sv2, noise, handshake, security]
---

# SV2 Noise NX

The current authenticated-encryption layer for Stratum v2 connections.

## Handshake (Noise_NX)

Three acts. Server-only authentication (initiator/miner is anonymous).

| Act | Direction | Payload | Notes |
|-----|-----------|---------|-------|
| 1 | initiator → responder | `e` | 64 bytes, EllSwift-encoded |
| 2 | responder → initiator | `e, ee, s, es, sig` | responder ephemeral + encrypted static + signed cert |
| 3 | (validate) | initiator validates cert signature | identity verified |

## Crypto choices

- secp256k1 + Schnorr (BIP340) — for **identity** signatures (NOT the channel keys).
- SHA-256.
- AEAD: **ChaCha20-Poly1305** (default) or AES-GCM.
- AEAD MAC = 16 bytes.

## Cert format

```
Version          U16
Valid From       U32   unix ts
Not Valid After  U32   unix ts
Server Pubkey    32B
Authority Pubkey 32B
Signature        64B   schnorr
```

Authority pubkey is the **identity miners trust**. Encoded as
base58check-versioned `[1,0]` and embedded in the pool URL:

```
stratum2+tcp://thepool.com:34254/9bXiEd8boQVhq7WddEcERUL5tyyJVFYdU8th3HfbNXK3Yw6GRXh
```

## Frame impact (over Noise)

| Region | Plaintext | Encrypted (with 16-byte MAC) |
|--------|-----------|------------------------------|
| Header | 6 bytes | 22 bytes |
| Payload | up to 65,519 bytes | up to 65,535 bytes (chunked) |

## Why Noise NX matters for the iroh integration

Two design choices, sharply different:

### Option A — Noise inside iroh (`NoiseIrohStream`)

Keep Noise_NX. The SV2 frame is encrypted at the SV2 layer; iroh's TLS
encrypts again on top.

Pros:
- **Mitigates Erosion** (Tran et al. S&P 2024) — the SV2 frame's 16-byte AEAD
  MAC defeats single-packet tampering even if iroh's QUIC layer were somehow
  compromised.
- Preserves the formally-analyzed Noise_NX security profile (Girol et al.
  USENIX Sec '20, Kobeissi & Nicolas EuroS&P '19).
- Keeps the existing `noise_sv2` crate doing real work — minimal refactor.

Cons:
- Double encryption (~2× crypto cost per byte). Mostly irrelevant at
  share-submission throughput.
- Two pubkey identities to manage (secp256k1 authority + Ed25519 EndpointId).

### Option B — Plain iroh (`PlainIrohConnection`)

Drop Noise. Trust iroh's TLS-RPK + RFC 7250 alone.

Pros:
- Simpler. One handshake.
- Single identity (Ed25519 EndpointId).
- Faster handshake (TLS 1.3 + 0-RTT possible).

Cons:
- **Loses the SV2-frame AEAD integrity property**. If a future bug in noq /
  rustls / iroh allowed packet injection, no SV2-layer defense remains.
- Forfeits the Noise_NX formal analysis. TLS 1.3 with RPK has its own analyses
  but they're different proofs.
- Curve mismatch with SV2 spec — the `Authority Pubkey` field of the SV2 cert
  is secp256k1, while the iroh identity is Ed25519. Either spec changes or
  the pool dual-publishes.

## Recommendation

**Default to Option A** for `feat/iroh-transport`. It's the lower-risk,
higher-defense choice. Keep Option B available behind a feature flag for
operators who specifically want minimum overhead.

## See also

- [[Erosion attack on SV2 — single-packet tampering|wiki/concepts/erosion-attack.md]]
- [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]]
