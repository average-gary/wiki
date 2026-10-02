---
title: "Pool Implementation Survey"
category: topic
sources:
  - raw/repos/2026-09-21-ckpool-architecture.md
  - raw/repos/2026-09-21-sv2-apps-pool-role-architecture.md
  - raw/repos/2026-09-21-public-pool-and-miningcore-managed-runtime-pools.md
  - raw/repos/2026-09-21-sri-and-sv2-apps-hardening-releases-2026.md
  - raw/articles/2026-09-21-dmnd-datum-decentralised-template-deployments.md
  - raw/articles/2026-09-21-solo-ckpool-production-operations.md
  - raw/notes/2026-09-21-pool-failure-modes-aggregate.md
  - raw/repos/2026-09-22-sri-pool-share-persistence-source-read.md
  - raw/repos/2026-09-23-blitzpool-source-read.md
created: 2026-09-21
updated: 2026-09-23
tags: [ckpool, sv2-apps, public-pool, miningcore, nomp, datum, dmnd, implementation-comparison, concurrency-model, storage-choice, role-separation]
aliases: ["pool software comparison", "which pool software"]
confidence: medium
volatility: warm
summary: "What the live open-source pool implementations actually do, read on their own terms. The axis that separates them is not language but whether accounting touches a database and whether roles live in one process or several — ckpool splits into three daemons with no database, sv2-apps splits into four binaries so trust boundaries can cross operators, and the managed-runtime pools (Miningcore, public-pool) take a database and push hashing into native code. Blitzpool shows the public-pool schema carried into a Rust split deployment with Redis in front. No benchmark compares them against each other."
---

# Pool Implementation Survey

> Read on their own terms, not ranked. **No benchmark compares these implementations against each
> other.** Round 2 found SV1-vs-SV2 *protocol* benchmarks (see [Pool Sizing Model](../references/pool-sizing-model.md)),
> but nothing measures one implementation against another under the same load, so "fastest" is not a
> question this survey can answer. What it can answer is how each one is *shaped*, and why.

## Comparison

| | Language | Concurrency | Storage | Roles | Distinguishing choice |
|---|---|---|---|---|---|
| **ckpool** | C, glibc only | 3 processes + threads, `epoll`, Unix-socket IPC | **none** (in-memory; optional file log) | one binary, 5 modes | passthrough tree for scale-out; socket handover for restarts |
| **sv2-apps (SRI)** | Rust, MSRV 1.88 | async (tokio presumed, unconfirmed) | **none** — in-RAM, HTTP polling API (round 2) | **4 binaries** (pool, JDS, JDC, translator) | role split across trust boundaries; pluggable template source |
| **Miningcore** | C# / .NET 6 | async/await + **native interop for PoW** | **PostgreSQL 10+** | one process, many coin pools | most explicitly staged share pipeline |
| **public-pool** | TypeScript / NestJS | Node cluster, 10k conns/worker | ORM (relational) | one process | solo/Bitaxe oriented; OS-level accept balancing |
| **Blitzpool** | Rust / tokio | task per socket; SV1+SV2 on one port by first byte | **PostgreSQL 18 + Redis** | front + satellite processes | public-pool port; non-custodial coinbase payouts |
| **node-stratum-pool / NOMP** | JavaScript | Node event loop | via NOMP integration | library, not a daemon | **unmaintained** (issues open 2022–2026) |
| **DATUM gateway** | C | — | — | gateway + miner's own node | miner-sovereign templates **over Stratum V1** |
| **demand-cli (DMND)** | Rust | — | — | miner-side client | SV1→SV2+JD translation on miner premises |

## ckpool — the reference design

Three daemons over Unix domain sockets:

- **`connector`** — owns every client TCP socket on an `epoll` loop. Reference-counted
  `client_instance` structs, client recycling, flow control via `blocked_time`, `SO_SNDBUF`/`SO_RCVBUF`
  tuning, **token-bucket rate limiting on subclient creation**, and the **1 KB / 16 MB message-size
  asymmetry** between untrusted miners and trusted nodes.
- **`stratifier`** — all mining logic. `uthash` tables for `user_instance` / `worker_instance` /
  `stratum_instance` / `notify_instance`; vardiff state per connection (`ssdc`, `ldc`); rolling
  share-rate averages over five windows; **one share queue handling both SV1 JSON and SV2 binary
  submissions** through a unified `shareq_item`.
