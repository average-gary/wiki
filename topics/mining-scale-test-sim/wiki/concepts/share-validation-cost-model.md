---
title: "Share validation cost model"
type: concept
created: 2026-06-24
confidence: high
tags: [validation, share, cost, ckpool, sri]
---

# Share validation cost model

For every `SubmitSharesStandard` (SV2) or `mining.submit` (SV1), the
pool performs an identical-shape workload:

SRI `validate_share` lives at
`marafoundation/stratum :: sv2/channels-sv2/src/server/extended.rs:676`.

| Stage | Operation | Cost (commodity CPU + SHA-NI) | SRI code location |
|-------|-----------|-------------------------------|-------------------|
| Job lookup | HashMap by job_id (active / past / stale) | ~50 ns | `JobStore` active/past/stale lookup in `extended.rs::validate_share` |
| Coinbase rebuild | memcpy prefix + extranonce + suffix | <1 µs | `extended.rs::validate_share` builds full coinbase from prefix + extranonce |
| Coinbase txid | 1× SHA256d on 250-800 B coinbase | ~1 µs | `bitcoin::Transaction::txid()` via rust-bitcoin |
| Merkle path | ~12× SHA256d on 64 B blobs | ~3 µs | `merkle_root_from_path` in `channels-sv2` utility |
| Header build | memcpy + splice merkle/nonce/ntime/version | <1 µs | `Block::header` constructor; BIP-320 version mask applied here |
| Header hash | 1× SHA256d on 80 B header | ~0.5 µs | `header.block_hash()` |
| Target check | 256-bit integer compare | <100 ns | `if hash > target { return Err(...) }` |
| Dup-detect | HashSet lookup on 32-B hash | ~100 ns | `ShareAccounting::is_share_seen` |
| Accounting write | counter increment, batch tracking | ~200 ns | `ShareAccounting::update_share_accounting` |

**Total: 5-10 µs (ckpool C + SHA-NI), 10-20 µs (SRI Rust)** — these
are **derived**, not measured. Round 2 path B confirmed that neither
`marafoundation/sv2-apps` nor `marafoundation/stratum` ships a
Criterion bench for any of these stages; `channels-sv2` has no
`[dev-dependencies]` section at all. Adding `criterion =
"0.5"` + `benches/validate_share.rs` is a single PR that turns each
row above into a measured cycles/share number, the first concrete
input to [[the bottleneck thesis|the bottleneck thesis]]'s headline
number (1M conn ≈ 2 cores). SHA work alone is 1-2 µs at the
SHA-NI ~1.7 GB/s/core ceiling; deserialize, hashtable, and lock
overhead dominate the rest of the budget.

## Per-core throughput ceiling

| Implementation | Shares/sec/core | Bottleneck before CPU |
|----------------|-----------------|----------------------|
| ckpool (SV1, C, SHA-NI) | ~100-200k | global `share_lock` mutex |
| SRI / sv2-apps (SV2, Rust, rust-bitcoin) | ~50-100k | per-channel `safe_lock` (sharded — much higher ceiling) |

No published microbenchmarks from either project — these are derived
from SHA-NI throughput (~1.7 GB/s/core) + measured deserialize cost.
**Open gap**: run `cargo bench` on
`ExtendedChannel::validate_share` to measure directly.

## Connection-vs-validation crossover

At sv2-apps default `shares_per_minute = 6.0` (1 share / 10s / channel):

| N connections | Aggregate sps | Cores busy (SRI 15 µs) |
|---|---|---|
| 10k | 1,000 | 1.5% |
| 100k | 10,000 | 15% |
| **1M** | **100,000** | **~2 cores** |
| 10M | 1,000,000 | ~15 cores |

At ckpool's tighter `drr=0.3` (~18 SPM), multiply sps by 3. Even then
**1M connections = ~6 cores of validation work** — easily handled by a
modern pool host. [[connection scale bottlenecks|Connection-layer
bottlenecks hit much sooner]] (kernel memory at 10-20 GB, ephemeral
ports, handshake CPU during reconnect storms).

