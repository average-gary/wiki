---
title: "gimballock vardiff simulation framework — FINDINGS.md (Iteration 0→N derivation)"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/FINDINGS.md
source_branch: vardiff/simulation-framework
type: paper
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, simulation, gimballock, findings, full-remedy, ada-cusum, derivation]
---

# FINDINGS.md — how we arrived at FullRemedy (and then AdaCUSUM)

The 310-line characterization document. Iteration-by-iteration
derivation of the algorithm composition, starting from the production
incumbent (ClassicComposed) and fixing one pipeline stage per step.

## Iteration protocol

Starting from production:
1. Identify the bottleneck stage using per-stage metrics
2. Replace ONLY that stage with a better implementation
3. Verify the fix improves the target metric without regressions
4. Repeat until no single-stage change yields further improvement

Each iteration: 1000 trials/cell, `base_seed = 0xDEADBEEFCAFEF00D`,
paired seeding (cross-algorithm differences attributable to the
algorithm alone, not the seed).

## Iteration 0: ClassicComposed baseline

`CumulativeCounter + AbsoluteRatio + StepFunction + FullRetargetWithClamp`
— fire-for-fire equivalent to the production `VardiffState`, just
introspectable.

| SPM | Selectivity | Reaction -50% | Jitter | Convergence | Overshoot p99 |
|---|---|---|---|---|---|
| 6   | 0.696 | 69.6% | 0.059 | 83.2% | 145.2% |
| 12  | 0.549 | 54.9% | 0.018 | 95.5% | 86.6%  |
| 30  | 0.336 | 33.6% | 0.002 | 99.7% | 23.4%  |
| 60  | 0.188 | 18.8% | 0.000 | 100%  | 13.8%  |
| 120 | 0.098 | 9.8%  | 0.000 | 100%  | 9.9%   |

**Diagnosis: Boundary is the bottleneck.** Selectivity degrades
monotonically with SPM (0.70 → 0.10). `StepFunction` uses a fixed
15% threshold regardless of share rate. At SPM=120, Poisson noise is
only 9% RSD, so a real −50% step produces a ~50% deviation — well
above what the boundary requires — yet the algorithm detects it only
9.8% of the time, because the `CumulativeCounter`'s window grows
with `dt` and dilutes the signal across long quiet periods.

## Iteration 1: Boundary fix (StepFunction → PoissonCI)

`CumulativeCounter + PoissonCI(z=2.576) + FullRetargetWithClamp`

| SPM | Selectivity | Reaction -50% | Jitter | Convergence | Overshoot p99 |
|---|---|---|---|---|---|
| 6   | 0.023 | 2.3%  | 0.000 | 100% | 91.9% |
| 12  | 0.073 | 7.3%  | 0.000 | 100% | 53.0% |
| 30  | 0.226 | 22.6% | 0.000 | 100% | 30.4% |
| 60  | 0.505 | 50.5% | 0.000 | 100% | 18.0% |
| 120 | 0.866 | 86.6% | 0.000 | 100% | 11.7% |

High-SPM detection fixed (0.098 → 0.866); low-SPM detection
**destroyed** (69.6% → 2.3%). The PoissonCI threshold at low SPM
+ short window is ~118%; the cumulative-counter's noisy single-window
estimate rarely exceeds it on a real -50% step.

**Diagnosis: Estimator is the new bottleneck.** Single-window
estimates are too noisy at low SPM. Need smoothing.

## Iteration 2: Estimator fix (CumulativeCounter → EwmaEstimator(120s))

`EwmaEstimator(120s) + PoissonCI(z=2.576) + FullRetargetWithClamp`

| SPM | Selectivity | Reaction -50% | Jitter | Convergence | Overshoot p99 |
|---|---|---|---|---|---|
| 6   | 0.745 | 86.9% | 0.070 | 99.9% | 106.2% |
| 12  | 0.803 | 91.8% | 0.062 | 100%  | 57.4%  |
| 30  | 0.993 | 99.3% | 0.037 | 99.9% | 33.8%  |
| 60  | 1.000 | 100%  | 0.019 | 100%  | 23.4%  |
| 120 | 1.000 | 100%  | 0.005 | 100%  | 15.8%  |

Detection restored across all SPM. But two regressions:
1. Jitter rose (0.000 → 0.070 at SPM=6) — the EWMA estimate drifts
   slightly under stable load.
2. Overshoot p99 exploded (91.9% → 106.2%) — `FullRetargetWithClamp`
   jumps to the EWMA estimate, which can transiently overshoot
   during cold-start ramp.

**Diagnosis: UpdateRule is the new bottleneck.** `FullRetargetWithClamp`
is too aggressive for the smoothed estimator.

## Iteration 3: UpdateRule fix → FullRemedy

`EwmaEstimator(120s) + PoissonCI(z=2.576) + PartialRetarget(0.2)`

