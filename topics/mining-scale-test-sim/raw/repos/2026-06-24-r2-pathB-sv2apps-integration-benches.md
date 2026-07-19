---
title: "sv2-apps integration-tests benches: hasher-only, no per-share Criterion bench"
source_url: https://github.com/marafoundation/sv2-apps/tree/main/integration-tests/benches
type: repo
ingested: 2026-06-24
quality: 5
confidence: high
tags: [sv2-apps, marafoundation, integration-tests, criterion, bench, mining-device, hasher, per-share, gap-analysis]
---

# sv2-apps integration-tests/benches inventory (round-2, path B)

## Headline

**Per-share Criterion bench DOES NOT EXIST in marafoundation/sv2-apps.** The
`integration-tests/benches/` directory contains exactly three Criterion benches,
all of which target the **mining-device SHA-256d compute path** (FastSha256d
midstate hasher), not the **pool-side `ExtendedChannel::validate_share` path**.
The closest indirect coverage of the per-share path is the integration test
`tests/mining_device_fast_hasher_equivalence.rs` (correctness, not throughput)
and `tests/jdc_cached_shares.rs` (functional, not throughput).

## Directory tree

`gh api 'repos/marafoundation/sv2-apps/git/trees/main?recursive=1'` filtered on
`bench`:

```
integration-tests/benches
integration-tests/benches/mining_device_hasher_bench.rs
integration-tests/benches/mining_device_microbatch_bench.rs
integration-tests/benches/mining_device_scaling_bench.rs
```

That is the complete bench inventory for the repo. No other crate
(`pool-apps/pool`, `miner-apps/jd-client`, `miner-apps/translator`,
`stratum-apps`) ships a `benches/` directory.

`integration-tests/tests/` (full list):

```
bitcoin_core_ipc_integration.rs   extensions.rs
jd_integration.rs                  jd_provide_missing_transaction.rs
jd_tproxy_integration.rs           jdc_block_propagation.rs
jdc_cached_shares.rs               jdc_fallback_to_solo.rs
jdc_receives_submit_shares_success.rs
jds_block_propagation.rs           mining_device_fast_hasher_equivalence.rs
monitoring_integration.rs          pool_integration.rs
pool_solo_mining.rs                sniffer_integration.rs
sv1.rs                             sv2_mining_device.rs
template_provider_integration.rs   translator_integration.rs
```

## Cargo.toml — bench declarations

From `integration-tests/Cargo.toml`:

```toml
[dev-dependencies]
# Criterion 0.5 without default features; combined with a dev pin of
# `half = 2.3.1` to stay Rust 1.75-compatible.
criterion = { version = "0.5", default-features = false, features = ["stable"] }
half = "=2.3.1"
num_cpus = "1"

[[bench]]
name = "mining_device_hasher_bench"
harness = false

[[bench]]
name = "mining_device_microbatch_bench"
harness = false

[[bench]]
name = "mining_device_scaling_bench"
harness = false
```

Crucially, the `[dependencies]` section keeps `rand`, `sha2 = { features =
["compress", "asm"] }`, `primitive-types`, `num-format` with a comment that
reads:

```
# Direct dependencies kept only for the embedded `mining_device` module.
# Remove this block when removing:
# - `integration-tests/lib/mining_device/`
# - `integration-tests/tests/mining_device_fast_hasher_equivalence.rs`
# - `integration-tests/benches/mining_device_*`
```

This makes the maintainer intent explicit: the three benches are scoped to the
embedded `mining_device` module and are expected to be removed when that module
is deprecated. They are **not** part of a pool-side perf baseline.

## Bench-by-bench characterization

### 1. `mining_device_hasher_bench.rs`

- **Group**: `mining_device_hasher`
- **Functions**:
  - `baseline_block_hash / full` — rust-bitcoin's stock `Header::block_hash()`
    per-nonce.
  - `fast_midstate / compress256` — `FastSha256d::from_header_static(&h)` +
    `hash_with_nonce_time(nonce, time)` (midstate cached, only the final
    compression block recomputed per nonce).
- **Parameters**: single random header; nonce increments per iter.
- **What it measures**: cycles per SHA-256d evaluation for the FastSha256d
  optimization vs. the rust-bitcoin baseline.
- **Published numbers**: none in the bench file or README. Criterion writes
  numbers to `target/criterion/...`, not committed.
