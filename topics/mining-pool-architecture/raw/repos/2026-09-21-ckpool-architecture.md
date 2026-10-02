---
title: "ckpool — architecture, process model, and operating modes"
source: "https://github.com/ckolivas/ckpool"
type: repos
ingested: 2026-09-21
tags: [ckpool, c-implementation, multi-process, unix-socket-ipc, epoll, connector, stratifier, generator, passthrough, socket-handover, vardiff, in-memory-accounting, uthash, ckmsgq, zmq, capnproto-ipc]
summary: "Con Kolivas's ckpool: the canonical high-performance pool design, C with minimal dependencies beyond glibc, GPLv3. Three cooperating daemons over Unix domain sockets — connector (epoll loop owning all client TCP sockets, 1 KB max message for miners and 16 MB for trusted nodes, client reference counting and recycling, token-bucket rate limiting on subclient creation), stratifier (all mining logic: uthash tables for user_instance/worker_instance/stratum_instance, vardiff, share validation, rolling share-rate averages over 1/5/60/1440/10080-minute windows, one share queue handling both SV1 JSON and SV2 binary submissions), and generator (bitcoind communication and template construction; RPC polling at a 100 ms default, or -blocknotify, or ZMQ, or Cap'n Proto IPC to Core's mining interface; failover across a btcd array). No database in the hot path — accounting is in-memory with optional share logging to files split by block height and workbase. Five operating modes (pool, solo via -B, proxy, passthrough, redirector) and socket handover (-H) for restart without dropping miners. Passthrough nodes are the documented horizontal-scaling story: aggregate many downstream connections into one upstream socket to 'scale to millions of clients'."
authors: [Con Kolivas]
license: GPLv3
repo_state: "Active as of 2026; running in production at solo.ckpool.org"
credibility: high
credibility_score: 6
credibility_rationale: "Primary source code plus maintainer README and shipped config examples; independently extracted by two agents this round (technical + applied) with consistent detail; the software is demonstrably in production."
confidence: high
research_round: 1
research_agent: "technical + applied (merged)"
extraction_note: "Merged from two subagent extractions of the same repo (README, README-CKPOOL_MODES, ckpool.conf, connector.c, stratifier.c, generator.c). File and struct names were reported consistently by both. Performance adjectives ('ultra low overhead', 'massively scalable') are the README's own marketing and carry no measurement — flagged inline."
---

# ckpool — architecture and operating modes

**Con Kolivas (ckolivas)** — C, GPLv3 — https://github.com/ckolivas/ckpool

Self-described as an "ultra low overhead massively scalable multi-process, multi-threaded modular
bitcoin mining pool". Deliberately "minimal outside libraries beyond basic glibc functions."

> **Note on claims.** "Ultra low overhead", "massively scalable", "minimal memory overhead" are the
> README's words with **no published benchmark attached**. No source in this round provided measured
> ckpool throughput. Treat the architecture as evidence; treat the adjectives as not evidence.

## Process model — three daemons over Unix sockets

Unix domain sockets were chosen over TCP for IPC on reliability and performance grounds.

### `connector` (`connector.c`)

Owns every client TCP socket. **epoll(7)** event loop.

- `client_instance` structs with **reference counting**; client recycling and dead-client cleanup.
- Send/receive buffers per client, with flow control tracked via `blocked_time`.
- **`MAX_MSGSIZE` = 1 KB for miners**; **`MAX_REMOTE_MSGSIZE` = 16 MB for trusted nodes.** The
  asymmetry is the architecture: a miner can never make the pool allocate a large buffer.
- Newline-delimited message framing. Non-blocking reads with timeout.
- `SO_SNDBUF` / `SO_RCVBUF` tuning with fallback to unprivileged limits.
- **Token-bucket rate limiting** on subclient creation for passthrough/trusted nodes
  (`subclient_tokens`, periodically refilled) — bounds connection *rate*, not just count.
- Limits: `maxclients` (total concurrent), `maxsubclients` (for passthrough parents).
- Max socket buffer **64 MB** to accommodate a mainnet `getblocktemplate` response (~10 MB JSON).

### `stratifier` (`stratifier.c`)

All mining logic. State lives in `uthash` (`UT_hash_handle`) hash tables:

- **`user_instance`** — per-username: worker list, shares, `best_diff`, auth state, **auth backoff on
  failed attempts**, and rolling share-rate averages `dsps1/5/60/1440/10080` (1 m / 5 m / 1 h / 1 d /
  1 wk).
- **`worker_instance`** — per-workername, aggregating across multiple stratum connections, same stats
  shape.
- **`stratum_instance`** — per-TCP-connection: `enonce1`, current diff, latency, user agent, vardiff
  state (`ssdc` = shares since diff change, `ldc` = last diff change), reject counter.
- **`notify_instance`** — job templates.
- Share queue `sshareq` feeds a unified `shareq_item` that carries **both SV1 JSON and SV2 binary**
  shares. One validation path, two wire formats.
- Pool-level `pool_stats_t`: absolute shares, diff shares, **`unaccounted` vs `accounted`** buckets
  (i.e. an explicit deferred-aggregation boundary), SPS over 1/5/15/60 m and DSPS out to
  360/1440/10080 m.

