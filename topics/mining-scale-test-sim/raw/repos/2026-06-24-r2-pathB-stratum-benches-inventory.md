---
title: "stratum-mining/stratum SV2 crate benches: full inventory; no channels-sv2 bench"
source_url: https://github.com/marafoundation/stratum/tree/main/sv2
type: repo
ingested: 2026-06-24
quality: 4
confidence: high
tags: [stratum, marafoundation, SRI, criterion, bench, channels-sv2, codec-sv2, noise-sv2, framing-sv2, buffer-sv2, validate_share, gap-analysis]
---

# stratum (SRI) SV2 sub-crate bench inventory (round-2, path B)

## Headline

`channels-sv2` — the crate that owns the per-share `ExtendedChannel::validate_share`
function — **has no `benches/` directory at all**. All Criterion benches in
`marafoundation/stratum` live in the I/O / serialization layer (buffer, codec,
framing, noise). The closest published numbers to the per-share path are
encoder/decoder/framing throughput benches that **bypass validation logic**.

## Bench tree

`gh api 'repos/marafoundation/stratum/git/trees/main?recursive=1'` filtered on
`bench`:

```
sv2/buffer-sv2/benches
sv2/buffer-sv2/benches/control_struct.rs
sv2/buffer-sv2/benches/pool_benchmark.rs
sv2/buffer-sv2/benches/pool_iai.rs
sv2/buffer-sv2/benches/random          # asset dir for synthetic msgs

sv2/codec-sv2/benches
sv2/codec-sv2/benches/buffer_exhaustion.rs
sv2/codec-sv2/benches/common.rs
sv2/codec-sv2/benches/decoder.rs
sv2/codec-sv2/benches/encoder.rs
sv2/codec-sv2/benches/noise_roundtrip.rs
sv2/codec-sv2/benches/pool_lifecycle.rs
sv2/codec-sv2/benches/serialization.rs

sv2/framing-sv2/benches
sv2/framing-sv2/benches/framing.rs

sv2/noise-sv2/benches
sv2/noise-sv2/benches/common.rs
sv2/noise-sv2/benches/handshake.rs
sv2/noise-sv2/benches/roundtrip.rs
```

`channels-sv2` directory inventory (no `benches/`):

```
sv2/channels-sv2
├── Cargo.toml
├── README.md
└── src/
    ├── bip141.rs        chain_tip.rs       lib.rs            merkle_root.rs
    ├── outputs.rs       target.rs
    ├── client/{error.rs, extended.rs, group.rs, mod.rs, share_accounting.rs, standard.rs}
    ├── extranonce_manager/{allocator.rs, bitvector.rs, mod.rs, prefix.rs}
    ├── server/{error.rs, extended.rs, group.rs, mod.rs, share_accounting.rs, standard.rs,
    │           jobs/{error.rs, extended.rs, factory.rs, job_store.rs, mod.rs, standard.rs}}
    └── vardiff/{classic.rs, error.rs, mod.rs, test/{classic.rs, mod.rs}}
```

`channels-sv2/Cargo.toml` confirms no `criterion` dev-dependency. Only `bitcoin`,
`binary_sv2`, `mining_sv2`, `template_distribution_sv2`, `tracing`,
`primitive-types`, and optional `hashbrown` (for `no_std`).

## Per-bench characterization

### buffer-sv2

- **`control_struct.rs`** — defines a `PPool` "control" implementation and a
  `MaxEfficiency` baseline. Helper module imported by the others.
- **`pool_benchmark.rs`** — Criterion bench: `with_pool` (the real
  `BufferPool`), `without_pool` (`BufferFromMemory`), `with_contro_struct`,
  `with_contro_struct_max_e`, plus threaded variants `with_pool_trreaded_1..N`
  that hold slices for `Duration::from_micros(10)` between allocations. Tests
  capacity = `2^16 * 5` bytes; payloads `2^14 - rand(0..12000)` bytes (typical
  SV2 frame sizes). Measures throughput of the front/back BufferPool strategy
  vs. naive allocation.
- **`pool_iai.rs`** — IAI (cachegrind) variant of the same comparisons —
  instruction-count rather than wall-clock.

### codec-sv2

