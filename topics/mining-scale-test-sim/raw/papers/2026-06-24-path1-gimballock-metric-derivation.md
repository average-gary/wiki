---
title: "Vardiff at the Information Floor — the §10 log-error regret/effort metric whitepaper"
source_url: https://github.com/marafoundation/stratum/blob/vardiff/simulation-framework/sv2/channels-sv2/sim/docs/METRIC_DERIVATION.md
source_branch: vardiff/simulation-framework
type: paper
ingested: 2026-06-24
quality: 5
confidence: high
tags: [vardiff, simulation, gimballock, information-theory, cramer-rao, regret, effort, whitepaper, champion, ewma360]
---

# Vardiff at the Information Floor — what a share-rate controller can and cannot do

The 714-line whitepaper (commit `412e6de5` "§10 log-error regret/effort
metric + theory writeup", iterated through `0d448b59` "structural-frame
paper rewrite + champion figures"). Derives the algorithm scoring metric
from two theorems, and uses it to select the production champion.

## Abstract

A vardiff controller is unusual: the only thing it can measure is its
own tracking error. Two theorems together imply that across the
operating band (`r* ≈ 4-30` spm) **every reasonable controller is
pinned to the same information floor**: the spread between best and
worst is ~12% in composite cost, the residual differences are
**gentleness and safety** rather than **agility**, and the one lever
that moves the floor is the share rate `r*` itself.

The shipped champion `Ewma360/s1.5` is not the hero of the story; it
is the existence proof that the safe corner of the achievable
frontier is occupiable. It is deliberately the gentlest decline-safe
configuration, and it pays for that with slow transients
(~65-min cold-start ramp, ~28-min detection latency at 12 spm).

The metric: **linear sign-split tracking regret + direction-split
effort, per scenario class, per share rate, detection reported
separately as a rate-dependent diagnostic** (not folded into the
production scalar — an earlier version that did was corrected after
measurement showed detection is floor-saturated below ~10 spm).

## Notation conventions

- *Theorem* and *Lemma* are reserved for results proved from the model
- *Argument*, *Rationale*, *Choice* are reasoning or decisions
- *Observation* is a fact about particular algorithms established in
  simulation, named inline
- *Regret* here = time-integrated tracking loss `∫|e|`, NOT
  online-learning regret against a comparator
- `e = ln(Ĥ/H)` is the log-error coordinate; `e > 0` is
  over-difficulty, `e < 0` is under-difficulty
- `s = ln(Ĥ⁺/Ĥ⁻)` is the additive log-step on a fire

## §1. Model

Variable difficulty exists because miners span many orders of
magnitude in hashrate while the pool needs every connection to
deliver shares at roughly the same rate. A single global `D` would
bury the pool with shares from big miners and starve small ones.
Per-connection vardiff moves each `D` so the realized share rate
stays near a target `r*`.

`r*` is doing three jobs at once:
- caps bandwidth and CPU each connection costs
- fixes variance of the pool's per-miner hashrate estimate
- bounds the miner's reward variance

**The one quantity that moves the fundamental limit is `r*`** — the
recurring theme from §1 (model) → §3 (floor) → §8 (lever).

Two modeling choices fall out of the physics:
1. **Share arrivals are Poisson** (each hash is an independent trial
   with tiny success probability, count is Poisson with rate
   `r_obs = r* · H/Ĥ`)
2. **Natural coordinate is `e = ln(Ĥ/H)`** (controller acts
   multiplicatively, observable depends on `Ĥ` only through `H/Ĥ`,
   over- and under-shoot by the same factor only equidistant in log)

## §2. Theorem 1 — Observable depends only on error

**Theorem 1.** *The sole observable `N` has a distribution depending
on `H` and `Ĥ` only through the error `e`.*

*Proof.* By (1)-(2), `N ~ Poisson(r*τ · e^{-e})`. The parameter is a
function of `e` alone. ∎

Implication: every quality statistic (accuracy, jitter, reaction,
overshoot) is a functional of `e(t)` and the fire sequence. The whole
metric can be written in `e` and `s`.

## §3. Theorem 2 — the information floor

**Theorem 2 (information floor).** *Any unbiased estimate of `e` from
a window of `τ` minutes has `Var(ê) ≥ 1/(r*τ)`.*

*Proof.* `N ~ Poisson(λ)`, `λ = r*τ · e^{-e}`. Log-likelihood in `e`:
`N ln λ − λ`. Score `= λ − N` (since `λ' = −λ`). Fisher information
`E[(λ−N)²] = Var(N) = λ`; at the operating point `e≈0`, `λ = r*τ`.
Cramér-Rao: `Var(ê) ≥ 1/(r*τ)`. ∎

Encoded as `SettledAccuracy::poisson_floor` at `metrics.rs:864` —
`1/√(r*τ)` as a percentile.

**Corollary (central trade-off).** Steady-state precision improves
only by enlarging the averaging window `τ`; but the same `τ` is the
lag in following a real change. **Accuracy and agility are bought
from one budget at a fixed rate `r*`.**

Three consequences:
- Apparent quality axes are one trade-off (`31a9dbc1`: four
  independent parameterizations all saturate at the same ≈0.55 quality
  wall, seen four ways)
- A steady offset has a price, not a defect
- Field is flat across the operating band; detection is floor-limited
  at production rates (~12% best-to-worst spread)

**Dynamic floor on a ramp.** On a decline of `ρ` per minute,
estimator lag is `≈ ρ·τ_eff`, noise is `1/√(r*τ_eff)`. Their sum has
a floor at `τ_eff ∝ (z/ρ)^{2/3} · r*^{-1/3}` — the physics behind
the §8 τ-safety-valley.

## §4. Linear error norm (not squared)

**Lemma (blindness of the square).** *A persistent, undetected
fractional hashrate drop `g` produces steady error `e = -ln(1-g) =
g + O(g²)`. Under `f(e) = e²` it costs `g² + O(g³)`; under
`f(e) = |e|` it costs `|e| = g + O(g²)`.*

Operational harm from a difficulty error (lost or excess work)
scales with **magnitude** `g`, i.e. linearly. Squared norm
undervalues it by `1/g`, diverging as `g → 0` — a small persistent
leak (failing/throttling ASIC, the case operators care most about)
is essentially free under `e²`.

**Observation (`regret-effort`):** an algorithm that detects a -10%
drop ~1% of the time scores BETTER on `e²` than one that always
detects it.

**Choice 1.** Use `f(e) = |e|`, split by sign:
```
regret_over  = ⟨|e|⟩ over time with e > 0   (over-difficulty)
regret_under = ⟨|e|⟩ over time with e < 0   (under-difficulty)
```

## §5. Detection is separate (and at production rates it's floor-limited)

**Argument.** *There is no functional `F` with
`detection = F(e on stable, e on step)` holding across all algorithms.*

Why: catching a small drop requires the share counter to be *young*
when the drop lands. Counter age at the drop is determined by the
fire history of a matured on-target loop — a state stable and step
scenarios never enter.

Detection must be carried explicitly:
```
detection = P[ fire within W min | counter matured, then -g drop ]
```

But detection must be measured against its own false-alarm rate. The
honest quantity is **EXCESS**:
```
EXCESS = P[fire within W | -g drop] - P[fire within W | no drop]
```

**Observation:** at production rates the information floor is so
coarse that a -10% drop is statistically invisible within a monitoring
window: `EXCESS = 0.00` at 60-min window, `+0.05` at 15-min window,
at 4-6 spm, for the WHOLE FIELD.

**Choice 2 (corrected).** Detection is REMOVED from the production
score. Below ~10 spm it's floor-saturated and carries no ranking
signal; folding it in just rewards twitchiness. Instead it's reported
as a **rate-dependent diagnostic** — `EXCESS` vs `r*` — where it does
discriminate (§8 lever): `EXCESS` climbs monotonically to `+0.75`
at 60 spm.

## §6. Directional asymmetry (3:1)

**Argument.** *Over-difficulty is worse than under-difficulty, and
tightening is worse than easing.*

Why:
1. `e < 0` (difficulty low) → shares run a little fast; all work
   valid; mild inefficiency. `e > 0` (difficulty high) → connection
   starved of valid shares; reward variance, hashrate-estimate
   variance, offline misread risk; compounds when `H` falls.
2. (proved) A tightening fire (`s > 0`) invalidates in-flight shares
   aimed at the old easier target — fraction `1 - e^{-s} > 0` lost;
   an easing fire leaves prior work valid.

**Choice 3.** Weight both at 3:1 (over:under and up:down), matching
`tighten_multiplier = 3` from commit `a1d3fa7b`.
**Observation (`champion-weights`):** the best algorithm is the same
for every ratio in `[1:1, 4:1]`; only an ungrounded 5:1 changes it.

Note: under-difficulty has its own resource cost (extra bandwidth, CPU,
share-accounting). Adds as `c · r* · max(0, -e)` — one external
calibrated input the simulation cannot supply. **This is exactly the
connection-side cost the scale-test wiki is trying to characterize.**

## §7. The metric

Per scenario class **and per share rate `r*`**, from the trajectory
`{(e, fired, s)}` alone (computable for every algorithm):

```
regret_over, regret_under   =  ⟨|e|⟩, split by sign of e            §4
effort_up, effort_down      =  Σs² and Σ|s|, split by sign of s
[diagnostic] EXCESS(r*)     =  P[fire|drop] - P[fire|no drop]       §5
```

**Vector is primary**; for ranking, the production scalar is:
```
cost = 3·regret_over + 1·regret_under
     + ρ·( (3·effort_up + 1·effort_down)_quadratic
           + λ·(3·effort_up + 1·effort_down)_linear ),     ρ = ½
```

Two corrections from earlier versions:
- **Detection no longer in the scalar** (§5, floor-saturated)
- **Effort carries a linear `Σ|s|` term alongside `Σs²`** — closes
  the dual of §4's blind spot: hold `Σs²` fixed, raise fire frequency
  with tiny steps, and `Σ|s| → ∞` while `Σs² → 0`. Lost work is
  linear in each step (`1 - e^{-s} ≈ s`), so cumulative lost work
  scales as `Σ|s|`.

Assumption: fire cadence is capped (15s minimum inter-fire interval).

**Per class and per rate, never pooled.** Cold-start cost dwarfs
steady-state cost; floor moves with `r*`. Pooled averaging erases
distinctions. Champion is selected by **minimax over `r*`** — best
worst-case across the band.

## §8. Figures (and three that died)

### Three premises drawn and killed by measurement (§8.1)

- "Performance vs `r*`, every controller hugging the floor from
  above" — false; the policy-free MLE sits ABOVE the field
- "Thin ribbon in steady-state error" — flatness is real but lives
  in composite cost across rates, not steady RMS
- "Champion = Pareto frontier" — five configs dominate on
  steady-vs-transient axes; champion only becomes the frontier when
  points are colored by safety — and all five dominators fail the
  cross-rate decline gate

These casualties earn the survivors trust.

### Surviving figures

- **§8.2 — steady-vs-transient scatter:** champion is the
  lower-left-most decline-safe point; safe configurations trace a
  convex envelope; champion is its gentle-steady corner
- **§8.3 — τ-safety-valley:** worst settled over-difficulty after
  sustained decline is a U-shaped function of estimator window τ,
  minimum at the champion's window (τ=360). Sleepy long windows lag
  into over-difficulty; twitchy short windows overshoot. The valley
  is sensitivity-invariant (identical across boundary `s ∈ {0.3...2}`)
  — a genuine window effect, not a window×threshold confound
- **§8.4 — EXCESS vs `r*` lever:** `EXCESS` climbs monotonically
  `+0.05` (4 spm) → `+0.75` (60 spm). At production rates the field
  is bunched near the floor; the floor binds *everyone*

## §9. Selection, safety, validation

### §9.1 Minimax over `r*`

`sweep-minimax.rs` scores the corrected metric at each rate
independently across `r* ∈ {4, 6, 12, 30}` (60 spm as a high-rate
anchor, outside the minimax). Three findings:
- Field is flat (~12% best-to-worst — Theorem 2 again)
- Cost-optimal walks with `λ` toward sleepy long-window corner
- Band-optimal cost lands in the sleepy corner; **decline-safety
  gate is the actual selector**, not cost

### §9.2 The decline-safety gate (death-spiral test)

`slow-decline.rs` over rate ∈ {1-40} %/hr × spm ∈ {2-30}. Gate is
**SETTLED error** after a 120-min recovery window, not the transient
trough.

**Result.** Among λ-robust band cluster, **only the champion
`Ewma360/s1.5` has zero runaway cells** (worst settled +2.7%). Every
sleepier configuration that beats it on band-cost fails at sub-guard
2-4 spm cells (settled +5.6% to +9.6%). Classic incumbent fails
hardest: settled +22%, transiently +109% — a starved miner.

### §9.3 Gate as constraint, not weighted objective

Decline-safety is a HARD CONSTRAINT across all plausible failure
magnitudes, not a weighted term. Because: failure magnitude is
firmware/config-mix-dependent and **operator-movable** (operators
can classify miners into similar-profile proxies and normalize the
distribution). Pool operators asked do not know the current
distribution. A controller tuned to that distribution would be
optimizing against a target that moves out from under it.

### §9.4 Hardware validation — what holds and what doesn't

**The behavioral layer reproduced on real hardware:** Antminer S21
(~200 TH/s) on testnet4 via shape-proxy:
- Steady-state jitter zero over 30+ min
- Deterministic -16.7% per fire
- Exact 300s cadence
- ~60% post-staircase overshoot
- ±50% symmetry
- **Counter-age dependence**: 5-min counter reacted in 4.4 min;
  51-min counter in 51.8 min (matured-counter blindness seen in iron)
- **Previous champion's win reproduced live**: deployed beside
  classic, both miners halved at once; classic took hours and first
  moved in the WRONG direction; champion responded in minutes and
  settled correctly

**Present champion `Ewma360/s1.5` on iron:**
- Deployed pool-only at `r*=6` and `r*=30` spm
- Sustained -50% step held ~50 min
- Difficulty-implied hashrate eased downward to follow the drop
- Shares kept flowing
- **Share-rejection rate stayed flat at zero through the decline**
  (the load-bearing tell — a runaway would have pinned difficulty
  high and starved the miner, spiking rejections)
- **Direction-and-starvation claim now holds on hardware**

**Still sim-only (not licensed by hardware):**
- Settled offset (~50 min < 120-min settle window)
- Slow moderate decline (`-ρ %/hr` was not run; only the easy -50%
  step was)
- Multi-connection operation (model assumes one worker per connection)
- Marginal cost `c` per extra share (the under-difficulty resource
  cost from §6)

## §10. Consistency check

**The offset is optimal, not a defect (`confirm-debias`).** Champion
sits at a steady under-difficulty offset, short of the noise-band
floor. Multiplying belief by `b ≥ 1` closes the offset smoothly but
the cost rises monotonically from `b=1`: under the 3:1 asymmetry
the cost-minimizing center of the noise band is not its mean but a
quantile below it, `≈ -0.67·σ_eff`. The metric is self-consistent.

**Falsifiers.** Result should be revised if:
(a) some `∫f(e)` on scored scenarios reproduces the detection ranking
(b) an *unbiased* estimator beats `1/(r*τ)`
(c) champion changes within `w_over:w_under ∈ [1:1, 4:1]` or
    across `λ ∈ {0, ½, 1, 2}`
(d) a real failure mode falls outside the scored ensemble

**Declared coverage gap (d).** Below spm6 the guard is symmetric
PoissonCI; it abandons the §6 safety asymmetry exactly where data is
sparsest. Bounded degradation (offset inside §3 noise band, σ≈45%
at 2 spm). The named fix `AsymmetricPoissonCI` is deferred: it would
reopen champion selection at the margin and owe a spm≥6 re-confirm.
**The trigger that would force it: real connection-rate data showing
a non-trivial tail of connections living at 2-4 spm.** ← directly
relevant to a scale-test harness that could measure this distribution.

## §11. Status of each claim

| Claim | Kind | Source |
|---|---|---|
| Observable depends only on `e` | Theorem 1 | §2 |
| Precision floor `1/(r*τ)` | Theorem 2 | §3 |
| Quality axes are one trade-off | Corollary + obs | §3, `31a9dbc1` |
| Field is flat across `r*` (~12% spread) | Observation | §8, `sweep-minimax` |
| Squared norm blind to small drops | Lemma | §4 |
| Detection not derivable from `e(t)` | Argument | §5 |
| Detection floor-saturated at production rates | Observation | §5, `detection-control` |
| EXCESS rises with `r*` (the lever) | Observation | §8, `excess-lever` |
| Over>under, tighten>ease | Argument | §6 |
| Champion robust over weight range | Choice + obs | `a1d3fa7b`, `champion-weights` |
| Linear `Σ\|s\|` closes churn blind spot | Argument | §7 |
| Champion = safe frontier (not cost frontier) | Observation | §8, `steady-transient` |
| Decline-safety is a τ-valley, floored at champion's window | Observation | §8, `tau-valley` |
| Champion = minimax over `r*` with safety as constraint | Choice + obs | §9 |
| Counter-age mechanism on real hardware | Observation (HW) | §9, PR #2154 |
| Previous champion beats classic on live drop | Observation (HW) | §9, PR #2154 |
| Present champion decline confirmed *in direction* | Observation (HW) | §9.4 |
| Present champion settled-offset + slow-moderate-decline still sim | Scope note | §9.4 |

## Implications for scale testing

This whitepaper IS the lever the scale-test wiki rests on. Reading
it carefully:

- **Vardiff at production rates is information-floor-limited.** The
  controller can't see small declines because the Poisson noise floor
  `1/√(r*τ)` is wider than the signal. This means the **share-validation
  rate at the pool is approximately `r* × N_connections`, regardless
  of underlying miner hashrate** — exactly the scale-test premise.
- **Raising `r*` buys agility at per-connection volume cost.** §8.4
  (the lever) shows `EXCESS` climbs monotonically with `r*`. The
  recommendation in §9.4: "production runs at `r* ≈ 4-6` spm with
  headroom; the model supports running faster — higher `r*` tightens
  both detection floor and estimate at a volume cost the headroom
  absorbs." The pool-side cost of that volume is what a scale-test
  harness needs to measure.
- **The §6 share-volume term is the missing scale-test input.**
  The whitepaper explicitly says the marginal cost `c` per extra
  share is "the one external-economics input the simulation cannot
  supply." A connection-scale harness IS the experiment that produces
  `c`.
- **Coverage gap (d) is the scale-test trigger.** If a scale-test
  reveals a real tail of connections at 2-4 spm, the `AsymmetricPoissonCI`
  guard fix becomes warranted and reopens champion selection at the
  margin.
