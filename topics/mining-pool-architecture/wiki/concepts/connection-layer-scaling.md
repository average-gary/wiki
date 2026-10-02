---
title: "Connection Layer Scaling"
category: concept
sources:
  - raw/notes/2026-09-21-adjacent-systems-design-transfer.md
  - raw/repos/2026-09-21-ckpool-architecture.md
  - raw/repos/2026-09-21-public-pool-and-miningcore-managed-runtime-pools.md
  - raw/articles/2026-09-21-solo-ckpool-production-operations.md
  - raw/data/2026-09-21-pool-scale-and-sizing-constants.md
created: 2026-09-21
updated: 2026-09-21
tags: [c10k, epoll, kqueue, so-reuseport, passthrough, connection-sharding, stateful-tcp, load-balancing, numa, nic-hash, reconnect-storm, socket-handover, geographic-distribution]
aliases: ["C10K", "connection scaling", "passthrough nodes"]
confidence: high
volatility: cold
summary: "Because vardiff flattens share rate, the connection layer is what actually saturates. Scaling it means sharding the accept path (SO_REUSEPORT, worker processes, passthrough trees) rather than growing one event loop — and living with the fact that Stratum is stateful TCP, which defeats ordinary load balancing and leaves a documented gap in how any pool routes miners across regions."
---

# Connection Layer Scaling

> A pool holds thousands to millions of long-lived TCP connections that are mostly idle but
> latency-sensitive. That is the C10K/C10M problem with a broadcast fan-out bolted on. Since
> [[vardiff-as-control-loop|vardiff]] ([vardiff](vardiff-as-control-loop.md)) holds share rate to
> `connections / interval`, this layer — not the validator — is the one that runs out first.

## What the connections cost

| | |
|---|---|
| Kernel memory per connection | **~3 KB** (~3 GB per million), measured at 12M concurrent connections |
| Application state | per-miner difficulty, extranonce assignment, last-share time, rolling averages |
| A single listening port | **never the limit** — uniqueness is on the four-tuple (server_ip, server_port, client_ip, client_port) |
| Thread-per-connection | dead on arrival: a 2 MB stack caps you at ~500 connections per GB |

So sockets are cheap and threads are not. Every serious pool is either event-driven or async.

## Sharding the accept path

The measured lesson from outside mining: **contention on a shared accept/receive path is the
bottleneck, and `SO_REUSEPORT` removes it.** Cloudflare's progression — naive single thread 197–370k
pps, dual-core multi-IP 650k, `SO_REUSEPORT` with 4 threads **1.10–1.15M**, NUMA-aligned **1.4M** —
attributes the big step specifically to eliminating lock contention on the shared receive buffer.
Crossing NUMA nodes costs **4×**; hyperthreading on shared physical cores cost ~50%.

A Go benchmark across 13 server designs on 40 cores found single-threaded epoll at 42k TPS against
198k for multiple epoll, 203k for goroutine-per-connection, and 444k for prefork — i.e. **multi-core
distribution is worth 4–10×, and which multi-core arrangement you pick is worth much less.**

Every production pool implements some version of this:

- **ckpool** — a dedicated `connector` process owning all client sockets on an `epoll` loop, separate
  from the `stratifier` (mining logic) and `generator` (node communication), communicating over Unix
  domain sockets.
- **public-pool** — Node cluster with `STRATUM_MAX_CONNECTIONS_PER_LISTENER` defaulting to 10,000 per
  worker per port, and `NODE_CLUSTER_SCHED_POLICY=none` required so the **OS** distributes accepted
  connections rather than Node round-robining them. That env var is `SO_REUSEPORT` arriving in a
  JavaScript pool by another name.
- **Miningcore** — async/await over .NET's task scheduler.

### One hazard specific to mining

NICs hash **(src_ip, dst_ip)** to select an RX queue; **ports are not in the hash**. A farm running
10,000 miners behind a single NAT address therefore lands on **one queue and one core**, and no amount
of `SO_REUSEPORT` fixes it. Large-farm aggregation behind one source IP is a realistic deployment, so
this is a live hot-spotting risk rather than a theoretical one.

## Scaling out: the passthrough tree

ckpool's answer to "millions of clients" is not a bigger process — it is **passthrough nodes**:
transparent per-user proxies that "combine connections to a single socket which can be used to scale to
millions of clients." The pool becomes a tree, with the core pool never directly exposed to client
connections.

Two consequences the repo handles explicitly:

- **A tree amplifies connection-rate spikes**, so the connector applies **token-bucket rate limiting**
  to subclient creation (`subclient_tokens`, periodically refilled). Bounding connection *rate*, not
  just count, is the part usually forgotten.
