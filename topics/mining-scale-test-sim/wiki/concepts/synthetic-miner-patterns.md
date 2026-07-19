---
title: "Synthetic miner patterns"
type: concept
created: 2026-06-24
confidence: high
tags: [synthetic-miner, simulator, poisson, fixture]
---

# Synthetic miner patterns

How do you drive 10k–1M fake miners at a chosen aggregate share rate
without burning megawatts on real PoW? Five patterns observed across
existing harnesses, ordered by what they exercise on the pool side.

## The five patterns

| # | Pattern | Per-miner cost | Tests pool path |
|---|---------|----------------|------------------|
| **A** | **Mock-share / accounting-only** — no submission, harness counts internally against algo under test | ~zero | Algorithm only |
| **B** | **Poisson over real connection** — real TCP+Noise; `tokio::sleep(exp(D·2^32/H))` then submit | 1 tokio task, ~few KB | Vardiff/ASERT closed-loop |
| **C** | **Fixture-target (diff-1 trick)** — easy bits `0x2100ffff` so any nonce is valid; pool still validates | 1 OS thread (JVM) | Full validate_share + submitblock |
| **D** | **Hybrid mock-validation** — real handshake; pool flag skips SHA256d on submit | minimal | Connection layer only |
| **E** | **Real-CPU miner** — actually grind SHA256d | 1+ OS thread/core | Everything, slowly |

Real harnesses use a mix:
- gimballock's `vardiff/simulation-framework` = Pattern **A** in-process
- p2poolv2's `SimEmitter` = Pattern **B** in-process (closed-loop)
- p2poolv2's JMeter setup = Pattern **C** (SV1)
- sv2-apps `mining_device` = Pattern **E** with `handicap` slowdown
- cpuminer-multi `--benchmark` = Pattern **E**, no network

## Workload-pattern axis (orthogonal to A-E)

A synthetic-miner *pattern* (A-E) is _how_ shares get produced; a
*workload pattern* is _the rate trajectory over time_. The two compose.

| Workload | Trajectory | Tests |
|----------|-----------|-------|
| `Steady` | Poisson at constant `λ = r* / 60` | Steady-state cost |
| `Ramp25/50/100` | First N% of fleet burst-connects at t=0 | First-retarget storm — [[share validation cost model|130 ms validation spike]] |
| `Dropout25/50/100` | Drop N% of connections at t=T, rejoin at t=T+Δ | Reconnect handshake-CPU + ramp re-storm |
| **`SlowWarmup`** | Declare low hashrate → vardiff floors → at t=60s shift to true hashrate without re-declaring | `public-pool#120` failure mode — 1 connection produces 1.6 M sps |
| **`MidBlockRetargetRejection`** | Fire `set_difficulty` mid-block without `clean_jobs` → 12-16% of queued shares firmware-rejected on S19/S21 | `SpiralPool#10` failure mode — measured vs realized SPM diverge |

The two new patterns (`SlowWarmup`, `MidBlockRetargetRejection`) map
to the only two public production post-mortems documented in [[operational
storm postmortems]]. Both are cheap to simulate: `SlowWarmup` is a
Poisson with a delayed step in `λ`; `MidBlockRetargetRejection` is a
realized-share counter that decrements by 12-16% on any mid-block
retarget event.

## The math

```
mean_inter_share_seconds = D × 2^32 / H
shares_per_second        = H / (D × 2^32)
hashes_per_diff_1_share  = 2^32 = 4_294_967_296
```

Tested and documented in `p2poolv2_lib::sim::timing::mean_share_interval_secs`
with three regression tests (doubling `H` halves interval; doubling `D`
doubles; mean converges to expected over 200k samples).

For Poisson share arrival with rate `λ = 1 / mean_inter_share_seconds`,
sample exponentially:

```rust
fn sample_exponential(mean: f64, rng: &mut impl Rng) -> f64 {
    let u: f64 = rng.gen_range(0.0..1.0);
    -mean * (1.0 - u).ln()
}
```

Each miner needs its own RNG state (~32 B); seed deterministically as
`master_seed.wrapping_add(miner_idx << 20)` for reproducibility.

## Recommended tiered plan for an SV2 scale harness

The pattern mix depends on the target scale:

| Tier | N | Pattern | Why |
|------|---|---------|-----|
| **1** | 10k | **B + C** — real Noise, real fixture-validated shares for every miner | Full validation path exercised |
| **2** | 100k | **D** for 99% of share loop, **B + C** for first 1% control group | Most miners only stress connections; control group validates pool's share path |
| **3** | 1M+ | Multi-host driver; each host runs Tier 2 | Single-host ceiling is ~500k connections |

## A clean trait

```rust
#[async_trait]
trait SyntheticMiner: Send {
    async fn next_share(&mut self) -> Option<SubmitSharesStandard<'static>>;
    fn on_set_target(&mut self, target: U256);
    fn on_new_job(&mut self, job: &NewMiningJob<'_>);
    fn hashrate_hps(&self) -> f64;
}
```

with one concrete impl per pattern. Driver loops with
`FuturesUnordered` for fair scheduling across the miner fleet.

## Reusable pieces

- **`Composed<E, B, U>` adapter from `channels-sv2::vardiff`**: same
  type used in production. The in-process scale-test has fake miners
  and pool both instantiate `Composed`, interacting through a
  share-rate channel. Reuses [[gimballock vardiff sim|gimballock's
  framework]] verbatim.
- **Mock-bitcoind** (from p2poolv2 JMeter): a Node.js stub that always
  returns the same `getblocktemplate` and OKs every `submitblock`.
  Decouples the pool from chain state during load tests.
- **Fixture nonces**: precompute a table keyed by `target_leading_zeros
  → valid_nonce`; the miner picks the right entry for current vardiff
  target. ~99% of bytes are shareable across the fleet.
- **ASICBoost / version-rolling**: free — set `SetupConnection.flags`
  bit, vary `version` field within `version_mask = 0x1fffe000` per
  share. Fixture-target accepts any version.

## Per-connection state cost (at N = 100k)

| Component | Per-miner | At N=100k |
|-----------|-----------|-----------|
| TCP socket + kernel buffers | ~32 KB | ~3.2 GB |
| Noise codec state | ~few KB | ~1 GB |
| tokio task | ~2 KB | ~200 MB |
| SV2 channel state | ~1 KB | ~100 MB |
| StdRng state | ~32 B | ~3 MB |
| File descriptor | 1 fd | 100k fds (ulimit) |
| **Total** | **~50 KB** | **~5 GB** |

Pool-side mirrors this, so 100k-miner = 200k-conn = **8-12 GB minimum
host**.

Shareable across miners: job template (via `tokio::sync::watch`),
fixture-nonce table, pool address. **Not shareable**: TCP fd, Noise
keys, channel_id, extranonce_prefix, RNG state.

## Published throughput

- p2poolv2 JMeter at 5,000 miners × 3 s submit cycle = ~1,700
  submits/sec aggregate, ~0.3 ms median latency, on 16 cores. SV1 only;
  ckpool fails 27% of submits at the same load (single-threaded accept
  loop).
- Extrapolated ceiling: **~16-20k submits/sec sub-ms latency per
  16-core load-host**, enough for ~250k vardiff-clamped miners at 1
  share / 15 s.
- **No published SV2 multi-miner scale numbers** — the gap this wiki
  exists to fill.

## See also

- [[load harness landscape]] — what framework runs these patterns
- [[connection scale bottlenecks]] — what the connection layer can support
- [[share validation cost model]] — what the pool side does per share
- [[gimballock vardiff sim]] — the Pattern A in-process reference
