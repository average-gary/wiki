---
title: "The bottleneck thesis — connections vs hashrate vs share validation"
type: topic
created: 2026-06-24
confidence: high
tags: [thesis, scale, vardiff, connections, validation]
---

# The bottleneck thesis

## Premise

When scale-testing a Stratum V2 mining pool by simulation, **connection
count saturates before share-validation does**, because [[vardiff
decoupling|vardiff clamps each connection's share-submission rate]] to a
target band regardless of underlying hashrate. So doubling miner
hashrate just doubles per-connection difficulty, not shares/sec at the
pool.

The user's working sentence: "we'll want to scale number of connections,
vs hashrate, as that will be a bottleneck before share validation is a
bottleneck (because we have vardiff to smooth that out)."

## Verdict

**Supported in steady state — with three caveats** (high confidence).

Path 4's [[share validation cost model|cost ledger]] grounds the math:
SRI's SV2 `validate_share` costs **10-20 µs per share** (5-10 µs in
ckpool C), one core sustains **~50-100k shares/sec** (SRI) or
**~100-200k** (ckpool with SHA-NI). At sv2-apps default
`shares_per_minute = 6.0`:

| Phase | Connections | Aggregate sps | Cores busy (SRI 15 µs) |
|-------|-------------|---------------|------------------------|
| Steady | 10k | 1,000 | 1.5% of one core |
| Steady | 100k | 10,000 | 15% of one core |
| **Steady** | **1M** | **100,000** | **~2 cores** |
| Steady | 10M | 1,000,000 | ~15 cores |
| **Burst (first ~130 ms)** | **100k S19-class** | **55.4 M** | **~385 cores ← validation IS the bottleneck** |

Meanwhile [[connection scale bottlenecks|the connection layer]]
saturates much sooner in steady state — kernel TCP memory hits ~10-20
GB at 1M connections, Linux ephemeral ports cap at ~64k per source IP,
public-pool (Node.js) trips backpressure at ~10k conns/worker. **In
steady state the connection layer hits the wall well before validation
does. During the burst-connect ramp-up storm, validation flips to the
binding constraint for ~130 ms.**

### Caveat 1 — vardiff is denser than assumed

The user's mental model assumed ~1 share / 30s per connection. **ckpool's
actual default is `drr=0.3` ≈ 1 share / 3.3s**, ~10× denser. At that
rate 1M connections produces 300k sps — still ~3-4 cores of work,
parallelizable, but no longer trivial. sv2-apps uses `shares_per_minute
= 6.0` (≈ 1 share / 10s), in between.

This doesn't refute the thesis — connections still saturate first —
but it constrains how aggressive you can be with the simulator's
implicit "validation is free" assumption.

### Caveat 2 — lock contention and burst handshake

Two specific bottleneck classes operate **below** the steady-state CPU
ceiling:

1. **Lock contention.** ckpool's single global `share_lock` (used on
   every `new_share` insert) can contend before CPU saturates. SRI's
   per-channel `safe_lock` is naturally sharded and doesn't have this
   problem.
2. **Noise handshake CPU during reconnect storms.** SRI bench:
   step_1_responder is **178 µs per handshake**, so one core handles
   ~5,600 conn/sec, 8 cores ≈ 45k conn/sec. A 1M-connection reconnect
   storm needs ~22 seconds of full-CPU work at 8 cores. Steady-state
   transport is essentially free (~5-16 µs per share message).

### Caveat 3 — burst-connect ramp-up flips the thesis for ~130 ms

ckpool's `startdiff = 42` is sized for a CPU miner, not an ASIC. An
S19 at 100 TH/s submits its first share at **~554 sps**, clearing the
72-share retarget window in ~130 ms. At burst-connect of N=100k, peak
aggregate share rate is **~55.4 M sps** — ~1800× steady state, and
~385 cores of validation budget. **During this ~130 ms window
validation is genuinely the binding constraint, not connections.**

ckpool hits `share_lock` contention long before reaching the 385-core
CPU bound; the practical limit is share-rejection rate (the lock
serializes the entire share path). SRI's `hash_rate_to_target` sizes
the initial target from declared hashrate, so honest SV2 clients
don't trigger the storm — but the **SV1→SV2 translator** wrapping
ASICs with no hashrate declaration mechanism inherits whatever
default the translator passes to `OpenStandardMiningChannel`. Open
question: what's that default?

Two real-world post-mortems document analogous storms:
`public-pool#120` (vardiff floor below 1 → 1.6 M sps from one
connection when a slow-tuning ASIC catches up) and `SpiralPool#10`
(mid-block `set_difficulty` causes 12-16% S19/S21 firmware-side
rejection inflation).

## Implication for the simulator

The harness should sweep **connection count** as the primary axis, with
share-rate-per-connection (controlled by [[vardiff
decoupling|vardiff]]'s `shares_per_minute`) as a secondary axis.
Single-host realistic ceiling is **100k-500k connections** on a tuned
32-core / 64 GB box with 5-10 source-IP aliases.

Recommended sweep points: `1k, 10k, 30k, 50k, 100k, 280k, 500k, 1M`
connections, each at `SPM ∈ {6, 18, 30}`. Add a **reconnect storm
sub-test** at each N (drop 25%/50%/100% of clients and measure
recovery), which is where handshake CPU shows up.

## What gimballock's framework does NOT cover

Critical scope distinction: [[gimballock vardiff sim|Eric Price's
`vardiff/simulation-framework`]] characterizes the **controller**
(estimator + boundary + update-rule) in a one-virtual-miner,
deterministic, in-process harness. It does not model connections,
network, Noise, or share-validation cost. The connection-scale harness
characterizes the **plumbing** — and the §6 of his white paper
explicitly flags "marginal cost `c` per extra share" as the one external
input the controller-sim cannot supply. A connection-scale harness is
the experiment that produces `c`.

## See also

- [[connection scale bottlenecks]] — full Path 2 ladder of saturation order
- [[share validation cost model]] — Path 4 cost ledger
- [[synthetic miner patterns]] — how to drive N fake miners at controlled share rate
- [[load harness landscape]] — toolchain survey
- [[simulator architecture]] — recommended design
- [[gimballock vardiff sim]] — primary reference
- [[vardiff decoupling]] — why this works
