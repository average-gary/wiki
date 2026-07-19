---
title: "Tokio vs Tokio-uring TCP+Kafka benchmark (Dec 2024, shbhmrzd)"
source_url: https://shbhmrzd.github.io/systems/rust/performance/2024/12/19/async_rt_benchmark.html
type: article
ingested: 2026-06-24
quality: 3
confidence: medium
tags: [scale, tokio, rust, tokio-uring, benchmark, 2024]
---

# Tokio vs tokio-uring HTTP-to-Kafka benchmark (Dec 2024)

Date: **2024-12-19**. Benchmark of a high-throughput web server that
accepts HTTP requests over TCP and forwards them to a remote Kafka
cluster, comparing tokio's TCP layer vs tokio-uring's.

## Hardware

- Ubuntu 22.04.1 LTS
- Kernel: 6.8.0-1018-gcp
- CPU: Intel Xeon @ 2.20GHz (2 cores)
- Memory: ~4 GB
- File-descriptor limit: 65,536

## Result

| Runtime      | Lower bound | Upper bound |
|--------------|-------------|-------------|
| Tokio        | 4,459.9 ops/s | 4,656.2 ops/s |
| Tokio-uring  | 3,924.6 ops/s | 3,939.5 ops/s |

**Tokio is ~13% faster than Tokio-uring on this workload.**

## Caveats

- 2 cores, ~4500 ops/sec — very small scale; bottleneck is likely Kafka
  client, not the TCP layer.
- Tokio version is not stated explicitly; only "tokio-1.42.0" appears in
  a panic trace.
- Author notes tokio-uring stability issues: "connection stalling and
  inability to assign ephemeral ports under sustained load."

## Implication for mining-scale-test

For Rust SV2 pool / mining-pool work, the operational lesson is:

> tokio-uring (the official Tokio io_uring crate, latest release v0.5.0
> on 2024-05-27 per GitHub releases) is **fs-focused** and not
> production-ready for sustained TCP workloads as of late 2024.
> Stability issues and a ~13% throughput deficit vs plain tokio mean
> it should not be assumed to be an upgrade. _[Correction: the
> upstream blog post we quoted states "0.4.0 November 2022"; that was
> stale at the time it was written — v0.5.0 had shipped 7 months
> earlier. The TCP-vs-fs conclusion stands regardless of which
> release.]_

For io_uring-on-TCP, the realistic options remain **monoio** (active,
2026-05 commits) and **compio** (active, 0.19.1 June 2026), not
tokio-uring.

## Source

- https://shbhmrzd.github.io/systems/rust/performance/2024/12/19/async_rt_benchmark.html
- Date: 2024-12-19
