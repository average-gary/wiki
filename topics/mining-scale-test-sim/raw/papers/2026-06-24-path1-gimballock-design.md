---
title: "gimballock vardiff simulation framework — DESIGN.md condensation"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/DESIGN.md
source_branch: vardiff/simulation-framework
type: paper
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, simulation, gimballock, design, three-stage-pipeline, four-axis, composed]
---

# DESIGN.md — the architectural reference

The 678-line architectural reference for `sv2/channels-sv2/sim`.
Defines the three-stage pipeline decomposition (originally framed
as four-axis), the explicit inter-stage handoff contracts, the
`Composed` adapter, the algorithm registry, and the simulation
infrastructure.

## The three-stage pipeline

A vardiff algorithm answers three questions in sequence, and the
framework's distinctive feature is to characterize algorithms as
**compositions of three sequential stages with explicit handoff
contracts**:

1. **What is happening?** → Estimator (state estimation)
2. **Should I act?** → Boundary (decision theory)
3. **How should I act?** → UpdateRule (control theory)

The deviation computation `|h_estimate / current_h - 1| × 100` is a
fixed normalization step performed by the `Composed` adapter between
stages 1 and 2 — not a configurable axis. (The earlier framing called
this `Statistic` and counted four axes; the current design demotes it
to inline arithmetic.)

### Pipeline execution model

```
shares arrive → Estimator → Belief → [delta] → Boundary → fire? → UpdateRule → new target
                    ↑                                                                │
                    └──────────────── on_fire(new, old) ◄────────────────────────────┘
```

On each tick, the `Composed` adapter:

```rust
fn try_vardiff(&mut self, hashrate, target, spm) -> Option<new_hashrate> {
    let snap = self.estimator.snapshot(dt, &ctx);              // Stage 1
    let delta = |snap.h_estimate / hashrate - 1.0| × 100;      // fixed
    let threshold = self.boundary.threshold(dt, spm, &snap);   // Stage 2
    if delta < threshold { return None; }
    let new_h = self.update.next_hashrate(&snap, hashrate, delta, spm);  // Stage 3
    self.estimator.on_fire(new_h, hashrate);                   // feedback
    Some(new_h)
}
```

## Why sequential handoffs (not independence)

The earlier "four axes are independent" framing was true at the
interface level but false at the behavioral level:

- `PoissonCI` was calibrated for EWMA's noise profile; swapping in
  CumulativeCounter produces pathological behavior.
- The `(τ, η, z)` parameter sweep is really a joint optimization
  over a coupled system.
- The boundary uses `dt_secs` as a *proxy* for estimator confidence
  — catastrophic for Bayesian estimators.

The new design makes the couplings explicit and principled:

1. Estimator reports its confidence (not just a point estimate)
2. Boundary uses that confidence directly (no proxy inference)
3. UpdateRule knows how decisive the fire was (no blind η)
4. Estimator is notified of fires, not forced to reset

## Stage 1: Estimator

```rust
pub struct Belief {
    pub h_estimate: f32,
    pub realized_spm: f64,
    pub n_shares: u32,
    pub dt_secs: u64,
    pub uncertainty: Option<Uncertainty>,
}
pub struct Uncertainty { pub ratio_std: f64, pub effective_n: f64 }

pub trait Estimator: Debug + Send + Sync {
    fn observe(&mut self, n_shares: u32);
    fn belief(&self, dt_secs: u64, ctx: &EstimatorContext) -> Belief;
    fn on_fire(&mut self, new_hashrate: f32, old_hashrate: f32);
    fn shares_count(&self) -> u32;
}
```

`on_fire` (not `reset`): absolute-rate estimators (CumulativeCounter,
EWMA) full-reset (their state is expressed relative to the old target,
invalid after retarget); ratio-based estimators (Bayesian) rescale
the posterior to ratio≈1.0 while preserving accumulated confidence.

