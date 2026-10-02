---
title: "public-pool (NestJS/TypeScript) and Miningcore (.NET) — managed-runtime pool architectures"
source: "https://github.com/benjamin-wilson/public-pool"
related_sources: ["https://github.com/oliverw/miningcore"]
type: repos
ingested: 2026-09-21
tags: [public-pool, miningcore, nestjs, typescript, dotnet, node-cluster, so-reusesport, connection-limits, postgresql, bitaxe, solo-mining, multi-coin, native-interop, vardiff, banning]
summary: "The two actively maintained pools built on managed runtimes, recorded together as the counterpoint to ckpool's C. public-pool (Benjamin Wilson; TypeScript/NestJS, solo-mining oriented, the default backend for Bitaxe self-hosting) scales by Node cluster with a hard per-worker cap: STRATUM_MAX_CONNECTIONS_PER_LISTENER defaults to 10,000 per worker per port, so a documented 28-worker deployment allows 280,000 connections on one port; needs NODE_CLUSTER_SCHED_POLICY=none for OS-level connection balancing under PM2 and Node >=22.12.0 for cluster-mode connection dropping. Miningcore (Oliver Weichhold; C#/.NET 6, multi-coin, PostgreSQL 10+) is the enterprise-shaped design: async/await Stratum, native-code interop for PoW validation, and explicitly separated subsystems — ShareReceiver / ShareRecorder / ShareRelay / StatsRecorder, plus Banning, Payments, Notifications (WebSocket event streaming), and a REST+WebSocket API on port 4000. Both demonstrate that the managed-runtime penalty is paid in the validation path, which is why both push hashing into native code or keep it trivially small."
authors: [Benjamin Wilson, Oliver Weichhold]
repo_state: "Both active as of 2026; Miningcore on .NET 6 with commercial support offered"
credibility: medium
credibility_score: 3
credibility_rationale: "Primary repo docs and configuration, but architecture is partly inferred from directory/file layout rather than from design documents. No benchmarks published by either project. public-pool connection figures come from its own configuration documentation and are a configured cap, not a measured ceiling."
confidence: medium
research_round: 1
research_agent: "technical + applied + data"
extraction_note: "Merged from three subagent reports. The public-pool 10,000/worker and 28x10,000=280,000 figures were reported identically by two agents reading the same documentation — they are a documented *configuration example*, not a benchmark. Miningcore module list is from the src/Miningcore/ directory listing; per-module behaviour is inferred from names where noted. One agent's attribution of public-pool to a 'Luke Dashjr contributor' was unsupported and is dropped."
---

# public-pool and Miningcore — pools on managed runtimes

Recorded as one file because they answer the same question — *what happens when you build a pool on a
garbage-collected runtime?* — in two different ways.

## public-pool — TypeScript / NestJS

**Benjamin Wilson** — https://github.com/benjamin-wilson/public-pool

**Positioning**: **solo mining**, explicitly aimed at individual miners (Bitaxe) rather than
commercial pools. A separate Angular project (`public-pool-ui`) provides monitoring.

**Concurrency and scaling.** Node.js event loop plus **cluster mode**.

- `STRATUM_MAX_CONNECTIONS_PER_LISTENER` — **default 10,000, enforced per worker per port.**
- Documented sizing rule: *"Size it using the busiest port: worker count × limit. For example, 28
  workers with the default limit of 10,000 allow up to 280,000 connections on one port."*
- **`NODE_CLUSTER_SCHED_POLICY=none`** is required when running under PM2 so the **OS** distributes
  accepted connections across workers instead of Node's round-robin. (This is the `SO_REUSEPORT`
  pattern arriving in a JavaScript pool by way of a runtime env var.)
- **Node.js ≥ 22.12.0** required for cluster-mode connection dropping.
- PM2 recommended for production; Docker and docker-compose supported, binding to 127.0.0.1 by
  default (must be changed to expose 3333/3334).

**Module layout** (`src/`): `ORM/` (persistence), `controllers/` (HTTP API), `models/`, `services/`
— including `stratum-v1.service.ts`, `stratum-v1-jobs.service.ts`, `external-shares.service.ts` —
and `utils/`. Jest tests with coverage tooling; `.spec.ts` files at service level.

