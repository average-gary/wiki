---
title: "Cloudflare: how to receive a million packets/sec (SO_REUSEPORT, NIC queues)"
source_url: https://blog.cloudflare.com/how-to-receive-a-million-packets/
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, connections, packets, linux, kernel, so_reuseport, primary-source]
---

# Cloudflare: receiving 1M packets/sec on Linux

Canonical reference for Linux kernel networking limits, packet receive
path, and SO_REUSEPORT scaling. Underpins capacity planning for any
mining-pool stratum frontend.

## Hardware in the test

- Dual six-core 2 GHz Xeon (24 logical processors w/ HT)
- 10G Solarflare NIC with 11 RX queues

## Headline numbers

| Setup                                | Throughput         |
|--------------------------------------|---------------------|
| Naive `recvmmsg()`, single thread    | 197k–350k pps       |
| Pinned to one core                   | ~370k pps           |
| Multiple threads on one socket       | DOWN to ~480-500k (lock contention on UDP rx buffer) |
| **SO_REUSEPORT**, separate sockets   | **1.114M pps**      |

## Bottlenecks identified

1. **NIC RX-queue hashing**: hardware only hashed by src/dst IP, not port,
   causing uneven distribution at 11-queue scale.
2. **NUMA penalty**: cross-node placement gave ~**4x slowdown**.
3. **Application processing**: the test app did NO work — practical
   throughput is much lower once you parse and validate.

## Implication for stratum pool servers

- A single Linux box with a 10G NIC can receive >1M packets/sec **only**
  with SO_REUSEPORT and per-CPU socket sharding. ckpool does this
  implicitly via multiple `serverurl` ports + one listener per port + 8192
  backlog. public-pool does this via PM2 cluster + `NODE_CLUSTER_SCHED_POLICY=none`.
- Stratum traffic is much heavier than the test (JSON parse, vardiff
  state, share validation), so real pool packet-rate ceiling is closer to
  100k-500k pps per box, not 1M.

## Implication for scale-test simulator

When simulating the load side (synthetic miners) on the same machine, use
SO_REUSEPORT and bind across all NIC queues, or expect the **simulator
itself** to saturate the kernel rx path before the pool under test does.

## Per-connection memory in Linux TCP

(Not from this article, but routinely cited): minimum sane Linux TCP
socket state is on the order of **4-8 KB kernel-side** (skbuff + sock
struct + minimum tcp_rmem/tcp_wmem). Practical default tcp_rmem/wmem
allocate 87380 / 16384 bytes initial windows, expandable to 6 MB / 4 MB
in the kernel auto-tune path. So **idle steady-state** ≈ 10-20 KB/conn
kernel-side, **active** can balloon to MBs if the app doesn't drain.

For 1M idle stratum connections this means **10-20 GB of kernel memory
alone**, on top of any userspace footprint.
