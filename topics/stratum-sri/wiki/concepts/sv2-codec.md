---
title: "SV2 Codec"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-benches.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, codec-sv2, encoder, decoder, noise, sv2-frame, no-std]
aliases: ["codec_sv2", "Encoder", "Decoder", "Sv2 codec"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "How `codec_sv2` glues SV2 framing to I/O: an Encoder/Decoder pair that operates on `Sv2Frame`s, an optional Noise transport mode that bolts encryption on the same call sites, and benchmarks for the buffer-pool-vs-alloc edges that matter at high connection counts."
---

# SV2 Codec

> `codec_sv2` is the I/O-side of the SV2 stack. It takes encoded payloads from [[sv2-binary-encoding|binary encoding]] ([binary encoding](sv2-binary-encoding.md)) wrapped in [[sv2-framing|framing]] ([framing](sv2-framing.md)) and turns them into a byte stream the application reads/writes — optionally encrypted via [[sv2-noise-handshake|Noise]] ([Noise](sv2-noise-handshake.md)).

## Components

`codec_sv2` exposes three core building blocks:

- **Encoder** — encodes SV2 messages with or without Noise transport encryption.
- **Decoder** — decodes SV2 messages with or without Noise transport decryption.
- **Handshake state** — tracks the current Noise handshake step so the same encoder/decoder can transition cleanly from handshake to transport mode.

## Feature flags

The crate is configurable via Cargo features:

- `std` — enable Rust `std` (default; turn off with `--no-default-features` for `no_std`).
- `noise_sv2` — pull in [[sv2-noise-handshake|`noise_sv2`]] ([noise_sv2](sv2-noise-handshake.md)) for encrypted transport.
- `with_buffer_pool` — route encode/decode allocations through the [[sv2-buffer-pool|SV2 buffer pool]] ([SV2 buffer pool](sv2-buffer-pool.md)) instead of `BufferFromSystemMemory`.

## Decode loop

The decoder is fill-then-parse, two-stage by design. From `buffer_sv2` and the codec API:

1. Codec asks the buffer for a writable region sized for the 6-byte header.
2. Application fills it from the socket.
3. Codec parses the header, uses `msg_length` to ask the buffer for a writable region the size of the payload.
4. Application fills that.
5. Codec hands ownership of the buffer to a `framing_sv2::framing::Frame` and returns the typed message.

The `next_frame()` loop is the path measured by the `decoder/plain` benchmark.

## Examples

The crate has two end-to-end examples:

- **Unencrypted Example** — encode/decode a regular `Sv2Frame`, no Noise.
- **Encrypted Example** — encode/decode a `Sv2Frame` after a full Noise handshake, including the handshake itself.

## Benchmarks (BENCHES.md)

`codec_sv2` ships a Criterion suite with six benches covering the spots where memory-allocation choices and Noise overhead matter:

| Bench | Purpose |
|-------|---------|
| `encoder.rs` | `encoder/plain`, `encoder/creation/plain`. With `noise_sv2`: `encoder/noise/transport`, `encoder/creation/noise`, `encoder/noise/handshake/complete`. |
| `decoder.rs` | `decoder/plain`, `decoder/creation/plain`. |
| `noise_roundtrip.rs` | `noise/roundtrip`, `noise/encode_only`, `noise/handshake/step_0`, `noise/handshake/step_1`. |
| `serialization.rs` | `serialization/frame_from_message` — `Sv2Frame::from_message()` overhead (still wraps as `Option<T>`, no serialization yet). |
| `buffer_exhaustion.rs` | Latency at each `BufferPool` state machine stage (`Back → Front → Alloc`); shows where the cost cliff is. |
| `pool_lifecycle.rs` | The "hold a decoded frame vs. copy and release" question, with `zc_hold` vs `owned_release` variants, exhaustion-boundary sweeps, sliding-window simulation, and an `alloc_amplification` group that uses a custom `TrackingAllocator` global allocator to count heap allocations per run. |

The pool-lifecycle suite is the most important one for capacity planning. It parameterizes `frames_held ∈ {0, 1, 2, 4, 6, 7, 8, 9, 12, 16, 32, 64}` against the [[sv2-buffer-pool|buffer pool]]'s 8-slot ceiling — the discontinuity at `n = 9` is the boundary where the pool falls back to system-memory allocation.

> Running: `cargo bench --all-features` for the full picture, or `cargo bench --bench buffer_exhaustion` for just the pool-state-machine view. Results stored under `target/criterion/` are diffed against the previous baseline.

## Where it sits

```
   socket ──► fill ──► codec_sv2 ──► framing_sv2 ──► parsers_sv2 ──► typed message
                          │
                          └──► (optional) noise_sv2 transport AEAD
```

Encoder is the mirror image, ending in a write-out side.

## See Also

- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — the layer producing the bytes the codec reads/writes
- [[sv2-noise-handshake|SV2 Noise Handshake]] ([SV2 Noise Handshake](sv2-noise-handshake.md)) — what the `noise_sv2` feature pulls in
- [[sv2-buffer-pool|SV2 Buffer Pool]] ([SV2 Buffer Pool](sv2-buffer-pool.md)) — backing allocator under `with_buffer_pool`
- [[sv2-binary-encoding|SV2 Binary Encoding]] ([SV2 Binary Encoding](sv2-binary-encoding.md)) — produces the field bytes the codec frames
- [[sv2-message-handlers|SV2 Message Handlers]] ([SV2 Message Handlers](sv2-message-handlers.md)) — consumes the typed messages the codec ultimately yields
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `codec_sv2`

## Sources

- [codec_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-readme.md) — components, feature flags, examples
- [codec_sv2 BENCHES](../../raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-benches.md) — bench-suite layout and the pool-exhaustion boundary at 8 slots