- **`generator`** — bitcoind communication. Template acquisition by RPC poll (100 ms default),
  `-blocknotify`, ZMQ, or **Cap'n Proto IPC** to Core's mining interface; **`btcd` failover array**;
  `txntable_t` with refcounting, capped at 65,535 transactions and 8,192 bytes per coinbase component.

**Stated design invariant**: *"Event driven communication based on communication readiness preventing
slow communicating clients from delaying low latency ones."*

**Scale-out is a tree, not a bigger process** — passthrough nodes aggregate downstream connections into
one upstream socket "to scale to millions of clients." Five modes (pool, solo `-B`, proxy, passthrough,
redirector), several runnable simultaneously under different `-n` names. Proxy mode needs a large
`nonce2length` (e.g. 8) to have extranonce space to subdivide.

**SV2 was added alongside V1, not instead of it** — conditional `HAVE_SV2` modules (`sv2_bridge`,
`sv2_codec`, `sv2_conn`, `sv2_jd`) feeding the same share queue.

**Production footprint** (solo.ckpool.org): endpoints in US west/east, Germany, Singapore, Australia;
10,000 difficulty floor with a cosmetic client-side floor of 1; separate high-difficulty rental ports
(4334 SV1 / 4336 SV2); **default Core transaction selection with no filtering**, published live at
`/pool.txns`; no registration, no operator wallet, 2% fee.

**Caveat**: "ultra low overhead", "massively scalable" are the README's own words with **no measurement
attached**. The architecture is evidence; the adjectives are not.

## sv2-apps — roles as separate binaries

The consequential decision: **four independent binaries** rather than one daemon with flags.

Splitting **JDS** (pool-side) from **JDC** (miner-side) puts the trust boundary *in the protocol*: the
miner runs the component that builds templates, the pool runs the one that validates and accounts. This
is the structural difference from everything in the ckpool lineage, where template construction is
necessarily pool-side code. The cost is operational — four processes, four configs, four upgrade paths.

**Pluggable template source**, selected by config: an SV2 Template Provider over TCP (optionally
Noise-encrypted, with `public_key` verification), or **Bitcoin Core IPC** over a Unix socket to Core
v30.2+, with `fee_threshold` and `min_interval` exposing the template-refresh control loop as
configuration.

**Config precedence**: TOML overridden by `POOL__`-prefixed environment variables with double-underscore
nesting; **exits with an error if a mandatory parameter is absent from both**. Fully env-driven
deployment is possible.

**Payout identity is parsed from the `user_identity` string** — `sri/donate/…`,
`sri/solo/<addr>/…`, `sri/donate/<pct>/<addr>/…`, with BIP-385 `addr()` descriptor validation. A
string-encoded control channel on an identity field, the same pattern as V1's `account.worker`
convention. It fails **open** (unrecognised → pool payout) except for a malformed `sri/` prefix, which
fails closed.

**NTP is a hard dependency** — certificate validation is time-sensitive, and "a few seconds" of drift
triggers `InvalidCertificate`. A drifting clock costs the pool its template provider.

**Share persistence was not documented, and round 2's source read settled it: there is none.** No
database crate and no file I/O. Counters live in RAM behind an HTTP polling API, and a restart loses them,
**`seen_shares` included**. See [Share Accounting and Durability](../concepts/share-accounting-and-durability.md).
The async runtime remains unconfirmed here.

### Maturity, per the 2026 releases

SRI v1.12.0 and sv2-apps v0.8.0 (both 2026-09-17) are a hardening pass, and the changelog is a useful
inventory of what production requires: `nTime` **upper** bounds on share validation (previously
missing); consensus-invalid coinbase construction fixed including a **100-byte scriptSig budget check
with BIP34 height allowance**; **job storage bounded on every axis** (future templates, past jobs,
replaced group jobs, per-client jobs, `seen_shares`, `rejected_shares`). *Round 2 correction:* those
caps are **client-side only**, and the pool server's `JobStore` maps are unbounded; **AES-256-GCM removed**,
leaving ChaCha20-Poly1305; arithmetic overflow replaced with saturating ops; and several panics fixed
including an `ExtranoncePrefix` **use-after-free**.

sv2-apps v0.8.0 implements **third-party Loupe audit** findings, and they are mostly *authorisation and
lifecycle*, not cryptography: job notifications only after **both** `mining.subscribe` **and**
`mining.authorize` (unauthenticated mining was possible); **late SV1 shares validated against their own
job's target/extranonce** rather than the current job's (a direct revenue fix); channel opens rejected
on extranonce/channel-ID exhaustion with failure **isolated to the affected miner**; typestate runtimes
with no `unwrap`/`expect`; DNS resilience by trying every A/AAAA record.

