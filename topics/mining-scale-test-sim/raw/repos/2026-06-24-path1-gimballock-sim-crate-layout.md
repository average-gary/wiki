---
title: "gimballock vardiff sim crate — Cargo.toml, lib.rs, composed.rs, grid.rs, trial.rs, schedule.rs, metrics.rs, rng.rs"
source_url: https://github.com/marafoundation/stratum/tree/vardiff/simulation-framework/sv2/channels-sv2/sim/src
source_branch: vardiff/simulation-framework
type: repo
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, simulation, gimballock, rust-crate, layout, public-api]
---

# vardiff_sim crate — source layout and public API

The crate is structured as its own Cargo workspace (parent `stratum`
workspace pins Rust 1.75; sim's `Cargo.lock` is v4 format which
1.75 cannot write). Lives in `sv2/channels-sv2/sim/`.

## `Cargo.toml`

```toml
[workspace]                             # own workspace, isolated lockfile

[package]
name = "vardiff_sim"
version = "0.1.0"
edition = "2021"
description = "Vardiff algorithm simulation framework for behavioral characterization and CI regression testing"

[dependencies]
channels_sv2 = { path = ".." }          # production crate; the sim consumes it
bitcoin = "0.32.5"
```

Notably **no** `rand`, no `tokio`, no `tracing`, no `serde`.
RNG is hand-rolled XorShift64 (rng.rs). TOML serialization is hand-rolled
in `baseline.rs` to keep the dep tree small and reproducible.

## `src/lib.rs` — public API

8 modules:

```rust
pub mod baseline;       // Cell / CellResult / Phase / Scenario / TOML serializers
pub mod composed;       // sim-side facade re-exporting production composed/
pub mod grid;           // Grid + AlgorithmSpec + VardiffBox + run_paired
pub mod metrics;        // Metric trait + ~30 metrics + bootstrap CI
pub mod naming;         // canonical algorithm-name generation
pub mod regression;     // baseline parsing + tolerance assertions
pub mod rng;            // XorShift64 + sample_exponential + sample_poisson
pub mod schedule;       // HashrateSchedule
pub mod trial;          // run_trial + run_trial_observed + TickRecord + Observable
```

Re-exports (the consumed API):
- From `baseline`: `Cell, CellResult, Phase, Scenario, phases_to_trial, RAMP_SEGMENTS`
- From `composed`: production three-stage types (`Composed`, all estimators,
  all boundaries, all update rules) — re-exported through this crate as
  a convenience namespace; the actual types live in `channels_sv2::vardiff::composed`
- From `grid`: `Grid, AlgorithmSpec, AsObservable, VardiffBox, ObservableVardiff`
- From `metrics`: all metric structs, `Distribution`, `MetricValues`,
  `ScenarioFilter`, `Tolerance`, `ToleranceCheck`, `SummarySpec`, `SummaryFmt`,
  `bootstrap_percentile_ci`, `CI_SEED`, `DEFAULT_CI_RESAMPLES`,
  `DEFAULT_JITTER_CEILING_PER_MIN`
- From `rng`: `XorShift64, sample_exponential, sample_poisson`
- From `schedule`: `HashrateSchedule`
- From `trial`: `run_trial, run_trial_observed, DecisionRecord, Observable,
  TickRecord, Trial, TrialConfig`

### Unit conventions (lib.rs docs)

| Location | Convention | Example |
|---|---|---|
| Boundary threshold/deviation (δ, θ) | percentage points | `δ = 60.0` ⇔ 60% |
| `bias_*`, `ramp_target_overshoot_*` | fraction | `0.10` ⇔ +10% |
| `settled_accuracy_*` | fraction | `0.04` ⇔ 4% off |
| `convergence_rate`, `reaction_rate` | fraction in [0, 1] | `0.95` ⇔ 95% |
| `jitter_*_per_min` | rate | `0.04` ⇔ 0.04 fires/min |
| `convergence_p*_secs`, `reaction_p*_secs` | seconds | `420.0` ⇔ 420 s |
| `variance_*` | dimensionless | `0.01` ⇔ σ²(H̃/H)=0.01 |

The percentage-point convention for δ/θ is preserved for bit-equivalence
with `VardiffState`'s internal formula (`hashrate_delta_percentage = ... * 100.0`).

## `src/composed.rs` — sim-side facade

58 lines. Re-exports `channels_sv2::vardiff::composed::*` and adds:

