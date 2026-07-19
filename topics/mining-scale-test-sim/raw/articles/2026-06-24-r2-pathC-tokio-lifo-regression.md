---
title: "Tokio 1.51 LIFO-stealing regression: +8.5% CPU on µs-handler high-QPS service"
source_url: https://github.com/tokio-rs/tokio/issues/8065
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, tokio, rust, scheduler, lifo, regression, primary-source, 2026]
---

# Tokio 1.51 LIFO-slot-stealing regression (issue #8065)

The single most-relevant 2024+ data point for SV2 / mining-scale work
that I found: a production tokio user, **kushudai**, reported on
**2026-04-18** a measurable CPU regression on a workload shaped almost
identically to "stratum share submission":

> "high-QPS lookup service with microsecond-duration handlers and
> no request-path I/O, running on a 4-worker multi-thread runtime"

## The regression in numbers

| Metric (per-worker average) | tokio 1.50.x | tokio 1.52.1 | Ratio |
|-----------------------------|--------------|--------------|-------|
| Worker park count           | 547 / s      | 1,430 / s    | 2.6×  |
| Noop-to-park ratio          | 0.12         | 0.47         | 4.0×  |
| Worker steal count          | 17 / s       | 312 / s      | 18×   |
| Busy duration rate          | 0.034        | 0.047        | 1.38× |
| **Aggregate CPU overhead**  | baseline     | **+8.5%**    |       |

## Root cause

PR #7431 (1.51.0, April 3 2026) added LIFO-slot stealing. To make that
work, `schedule_local()` was modified to unconditionally call
`notify_parked_local()` whenever a parked worker existed — eliminating
a "should_notify" short-circuit. The pre-1.51 fast path: a task placed
in the current worker's own LIFO slot did **not** wake any other
worker. Post-1.51: it always did, producing spurious cross-thread
wakeups whose total cost on a µs-handler service was 8.5% of CPU.

## Lifecycle

- 2026-04-03  tokio 1.51.0 ships with LIFO-stealing (PR #7431).
- 2026-04-18  kushudai files #8065 with the +8.5% measurement.
- 2026-04-14  tokio 1.52.0 ships with LIFO-stealing still enabled.
- 2026-04-16  tokio 1.52.1 — does not fix the issue (different revert).
- 2026-05-04  tokio 1.52.2 reverts PR #7431 (#8100).
- 2026-05+    PR #8120 ("re-enable LIFO slot stealing") opens with an
  `UnparkingMode` enum (`Traditional` vs `Cautious`) to make the
  aggressive wakeup opt-in. Benchmarks on a 24-core Ryzen Threadripper:
  spawn_many_local +17%, ping_pong +14%, but spawn_many_remote_busy2
  -23% and chained_spawn -42% (Criterion noise up to 37%).

## Mining-scale-test implications

This is the closest public proxy we have for "what does the modern
tokio scheduler do at SV2 share-submit rates":

- "high-QPS, microsecond handlers" ≈ stratum share submit (5-20 µs
  validation per share, 300k shares/sec at 1M conns × 0.3 sps).
- The 8.5% CPU swing between 1.50.x and 1.51.0/1.52.0/1.52.1 is **a
  material part of the budget** for a simulator measuring "how many
  shares-per-second can N connections sustain before the validator
  saturates."
- **Operational recommendation: pin the mining-scale simulator's tokio
  version to either `1.50.x` (the pre-regression baseline) or
  `>= 1.52.2` (after the revert).** Avoid 1.51.x and 1.52.0/1.52.1.

## Wider lesson

The tokio scheduler is at a local optimum. Both of the 2026 cycle's
biggest changes — LIFO stealing and sharded spawn_blocking — were
reverted within weeks of shipping. Any benchmark report that doesn't
cite an exact tokio version is essentially unreproducible for our
workload, because version differences are the same order of magnitude
as the difference between "well-tuned tokio" and "tokio with a known
regression."

## Source

- Issue: https://github.com/tokio-rs/tokio/issues/8065
- Reverting PR: https://github.com/tokio-rs/tokio/pull/8100
- Original change: https://github.com/tokio-rs/tokio/pull/7431
- Re-introduction proposal: https://github.com/tokio-rs/tokio/pull/8120