| SPM | Selectivity | Reaction -50% | Jitter | Convergence | Overshoot p99 |
|---|---|---|---|---|---|
| 6   | 0.877 | 87.7% | 0.034 | 100%  | 10.0% |
| 12  | 0.974 | 97.4% | 0.028 | 100%  | 5.9%  |
| 30  | 1.000 | 100%  | 0.016 | 99.8% | 0.7%  |
| 60  | 1.000 | 100%  | 0.006 | 99.9% | 0.0%  |
| 120 | 1.000 | 100%  | 0.000 | 99.9% | 0.0%  |

All metrics improve or hold. Step correction = 0.176 at SPM=6
(approximately η=0.2, confirming the rule behaves as designed).

## Three-fix summary

| Step | Stage | Key metric | Before → After |
|---|---|---|---|
| 0→1 | Boundary | Reaction at SPM=120 | 9.8% → 86.6% |
| 1→2 | Estimator | Reaction at SPM=6 | 2.3% → 86.9% |
| 2→3 | UpdateRule | Overshoot p99 at SPM=6 | 106.2% → 10.0% |

Ordering is forced: a rate-blind boundary masks all other problems
at high SPM, so it must be fixed first. PartialRetarget with a noisy
estimator would oscillate, so the estimator must be fixed before the
update rule. The update rule's failure mode (overshoot) only manifests
when the algorithm fires frequently during transients.

## Iteration 4: AdaCUSUM (the next iteration)

`EwmaEstimator(120s) + AdaptiveCusumBoundary(s=1.5, floor=0.05) + PartialRetarget(0.2)`

Diagnosis from FullRemedy: under the `operational_fitness` metric
(weights small-change detection at 30%), `PoissonCI` treats each tick
independently; a -10% decline produces a persistent across-ticks
signal that PoissonCI's per-tick test misses. `AdaptiveCusumBoundary`
accumulates evidence sequentially (threshold scales as `1/n_ticks`);
the rate-adaptive `sqrt(SPM/30)` term keeps it conservative at low SPM.

**Operational fitness across SPM=6-30 (1000 trials/cell):**

| SPM | FullRemedy | AdaCUSUM | Δ |
|---|---|---|---|
| 6   | 0.746 | 0.795 | +4.9% |
| 8   | 0.752 | 0.806 | +5.4% |
| 10  | 0.768 | 0.807 | +3.9% |
| 12  | 0.777 | 0.802 | +2.5% |
| 15  | 0.784 | 0.801 | +1.7% |
| 20  | 0.793 | 0.799 | +0.6% |
| 25  | 0.802 | 0.823 | +2.1% |
| 30  | 0.801 | 0.828 | +2.7% |

**Small-change (-10%) detection:**

| SPM | FullRemedy | AdaCUSUM |
|---|---|---|
| 6  | 33% | 85% |
| 8  | 30% | 75% |
| 10 | 33% | 67% |
| 12 | 34% | 61% |

AdaCUSUM detects 10% hashrate declines 2-3× more reliably than
FullRemedy. The primary operational value: catching failing ASICs,
thermal throttling, firmware issues before they accumulate into
revenue loss.

## The `operational_fitness` metric

```
fitness = 0.30 × reaction_rate(-10%)        [small-change detection]
        + 0.20 × reaction_rate(-50%)        [large-change detection]
        + 0.20 × clamp(1 - jitter/0.30, 0, 1) [share stability]
        + 0.20 × convergence_rate           [cold-start reliability]
        + 0.10 × (1 - overshoot_p99)        [ramp safety]
```

Jitter ceiling 0.30 fires/min (~18 retargets/hour). Retargets are
cheap (one ~50-byte message, no work disruption); missed declines
are expensive (delayed failure detection, wasted infrastructure).

Note: by the time the white paper (`METRIC_DERIVATION.md`) was
written, this composite was retired in favor of the log-error
regret/effort vector, with detection demoted to a rate-dependent
diagnostic — because measurement showed `operational_fitness`
saturates at production rates. AdaCUSUM was then revisited in
the §8/§9 minimax analysis and the **current champion is
`Ewma360/s1.5`** (`EwmaEstimator(360s) + AdaptiveSignPersist(spm_threshold=6) + AcceleratingPartialRetarget(0.2, 0.6, 0.05)`),
selected by minimax-over-`r*` with decline-safety as a hard constraint.

## Implications for scale testing

The "fix one stage, measure, repeat" methodology is a useful
template for a connection-scale harness:

- Iteration 0: baseline against current pool — number of connections
  supported with default config
- Iteration 1: fix the bottleneck (TCP backlog, fd ulimit, Noise CPU,
  async-runtime task count, ...) — measure
- Iteration N: each stage has its own metrics

The metric grid (per algorithm × per share rate × per scenario, 1000
trials, TOML baseline regression) is the pattern to reuse. For
connection-scale, the equivalent grid would be
`(implementation) × (connection_count) × (workload_pattern)`.
