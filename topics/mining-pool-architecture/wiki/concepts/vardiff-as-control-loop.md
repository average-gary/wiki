---
title: "Vardiff as a Control Loop"
category: concept
sources:
  - raw/articles/2026-09-21-vardiff-non-arrival-blindness-optech-423.md
  - raw/data/2026-09-21-pool-scale-and-sizing-constants.md
  - raw/papers/2026-09-21-bip310-stratum-extensions.md
  - raw/articles/2026-09-21-solo-ckpool-production-operations.md
  - raw/repos/2026-09-21-ckpool-architecture.md
  - raw/papers/2026-09-21-hardening-stratum-bedrock-pets2017.md
created: 2026-09-21
updated: 2026-09-21
tags: [vardiff, control-loop, stranded-difficulty, arrival-triggered, timer-based-reduction, last-hop-principle, share-rate, difficulty-tiers, hashrate-estimation, privacy]
aliases: ["variable difficulty", "vardiff", "stranded difficulty"]
confidence: high
volatility: warm
summary: "Vardiff is the feedback controller that sets each connection's share difficulty, and it does three jobs at once: it decouples aggregate share rate from network hashrate, it determines per-miner payout variance and feedback latency, and — because it is usually triggered by share arrival — it is structurally blind to a miner slowing down. Eric Price's 2026 finding is that no parameter tuning fixes the blindness; the controller needs a timer, and it must live at the last hop that still sees individual miners' shares."
---

# Vardiff as a Control Loop

> Variable difficulty looks like a convenience feature. It is in fact the pool's primary control
> surface: the one knob that decouples the load on the pool from the hashrate connected to it. It is
> also the subsystem most likely to be silently wrong.

## What it controls

Vardiff sets a per-connection share target so that the connection submits at roughly a target
interval — commonly one share every 5–30 seconds. Three consequences follow, and they are usually
discussed separately when they should be discussed together.

### 1. It decouples share rate from hashrate

If vardiff holds a target interval per connection, then:

```
aggregate_shares_per_second ≈ connection_count / target_interval_seconds
```

There is **no hashrate term**. A pool can absorb an order of magnitude more hashrate at constant
share rate by raising difficulty, which is exactly what production pools do — solo.ckpool enforces a
10,000 difficulty floor generally and runs separate high-difficulty ports (4334/4336) for rental
hashrate, and ckpool ships `mindiff` / `startdiff` / `maxdiff` knobs with "stable unlimited maximum
difficulty handling."

**This is the single most consequential sizing fact in pool architecture**, and it is why published
"shares per second" figures derived from `hashrate / (difficulty × 2³²)` at a fixed assumed difficulty
are wrong by orders of magnitude. See [[pool-sizing-model|the sizing model]]
([the sizing model](../references/pool-sizing-model.md)) for the corrected arithmetic and the error it
replaces.

The corollary: **the component that saturates first is the connection layer, not the validator.** Cf.
[[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](connection-layer-scaling.md)).

### 2. It sets variance and feedback latency

Raising difficulty cuts share rate and bandwidth, but it also increases each miner's payout variance
and lengthens the interval over which the pool can estimate that miner's hashrate or notice it has
died. **That is the real vardiff trade — not validator CPU.**

### 3. It is a privacy parameter

The ISP Log attack in Recabarren & Carbunar's PETS 2017 paper works because F2Pool's first
post-subscribe difficulty notification was always the minimum (1024) and the second arrived after
roughly 50 shares — so counting the first ~50 packets yields a hashrate estimate with **−9.49% mean
error** from metadata alone. A publicly known, fixed starting difficulty converts packet counts into a
hashrate oracle. BIP 310's `minimum-difficulty`, where the *miner* requests its floor, is better here
precisely because the value is no longer globally predictable.

## The structural defect: blindness to non-arrival

Eric Price, published in Bitcoin Optech #423 (2026-09-18).

A controller that updates **on share arrival** has no input for **absence**. When a miner slows down:

1. It keeps its previous, now far-too-high difficulty.
2. It therefore produces far fewer shares than the target rate.
3. The controller never receives the event that would lower the difficulty.
4. The miner remains stranded at high difficulty **indefinitely**.

The loop is self-reinforcing in the wrong direction: the worse the slowdown, the fewer chances the
controller gets to correct it.

**Stated explicitly in the source: no amount of parameter tuning can solve this.** It is a property of
an arrival-triggered controller, not of a badly chosen time constant. That is what makes it an
architecture finding rather than an operations note.

