---
title: "gimballock's vardiff/simulation-framework — primary reference"
type: reference
created: 2026-06-24
confidence: high
tags: [gimballock, primary-source, vardiff, simulation, sri]
---

# gimballock vardiff sim — primary reference

**Author**: Eric Price (gimballock on GitHub, github.com/gimballock).
26 public repos. Recent activity dominantly in
`marafoundation/stratum` and `marafoundation/sv2-apps`.

**Primary branches** (as of 2026-06-24):

| Repo | Branch | HEAD | Status |
|------|--------|------|--------|
| `marafoundation/stratum` | `vardiff/simulation-framework` | b73125dd (2026-06-23 19:42 UTC) | 52 commits ahead, 0 behind main; 113 files changed |
| `marafoundation/sv2-apps` | `test/vardiff-simulation-framework` | 213ae7da (2026-06-23 19:55 UTC) | 9 commits ahead; deploy branch advancing stratum-core dep through the algorithm migration |

**Production landed**: commit `53924efb feat(vardiff): ship the
champion as production VardiffState` (2026-06-23 13:08 UTC) on
`vardiff/simulation-framework`. The Champion algorithm is now the
production `channels_sv2::VardiffState`.

## What it is

A **deterministic in-process Rust simulation harness** for
characterizing any implementor of the `Vardiff` trait. Lives at
`sv2/channels-sv2/sim/` — its own Cargo workspace (~2350-line
`grid.rs`, ~4575-line `metrics.rs`, ~46 binaries under `src/bin/`, 8
long doc files under `docs/`).

The crate is its own workspace specifically so it can carry an
isolated `Cargo.lock`, pin different versions of `rand`/`statrs`/etc.
than the parent SRI workspace, and not impose its dev-dependency cost
on the rest of stratum-core. Parent depends on it only path-locally.

## The three-stage pipeline

```
shares arrive → Estimator → Belief → [delta] → Boundary → fire? → UpdateRule → new target
                    ↑                                                                │
                    └──────────────── on_fire(new, old) ◄────────────────────────────┘
```

```rust
fn try_vardiff(&mut self, hashrate, target, spm) -> Option<new_hashrate> {
    let snap = self.estimator.snapshot(dt, &ctx);
    let delta = |snap.h_estimate / hashrate - 1.0| × 100;
    let threshold = self.boundary.threshold(dt, spm, &snap);
    if delta < threshold { return None; }
    let new_hashrate = self.update.next_hashrate(&snap, hashrate, delta, spm);
    self.estimator.on_fire(new_hashrate, hashrate);
    Some(new_hashrate)
}
```

**Stage 1 — Estimator**. "What is happening?" Produces `Belief {
h_estimate, realized_spm, n_shares, dt_secs, uncertainty:
Option<Uncertainty> }`. Shipped: `CumulativeCounter`,
`EwmaEstimator(τ)`, `SlidingWindowEstimator(N)`, `BayesianEstimator`,
`CkpoolEstimator`, `SpmRatioEstimator`, `TimeBiasEwmaEstimator`.

**Stage 2 — Boundary**. "Should I act?" Sees the full belief and
returns a threshold; uncertainty-aware boundaries self-calibrate.
Shipped: `StepFunction`, `PoissonCI`, `CredibleIntervalBoundary`,
`AsymmetricCusumBoundary`, `AdaptiveCusumBoundary`,
`AsymmetricPoissonCI`, `AdaptiveSignPersist`, `HysteresisGate`.

**Stage 3 — UpdateRule**. "How should I act?" Sees the margin
(`deviation − threshold`) so future "decisive vs marginal" fires are
expressible. Shipped: `FullRetargetWithClamp`, `PartialRetarget(η)`,
`FullRetargetNoClamp`, `AcceleratingPartialRetarget`,
`GuardedAccelRetarget`.

The deviation `|h_estimate / current_h − 1| × 100` was demoted from a
configurable Statistic axis to inline arithmetic — the previous
four-axis framing collapsed to three when the framework matured.

## The metric grid

