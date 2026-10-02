---
title: "Optimal Pool Architecture"
category: topic
sources:
  - raw/repos/2026-09-21-ckpool-architecture.md
  - raw/data/2026-09-21-pool-scale-and-sizing-constants.md
  - raw/articles/2026-09-21-vardiff-non-arrival-blindness-optech-423.md
  - raw/papers/2026-09-21-hardening-stratum-bedrock-pets2017.md
  - raw/papers/2026-09-21-withholding-and-power-splitting-attack-economics.md
  - raw/repos/2026-09-21-sri-and-sv2-apps-hardening-releases-2026.md
  - raw/notes/2026-09-21-pool-failure-modes-aggregate.md
  - raw/notes/2026-09-21-adjacent-systems-design-transfer.md
  - raw/articles/2026-09-21-bitcoin-core-mining-ipc-and-template-interfaces.md
  - raw/articles/2026-09-21-solo-ckpool-production-operations.md
created: 2026-09-21
updated: 2026-09-21
tags: [architecture-synthesis, design-objectives, reference-architecture, failure-modes, evidence-grading, minimal-viable-pool, recommendation]
aliases: ["best pool architecture", "pool design", "how to build a mining pool"]
confidence: medium
volatility: warm
summary: "The synthesis. 'Optimal' is objective-dependent, so this article names four objectives and says what the evidence supports under each. The load-bearing findings: share validation is not the bottleneck (~1 us/share, and vardiff makes share rate a function of connection count rather than hashrate), so the connection layer and the per-miner control loops are what matter; the highest-consequence failure is a consensus-invalid coinbase paying zero on a found block; the most dangerous is silent, and there are at least three silent ones."
---

# Optimal Pool Architecture

> The topic name asks a normative question. The honest answer is that **optimality here is
> objective-dependent** — a pool optimised for revenue per hashrate, one optimised for operator cost,
> and one optimised for template decentralisation are different programs. What follows names the
> objective before each recommendation, and grades the evidence.

## Four objectives, and what changes between them

| Objective | What it buys | What it costs |
|---|---|---|
| **Revenue per hashrate** | minimise stale shares, minimise orphans, maximise fee capture | pushes toward SPV-mining risk and aggressive template refresh |
| **Operator cost and reliability** | fewest moving parts, no database, no accounts | forecloses PPS, accounts, rich dashboards |
| **Miner sovereignty** | template decentralisation, censorship resistance | a node per miner, or a JDC + template provider |
| **Time to ship** | an existing implementation, unmodified | inherits its failure modes |

Almost every disagreement in pool design dissolves once the objective is stated. The rest of this
article is what holds *across* objectives.

## The four findings that actually constrain the design

### 1. Share validation is not the bottleneck. The connection layer is.

Two facts compose. First, validating a standard-channel share is **one double-SHA256 of an 80-byte
header — about 1 µs**; an extended channel with coinbase and merkle-path rebuild is ~10 µs. Schnorr
verification is per-connection handshake work, not per-share. Second,
[[vardiff-as-control-loop|vardiff]] ([vardiff](../concepts/vardiff-as-control-loop.md)) holds each
connection near a target submission interval, so:

```
aggregate_shares_per_second ≈ connection_count / target_interval_seconds
```

**No hashrate term.** A 23,000-connection pool at Foundry's scale does **~2,300 shares/sec** — about
**0.2% of one core** — not the ~1.09M shares/sec that follows from assuming a fixed pool-wide
difficulty. Bandwidth lands in single-digit Mbit/s. See
[[pool-sizing-model|the sizing model]] ([the sizing model](../references/pool-sizing-model.md)) for the
derivation and the corrected figures.

**Consequence**: spend the complexity budget on sockets and on per-miner control-loop correctness.
Kernel bypass, io_uring and zero-copy share parsing answer problems this workload does not have. ckpool
reached the same conclusion structurally — validation in-process and in-memory, three processes and a
passthrough tree for the connection layer.

*Evidence: derived arithmetic from canonical difficulty math, cross-checked. Independently matches the
`mining-scale-test-sim` thesis. **High confidence.***

### 2. Per-miner control loops must live at the last hop that sees the miner