**Still alpha.** All crates took breaking version bumps.

## Miningcore — the enterprise shape

C# / .NET 6, "ultra-low-latency, multi-threaded Stratum implementation using asynchronous I/O", with
**native code for PoW validation** — the managed/native split is the tell: keep per-share hashing out of
the CLR.

Most explicitly decomposed design in the survey. `Mining/` alone contains **`ShareReceiver`,
`ShareRecorder`, `ShareRelay`**, `StatsRecorder`, `StratumShare`, `WorkerContextBase`, `PoolBase`,
`BtStreamReceiver`. Separating *receive* from *record* from *relay* is the clearest published statement
that share acceptance and share durability are different concerns on different latency budgets.

Plus `Banning/` (DDoS/flood protection), `Payments/`, `Persistence/`, `Notifications/` (WebSocket
streaming of blocks found / unlocked / payments), `Api/` on port 4000, `Native/`, `Crypto/`,
`Nicehash/`. **PostgreSQL 10+ required.** Multi-pool cluster, adaptive vardiff, zombie-worker purging,
IP banning, PoW and PoS. Fourteen-plus hash algorithms — built for altcoin multi-pool operation, not
Bitcoin alone.

Deployment note: build optimisations target the host CPU (AVX), so the project recommends **building on
the target host**.

## public-pool — solo mining on a managed runtime

TypeScript/NestJS, aimed at individual miners (Bitaxe), with a separate Angular UI.

Scaling is Node cluster with a hard per-worker cap: **`STRATUM_MAX_CONNECTIONS_PER_LISTENER` defaults to
10,000 per worker per port**, and the docs give the sizing rule directly — *28 workers × 10,000 =
280,000 connections on one port*. Requires **`NODE_CLUSTER_SCHED_POLICY=none`** under PM2 so the **OS**
distributes accepted connections rather than Node round-robining them (this is `SO_REUSEPORT` arriving
by another name), and **Node ≥ 22.12.0** for cluster-mode connection dropping.

**10,000 per worker is a configured default, not a measured ceiling** — but it is the only per-worker
number any implementation publishes, which makes it a useful anchor and a bad benchmark.

*Unresolved*: a "first shares accepted within about 6 minutes" note was attributed by agents to both
public-pool and DMND docs; at least one attribution is wrong, and the figure is more plausibly a
stats/UI delay than a share-acceptance delay. Do not carry it without re-reading both READMEs.

## Blitzpool — public-pool, rewritten and split

A Rust/tokio port of public-pool by yourdevice.ch (`warioishere/blitzpool-server-rust`, read at
`c295ae0`, v2.3.5). It keeps public-pool's Postgres schema names and has grown into a **front/satellite
split**:
- **Front process.** Holds one listener per port, serves SV1 and SV2 on the same port (it tells them
  apart by the first byte), and spawns a task per socket (`bin/blitzpool/src/stratum.rs:291-398`).
- **Satellite process.** Consumes accepted shares from a Redis stream and owns payout state.

**Templates come only from Bitcoin Core's SV2 Template Distribution Protocol over Cap'n Proto IPC.**
There is no GBT or ZMQ fallback. This is the first implementation in the survey to commit fully to the
push model described in [Template Sourcing and Control](../concepts/template-sourcing-and-control.md).

**Payouts are non-custodial, in the coinbase.**
- **PPLNS:** the window is 4 × network difficulty with a 90-day age cut. Sub-minimum balances carry
  forward in `pplns_balance`.
- **Group-solo:** a finder bonus capped at 500,000 ppm.
- **"Blockparty":** a fixed basis-point split.
- **Coinbase size:** bounded by **weight** (50k WU, autoscaling) rather than an output count, roughly
  285 outputs worst case. Dust goes to the pool output.

**Vardiff has the Optech #423 fix, switched off.** `vardiff_silence_easing_enabled` walks a silent
session's difficulty down along "the rate its own silence still supports". It is bounded (16× descent,
8× up-step) and pauses while rejects arrive, but it **defaults to off** (`bp-config/src/lib.rs:505-512`).
So out of the box a slowed miner is stranded exactly as Price describes. See
[Vardiff as a Control Loop](../concepts/vardiff-as-control-loop.md).