### Consequences

- **Silent revenue distortion.** The miner contributes real hashrate and is credited with
  disproportionately few shares. It is underpaid through no fault of its own.
- **Hashrate estimation breaks.** Pool-side estimation cannot distinguish "slowed" from
  "disconnected" — both are an absence of shares at the current difficulty. Every dashboard built on
  share-rate × difficulty inherits the error.
- **Nothing alerts.** No rejection, no error, no log line. This is the signature of the most dangerous
  class of pool bug: the accounting is wrong and the system reports health.

### The remedy, and its own parameter

**Timer-based reduction** — lower difficulty after a fixed interval of silence, e.g. halve every 30 s.
This gives the controller an input that does not depend on the miner succeeding.

SRI already implements this, but Price noted **recovery is slow for long-lived connections that have
ramped to high difficulty** — halving down from a large value takes many intervals. So having the
mechanism is not the same as having an adequate response time; the reduction schedule is itself a
design parameter. ckpool was reported as recomputing only on share arrival, i.e. exposed — though
`stratifier.c` does track `ldc` (last diff change) alongside `ssdc` (shares since diff change), so
whether time already drives a reduction is worth confirming in the source.

**Blitzpool ships the remedy switched off.** Its vardiff runs on a 60 s timer per connection, and
`vardiff_silence_easing_enabled` walks a silent session's difficulty down "along the rate its own silence
still supports". It is bounded (16× maximum descent, 8× maximum up-step) and pauses while rejects are
still arriving. But it is **off by default** ("switch it on deliberately (staging first)",
`bp-config/src/lib.rs:505-512`, at `c295ae0`). Having a timer is not enough. The timer has to be allowed
to *lower* difficulty, and here that is an opt-in.

## The placement rule (the more general result)

Price: control must occur at **"the last hop that still sees each miner's shares."** Anthony Towns,
agreeing: in Stratum V2 and DATUM deployments that means the **local proxy or gateway**, not the
upstream pool role.

The reasoning generalises well beyond vardiff. In a tiered topology — miners → proxy/translator/gateway
→ pool — the upstream sees **aggregated** shares, and aggregation destroys the signal: one miner's
silence is invisible once mixed with thousands of others' presence.

**Therefore any per-miner control loop must live at the deepest tier that still has per-miner
visibility.** This applies to vardiff, per-miner health detection, hashrate estimation, and stale-rate
attribution.

Note the direct tension with ckpool's passthrough scaling model, where aggregating many downstream
connections into one upstream socket is the entire mechanism for reaching "millions of clients." The
rule says: wherever you aggregate, place the per-miner control loops on the *downstream* side of the
aggregation point. It also reframes what a proxy is for — not merely connection aggregation, but the
last place per-miner control is possible. Both DMND's `demand-cli` and Ocean's DATUM gateway converge
on this component independently.

## Heterogeneity, and why difficulty became negotiable

The span of device capability is enormous: a Bitaxe-class lottery miner needs difficulty near 1 to see
any shares at all; a 10 PH/s farm needs 100,000+ to keep submission sane. BIP 310's
`minimum-difficulty` extension exists to let the miner state its floor — the admission that
**difficulty is a negotiated per-connection parameter, not a pool-wide policy.**

Pools lacking it express difficulty tiers as **separate listening ports**, which is what solo.ckpool
does (3333 SV1, 3336 SV2, 4334/4336 high-difficulty rental). solo.ckpool also does something subtler:
it enforces a 10,000 floor for *accounting* while offering a client-side cosmetic floor of 1 via
`client-diff`. **The share stream a miner observes and the share stream the pool accounts for are
deliberately different things** — miner-facing feedback is a UX requirement served separately from
accounting.

## Testing it

Price published a **shaping proxy** that probabilistically drops shares to simulate a degraded miner,
so an operator can determine empirically whether their pool strands slowed miners without touching
production. This is the actionable artifact: the defect is now testable rather than theoretical.

The `mining-scale-test-sim` hub topic is built around the same author's vardiff characterisation
harness, and this finding is the substantive result that line of work produced.

## See Also

- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](the-two-hot-paths.md)) — vardiff sits on neither, but needs per-miner visibility.
- [[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](connection-layer-scaling.md)) — what saturates once vardiff has flattened share rate.
- [[pool-sizing-model|Pool Sizing Model]] ([Pool Sizing Model](../references/pool-sizing-model.md)) — the `connections / interval` relation and the figure it corrects.
- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](../topics/optimal-pool-architecture.md)).
