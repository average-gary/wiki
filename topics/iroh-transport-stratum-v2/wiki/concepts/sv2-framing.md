---
title: "SV2 framing (codec_sv2)"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: cold
confidence: high
sources:
  - raw/articles/2026-05-20-sv2-protocol-overview-framing.md
tags: [sv2, framing, codec]
---

# SV2 framing

## Header (6 bytes)

```
extension_type   U16
msg_type         U8
msg_length       U24
```

- `extension_type = 0x0000` → core SV2 messages.
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

Multibyte fields are **little-endian**.

## Channels

A single SV2 connection multiplexes many channels — typically one per device a
proxy is fronting. Channels are distinguished by `channel_id` in the payload,
not by separate streams.

## Mapping to iroh QUIC

There are two structural choices for SV2-over-iroh:

### Choice A — Single bidi QUIC stream per Connection

Run the existing SV2 byte stream over **one** bidi QUIC stream. Channels
remain inside the stream, multiplexed by `channel_msg` bit.

- ✅ Minimum diff. `codec_sv2` and `roles_logic_sv2` unchanged.
- ✅ Wire-equivalent to TCP — easy to reason about.
- ❌ Head-of-line blocking inside the stream: a slow channel slows all channels.
  But QUIC streams don't HoL block each other; HoL is only inside one stream.

### Choice B — Bidi QUIC stream per channel

Map each SV2 channel to its own QUIC bidi stream. Use QUIC's per-stream flow
control instead of the SV2 channel multiplexer.

- ✅ True per-channel isolation.
- ✅ Future SV2 versions could shed `channel_msg` framing entirely.
- ❌ Big refactor in `roles_logic_sv2` and channel-management code.
- ❌ Setup latency per channel.

## Recommendation

**Choice A** for the first iroh transport. Match the TCP behavior 1:1; revisit
multi-stream only if profiling shows HoL blocking matters.

## See also

- [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]]
- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
