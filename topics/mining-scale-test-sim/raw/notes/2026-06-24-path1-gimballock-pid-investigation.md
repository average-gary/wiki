---
title: "gimballock notes — PID controller investigation (Pow2-PID and well-tuned PID)"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/PID_INVESTIGATION.md
source_branch: vardiff/simulation-framework
type: notes
ingested: 2026-06-24
quality: 4
confidence: high
tags: [vardiff, simulation, gimballock, pid, accelerating-partial-retarget, prior-art]
---

# PID vardiff investigation

206-line investigation. Tests the PID controller pattern used by
some open-source pool implementations (operating in difficulty-space
with power-of-2 quantization). The investigation concludes PID
fundamentally cannot match the three-stage pipeline, but extracts
one transferable idea (`AcceleratingPartialRetarget`).

## The Pow2-PID pattern (common in OSS pools)

Uses the `pid` crate (v4.0.0):
- Setpoint: shares per minute (typically 10.0)
- Kp: `-difficulty × 0.01` (negative — over-target SPM → lower difficulty)
- Ki: 0.0 (disabled)
- Kd: 0.0 (disabled)
- Output limit: `difficulty × 10.0`
- Quantization: `nearest_power_of_2()` on every retarget
- Interval: 120s (configurable)
- Window: 20-60s sliding window of share timestamps
- On retarget: rebuilds PID with gains proportional to new difficulty

### Critical flaw: power-of-2 dead zone

Quantization creates a ~41% dead zone. For difficulty to change, PID
output must push past geometric midpoint between adjacent powers of 2:
```
|pid_output| > 0.414 × current_difficulty
With Kp = -0.01 × diff:
  |SPM_target - realized| > 41.4
```

At SPM target of 10, realized SPM must exceed ~51 or drop to ~0 to
trigger a retarget. **Hashrate changes of ≤5× go undetected.**

### Simulation results

Across all 50 cells (5 SPM × 10 scenarios), Pow2-PID:
- Reaction rate: **0.000** — never fires on any step ≤ ±50%
- Jitter: **0.000** — never fires at all
- Effectively a fixed-difficulty system

## Why PID fails: lack of stage separation

A PID controller conflates all three pipeline stages:

| PID Term | Conflated Stages | Problem |
|---|---|---|
| P (proportional) | Estimator + Boundary | Kp simultaneously controls how noisy the belief is AND how much deviation triggers action. Tuning Kp for low jitter (small gain) kills reaction; tuning for fast reaction (large gain) causes noise-driven fires. |
| I (integral) | Boundary persistence + Update magnitude | Accumulates sub-threshold error (a boundary concern) but adds directly to control signal (an update concern). Anti-windup limits clamp both. |
| D (derivative) | Estimator smoothing + Update damping | Acts as both noise filter on measurement AND damping on actuator. Cannot tune independently. |

### The dead zone as stage confusion

In the three-stage framework, the 41% dead zone is clearly a *boundary*
problem. But in PID, the dead zone arises from interaction of:
1. Gain magnitude (estimator/boundary concern)
2. Quantization rounding (post-update concern)
3. Output limit (update concern)

Because these aren't separated, the developer cannot identify "the
boundary is too wide" as root cause.

### The well-tuned PID (`pid_tuned.rs`)

`PidTunedVardiff` with all three terms active:
- Rate-aware gain scheduling (`√SPM` noise scaling)
- Anti-windup with exponential decay + hard clamp
- Dead zone to suppress noise-driven fires
- Configurable presets (balanced, aggressive, conservative)

Even tuned, it cannot escape the fundamental coupling. The dead zone
(boundary) interacts with integral accumulation (persistence) which
interacts with gain schedule (estimator). Tuning one shifts the others.

## What PID revealed

Decomposing PID into the three-stage pipeline let each idea be
evaluated **in isolation** — something monolithic PID cannot do.
Three candidates extracted; one survived.

### 1. Integral term → `AcceleratingPartialRetarget` *(TRANSFERRED)*

