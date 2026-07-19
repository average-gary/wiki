---
title: Synthetic-miner methodology — pattern synthesis for scale-testing pools
source_url: synthesis from p2poolv2, sv2-apps, gimballock vardiff sim, ckpool
type: notes
ingested: 2026-06-24
quality: A
confidence: medium-high
tags: [synthesis, synthetic-miner, patterns, scale-test, poisson, fixture, design]
---

# Synthetic-miner methodology — pattern synthesis

A unified vocabulary for "how do you fake N miners against a pool
without burning electricity". Derived from inspection of p2poolv2's
sim feature, sv2-apps's mining_device, gimballock's vardiff
simulator, and the JMeter+mock-bitcoind harness.

## 1. The math, restated

For a miner of hashrate `H` (h/s) submitting shares at pool
difficulty `D` (diff-1 relative):

```
mean_inter_share_seconds = D * 2^32 / H
shares_per_second = H / (D * 2^32)
```

Hashes per diff-1 share: **2^32 = 4_294_967_296**.

Example calibrations:
- 100 TH/s, D=1:                ~4.3 µs/share          (233k shares/sec)
- 100 TH/s, D=10_000:           ~43 ms/share           (~23 shares/sec)
- 100 TH/s, D=1_000_000_000:    ~43 sec/share          (typical vardiff target)
- 1 TH/s,   D=1:                ~4.3 ms/share          (233 shares/sec)

Vardiff clamps to ~1 share / 20–60s per connection regardless of
hashrate — so at steady state, share-rate-per-connection is
roughly constant and the **pool-side share-validation cost scales
with connection count**, not aggregate hashrate.

## 2. The four patterns (with attribution)

### Pattern A — Mock-share / accounting-only

What: no submission to the pool — the harness internally tracks
"I would have submitted N shares" against a model state machine.
The pool never sees these.

Used by: gimballock's `run_trial` / `Composed` (the sim is the
*counterparty*, the pool is the algorithm under test, no transport).

Strengths: trivially deterministic, replayable, runs 12M trial-ticks
in 2–3 minutes.

Limits: doesn't test serialization, framing, Noise, share-validation
crypto paths.

### Pattern B — Poisson exponential-sleep over real connection

What: open a real TCP+Noise connection, complete SetupConnection,
OpenChannel. For each (job, target), compute
`mean = D * 2^32 / H_modeled`. `tokio::sleep` an exponential draw,
then send a SubmitSharesStandard frame. Loop.

Used by: p2poolv2's `SimEmitter` (in-process variant) + per-process
launch via `run-swarm.sh`. The wire format is real bytes; only
the act of *finding* a nonce is faked.

Strengths: closes the loop with the pool's vardiff/ASERT controller.
When difficulty rises, the emitter slows automatically.

Limits: each emitter is one tokio task — at 10k+ miners the wakeups
start to matter. **Per-connection cost is the dominant load source.**

### Pattern C — Fixture-target (difficulty-1 trick)

What: configure the upstream bitcoind / bitcoind-mock to return a
genesis-easy target (e.g. `bits=0x2100ffff`, `target=0xffff0..`).
Every nonce now satisfies the target, so the synthetic miner just
sends any precomputed (job, nonce) and the pool's share-validation
path executes fully on real bytes.

Used by: p2poolv2's JMeter test (hardcoded nonce `"f15f1590"`,
hardcoded ntime `"67b6f938"`).

Strengths: exercises the pool's real validate-share path including
SHA256d-of-header, serialization, signature, and the submitblock
path against the mock bitcoind.

Limits: requires control of the upstream bitcoind (regtest or mock).
Doesn't model vardiff convergence (target is fixed at "trivial").

### Pattern D — Hybrid: fixture handshake, mock-validated work

What: do the full Noise + SetupConnection + OpenChannel against the
real pool (correctness), then for the share loop use Pattern B
(Poisson timing) where the actual SubmitShares frame is sent but
the pool is configured in a mode where validate-share returns Ok
without doing the SHA256d check (development-only mode).

Used by: not published in the surveyed harnesses, but several
prompts/comments suggest it as the right pattern for million-miner
scale tests where even fixture validation is too expensive at peak.

Strengths: lowest per-share cost on the pool side. Maximum
connection count per host.

