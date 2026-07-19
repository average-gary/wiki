---
title: raw/notes
---

# raw/notes

- [2026-06-24-path1-gimballock-ckpool-investigation.md](2026-06-24-path1-gimballock-ckpool-investigation.md) — CKPOOL_INVESTIGATION.md: porting ckpool's dsps EMA + adaptive window switching, hysteresis sweep, estimator equivalence; lesson on per-share vs per-tick numerical stability
- [2026-06-24-path1-gimballock-pid-investigation.md](2026-06-24-path1-gimballock-pid-investigation.md) — PID_INVESTIGATION.md: why a Pow2-PID's quantization dead zone blocks all retargets ≤5×; what the three-stage pipeline did with PID-derived ideas (`AcceleratingPartialRetarget` transferred; `SpmRatioEstimator` and `SignPersistenceCusumBoundary` discarded)
- [2026-06-24-path1-gimballock-slow-decline.md](2026-06-24-path1-gimballock-slow-decline.md) — SLOW_DECLINE_TEST.md: the death-spiral safety gate that selected the champion. Spec, hard-gate pass/fail criteria, sub-guard sub-spm6 sub-band bounded limit (`+5% at 2 spm`), hardware validation status
- [2026-06-24-path5-load-harness-landscape-notes.md](2026-06-24-path5-load-harness-landscape-notes.md) — load-harness compatibility matrix (wrk/k6/JMeter/Gatling/Locust/Goose/drill/oha/tcpkali/emqtt-bench/mqtt-stresser/ddosify/Tsung), three viable paths (custom Rust / Goose+TCP / Locust+ext), single-host connection ceiling (64k × source-IP multiplier), distributed coordination patterns, metrics export formats

## Path-3 (synthetic-miner methodology) — 2026-06-24

- [2026-06-24-path3-synthetic-miner-patterns-synthesis.md](2026-06-24-path3-synthetic-miner-patterns-synthesis.md) — Pattern A/B/C/D/E taxonomy for synthetic miners (mock / Poisson-over-real-conn / fixture-target / hybrid / real-CPU). Canonical share-rate math, per-connection state cost model (4–6 GB / 100k miners), recommended `SyntheticMiner` trait shape, tiered scale-test plan for 10k → 100k → 1M miners.

## Path-4 (share-validation cost model) — 2026-06-24

- [2026-06-24-path4-validation-vs-connection-bottleneck-math.md](2026-06-24-path4-validation-vs-connection-bottleneck-math.md) — crossover math: at N=1M connections (6 SPM), validation needs 2–15 cores while connection layer hits OS limits (sockets, fds, ephemeral ports) first; verdict on user's premise

## Round-2 path-D (vardiff ramp-up vs steady state) — 2026-06-24

- [2026-06-24-r2-pathD-vardiff-rampup-math.md](2026-06-24-r2-pathD-vardiff-rampup-math.md) — quantified burst-connect storm: ckpool startdiff=42 → 554 sps/conn for S19 → 55M sps aggregate at N=100k, ~1800× steady-state for ~65 ms before first retarget. SRI vs ckpool asymmetry. public-pool #120 inverse-storm case.
- [2026-06-24-r2-pathD-gimballock-coldstart-metrics.md](2026-06-24-r2-pathD-gimballock-coldstart-metrics.md) — gimballock's `convergence_p50/p90_secs` + `overshoot_p99` metric definitions from bin/convergence-time + FINDINGS.md; Champion commit 1c645bcf cold-start ramp 34→15 min; EwmaEstimator cold-start code path; SPM=6 cascade explanation.
