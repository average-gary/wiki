---
title: "Vardiff decoupling — why connection count is the right axis"
type: concept
created: 2026-06-24
confidence: high
tags: [vardiff, decoupling, controller, gimballock]
---

# Vardiff decoupling

Vardiff is a per-channel controller that targets a configured shares-per-minute
rate `r*` (typical: 6 SPM at sv2-apps, 18 SPM at ckpool). For a miner with
hashrate `H` and current target `D`:

```
shares_per_second = H / (D × 2^32)
```

So vardiff raises `D` until `H / (D × 2^32) ≈ r* / 60`. Doubling `H`
just doubles `D` — share rate at the pool stays at `r*`.

This is **the decoupling** that makes connection count (not aggregate
hashrate) the right simulator axis. The pool's per-channel work is
bounded by `r*` regardless of how powerful the underlying miner is.

## The decoupling_score metric

[[gimballock vardiff sim|gimballock's framework]] formalizes this with
a single metric per algorithm × share-rate cell:

```
decoupling_score = reaction_rate × clamp(1 − jitter_p50 / J_max, 0, 1)
```

— a number in `[0, 1]` summarizing "how reliably does this algorithm
keep each connection on-target without spurious fires." A perfect
decoupling_score means the pool's perceived share rate is exactly
`r* × N_connections`, with `N` the only knob, regardless of miner mix.

The white paper's [[gimballock-design|three-stage pipeline]] decomposes
the score so a regression is attributable to one of:
- **Estimator** (state estimation — what's happening?)
- **Boundary** (decision theory — should I act?)
- **UpdateRule** (control theory — how should I act?)

## The current production champion

`feat(vardiff): ship the champion as production VardiffState`
(`marafoundation/stratum@53924efb`, 2026-06-23) shipped:

```
Ewma360/s1.5 = EwmaEstimator(τ=360s)
             + AdaptiveSignPersist(spm_threshold=6)
             + AcceleratingPartialRetarget(0.2, 0.6, 0.05)
```

selected by minimax-over-`r*` with decline-safety as a hard constraint
(see [[gimballock-slow-decline|slow decline safety test]]). The
champion's decline response is hardware-confirmed *in direction* on
Antminer S21 at `r* ∈ {6, 30}`.

### Cold-start metric (round 2 measurement)

The Champion's `AdaptiveSignPersist` boundary was designed to cut
cold-start ramp time. Round-2 path D extracted the numbers from
commit `1c645bcf` ("feat(vardiff): SignPersist champion — fix
ramp-up & settle-bias", 2026-06-18):

| Metric | Interim (AsymCusum) | Champion (SignPersist) |
|--------|--------------------|-----------------------|
| Cold-start ramp-up | ~34 min | **~15 min** |
| p99 cold-start overshoot @ SPM=6 (Classic) | 145% | **10%** (14.5× reduction) |

Both numbers matter for the scale-test simulator: the Champion fixes
the **controller's** cold-start behavior, but the [[operational
storm postmortems|burst-connect storm]] is a **plumbing** problem —
ckpool's `startdiff=42` triggers a 55 M sps storm for ~130 ms before
the controller can even retarget. Champion improves SRI's
controller-side cold-start; ckpool's storm requires changing
`startdiff` semantics, not the algorithm.

## Why this matters for scale testing

Two consequences for a connection-scale harness:

1. **Each virtual miner should run real vardiff state.** Re-using the
   production `Composed<E, B, U>` adapter from `channels_sv2::vardiff`
   means the simulated pool-side controller is bit-identical to
   production, so the simulator measures real behavior, not a
   simplified model.

2. **Share-rate-per-connection is policy, not physics.** The simulator
   should sweep `r* ∈ {6, 18, 30}` to characterize how validation load
   scales with policy choice — letting operators tune `r*` against
   their per-pool-host budget. The Champion white paper's §3 corollary:
   "accuracy and agility are bought from one budget at a fixed rate `r*`."

## Caveats

- **Ramp-up phase**. New connections start at `startdiff = 42` (ckpool)
  or `hash_rate_to_target(nominal_hashrate, SPM)` (SRI). Burst-connect
  scenarios produce a **~1800× steady-state spike for ~130 ms** at the
  ckpool default — see [[share validation cost model|Caveat 2]] and
  [[the bottleneck thesis|Caveat 3]] for the storm magnitude
  numbers. The simulator must model ramp-up as a distinct phase, not
  fold it into steady-state.

- **SV1→SV2 translator inheritance (open)**. SRI's
  `hash_rate_to_target(nominal_hashrate, SPM)` requires the client to
  declare hashrate at the wire level — which SV2 clients do via
  `OpenStandardMiningChannel`. The **SV1→SV2 translator** wraps SV1
  miners that have no hashrate-declaration mechanism, so the
  translator must pass _some_ default `nominal_hashrate` to the
  pool's `OpenStandardMiningChannel`. **An unrealistically low
  default makes sv2-apps inherit ckpool's storm shape**, defeating
  SRI's hashrate-derived initial-target design. Open follow-up: grep
  `stratum-apps/translator/src/` for the translator's default
  hashrate constant and document it.

- **Multi-worker connections.** Gimballock's framework assumes one
  worker per connection. Real connections multiplex many workers
  through extended channels — share rate per *socket* can be `K × r*`
  for `K` workers. The connection-scale harness should model both
  shapes.

- **`r* = 6` is a default, not a law.** §8.4 of the white paper shows
  detection improves at higher `r*` — running faster tightens both
  detection and estimation at a linear volume cost. Operators with
  spare validation budget may push `r*` higher; the scale harness can
  quantify the trade.

## See also

- [[the bottleneck thesis]] — why decoupling justifies the
  connection-count axis
- [[gimballock vardiff sim]] — the framework that characterizes this
- [[share validation cost model]] — the validation budget that `r*`
  spends
