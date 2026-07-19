---
title: Connection vs validation bottleneck — concrete crossover math
source_type: notes
fetched: 2026-06-24
path: 4
tags: [scale-test, vardiff, share-validation, crossover, math]
---

# Where does share validation actually become a bottleneck?

Derived from the path-4 source set
(`/raw/repos/2026-06-24-path4-*.md`,
`/raw/articles/2026-06-24-path4-sha256-throughput-modern-cpus.md`).

## Inputs (cited)

| Quantity | Value | Source |
|---|---|---|
| SV2 reference pool `shares_per_minute` | 6.0 | sv2-apps `pool-config-bitcoin-core-ipc-example.toml` |
| Equivalent target | 1 share / 10 s / channel | derived |
| ckpool vardiff target ratio | `drr = 0.3` (sweet) | stratifier.c:5805 |
| ckpool target inter-share interval | ~3.33 s | derived from drr |
| ckpool mindiff default | 1 | ckpool.c:1785 |
| ckpool startdiff default | 42 | ckpool.c:1787 |
| Per-share validation cost (ckpool, SHA-NI) | ~5–10 µs | derived |
| Per-share validation cost (SRI Rust) | ~10–20 µs | derived |
| Single-core validation ceiling | 50k–200k shares/s | derived |

## Aggregate share rate vs connections (SV2 defaults, 6 SPM)

| N connections | shares/sec | shares/min | One core busy? (SRI 15 µs) |
|---|---|---|---|
| 1k | 100 | 6,000 | 0.15% |
| 10k | 1,000 | 60,000 | 1.5% |
| 100k | 10,000 | 600,000 | 15% |
| 1M | 100,000 | 6,000,000 | **150% — needs 2 cores** |
| 10M | 1,000,000 | 60,000,000 | needs 15 cores |

At ckpool's tighter ~3.3 s target (≈18 SPM), multiply by 3:

| N connections | shares/sec | One core busy? (ckpool 7 µs) |
|---|---|---|
| 1k | 300 | 0.2% |
| 10k | 3,000 | 2.1% |
| 100k | 30,000 | 21% |
| 1M | 300,000 | **210% — needs 3 cores** |

## Crossover with connection-management cost

Connection-management cost is dominated by:

- Per-connection TCP/QUIC socket (~10–50 KB kernel buffer each):
  N=100k = 1–5 GB of kernel memory. Most kernels max out at
  ~500k–1M sockets per process, gated by `nofile` rlimit / ephemeral
  port range / kernel TCP hash table size.
- Per-connection Noise (SV2) state: ~200 bytes per channel + AES-GCM
  context. At 100k = 20 MB.
- Per-connection async-runtime tasks: tokio task overhead is ~1–3 KB
  per task (stack + waker), so 100k = 100–300 MB.

Total at N=100k connections: ~5–10 GB RAM. Easily fits on a
modern server, but **OS-level file-descriptor / TCP-table limits hit
first**.

Empirically observed connection-saturation thresholds for binary-protocol
TCP servers (well-tuned Linux):
- Default Linux: ~1M sockets / process / IP.
- Kernel-bypass userspace TCP (DPDK / io_uring + AF_XDP): tested into
  the 10M range, but rarely deployed for stratum.

## Concrete crossover

At N=1M connections, single-machine validation needs **2–15 cores
(SV2 6 SPM → ckpool 18 SPM)**. Modern 64-core servers handle that
trivially — share validation is **never** the bottleneck unless the
pool is single-threaded and the box is anemic.

Meanwhile at N=1M, the *connection layer* needs:
- ~10–20 GB RAM
- Open-fd limit raised to 2M+
- Possibly multiple listening addresses to escape the 65k ephemeral
  port limit per (src_ip, dst_ip, dst_port) tuple.

Connection saturation hits **at or before the validation cost
becomes 1 core**.

## When could validation actually be the bottleneck?

1. **Single-threaded share-handling code paths**. If a pool has one
   global `share_lock` (ckpool does — `sdata->share_lock` is a single
   mutex protecting the per-workbase share hashtable), then under
   high share rates the bottleneck is **lock contention**, not CPU
   time. Lock contention at 30k shares/sec across many cores can
   easily exceed validation latency.
2. **Pre-SHA-NI hardware**. Cycles/byte ~10× higher, so 5–20 µs → 50–
   200 µs per share. At N=100k × 6 SPM = 10k shares/s, one core sees
   500 ms–2 s of work per wall-second — **saturates 1 core, then 2,
   then…**.
3. **JD-mode if the JDS hasn't cached the validated template**, but
   that's a per-template cost, not per-share.
4. **Very low vardiff floor + powerful miners**. If a pool sets
   mindiff=1 and a miner submits at full hashrate, the rate of valid
   shares jumps until vardiff catches up. ckpool's vardiff only
   adjusts every 240 s OR every 72 shares (line 5783), so during the
   first 30–60 s of a session, share rates can spike well above
   target. Smoothing isn't instantaneous.

## Counter-evidence sought

I did not find published post-mortems from F2Pool / AntPool / GHashIO
explicitly identifying share validation as the bottleneck. The Bitcoin
mining literature focuses on:
- Connection saturation (most outages attributable to TCP exhaustion
  / DDoS).
- Template-update latency (Compact Block Relay improvements).
- Coinbase tx size / merkle path size scaling (not validation cost,
  but template-distribution cost).

No public post-mortems known to me attribute pool outages to share
validation CPU. The bottleneck is consistently network / DB / connection
state.

## Verdict on user's premise

User: *"vardiff smooths share-validation rate, so connections will
saturate before validation does."*

**Verdict: YES, strongly true, with two caveats.**

- ✅ At modern SHA-NI hardware + multi-threaded share path, validation
  needs 2–15 cores for 1M connections. Connection-layer limits hit
  first.
- ⚠️ Caveat 1: ckpool's global `share_lock` could become a contention
  bottleneck well before CPU saturates. Lock-free or
  per-shard hashtables would push the ceiling much higher.
- ⚠️ Caveat 2: New-connection transient (first 30–60 s) is **not
  smoothed**, since vardiff hasn't kicked in yet. A simulator's
  ramp-up phase can briefly look like a validation bottleneck even
  though steady-state would not.