Cell × CellResult × Grid, Cartesian product of `(algorithm × share_rate
× scenario × trial)` with 1000 trials/cell by default. Paired seeding:
`base_seed = 0xDEADBEEFCAFEF00D`, per-trial seed `base_seed +
(cell_index << 20) + trial_index`. Same trial index across algorithms
shares the share-arrival sequence — cross-algorithm differences are
attributable to the algorithm alone.

| Metric | Category | What it measures |
|--------|----------|------------------|
| `convergence_time` | Behavioral | seconds to first fire-followed-by-quiet-window after cold start |
| `settled_accuracy` | Behavioral | `\|final_hashrate / true_hashrate − 1\|` |
| `jitter` | Behavioral | fires per minute under stable load post-convergence |
| `reaction_time` | Behavioral | seconds from step change to first subsequent fire |
| `bias` | Estimator | `E[H̃ − H_true] / H_true` post-settle |
| `variance` | Estimator | population variance of `H̃ / H_true` post-settle |
| `ramp_target_overshoot` | Behavioral | peak fire-target above truth during cold start |
| `reaction_asymmetry` | Robustness | `reaction_rate(+δ%) − reaction_rate(−δ%)`, δ ∈ {5,10,25,50} |
| `decoupling_score` | Cross-cutting | `reaction_rate × clamp(1 − jitter_p50 / J_max, 0, 1)` |

The white paper's primary scoring is `LogErrorRegret`: a 4-vector
`(regret_over, regret_under, effort_up, effort_down)` per scenario
class per share rate. Detection (`EXCESS`) is reported as a
rate-dependent diagnostic, not scored — measurement showed detection
is floor-saturated at production share rates.

## The Champion

```
Ewma360/s1.5 = EwmaEstimator(τ=360s)
             + AdaptiveSignPersist(spm_threshold=6)
             + AcceleratingPartialRetarget(0.2, 0.6, 0.05)
```

Selected by minimax-over-`r*` with decline-safety as a hard constraint
(`docs/SLOW_DECLINE_TEST.md`: only Champion has zero runaway cells;
classic hits +69% over-difficulty transient on a 40%/hr decline).

Hardware-confirmed *in direction* on Antminer S21 at `r* ∈ {6, 30}`:
no rejection runaway through a −50% drop. Settled-offset measurement
and slow-moderate-decline test are remaining hardware-validation
tasks.

The white paper (`docs/METRIC_DERIVATION.md`, 714 lines) derives from
Theorem 1 (`N ~ Poisson(r*τ·e^{-e})` depends on `e` alone) and
Theorem 2 (Cramér-Rao floor `Var(ê) ≥ 1/(r*τ)`) that:

> Across the operating band the field is flat (~12% best-to-worst
> spread in composite cost), residual differences are
> gentleness-and-safety not agility, and the one lever is `r*`.

§3 corollary: **accuracy and agility are bought from one budget at a
fixed rate `r*`** — which is exactly why connection-count is the
right scale axis: `r*` is set by policy at the pool, not by miners.

## Iteration history

`FINDINGS.md` walks the iterative protocol that produced FullRemedy
then AdaCUSUM then the Champion:

```
Iteration 0: ClassicComposed = CumulativeCounter + AbsoluteRatio
                              + StepFunction + FullRetargetWithClamp
Iteration 1: fix Boundary    → + PoissonCI(z=2.576)
Iteration 2: fix Estimator   → + EwmaEstimator(120s)
Iteration 3: fix UpdateRule  → + PartialRetarget(0.2)
              ⇒ FullRemedy
Iteration 4: fix Boundary    → + AdaptiveCusumBoundary(s=1.5, floor=0.05)
              ⇒ AdaCUSUM (2-3× better at small -10% declines)
Iteration 5: fix Boundary    → + AdaptiveSignPersist(spm_threshold=6)
              ⇒ Champion ramp-up: ~34 min → ~15 min;
                p99 cold-start overshoot @ SPM=6: 145% → 10% (14.5×)
                (commit 1c645bcf, "feat(vardiff): SignPersist champion
                — fix ramp-up & settle-bias", 2026-06-18)
Iteration N: white-paper-driven minimax-over-r* selection
              ⇒ Ewma360/s1.5 Champion (shipped 53924efb)
```

