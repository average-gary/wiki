---
title: "A conservation-law theory of vardiff quality — THEORY.md"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/THEORY.md
source_branch: vardiff/simulation-framework
type: paper
ingested: 2026-06-24
quality: 4
confidence: high
tags: [vardiff, simulation, gimballock, theory, conservation-law, lq-tracking, cramer-rao]
---

# THEORY.md — a conservation-law theory of vardiff quality

The 1021-line design note. Status (gimballock's own framing):
"design note / proposal. No code in this crate implements the metrics
below yet. The intent is to decide whether this framing should replace
the six-axis `EqualWeightFitness` radar."

This is the predecessor to the production-shipped white paper
(`METRIC_DERIVATION.md`). THEORY.md proposes the conservation-law
framing and **tries to break its own theory** (§5 Holes). The
white paper is the rigorous version after the broken pieces were
identified and replaced.

## §1. The plant is one identity

Strip `run_trial_with_observer` to its mechanics:
- Algorithm commits to estimate `H_est`, sets `D = H_est / r*`
- Sim draws `N ~ Poisson(λ)` with `λ = (H_true/H_est) · r* · (Δt/60)`
- Observed share rate vs setpoint: `r_obs / r* = H_true / H_est` (★)

**The single most important identity:** the quantity the algorithm
can observe (its share rate vs setpoint) is exactly the reciprocal of
the quantity it's trying to control (its difficulty error). There is
no separate plant output and error signal — they are the same signal.
**Every vardiff is a feedback controller whose measurement is its
tracking error.**

Natural coordinate (logarithmic, because difficulty is multiplicative
and quantized in powers of 2):
```
e(t) = log(H_est(t) / H_true(t)) = -log(r_obs / r*)
```

(★) rewrites as:
```
r_obs = r* · e^(-e)    (★★)
```

## §2. Conservation law: information rate pinned to `r*`

For a Poisson stream, the Fisher information an interval carries
about `log H_true` equals its expected count `λ`. When loop is
on-target (`e ≈ 0`, `λ ≈ r*·Δt/60`), information arrives at a
**constant rate of `r*` nats per minute — independent of `H`, of
difficulty, of miner size**. The algorithm fixes its own sensory
bandwidth by policy.

This is the conserved quantity. Cramér-Rao bound on any unbiased
estimate of `e` over effective window `τ_eff`:
```
Var(ê) ≥ 1/(r* · τ_eff)   (1)
```

Encoded in the crate as `SettledAccuracy::poisson_floor`
(`src/metrics.rs:863`).

**Quality is not free: it is bought with observation time, at a
fixed exchange rate `r*` set by policy, not by algorithmic
cleverness.**

## §3. The algebraic consequence: every axis is one trade-off

Push (1) through the four-axis decomposition:

- **Estimator (bias vs variance):** Steady error `~ 1/(r*·τ)`
  shrinks with τ; post-step lag `~ τ` grows with τ. One knob.
- **Boundary (Type I vs Type II):** A likelihood-ratio detector
  firing at evidence `log(1/α)` against step `δ` waits:
  `T_d(δ) ≈ 2·log(1/α) / (r*·δ²)   (2)`
  Jitter `= α` per unit time; reaction time `= T_d`. One ROC point.
- **Update rule (overshoot vs convergence):** Partial retarget η
  gives `e_k ≈ e_0·(1-η)^k`: convergence `∝ 1/η`, per-fire
  exposure `∝ η`. One knob.

All three are **speed vs stability**, bounded by the conserved rate
`r*`. The four-axis split is engineering-real and worth keeping for
*attribution*; informationally there is ~one knob per axis and they
all spend the same currency.

**Empirical confirmation:** commit `31a9dbc1` found "~0.55 maximin
ceiling for the three-stage architecture... small-drop reaction and
convergence trade against each other on a shared agility budget,
confirmed from four independent directions." Four unrelated
parameterizations hitting the same wall = a conservation law from
the outside.

### §3a. The magnitude-cancellation result — REFUTED

> **This subsection's conclusion is empirically false** (kept for
> instructional value — see §5.8).

Argument: pre-detection regret = `δ² · T_d`. Substitute (2):
`δ² · 2log(1/α)/(r*·δ²) = 2log(1/α)/r*`. The `δ²` cancels.
**Implication (had it been true):** every step change costs the same
integrated tracking error, so splitting reactivity into React −10%
and React −50% double-counts one conserved quantity.

§5.8 measurement refutes this: post-step regret rises ~`∝ δ²`, not
flat. Real boundaries (PoissonCI, CUSUM) are not SPRT.

## §4. The proposed objective (LQ-style)

Because regret is additive over time:
```
J = (1/T) ∫₀ᵀ (log H_est/H_true)² dt + ρ·Σ_fires (Δ log D)²
    └──── tracking regret ────────┘    └── control effort ──┘
```

- Regret term absorbs convergence + reaction + settled-accuracy +
  overshoot with model-derived weights (no hand-chosen ceilings)
- Effort term absorbs jitter + step-safety in one quadratic
- `ρ` replaces all six arbitrary ceilings with one interpretable
  Lagrange multiplier

**Normalization via the conservation law.** Minimum achievable `J`
over a scenario is set by `r*` and process-noise statistics
(Wiener/Kalman bound). Report unit-free efficiency
`E = J_optimal / J_algorithm ∈ (0, 1]`.

## §5. Holes (read this part)

