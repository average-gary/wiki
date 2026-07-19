---
title: "Tokio benchmarks 2024-2026: what's actually changed since the 2019 scheduler post"
source_url: synthesis
type: notes
ingested: 2026-06-24
quality: 4
confidence: medium
tags: [scale, connections, tokio, rust, scheduler, benchmark, 2024+, synthesis, round2]
---

# Modern tokio benchmarks (2024-2026) — synthesis

Round-1 cited the 2019 tokio.rs scheduler post as the primary benchmark
reference. This path-C synthesis pulls in primary 2024-2026 sources and
attempts to update the per-task / wakeup / scalability numbers for the
mining-scale simulator. **The headline finding is that comprehensive
public benchmarks at 1M-connection scale, with modern tokio (1.45+) and
io_uring, do not appear to exist in the public record.** What does exist
is a mix of (a) tokio's own internal regression benches, (b)
production-user perf-regression reports against tokio CHANGELOG.md, and
(c) third-party comparisons of tokio vs monoio/glommio/tokio-uring on
short-lived ping-pong loads at 80-250 connections, dated late 2024.

## Headline numbers

| Source                                                           | Date         | Scale                  | Number                                              |
|------------------------------------------------------------------|--------------|------------------------|-----------------------------------------------------|
| shbhmrzd.github.io tokio vs tokio-uring                          | 2024-12-19   | 2 cores, TCP+Kafka     | tokio 4,460-4,656 ops/s; tokio-uring 3,925-3,940 ops/s — tokio +13% |
| cnblogs.com piperck cross-runtime                                | 2024-12-10   | 4-core GCP, 80 conns   | tokio 110,883 RPS @ 568 µs; monoio 113,239 @ 552 µs; tokio-uring 113,718 @ 550 µs; glommio 108,493 @ 553 µs |
| cnblogs.com piperck + Hyper                                      | 2024-12-10   | 4-core GCP, 80 conns   | tokio+Hyper 108,694 RPS @ 553 µs; monoio+Hyper 109,298 @ 576 µs |
| monoio-rs benchmark suite (official)                             | 2021-12-01   | 16 cores, 1KB payload  | monoio ~3x tokio @ 16 cores, ~2x @ 4 cores; **2024+ refresh: NOT FOUND** |
| tokio issue #8065 (kushudai production report)                   | 2026-04-18   | 4-worker multithread   | LIFO-stealing 1.51.0 → 1.52.1: +8.5% aggregate CPU on µs-duration handlers; 18× worker-steal rate |
| tokio PR #7757 (sharded spawn_blocking)                          | 2026-04-10   | spawn_blocking         | 16-thread: 247.8ms → 22.4ms (-91%); 8-thread: 111.5ms → 20.3ms (-82%); single-thread: 13.3ms → 17.8ms (+34% overhead) |
| tokio PR #8120 (LIFO re-enable)                                  | 2026-05+     | 24-core Threadripper   | spawn_many_local +17%; ping_pong +14%; spawn_many_remote_busy2 -23%; chained_spawn -42% (Criterion noise up to 37%) |

## What modern tokio (1.45 → 1.52, 2025-2026) actually changed

Drawn from `tokio/CHANGELOG.md` and PR threads:

