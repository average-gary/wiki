---
title: "Adjacent-systems evidence: C10K/C10M, SO_REUSEPORT sharding, async runtimes, batched ingest, single-writer, tail latency"
source: "http://www.kegel.com/c10k.html"
related_sources:
  - "https://blog.cloudflare.com/how-to-receive-a-million-packets/"
  - "https://blog.cloudflare.com/the-story-of-one-latency-spike/"
  - "https://tokio.rs/blog/2019-10-scheduler"
  - "https://docs.influxdata.com/influxdb/v1.8/concepts/storage_engine/"
  - "https://mechanical-sympathy.blogspot.com/2011/09/single-writer-principle.html"
  - "https://mrotaru.wordpress.com/2013/10/10/scaling-to-12-million-concurrent-connections-how-migratorydata-did-it/"
  - "https://github.com/smallnest/1m-go-tcp-server"
  - "https://github.com/disruptor-net/Disruptor-net/wiki/Getting-Started"
type: notes
ingested: 2026-09-21
tags: [c10k, c10m, epoll, kqueue, so-reuseport, numa, tokio, work-stealing, async-runtime, batched-writes, wal, single-writer-principle, lock-contention, tail-latency, tcp-collapse, tcp-rmem, ring-buffer, disruptor, connection-memory, fan-out]
summary: "Nine general-systems sources aggregated as one research note, because a mining pool is a special case of a well-studied problem — a stateful long-lived-TCP fan-in server with low-latency broadcast fan-out and a high-rate small-message ingest path. Load-bearing measured figures: SO_REUSEPORT sharding took Cloudflare from 650k to 1.15M packets/sec by removing lock contention on a shared receive buffer, with a further step to 1.4M from NUMA alignment and a 4x penalty for crossing NUMA nodes; MigratoryData sustained 12M concurrent WebSocket connections on one 24-core box at roughly 3 KB of KERNEL memory per connection (3 GB per million) and 200k messages/sec; Martin Thompson's single-writer measurements put two-thread CAS at 60x and two-thread locking at 393x the cost of a single thread doing the same 500M increments; Tokio's work-stealing scheduler delivered +34% throughput and -26% latency on a real HTTP benchmark; InfluxDB's TSM engine batches 5,000-10,000 points per fsync rather than durably writing each event; and a Cloudflare tail-latency postmortem traced 1-second outliers to tcp_collapse garbage-collecting oversized receive buffers, fixed by cutting tcp_rmem max from 32 MB to 2-4 MB. Each is annotated with how it maps onto pool internals."
credibility: high
credibility_score: 5
credibility_rationale: "Individually strong primary engineering accounts with published measurements (Cloudflare, Tokio, MigratoryData, Thompson). Aggregated into one note because none is about mining pools; the transfer to pool design is this session's and the agent's inference, not the sources' claim."
confidence: high
confidence_rationale: "High for the measured figures in their original domains. The pool mappings are reasoned transfers, explicitly graded below — do not present them as measured facts about pools."
research_round: 1
research_agent: adjacent
transfer_warning: "No source in this file measured a mining pool. Every 'maps to pool' statement is an inference. Graded high / medium / speculative at the end."
extraction_note: "Subagent extraction across nine sources, condensed. Two low-value sources from the same report (Cloudflare Workers isolates, scored 3/5 and explicitly inapplicable; Disruptor-net getting-started with no benchmarks) are retained only as the notes below."
---

# Adjacent-systems evidence

A pool is: thousands of long-lived TCP connections, mostly idle, latency-sensitive on a broadcast
(job push), with a high-rate small-message ingest (share submit) and an accounting write path. Every
one of those is a solved problem somewhere else.

## Connection handling

**The C10K problem** (Dan Kegel) — the canonical survey. Hardware stopped being the constraint around
2001 (at 20k connections on a 1 GHz/2 GB/1 Gbps box each client gets ~50 kHz of CPU, ~100 KB of RAM,
~50 kbps). Five architecture families:

1. **Level-triggered readiness** (`select`/`poll`/`/dev/poll`) — simple, doesn't scale; Solaris
   `/dev/poll` showed ~10% of `poll()` overhead at 750 clients.
2. **Edge-triggered readiness** (`epoll`/`kqueue`) — kernel signals state *transitions*; OLS 2002
   benchmarks made kqueue and epoll the "clear winners" on event latency. epoll coalesces redundant
   events; needs care to avoid stalling.
