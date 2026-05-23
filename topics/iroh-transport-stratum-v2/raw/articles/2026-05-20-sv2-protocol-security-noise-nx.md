---
title: "Stratum V2 Protocol Security (Noise NX)"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md
type: spec
date: 2026-05-20
org: SRI / Stratum V2 Working Group
credibility: high
quality: 5
relevance: direct
tags: [sv2, noise-nx, security, spec, handshake]
ingested: 2026-05-20
---

# Stratum V2 — Protocol Security (Noise NX)

## Handshake = Noise_NX (server authentication)

Three acts:

| Act | Direction | Payload | Notes |
|-----|-----------|---------|-------|
| 1 | initiator → responder | `e` (ephemeral pubkey) | **64 bytes EllSwift-encoded** |
| 2 | responder → initiator | `e, ee, s, es, SIGNATURE_NOISE_MESSAGE` | responder ephemeral + encrypted static + signed certificate |
| 3 | post-handshake | (initiator validates cert signature) | identity verified |

## Cryptographic primitives

| Function | Algorithm |
|----------|-----------|
| Curve | secp256k1 |
| Signature | Schnorr (BIP340) |
| Hash | SHA-256 |
| AEAD | ChaCha20-Poly1305 (default) or AES-GCM |
| AEAD MAC length | 16 bytes |
| Ephemeral encoding | EllSwift (64 bytes) |

## Certificate format

```
Version          U16
Valid From       U32   (unix timestamp)
Not Valid After  U32   (unix timestamp)
Server Pubkey    32B
Authority Pubkey 32B
Signature        64B
```

The **authority pubkey** is what gets distributed to clients (base58check
versioned `[1, 0]`) and embedded in pool URLs:

```
stratum2+tcp://thepool.com:34254/9bXiEd8boQVhq7WddEcERUL5tyyJVFYdU8th3HfbNXK3Yw6GRXh
```

## Frame impact

- Plaintext SV2 header: **6 bytes** (extension_type U16 + msg_type U8 + msg_length U24).
- Encrypted SV2 header: **22 bytes** (6 + 16-byte AEAD MAC).
- Max transport message (ciphertext): **65,535 bytes**.
- Payload chunked at 65,519 bytes (+16 MAC = 65,535).

## Mandatory vs optional

- **Mandatory** for remote (pool, JD, TP) connections.
- **Optional** on local LAN.

## Failure mode

> Handshake aborts on any decryption/auth failure.

## Implications for Iroh integration

- The Noise_NX handshake is structurally redundant inside an iroh QUIC connection
  that already does TLS 1.3 with raw public keys. Both achieve mutual or
  one-sided authenticated encryption with forward secrecy.
- If Noise is kept (`NoiseIrohStream`/`IrohConnection`): integrators get
  defense-in-depth and the formally-analyzed Noise_NX security profile.
- If Noise is dropped (`PlainIrohConnection`): integrators trust iroh's TLS-RPK
  alone. **This forfeits AEAD-frame integrity at the SV2 framing layer**, which
  is the property that defeats Erosion-style single-packet tampering attacks
  (Tran et al., S&P 2024).
- Curve mismatch: SV2 authority keys are secp256k1; iroh `EndpointId` is
  Ed25519. The two key spaces cannot be made equivalent — a pool will need to
  publish BOTH (secp256k1 for legacy stratum2+tcp URLs, Ed25519 for iroh
  endpoint dialing) until/unless the SV2 spec gains an Ed25519-based
  authority-key encoding.
- Frame size cap (65,535 ciphertext bytes) is well below QUIC stream limits, so
  no friction from the carrier layer.
