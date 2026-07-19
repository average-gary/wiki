---
title: concepts
---

# Concepts

- [[vardiff-decoupling]] — vardiff clamps each connection's share rate to `r*`, regardless of underlying hashrate. The framework's `decoupling_score` metric quantifies this. Champion algorithm (`Ewma360/s1.5`) shipped to production VardiffState on 2026-06-23.
- [[connection-scale-bottlenecks]] — 8-stage saturation order on commodity hardware for 1k → 1M concurrent SV2 connections. Per-connection memory by impl. SRI Noise bench numbers (178 µs/handshake responder). Sysctl/ulimit recipes.
- [[share-validation-cost-model]] — per-share cost ledger (5-20 µs), per-core ceiling (50-200k sps), the JD-path special case (per-template, not per-share), duplicate-detection memory, lock-contention and vardiff-ramp-up caveats.
- [[synthetic-miner-patterns]] — five patterns (A mock / B Poisson / C fixture / D hybrid / E real-CPU), the share-rate math, recommended tiered plan, per-connection state cost.
- [[load-harness-landscape]] — three buckets (HTTP-only / HTTP-extensible / protocol-specific), Goose/Locust/JMeter/emqtt-bench assessment, recommended custom-thin-Rust harness, single-host connection ceiling. **Round 2: IanoNjuguna/stratum-v2-tools verdict closed → rewrite from scratch (100% in-process mock, no SV2 wire deps, license null, abandoned).**
- [[operational-storm-postmortems]] — `public-pool#120` (1.6 M sps from one connection on vardiff floor below 1) + `SpiralPool#10` (12-16% S19/S21 firmware rejection on mid-block `set_difficulty`). Both map to new simulator workload patterns `slow_warmup` and `mid_block_retarget_rejection`.