Eric Price (Optech #423, 2026-09-18): a vardiff controller triggered by **share arrival cannot detect
non-arrival**, so a slowed miner keeps its too-high difficulty, produces almost no shares, and never
generates the event that would lower it. It is stranded, **underpaid, and invisible to hashrate
estimation** — which cannot distinguish "slowed" from "disconnected". **No parameter tuning fixes it**;
the controller needs a timer.

The generalisation, agreed by Anthony Towns: control must sit at **"the last hop that still sees each
miner's shares"**, because aggregation destroys the signal — one miner's silence disappears into
thousands of others' presence.

**Consequence**: wherever you aggregate — ckpool passthrough, SRI translator, DMND `demand-cli`, DATUM
gateway — the per-miner loops go on the *downstream* side. This reframes the proxy from a fan-in device
into the architecturally pivotal component. It also puts a direct tension in ckpool's
"aggregate to scale to millions of clients" model that the repo does not address.

*Evidence: named researcher, authoritative venue, on-record agreement, released test harness.
**High confidence.***

### 3. The highest-consequence failure is a found block that pays zero

SRI PR #2243: defects in `channels_sv2` coinbase construction — scriptSig length mismatch, **no 100-byte
consensus budget enforcement**, budget validation bypassable by config change, **custom job paths with
no budget check at all**, undersized BIP141 witness commitment parts — produced **consensus-invalid
blocks**. A block found on an affected channel is rejected by every node: it presents as an orphan and
pays **0 BTC instead of ~3.125 BTC plus fees**.

**Consequence**: validate consensus limits **at job creation time and at every trust boundary**, with
identical validation on custom and standard paths. And note the structural point — once the *miner*
assembles coinbase bytes (Job Declaration, DATUM), consensus limits that used to be the pool's private
invariant become a distributed responsibility. Moving template construction to the miner moves this
entire class of check with it.

*Evidence: release notes of the reference implementation. **Medium confidence** on the specific PR
details (not independently opened); high on the class.*

### 4. The dangerous failures are silent

Three documented failures produce no error, no rejection, and no alert:

- **Stranded vardiff** — the miner is underpaid and the dashboard reads healthy.
- **Late shares validated against current state** instead of their own job — valid work rejected for
  having the wrong target or extranonce (fixed in sv2-apps v0.8.0's translator proxy; assume any
  SV1↔SV2 translator has it until checked).
- **Block withholding** — an authenticated miner submitting valid shares and dropping the one that is a
  block. Statistically invisible in a short window; the pool just looks unlucky.

**Consequence**: the pool needs *expected-versus-actual* reconciliation per worker over long horizons,
not just error counters. That is a retention requirement on the share pipeline imposed by adversaries
rather than by payout arithmetic. See
[[share-accounting-and-durability|share accounting]] ([share accounting](../concepts/share-accounting-and-durability.md)).

*Evidence: peer-reviewed (withholding), authoritative newsletter (vardiff), release notes (late shares).
**High confidence** that all three are real.*

## A reference architecture

Stated as what the evidence supports, with the objective named. Nothing here is novel — it is close to
what ckpool already is, which is itself a finding.

```
                    ┌─────────────────────────────────────────┐
   miners ────────► │ edge / proxy tier                       │
   (SV1 or SV2)     │  • epoll/kqueue, SO_REUSEPORT sharded   │
                    │  • per-miner vardiff  ◄── last hop      │
                    │  • per-miner health + hashrate estimate │
                    │  • 1 KB max message from untrusted      │
                    └──────────────┬──────────────────────────┘
                                   │ aggregated, trusted link (16 MB ok)
                    ┌──────────────▼──────────────────────────┐
                    │ core pool                               │
                    │  • share validate (~1 µs) + dedup       │
                    │  • job build + fan-out                  │
                    │  • in-memory accounting, single-writer  │
                    └──────┬───────────────────────┬──────────┘
                           │ off hot path          │
              ┌────────────▼─────────┐   ┌─────────▼──────────────┐
              │ accounting sink      │   │ template source        │
              │ batch 5–10k, 1 fsync │   │ Core IPC (push) or GBT │
              │ long-horizon history │   │ + failover array       │
              └──────────────────────┘   └────────────────────────┘
```

**Load-bearing choices:**

1. **Separate the edge from the core** — by process, not by thread. ckpool's three-daemon split over
   Unix sockets means a template-source stall cannot corrupt mining state. *(Objective: reliability.)*
2. **Shard the accept path**, don't grow one loop. `SO_REUSEPORT` / worker processes / passthrough tree.
   Cloudflare measured 650k → 1.15M pps from removing accept-path contention alone. Watch for the NIC
   hash excluding ports: **a farm behind one NAT address lands on one queue**. *(Throughput.)*
3. **Per-miner control loops downstream of every aggregation point**, with **timer-based** vardiff
   reduction. *(Revenue correctness.)*
4. **No database on the hot path.** In-memory accounting, single-writer per shard, batched off-thread
   persistence. Locks cost **393×** in Thompson's measurements; ckpool ships no SQL schema at all.
   *(Operator cost.)*
5. **Message-size asymmetry as a defence** — 1 KB from untrusted miners, large only on trusted links.
   Cheap and complete against buffer exhaustion. *(Security.)*
6. **Socket handover for restarts** (`-H`) so upgrades don't drop every connection. *(Reliability — and
   the only engineered answer anyone has to reconnect storms.)*
7. **`tcp_rmem` max at 2–4 MB, not 32 MB**, and monitor **p99/p999**. A stall on one socket is invisible
   in a mean across 23,000. *(Job-push tail latency.)*