- **Relevance to per-share path**: none. SHA-256d cycles are upstream of
  miner-side block-finding, not pool-side share validation.

### 2. `mining_device_microbatch_bench.rs`

- **Group**: `mining_device_microbatch`
- **Bench**: iterates over `MINING_DEVICE_BATCH_SIZES` (default `[1, 8, 32,
  128]`), calling `FastSha256d::hash_with_nonce_time` `b` times per Criterion
  iteration; `Throughput::Elements(b)` reports hashes/sec.
- **Side effect**: a `println!` runs ~200k hashes outside Criterion and prints
  `batch=B: ~X.YZZ MH/s` for human consumption.
- **What it measures**: per-thread microbatch throughput of FastSha256d (single
  core, single header).
- **Hardware-aware**: prints whether x86 `sha` (SHA-NI) or aarch64 `sha2` is
  available at startup.
- **Relevance to per-share path**: none. This is the hasher inner loop the
  mining_device binary uses to find shares; the pool-side `validate_share`
  cost is entirely separate.

### 3. `mining_device_scaling_bench.rs`

- **Group**: `mining_device_scaling`
- **Bench**: for `workers in 1..=num_cpus::get()`, spawn `n` `std::thread`s
  each running `FastSha256d::hash_with_nonce_time` in a tight loop with stride
  `n` to avoid nonce overlap; `Barrier` to start together; max-elapsed
  per-thread reported.
- **Side effect**: prints `workers=N: ~X.YZZ MH/s (total) | +Δ vs prev
  (+P.Q%), ~Y.YY MH/s per added worker`.
- **What it measures**: cores → MH/s scaling curve for FastSha256d on the host
  machine.
- **Relevance to per-share path**: none. This is purely the miner-side hashing
  scaling curve.

## What's missing (gap analysis)

The pool-side **per-share path** in SV2 lives in
`marafoundation/stratum/sv2/channels-sv2/src/server/extended.rs`,
specifically `ExtendedChannel::validate_share(&mut self, share:
SubmitSharesExtended) -> Result<ShareValidationResult, ShareValidationError>`
(line 676 of that file as of 2026-06-24 main). It does:

1. Job lookup (active / past / stale) via `JobStore`.
2. Extranonce-size check.
3. `merkle_root_from_path` (allocates `full_extranonce: Vec<u8>`, then SHA-256d
   over `coinbase_tx_prefix || extranonce || coinbase_tx_suffix` and folds the
   merkle path).
4. Version-rolling mask check (`share.version & 0x1fffe000`).
5. Header hash and target comparison vs. job_target and chain_tip nbits.
6. Duplicate-share check against `ShareAccounting::seen_shares` (flushed on
   prev-hash change).

None of these steps are individually benched anywhere in
`marafoundation/sv2-apps`. The integration tests
`jdc_cached_shares.rs`, `jdc_receives_submit_shares_success.rs`, and
`pool_integration.rs` exercise this code functionally end-to-end (with a real
sv2-tp and Bitcoin Core in regtest) but make no throughput assertions.

## Implication for the scale-test sim

A scale-test simulator that wants to claim "the pool validate_share path can
sustain X shares/sec at the modelled offered load" cannot lift a number from
the existing benches — the existing benches only measure the miner's hasher.
The simulator either:

- (a) needs to add its own Criterion bench of `ExtendedChannel::validate_share`
  with a synthetic `SubmitSharesExtended` (similar shape to the share carried
  in `tests/jdc_cached_shares.rs`), measuring p50/p99 per-share latency and
  hashes/sec equivalent; or
- (b) needs to derive the cost from the constituent operations
  (`merkle_root_from_path`, `sha256d` over the header, target compare, hashmap
  insert) using the codec/framing benches as proxies — but those measure framing,
  not validation logic.

Option (a) is the right move and is straightforward (the existing
`mining_device_hasher_bench` is a working template; one would copy its
`criterion_group!` skeleton and substitute a populated `ExtendedChannel`
fixture).

## Provenance

- Repo tree: `gh api 'repos/marafoundation/sv2-apps/git/trees/main?recursive=1'`
- Cargo: `gh api 'repos/marafoundation/sv2-apps/contents/integration-tests/Cargo.toml'`
- Bench sources fetched and inspected in full on 2026-06-24.