**Shipped estimators:**

| Estimator | Memory model | Uncertainty | on_fire |
|---|---|---|---|
| `CumulativeCounter` | since last fire | None | Full reset |
| `EwmaEstimator(τ)` | exponential decay | None | Full reset |
| `SlidingWindowEstimator(N)` | rectangular | None | Full reset |
| `BayesianEstimator(d, p)` | Gamma posterior | `Some` | Rescale, preserve confidence |
| `CkpoolEstimator` | per-share EMA simulation | None | Full reset |
| `SpmRatioEstimator` | EWMA on raw SPM | None | (discarded — see PID_INVESTIGATION) |
| `TimeBiasEwmaEstimator` | single-window EWMA with bias correction | None | (reference) |

Rule of thumb: memory ≈ 2× the noise timescale to reject.
At SPM=6 (41% per-tick RSD), τ=60–120s for EWMA or discount=0.85–0.95
for Bayesian.

## Stage 2: Boundary

```rust
pub trait Boundary: Debug + Send + Sync {
    fn threshold(&self, dt_secs: u64, spm: f32, belief: &Belief) -> f64;
}
```

Fire iff `magnitude ≥ θ`. The boundary sees the full `Belief` so
uncertainty-aware boundaries can adapt.

**Shipped boundaries:**

| Boundary | Rate-aware | Uncertainty-aware | Behavior |
|---|---|---|---|
| `StepFunction` | No | No | Fixed dt_secs lookup table (classic) |
| `PoissonCI(z, margin)` | Yes | No | Poisson CI on expected count |
| `CredibleIntervalBoundary(level)` | Yes | Yes | Fires when posterior CI excludes 1.0 |
| `AsymmetricCusumBoundary(s, f, r)` | Yes | No | Directional cost-awareness |
| `AdaptiveCusumBoundary(s, f)` | Yes | No | Sequential evidence accumulation, `1/n` scaling |
| `AsymmetricPoissonCI` | Yes | No | Asymmetric CI on tighten/ease |
| `AdaptiveSignPersist` / `SignPersistenceCusumBoundary` | Yes | No | PoissonCI<spm_threshold, sign-persist CUSUM≥ |
| `HysteresisGate` | No | No | (ckpool port — discarded) |

## Stage 3: UpdateRule

```rust
pub trait UpdateRule: Debug + Send + Sync {
    fn act(
        &self,
        belief: &Belief,
        current_hashrate: f32,
        deviation: &Deviation,
        margin: f64,
        spm: f32,
    ) -> f32;
}
```

**Shipped update rules:**

| UpdateRule | Per-fire magnitude | Behavior |
|---|---|---|
| `FullRetargetWithClamp` | 100% (clamped) | Classic: jump to estimate, clamp to [/4, ×4] or [/2, ×2] |
| `PartialRetarget(η)` | η × gap | Move η fraction toward estimate |
| `FullRetargetNoClamp` | 100% | Direct jump |
| `AcceleratingPartialRetarget(base, max, acc)` | base→max over consecutive same-direction fires | PID-derived; promoted to production |
| `GuardedAccelRetarget` | accel with guard rail | |

## Cross-stage coupling rules

| Rule | Coupling | Why |
|---|---|---|
| 1 | Estimator noise ↔ Boundary width | Noisy estimator + tight boundary = false fires |
| 2 | Boundary tightness ↔ UpdateRule η | Tight boundary + aggressive update = oscillation |
| 3 | Estimator lag ↔ UpdateRule damping | Lagged estimate + aggressive update = undershoot |
| 4 | Share rate range ↔ Boundary type | Wide SPM range → need rate-aware boundary |
| 5 | Estimator uncertainty ↔ Boundary adaptation | The key redesign insight |

## The `Composed` adapter

