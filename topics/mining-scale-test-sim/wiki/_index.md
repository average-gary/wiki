---
title: wiki
---

# Compiled articles

## topics/

- [[topics/the-bottleneck-thesis|the bottleneck thesis]] — the central premise + verdict (connections saturate before validation; vardiff smooths share rate; user's hypothesis supported with two caveats)
- [[topics/simulator-architecture|simulator architecture]] — recommended design synthesizing all 5 paths into a `scale-sim-harness` crate + pool instrumentation + mock-bitcoind

## concepts/

- [[concepts/vardiff-decoupling|vardiff decoupling]] — why connection count is the right scale axis (Champion algorithm production-landed 2026-06-23)
- [[concepts/connection-scale-bottlenecks|connection-scale bottlenecks]] — what saturates first (ephemeral ports → SYN backlog → Noise CPU → kernel memory → userspace memory → tokio → conntrack → validation)
- [[concepts/share-validation-cost-model|share-validation cost model]] — 5-20 µs/share, 50-200k sps/core, crossover math, two caveats
- [[concepts/synthetic-miner-patterns|synthetic miner patterns]] — five patterns A-E, the math, recommended tiered plan, per-connection state cost model
- [[concepts/load-harness-landscape|load-harness landscape]] — three buckets surveyed, recommends custom-thin-Rust harness; p2poolv2 JMeter assessment; IanoNjuguna sv2-tools rewrite verdict
- [[concepts/operational-storm-postmortems|operational storm postmortems]] — `public-pool#120` + `SpiralPool#10`; two new simulator workload patterns (`slow_warmup`, `mid_block_retarget_rejection`)

## reference/

- [[reference/gimballock-vardiff-sim|gimballock vardiff sim]] — primary reference for marafoundation/stratum :: vardiff/simulation-framework

## articles/

(empty — articles directory reserved for narrative deep-dives)
