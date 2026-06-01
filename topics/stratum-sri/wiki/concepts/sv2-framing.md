---
title: "SV2 Framing"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-framing-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-framing-sv2-benches.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, framing-sv2, framing, header, channel-msg, no-std]
aliases: ["framing_sv2", "Sv2Frame", "channel_msg bit"]
confidence: high
volatility: cold
verified: 2026-05-28
summary: "The 6-byte SV2 message header (extension_type, msg_type, msg_length) and how the `channel_msg` bit on `extension_type` toggles whether the first 4 bytes of the payload carry a `channel_id`. Implemented by `framing_sv2`."
---

# SV2 Framing

> SV2 is a binary protocol with fixed message framing. Each frame starts with a 6-byte header — `extension_type` (U16), `msg_type` (U8), `msg_length` (U24) — followed by a variable-length payload. `framing_sv2` implements both regular SV2 frames and Noise handshake frames.

## Header layout

Per the [SV2 spec § 3.2 Framing](https://github.com/stratum-mining/sv2-spec/blob/main/03-Protocol-Overview.md#32-framing):

| Field | Width | Description |
|-------|-------|-------------|
| `extension_type` | U16 | Identifier of the extension this message belongs to. |
| `msg_type` | U8 | Identifier of the protocol message. |
| `msg_length` | U24 | Length of the payload, **not** including this 6-byte header. |
| `payload` | BYTES | `msg_length` bytes of message-specific data. |

## The `channel_msg` bit

The least-significant bit of `extension_type` (bit 15, 0-indexed; equivalent to the MSB of the U16 in network order) is repurposed as the `channel_msg` flag:

- **`channel_msg = 1`** — the message is specific to a channel. The first four bytes of `payload` are a U32 `channel_id`. Those four bytes are still counted in `msg_length`.
- **`channel_msg = 0`** — the message is interpreted by the immediate receiver and has no `channel_id` prefix.

Extension lookup ignores `channel_msg`: an `extension_type` of `0x8ABC` is the same extension as `0x0ABC`. JDP and TDP frames always have `channel_msg = 0`, since those subprotocols don't run on a mining channel — see [[sv2-job-declaration-subprotocol|JDP]] ([JDP](../topics/sv2-job-declaration-subprotocol.md)) and [[sv2-template-distribution-subprotocol|TDP]] ([TDP](../topics/sv2-template-distribution-subprotocol.md)).

## Components

`framing_sv2` exposes:

- **Header** — the 6-byte struct above, knowing how to read/write `extension_type`, `msg_type`, `msg_length`, and the `channel_msg` interpretation.
- **Sv2 Framing** — serializes a plaintext SV2 message frame (`Sv2Frame`).
- **Noise Handshake Framing** — serializes Noise protocol handshake messages, used during the [[sv2-noise-handshake|Noise handshake]] ([Noise handshake](sv2-noise-handshake.md)) before transport keys exist.

## Features and benchmarks

The crate has one feature flag, `with_buffer_pool`, which routes framing allocations through the [[sv2-buffer-pool|SV2 buffer pool]] ([SV2 buffer pool](sv2-buffer-pool.md)). Criterion benchmarks under `benches/framing.rs` track encode/decode regression cost; the BENCHES.md notes that results are for relative comparison, not absolute performance claims.

## Where it sits

```
   typed message           SV2 frame on the wire
  ┌────────────┐         ┌──────────────────────┐
  │ Rust struct│  encode │ 2B ext  1B mt  3B len│
  │ (binary_sv2│ ──────► │ + (4B chan_id)?      │
  │  fields)   │         │ + payload bytes…     │
  └────────────┘         └──────────────────────┘
       ▲                            │
       │                            ▼
   parsers_sv2 ◄── framing_sv2 ── codec_sv2 (encrypts via noise_sv2 if enabled)
```

`framing_sv2` is the layer between the [[sv2-binary-encoding|binary encoding]] ([binary encoding](sv2-binary-encoding.md)) of fields and the [[sv2-codec|codec]] ([codec](sv2-codec.md))'s I/O loop.

## See Also

- [[sv2-binary-encoding|SV2 Binary Encoding]] ([SV2 Binary Encoding](sv2-binary-encoding.md)) — encoding of the payload's fields
- [[sv2-codec|SV2 Codec]] ([SV2 Codec](sv2-codec.md)) — drives encode + framing + Noise end-to-end
- [[sv2-noise-handshake|SV2 Noise Handshake]] ([SV2 Noise Handshake](sv2-noise-handshake.md)) — uses the Noise handshake framing
- [[sv2-buffer-pool|SV2 Buffer Pool]] ([SV2 Buffer Pool](sv2-buffer-pool.md)) — backs the `with_buffer_pool` feature
- [[sv2-extensions|SV2 Extensions]] ([SV2 Extensions](sv2-extensions.md)) — the `extension_type` field framing routes on
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `framing_sv2`

## Sources

- [framing_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-framing-sv2-readme.md) — header layout, `channel_msg` semantics, components
- [framing_sv2 BENCHES](../../raw/articles/2026-05-28-stratum-sri-sv2-framing-sv2-benches.md) — Criterion harness scope and methodology caveats