Limits: now you're not testing the validation path. Should be a
*tier* in a multi-tier scale-test plan, not the only mode.

### Pattern E — Real-CPU mining (for reference only)

What: actually run cpuminer / sv2-apps's `mining_device`. Spin
worker threads grinding SHA256d.

Used by: sv2-apps integration tests (one or a few miners as
counterparties).

Strengths: catches edge cases in target / hash format mismatches that
Patterns A–D would silently glide past.

Limits: ~100 KH/s/core CPU vs 100 TH/s/ASIC = 10^9× slowdown.
Inappropriate for any test with more than ~10 miners on a single host.

## 3. The throughput trick: per-tick bulk Poisson (gimballock)

gimballock's sim takes Pattern A one step further: don't sample
per-share inter-arrivals at all. Sample the **count** for the entire
tick interval as a single Poisson(λ) draw, where:

```
λ = (true_h / est_h) * shares_per_minute * (tick_secs / 60)
```

For a 60-second tick: one RNG call replaces what would otherwise be
12 (at 12 spm) or 12_000 (at 12000 spm) per-share draws. **The
algorithm's behavior is identical** because the algorithm only acts
at tick boundaries.

This is essentially "Pattern A optimized": when you don't need to
exercise the transport, bulk-sampling is 10–1000× faster than
per-share sampling.

## 4. SyntheticMiner trait shape (recommended)

A clean Rust abstraction unifying these:

```rust
#[async_trait]
pub trait SyntheticMiner: Send {
    /// Drive forward to the next share emission point. Returns the
    /// share to submit (or None if the miner is "asleep" / out of
    /// shares this tick). For in-process variants, advancing simulated
    /// time happens here (MockClock.set(...)). For network variants,
    /// this `await`s a real exponential-distribution sleep.
    async fn next_share(&mut self) -> Option<SubmitSharesStandard<'static>>;

    /// React to a difficulty / target change from the pool.
    fn on_set_target(&mut self, target: U256);

    /// React to a new job. Some implementations may pick a fresh
    /// fixture nonce here.
    fn on_new_job(&mut self, job: &NewMiningJob<'_>);

    /// Per-miner hashrate (h/s). Used to compute mean share interval.
    fn hashrate_hps(&self) -> f64;
}

// Concrete impls:
//   InProcessPoissonMiner   — Pattern A/B (in-process, no transport)
//   NetworkPoissonMiner     — Pattern B (real TCP+Noise)
//   FixtureNonceMiner       — Pattern C (real TCP+Noise, fixture nonces)
//   MockValidationMiner     — Pattern D (pool-side fast-validate flag)
//   RealCpuMiner            — Pattern E (actual SHA256d grind)
```

## 5. Per-connection state cost model

For a target of N=100k miners on a single host, the dominant costs:

| Component                          | Per-miner cost            | At N=100k             |
|------------------------------------|---------------------------|-----------------------|
| TCP socket + kernel buffers        | ~16 KB (rcv) + ~16 KB (snd) | ~3.2 GB             |
| Noise codec state (keys + buffers) | ~few KB                   | ~1 GB                 |
| tokio task (stack)                 | ~2 KB (boxed future)      | ~200 MB              |
| SV2 channel state (ext_prefix, target, job tracking) | ~1 KB | ~100 MB     |
| StdRng state                       | ~32 B                     | ~3 MB                 |
| File descriptor                    | 1 fd                      | 100k fds (ulimit)     |

→ 4–6 GB of memory just for connection state. Need `ulimit -n` ≥ 100k
+ `net.core.somaxconn` tuned + ephemeral port range expanded.

The pool-side cost is at least as large (matching server-side state).
So **a 100k-miner scale test is a 200k-connection-state test** and
roughly an 8–12 GB host minimum.

### Per-connection state you can NOT share

- TCP socket fd (kernel)
- Noise session keys (must be unique per peer for replay-resistance)
- SV2 channel_id and extranonce_prefix (pool allocates per channel)
- StdRng state (or shares with deterministic split)

### Per-connection state you CAN share

- Job template / prev_hash (broadcast from one source via watch
  channel — this is what p2poolv2 does internally)
- Fixture nonce pool (precompute one share per (target_difficulty,
  job) tuple, share across miners)
- The pool address / endpoint

## 6. ASICBoost-style rolling extranonce (version-rolling)