[[the bottleneck thesis|This confirms the user's premise]].

## JD-path special case

Job Declaration (SV2) does NOT flip the bottleneck back to validation,
because **template validation is per-`DeclareMiningJob`, not per-share**.

`pool-apps/jd-server/src/lib/job_declarator/job_validation/bitcoin_core_ipc.rs`
shows template validation is gated by a `DeclaredCustomJob.validated:
bool` flag and runs **once per template declaration**, with full
Bitcoin Core IPC roundtrip. `SetCustomMiningJob` is field-equality only
(prev_hash / nbits / version / coinbase prefix bytes). The per-share
path (`mining_message_handler.rs:793`) calls
`extended_channel.validate_share(...)` — same as Pool mode.

Per-template IPC cost: **~50 ms for `testblockvalidity` on a 4 MB / 4000-tx
mainnet block**. At ~10 chain-tip events/hour × 100k JD-clients × 50 ms
≈ ~140 IPC ops/sec — **a new bottleneck class** (Bitcoin Core IPC
channel) but not per-share, and easily absorbed by a small async pool.

## Duplicate-detection memory

- **ckpool** (`stratifier.c:844`): `age_share_hashtable()` clears the
  per-workbase share table when the workbase is retired (every ~5-30 s
  on chain-tip / template-update).
  Bound: `N × shares_per_workbase × 32 B` ≈ `N × 5 × 32 B`.
  At N=1M: **~160 MB**.
- **SRI** (`share_accounting.rs:158`): `flush_seen_shares()` doc:
  "Should be called on every chain tip update to avoid unbounded
  growth." `HashSet<Hash>` ≈ 80 B/entry.
  Bound: `N × SPM × 10 min` ≈ `N × 60`.
  At N=1M, SPM=6: **~5 GB upper bound** — non-pathological but
  worth watching. Sv2-apps could flush more aggressively if needed.

## Two caveats

### Caveat 1 — lock contention

ckpool's single global `share_lock` mutex (`stratifier.c:469`) is used
in every `new_share` insert. It can contend before pure CPU saturates;
no published curve of contention vs N-cores. SRI's per-channel
`safe_lock` is naturally sharded and avoids this.

For the simulator: instrument lock-wait time as a first-class metric
(separate from CPU). Lock contention will surface differently from
pure CPU saturation.

### Caveat 2 — vardiff ramp-up (validation IS the bottleneck for ~130 ms)

Round-2 measurement: the round-1 phrasing "briefly look like a
validation bottleneck" understated the storm magnitude by **3+ orders
of magnitude**. New ckpool connections start at `startdiff = 42`
regardless of declared hashrate. For an Antminer S19 at 100 TH/s the
first-share rate is:

```
shares/sec = H / (D × 2^32) = 1e14 / (42 × 4.295e9) ≈ 554 sps per connection
```

72 shares clears the first retarget window in **~130 ms** (not 30-60 s).

For a burst-connect of N=100,000 S19-class miners:

| Phase | Per-conn sps | Aggregate sps | Duration | Validation budget (7 µs/share) |
|-------|-------------|---------------|----------|-------------------------------|
| First-share storm | 554 | **55.4 M sps** | ~130 ms | **~385 cores fully busy** |
| Mid-retarget (~10 retargets in) | ~30 | 3 M | ~minutes | ~21 cores |
| Steady-state (SPM=6) | 0.1 | 10k | indefinite | ~0.15 cores |

**Ratio: ~1800× steady-state** for ~65-130 ms. During this window
validation is genuinely the binding constraint, not connections.

**ckpool reaches `share_lock` contention long before 385 cores of
CPU**: the single global lock serializes the entire share path. The
practical limit during the storm is share-rejection rate (drops),
not throughput.

#### SRI inheritance question (open)

SRI's `hash_rate_to_target(nominal_hashrate, SPM)` sizes the initial
target from the client's declared hashrate. If the client is honest,
no storm. But the **SV1→SV2 translator** wraps clients that have no
mechanism to declare hashrate at the wire level — what default
`nominal_hashrate` does the translator pass to
`OpenStandardMiningChannel`? An unrealistically low default makes
sv2-apps inherit the ckpool storm shape. **Open: grep
`stratum-apps/translator/src` for the default.**

Simulator must model the ramp-up storm as a **distinct workload
pattern** (`ramp_25 / ramp_50 / ramp_100`) with **first-retarget
latency** as a separate metric from `convergence_time`. The
[[simulator architecture]]'s grid axis already lists these; this
caveat is why.

Two real-world post-mortems documenting analogous storms:
- `public-pool#120` — vardiff ramping below 1 produced 1.6M sps from
  one connection when a slow-tuning ASIC finally hashed.
- `SpiralPool#10` — mid-block `set_difficulty` caused 12-16%
  miner-side firmware rejection inflation on S19/S21.

## See also

- [[the bottleneck thesis]] — premise this cost model supports
- [[vardiff decoupling]] — why `r* × N` is the right share-rate formula
- [[connection scale bottlenecks]] — the bottlenecks that hit first
- [[synthetic miner patterns]] — how to feed shares at controlled rate
