---
title: "Stratum V2 Protocol Overview (framing)"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/03-Protocol-Overview.md
type: spec
date: 2026-05-20
org: SRI / SV2 WG
credibility: high
quality: 5
relevance: direct
tags: [sv2, framing, codec, spec]
ingested: 2026-05-20
---

# Stratum V2 — Protocol Overview / Framing

## Frame header (6 bytes)

```
extension_type   U16
msg_type         U8
msg_length       U24
```

- `extension_type = 0x0000` → core messages.
- High bit of `extension_type` = `channel_msg` flag.
- When `channel_msg` is set, **first 4 payload bytes = `channel_id`** (U32).

## Variable-length types

| Type | Max bytes |
|------|-----------|
| STR0_255 | 255 |
| B0_255 | 255 |
| B0_64K | 65,535 |
| B0_16M | 16,777,215 |

## Endianness

> "Multibyte data types are always serialized as little-endian."

## Channel multiplexing

Channels enable proxies to aggregate multiple devices on one connection. A
translator proxy talking SV1 downstream and SV2 upstream uses one SV2 connection
with N channels for N SV1 miners.

## Implications for Iroh

- An iroh QUIC connection is a **per-peer** carrier. Channels (multiplexed inside
  one SV2 connection) remain at the SV2 framing layer — they are NOT mapped to
  separate QUIC streams. The integration shape is:
  - 1 iroh `Endpoint` per process
  - 1 iroh `Connection` per peer (proxy↔pool, miner↔proxy, etc.)
  - 1 bidi QUIC stream per `Connection` carrying the SV2 byte stream
  - SV2 channels remain inside that stream, multiplexed by `channel_msg` bit
- **OR**: open separate QUIC bidi streams per SV2 channel and let QUIC's
  per-stream flow control replace SV2's channel multiplexing. This is structurally
  cleaner but breaks wire compat with TCP-based SV2 — every channel-aware piece
  of code in `roles_logic_sv2` would need a new abstraction.
- Recommendation (default): preserve the SV2 framing, run it as bytes over a
  single bidi QUIC stream — minimum-diff path to a working transport.
