---
title: "gimballock notes — slow-decline safety test (the death-spiral gate)"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/SLOW_DECLINE_TEST.md
source_branch: vardiff/simulation-framework
type: notes
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, simulation, gimballock, safety, death-spiral, slow-decline, champion, hardware-validation]
---

# Slow-decline safety test — specification and results

188-line spec + results document. This is the safety gate that
selected the production champion `Ewma360/s1.5`. Spec earns
(or bounds) the death-spiral safety claim that `METRIC_DERIVATION.md`
§6 originally only *argued*.

## §1. The mechanism under test (get the sign right)

`e = ln(Ĥ/H)`. During a decline `H↓` with `Ĥ` lagging, `Ĥ/H` rises,
so **`e` drifts positive — over-difficulty**, the costly side of §6.
Shares arrive *slow*; the correct response is to **ease** (lower `Ĥ`
toward `H`).

**The naive worry** ("does it tighten when it should ease?") is not
the real risk. The real death spiral is self-reinforcing starvation:
> over-difficulty → fewer valid shares → sparser counter / less
> statistical evidence → slower to fire the corrective ease → stays
> over-difficulty longer → still fewer shares.

**The champion-specific trigger.** `AdaptiveSignPersist` switches to
the conservative low-SPM PoissonCI guard below its `spm_threshold` (6).
As a decline drags the *effective* realized rate down, the boundary
can flip into its slowest mode exactly when fast easing is most needed
— the guard meant to prevent low-SPM false fires could instead freeze
the correction. **Falsifiable hypothesis:** does the champion keep
pace with a sustained decline, or does the low-SPM guard stall the
ease and let `e` run away upward?

## §2. Scenario definition

```
Phase::Hold { secs: T_mature, h: H0 }          // mature the counter on-target
Phase::Ramp { secs: T_decline, from: H0, to: H0·(1-D_total) }
Phase::Hold { secs: T_observe, h: H0·(1-D_total) }  // settle at floor
```

Sweep:
- `rate ρ ∈ {2, 5, 10, 20, 40} %/hour` (gentle thermal sag → fast
  failing fan). The natural dimensionless quantity is *drop-per-effective-
  window* `ρ·τ`. Report against `ρ·τ`, not `ρ` alone.
- `T_mature = 60 min`
- `D_total = 50%`
- share-rate grid: `{6, 8, 12, 20, 30}` — but the low end is the
  point, since that's where the decline pushes effective SPM through
  the guard.

## §3. Pass/fail criteria

Per cell during the decline phase:

1. **Direction (hard gate).** Every fire during a monotonic decline
   must be an ease (`s < 0`). A single tightening fire (`s > 0`)
   during the decline is a fail — the literal §6 runaway step.
2. **No upward runaway (hard gate).** `e(t)` must stay bounded;
   `max e` during decline must not grow monotonically to the end.
3. **Tracking lag (graded).** Time-averaged `e` over the decline
   (this is `regret_over`) — smaller is better.
4. **Guard-freeze probe (the hypothesis).** Log the fraction of
   decline ticks in low-SPM PoissonCI mode vs sign-persist mode, and
   the fire latency in each. If easing latency spikes when effective
   SPM crosses 6, the guard-freeze mechanism is real.

A clean pass (all eases, bounded `e`, lag comparable to references,
no guard-freeze) is a strong safety result. Any hard-gate failure
locates the decline rate at which the mechanism breaks — itself a
deployable bound ("safe for declines up to X%/hr at SPM ≥ Y").

## §4. Algorithms tested

1. **champion (SignPersist)** — the deployment candidate
2. **interim (AsymCusum, no sign-persistence)** — control to isolate
   whether the sign-persistence discount specifically helps or hurts
3. **classic (real vardiff)** — incumbent baseline

## §5. Hardware version (shape-proxy)

Simulation result must be confirmed on hardware. Shape-proxy already
has a Ramp profile — drive a slow downward ramp (e.g.
`Ramp{1.0 → 0.5 over 2h}`) on an S21/testnet4, champion and classic
side-by-side. Run the gentlest rate that still crosses the spm-6
guard for the configured `r*`, since that's where the hypothesis lives.

**Champion vs classic side-by-side** is the ship/no-ship test. Add
the interim run only if simulation flags a champion-vs-interim
divergence worth confirming.

## §6. Simulation results (`bin/slow-decline`)

Grid: rate ∈ {1, 2, 5, 10, 20, 40} %/hr × spm ∈ {2, 4, 6, 8, 12, 20, 30}
× {champion, interim, classic}. Sparse cells oversampled. **Runaway
test is the SETTLED error after 120-min post-decline recovery
window** — not the instantaneous trough during decline.