### `generator` (`generator.c`)

bitcoind communication and work generation.

- `notify_instance` carries `prevhash`, merkle branches, `nbit`, `ntime`, `coinbase1`/`coinbase2`.
- Template acquisition, in order of preference available: **RPC polling** (`blockpoll`, default
  **100 ms**), **`-blocknotify`** via the shipped `notifier` binary, **ZMQ** (`zmqblock`), or
  **Cap'n Proto IPC** (`ipcmining` socket path) to Bitcoin Core's mining interface.
- **Multiple bitcoind failover** via the `btcd` array in config.
- `txntable_t` with refcounting and merkle-tree construction. Limits: **65,535 transactions**
  (2¹⁶ merkle leaves), **8,192 bytes per coinbase component**.
- "New work generation on block changes incorporate full bitcoind transaction set without delay."

## Concurrency primitives

- `ckmsgq` asynchronous message queues with pthread condition variables.
- Multiple `ckmsgq` workers can share one primary queue (`ckmsgq[0]`) to spread load.
- **Priority queueing via head/tail insertion** — urgent messages jump the queue.
- Separate threads for console and file logging so logging cannot block mining.
- Design rationale from the README: *"Event driven communication based on communication readiness
  preventing slow communicating clients from delaying low latency ones."* This is the single most
  important sentence in the repo for architecture purposes — it states the invariant (one slow miner
  must not add latency to a fast one) that motivates the whole event-driven design.

## Storage

**No database for core operation.** Pure in-memory accounting; optional share logging via `-L`,
"divided by block height and workbase", written by a dedicated logging thread. No SQL schema is
shipped.

This is the strongest single data point against per-share durable writes: the most scaled
open-source Bitcoin pool keeps shares out of a database entirely.

## Operating modes (README-CKPOOL_MODES)

1. **Pool** (default) — single coinbase address, hashrate combined.
2. **Solo** (`-B`) — usernames must be valid Bitcoin addresses; 100% of the block reward to the
   solver.
3. **Proxy** — aggregates hashrate and presents it upstream as a single connection. **Requires a
   large `nonce2length` (e.g. 8)** to have enough extranonce space to subdivide.
4. **Passthrough** — transparent per-user proxy; "combine connections to a single socket which can be
   used to scale to millions of clients." This is ckpool's horizontal-scaling mechanism: a tree, not
   a bigger box.
5. **Redirector** — watches shares and redirects active miners to direct pool URLs via stratum
   reconnect.
6. *(Unmaintained)* **Node mode** — geographic distribution with a local bitcoind for block
   propagation.

A single instance can run several modes simultaneously under different `-n` names.

## Operations

- **Socket handover (`-H`)**: "virtually seamless restarts for upgrades through socket handover from
  exiting instances to new starting instance" — the new process inherits the listening socket. This
  is how ckpool avoids a reconnect storm on upgrade, and it is a feature most alternatives lack.
- Process management escalates SIGTERM → SIGKILL.
- Listener accepts runtime commands: `shutdown`, `ping`, `loglevel`, `accept`/`reject`, `reconnect`,
  and stats queries.
- Log rotation every minute; **millisecond-precision timestamps**; **RPC calls slower than 5 s are
  logged** as a bottleneck signal.
- Stratum messaging to live clients for operator notifications.

## Vardiff

"Rapid vardiff adjustment with stable unlimited maximum difficulty handling." Config: `mindiff`,
`startdiff`, optional `maxdiff`. Instant starting difficulty supported.

## Configuration (shipped examples)

TOML-like `ckpool.conf` / `ckproxy.conf`. Notable values: `nonce1length: 4`, `nonce2length: 8`
(critical for proxy subdivision), version mask for version rolling, `update_interval: 30 s`,
`dropidle` for disconnecting idle clients, separate bindings for node / trusted / passthrough
servers, configurable coinbase signature.

## Build dependencies

Required: `yasm`. Optional: `libzmq3-dev` (ZMQ block notifications), `libcapnp-dev` (Core IPC),
`libsodium-dev` (SV2 Noise). SV2 support is modular and compiled conditionally behind `HAVE_SV2`
via `sv2_bridge`, `sv2_codec`, `sv2_conn`, `sv2_jd` (Job Declaration) modules — i.e. SV2 was added
**alongside** the SV1 path rather than replacing it, sharing the same share queue.

## Architectural reading

- **Isolation by process, not by thread.** Client I/O, mining logic, and node communication are
  separate address spaces. A generator stall cannot corrupt stratifier state; a connector restart is
  survivable. This is why the three-daemon split, which looks like extra complexity, is the
  conservative choice.
- **The hot path holds no durable storage and no database.** Everything on the share path is memory
  plus an append-only log written off-thread.
- **Scaling is a tree, not a bigger process.** Passthrough nodes, not threads, are the answer to
  "millions of clients" — and the token bucket exists because a tree amplifies connection-rate
  spikes.
- **Message-size asymmetry as a defence.** 1 KB for untrusted miners vs 16 MB for trusted nodes is a
  cheap, complete answer to buffer-exhaustion from the miner side.
