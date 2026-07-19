---
title: SRI stratum/channels-sv2 — server validate_share (SV2 share validation)
source_type: repos
source_url: https://github.com/stratum-mining/stratum/blob/main/sv2/channels-sv2/src/server/extended.rs
fetched: 2026-06-24
path: 4
tags: [stratum-v2, sri, share-validation, share-accounting, dup-detection, vardiff]
---

# SRI SV2 `validate_share` — Rust share validation path

Server-side validation lives in
`sv2/channels-sv2/src/server/extended.rs::ExtendedChannel::validate_share`
(also `server/standard.rs` for `SubmitSharesStandard`). Identical
shape to ckpool but in Rust with `rust-bitcoin` primitives.

## Cost ledger per share (extended.rs:662–870)

1. **Three job-store lookups** (`HashMap<u32, ExtendedJob>`):
   active / past / stale → constant time, ~50 ns.
2. **Extranonce size check** (single integer compare).
3. **Merkle root reconstruction** (`merkle_root::merkle_root_from_path`,
   merkle_root.rs:24–46):
   - Concat coinbase_prefix + extranonce + coinbase_suffix.
   - `consensus::deserialize::<Transaction>(...)` — full bitcoin tx
     parse on the assembled coinbase (~1 µs).
   - `coinbase.compute_txid()` — SHA256d over serialized coinbase.
   - `reduce_path()` — one SHA256d per merkle path node (~12 nodes for
     a full mainnet block).
4. **Header construction** — stack-allocated `Header { version,
   prev_blockhash, merkle_root, time, bits, nonce }`.
5. **`header.block_hash()`** — SHA256d on 80-byte header.
6. **`Target::from_le_bytes(raw_share_hash)` + `is_met_by` /
   `<= *job_target`** — two 256-bit integer compares.
7. **`share_accounting.is_share_seen(share_hash)`** — `HashSet<Hash>`
   lookup (~100 ns).
8. **`update_share_accounting()`** — insert into HashSet, increment
   counters.

Same workload as ckpool: ~14 SHA256 operations + HashMap/HashSet ops.
On `rust-bitcoin` (which uses libsecp256k1's SHA256 with SHA-NI when
available), single-core cost is **~10–20 µs per share**. Slightly
higher than ckpool's pure-C path due to deserialize / safer types.

## Duplicate detection memory model (share_accounting.rs:80–160)

```rust
pub struct ShareAccounting {
    ...
    seen_shares: HashSet<Hash>,
    ...
}

pub fn flush_seen_shares(&mut self) {
    self.seen_shares.clear();
}
```

Doc comment on `flush_seen_shares`: *"Should be called on every chain
tip update to avoid unbounded growth of memory and allow new shares
for the new tip."*

Bound per channel: ~`spm × seconds_since_tip` shares. At
`shares_per_minute = 6.0` (default) × 600 s mean inter-block ≈ 60
hashes (= ~2 KB per channel). At 100k channels = 200 MB max. Bounded,
non-pathological.

## Vardiff (vardiff/classic.rs)

`VardiffState::try_vardiff` adapts each channel's target. Adjustment
thresholds (note: time-sensitive — won't churn under brief noise):

| Δ% from target hashrate | min elapsed | acts? |
|---|---|---|
| ≥ 100% | 0 s | yes (immediate) |
| ≥ 60% | 60 s | yes |
| ≥ 50% | 120 s | yes |
| ≥ 45% | 180 s | yes |
| ≥ 30% | 240 s | yes |
| ≥ 15% | 300 s | yes |
| < 15% | any | no |

`DEFAULT_MIN_HASHRATE = 1.0` H/s. The floor isn't on difficulty; it's
on hashrate. The realized target is computed from `nominal_hashrate`
and `expected_share_per_minute` via `hash_rate_to_target`:

> formula: `t = (2^256 - sh) / (sh + 1)` where `s = shares per
> second = SPM / 60` and `h = hashrate`.

So `expected_share_per_minute` IS the vardiff target. Default for the
SV2 reference Pool: **6.0 SPM = 1 share / 10 s**.

## SV2-specific: batching of `SubmitShares.Success`

Pool replies with one `SubmitShares.Success` per `share_batch_size`
shares (default 10). The success message aggregates
`new_submits_accepted_count` and `new_shares_sum`. So the **wire
overhead per share is roughly 1/10 of SV1**: SV1 sends a JSON-RPC reply
per share; SV2 sends one tiny binary message per 10 shares. Validation
cost is unchanged but I/O cost drops 10×.

## Files referenced

- `/tmp/sv2_extended.rs`, `/tmp/sv2_share_accounting.rs`
- `/tmp/sv2_vardiff.rs`, `/tmp/sv2_merkle.rs`