PID's integral accelerates correction when error persists in one
direction. Our `PartialRetarget(η=0.2)` always moves 20% regardless
of history. `AcceleratingPartialRetarget`: η ramps `0.2 → 0.4 → 0.6`
on consecutive same-direction fires.

**Parameter sweep:** `acceleration=0.2, eta_max=0.6` is optimal.
Convergence improved 9-40% across SPM=6-30. Jitter: zero cost.

This transferred cleanly because it addresses a concern within a
single stage (update-rule magnitude over time). No cross-stage
calibration involved. **Now in production** as part of the champion
composition.

### 2. SPM-space operation → `SpmRatioEstimator` *(DISCARDED)*

PID operates on `realized_spm` directly. `SpmRatioEstimator`
mirrored: EWMA on raw SPM, then `h_estimate = current_h ×
(realized/expected)`.

Initial result: indistinguishable from `EwmaEstimator` on head-to-head.
Re-evaluation: further scenarios exposed regressions the
paired-simulation harness initially missed. Retained as experimental
alternative; not in any production composition.

### 3. Sub-threshold persistence → `SignPersistenceCusumBoundary` *(DISCARDED)*

In PID, errors below the dead zone still accumulate in the integral.
`SignPersistenceCusumBoundary`: when deviation sign persists across
ticks, threshold decreases slightly.

Initial: +6% detection rate on ±10% steps at +23% jitter on stable.
Re-evaluation: jitter penalty outweighed detection gain across the
full grid; tuning attempts couldn't move the Pareto frontier.

### Meta-observation

Decomposition into three stages is what *made the failure modes
visible*. Two of three extracted ideas looked promising in narrow
tests and were ultimately rejected only because each could be
exercised on its own boundary/estimator/update axis without
confounding the others. PID's monolithic structure offers no such
diagnosis — its dead zone, gain schedule, and integral windup all
interact, so a failing parameter sweep gives no actionable signal.

## Speculative composition (not adopted)

```rust
Composed::new(
    SpmRatioEstimator::new(120),
    AsymmetricCusumBoundary::new(1.5, 0.05, 3.0),
    AcceleratingPartialRetarget::new(0.2, 0.6, 0.2),
    min_allowed_hashrate,
    clock,
)
```

Head-to-head (1000 trials, 8 SPM × 10 scenarios): ~2 min slower
cold start for 2-3× better steady-state accuracy. Looked favorable
initially, abandoned once `SpmRatioEstimator` and
`SignPersistenceCusumBoundary` were independently rejected.

## Files added

Production:
- `composed/update.rs` — `AcceleratingPartialRetarget`

Experimental/reference:
- `pow2_pid.rs` — reference Pow2-PID
- `pid_tuned.rs` — well-tuned PID (P+I+D active)
- `composed/estimator.rs` — `SpmRatioEstimator` (discarded, kept for reference)
- `composed/boundary.rs` — `SignPersistenceCusumBoundary` (discarded, kept)

## Implications for scale testing

The PID investigation is methodologically relevant to a connection-scale
harness for two reasons:

- **"Decompose to diagnose" works.** Each PID-derived idea could be
  evaluated on its own axis (estimator, boundary, update) because
  the three-stage framework separated concerns. For a connection-scale
  harness, the analogous separation is (network IO, protocol framing,
  share validation, channel accounting). A regression in any one
  must be attributable.
- **Don't tune a monolith.** PID's dead zone, gain schedule, and
  integral windup all interact, so a failing parameter sweep gives
  no actionable signal. If a connection-scale harness puts
  Noise+framing+validation all behind one knob, the same problem
  appears.
- **Power-of-2 quantization matters.** Difficulty moves in powers
  of 2 — this is a real production constraint the sim respects, and
  is one source of the irreducible jitter (toggling across a quantum
  boundary). A scale-test harness modeling pool-side accounting
  should keep this constraint in mind for realistic share weight.