```rust
impl<E, B, U> Observable for Composed<E, B, U>
where E: Estimator, B: Boundary, U: UpdateRule
{
    fn last_decision(&self) -> Option<DecisionRecord> {
        self.last_decision
    }
}
```

That's it — the entire sim-side composed module is the `Observable`
extension. The four-axis decomposition (Estimator, Boundary, UpdateRule,
Composed adapter) lives in PRODUCTION at `sv2/channels-sv2/src/vardiff/composed/`,
having been promoted from the sim crate by commit `ef2eb2e6`.

The smoke test:
```rust
#[test]
fn vardiff_state_delegates_to_composed_and_produces_fires() {
    // VardiffState now wraps AdaCUSUM internally. Verify it
    // actually fires during a cold-start scenario.
    ...
    let trial = run_trial(state, clock, config, &schedule, 0xCAFE);
    assert!(trial.fires().len() >= 3);
}
```
(Note the comment says "AdaCUSUM" — but the latest production VardiffState
delegates to `champion_composed` which is `Ewma360/s1.5` — the comment
is stale, the test still passes because the champion also fires multiple
times during cold start.)

## `src/grid.rs` — algorithm registry (~2350 lines)

The Cartesian product layer. Key types:

```rust
pub trait ObservableVardiff: Vardiff + Observable {}
impl<T: Vardiff + Observable + ?Sized> ObservableVardiff for T {}

// Wraps a non-observable Vardiff so it can flow through the
// run_trial_observed dispatch path with introspection fields as None.
pub struct AsObservable<V: Vardiff>(pub V);

// Type-erased Vardiff + Observable for storing heterogeneous algorithms
// in the same algorithms vector.
pub struct VardiffBox(pub Box<dyn ObservableVardiff>);

pub struct AlgorithmSpec {
    pub name: String,
    pub factory: Arc<dyn Fn(Arc<MockClock>) -> VardiffBox + Send + Sync>,
}

pub struct Grid {
    pub algorithms: Vec<AlgorithmSpec>,
    pub share_rates: Vec<f32>,
    pub scenarios: Vec<Scenario>,
    pub trial_count: usize,
    pub base_seed: u64,
}
```

Methods:
- `Grid::run` — Cartesian product, return `HashMap<algo_name, Vec<CellResult>>`
- `Grid::run_paired` — strips algorithm index from seed so all algos see
  identical trial inputs (paired A/B)

Seeding:
```rust
seed = base_seed + (cell_index << 20) + trial_index
cell_index = algo_idx * N_spm * N_scen + spm_idx * N_scen + scen_idx
// run_paired strips algo_idx so all algorithms see the same per-cell seeds
```

The `<< 20` shift gives each cell a 1,048,576-entry seed range —
collision-free as long as `trial_count ≤ 2^20`.

`AlgorithmSpec` factories include ~30 algorithm presets (sampled):
`classic_vardiff_state`, `classic_composed`, `parametric`,
`parametric_strict`, `ewma_60s`, `ewma(τ)`, `sliding_window(n)`,
`classic_partial_retarget(η)`, `full_remedy`, `ada_cusum`,
`bayesian_ci`, `pow2_pid`, `pid_balanced/aggressive/conservative`,
`ckpool*`, `best_of_best`, etc.

## `src/trial.rs` — trial recording

Key types:

```rust
pub struct TrialConfig {
    pub duration_secs: u64,            // default 30 * 60
    pub initial_hashrate: f32,         // default 1.0e10
    pub shares_per_minute: f32,        // default 12.0
    pub tick_interval_secs: u64,       // default 60
}

pub struct TickRecord {
    pub t_secs: u64,
    pub n_shares: u32,
    pub fired: bool,
    pub new_hashrate: Option<f32>,
    pub current_hashrate_before: f32,
    pub delta: Option<f64>,
    pub threshold: Option<f64>,
    pub h_estimate: Option<f32>,
    pub ratio_std: Option<f64>,
    pub effective_n: Option<f64>,
}

pub struct Trial {
    pub config: TrialConfig,
    pub seed: u64,
    pub ticks: Vec<TickRecord>,
    pub final_hashrate: f32,
    pub true_hashrate_at_end: f32,
}
```

The trial driver per-tick algorithm:
```rust
1. compute λ = (true_h / est_h) × spm × (interval_secs / 60)
   using schedule.at(interval_midpoint)
2. n_shares = sample_poisson(rng, λ)
3. vardiff.add_shares(n_shares)
4. clock.set(tick_at)
5. result = vardiff.try_vardiff(current_h, target, spm)
6. decision = observe(&vardiff)  // None for non-observable
7. push TickRecord
8. if fired: current_h = new_h, recompute target via hash_rate_to_target_safe
```

