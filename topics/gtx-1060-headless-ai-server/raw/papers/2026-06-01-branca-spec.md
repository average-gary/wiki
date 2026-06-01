---
title: "Branca Token Specification"
source: https://github.com/tuupola/branca-spec
type: paper
tags: [branca, xchacha20-poly1305, token, minimal, qr-friendly, spec]
date: 2026-06-01
quality: 4
confidence: high
agent: academic
summary: "Single-version, single-cipher format. Fixed wire layout: Version(1B=0xBA) || Timestamp(4B BE u32) || Nonce(24B) || Ciphertext(*) || Tag(16B), base62-encoded. Fixed overhead = 45 bytes before payload + base62 expansion (~37% bloat). Always IETF XChaCha20-Poly1305 (no algorithm agility). Built-in 4-byte timestamp gives server-side TTL enforcement for free; rolls over in 2106. Spec is intentionally tiny — a few pages of pseudocode; trivial to implement in ~200 lines of Rust."
---

# Branca

The minimal-overhead alternative to PASETO. Right pick if QR-code byte budget matters.

## Wire layout

```
[ 0xBA | timestamp(4 BE) | nonce(24) | ciphertext(*) | tag(16) ]
```

Then base62-encoded. **Fixed overhead = 45 bytes** before payload. Base62 adds ~37% bloat.

## Cipher

Always **IETF XChaCha20-Poly1305**. No algorithm agility = no negotiation footguns.

## Built-in timestamp

4-byte big-endian unix seconds. Server enforces TTL by checking `now() - token.timestamp < ttl`. Rolls over in **year 2106** — fine for our purposes.

## Spec size

A few pages of pseudocode. Trivial to implement in ~200 lines of Rust on top of `chacha20poly1305`. Reference: `branca` crate 0.10.2 (2025-07-22).

## Why this matters for the iroh app token

For a **single-use printed sticker** (e.g., a guest QR on a refrigerator), every byte counts. Compare for a 64-byte payload:

| Format | Total wire bytes | Notes |
|--------|------------------|-------|
| Branca (base62)         | (45 + 64) × 1.37 ≈ **149 chars** | minimal |
| PASETO v4.local (b64u)  | ~10 prefix + (32 nonce + 64 ct + 16 tag) × 1.33 ≈ **160 chars** + footer | comparable |
| JWT HS256               | 36 header + 64 claims-b64u + 32 sig-b64u ≈ 200+ chars | bloated |
| Biscuit v3 (Protobuf+b64) | 200+ chars typical (Ed25519 sigs are 64B each, multiple blocks) | rich but heavy |

QR-code Alphanumeric mode at version 25 / Q error correction holds ~1100 chars; all four fit. **For the homelab use case Branca is overkill on minimization** — PASETO's footer + implicit-assertion features are worth ~10 extra chars.

## API (branca crate 0.10.2)

```rust
let branca = Branca::new(&key)?;
let token = branca.encode(payload_bytes)?;        // bytes
let payload = branca.decode_with_timestamp(&token)?;  // (Vec<u8>, u32)
```

Single TTL check is the only built-in policy. Anything else — flags, NodeId binding, single-use marks — **must be in the payload bytes** and validated by application code.

## Trade-off vs PASETO

Pick PASETO v4 if you want:

- Footer for non-secret hints (revocation epoch)
- Implicit assertion (bind NodeId without transmitting)
- Versioned protocol evolution

Pick Branca if you want:

- Smallest possible wire size
- Minimal dependency (one crate, ~200 LOC)
- Pure opaque AEAD bag-of-bytes

For the iroh app token wrapper as designed, **PASETO v4 wins** — the footer's revocation-epoch slot and the implicit-assertion's NodeId binding are exactly what we need.

## See also

- [[2026-06-01-paseto-v4-spec]]
- [[2026-06-01-rfc-8392-cwt]]
