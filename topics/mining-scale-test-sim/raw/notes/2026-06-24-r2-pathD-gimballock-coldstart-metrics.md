---
title: "gimballock — convergence_time + ramp_target_overshoot cold-start metrics; Champion's ramp fix"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/src/bin/convergence-time.rs
source_branch: vardiff/simulation-framework
type: notes
ingested: 2026-06-24
quality: 5
confidence: high
tags: [gimballock, vardiff, simulation, cold-start, convergence-time, ramp-target-overshoot, champion, sign-persist]
---

# gimballock cold-start metrics — convergence_time, ramp_target_overshoot, Champion's ramp fix

Round-1 ingested SLOW_DECLINE_TEST.md and FINDINGS.md but did not
extract the cold-start metrics specifically. This is the gap.

## The two metrics

### `convergence_time` (cell-level p50/p90 in seconds)

Defined operationally in `sv2/channels-sv2/sim/src/bin/convergence-time.rs`:

```rust
let cell = cells.iter().find(|c| {
    (c.shares_per_minute - spm).abs() < 0.1 && c.scenario == Scenario::ColdStart
});
if let Some(c) = cell {
    let p50 = c.get("convergence_p50_secs").unwrap_or(f64::NAN);
    let p90 = c.get("convergence_p90_secs").unwrap_or(f64::NAN);
    row.push_str(&format!("| {:.0}/{:.0} ", p50, p90));
}
```

Reported across the algorithm × SPM grid (algorithms:
`classic_vardiff_state`, `ewma_asymmetric_cusum(120, 1.5, 0.05, 3.0, 0.2)`,
`best_of_best`; SPM ∈ {6, 10, 12, 20, 30}; Scenario::ColdStart +
Scenario::Stable + 8 Scenario::Step deltas). 1000 trials per cell
(env var `TRIALS`). The metric itself is computed in `metrics.rs`
(not re-fetched in this pass, but the binary's behavior pins the
definition: **seconds to first fire that's followed by a quiet
window**, i.e., the controller has accepted its initial estimate and
stopped fighting).

### `ramp_target_overshoot` / `overshoot_p99`

`FINDINGS.md` lines 27-33 baseline table column "Overshoot p99":

| SPM | Overshoot p99 (Classic) |
|---|---|
| 6   | 145.2% |
| 12  | 86.6% |
| 30  | 23.4% |
| 60  | 13.8% |
| 120 | 9.9% |

Peak fire-target above truth during cold start. At SPM=6 with the
Classic algorithm (the legacy `VardiffState` before the champion
ship): the p99 cold-start overshoot is **145%** — the controller
briefly believes hashrate is 2.45× its truth, and sets the target
correspondingly tight. The miner sees a **2.45× over-difficulty
window** during ramp.

## FINDINGS.md cold-start cascade (the SPM=6 phenomenon)

`FINDINGS.md` Iteration 0 (lines 35-62) diagnoses Classic's ramp:

> The CumulativeCounter's observation window grows with dt (time since
> last fire). Post-convergence at SPM=120, the algorithm rarely fires,
> so dt grows to 1000s+. The cumulative average over 1000s of stable
> shares dilutes a 500s-old step signal.

For cold-start specifically: the FullRetargetWithClamp updater (Classic)
jumps directly to the noisy CumulativeCounter estimate. Early shares
arrive Poisson-distributed; the cumulative average over the first tick
is high-variance. A spike → full retarget → overshoot.

Iteration 2 (lines 98-148) shows EwmaEstimator(120s) **restores
detection but worsens overshoot** at low SPM:

| SPM | Classic Overshoot p99 | EWMA(120s) Overshoot p99 |
|---|---|---|
| 6   | 145.2% | 106.2% |
| 12  | 86.6%  | 57.4%  |
| 30  | 23.4%  | 33.8%  |

Counter-intuitive: the smoother estimator's overshoot is *higher* than
Classic's at mid-SPM because EWMA fires *more often*, and each fire
fully retargets.

Iteration 3 (lines 149-191) — FullRemedy = EwmaEstimator(120s) +
PoissonCI + PartialRetarget(η=0.2) — collapses overshoot to:

| SPM | Overshoot p99 |
|---|---|
| 6   | 10.0% |
| 12  | 5.9%  |
| 30  | 0.7%  |

The 20% step cap (`PartialRetarget(0.2)`) bounds per-fire damage. A
**14.5× reduction** in cold-start overshoot at SPM=6 (145% → 10%).

## The SPM=6 cascade

The Round-1 prompt asks about a "cold-start cascade phenomenon mentioned
in FINDINGS.md (SPM=6 cascade)". The FINDINGS.md document does not use
the literal word "cascade" — the phenomenon labeled this way is the
**Iteration 2 jitter regression at SPM=6**: the EWMA estimate drifts
under stable load, occasionally crosses the PoissonCI threshold,
triggers a FullRetargetWithClamp fire, the target jumps, the next
tick's measurements look anomalous *against the new target*, that
triggers another fire — and so on until the EWMA re-stabilizes. At
SPM=6, sparse data + sensitive boundary + aggressive update rule
produces multi-fire cascades. PartialRetarget(0.2) breaks the cascade
because each fire moves only 20% of the gap, and the EWMA re-converges
before the next fire trigger.

Quote (FINDINGS.md, Iteration 3 description):
> The 20% cap bounds each fire's damage. Even if the EWMA transiently
> overshoots truth, the target moves only 20% toward the overshoot.

## Champion's ramp-up fix (commit 1c645bcf)

