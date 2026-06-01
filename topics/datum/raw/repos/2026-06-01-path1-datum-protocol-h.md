---
title: "datum_protocol.h — DATUM Protocol wire-format header"
source: "https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_protocol.h"
type: repos
tags: [datum, datum-protocol, wire-format, opcodes, encryption, libsodium, ocean, c-source]
summary: "The C header file that authoritatively defines the DATUM Protocol wire format: 8-byte packed header with bit-flagged encryption fields, 5-bit proto_cmd opcode space (32 commands), Ed25519 + X25519 keypair structs, share-submission and rejection-code constants. Protocol version pinned at v0.4.1-beta."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 5
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_protocol.h"
license: MIT
revision_branch: master
---

# datum_protocol.h — wire-format header

Authoritative C definitions for the DATUM Protocol. This is the closest thing to a published spec; the README still claims the spec is "evolving and will be published elsewhere" but every constant and struct that defines the wire format lives here.

## Protocol identity

- `DATUM_PROTOCOL_VERSION` — string `"v0.4.1-beta"`. Sent in the handshake; embedded alongside `GIT_COMMIT_HASH` and optional `BUILD_GIT_TAG`.
- `DATUM_PROTOCOL_CONNECT_TIMEOUT` — 30 seconds.
- `MAX_DATUM_PROTOCOL_JOBS` — 8 concurrent jobs.
- `DATUM_PROTOCOL_MAX_CMD_DATA_SIZE` — 4,194,304 bytes (2^22). Hard cap on a single command payload.
- `DATUM_PROTOCOL_BUFFER_SIZE` — 3 × MAX_CMD_DATA_SIZE.
- `MAX_DATUM_CLIENT_EVENTS` — 32 (epoll batch size).

## The header struct (`T_DATUM_PROTOCOL_HEADER`, packed)

A single 32-bit word, bit-packed:

| Field | Bits | Meaning |
|---|---|---|
| `cmd_len` | 22 | Length of command payload in bytes (matches MAX_CMD_DATA_SIZE) |
| `reserved` | 2 | Reserved for future use |
| `is_signed` | 1 | Whether payload carries an Ed25519 signature |
| `is_encrypted_pubkey` | 1 | Sealed-box (one-shot) X25519 encryption (handshake only) |
| `is_encrypted_channel` | 1 | Authenticated session encryption (post-handshake) |
| `proto_cmd` | 5 | Top-level command — only **32 opcodes possible** in the protocol |

Implication: the protocol distinguishes **three encryption modes** at the framing layer — unencrypted, sealed-box (handshake), and authenticated channel (steady-state) — and signaling and encryption are independent (signed-and-encrypted, signed-only, etc.).

## Opcode space (the 5-bit `proto_cmd`)

Observed top-level commands:

- `1` — PING
- `2` — Handshake response (server → client)
- `5` — Mining command (the workhorse — most traffic is sub-dispatched under this)
- `7` — Server INFO/MOTD

That's only 4 of 32 commands documented; the rest are reserved or used in less common paths.

### Sub-opcodes under `proto_cmd = 5`

| Subcmd | Meaning |
|---|---|
| `0x99` | Client configuration |
| `0x11` | Coinbaser response (pool → client) |
| `0x10` | Coinbaser request (client → pool) |
| `0x50` | Job validation commands (further sub-dispatched) |
| `0x8F` | Share-submission response |
| `0xF9` | Block notification |

Job-validation sub-sub-opcodes under `0x50`:

| Subcmd | Meaning |
|---|---|
| `0x10` | Send short transaction ID list (compact-block style) |
| `0x11` | Send requested transactions by ID |
| `0x12` | Send entire block transactions |

This nested dispatch lets the pool reconstruct the block by asking only for txns it doesn't already have — reducing bandwidth in the present-version "pool validates the block" trust model the README warns will be removed in a future revision.

## Cryptographic key structs

- `DATUM_ENC_KEYS` — holds an Ed25519 keypair (`pk_ed25519` / `sk_ed25519`, 32 + 64 bytes per libsodium) **and** an X25519 keypair (`pk_x25519` / `sk_x25519`, 32 + 32 bytes). Each side maintains a long-term keypair AND a session keypair, so 4 keypairs total per side.
- `DATUM_ENC_PRECOMP` — output of `crypto_box_beforenm()`: a precomputed shared secret used with `crypto_box_easy_afternm()` for fast post-handshake AEAD.

## Share submission and PoW

- `T_DATUM_PROTOCOL_JOB` — tracks each of the up-to-8 pool-side jobs and their stratum integration.
- `T_DATUM_PROTOCOL_POW` — encapsulates a share submission: nonce, ntime, target byte, version, extranonce, etc.

## Response codes (share submissions)

```
DATUM_POW_SHARE_RESPONSE_ACCEPTED              = 0x50
DATUM_POW_SHARE_RESPONSE_ACCEPTED_TENTATIVELY  = 0x55
DATUM_POW_SHARE_RESPONSE_REJECTED              = 0x66
```

The `ACCEPTED_TENTATIVELY` state is unique to DATUM and reflects the trust model: shares that look valid but need pool-side block validation before being credited. SV1 has no equivalent — it's "accepted" or "rejected." This tri-state response is one of the cleanest tells that DATUM is a different protocol family.

## Rejection codes (`DATUM_REJECT_*`)

Range 10–30 covering: bad job ID, coinbase issues, target mismatches, hash validation, stale blocks. (Header lists named codes; semantic taxonomy is similar to SV1 but more granular and binary, not string.)

## Why this matters for the SV2-downstream-proxy design

If you're building a binary that speaks SV2 to miners and DATUM upstream, this header is the spec you'd map against. Two big surprises vs SV1:

1. The 5-bit opcode space is **tiny** (32 max). There's not a lot of room for protocol expansion without a version bump or a sub-dispatched escape hatch (which is what `proto_cmd=5` already is).
2. Encryption is **first-class at the framing layer** (header bits), not a transport-layer wrapper. SV2 uses Noise inside a TCP socket; DATUM uses libsodium primitives with framing-layer flags. A translator has to invert this difference, not just remap message types.

## Known gaps in this header

- No published Markdown spec — the header is the spec.
- The `reserved` 2 bits and most of the 32-opcode space are undocumented in this version. A future revision (the README's promised "almost completely blinded" pool model) would consume some of these.

## Sources

- [datum_protocol.h @ master](https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_protocol.h) — file size 5,934 bytes, 144 lines (approx) at HEAD `a3da9e69` (2026-04-06).
