---
title: "Tokio scheduler benchmarks (work-stealing rewrite)"
source_url: https://tokio.rs/blog/2019-10-scheduler
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, connections, tokio, rust, scheduler, benchmark, primary-source]
---

# Tokio scheduler: micro-bench numbers

The tokio.rs blog post from 2019 documenting the move to a work-stealing
scheduler. Numbers are stale (newer optimizations exist), but they are
the most-cited primary source on tokio task throughput.

## Hyper hello-world (wrk -t1 -c50 -d10)

- Old scheduler: **113,923 req/s**
- New scheduler: **152,258 req/s**   (+34%)

## Tonic gRPC: ~10% speedup

## Task-scheduling microbenches (lower is better)

| Benchmark      | Old        | New        | Speedup |
|----------------|------------|------------|---------|
| chained_spawn  | 2.02M ns   | 168.8K ns  | **11.9x** |
| ping_pong      | 1.28M ns   | 562.6K ns  | 2.3x    |
| spawn_many     | 10.28M ns  | 7.32M ns   | 1.4x    |
| yield_many     | 21.45M ns  | 14.64M ns  | 1.5x    |

## Per-task overhead

- One allocation per task (down from two)
- Eliminated atomic inc/dec cycles in wake-by-ref via scheduler-maintained
  task lists.

## Implication for stratum pool servers in Rust

If a Rust SV2 pool spawns one task per connection (typical pattern):
- task spawn cost ≈ ~7 µs (`spawn_many / N` ≈ ~70 µs/spawn but parallel)
- task wakeup cost ≈ sub-µs
- A `chained_spawn` chain of 1000 hops in 168 µs ⇒ ~170 ns/wake/hop in
  the inlined fast path.

For 1M connections at 0.3 shares/sec each (ckpool vardiff target):
- 300k tasks woken/sec for share submission
- 300k × ~1 µs scheduler-overhead = ~0.3 sec of CPU/sec ⇒ ~30% of one core
- This is non-trivial: at 1M connections the scheduler alone takes ~1/3
  of a core just for share-submit wakeups, BEFORE you do any work.

## Caveats

- Numbers are from 2019; tokio has had 5+ years of further optimization.
- `chained_spawn` and `ping_pong` are micro-benchmarks; real stratum
  workload has per-connection state, JSON parse, channel state mutation,
  validation — net cost per share is dominated by these, not scheduler.
- For genuinely scale-relevant Rust async numbers in 2025+, look for
  blog posts comparing **monoio** / **glommio** / **compio** vs tokio at
  1M-connection scale. (Not found in this research pass — open question.)