Each iteration identifies the bottleneck stage by per-stage diagnostics
and replaces only that stage. Stage-attributed metrics make this
possible — without them, "the algorithm got better" wouldn't decompose
into "which axis."

## What this framework explicitly does NOT cover

- **No connection-count axis**. Grid is `algorithm × share_rate ×
  scenario` — one virtual miner per trial.
- **No share-validation cost model**. Shares are counted
  (`Vardiff::add_shares(n)`) but never validated. No SHA, no target
  check, no PoW.
- **No network layer**. No TCP, no Noise, no SV2 framing, no tokio, no
  async runtime. Single-process algorithm-step driver.
- **No pool-side state**. No accounting beyond per-trial counter, no
  payouts, no template distribution.
- **No multi-worker connections**. §9.4 of the paper says "the model
  assumes one worker per connection."
- **No marginal cost `c` per extra share**. §6 of the white paper
  flags this as "the one external-economics input the simulation
  cannot supply" — a connection-scale harness IS the experiment that
  produces `c`.

The gap is exactly the user's premise: **gimballock characterized the
controller; a scale-test harness characterizes the plumbing**.

## What to reuse verbatim

Translation patterns for the connection-scale harness:

- **Cargo workspace structure** — own workspace, isolated `Cargo.lock`,
  parent path-deps in.
- **Cell × CellResult × Grid Cartesian product** — replace algorithm
  axis with `(implementation, connection_count, workload_pattern)`.
  `Grid::run_paired` semantics carry over.
- **`base_seed = 0xDEADBEEFCAFEF00D` + paired seeding** — reproducible
  across machines and time.
- **TOML baseline + `#[ignore]`-d slow regression test** — TOML
  structured, markdown human-review, PR review is the gate.
- **Per-tick Poisson share-arrival sampling** — Knuth (λ < 30) or
  normal approx (λ ≥ 30). One stream per virtual connection.
- **Hand-rolled XorShift64 + Poisson/exponential samplers** — avoid
  `rand` for cross-version reproducibility.
- **`Phase::{Hold, Ramp, Stall}` DSL** for HashrateSchedule — build
  `ConnectionSchedule` over time the same way.
- **`Trial` carries the seed** — a failing trial reproduces via a
  single-trial reproducer binary. Build a `trace-trial`-equivalent.
- **Bootstrap percentile CI** with separate `CI_SEED` so CI doesn't
  perturb trial reproducibility.
- **`Metric` trait + registry** — plug new metrics (handshake latency,
  fd count, RSS, task queue depth, validation CPU per share) into the
  same registry shape.
- **Stage-attributed metrics** — decompose pool-side load into
  (network IO, framing, validation, accounting) so a regression is
  attributable to one tier.

## Raw source files

- `raw/repos/2026-06-24-path1-gimballock-vardiff-sim-overview.md`
- `raw/repos/2026-06-24-path1-gimballock-sim-crate-layout.md`
- `raw/repos/2026-06-24-path1-gimballock-sv2apps-deploy.md`
- `raw/papers/2026-06-24-path1-gimballock-design.md`
- `raw/papers/2026-06-24-path1-gimballock-findings.md`
- `raw/papers/2026-06-24-path1-gimballock-metric-derivation.md`
- `raw/papers/2026-06-24-path1-gimballock-theory.md`
- `raw/notes/2026-06-24-path1-gimballock-ckpool-investigation.md`
- `raw/notes/2026-06-24-path1-gimballock-pid-investigation.md`
- `raw/notes/2026-06-24-path1-gimballock-slow-decline.md`

## See also

- [[vardiff decoupling]] — what the decoupling_score measures and why it justifies the connection-axis scale test
- [[simulator architecture]] — the scale-test design that fills this framework's gap
- [[the bottleneck thesis]] — central premise; informed by §3 corollary