1. **Stealable LIFO slot** (PR #7431, 1.51.0 April 2026 → reverted in
   1.52.2 May 2026): meant to fix deadlocks when a notifying task
   doesn't yield, but caused 8.5% aggregate CPU regression in production
   high-QPS services with microsecond handlers (kushudai, issue #8065).
2. **Alternative timer wheel** (PR #7467, 1.49.0 Jan 2026): sharded
   per-worker timer wheels behind `tokio_unstable enable_alt_timer`.
   Existing timer in tokio 1.45+ has a documented contention regression
   that ScyllaDB's Latte explicitly worked around by upgrading.
3. **Eager I/O driver handoff** (PR #8010, 1.52.0 Apr 2026): prevents
   I/O starvation when a worker holds the driver and is about to poll a
   long task. Opt-in via `enable_eager_driver_handoff()`. No public
   throughput numbers; correctness-first change.
4. **Sharded spawn_blocking queue** (PR #7757, 1.52.0): the largest
   measured improvement in the 2026 cycle: -82% to -91% latency at 8-16
   threads, +34% single-thread overhead. **Relevant to mining-scale
   only if validation is `spawn_blocking`-ed.**
5. **Removed lfence on local queue tail** (PR #7340, 1.46.0): no
   numbers published; eliminates an x86 memory-fence in the
   work-stealing hot path.
6. **io_uring file ops** (PRs #7321, #7567, #7617, #7696, #7907): incremental
   addition of io_uring for `fs::*` only. **The TCP layer remains
   epoll-based.** This is the key gap for SV2: a Rust pool using
   tokio cannot get io_uring's batched recv/send for the share-traffic
   path without switching runtimes.
7. **AtomicWaker::wake → swap** (PR #7450, 1.47.0 July 2025): replaces
   compare-and-swap loop with single x86 `xchg`. No throughput numbers
   published.

## Cross-runtime comparison (2024-12, 4-core GCP)

The most relevant single 2024 source is the December 10 2024 cnblogs
benchmark (k6, 80 conns, 4-core Xeon @ 2.20GHz, kernel 5.15):

- All four runtimes (tokio, tokio-uring, monoio, glommio) landed within
  ~5% of each other on RPS (108k-113k) and within 30 µs on p50 latency
  (550-665 µs).
- **CPU efficiency** spread was wider: monoio 43,221 RPS/core, tokio
  40,766, tokio-uring 33,644, glommio 28,626.
- Author conclusion: "io-uring demonstrated no significant performance
  advantage over epoll or thread-per-core models" at this connection
  count, **for ping-pong workloads**.

This is a 2024 update to the 2021 monoio benchmark's 2-3x tokio claim:
the original gap was measured at higher core counts (16) and with
particular workloads; at 4 cores / ~80 conns / 1KB the gap has closed.

## What the 2019 → 2026 delta looks like for SV2

The mining-scale simulator's tokio cost model from path-2 round-1 was:

> 300k tasks woken/sec × ~1 µs scheduler-overhead ≈ ~30% of one core
> at 1M connections × 0.3 sps each.

Modern data does not change this order of magnitude. Specifically:

- **No 2024+ source publishes a comparable "per-wake nanosecond" number.**
  The 2019 `chained_spawn` of ~170 ns/wake/hop remains the most-cited
  primary number; tokio PRs since (LIFO change, alt-timer, lfence-removal,
  AtomicWaker swap) move things by single-digit percents at best.
- The most material *negative* delta is the 1.51.0 LIFO-stealing
  regression: +8.5% aggregate CPU on a workload of "high-QPS,
  microsecond handlers" (i.e. roughly the SV2 share-submit shape). If
  the simulator runs on 1.51.0 or 1.52.0/1.52.1, it should pin to 1.50.x
  or 1.52.2+.
- The most material *positive* deltas (sharded spawn_blocking,
  alt-timer) target workloads the SV2 share path does not have (compute
  blocking, dense timer wheels).

**Net conclusion: the 2019 per-wake ballpark survives. Path-2's
"~30% of one core for share-submit scheduler overhead at 1M
connections" estimate is unchanged by 2024-2026 evidence.**

## io_uring for TCP: still a runtime-switch question, not a tokio question

tokio-uring (latest release **v0.5.0 on 2024-05-27**; verified via
`gh api repos/tokio-rs/tokio-uring/releases/latest`) and tokio's own
io_uring work are both **fs-only**. For TCP, the runtime choices for
"many small messages" are:

- tokio + epoll (status quo; 1.52.3 May 2026)
- monoio (active; latest commit 2026-05-29; thread-per-core, io_uring)
- glommio (semi-dormant; last commit 2025-04-21; thread-per-core, io_uring)
- compio (active; 0.19.1 June 2026; cross-platform IOCP+io_uring+poll;
  inspired by monoio)

The thread-per-core runtimes change the connection-affinity model
materially: each connection is pinned to a core, so SO_REUSEPORT plus
per-core acceptors maps connections without work-stealing. This matters
for SV2 mostly via the path-2 finding (cloudflare-million-packets: NUMA
penalty without SO_REUSEPORT). It is **not** required to hit 1M
connections in tokio; ckpool does it in a single-threaded epoll loop.

## Open questions for round 3

- p50 / p99 wake-to-poll latency for tokio 1.50.x at 100k-1M sustained
  idle connections — no public number.
- Memory footprint per idle tokio task at 1.50+ — task struct size is
  in the 200-byte range but the published numbers are 2019-vintage
  (1024 bytes total per the old scheduler post, 64 bytes per task in
  newer); needs a clean measurement.
- Whether any SV2 pool actually uses `current_thread` vs `multi_thread`
  for the connection-handling layer (cf. round-1 sv2-apps config).
- TokioConf 2026 talks (May 29 2026 videos posted) — playlist not yet
  pulled; may contain perf data we missed.

## Sources

- `2026-06-24-r2-pathC-tokio-changelog-2024-2026.md` — tokio 1.42-1.52
  CHANGELOG.md perf-relevant entries with dates, PR numbers
- `2026-06-24-r2-pathC-tokio-lifo-regression.md` — issue #8065 +
  PR #7431 + PR #8120, the LIFO-stealing saga and production CPU impact
- `2026-06-24-r2-pathC-cnblogs-4runtime-2024.md` — cnblogs.com piperck
  Dec 2024 benchmark of tokio/tokio-uring/monoio/glommio
- `2026-06-24-r2-pathC-shbhmrzd-tokio-uring-2024.md` — shbhmrzd
  Dec 2024 tokio vs tokio-uring TCP+Kafka benchmark
- `2026-06-24-r2-pathC-monoio-benchmark-2021.md` — monoio official
  benchmark doc (Dec 2021), the canonical multi-core claim
- `2026-06-24-r2-pathC-tokio-perf-prs-2026.md` — PR #7757, #7467,
  #8010, #7340, #7450 — modern perf-relevant tokio PRs