3. **Async I/O with completion notification** — mattered for disk, not sockets at the time.
4. **Thread-per-client** — memory-bound: at a 2 MB stack, ~512 threads exhausts 1 GB of user space on
   32-bit. NPTL (1:1) benchmarked "significantly better" than M:N.
5. **In-kernel servers** (khttpd/TUX) — fastest, least portable.

Also: FD limits are tunable to 31k–90k+ (tested on old kernels); `sendfile()` for zero copy;
`TCP_CORK` to suppress small frames; and an overload heuristic — **"smoothed number of clients with
I/O ready"** as a load metric, with **dropping connections during overload improving the shape of the
curve**. Vivek Pai's Flash-server caveat is worth keeping: *"the big performance win stems from
application-level caching… marginal difference from software architecture"* without it.

**→ Pool.** Edge-triggered epoll/kqueue is the direct fit and is what ckpool uses in its `connector`.
The overload heuristic maps onto refusing *new* connections rather than degrading existing miners'
service. `sendfile` is irrelevant (no file serving).

**MigratoryData — 12M concurrent connections** (2013). Dell R610 1U, 24 cores, Intel X520-DA2 10 Gbps
(24 tx/rx queues), 96 GB RAM / 54 GB JVM heap.

- **A single listening port accepts any number of clients** — the four-tuple
  (server_ip, server_port, client_ip, client_port) is what must be unique, so server-side port count
  is never the limit. (Worth stating because it is a persistent misconception.)
- **~3 GB of kernel memory per million connections (~3 KB each)**; kernel 3.9.4 avoided an extra
  4 KB/socket that older 2.6.x carried.
- JVM: 55,296 MB heap, `UseCompressedOops`, `ObjectAlignmentInBytes=16` to keep pointer compression
  above the 32 GB threshold.
- **12M connections sustained at 200k messages/sec**, 512-byte payload, mean latency **269.68 ms**
  (σ 420.36 ms).
- Client side needed **19 IP aliases per load generator** — ~65k connections per source IP from the
  ephemeral port range. Relevant for *load testing*, not production.
- NIC IRQ balancing across cores via `smp_affinity`.

**→ Pool.** 3 KB/connection kernel-side means connection *count* is cheap: 100k connections ≈ 300 MB
kernel. The binding constraint is message rate and application state, not sockets. Note the contrast
with DATUM's published guidance of ~1 GB per 1,000 clients (~1 MB each) — ~300× higher, which must be
application state, not kernel.

**Go 1M-connection benchmark** (13 implementations, 40 logical cores, 32 GB):

| Model | Throughput (TPS) | Latency |
|---|---|---|
| goroutine-per-connection | 202,830 | 4.9 s |
| single epoll (server) | 42,402 | 0.8 s |
| **multiple epoll** | 197,814 | 0.9 s |
| **prefork** | **444,415** | 1.5 s |
| **workerpool** | 190,022 | **0.3 s** |

Tuning required: `fs.file-max=2000500`, `net.nf_conntrack_max=2000500`, `tcp_tw_reuse`,
`ulimit -n`. **Single-threaded epoll is 4–10× worse than any multi-core arrangement** — the headline.

**→ Pool.** Prefork (multiple processes over `SO_REUSEPORT`) wins throughput; workerpool wins latency;
plain async is competitive and simplest. Given the corrected finding that share validation is ~1 µs,
the CPU-heavy-worker case barely applies — argues for the simple async or prefork end.

## Sharding the accept path

**Cloudflare, "How to receive a million packets per second"** — progressive measurement:

| Step | pps |
|---|---|
| naive single thread | 197k–370k |
| dual-core, multi-IP | 650k |
| **`SO_REUSEPORT`, 4 threads** | **1.10M–1.15M** |
| + NUMA-aligned | **1.4M** |

- Multiple processes bind the *same* port with separate socket descriptors; the kernel distributes,
  **eliminating lock contention on the shared receive buffer — which was the bottleneck**.
- NICs hash (src_ip, dst_ip) to RX queues; **ports are not in the hash**, so distribution is limited
  unless multiple destination IPs are configured.
