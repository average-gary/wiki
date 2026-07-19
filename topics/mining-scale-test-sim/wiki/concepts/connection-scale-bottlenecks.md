---
title: "Connection-scale bottlenecks — what saturates first"
type: concept
created: 2026-06-24
confidence: high
tags: [scale, bottleneck, tcp, noise, tokio]
---

# Connection-scale bottlenecks

For a Rust/C SV2 pool on a modern 8-16 core box with a 10G NIC,
saturation order from 1k → 1M concurrent stratum connections:

| # | Bottleneck | Hits at | Mitigation |
|---|------------|---------|------------|
| 1 | Ephemeral port exhaustion on simulator host (5-tuple) | ~28-64k from one source IP | Multiple source IPs (`ip addr add … dev eth0`); 5-10 aliases × 64k = 300-600k per host |
| 2 | `listen()` + SYN-flood backlog | `net.core.somaxconn` default 4096; ckpool sets 8192 | Raise `somaxconn` to 65535; `sysctl tcp_max_syn_backlog` |
| 3 | Noise handshake CPU during reconnect storm | ~5,600 conn/sec/core (178 µs SRI step_1_responder) | 8 cores → 45k conn/sec; for 1M reconnect → ~22 sec full-CPU |
| 4 | Kernel socket memory | ~10-20 KB per idle conn → 10-20 GB at 1M | Tune `tcp_rmem/tcp_wmem`, accept slow pages |
| 5 | Userspace per-conn memory | ckpool ~1-2 KB; Rust SV2 ~5-15 KB; **Node.js ~250 KB** | Pick C/Rust; Node.js pool dies at ~10k/worker |
| 6 | Async-runtime scheduler wakeups | tokio: ~30% of one core at 300k sps (2019 num; round-2 path C found no 2024-2026 benchmark refuting it at this scale) | **Pin `tokio = "1.50"` or `>=1.52.2`** to avoid the LIFO-slot-stealing regression in 1.51.x / 1.52.0 / 1.52.1 (issue #8065, +8.5% CPU at microsecond handlers, reverted in 1.52.2). For io_uring on TCP, swap runtime to monoio or compio — `tokio-uring` is fs-only as of v0.5.0 (2024-05-27). |
| 7 | conntrack table | silent killer at high accept rate | Disable or `nf_conntrack_max = 4 × N_conns` |
| 8 | Share-validation throughput (steady state) | ~50-100k sps/core (SRI), ~100-200k sps/core (ckpool/SHA-NI) | [[share validation cost model|See cost ledger]] |
| 8b | **Validation during burst-connect ramp-up** | **~385 cores @ N=100k S19, 130 ms** | [[share validation cost model|Caveat 2]] — flips the bottleneck temporarily |

[[the bottleneck thesis|The bottleneck thesis]] is supported in steady
state: rows 1-7 hit before row 8. **Row 8b inverts the order for
~130 ms during burst-connect ramp-up** — validation IS the bottleneck
during the first-retarget window.

## Concrete numbers from primary sources

### Noise handshake (SRI bench)

From `stratum-mining/stratum :: sv2/noise-sv2/BENCHES.md`:

| Step | Direction | Cost |
|------|-----------|------|
| step_0_initiator | downstream-side | 18.7 µs |
| **step_1_responder** | **pool-side** | **178.1 µs** |
| step_2_initiator | downstream-side | 120.9 µs |
| Full handshake (3-msg Noise_NX) | — | 317.4 µs |
| Transport roundtrip (64 B) | — | 5.2 µs |
| Transport roundtrip (256 B) | — | 5.5 µs |
| Transport roundtrip (1 KB) | — | 7.3 µs |
| Transport roundtrip (4 KB) | — | 16.4 µs |

**Pool-side ceilings**:
- One core: ~5,600 handshakes/sec
- 8 cores: ~45,000 handshakes/sec
- 16 cores: ~90,000 handshakes/sec

Steady-state share transport is essentially free at <2% of one core
even at 100k connections — handshake is the spike, not the average.

### Per-connection memory

| Implementation | Per-conn userspace | Source |
|---------------|--------------------|---------|
| ckpool (C, epoll) | ~1-2 KB | `connector.c` struct + 1 KB read buffer |
| **public-pool (Node.js + NestJS)** | **~250 KB** | 2.5 GB RSS / 10k conn worker threshold |
| SV2 Rust (extrapolated) | ~5-15 KB | tokio task + 2 Noise CipherStates + bufs |
| Linux kernel TCP (sock+skbs idle) | ~10-20 KB | tcp_{r,w}mem defaults |

**Headline**: a **Node.js stratum** at 1M connections needs ~250 GB
RAM. A **Rust/C stratum** at 1M connections needs ~10-30 GB RAM
(mostly kernel).

### Linux limits to tune

```bash
# fd ceiling
ulimit -n 1000000

# ephemeral port range — get every port possible
sysctl net.ipv4.ip_local_port_range='1025 65534'

# accept backlog
sysctl net.core.somaxconn=65535
sysctl net.ipv4.tcp_max_syn_backlog=65535

# socket buffer defaults (smaller per-conn at scale)
sysctl net.core.rmem_default=87380
sysctl net.core.wmem_default=16384

# disable conntrack on load host or raise limit
sysctl net.netfilter.nf_conntrack_max=4000000
```

## Per-source-IP multiplier

The Linux 5-tuple `(src_ip, src_port, dst_ip, dst_port, proto)` must be
unique. A single source IP → ~64k usable ports → 64k connections to
**one** `(dst_ip, dst_port)`. To scale a single load-host to 1M
connections, alias 16+ source IPs:

```bash
for i in $(seq 1 16); do
  sudo ip addr add 10.0.0.$((10+i))/24 dev eth0
done
```

emqtt-bench's `--ifaddr 10.0.0.10,10.0.0.11,...` flag is exactly this
pattern; reuse it.

## Recommended sweep points

| N (connections) | What to observe |
|-----------------|-----------------|
| 1k | Trivial baseline. ~100-300 sps. |
| 10k | Single Node.js worker ceiling. public-pool backpressure. |
| 30k | Single source-IP ephemeral port wall. |
| 50k | Single tokio core's task-wakeup budget measurable. |
| 100k | ~10-30k sps at default SPM. Kernel TCP memory ~1-2 GB. |
| 280k | public-pool's documented production scale (28 × 10k workers). |
| 500k | Kernel memory ~5-10 GB. Reconnect storm ~17 sec at 8-core. |
| 1M | Kernel memory ~10-20 GB. ~100-300k sps. Reconnect storm ~35 sec at 8-core. Requires multi-host driver. |

Plus a **reconnect storm sub-test** at each N: drop 25%/50%/100% of
clients and measure recovery time. This is where handshake CPU shows
up.

## See also

- [[load harness landscape]] — what tool drives this load
- [[synthetic miner patterns]] — what each connection does
- [[gimballock vardiff sim]] — does NOT exercise this layer
- [[the bottleneck thesis]] — premise this evidence supports