The framing above is clean, which is suspicious.

### §5.1 The cost is asymmetric — symmetric `e²` is the biggest error

Commits `a1d3fa7b` (AsymmetricCusum) and `5d871ed3` ("never surprise
the miner") establish two directions are NOT equally costly:
- Tightening (`e ↑`): invalidates in-flight shares, can trigger
  timeout death spiral
- Easing (`e ↓`): old harder work still valid; nearly free

Symmetric quadratic `e²` averages this away. Real loss is asymmetric,
possibly with a barrier on the over-difficulty side. **Fix:** split
regret into over/under-difficulty halves with `w_over ≫ w_under`,
split effort into up/down fires with `ρ_up > ρ_down`.

### §5.2 The conservation law is only local — and that IS the death spiral

§2 claims information arrives at constant rate `r*`. By (★★) the
ACTUAL rate is `r* · e^(-e)`:
- Over-difficulty (`e > 0`): `r_obs` collapses → information
  STARVES exactly when you need to detect the error. Positive
  feedback. **This is the death spiral, endogenous to the Poisson
  observation model.**
- Under-difficulty (`e < 0`): `r_obs` floods → fast self-correction.

"Constant `r*`" is the conservation law AT THE SETPOINT ONLY. The
`e^(-e)` factor that makes over-difficulty harmful also makes it
harder to observe. A good objective must reward escaping the starved
region fast — plain symmetric regret under-weights this.

### §5.3 The `δ²` cancellation is fragile
### §5.4 `J_optimal` is probably not computable
### §5.5 Quantization breaks continuous LQ
### §5.6 The score is only as good as the scenario ensemble
### §5.7 Non-stationary truth

### §5.8 Validation pass results (`regret-effort.rs`, 1000 trials)

**Q1 — Is the conservation law binding? NO (true but slack).**
Settled steady-state mean-`e²` runs at 0.02-0.20× the single-tick
Poisson floor — far BELOW the one-tick floor, because estimators
average over `τ_eff ≫ 1`. The CRLB is a real lower bound but it's
**not where the cost lives**. The 0.55 maximin ceiling is NOT the
CRLB wall — it's a property of control architecture and old metric
normalization. **That plank is withdrawn.**

**Q2 — Does `δ²` cancellation hold? NO — refuted.** Post-step
regret rises monotonically and steeply with `|δ|`: production at
SPM=6 goes 0.21 (-10%) → 0.98 (-25%) → 4.58 (-50%) nats²·min,
roughly `∝ δ²`. §3a is wrong as stated. **Practical consequence:**
keep both small-step and large-step terms, weighted by *cost* not
equal rates.

**Q2′ — Directional asymmetry is real and large.** For equal `|δ|`,
drops cost ~3-4× more than rises: SPM=6 production -50% = 4.58 vs
+50% = 1.20 nats²·min. Drop regret >99% over-difficulty,
rise regret >97% under-difficulty. **Strongest-confirmed part of
the theory:** the directional structure of `r_obs = r*·e^(-e)`
shows cleanly in data.

**Q3 — Inconclusive from this pass.** Cold-start regret dominates
aggregate; workload-weighted.

## §6+. Subsequent sections (~700 more lines)

The remaining sections refine the framing toward what shipped in
`METRIC_DERIVATION.md`:
- Linear `|e|` norm instead of `e²` (the white paper §4 Lemma)
- Direction-split regret (`regret_over` ≫ `regret_under`)
- Linear `Σ|s|` effort term (closes churn blind spot)
- Detection separated as rate-dependent diagnostic
- Per-class, per-share-rate, never pooled (minimax over `r*`)

## Position relative to METRIC_DERIVATION.md

THEORY.md is the messy thinking from which the white paper was
distilled. The white paper carries the survivors:
- Theorem 1 (observable depends only on `e`) — survived
- Theorem 2 (information floor `1/(r*τ)`) — survived as the
  CRLB structural floor
- The conservation law's binding claim — refuted by §5.8
- Symmetric `e²` regret — replaced by linear `|e|` (§4 Lemma)
- LQ efficiency `E = J_opt/J` — abandoned (`J_opt` not computable)
- `δ²` cancellation — refuted
- Directional asymmetry — promoted to §6 of the white paper

The disciplined thing about gimballock's process is that THEORY.md
is *checked in*, not deleted: it's the visible record of how the
shipped metric was selected by killing weaker premises first. The
white paper acknowledges this in §8.1 "three premises drawn and
killed" — but THEORY.md carries the broader killed-premise record.

## Implications for scale testing

THEORY.md is more conceptual than the white paper, but two of its
formulations are useful frames:

- **"Every vardiff is a feedback controller whose measurement is
  its tracking error."** This is the seam where a connection-scale
  harness can intervene cleanly: replacing `Vardiff` is one trait
  swap; the harness can run a "do-nothing" vardiff (fixed difficulty)
  alongside the real one and compare server-side load.
- **`r_obs = r* · e^(-e)` makes share volume per-connection a
  function of error.** For a scale-test harness modeling N
  connections, the steady-state per-connection volume is `r*` but
  during transients it can spike. A spike across N connections is
  the worst-case load the pool must absorb — and §5.2's "constant
  `r*` only at the setpoint" warning means transients matter.
- **`τ_eff ≫ 1 tick`** is what makes the CRLB slack in practice.
  This is the reason a scale-test harness needs many minutes of
  simulated time per scenario to be representative of steady state.