```rust
pub struct Composed<E: Estimator, B: Boundary, U: UpdateRule> {
    pub estimator: E,
    pub boundary: B,
    pub update: U,
    pub timestamp_of_last_update: u64,
    pub min_allowed_hashrate: f32,
    pub clock: Arc<dyn Clock>,
    pub last_decision: Option<DecisionRecord>,
}
```

Lives in production (`channels_sv2::vardiff::composed::Composed`,
~10 KB). The sim crate adds only an `impl Observable for Composed`
extension to expose `last_decision` for trial recording.

The only policies the adapter imposes are:
- 15-second minimum inter-fire guard (matching legacy `VardiffState`)
- `min_allowed_hashrate` floor

## Algorithm registry (current shipped factories)

| Factory in `sim/src/grid.rs` | Composition | Role |
|---|---|---|
| `classic_vardiff_state()` | the legacy production reference (not introspectable) | baseline |
| `classic_composed()` | `CumulativeCounter + StepFunction + FullRetargetWithClamp` | fire-for-fire equivalent to classic; introspectable |
| `parametric()` | `… + PoissonCI(z=2.576) + …` | classic + rate-aware threshold |
| `parametric_strict()` | `… + PoissonCI(z=3.0) + …` | 99.7% CI |
| `ewma_60s()`, `ewma(τ)` | `EwmaEstimator(τ) + … + PartialRetarget(0.5)` | smoothed |
| `sliding_window(n)` | `SlidingWindowEstimator(n) + … + FullRetargetNoClamp` | last-n averaging |
| `classic_partial_retarget(η)` | `… + PartialRetarget(η)` | classic + damped |
| `full_remedy()` | `EwmaEstimator(120s) + PoissonCI + PartialRetarget(0.3)` | derived in FINDINGS.md |
| `ada_cusum()` | `EwmaEstimator(120s) + AdaptiveCusumBoundary(1.5, 0.05) + PartialRetarget(0.2)` | post-FullRemedy improvement |
| `bayesian_ci()` | `BayesianEstimator + CredibleIntervalBoundary + PartialRetarget` | uncertainty-aware |
| `pow2_pid()`, `pid_balanced/aggressive/conservative()` | PID controllers (Pow2-PID, well-tuned PID) | comparison only — both fail |
| `ckpool()`, `ckpool_remedy*()`, `ckpool_narrow_hyst()`, `ckpool_with(τs, τl, lo, hi)` | ckpool ports | comparison; not adopted |
| `best_of_best()` | speculative all-PID-derived | abandoned |
| `Ewma360/s1.5` (the champion) | `EwmaEstimator(360s) + AdaptiveSignPersist(spm_threshold=6) + AcceleratingPartialRetarget(0.2, 0.6, 0.05)` | **the current production VardiffState** |

## Trial recording

Every tick of every trial is a `TickRecord`:

```rust
pub struct TickRecord {
    pub t_secs: u64,
    pub n_shares: u32,
    pub current_hashrate_before: f32,
    pub delta: Option<f64>,
    pub threshold: Option<f64>,
    pub h_estimate: Option<f32>,
    pub uncertainty: Option<Uncertainty>,
    pub fired: bool,
    pub new_hashrate: Option<f32>,
}
```

Optional fields populated by `run_trial_observed` for algorithms
implementing `Observable`. Non-observable algorithms (legacy
`VardiffState`) leave them `None` and only end-to-end metrics work.

## Scenarios

```rust
pub enum Phase {
    Hold { duration_secs: u64, h: f32 },
    Ramp { duration_secs: u64, from: f32, to: f32 },
    Stall { duration_secs: u64 },
}
```

Named scenarios:
- `ColdStart` (10 GH/s → 1 PH/s)
- `Stable` (1 PH/s)
- `Step { delta_pct }` (step change at 15 min)
- `SlowDecline` (sustained `−ρ %/hr` ramp — the §9 safety scenario)
- `settled-aged drop` (truth holds long enough to mature counter, then drops)

## Grid