**Storage**: a TypeScript ORM layer, relational (PostgreSQL implied by the NestJS pattern; not
confirmed).

**Bitcoin Core**: RPC via `.env` credentials. Docker deployments must add
`rpcallowip=172.16.0.0/12` to `bitcoin.conf` for container-network access.

**Ports**: 3333 / 3334 for difficulty tiers; 8332 referenced for API/monitoring.

> **One reported behaviour to treat with suspicion.** An agent recorded from the docs that operators
> should "expect the first shares to be accepted within about 6 minutes of the miner submitting its
> first share — this is normal, not a fault", and attributed it to batching or a validation window.
> The same sentence was also attributed to the DMND client docs. At least one attribution is wrong,
> and the 6-minute figure is more plausibly a *statistics/UI* delay than a share-acceptance delay.
> **Unresolved — do not carry this into a compiled article without re-reading both READMEs.**

## Miningcore — C# / .NET 6

**Oliver Weichhold** — https://github.com/oliverw/miningcore (formerly coinfoundry/miningcore)

**Concurrency**: "ultra-low-latency, multi-threaded Stratum implementation using asynchronous I/O"
— Task-based async/await. **Native code for PoW validation** (the managed/native split is the
architectural tell: keep the per-share hashing out of the CLR).

**Subsystem separation** (`src/Miningcore/`), the most explicitly decomposed design of any pool in
this round:

- `Mining/` — `PoolBase.cs`, **`ShareReceiver.cs`**, **`ShareRecorder.cs`**, **`ShareRelay.cs`**,
  `StatsRecorder.cs`, `StratumShare.cs`, `WorkerContextBase.cs`, `BtStreamReceiver.cs`.
  Note that *receive*, *record*, and *relay* are three separate components — the share pipeline is
  explicitly staged rather than a single handler.
- `Banning/` — DDoS/flood protection; `JsonRpc/`; `Blockchain/` (multi-coin abstraction);
  `Crypto/` + `Native/` (algorithm implementations and interop); `Payments/`; `Persistence/`;
  `Notifications/` (WebSocket streaming of "blocks found, blocks unlocked, payments");
  `Messaging/`; `Nicehash/`; `Api/`, `Rest/`, `Serialization/`, `Configuration/`, `Contracts/`.

**Storage**: **PostgreSQL 10+** required, schema owned by a `miningcore` role. Unlike ckpool, the
database is a first-class component.

**Features**: multi-pool cluster (one instance, many coin pools), adaptive vardiff, session
management with zombie-worker purging, IP banning, payment processing, PoW and PoS, per-pool logging.

**API**: port **4000** — live stats REST plus WebSocket event streaming.

**Algorithms**: SHA256, Scrypt (+Jane, +N), Quark, X11/X13/X16R/X16RV2, NIST5, Keccak, Skein,
Groestl, plus experimental Blake/Fugue/Qubit/SHAvite-3/Sha1/Hefty1 — i.e. built for altcoin
multi-pool operation, not Bitcoin-only.

**Build/deploy**: needs `libssl-dev`, `pkg-config`, `libboost-all-dev`, `libsodium-dev`,
`build-essential`, `cmake`. Docker multi-stage from `mcr.microsoft.com/dotnet/sdk:6.0`. Build
optimisations target host CPU (AVX) — **recommendation to build on the target host**, which is a
deployment constraint worth noting.

## Architectural reading

- **Both push hashing out of the managed runtime** — Miningcore explicitly via `Native/`, public-pool
  by targeting solo mining where share volume is low. Neither tries to validate at scale in the
  managed language. That is the real lesson about runtime choice: it constrains *where* the
  validation code can live, not whether the pool can exist.
- **Connection scaling is horizontal within the box.** public-pool's `workers × limit` is the same
  shape as ckpool's passthrough tree and Cloudflare's `SO_REUSEPORT` sharding — shard the accept
  path, don't grow one loop.
- **10,000 connections per worker is a configured default, not a measured ceiling.** It is the only
  per-worker number any implementation in this round publishes, which makes it useful as an anchor
  and dangerous as a benchmark.
- **Miningcore's staged share pipeline (receive → record → relay) is the cleanest published
  articulation** of the idea that share *acceptance* and share *durability* are different concerns on
  different latency budgets.
