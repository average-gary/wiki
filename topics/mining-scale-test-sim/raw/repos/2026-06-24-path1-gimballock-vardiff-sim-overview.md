---
title: "gimballock vardiff simulation framework — overview and commit narrative"
source_url: https://github.com/marafoundation/stratum/tree/vardiff/simulation-framework/sv2/channels-sv2/sim
source_branch: vardiff/simulation-framework
type: repo
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, simulation, gimballock, mining-scale-test, sv2, stratum, marafoundation]
---

# gimballock's vardiff simulation framework

A deterministic in-process Rust harness in `sv2/channels-sv2/sim/`
(its own Cargo workspace, ~2350 line `grid.rs` + ~4570 line `metrics.rs`,
plus 8 long docs and ~46 binaries) for characterizing the behavior of
any `Vardiff` implementation in the SRI `channels_sv2` crate.

- Repo: `marafoundation/stratum` (a fork of `stratum-mining/stratum`)
- Branch: `vardiff/simulation-framework`
- HEAD: `b73125dd` (52 commits ahead of `main`, 113 files changed)
- All sim work under `sv2/channels-sv2/sim/`
- Production vardiff work under `sv2/channels-sv2/src/vardiff/`
- CI: `.github/workflows/vardiff-sim.yaml` runs fast tests + slow
  baseline regression on PRs that touch the sim or vardiff code

## Summary

gimballock (Eric Price) built a glass-box simulation harness that
characterizes a vardiff algorithm — the controller every Stratum pool
runs to keep each connection's share rate near a target like 6 SPM —
as a deterministic distribution over (algorithm × share-rate ×
scenario × trial). The harness is in-process Rust, not network-driven:
no real connections, no real shares, no Stratum framing. Share arrival
is modeled as `n_shares ~ Poisson(λ)` per simulated 60-second tick.
The framework is sophisticated enough that it produced a published
white paper (`docs/METRIC_DERIVATION.md`) deriving — from a Cramér-Rao
information bound — that across the operating share-rate band every
reasonable vardiff is pinned to the same floor, so the residual axis
is "gentleness and safety" rather than "agility," and the one lever
that moves the floor is the target share rate `r*` itself.

The simulation result was strong enough to ship the new champion as
production `VardiffState` (commit `53924efb`).

## Branch structure

| Branch | Repo | Role |
|---|---|---|
| `vardiff/simulation-framework` | `marafoundation/stratum` | the sim crate + the production algorithm work; 52 commits ahead of main; this is the upstream candidate |
| `test/vardiff-simulation-framework` | `marafoundation/sv2-apps` | deploys the stratum branch as pinned `stratum-core` for hardware validation on real testnet4 miners |