- **Cross-NUMA costs 4×.** Hyperthreading on shared physical cores cost ~50% versus isolated cores.
- `sendmmsg`/`recvmmsg` batch syscalls.
- **Stated caveat: "the application was NOT doing actual processing."** Real work lowers the ceiling.

**→ Pool.** This is the mechanism behind public-pool's `NODE_CLUSTER_SCHED_POLICY=none` (let the OS
distribute accepts) and behind ckpool's multi-process split. The NIC-hash detail matters for a pool:
since the hash excludes ports, connections from *one* large farm behind *one* source IP land on *one*
queue. A farm with 10,000 miners behind a single NAT is a hot-spotting hazard no amount of
`SO_REUSEPORT` fixes.

## Async runtime

**Tokio work-stealing scheduler** (2019). Per-processor run queues (single-producer, multi-consumer)
with bounded fixed-size queues using Acquire/Release rather than SeqCst; overflow to a global
mutex-guarded queue. *"Under load, almost no contention on queues since each processor only accesses
its own."* A **"next task" slot** prioritises just-woken tasks for immediate execution (cache locality
+ latency). Work-stealing is **throttled** — at most half the processors search at once — to avoid a
thundering herd. One allocation per task; scheduler-held task list removes refcount traffic in
`wake_by_ref()`.

Measured: `chained_spawn` 2.0 ms → 168 µs (11.9×), `ping_pong` 1.3 ms → 562 µs (2.3×), `spawn_many`
10.3 ms → 7.3 ms (1.4×). **Real Hyper HTTP: 113,923 → 152,259 req/sec (+34%), latency 371 µs → 275 µs.**
Validated with Loom permutation testing, which "found more than 10 bugs missed by other unit tests."

**→ Pool.** Tokio is the default for a Rust pool (and the presumed, unconfirmed runtime of sv2-apps).
The **"next task" slot is the directly relevant feature for job push**: waking N connection tasks to
deliver a new job should run immediately rather than queue behind unrelated work. Async also avoids the
thread-per-connection memory wall entirely.

## The ingest path

**InfluxDB TSM engine.** *Batch 5,000–10,000 points* to amortise fsync. Points are serialised,
Snappy-compressed, appended to a WAL; **fsync only once per batch, not per event**. WAL segments hold
multiple compressed blocks and close at 10 MB for sequential I/O; TLV framing (1-byte type, 4-byte
length). Multi-level compaction (levels 1–4) moves data from write-optimised to read-optimised; cache
snapshots to TSM files on memory thresholds. Claimed up to **45× disk-space reduction versus BoltDB**
with higher write throughput; "hundreds of thousands of writes per second" typical, "millions" for
large deployments.

**→ Pool.** Shares *are* time-series (timestamp, worker, difficulty, job). The batch-then-fsync pattern
is the direct answer to per-share write amplification, and the hot/cold split maps onto recent shares
(needed for payout windows) versus archived shares. Note that ckpool sidesteps this entirely by keeping
accounting in memory and writing an append-only log off-thread — the laziest version of the same idea.

**Single-writer principle** (Martin Thompson). *"For any item of data, that item should be owned by a
single execution context for all mutations."* Measured, 500M counter increments on a 2.4 GHz Westmere:

| Arrangement | Time | Relative |
|---|---|---|
| single thread | 300 ms | 1× |
| single thread + memory barrier | 4,700 ms | **15.7×** |
| two threads, CAS | 18,000 ms | **60×** |
| two threads, locks | 118,000 ms | **393×** |

Contention overhead — context switches, cache invalidation, kernel involvement — exceeds the actual
work. Patterns: Disruptor ring buffer with one writer per slot and independent consumer read positions;
for multiple producers, separate single-producer queues into a multiplexer. Read-only copies propagate
free via cache coherency.

**→ Pool.** The anti-pattern is named precisely: several stratum workers contending on one shared
share/stats map under a lock. The fix is per-worker (or per-miner-shard) counters with no lock, flushed
periodically to a single accounting owner. ckpool's `unaccounted`/`accounted` split in `pool_stats_t`
is exactly this boundary, and its `ckmsgq` queues are the multiplexer. **393× is the number that
justifies the architecture.**

