---
title: "Operational storm post-mortems — real-world vardiff failure modes"
type: concept
created: 2026-06-24
confidence: medium
tags: [postmortem, storm, vardiff, public-pool, spiralpool, simulator-pattern]
---

# Operational storm post-mortems

The only two **public production post-mortems** of vardiff-related
storm conditions found across two rounds of research. Both directly
map to simulator workload patterns the harness should exercise.

## `public-pool#120` — vardiff floor below 1 produces 1.6 M sps per connection

`bitcoinpoolorg/public-pool` issue #120 documents that when vardiff
floors below 1 (allowed in some configurations), a single slow-tuning
ASIC that finally catches up submits at **~1.6 million shares/sec**
from one connection — far above any steady-state bound.

**Failure mode**: the vardiff controller dropped the target while the
ASIC was warming up. Once warm, the ASIC produced shares at full
capacity against the floor-1 target. The pool's share-validation path
(Node.js, single-threaded per worker) was overwhelmed by one
connection.

**Mapping to the simulator**: new workload pattern `slow_warmup`.

```rust
enum WorkloadPattern {
    Steady,
    Ramp25, Ramp50, Ramp100,
    Dropout25, Dropout50, Dropout100,
    SlowWarmup,                  // <-- new
    MidBlockRetargetRejection,   // <-- new
}
```

`SlowWarmup` semantics: the synthetic miner declares low hashrate
(e.g., 1 GH/s), the pool vardiff retargets down to floor over 30s,
then at t=60s the miner shifts to 100 TH/s share submission rate
without re-declaring. The pool must catch the storm.

Cheap to simulate — Poisson with a delayed warm-up step in the rate
parameter; no extra harness machinery needed.

## `SpiralPool#10` — mid-block `set_difficulty` causes 12-16% firmware rejection

`SpiralPool` issue #10 documents that issuing `mining.set_difficulty`
mid-block (without `clean_jobs=true`) causes Antminer S19/S21 firmware
to reject **12-16% of in-flight shares**. The firmware computes
difficulty against the new target but the shares were prepared against
the old target.

**Failure mode**: pool-side vardiff fires a retarget without gating it
on a `clean_jobs` boundary. Miner firmware silently rejects a chunk of
work that the pool would have accepted.

**Mapping to the simulator**: new workload pattern
`mid_block_retarget_rejection`. The synthetic miner accumulates a
queue of shares against the current target; when vardiff fires
mid-block, the simulator computes which fraction of queued shares
would have been firmware-rejected (12-16% for S19/S21) and decrements
the realized share count accordingly.

This makes the simulator a faithful model of **what the pool actually
sees** as the realized vardiff outcome, not what the controller
expected. Firmware-side rejection is invisible to the pool's vardiff
loop but reduces the realized SPM.

## What this means for the bottleneck thesis

Both storms are pool-side post-mortems but neither is a pure
connection-count problem. They both flip the bottleneck from
[[connection scale bottlenecks|connection-layer saturation]] to
[[share validation cost model|share-validation throughput]]:

- public-pool#120: one connection generates more share-validation load
  than 1.6M steady-state connections would.
- SpiralPool#10: the simulated and realized share rates diverge, so
  measuring only one is misleading.

The [[the bottleneck thesis|bottleneck thesis]] (connections first) is
correct in steady state. It is **incomplete** during transition
phases (cold-start, slow-warmup, mid-block-retarget-rejection). The
simulator must measure these phases as distinct workloads, not
collapse them into a steady-state baseline.

## Sources

- public-pool issue #120 — `bitcoinpoolorg/public-pool#120` (surfaced
  in round-2 path D)
- SpiralPool issue #10 — `SpiralPool/spiral#10` (surfaced in round-2
  path D)

Both link to [[gimballock vardiff sim|the gimballock champion
algorithm]]'s `AdaptiveSignPersist` boundary, which is designed to
suppress retargets during low-confidence transitions — `slow_warmup`
in particular. Champion vs Classic comparison on a real-pool reproduction
of these storms would be a high-value addition to the wiki.

## See also

- [[the bottleneck thesis]] — caveat 3 references these post-mortems
- [[share validation cost model]] — caveat 2 references them too
- [[synthetic miner patterns]] — extends the pattern list with
  `slow_warmup` and `mid_block_retarget_rejection`
- [[simulator architecture]] — workload_pattern axis includes both new
  patterns as numbered next steps
- [[gimballock vardiff sim]] — Champion's AdaptiveSignPersist boundary
  is designed for this class
