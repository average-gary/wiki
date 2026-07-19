---
title: "Tokio 2025-2026 performance PRs: sharded spawn_blocking, alt timer, eager driver handoff"
source_url: https://github.com/tokio-rs/tokio/pulls?q=is%3Apr+performance+merged%3A%3E2024-01-01
type: article
ingested: 2026-06-24
quality: 4
confidence: high
tags: [scale, tokio, rust, scheduler, prs, 2025, 2026]
---

# Tokio 2025-2026 performance PRs — what's been merged, what's measured

## PR #7757 — sharded spawn_blocking queue (1.52.0, April 2026)

The largest measured improvement in the 2026 cycle. Replaces the
single-mutex spawn_blocking queue with 16 sharded queues.

| Concurrency | Before    | After    | Change   |
|-------------|-----------|----------|----------|
| 1 thread    | 13.3 ms   | 17.8 ms  | **+34%** |
| 2 threads   | 26.0 ms   | 20.1 ms  | -23%     |
| 4 threads   | 45.4 ms   | 27.5 ms  | -39%     |
| 8 threads   | 111.5 ms  | 20.3 ms  | **-82%** |
| 16 threads  | 247.8 ms  | 22.4 ms  | **-91%** |

Single-thread overhead is real. Reverted in 1.52.1, re-landed.

**Mining-scale relevance: low.** SV2 share-validation in Rust is
typically not `spawn_blocking`-ed (it's sub-µs SHA + sub-ms protocol
work).

## PR #7467 — alternative timer wheel (1.49.0, January 2026)

Sharded per-worker timer wheels behind `tokio_unstable enable_alt_timer`.
The existing tokio 1.45+ timer has a documented contention regression
that ScyllaDB's Latte explicitly upgraded to this to work around.

No public benchmark numbers in the PR body. The PR notes a separate
design doc / issue (#7747) covers benchmarks but the relevant page
content was inaccessible in our research pass.

**Mining-scale relevance: medium.** A SV2 pool may use tokio timers
for vardiff retarget intervals (`gimballock` etc) and connection
keepalive timers. Per-worker sharding helps at 1M conn / many-worker
deployments where the single global timer wheel becomes contended.

## PR #8010 — eager I/O driver / timer handoff (1.52.0, April 2026)

Unstable opt-in via `Builder::enable_eager_driver_handoff()`. When a
worker returns from parking on I/O or timer and is about to poll a
task, it notifies another worker to take the driver. Prevents
starvation when a long-running task holds the driver hostage.

Author note: "controversial" because of increased cross-thread
synchronization. **No public throughput / latency numbers** in the PR.
One user reported moving from "fails on 3rd run" to "100 successful
runs" in their starvation-prone scenario.

**Mining-scale relevance: medium-high.** A simulator that wants
predictable wake-up of timers for vardiff retarget under sustained
share traffic may benefit from this flag if it hits I/O starvation. To
be confirmed empirically.

## PR #7340 — eliminate unnecessary lfence on Local queue tail (1.46.0+)

Replaces an `Acquire` atomic load with a plain pointer dereference for
the local worker queue tail (only modified by the owning worker). On
x86 this eliminates an `lfence`. No published throughput numbers.

**Mining-scale relevance: pervasive but unmeasured.** The hot path of
work-stealing is now lfence-free; whatever speedup it provides applies
to every scheduled task.

## PR #7450 — AtomicWaker::wake swap optimization (1.47.0, July 2025)

Replaces `fetch_and` (compare-and-swap loop on x86) with `swap`
(single `xchg` instruction). Improves the cost of waking a future via
`AtomicWaker`. No published numbers.

**Mining-scale relevance: low.** AtomicWaker is used in primitives
like `Notify`, `oneshot`, and some channel internals. SV2 share-submit
flow doesn't pivot on this primitive.

## PR #8120 — re-enable LIFO slot stealing (open, May 2026+)

Re-introduces the reverted PR #7431 with a configurable
`UnparkingMode` (`Traditional` vs `Cautious`). Benchmarks on a 24-core
Ryzen Threadripper:

- spawn_many_local: +17%
- ping_pong: +14%
- spawn_many_remote_busy2: -23%
- chained_spawn: -42%

Author acknowledges Criterion noise up to 37%.

**Mining-scale relevance: medium.** ping_pong (+14%) is the closest
microbench to SV2 share-submit. If this lands on `Traditional` mode by
default, the kushudai-style production regression may return.

## PR #7871 — vectored writes for `write_buf` (1.50.0, March 2026)

Implements vectored writes when a `Buf` has multiple non-contiguous
chunks. Comment in PR: "small performance boost" but no quantified
number. Relevant for cases where the SV2 framing layer batches multiple
small messages into a single `write_buf` call.

## Net assessment

The 2025-2026 tokio cycle has shipped many small to medium scheduler
improvements with **very limited published benchmark data accompanying
them**. The single largest measured number (-91% spawn_blocking
latency at 16 threads) is for a primitive that mining-pool servers
don't typically rely on for hot-path work.

The 2019 per-task / per-wake numbers remain the best public reference
for absolute scheduler costs. The 2024-2026 data is mostly relative
("this PR made X faster by Y%") with the baseline unspecified.

## Sources

- https://github.com/tokio-rs/tokio/pull/7757
- https://github.com/tokio-rs/tokio/pull/7467
- https://github.com/tokio-rs/tokio/pull/8010
- https://github.com/tokio-rs/tokio/pull/7340
- https://github.com/tokio-rs/tokio/pull/7450
- https://github.com/tokio-rs/tokio/pull/8120
- https://github.com/tokio-rs/tokio/pull/7871