**Per-tick (not per-share)** Poisson sampling for two reasons:
1. Rate independence: works for any λ from near-zero to millions
2. Algorithm fidelity: the algorithm only acts at tick boundaries,
   so within-tick share timing is irrelevant to its behavior

## `src/schedule.rs` — scenario DSL

```rust
pub struct HashrateSchedule {
    segments: Vec<(u64, f32)>,  // (start_secs, hashrate), sorted, first = (0, _)
}

impl HashrateSchedule {
    pub fn stable(hashrate: f32) -> Self;
    pub fn step(before: f32, after: f32, change_at_secs: u64) -> Self;
    pub fn throttle(baseline: f32, during: f32, start: u64, end: u64) -> Self;
    pub fn at(&self, t: u64) -> f32;  // step-function lookup
}
```

**Schedule-change approximation** (trial.rs comment): the expected
share count is computed from `schedule.at(interval_midpoint)`. For
schedules that change at tick boundaries (default scenarios), this is
exact. For mid-tick transitions, the error is bounded to one tick.

## `src/metrics.rs` — ~4575 lines

The Metric trait, registry of ~30 metrics, and bootstrap CI:

Key metrics (consumed by baselines and the regression suite):
- `ConvergenceTime` — seconds to first fire-followed-by-quiet-window
- `SettledAccuracy` — `|final_h / true_h − 1|` at trial end (split active/inert)
- `Jitter` — fires/min under stable load
- `ReactionTime` — seconds from step to first subsequent fire
- `SettledReactionTime` — reaction after counter has matured
- `Bias` — `E[H̃ − H_true] / H_true` post-settle (introspectable only)
- `Variance` — `Var[H̃ / H_true]` post-settle
- `RampTargetOvershoot` — peak fire-target above truth during cold start
- `ReactionAsymmetry` — `reaction_rate(+δ%) − reaction_rate(−δ%)`
- `DecouplingScore` (renamed `Selectivity` in DESIGN.md) —
  `reaction_rate × clamp(1 − jitter_p50 / J_max, 0, 1)`
- `CounterAgeSensitivity` — reaction conditional on counter age
- `LogErrorRegret` — the §10 white-paper metric: `regret_over`, `regret_under`,
  `effort_up`, `effort_down`, EXCESS(r*) diagnostic

Derived/composite:
- `EqualWeightFitness` — deprecated (six-axis radar, rewards trade-off midpoint)
- `ComprehensiveFitness` — composite operational score (FINDINGS.md)
- `OperationalFitness` — second-generation composite (FINDINGS.md §"operational_fitness")

Bootstrap CI:
- `bootstrap_percentile_ci(values, percentile, n_resamples, seed) -> (low, mid, high)`
- `CI_SEED` — separate from the trial seed so CI computation doesn't
  interfere with trial reproducibility
- `DEFAULT_CI_RESAMPLES = 200`
- `DEFAULT_JITTER_CEILING_PER_MIN = 0.30`

## `src/baseline.rs` — Cell / CellResult / TOML serializers

```rust
pub struct Cell {
    pub share_rate: f32,
    pub scenario: Scenario,
}

pub struct CellResult {
    pub cell: Cell,
    pub trials: Vec<Trial>,
    pub metrics: MetricValues,
}

pub enum Scenario {
    ColdStart, Stable, Step { delta_pct: i32 },
    SettledStep { delta_pct: i32 }, SlowDecline, ...
}

pub enum Phase {
    Hold { duration_secs: u64, h: f32 },
    Ramp { duration_secs: u64, from: f32, to: f32 },
    Stall { duration_secs: u64 },
}

pub const DEFAULT_BASELINE_SEED: u64 = 0xDEADBEEFCAFEF00D;
pub const DEFAULT_TRIAL_COUNT: usize = 1000;
pub const RAMP_SEGMENTS: usize = 8;
```

TOML format is the structured source of truth; markdown is the human-review
view. A regenerated baseline diff is the gate for accepting an algorithm change.

## `src/regression.rs` — baseline-parsing + tolerance assertions

The `#[ignore]`-d test that runs `cargo test --release --lib -- --ignored`.
Loads the committed `baseline_VardiffState.toml`, regenerates the cell grid
under the current production algorithm, and compares with metric-specific
tolerance budgets. CI-aware (looser tolerance on noisy metrics).

## `src/rng.rs` — XorShift64 + Poisson/exponential sampling