**Disruptor ring buffer** — fixed power-of-2 capacity, pre-allocated mutable events, claim/configure/
publish, single- vs multi-producer modes, backpressure blocks publishers when full. *(No benchmarks in
the source consulted; the measured case for it is Thompson's note above.)*

**→ Pool.** Shares in (multi-producer, from connection workers) → ring → accounting (single consumer,
batching to storage). Jobs out (single producer) → ring → fan-out workers. Backpressure policy is a
real decision: **block rather than drop, because a dropped share is money.**

## Tail latency

**Cloudflare, "The story of one latency spike."** *"5 requests out of thousands took as long as
1000 ms."* Delays clustered at 1, 3, 7, 15, 31 s — TCP retransmission backoff. Root cause:
**`tcp_collapse`**, which garbage-collects TCP receive buffers by merging adjacent packets under memory
pressure. Over 300 s: ~1,500 `tcp_collapse` executions, max 21 ms each. Configuration was
`net.ipv4.tcp_rmem = 4096 5242880 33554432` (32 MB max). **Fix: reduce to 2 MB max (settled at 4 MB)**
→ `net_rx_action` max latency **23 ms → 3 ms**, outliers gone.

**→ Pool.** Job push is the latency-critical path: a stall delays that miner's new job and produces
stale shares. Stratum messages are tiny (jobs ~1 KB, shares ~100 B), so **large receive buffers buy
nothing and cost tail latency.** Keep `tcp_rmem` max at 2–4 MB and monitor **p99/p999, not mean** — a
per-connection stall is invisible in an average across 23,000 connections.

## Counter-example kept deliberately

**Cloudflare Workers / V8 isolates** — hundreds-to-thousands of isolates per runtime, ~100× faster
cold start than a Node process, but **"no guarantee any two requests route to the same or a different
instance; do not use or mutate global state"** and isolates may be evicted. **Inapplicable**: a pool is
stateful by nature (long-lived TCP, per-miner difficulty, extranonce assignment, session continuity).
Recorded because the *negative* result is useful — it delimits the design space. A "serverless pool"
would need an external session store on the hot path, which trades the one thing edge deployment was
supposed to buy.

## Transfer grading

**High confidence — directly measured in the source domain, mechanism identical:**

1. Edge-triggered `epoll`/`kqueue` for 10k+ long-lived connections; level-triggered doesn't scale.
2. `SO_REUSEPORT` sharding removes accept-path/receive-buffer lock contention (650k → 1.15M pps).
3. Async runtimes avoid the thread-per-connection memory wall (2 MB stack → ~500/GB).
4. ~3 KB kernel memory per connection; connection count is cheap.
5. Batch 5k–10k events per fsync; never durably write per event.
6. Single-writer: locks cost 393× — shard mutable state per owner.
7. `tcp_rmem` max 2–4 MB, not 32 MB; watch p99/p999.
8. NUMA alignment matters (4× penalty).
9. Work-stealing with a fast path for woken tasks: +34% throughput, −26% latency.
10. Multi-level hot/warm/cold compaction for time-series retention.

**Medium — strongly suggested, not measured on this workload:**

11. Prefork over `SO_REUSEPORT` maximises network-I/O throughput (444k TPS in the Go benchmark).
12. Ring buffers over mutex queues for internal hand-off.
13. Batch fan-out writes (`writev`, io_uring) for job push.
14. NIC RX-queue IRQ balancing via `smp_affinity` to saturate 10G+.
15. Tune `fs.file-max`, `nf_conntrack_max`, `tcp_tw_reuse` before 10k connections.

**Speculative — logical, no supporting evidence in any source here:**

16. Per-miner session affinity via consistent hashing or client-IP-hashed `SO_REUSEPORT`.
17. Separating the fast path (job push, share accept) from the slow path (vardiff recompute, payout) to
    avoid head-of-line blocking.
18. Snappy-style compression on persisted share logs.
19. Memory-mapped share logs for zero-copy payout reads.
20. Under overload, refuse new connections rather than degrade established miners.

**One important negative from the corrected sizing work**: several of these optimisations target
throughput ceilings a Bitcoin pool never reaches. At ~1 µs per share validation and share rate bounded
by `connections / vardiff interval`, a pool with 23,000 connections is doing ~2,300 shares/sec —
roughly 0.2% of one core. Kernel-bypass, io_uring and DPDK are answers to problems this workload does
not have. **The binding constraints are connection count, per-miner control-loop correctness, and job
push tail latency** — which is why items 1, 6, 7 and the Optech vardiff placement rule matter far more
than items 11–14.
