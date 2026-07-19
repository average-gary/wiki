---
title: cpuminer-multi --benchmark — offline CPU-bound mining loop (no stratum)
source_url: https://github.com/tpruvot/cpuminer-multi/blob/linux/cpu-miner.c
type: repos
ingested: 2026-06-24
quality: B-
confidence: high
tags: [cpuminer, benchmark, offline, real-cpu, sha256d, comparison]
---

# `cpuminer-multi --benchmark` — what "benchmark mode" actually does

Files: `cpu-miner.c` lines 226 (declaration), 1655–1675 (work
construction), 3231 (CLI parse), 2516+ (per-thread hash counters).

## What benchmark mode is

It is **NOT a stratum simulator**. It's a way to run cpuminer-multi
*without any pool connection* — purely CPU benchmarking the hashing
algorithm. The loop:

```c
if (opt_benchmark) {
    uint32_t ts = (uint32_t) time(NULL);
    for (int n=0; n<74; n++) ((char*)work->data)[n] = n;  // 0,1,2,...,73
    work->data[17] = swab32(ts);
    memset(work->data + 19, 0x00, 52);
    work->data[20] = 0x80000000;                          // SHA256d padding
    work->data[31] = 0x00000280;                          // length 640 bits
    memset(work->target, 0x00, sizeof(work->target));     // target = 0 (impossible)
    return true;
}
```

Construction is:
- `work->data[0..74]` set to byte sequence `0, 1, 2, ..., 73`
- Slot 17 (4 bytes) overwritten with byte-swapped wall-clock time
- Slots 19..30 zeroed (where nonce gets ground)
- SHA256d padding inserted (`0x80000000` at slot 20, length at 31)
- **`target = 0`** so the comparison `hash < target` is never true

Result: the threads grind SHA256d forever, never find a share, never
network anything. The per-thread hashrate counter (`opt_n_threads-1`
in line 2516) reports MH/s.

## Why this is *not* what scale-test-sim wants

- No connection to anything
- No share submission
- No vardiff feedback loop
- No pool-side validation exercise

It's a microbenchmark of the SHA256d inner loop, period.

## Where this is useful in the topic

As a **baseline for CPU-side per-core hashrate** when calibrating a
real-CPU miner like sv2-apps's `mining_device`. If `cpuminer-multi
--benchmark` reports 30 MH/s on your test box, then a 10k-miner
synthetic swarm that needs to fake "100 TH/s per miner" needs
`100 TH/s ÷ 30 MH/s = 3.3 × 10^6×` more throughput than CPUs can
deliver — confirming you cannot use real-CPU mining for scale.

## What `--cputest` does (different mode)

There's also `--cputest` which validates that each algo's SIMD
intrinsics produce the same hash as the scalar reference. Not
relevant to load-testing.

## What about pooler/cpuminer (the other cpuminer)?

`pooler/cpuminer` (used by sv2-apps's `sv1_minerd` integration test
as a downloaded binary, version 2.5.1) has a similar
`--benchmark` mode. sv2-apps uses it *not* in benchmark mode — they
launch it as a real SV1 client pointed at a local proxy on
`127.0.0.1:<random>`, then proxy traffic to the upstream SV2 pool.
That's a single-instance correctness counterparty, not scale.

## Takeaway

cpuminer's `--benchmark` mode is a hash-rate-of-this-CPU oracle,
useful for sizing how many real-CPU miners you could feasibly run
on a test host before saturating cores. For the scale-test-sim
topic, the conclusion is: you cannot use any real-CPU miner —
cpuminer or otherwise — to fake even one ASIC's worth of work, let
alone 1,000 of them. You must use the Poisson-emitter approach
(p2poolv2) or the fixture-target approach (jmeter+mock-bitcoind), or
both.