**Storage** is covered in [Share Storage Architectures](../references/share-storage-architectures.md):
there are no per-share rows, and the corpus's only prod measurement of HOT-update failure on a stats
table comes from here.

**Robustness is mixed.** It has 2,255 test attributes, regtest harnesses and criterion benches. There is
**no connection cap**, and a comment refers to a "fail-ban" that is not implemented. Duplicate-share
detection is a per-connection in-memory set, so, as in SRI, it does not survive a restart.

**The companion rental proxy** (`warioishere/blitzpool-rental-proxy`, `f25a87d`) uses SQLite and stores no
per-share data. It has a working live upstream swap that production deliberately does not use (see
[Regional Routing and Session Continuity](../concepts/regional-routing-and-session-continuity.md)). It has
unbounded channels and no rate limits.

## node-stratum-pool / NOMP — the abandoned generation

A **library, not a daemon**: *"This software will not be useful unless you're a Node.js developer."*
Provided the stratum server, job manager, daemon RPC, a **P2P peer node for faster block notification**,
vardiff, auto-ban and sync detection; NOMP added payments, web front end, database and MPOS
compatibility on top.

**Unmaintained** — issues open 2022–2026 covering payment RPC failures, setup failures, and ASICs not
connecting; a 2025 comment suggesting the repo be archived. Several algorithms self-documented as "not
working currently".

**The agent-supplied diagnosis that Node.js is architecturally unsuitable is not supported by any
source, and is partly contradicted** by the sizing arithmetic: share rate is bounded by
`connections / vardiff interval` and validation is ~1 µs, so a Node pool is nowhere near an event-loop
limit on share volume. What survives is narrower and still useful: **a library that makes the operator
write auth, payments and persistence themselves is a worse deal than a complete daemon**, which is what
its own README says.

## The miner-side tier

**demand-cli (DMND)** — runs on the *miner's* premises. Miners connect with ordinary
`stratum+tcp://` on **32767** with unchanged firmware; the client speaks SV2 + Job Declaration
**outbound on 20000**; a local Template Provider on **8336** talks to Core v30+ over IPC. Firewall
requirement in full: outbound to the pool plus LAN access to 32767 — **no inbound exposure**. Auth is a
token in the **password** field. Reported the **first SV2 Job Declaration block, 2026-06-26, height
955,318**. Payout is **SLICE**: PPLNS for the subsidy, job-declaration scoring for the **fees**.

**DATUM gateway (Ocean)** — the stronger form. The **miner's own node** generates the template via
`getblocktemplate`; the pool coordinates rewards and (during beta) still validates after submission. The
gateway translates GBT to **Stratum V1 with version rolling** for the hardware — so DATUM achieves
template decentralisation **without requiring SV2 at all**, which makes template decentralisation and
the V1→V2 migration separable problems.

**Still explicit public beta** after six releases (Jul 2025 – Jan 2026), warning that "protocol changes
may require upgrading with short or even no notice". Requires a synced full node (**Knots recommended**)
and sizes RAM at **~1 GB plus 1 GB per 1,000 concurrent stratum clients** — ~1 MB per connection,
roughly 300× the ~3 KB kernel-side figure measured elsewhere, so that budget is application state or
conservative guidance.

## What separates them

Not language. Two axes:

1. **Does accounting touch a database on the way in?** ckpool: no, and it ships no schema. Miningcore,
   public-pool and Blitzpool: yes, though all three aggregate first. sv2-apps: no, and it keeps nothing. The no-database option is available only if you also give up
   accounts — solo.ckpool's usernames *are* payout addresses, which is what removes the persistence tier
   entirely.
2. **One process or several, and where do the boundaries fall?** ckpool splits by *function* (I/O /
   mining / node) for fault isolation inside one operator. sv2-apps splits by *trust* (pool / JDS / JDC
   / translator) so the boundaries can cross operators. Those are different kinds of decomposition
   solving different problems, and they compose — an SV2 pool could be internally split the ckpool way.

## See Also

- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](optimal-pool-architecture.md))
- [[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](../concepts/connection-layer-scaling.md))
- [[share-accounting-and-durability|Share Accounting and Durability]] ([Share Accounting and Durability](../concepts/share-accounting-and-durability.md))
- [[template-sourcing-and-control|Template Sourcing and Control]] ([Template Sourcing and Control](../concepts/template-sourcing-and-control.md))
- `stratum-sri` hub topic for SV2 crate internals; `datum` for DATUM internals.
