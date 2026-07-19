---
title: gimballock vardiff sim — Composed adapter + per-tick Poisson trial driver
source_url: https://github.com/marafoundation/stratum/tree/vardiff/simulation-framework/sv2/channels-sv2/sim
type: repos
ingested: 2026-06-24
quality: A
confidence: high
tags: [vardiff, composed-adapter, poisson, deterministic, gimballock, channels-sv2, in-process]
---

# Gimballock's `Composed` + `run_trial` — in-process vardiff simulator

Location: `sv2/channels-sv2/sim/` on branch
`vardiff/simulation-framework`. Authored by Eric Price (gimballock).
A separate Cargo workspace inside the stratum repo.

## Two layers

1. **`Composed<E, B, U>`** — four-axis decomposition of any vardiff
   algorithm into `Estimator + Boundary + UpdateRule`. Production
   `VardiffState` is implemented as a `Composed`-wrapping façade;
   alternative algorithms (EWMA, sliding-window, parametric,
   AdaCUSUM, FullRemedy) plug into the same shape.
2. **`run_trial(vardiff, clock, config, schedule, seed)`** — a
   deterministic in-process simulator that drives any `Vardiff`
   impl through `duration_secs` of simulated time with synthetic
   share arrivals.

## Per-tick Poisson sampling — the throughput trick

```rust
// At each tick:
let interval_midpoint = (last_tick_at + tick_at) / 2;
let true_h = schedule.at(interval_midpoint) as f64;
let est_h = current_hashrate as f64;
let interval_secs = (tick_at - last_tick_at) as f64;

let lambda = (true_h / est_h) * (config.shares_per_minute as f64) * (interval_secs / 60.0);
let n_shares = sample_poisson(&mut rng, lambda);
vardiff.add_shares(n_shares);
```

This is the key insight that distinguishes this from p2poolv2's
emitter:

- **Per-tick bulk Poisson** instead of per-share exponential
  inter-arrival times.
- **Rate-independent**: works for λ from near-zero to millions of
  shares/tick. Per-share inter-arrival sampling would need sub-second
  time resolution to model high share rates without aliasing.
- **Algorithm fidelity preserved**: the vardiff algorithm acts only
  at tick boundaries, so within-tick share timing is irrelevant. Per-
  tick sampling produces *identical* algorithm outcomes at a
  fraction of the cost.
- **No tokio sleep**: simulated time advances via `clock.set(tick_at)`
  on a `MockClock` shared `Arc`. The whole 30-minute trial runs in
  ~ms of wall time.

A 30-tick trial (30 simulated minutes at 60s ticks) does ~30 Poisson
draws total — **regardless of share rate**. Compare to p2poolv2's
emitter which would do `30·60·shares_per_sec` actual sleeps.

## TrialConfig surface

```rust
pub struct TrialConfig {
    pub duration_secs: u64,        // default 30 * 60
    pub initial_hashrate: f32,     // default 1.0e10
    pub shares_per_minute: f32,    // default 12.0 (target rate)
    pub tick_interval_secs: u64,   // default 60
}
```

## Determinism

> Every trial is fully deterministic given its `(config, schedule,
> seed)` triple. The grid uses a fixed `base_seed` (default
> `0xDEADBEEFCAFEF00D`) and derives per-cell, per-trial seeds via
> `base_seed.wrapping_add(cell_index << 20).wrapping_add(trial_index)`.
> Re-runs produce byte-identical output across machines and time,
> modulo Rust toolchain version changes that affect floating-point
> determinism.

Self-tests cover:
- Same seed → byte-identical tick timeline
- Different seeds → diverging fire timelines
- Step-schedule changes are observable in the algorithm's response
- High-share-rate cold-start converges (regression test for an
  earlier bug where ~1 share/sec was capped regardless of config)

## HashrateSchedule — modeling the "miner"

```rust
HashrateSchedule::stable(1.0e15)                          // constant
HashrateSchedule::step(1.0e15, 5.0e14, 15 * 60)           // halve at 15min
HashrateSchedule::throttle(1.0e15, 7.0e14, 900, 1200)     // dip + recover
```

Piecewise-constant step function over simulated time. This is the
"shape" of the synthetic miner — the algorithm being tested has no
idea what it really is.

## Glass-box recording per tick

```rust
pub struct TickRecord {
    pub t_secs: u64,
    pub n_shares: u32,
    pub fired: bool,
    pub new_hashrate: Option<f32>,
    pub current_hashrate_before: f32,
    // introspection fields populated by run_trial_observed
    pub delta: Option<f64>,        // test statistic at this tick
    pub threshold: Option<f64>,    // decision threshold
    pub h_estimate: Option<f32>,   // estimator's belief
    pub ratio_std: Option<f64>,
    pub effective_n: Option<f64>,
}
```

Every tick is recorded, not just fires. Metrics (`convergence_time`,
`settled_accuracy`, `jitter`, `reaction_time`, `bias`, `variance`,
`ramp_target_overshoot`, `decoupling_score`) consume this stream.

## What this is good for

- **Algorithm characterization** at insane speed: 50 cells × 1000
  trials × 8 algorithms × 30 ticks = 12M trial-ticks in **2–3
  minutes** on a single host.
- **Regression detection**: committed `.toml` baselines for 8
  algorithms; CI fails if metrics drift.
- **Reproducible worst-case hunting**: `--scan-overshoot 100` runs
  100 seeds and reports the worst.

## What this is NOT

- **Not a network/transport test.** No TCP, no Noise, no framing.
  The `Vardiff` trait surface is the only entry point — it's a pure
  algorithm harness.
- **Not multi-miner.** One `Vardiff` instance per trial. Multi-
  miner population shape is encoded in the `HashrateSchedule` for
  the *one* miner under test; cross-miner effects are out of scope.

## Reuse for scale-testing

The `Composed` adapter is the production vardiff in
`channels-sv2` (the sim wraps it for introspection). So the *same*
algorithm code runs in the production stratum server and in the
in-process sim.

This is a strong precedent: build the synthetic miner around the
same crate-level abstractions the production pool uses, then write
two drivers — one in-process (fast, algorithm-only) and one
network-level (real TCP+Noise, transport-faithful) — that share
the per-miner state shape.

For a 100k-miner connection-scale sim, you'd want:
- a `SyntheticMiner` trait with a single method
  `async fn next_share(&mut self) -> Option<SubmitSharesStandard>`
- an in-process impl that uses MockClock and bulk Poisson (this
  module's pattern)
- a network impl that wraps a real `Connection` and runs the
  exponential-sleep loop (p2poolv2's emitter pattern)
- a `Driver` that owns a `Vec<Box<dyn SyntheticMiner>>` and races
  their `next_share` futures via `FuturesUnordered`.