- **`encoder.rs`** — `encoder/plain` (plain frame encode), `encoder/creation/plain`
  (cost of `Encoder::new`). `noise_sv2` feature adds noise-encoder variants
  using hardcoded SRI test keys (`9auqWEzQDVyd2oe1JVGFLMLHZtCo2FFqZwtKA5gd9xbuEu7PH72`).
- **`decoder.rs`** — `decoder/plain`: chunked feed of a serialized
  `Sv2Frame<TestMsg>` into `StandardDecoder` until a frame pops out.
- **`serialization.rs`** — `serialization/frame_from_message` (struct → Sv2Frame),
  `serialization/frame_serialization_roundtrip` (Sv2Frame → bytes).
- **`framing.rs`** (codec, but really wraps framing-sv2) — payload sizes
  `[64, 1024, 16KiB, 60KiB, 0xFFFFFF]`.
- **`noise_roundtrip.rs`** — encrypt+decrypt round-trip after AEAD setup.
- **`pool_lifecycle.rs`** — registers a custom `GlobalAlloc`
  (`TrackingAllocator`) to count heap allocations across a frame-decode
  lifecycle; `COINBASE_SIZES = [16, 64, 256, 1024]`, `POOL_CAPACITY = 8`.
  Closest in spirit to a "validation throughput" bench because it processes
  decoded frames, but stops short of touching `channels-sv2`.
- **`buffer_exhaustion.rs`** — encoder behavior when the pool back is filled
  (forces fallback to system allocator); uses `iter_custom` to time encode
  steps explicitly.

### framing-sv2

- **`framing.rs`** — duplicated payload-size sweep `[64, 1024, 16KiB, 60KiB,
  0xFFFFFF]`; benches `Sv2Frame::from_message` and serialize across both `Vec`
  and `buffer_pool::Slice` backends (chosen by the `with_buffer_pool` feature).

### noise-sv2

- **`common.rs`** — shared key/RNG helpers.
- **`handshake.rs`** — `step_0_initiator`, `step_1_responder`,
  `step_2_initiator`, and full `handshake`. Uses
  `BatchSize::SmallInput`. Measures NX-pattern Noise handshake CPU. Maps
  directly to the "handshakes/sec at ramp-up" question.
- **`roundtrip.rs`** — encrypt+decrypt one message.

## What the SRI benches do NOT cover

None of these benches exercise:

- `ExtendedChannel::validate_share` (the actual per-share path).
- `merkle_root_from_path` with realistic merkle-branch length.
- `ShareAccounting::seen_shares` HashMap behavior under sustained load.
- `JobStore` active/past/stale lookups.
- `Vardiff::try_vardiff` (the rate-control loop that runs every share
  acceptance).

The codec/framing benches measure how fast SV2 frames can be moved across the
wire — the necessary but not sufficient condition for high share throughput.
The noise handshake bench measures ramp-up CPU. Neither addresses the steady-state
per-share validation cost that the scale-test sim needs to model.

## Workspace-level CI artifacts

`marafoundation/stratum/.github/workflows/` — the bench paths above are run in
CI but Criterion's HTML/CSV output is not committed to the repo; published
numbers would require either the CI artifact zip from a specific run or a
local `cargo bench` invocation.

## Cross-references

- The `mining_device_*_bench.rs` triad in `sv2-apps/integration-tests/benches/`
  (see sibling raw note `2026-06-24-r2-pathB-sv2apps-integration-benches.md`)
  covers the miner-side hasher (FastSha256d) and is the only place either repo
  carries a Criterion bench remotely adjacent to the share lifecycle.
- The per-share validation function lives at
  `marafoundation/stratum/sv2/channels-sv2/src/server/extended.rs` line 676,
  `ExtendedChannel::validate_share`, and is invoked by Pool roles in
  `marafoundation/sv2-apps/pool-apps/pool` and JD-client/JDS variants.

## Provenance

- Tree fetch: `gh api 'repos/marafoundation/stratum/git/trees/main?recursive=1' --jq '.tree[] | select(.path | test("bench")) | .path'`
- `channels-sv2/Cargo.toml` and source files fetched 2026-06-24.
- Bench source files inspected via `gh api .../contents/...` and base64-decoded.
