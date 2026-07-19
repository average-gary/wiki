---
title: "gimballock notes — porting ckpool's dsps EMA + adaptive window switching"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/CKPOOL_INVESTIGATION.md
source_branch: vardiff/simulation-framework
type: notes
ingested: 2026-06-24
quality: 4
confidence: high
tags: [vardiff, simulation, gimballock, ckpool, ema, per-share-evaluation, prior-art]
---

# Ckpool vardiff investigation

344-line investigation. Ports [ckpool](https://github.com/ckolivas/ckpool)
(Con Kolivas's Stratum V1 pool) vardiff to the SV2 three-stage pipeline.
Reference: a Rust reimplementation by @paratoxicdev at
`parasitepool/para/blob/master/src/vardiff.rs`.

## What ckpool does

Core: **exponentially-decaying shares-per-second (`dsps`)** EMA
updated on every share submission via `decay_time()`:
```c
fprop = 1 - e^(-elapsed / interval)
f += (share_diff / elapsed) * fprop
f /= (1 + fprop)
```

Five parallel EMAs with time constants (1m, 5m, 1h, 1d, 1w) per client.

**Adaptive window switching:** when shares flood in (`ssdc >= 72`),
the 1-minute EMA is used (fast ramp-up). Otherwise the 5-minute EMA
provides conservative steady-state tracking. Threshold `72 = 240s / 3.33s`
(80% of long window at target).

**Hysteresis band:** no retarget if `drr = dsps / current_diff` falls
in `[0.15, 0.4]` around target 0.3. Band is asymmetric: 0.5× below,
1.33× above target.

**Oscillation guard:** suppress difficulty decrease if only 1 share
observed since last change.

**Time-bias warmup correction:** `bias = 1 - e^(-elapsed/period)`
compensates for EMA suppression when client active less than one
full window period.

## Port attempt 1: direct translation — CATASTROPHIC

Batch EMA + time-bias correction:
- Hysteresis band too wide for 60s-tick evaluation
- Settled accuracy 59-73% at SPM 6-12; overshoot 100-200%

## Port attempt 2: CkpoolRemedy (ckpool estimator + FullRemedy boundary/update)

Also bad: settled accuracy 177-275%, overshoot 350-427%.

**Root cause:** time-bias was calibrated for per-share evaluation
(~3.33s intervals). In the tick framework, `dt` after a fire is
always 60s. With τ=300s:
```
time_bias(60, 300) = 1 - e^(-0.2) ≈ 0.18
correction = rate / 0.18 = rate × 5.5
```
This amplification is the overshoot source: EMA is naturally low
after a fire (one tick of data), dividing by 0.18 inflates it 5.5×.

## The fix: per-share `decay_time()` simulation within snapshot()

When N shares arrive in a 60s tick, run N individual `decay_time()`
calls with `elapsed = 60/N` seconds each. Faithfully reproduces what
ckpool's EMA would have seen.

**Result:** completely fixed. Settled accuracy 177% → 4.6-7.5%
(matching FullRemedy); overshoot 350% → 0-9%.

**Lesson.** When porting a continuous-time algorithm to a
discrete-time framework, simulate the original update cadence within
each tick — don't apply a time-domain correction factor. The
`on_fire()` feedback mechanism lets the estimator know when retargets
happened and simulate share arrivals accordingly.

## Comprehensive comparison at SPM 4-5

| Variant | Reaction -50% | Accuracy p50 | Overshoot p99 | Jitter | Fitness |
|---|---|---|---|---|---|
| FullRemedy | 70 / 82% | 7.6 / 7.4% | 7.7 / 7.1% | 0.042/0.032 | **0.691/0.732** |
| Ck-cusum-eta20 | **96 / 98%** | 9.3 / 9.1% | 24.5 / 15.1% | 0.158/0.140 | 0.612/0.644 |
| Ck-tl120-eta20 | 67 / 77% | 9.7 / 7.4% | 20.1 / 19.3% | 0.065/0.057 | 0.656/0.675 |
| CkpoolRemedy | 55 / 53% | 9.1 / 7.7% | **0 / 0%** | **0.009/0.031** | 0.679/0.682 |
| VardiffState | **99 / 99%** | 12.3 / 11.8% | 44.4 / 32.4% | 0.143/0.118 | 0.626/0.658 |
| AdaCUSUM η=0.2 | **99 / 99%** | 8.4 / 6.4% | 29.5 / 28.2% | 0.220/0.192 | 0.633/0.662 |

## Key findings

1. **Boundary is the decisive axis.** CUSUM gives 96-99% reaction at
   3-5× jitter; PoissonCI gives low jitter at 67-77% reaction. No
   ckpool estimator tuning escapes this.
2. **Shorter τ_long (120s) helps more than lower fast-threshold.**
   Once long-window EMA is responsive enough, dual-window switching
   becomes redundant.
3. **Higher η degrades everything except reaction.**
4. **CkpoolRemedy (default `ft=72`) achieves zero overshoot** because
   long-window EMA (τ=300s) dampens cold-start so aggressively the
   target never overshoots truth — at the cost of killing reaction
   rate (55% at SPM 4).

## Hysteresis boundary sweep

Across band widths from [0.5, 1.33] (native) to [0.9, 1.1] (narrow),
with data gates of 2/4/6 shares:
- No hysteresis parameterization achieved competitive comprehensive
  fitness
- Narrowing improves reaction dramatically (Hyst [0.8, 1.2] achieves
  96-100% reaction — better than any statistical boundary) but jitter
  explodes to 0.15-0.32 fires/min vs 0.03/min for PoissonCI
- Fundamental issue: hysteresis fires whenever the rate ratio crosses
  the band threshold with NO evidence accumulation
- Statistical boundaries (PoissonCI, CUSUM) distinguish real changes
  from noise by requiring cumulative evidence

## Estimator equivalence (revised)

Initial claim: `CkpoolEstimator` (per-share `decay_time()`) and
`EwmaEstimator(120s)` are equivalent. True under PoissonCI +
PartialRetarget (~5% fitness gap).

Under the production-tuned `AdaptivePoissonCusum(10) +
AcceleratingPartialRetarget(0.2, 0.4, 0.2)`:

| Composition | SPM 4 | SPM 8 | SPM 12 | SPM 20 | SPM 30 |
|---|---|---|---|---|---|
| EWMA(120) + AdpBnd + AccelRet (production) | 0.689 | 0.768 | 0.787 | 0.882 | 0.869 |
| CkpoolEstimator(60,300) + same | 0.698 | 0.638 | 0.696 | 0.777 | 0.858 |
| CkpoolEstimator(60,120) + same | 0.598 | 0.688 | 0.764 | 0.805 | 0.858 |

ckpool estimator underperforms EWMA(120s) significantly at mid-SPMs
(0.638-0.696 vs 0.768-0.787). Jitter 2-3× higher; reaction at low
SPM drops to 48-57% (vs 73-94%).

**Root cause:** per-share `decay_time()` runs N separate EMA decay
steps per tick. Each step introduces rounding and uniform inter-share
spacing adds variance. Single batch EWMA update is numerically
cleaner. Under aggressive CUSUM, the ckpool estimator's per-tick
noise triggers more false fires.

**Revised conclusion on evaluation cadence:** the original claim "the
evaluation cadence is just scheduling, not information" was too
strong. While information content of N shares in T seconds is
identical regardless of cadence, **numerical stability** of the
estimate depends on how that information is processed.

## What transfers and what doesn't

**Transfers:**
- Per-share `decay_time()` simulation technique
- Oscillation guard principle (though PartialRetarget η=0.2 makes it
  redundant)

**Does not transfer:**
- Time-bias warmup correction (calibrated for per-share evaluation)
- Wide hysteresis band [0.5, 1.33] (too wide for 60s ticks)
- Dual-window adaptive switching (once τ_long=120s, single EWMA(120s)
  achieves the same balance)
- Share-count data gate (72 shares) — meaningless in tick framework

## Production recommendation (current as of this doc)

```rust
Composed::new(
    EwmaEstimator::new(120),
    AdaptivePoissonCusum::new(10),
    AcceleratingPartialRetarget::new(0.2, 0.4, 0.2),
    min_allowed_hashrate,
    clock,
)
```

(Note: this was later superseded by the champion `Ewma360/s1.5` —
`EwmaEstimator(360) + AdaptiveSignPersist(spm_threshold=6) +
AcceleratingPartialRetarget(0.2, 0.6, 0.05)` — selected by the
white paper's minimax-over-`r*` with decline-safety constraint.)

## Files added

Production components (`src/vardiff/composed/`):
- `estimator.rs` — `CkpoolEstimator`, `TimeBiasEwmaEstimator`
- `boundary.rs` — `HysteresisGate`
- `update.rs` — `CkpoolRetarget`

Grid registrations (`sim/src/grid.rs`):
- `AlgorithmSpec::ckpool()`, `ckpool_remedy()`, `ckpool_remedy_ft(n)`,
  `ckpool_narrow_hyst()`, `ckpool_with(τs, τl, lo, hi)`,
  `time_bias_remedy()`

## Implications for scale testing

This investigation is a clean case study in **how prior-art port-and-test
works in a deterministic harness.** Lessons for a connection-scale
harness:

- **Test the port, don't assume the original tuning carries.** ckpool's
  parameters were optimized for per-share evaluation; they collapsed
  at tick cadence. A scale-test harness reusing prior-art load
  shapes (e.g., JMeter scripts, ckpool's connection patterns) should
  re-tune from scratch.
- **The integration mechanism matters as much as the algorithm.**
  Per-share vs per-tick is the difference between
  "behaviorally-indistinguishable" and "5.5× catastrophic overshoot."
  For a scale-test harness, "per-message" vs "per-second" load
  shaping is the analogous concern.
- **Boundary is the load-bearing axis.** Across every variant tested,
  the boundary's reaction-vs-jitter trade-off dominated. For
  connection-scale testing the analogous load-bearing axis is
  *probably* the share-validation path (CPU + accounting cost per
  share), which the gimballock framework does NOT touch.