### Operating regime (spm ≥ 6) — worst-case over rates

| algo | worst mean_e (during) | worst SETTLED e | worst max_e | verdict |
|---|---|---|---|---|
| champion | 4.3% | **−1.6% (safe side)** | +16% | tracks down, settles safe |
| interim | 3.5% | −2.0% | +13% | same, slightly tighter |
| **classic** | **31%** | **+8.3%** | **+69%** | severe transient lag; recovers slowly |

The champion tracks every decline down and **settles on the safe
(under-difficulty) side** at every spm≥6 cell. Classic falls badly
behind *during* the decline — up to +69% over-difficulty transiently
at 40%/hr, `e≈ln(1.69)`, a badly starved miner — and is slow to
recover (settled +8.3% still over-difficulty).

**Correction to an earlier draft:** classic's +69% is the transient
*trough*, not where it settles; with 120-min recovery, it does
eventually catch up. So the honest framing is *severe transient lag
in the dangerous direction*, not permanent runaway — but the
champion's worst transient (+16%) is ~4× gentler.

### Sub-guard regime (spm < 6) — a real, named, bounded limit

Below the spm6 PoissonCI guard, the champion carries a **steady
positive (over-difficulty) bias**: settled e ≈ **+5% at 2 spm, +2.6%
at 4 spm**, flat across all decline rates. Present identically in
champion and interim, so it is **not** the sign-persistence discount
— it is the shared low-SPM guard.

**Root cause (isolated, not assumed):**
- A stable-load probe with the PoissonCI margin zeroed moved the
  bias only +5.16%→+4.58% — additive margin is **not** the source
- Sign flips exactly at guard boundary: below +5%; at/above -9% to
  -6% (the intended asymmetry-optimal side)
- Mechanism is two-legged:
  1. Guard's symmetric PoissonCI **removes** the protective ≈-0.67σ
     asymmetry the high-SPM boundary carries
  2. That **exposes** the EWMA small-N upward (Jensen) bias —
     `≈+1/(2N)` on `ln`, partially damped, landing at ~+5%

**Why this ships anyway:**
- +5% is inside §3 noise band at 2 spm (σ = 1/√(r*τ) ≈ 45%, so
  +5% ≈ 0.11σ)
- below 4-6 spm operating range
- champion still beats classic on every sub-guard cell (max_e
  +27-42% vs classic's +107%)
- 2 spm is marginal for the *application* (a connection that sparse
  has a noisy hashrate estimate regardless of vardiff)

**Deferred fix:** `AsymmetricPoissonCI` for the guard. Taking it would
reopen champion selection at the margin and owe a spm≥6 re-confirm
— bad trade unless real connection-rate data shows a tail living at
2-4 spm.

### Residual wrong-direction fires

Rare tighten-while-over-difficulty fires (~4% of fires at noisiest
cells) are Poisson mis-reads on sparse data, scaling up with sparsity
and down with rate — signature of noise, not spiral.

**The low-SPM-guard-*freeze* hypothesis is NOT borne out.** Ease
counts stay high (6-37/run) throughout.

## Status

§6 death-spiral safety claim is earned in simulation:
- spm6 guard well-placed (not proven optimal)
- champion settles safe-side in operating range
- stays bounded and far better than classic below it

Hardware confirmation (§5) remains the deployment gate. The
`METRIC_DERIVATION.md` §9.4 update reports that the present
champion's decline response has now been hardware-confirmed in
direction (eases safe-side, no rejection runaway) on Antminer S21
at `r*=6` and `r*=30` spm, against a -50% step. The slow moderate
decline on which the gate actually binds was NOT yet run on iron.

## Implications for scale testing

This test is the most operationally important result in the whole
gimballock corpus. For a scale-test harness:

- **The sub-guard tail is exactly what a scale-test harness should
  measure.** "Is there a non-trivial tail of connections living at
  2-4 spm?" is the question whose answer determines whether the
  `AsymmetricPoissonCI` fix is warranted. A real connection-rate
  distribution from a deployed pool would answer it.
- **120-min settle windows are needed for safety claims.** Any
  scale-test scenario claiming "the pool survives a decline of N
  miners simultaneously" needs at least this long of observed
  recovery. Transient troughs lie.
- **Asymmetry matters for load too.** Over-difficulty starves the
  connection (slows shares); under-difficulty floods it (raises
  shares). Both are real per-connection load shapes — and a
  scale-test harness must distinguish them, not collapse to "shares
  per second."
- **The hardware-validation precedent is real.** Gimballock proved
  the `s = -0.167` per-fire and counter-age dependence in physics,
  not just sim. A scale-test simulator's claims about pool capacity
  should similarly be validated against a real pool under the same
  workload at smaller scale before extrapolation.