8. **Consensus-budget validation at job creation**, both paths. *(Not losing a block.)*

## The minimal viable pool, and the cost of each addition

The laziest thing that works is close to ckpool-solo: **C or Rust, event-driven, in-memory accounting,
no accounts (usernames are payout addresses), no database, PPLNS or solo, Stratum V1 with SV2
alongside.** Every addition beyond it buys something and costs something:

| Addition | Buys | Costs |
|---|---|---|
| **Accounts** | dashboards, non-address usernames, fee tiers | the entire persistence tier, auth, credentials, KYC surface |
| **PPS / FPPS** | miner variance absorbed | exposure to withholding attacks that need **0.0000002%** of network hashpower to zero your revenue |
| **SV2** | encryption + authentication (closes the peer-reviewed BiteCoin/StraTap attack class) | job stores, channel state, witness commitments, extension negotiation — every 2026 hardening bug is a consequence |
| **Job Declaration / DATUM** | miner sovereignty, censorship resistance | a node or JDC per miner, template validation, consensus checks distributed, fee attribution per template |
| **Decentralised payout** (p2pool-style) | trust removal | the variance death spiral — blocks every ~108 days on mainnet p2pool in 2018 |
| **Geographic distribution** | latency, resilience | routing stateful TCP, which **nobody has publicly explained how to do** |

**SV2's honest case is security, not performance.** The encryption/authentication argument rests on
peer-reviewed work — Recabarren & Carbunar demonstrated working passive hashrate inference (−9.49% mean
error from *metadata alone*) and active share hijacking via TCP hijack with username rewriting. The
published performance figures (60/70% bandwidth, 228 ms → 2.44 ms job latency, "100% share acceptance")
are vendor self-reports with no methodology, and two are implausible on their face: no protocol can
drive stale rate to zero, and 2.44 ms is below plausible WAN RTT — it most likely measures a
*local* Job Declaration path against a *WAN* V1 path. See
the [SV2 vendor claims audit](../../raw/data/2026-09-21-sv2-claimed-performance-gains-vendor.md).
Note also that the bandwidth those figures optimise **was never a binding constraint**.

## What the evidence does not support

- **That any implementation is faster than another.** **No benchmark comparing pool *implementations*
  exists** — nothing measures ckpool against sv2-apps against Miningcore against public-pool under the
  same load. Every project claims "ultra low overhead" or "high performance"; none substantiates it.
  *(Corrected 2026-09-22: round 1 said no benchmark of pool software existed at all. That was wrong —
  two empirical SV1-vs-SV2 **protocol** benchmarks exist on real ASICs with a reusable harness. See
  [[pool-sizing-model|the sizing model]] ([the sizing model](../references/pool-sizing-model.md)). The
  surviving gap is implementation-vs-implementation comparison.)*
- **That language or runtime choice determines viability.** Asserted about Node.js, and partly
  contradicted by the arithmetic — share rate is bounded by connections/interval, so a Node pool is
  nowhere near an event-loop limit on share volume. NOMP/MPOS are unmaintained; *why* is not
  established.
- **That the database is the bottleneck.** No postmortem found. ckpool avoids a database entirely, so
  the hypothesis is untested rather than confirmed.
- **That reconnect storms or stratum DDoS are significant in practice.** Everyone designs against them;
  **no public incident report was found for either.**

Those four gaps are the most conspicuous absences in the whole topic.

## Recurrence as evidence

slush0's own `stratum-mining` (archived read-only, March 2023) carried: "Job id 'c3a6' not found",
"ntime out of range", and a request for per-port difficulty tiers. The 2026 SV2 hardening release fixed
**job-ID collision handling**, **missing `nTime` upper bounds**, and shipped per-connection difficulty
via channels. **Fourteen years apart, different languages, different authors, the protocol's inventor on
one end.**

These are not slips. Job identity is a small shared namespace with independent client lifetimes;
submitted time is attacker-controlled input. **Treat both as known-hard and test them first** in any new
implementation.

## See Also

- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](../concepts/the-two-hot-paths.md)) — the organising principle.
- [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](../concepts/vardiff-as-control-loop.md))
- [[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](../concepts/connection-layer-scaling.md))
- [[share-accounting-and-durability|Share Accounting and Durability]] ([Share Accounting and Durability](../concepts/share-accounting-and-durability.md))
- [[template-sourcing-and-control|Template Sourcing and Control]] ([Template Sourcing and Control](../concepts/template-sourcing-and-control.md))
- [[pool-implementation-survey|Pool Implementation Survey]] ([Pool Implementation Survey](pool-implementation-survey.md))
- [[pool-sizing-model|Pool Sizing Model]] ([Pool Sizing Model](../references/pool-sizing-model.md))
- [[pool-protocol-timeline|Pool Protocol Timeline]] ([Pool Protocol Timeline](../references/pool-protocol-timeline.md))