A real miner with version-rolling rolls `version_mask` to get extra
search space without changing the merkle root. For a synthetic miner
this is **free**:
- The pool already supports `version_mask = "1fffe000"` (see
  p2poolv2 config-load-test.toml).
- The fake miner can vary the `version` field in
  `SubmitSharesExtended` (or `SubmitSharesStandard` if it tracks the
  job's version) freely within the mask — the pool validates the
  mask and the share.
- At fixture-target, every version-rolled share is also accepted.

So enabling version-rolling on the simulator just means setting the
appropriate `SetupConnection.flags` bit and emitting different
`version` values per share. No cost.

## 7. Throughput ceilings from published numbers

Published submit rates (these are end-to-end roundtrip latency, not
peak):
- p2poolv2 JMeter, 5k miners, 3-sec submit-cycle: **~1700 submits/sec
  aggregate, ~0.3 ms median latency, 0 errors** on a 16-core box.
- Per-core: ~100 submits/sec at this latency profile.
- Scaling linearly (limit-extrapolation): a 16-core box could handle
  ~16k–20k submits/sec at sub-ms latency — i.e. enough for ~250k
  vardiff-clamped miners at 1 share / 15s.

These are SV1 numbers. SV2 numbers will be slightly higher
per-share (binary vs JSON parsing) but each Noise handshake at
connection time is heavier (~ms range), so the **ramp-up storm** is
the worse problem at 100k+ scale, not the steady-state submit rate.

## 8. Open questions / follow-ups

- **Is the JobTracker actor in p2poolv2's SimEmitter per-emitter or
  shareable?** Currently spawned per-emitter (line:
  `tracker: start_tracker_actor()` in `SimEmitter::new`). Could be
  unified for 100k+ emitters; need to verify the actor's API doesn't
  bake in per-miner state.
- **Can the `Composed<E, B, U>` adapter from gimballock's framework
  be re-used in an in-process fake-miner pool?** Yes, it's the exact
  same type used in production (just wrapped with the sim's
  `Observable` extension trait). For an in-process scale-test the
  fake miner would call into a `Composed` instance as its own
  vardiff controller, then the pool's vardiff would also be
  `Composed` — and the two interact through the share-rate channel.
- **Asymmetric Poisson sweep**: gimballock has
  `asymmetric_poisson_sweep.md` at the sim/channels-sv2/ root.
  Worth fetching to see if there are pre-computed worst-case
  scenarios for connection scale.
- **Per-core synthetic-miner throughput ceiling**: nobody has
  published "this pool sustained X simulated miners on Y hardware"
  for SV2 specifically. JMeter results above are SV1. Need a Rust
  async harness to push past 5k cleanly.
- **Connection-storm vs steady-state**: ramp-up cost (Noise handshake
  CPU) is the dominant peak. Need a "slow-start" pattern that
  staggers handshake completion across N seconds for honest steady-
  state numbers.
- **What does the marafoundation/sv2-apps integration-tests/benches/
  directory contain?** Could include a Criterion bench of the
  per-share path that informs the cost model.

## 9. Recommended pattern for an SV2 connection-scale sim

1. **Driver process**: one binary owns a `Vec<Box<dyn SyntheticMiner>>`
   and a `FuturesUnordered<async fn next_share>` for fairness.
2. **Per-miner**: `NetworkPoissonMiner` — real TCP+Noise to the
   pool, exponential-sleep loop, fixture nonce per (job, target)
   tuple. Pattern B + C combined.
3. **Shared resources**: precomputed fixture-nonce table indexed by
   target-leading-zeros, shared across all miners.
4. **Hashrate distribution**: Zipf weights with reproducible seed
   (run-swarm.sh's awk script is a working reference).
5. **Tiered tests**:
   - Tier 1 (10k miners): full Pattern B+C, real validation.
   - Tier 2 (100k miners): Pattern D (pool in fast-validate mode)
     for the share loop, Pattern B+C only for the first 1%
     "control group" miners.
   - Tier 3 (1M miners): cross-host harness, multiple driver
     processes each running tier-2.
6. **Metrics**: per-second submit rate, p50/p95/p99 submit latency,
   handshake errors, connection RST count, pool-side memory growth.
7. **Determinism**: per-miner seed derived from
   `master_seed.wrapping_add(miner_index << 20)` (gimballock pattern).
