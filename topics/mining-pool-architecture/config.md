---
title: "mining-pool-architecture"
description: "Software architecture and design of Bitcoin mining pool servers. Connection handling, work distribution, share validation and accounting pipelines, template sourcing, deployment topology, failure modes, and the measured numbers that constrain each choice."
created: 2026-09-21
freshness_threshold: 90
---

# Wiki Configuration

## Scope

How pool *software* is built — the server that aggregates miners, hands out work, validates
shares, and submits blocks — and what evidence supports one design over another. Covers:

- **Connection layer.** Stateful long-lived TCP fan-in at scale: event loop vs thread-per-connection
  vs async runtime, `epoll`/`kqueue`/io_uring, `SO_REUSEPORT` sharding, per-connection memory,
  reconnect storms, load balancing a protocol that cannot be round-robined, TLS/Noise cost.
- **Work distribution.** Job push latency and fan-out, template refresh cadence, extranonce and
  nonce-space allocation, version-rolling (BIP310), vardiff as a control loop, `clean_jobs` and
  stale handling.
- **Share pipeline.** Validation cost per share, batching, what is actually durable vs derived,
  queue/stream choices, per-share write amplification, and where accounting sits relative to the
  hot path.
- **Template sourcing.** `getwork` → `getblocktemplate` (BIP22/23) → Stratum V2 Template Provider →
  Bitcoin Core's Mining/IPC interface. Redundancy across template sources, `submitblock` paths,
  and what template ownership does to the architecture.
- **Implementation survey.** Real designs read on their own terms: ckpool/ckpool-solo, public-pool,
  Miningcore, NOMP / node-stratum-pool, eloipool, stratum-mining, the SRI `sv2-apps` roles,
  Braiins, Ocean + DATUM, p2pool/p2poolv2. Language, concurrency model, storage, module boundaries,
  stated rationale.
- **Operations.** Deployment topology, geographic endpoints, failover of long-lived connections,
  observability (stale rate, per-worker hashrate estimation, block latency), and what operators
  report as the hard parts.
- **Failure modes.** Documented outages and postmortems, rewrites and abandonments, security
  failures (hashrate hijacking, BGP, DDoS against stratum, weak auth), block/share withholding, and
  the scaling myths that survive without evidence.
- **Cross-domain transfer.** C10K/C10M work, low-latency broadcast fan-out from market-data systems,
  high-rate event ingestion pipelines, and pools in other chains — imported only with an explicit
  note on how the lesson maps onto a pool.
- **The numbers.** Connections per node, shares/sec per unit hashrate, bytes per job, bandwidth
  V1 vs V2, stale-rate → revenue loss, hashrate distribution. Sizing constants with their sources.

Out of scope for this topic:

- **Payout and reward schemas.** PPLNS / FPPS / PPS+ / ecash redenomination / share-chain accounting
  belong to the `bitcoin-mining-payout-schemas` hub topic. Referenced here only where the schema
  choice forces an architectural one (e.g. what must be durable per share).
- **SV2 crate internals.** Codec, framing, Noise handshake, channel state machines are the
  `stratum-sri` topic. Cited here at the interface level, not the byte level.
- **p2pool / DATUM internals.** Owned by `sv2-p2pool-integration` and `datum`. Treated here as
  architectural alternatives, not re-documented.
- **Scale-test and vardiff simulation methodology.** Owned by `mining-scale-test-sim`. This topic
  consumes its findings; it does not duplicate the harness design.
- **Employer-specific deployment.** Any MARA / internal-infrastructure specifics belong in
  `~/repos/pool-v4-infra/.wiki`, never here. This topic stays publishable.
- Mining hardware selection, electricity economics, hosting contracts, and pool business models.
- Altcoin pool software except as an explicit comparison point.

## Conventions

- **"Optimal" is a claim, not a given.** The topic name asks a normative question. Every design
  preference recorded here must name the objective it optimises (revenue per hashrate? operator
  cost? decentralisation? time-to-ship?) and the evidence behind it. An unqualified "best
  architecture" line is a defect.
- **Separate mechanism from measurement from recommendation.** State what a system does, then what
  was measured, then what follows. These fail independently — a mechanism can be real while the
  benchmark behind the recommendation is unrepresentative.
- **Tag numbers with their provenance and units.** Never carry a shares/sec, connection count, or
  latency figure without its source, measurement window, and units. Mark derived figures as derived
  and show the arithmetic.
- **Name the implementation, don't generalise from it.** "ckpool does X" is a fact; "C pools do X"
  usually isn't. Attribute design choices to specific software at a specific version/date.
- **Distinguish "nobody does this" from "this doesn't work".** Absence of adoption (p2pool, Job
  Declaration) is evidence about incentives and ergonomics, not automatically about the design.
- **Forum and mailing-list sources are admissible with specifics.** A bitcoin-dev or Delving
  Bitcoin thread from a named implementer outranks a polished but sourceless blog post. Record who
  said it and whether anyone contradicted them in the same thread.
- **Keep the hot path visible.** When describing any pool component, say whether it sits on the
  share-submit path, the job-push path, or off both. Most architecture arguments are really
  arguments about what belongs on those two paths.
