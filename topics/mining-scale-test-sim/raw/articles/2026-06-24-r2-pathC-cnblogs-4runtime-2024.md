---
title: "4-runtime async Rust benchmark: tokio vs tokio-uring vs monoio vs glommio (Dec 2024)"
source_url: https://www.cnblogs.com/piperck/p/18597976
type: article
ingested: 2026-06-24
quality: 4
confidence: medium
tags: [scale, tokio, rust, monoio, glommio, benchmark, comparison, 2024]
---

# Cross-runtime async Rust benchmark (Dec 2024, cnblogs / piperck)

Date: **2024-12-10**. The most recent (as of 2026-06-24) cross-runtime
benchmark of all four major async Rust runtimes with both raw-socket
and Hyper-served HTTP variants. Chinese-language blog post by piperck.

## Hardware

- GCP 4-core instance
- Ubuntu 22.04.5 LTS, kernel 5.15.0-1065-gke
- CPU: Intel Xeon @ 2.20 GHz
- Load tool: k6

## Workload

TCP ping-pong with HTTP framing. 80 concurrent connections (the same
fixed-pressure point as the 2021 monoio benchmark, allowing direct
comparison).

## Results — raw runtime (no HTTP library)

| Runtime      | RPS       | p50 latency | CPU usage | RPS / core |
|--------------|-----------|-------------|-----------|------------|
| Tokio        | 110,883   | 568 µs      | 2.72c     | 40,766     |
| Tokio-uring  | 113,718   | 550 µs      | 3.38c     | 33,644     |
| MonoIO       | 113,239   | 552 µs      | 2.62c     | 43,221     |
| GlommIO      | 108,493   | 553 µs      | 3.79c     | 28,626     |

## Results — with HTTP libraries

| Runtime        | RPS     | p50 latency | CPU usage |
|----------------|---------|-------------|-----------|
| Tokio + Hyper  | 108,694 | 553 µs      | 3.48c     |
| MonoIO + Hyper | 109,298 | 576 µs      | 3.66c     |
| Actix-web      | 109,976 | 571 µs      | 3.70c     |
| GlommIO + Hyper| 94,816  | 665 µs      | 3.85c     |

## Author's conclusion

> "io-uring demonstrated no significant performance advantage over
> epoll or thread-per-core models" in this ping-pong scenario.

## Interpretation

1. **At 80 connections / 4 cores, all four runtimes are within ~5% RPS
   and ~30 µs p50.** The 2-3x monoio advantage from the 2021 benchmark
   does not reproduce here — that gap was 16-core / specific workload.
2. **Monoio has the best CPU efficiency** (43,221 RPS/core), tokio
   second (40,766), tokio-uring and glommio noticeably worse. For
   "fixed RPS, minimize CPU" the ranking is monoio > tokio > {others}.
3. **For "fixed CPU, maximize RPS"** the four runtimes are roughly
   equivalent. The TCP layer's bottleneck at this scale is kernel
   epoll/io_uring path costs, not user-space scheduling.
4. **Glommio is the weakest in both metrics**, consistent with its
   semi-dormant maintenance status (last commit April 2025).

## Mining-scale relevance

This benchmark is at 80 conns / 4 cores — five orders of magnitude
below the 1M-conn target. It does not directly answer the SV2 scale
question. What it does tell us:

- Choosing between tokio and monoio is a **CPU-efficiency** decision
  (~5-10%), not a throughput-ceiling decision, at the small-message
  ping-pong shape.
- The cost of using Hyper on top of tokio is real but small
  (~2% RPS, +28% CPU vs raw-tokio TCP echo).
- **A 1M-conn-scale tokio vs monoio benchmark does not exist in the
  public record as of June 2026.** Both runtimes' README claims rely
  on data points that are either tiny (80 conns) or stale (2021).

## Source

- Original: https://www.cnblogs.com/piperck/p/18597976
- Date: 2024-12-10
- Author: piperck (cnblogs)