The deploy branch's commits are mostly `chore(deps): update
stratum-core to <sha>` — it carries no algorithm logic of its own;
it just pins the right stratum branch so a real pool/translator
binary embedding `channels_sv2::VardiffState` exercises the new
champion against a live Antminer S21.

## Commit narrative (~52 commits, oldest → newest)

The arc tells the whole research story:

1. **2026-05-13**: framework born
   - `771afa32` inject `Clock` trait + `add_shares` method into the
     production `Vardiff` trait so the sim can use a `MockClock`
   - `255b9bfd` "in-process simulation framework for vardiff characterization"
   - `f490ad4c` design doc + baseline characterization of current `VardiffState`
2. **2026-05-16-17**: four-axis decomposition
   - `c90cecdb` "four-axis algorithm decomposition + characterization" —
     splits any vardiff into (Estimator, Statistic, Boundary, UpdateRule)
   - `33a8db3d` pareto report, CI on rates, MD columns + first CI workflow
   - `ef2eb2e6` "promote four-axis `composed/` from sim to production" —
     the sim crate's abstractions move into the production crate; the
     sim becomes the consumer rather than the inventor of those types
   - `f0bda618` add top-level `default()` factory + deprecate `VardiffState::new`
   - `5f8a1465` retune `FullRemedy` default to η=0.2 + (η, z) Pareto sweep
3. **2026-05-20-21**: directional asymmetry baked in
   - `a1d3fa7b` `AsymmetricCusumBoundary` — directional cost awareness
     (commit fixes `tighten_multiplier = 3`; see §6 of the white paper)
   - `459633e7` "three-stage pipeline, AdaCUSUM algorithm, operational metrics"
   - `2a791c49` add asymmetry preference to fitness + `upward_step_magnitude` metric
   - `5d871ed3` revamp fitness weights for harm-avoidance priority
4. **2026-06-02-04**: counter-age awareness + ckpool port
   - `70fcb260` counter-age-aware algorithm evaluation
   - `6aa27a9e` ckpool algorithm investigation + per-share `decay_time` simulation
   - `15d70920` adaptive boundary — PoissonCI at low SPM, CUSUM at high SPM
   - `92a10d2f` `AsymmetricPoissonCI` boundary + parameter sweep
   - `b77eff8e` ckpool hysteresis sweep + estimator equivalence test
   - `f4cd687d` promote `EwmaEstimator` to production
5. **2026-06-08-10**: PID investigation
   - `9ad17450` "PID investigation yields `AcceleratingPartialRetarget`"
   - `81f71d2d` promote `AcceleratingPartialRetarget` to production
6. **2026-06-18-19**: theory + champion derivation
   - `412e6de5` "§10 log-error regret/effort metric + theory writeup" — the white paper
   - `5a21b0f0` regret/effort sweep, weight analysis, trajectory viz
   - `74642401` REVERT production VardiffState to the classic algorithm — measured-data discipline; the previous "champion" was retired
   - `1c645bcf` `SignPersist` champion — fix ramp-up & settle-bias
   - `f5ba4aea` WarmupBoundary primitive + cold-start warm-up negative result
   - `252e26b9` `DebiasEstimator` + settle-gap-is-optimal result
7. **2026-06-22-23**: validation, then ship
   - `7f8d662e` apply review revisions + real-hardware validation
   - `a04d1f85` slow-decline safety test — champion passes, classic spirals
   - `bda7b41c`/`4dd32954`/`3f9e97be`/`ff5c7b86` metric-correction investigation,
     floor-relative responsiveness gate, false-alarm-check correction, safety
     re-clear PASSES on corrected champion
   - `3f2048f9` minimax-over-`r*` champion selection confirms `Ewma360/s1.5`
   - `b1439a23`/`0d448b59` structural-frame paper rewrite + champion figures
   - **`53924efb`** "ship the champion as production `VardiffState`"
   - `de3a2ff4`/`b73125dd`/`20c03ad2` debug-logging for the Theorem-2 lever test
     on real hardware

## What the sim crate is and what it is not

- **In-process and deterministic.** Trials are pure compute against
  a `MockClock` (sim time) and an `XorShift64` RNG seeded from
  `(base_seed = 0xDEADBEEFCAFEF00D, cell_index, trial_index)`. Two
  runs years apart produce byte-identical output modulo `f64::ln`
  determinism across rustc versions.
- **No connections, no network, no real shares.** Share arrival is
  modeled as `n_shares ~ Poisson(λ)` per 60-second tick, with
  `λ = (true_hashrate / estimated_hashrate) × shares_per_minute × (interval_secs/60)`.
- **One miner per trial.** The framework has no connection-count axis.
  Hashrate is a `HashrateSchedule` (piecewise-constant or piecewise-linear
  step function over simulated time), not a population.
- **`Vardiff` is the only entry point.** Anything that implements
  the production `Vardiff` trait plugs in. The harness drives it
  through `try_vardiff` once per tick and records the result.
- **Production-ready outputs.** The `composed/` pipeline started in
  the sim crate and was promoted to production (`channels_sv2::vardiff::composed`).
  The sim crate now re-exports those production types and adds only
  an `Observable` extension trait for introspection.

## How the sim relates to a connection-scale harness

The gimballock framework characterizes the **algorithm**, not the
**plumbing**. For the user's connection-scale question:

- Reusable: the four-axis decomposition, the trial recording model,
  the scenario DSL, paired seeding for reproducibility, baseline
  regression via TOML comparison, the `Cell`/`CellResult`/`Grid`
  Cartesian product, the `Metric` trait + registry. These are general
  scientific-software patterns that translate to a connection-scale
  harness verbatim (replace "metric of algorithm behavior" with
  "metric of server-side load").
- Not reusable: the entire `Composed<E, B, U>` pipeline, the
  algorithm registry, the Poisson share-arrival sampler. None of
  this touches connections, TCP, Noise, or framing — it operates
  one tier above, on the abstract `Vardiff` interface.

The bridge: gimballock's claim that **at production share rates the
floor binds everyone** (§3 of `METRIC_DERIVATION.md`) is exactly the
premise of the user's scale-test wiki: vardiff clamps each connection's
share rate to `r*`, so share-validation rate is `~r* × N_connections`
regardless of underlying hashrate. The wiki's bottleneck claim —
"connection count dominates, not hashrate" — is the same observation
read from the pool's side instead of the controller's side.

## Implications for the scale-test premise

- The gimballock framework does **not** characterize share-validation
  cost or connection scaling. Its scope is "given one miner, how
  does the controller behave."
- It confirms (indirectly) that `r*` is the lever the pool operator
  controls: raising `r*` tightens detection but multiplies the
  per-connection share rate. The white paper §8.4 figure
  ("EXCESS vs `r*`") is the controller-side view of the same
  trade-off the scale-test wiki frames as "share-validation cost
  is linear in connection count at fixed `r*`."
- The deterministic per-tick Poisson sampling is the load model
  pieces a connection-scale harness should re-use: feed `Poisson(r*)`
  per virtual connection into the share-validation path.

## Files in this branch

```
sv2/channels-sv2/sim/
├── Cargo.toml              # own workspace, isolated lockfile
├── README.md
├── docs/
│   ├── DESIGN.md           # 678 lines — architectural reference
│   ├── FINDINGS.md         # 310 lines — Iteration 0..N FullRemedy derivation
│   ├── METRIC_DERIVATION.md# 714 lines — the white paper
│   ├── THEORY.md           # 1021 lines
│   ├── SLOW_DECLINE_TEST.md
│   ├── CKPOOL_INVESTIGATION.md
│   ├── PID_INVESTIGATION.md
│   └── TODO-CLI-ERGONOMICS.md
├── baseline_*.{toml,md}    # ~10 algorithm baselines (FullRemedy, EWMA, AdaCUSUM, classic, etc)
├── eta_sweep.md, ewma_tau_sweep.md, pareto.md, z_sweep.md, eta_z_joint_sweep.md, iterative_eval.md
└── src/
    ├── lib.rs              # public API + unit conventions
    ├── rng.rs              # XorShift64 + Poisson/exponential samplers
    ├── schedule.rs         # HashrateSchedule (stable/step/throttle)
    ├── trial.rs            # run_trial + TickRecord + Observable
    ├── metrics.rs          # ~4575 lines — Metric trait + registry + many metrics
    ├── baseline.rs         # Cell/CellResult/Scenario/Phase DSL + TOML serializers
    ├── regression.rs       # baseline-parsing + tolerance assertions
    ├── grid.rs             # ~2350 lines — Grid + AlgorithmSpec + VardiffBox + run_paired
    ├── naming.rs
    ├── composed.rs         # thin sim-side facade re-exporting production composed/
    └── bin/                # 46 binaries
        ├── generate-baseline.rs, compare-algorithms.rs, compare-best.rs, compare-pid.rs
        ├── sweep-{ewma-tau, eta, eta-z, adaptive, asymmetric-poisson, bayesian, bayesian-ci,
        │           regret, regret-big, signpersist*, ckool/accelerating, balanced, corrected,
        │           voladapt, estimators, minimax, z}.rs  (~22 sweeps)
        ├── confirm-{champions, debias, signpersist, warmup}.rs
        ├── slow-decline.rs, regret-effort.rs, regret-radar.rs
        ├── trace-trial.rs (single-trial tick-by-tick reproducer)
        └── ... ~46 binaries total
```