- **Message-size asymmetry as a defence**: `MAX_MSGSIZE` is **1 KB for miners** but
  `MAX_REMOTE_MSGSIZE` is **16 MB for trusted nodes**. An untrusted miner can never make the pool
  allocate a large buffer. Cheap, complete, and worth copying.

But aggregation collides with the placement rule from
[[vardiff-as-control-loop|vardiff]] ([vardiff](vardiff-as-control-loop.md)): once shares are
aggregated, individual miners' silence is invisible. **Wherever you aggregate, the per-miner control
loops must sit on the downstream side of the aggregation point.** This is what makes the
proxy/gateway — ckpool's passthrough, SRI's translator, DMND's `demand-cli`, Ocean's DATUM gateway —
the architecturally pivotal component rather than a mere fan-in device.

## Routing stateful connections across regions

Stratum cannot be round-robined. A connection carries difficulty state, extranonce assignment and job
history; moving it mid-session loses all of it.

**Round 2 answered this** — see
[[regional-routing-and-session-continuity|Regional Routing and Session Continuity]] ([Regional Routing and Session Continuity](regional-routing-and-session-continuity.md)).
In short: the major pools (AntPool, F2Pool, ViaBTC, Foundry, Braiins, Poolin, SpiderPool) sit behind
**Cloudflare anycast**, where the **edge terminates TCP** so session state never has to move; and
**migrating an established connection between servers is unsolved** for stateful TCP without
application-layer resumption, which Stratum lacks. `SO_REUSEPORT` distributes *new* connections only —
the kernel cannot move an established one between processes.

So the LB layer can be reloaded hitlessly while a **backend** restart still breaks every session on it,
and consistent hashing bounds the blast radius rather than preserving sessions.

Still undocumented:

- **Hot/standby topology for template sources.** ckpool supports a `btcd` failover array, but nothing
  describes whether regional deployments run active-active nodes, how a switch is detected, or how
  template consistency is maintained across regions.
- **Reconnect storms.** Repeatedly named as a likely operational pain point; **no published
  postmortem of one was found.** The circumstantial evidence that it is real is ckpool's **socket
  handover (`-H`)**, which lets a new process inherit the listening socket from the exiting one for
  "virtually seamless restarts" — the only pool-side instance of the technique anywhere, and an
  engineered answer to a problem someone clearly had. Most alternatives have no equivalent, so an upgrade
  drops every connection at once. Note that a CDN edge POP failure produces exactly the same
  *synchronised* reconnect event, which is the dangerous form.

## Kernel and OS tuning

From the C10K survey and the benchmarks that followed it:

- **Edge-triggered `epoll` / `kqueue`**; level-triggered `select`/`poll` degrades past ~1k
  (`/dev/poll` at 750 clients showed ~10% of `poll()`'s overhead).
- `fs.file-max`, `ulimit -n`, `net.nf_conntrack_max` sized above the connection target;
  `tcp_tw_reuse`.
- **`tcp_rmem` max at 2–4 MB, not 32 MB.** A Cloudflare postmortem traced 1-second tail latencies to
  `tcp_collapse` garbage-collecting oversized receive buffers (~1,500 invocations over 300 s, up to
  21 ms each); cutting the max took `net_rx_action` worst case from 23 ms to 3 ms. Stratum messages are
  ≤1 KB, so big buffers buy nothing and cost tail latency.
- NIC RX-queue IRQ affinity (`smp_affinity`) spread across cores.
- An overload heuristic worth stealing: the **"smoothed number of clients with I/O ready"** as a load
  metric, with **refusing new connections** — not degrading established ones — as the response.

## What *not* to build

At ~1 µs per share validation and share rate bounded by `connections / interval`, a 23,000-connection
pool does ~2,300 shares/sec, roughly **0.2% of one core**. Kernel bypass (DPDK), io_uring, and
zero-copy share parsing are answers to throughput problems this workload does not have. The binding
constraints are **connection count, per-miner control-loop correctness, and job-push tail latency**.
See [[pool-sizing-model|the sizing model]] ([the sizing model](../references/pool-sizing-model.md)).

## See Also

- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](the-two-hot-paths.md))
- [[regional-routing-and-session-continuity|Regional Routing and Session Continuity]] ([Regional Routing and Session Continuity](regional-routing-and-session-continuity.md)) — the across-regions half.
- [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](vardiff-as-control-loop.md)) — why this layer is the one that saturates, and the placement rule that constrains aggregation.
- [[pool-sizing-model|Pool Sizing Model]] ([Pool Sizing Model](../references/pool-sizing-model.md))
- [[pool-implementation-survey|Pool Implementation Survey]] ([Pool Implementation Survey](../topics/pool-implementation-survey.md))