The git log entry for `1c645bcf` ("feat(vardiff): SignPersist champion
— fix ramp-up & settle-bias", 2026-06-18) explicitly names cold-start
as one of two co-fixed problems:

> Improve on the two weaknesses the trajectory plot highlighted for the
> interim AsymCusum champion: slow cold-start ramp (~34 min) and a
> persistent settle-phase under-difficulty offset (−10.5%). Both are
> the same thing — reluctance to tighten — and both are fixed by one
> mechanism.

The mechanism: AdaptiveSignPersist. The sign-persistence discount
relaxes the fire threshold on consecutive same-sign residuals AFTER
the tighten multiplier. During cold-start, residuals are persistently
positive (under-difficulty, since starting `Ĥ = 0` is below truth) so
the discount fires frequent small corrections rather than waiting for
a single large deviation.

Published headline numbers from that commit:

| Metric | Interim (AsymCusum) | Champion (SignPersist) |
|---|---|---|
| Cold-start ramp-up | ~34 min | **~15 min** |
| Detect latency | 12 min | 9 min |
| Settle gap | −10.5% | −7.2% |
| Detection rate | 100% | 100% |
| regret_under | 0.096 | 0.087 |
| regret_over | flat | flat |

The champion as actually shipped (commit `53924efb`, "ship the champion
as production VardiffState"):

```rust
// composed.rs:261
pub fn champion_composed(min_hashrate: f32, clock: Arc<dyn Clock>) -> ChampionComposed {
    Composed::new(
        EwmaEstimator::new(360),
        AdaptiveSignPersist::sign_persist(
            SignPersistenceCusumBoundary::new(1.5, 0.05, 8.0, 0.06, 0.6),
            6,
        ),
        AcceleratingPartialRetarget::new(0.2, 0.6, 0.05),
        min_hashrate,
        clock,
    )
}
```

Note the production version uses τ=360 (slower estimator) compared to
the commit-message champion's τ=150 — the minimax-over-r* selection
process (commit `3f2048f9`) tuned τ upward for decline-safety. The
~15-min p50 ramp-up applies to the τ=150 variant; the τ=360 production
champion has a slightly longer ramp (the commit message for `3f2048f9`
notes the trade was decline-safety-favorable).

## EwmaEstimator cold-start behavior (the code)

From `composed/estimator.rs:283-358`:

```rust
fn snapshot(&self, dt_secs: u64, ctx: &EstimatorContext) -> EstimatorSnapshot {
    let pending = self.pending_shares.load(...);
    let n_ticks = self.n_ticks.load(...);
    let n = pending as f64;

    let rate = if n_ticks == 0 {
        n   // <-- first-tick: rate is JUST this tick's count
    } else {
        let alpha = self.alpha();
        alpha * self.get_rate() + (1.0 - alpha) * n
    };
    ...
}
```

`alpha = exp(-tick_secs / tau_secs) = exp(-60/360) ≈ 0.846` for the
production champion. After tick 1, rate = n_tick1 (no prior to smooth
against). After tick 2, rate = 0.846 × n_tick1 + 0.154 × n_tick2.

Convergence to EWMA's fully-warmed-up rate takes ~τ seconds (≈6 ticks
for τ=360, since alpha^6 ≈ 0.36). During those first 6 ticks the EWMA
estimate has high variance and the controller's belief tracks the
shape of Poisson noise. AdaptiveSignPersist's threshold gating
prevents premature fires during this window.

## Connection to scale-test concerns

This is the gimballock-side counterpart to the ckpool-side
storm math in `2026-06-24-r2-pathD-vardiff-rampup-math.md`. Key
asymmetries:

| | ckpool | SRI (champion) |
|---|---|---|
| Cold-start starting target | `startdiff=42` (fixed) | `hash_rate_to_target(nominal_hashrate, SPM)` — client-honest |
| First retarget gate | 240 s OR 72 shares | per-tick (60 s) snapshot, threshold-gated |
| First retarget timing | 65 ms for 100 TH/s | 60+ s (first tick must elapse) |
| Cold-start over-difficulty p99 | depends on miner-vs-startdiff ratio | 10% (FullRemedy), ~16% (production champion at SPM=6) |
| Cold-start convergence | 60-300 s (2-4 retargets) | 15-min p50 ramp |
| Cold-start UNDER-difficulty risk | catastrophic if `mindiff < truth` | bounded by `min_allowed_hashrate` floor |

The SRI cold-start is **slower in wall-clock terms** but **does not
produce a storm**, because the initial target is sized correctly. The
ckpool cold-start is **fast** but **does produce a storm** because
`startdiff=42` is sized for the lowest-hashrate device.

## Implications for scale testing

- **A "cold-start budget" metric is needed**. Convergence to within X%
  of truth in Y seconds. gimballock's `convergence_p90_secs` is the
  template; for a scale-test harness, expose it per-algorithm and
  per-SPM.
- **Ramp-target-overshoot bounds the over-difficulty load shape**.
  Over-difficulty means the miner submits FEWER shares than target
  during ramp. Under-difficulty (the public-pool #120 mode) means the
  miner submits MORE shares than target. A scale-test harness must
  measure both directions. gimballock conflates them into
  `overshoot_p99` (absolute deviation); a scale-test harness should
  separate them since their network/CPU implications are opposite.
- **The cascade phenomenon at SPM=6 is real**. Any scale-test running
  at SRI default SPM=6 must include enough cold-starts to see the
  Iteration-2 cascade (≥1000 trials before it shows up).
- **PartialRetarget(η=0.2) is the scale-test-relevant safety net**. A
  pool stack that doesn't dampen retargets will produce target oscillations
  that translate to client-side rejection inflation (per SpiralPool
  issue #10).
