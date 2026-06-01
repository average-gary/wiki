---
title: "SV2 Buffer Pool"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-buffer-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-buffer-sv2-benches.md
  - raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-benches.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, buffer-sv2, memory, no-std, buffer-pool, performance]
aliases: ["buffer_sv2", "BufferPool", "BufferFromSystemMemory", "Slice"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "`buffer_sv2` is the memory layer the rest of the SV2 stack rents from: a `Buffer` trait, a `BufferPool` with an 8-slot back/front/alloc state machine that backs the `with_buffer_pool` feature on every other crate, and a fallback `BufferFromSystemMemory` for the no-pool case."
---

# SV2 Buffer Pool

> Pools, proxies, and translators handle thousands of simultaneous connections; allocator pressure dominates if every frame triggers a fresh `Vec<u8>`. `buffer_sv2` is SRI's answer: a tiny memory-management crate with a `Buffer` trait, a fast `BufferPool`, and a slow-but-simple `BufferFromSystemMemory` fallback. It is the backing of every `with_buffer_pool` feature flag in the rest of the stack.

## The `Buffer` trait

`Buffer` is designed for the [[sv2-codec|`codec_sv2`]] ([codec_sv2](sv2-codec.md)) decode loop:

1. Fill a buffer the size of the protocol header.
2. Parse the filled bytes to compute message length.
3. Fill a buffer the size of the message.
4. Construct a `framing_sv2::framing::Frame` from the header + message bytes.

Two methods carry the contract:

```rust
fn get_writable(&mut self, len: usize) -> &mut [u8];
fn get_data_owned(&mut self) -> Slice;
```

`get_writable` returns a mutable slice from the current cursor to `cursor + len` and advances the cursor. `get_data_owned` returns a `Slice` (`AsMut<[u8]> + Send`) that the codec can hand off to a `Frame`.

The trait is implemented twice:

- `BufferFromSystemMemory` — backed by a fresh `Vec<u8>` per buffer. Simple, no pool bookkeeping.
- `BufferPool` — preallocates `Vec<u8>` of user-defined capacity, hands out `Slice`s into it, and reuses memory as `Slice`s drop.

The crate also defines a `Write` trait so it can stand in for `std::io::Write` in `no_std`.

## `BufferPool` state machine

`BufferPool` tracks up to **8 slots** (an `AtomicU8` bitmap) and a byte capacity. Three modes:

| Mode | When | Behavior |
|------|------|----------|
| **Back Mode** | Default | Allocations grow from the back of the preallocated region. |
| **Front Mode** | Back is exhausted but earlier slots have been freed | Reuse the front section. |
| **Alloc Mode** | Both back and front are full | Fall back to `BufferFromSystemMemory` (heap allocation per buffer). |

Fragmentation is limited to two boundaries: front↔back and back↔end. `Slice` implements `Drop` so reused-region tracking is implicit; the pool is also optimized for the common cases of "drop all slices" and "drop the last slice".

The README's diagrams trace the most-optimized cases: filling slots `1..=8`, resetting on full release, and switching back↔front when freed slots open up:

```
--------  BACK MODE
1-------
12------
…
12345678  BACK MODE (full)
12345678  ALLOC MODE
…
```

## Unsafe surface

The crate has four `unsafe` blocks, all called out in the README:

- `buffer_pool/mod.rs::get_writable_(...)` — internal writable-slice constructor.
- `slice.rs::unsafe impl Send for Slice {}` — sending pool-backed slices across threads.
- Two `AsMut<[u8]>::as_mut` impls on `Slice`.

This is the surface code review should focus on; the rest of the crate is safe Rust.

## Benchmarks

`buffer_sv2`'s own `BENCHES.md` runs `BufferPool` against three references — `BufferFromSystemMemory` (no pool), `PPool` (a hashmap-based pool), and `MaxEfficiency` (a control implementation that's "completely broken" and only there to stop the compiler from optimizing the test harness away). Headline numbers (2,000 samples):

| Workload | BufferPool | BufferFromSystemMemory | PPool | MaxEfficiency |
|----------|------------|------------------------|-------|---------------|
| single-thread | 7.50 ms | 10.27 ms | 32.59 ms | 1.26 ms |
| multi-thread | 34.66 ms | 142.23 ms | 49.79 ms | 18.20 ms |
| multi-thread 2 | 80.87 ms | 192.24 ms | 101.75 ms | 66.97 ms |

So in the realistic case where decoded buffers are sent to another thread before drop, `BufferPool` is ~4× faster than no-pool, ~1.4× faster than `PPool`, and ~1.8× slower than the (broken) max-efficiency control.

## The 8-slot cliff

The 8-slot bitmap shows up directly in [[sv2-codec|`codec_sv2`]]'s `pool_lifecycle` and `buffer_exhaustion` benches: `frames_held = 8 → 9` is the boundary where `zc_hold` (zero-copy, pool slot pinned for the frame's lifetime) falls into Alloc Mode. The `owned_release` variant (copy payload into `OwnedMsg`, drop the frame) avoids that cliff entirely at the cost of one memcpy per message.

This is not a knob to tune — it is the load-shape question every SV2 server has to answer: hold decoded frames or copy and release. The codec benches make that tradeoff measurable.

## Feature flags

- `debug` — extra tracking for diagnosing memory-management bugs.
- `fuzz` — supports fuzz-target builds.

## See Also

- [[sv2-codec|SV2 Codec]] ([SV2 Codec](sv2-codec.md)) — primary consumer; pool-lifecycle benches live here
- [[sv2-binary-encoding|SV2 Binary Encoding]] ([SV2 Binary Encoding](sv2-binary-encoding.md)) — `with_buffer_pool` propagates here for encode allocations
- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — `with_buffer_pool` propagates here for frame allocations
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `buffer_sv2`

## Sources

- [buffer_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-buffer-sv2-readme.md) — `Buffer` trait, `BufferPool` modes, unsafe surface, single/multi-thread benchmark numbers
- [buffer_sv2 BENCHES](../../raw/articles/2026-05-28-stratum-sri-sv2-buffer-sv2-benches.md) — Criterion harness for the standalone benchmarks
- [codec_sv2 BENCHES](../../raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-benches.md) — codec-side `pool_lifecycle` exhaustion-boundary view (`frames_held = 8 → 9`)