Hand-rolled because:
- Reproducibility across rustc/dep versions (two runs years apart
  produce identical share-arrival streams from the same seed)
- Minimal dep footprint

```rust
pub struct XorShift64 { state: u64 }
pub fn sample_exponential(rng: &mut XorShift64, rate: f64) -> f64;
pub fn sample_poisson(rng: &mut XorShift64, lambda: f64) -> u32;
```

Poisson sampling: Knuth's algorithm for `λ < 30` (exact, slow for large λ),
normal approximation for `λ ≥ 30` (O(1), accurate to ~1% of variance).

The base seed `0xDEADBEEFCAFEF00D` is referenced throughout — it's the
fixed grid base from which per-cell, per-trial seeds derive.

## `src/bin/` — 46 binaries (sampled)

Roughly grouped by phase of the investigation:

**Baselines / regression:**
- `generate-baseline.rs` — single-algorithm baseline regeneration
- `compare-algorithms.rs` — cross-algorithm sweep (~2-3 min, 8 algos × 50 cells)
- `trace-trial.rs` — single-trial tick-by-tick reproducer (uses paired seed)

**Parameter sweeps (~22 binaries with `sweep-*` prefix):**
- `sweep-ewma-tau`, `sweep-eta`, `sweep-eta-z`, `sweep-z`, `sweep-bayesian-ci`,
  `sweep-asymmetric-poisson`, `sweep-adaptive`, `sweep-accelerating`,
  `sweep-balanced`, `sweep-corrected`, `sweep-estimators`, `sweep-minimax`,
  `sweep-regret`, `sweep-regret-big`, `sweep-signpersist`,
  `sweep-signpersist-regret`, `sweep-signpersist-cotuned`, `sweep-voladapt`
- Each sweeps one parameter axis and produces a `.md` Pareto report

**Champion confirmation:**
- `confirm-champions.rs`, `confirm-debias.rs`, `confirm-signpersist.rs`,
  `confirm-warmup.rs`

**Specific investigations:**
- `compare-pid.rs`, `compare-best.rs` — PID investigation
- `regret-effort.rs`, `regret-radar.rs` — §10 white-paper metric
- `tau-valley.rs` — the τ-safety-valley figure (white paper §8.3)
- `excess-lever.rs` — the EXCESS-vs-`r*` figure (§8.4)
- `steady-transient.rs` — the steady-vs-transient scatter (§8.2)
- `slow-decline.rs` — the death-spiral gate
- `iterative-eval.rs` — Iteration-0-to-N evaluation (FINDINGS.md)
- `convergence-time.rs`, `counter-age-sweep.rs`,
  `corner-reaction.rs`, `cusum-floor.rs`, `detection-control.rs`,
  `detection-vs-sens.rs`, `floor-ribbon.rs`, `per-config-arl0.rs`,
  `false-alarm-check.rs`, `rescore-corrected.rs`, `trajectory-plot.rs`,
  `champion-weights.rs`, `baseline-asymmetric.rs`

## Reuse for a connection-scale harness

The patterns directly portable:

| Pattern | Reused | Connection-scale equivalent |
|---|---|---|
| `Cell × CellResult × Grid` | yes | `(impl, conn_count, workload) × CellResult × Grid` |
| Paired seeding for A/B | yes | identical |
| TOML baseline + regression suite | yes | identical |
| Bootstrap percentile CI on metrics | yes | identical |
| `#[ignore]`-d slow regression test in CI | yes | identical |
| Hand-rolled XorShift + Poisson | yes (for share arrival per virtual connection) | identical |
| Deterministic `MockClock` | partial | for non-network-bound metrics |
| Per-tick (not per-share) evaluation | partial | depends on scale-test metric |
| `HashrateSchedule` piecewise step-function | yes (one schedule per virtual connection) | `ConnectionSchedule` over time |
| `Metric` trait + registry | yes | new metrics (server CPU, RSS, throughput, latency) |

The patterns that don't translate:
- The `Composed<E, B, U>` pipeline (algorithm-specific)
- The algorithm registry
- The `Observable` introspection trait
- The `Belief`/`Uncertainty` types
- The bin sweeps over algorithm parameters

A scale-test harness should be a sibling crate
(`sv2/channels-sv2/scale-test/` or `sv2/connection-scale-sim/`) with the
same Cargo workspace pattern, reusing `baseline`, `metrics`, `regression`,
`rng`, and `trial`'s recording shape — with a new "trial" definition
where each tick produces server-side load metrics instead of (or in
addition to) algorithm-side decisions.