`Grid` is a Cartesian product over `algorithms × share_rates × scenarios`.
`Grid::run_paired` strips the algorithm index from the seed so all
algorithms see identical trial inputs — metric differences are
attributable to the algorithm alone. Seeds derived as
`base_seed.wrapping_add(cell_index << 20).wrapping_add(trial_index)`
with `base_seed = 0xDEADBEEFCAFEF00D`.

## Metrics (stage-attributed)

The metrics are organized by **what information is available at each
pipeline stage** so a regression can be attributed to the specific
stage that changed.

**Stage 1 (Estimator):**
- `bias` — `E[(h_estimate - true_h) / true_h]` post-settle
- `variance` — `Var[h_estimate / true_h]` post-settle
- tracking error (RMSE over full trial)
- uncertainty calibration — `P(true_h ∈ CI_reported)` vs nominal
- confidence recovery — ticks after fire until `ratio_std < X`

**Stage 2 (Boundary):**
- `selectivity` / `decoupling_score` = `reaction_rate × clamp(1 − jitter/J_max, 0, 1)`
- `reaction_rate` (within 5 min of step)
- `jitter` (fires/min under stable load)
- fire decisiveness, threshold adaptiveness
- false fire rate, missed detection rate

**Stage 3 (UpdateRule):**
- `ramp_target_overshoot`
- `convergence_rate`, `convergence_time`
- step correction (`(new − current) / (true − current)`)
- oscillation

**End-to-end:**
- `settled_accuracy` (split: active vs inert)
- `reaction_asymmetry`
- time-to-target

## Determinism

Every trial is fully deterministic given `(config, schedule, seed)`.
`XorShift64`, reproducible across machines.

## Production migration

`Composed<E, B, U>` implements `Vardiff`, so any composition is a
drop-in replacement at any production call site that accepts
`Box<dyn Vardiff>` or `impl Vardiff`. Several "experimental" sim-only
algorithms (PID variants, SpmRatioEstimator, SignPersistenceCusumBoundary,
HysteresisGate, CkpoolRetarget) live in production code but are not
adopted — they exist so the grid can include them as comparison points.

## Implications for scale testing

- **Share-arrival is Poisson with rate = `r* × H/Ĥ`.** A connection-scale
  harness wanting realistic share traffic from `N` virtual miners can
  use the same Poisson model (one per virtual miner) — this is the
  load-shape model the sim implicitly validates.
- **Per-tick (not per-share) evaluation.** The sim ticks every 60s and
  samples `n_shares ~ Poisson(λ × dt)` for the whole interval. A
  scale-test harness running the actual `Vardiff` trait should match
  this cadence; per-share evaluation is a CKPOOL idiom that the
  CKPOOL_INVESTIGATION explicitly retired because it's noisier per-tick.
- **The `Vardiff` trait is the seam.** A scale-test harness can plug
  in any vardiff implementation behind the trait — the production
  `VardiffState`, a `Composed<E, B, U>` of any combination, or a
  mock returning fixed targets — without changes to the connection
  layer.
- **No connection-count axis exists.** The `Grid` is
  `algorithm × share_rate × scenario`. To extend it to connections,
  a parallel `connection_count` axis would be needed; the metric
  registry would also need server-side metrics (handshake latency,
  socket count, validation CPU) that don't exist today.

## What the framework cannot say about scale

- It says nothing about TCP/Noise/framing throughput.
- It says nothing about how `N_connections × r*` shares per second
  pile up at the pool. Each trial is a single connection.
- It says nothing about share-validation cost — there's no validation
  in the sim, just a `Vardiff::try_vardiff` call per tick.
- Its claim about the "information floor" `1/(r*τ)` is per-connection
  and tells the operator that raising `r*` buys agility at a
  per-connection volume cost. The pool-side cost (multiplied by
  N connections) is exactly what the scale-test wiki argues is the
  real scaling bottleneck.
