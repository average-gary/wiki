---
title: "The Two Hot Paths"
category: concept
sources:
  - raw/repos/2026-09-21-ckpool-architecture.md
  - raw/data/2026-09-21-pool-scale-and-sizing-constants.md
  - raw/notes/2026-09-21-adjacent-systems-design-transfer.md
  - raw/repos/2026-09-21-public-pool-and-miningcore-managed-runtime-pools.md
created: 2026-09-21
updated: 2026-09-21
tags: [hot-path, share-submit, job-push, latency-budget, architecture-organising-principle, fan-in, fan-out]
aliases: ["share path", "job path", "pool hot path"]
confidence: high
volatility: cold
summary: "A pool has exactly two latency-critical paths — job push (fan-out: template change to every miner holding work) and share submit (fan-in: miner solution to accept/reject). Almost every architecture argument in pool design is really an argument about what is allowed to sit on one of these two paths. Naming them first makes the rest of the design decidable."
---

# The Two Hot Paths

> A mining pool does many things, but only two of them are latency-critical: **pushing a new job to
> every connected miner**, and **accepting a submitted share**. Everything else — payout calculation,
> statistics, persistence, dashboards, payments — is off both paths and may be as slow as it likes.
> Most disagreements about pool architecture are disagreements about what belongs on these two paths.

## Path 1 — job push (fan-out)

**Trigger**: the template changed. Either the chain tip moved, or the fee-optimal template drifted
enough to be worth reissuing.

**Work**: build the new job, then write it to *N* connections.

**Why latency matters**: every miner still working the previous job is producing work that will be
stale. The stale window is `block found somewhere → pool learns of it → new template → job written to
this miner's socket`. Only the last two terms are the pool's to control.

**Shape**: one-to-many broadcast. This is the same problem market-data systems solve, and the
transferable rules come from there — batch the writes, watch p99/p999 rather than the mean, and keep
kernel buffers small (a Cloudflare postmortem traced second-long outliers to `tcp_collapse` garbage
collecting oversized receive buffers, fixed by cutting `tcp_rmem` max from 32 MB to 2–4 MB). Stratum
messages are ~1 KB or less, so large buffers buy nothing and cost tail latency. See
the [adjacent-systems evidence note](../../raw/notes/2026-09-21-adjacent-systems-design-transfer.md).

**The invariant ckpool states explicitly**: *"Event driven communication based on communication
readiness preventing slow communicating clients from delaying low latency ones."* One slow miner must
not add latency to a fast one. That single sentence motivates the whole event-driven design, and it is
a property of the *push* path specifically.

## Path 2 — share submit (fan-in)

**Trigger**: a miner found a hash under its share target.

**Work**: validate, deduplicate, credit, respond accept/reject. And — rarely — notice that this share
is actually a block and submit it.

**Why latency matters less than it appears**: a share is not money in flight; it is an accounting
event. The one case where submit latency matters enormously is the block case, which is why block
submission is worth a dedicated fast path even though it fires once per pool per hours.

**Cost, corrected**: validating a standard-channel share means substituting the submitted
nonce/nTime/version into the 80-byte header and taking one double-SHA256 — about three SHA-256
compressions, **~1 µs**. An extended channel, where the miner varies extranonce inside the coinbase,
requires rebuilding the coinbase txid and walking a ~12–14 level merkle path, **~10 µs**. Schnorr
verification is *per-connection handshake* work, not per-share. See
[[pool-sizing-model|the sizing model]] ([the sizing model](../references/pool-sizing-model.md)).

**Therefore share validation is not a bottleneck at any plausible scale**, and no source found in this
research round demonstrated otherwise. ckpool's design agrees: validation happens in-process,
in-memory, with no database, and the complexity budget goes to the connection layer instead.

## Why naming the paths settles arguments

Once you ask "is this on a hot path?", a set of recurring design questions answer themselves:

| Question | Answer via the paths |
|---|---|
| Should shares be written to a database as they arrive? | No — durability is off both paths. Batch it. See [[share-accounting-and-durability|share accounting]] ([share accounting](share-accounting-and-durability.md)). |
| Where does vardiff belong? | On neither path, but it needs per-miner visibility, which puts it at the last hop that sees individual shares. See [[vardiff-as-control-loop|vardiff]] ([vardiff](vardiff-as-control-loop.md)). |
| Does the pool need a fast validator? | No. It needs a fast *fan-out* and a lot of sockets. |
| Can accounting be sampled instead of exhaustive? | Yes in principle — SmartPool's probabilistic verification makes cheating expectation-neutral — because accounting is off the hot path and can afford a different correctness model. |
| Is bandwidth a constraint? | No. Single-digit Mbit/s at realistic scale. The 10 MB template fetch is the only fat pipe, and it is on the *node* side. |

## The staged share pipeline

Miningcore is the clearest published articulation: `ShareReceiver` → `ShareRecorder` → `ShareRelay` as
three separate components. That is the two-path principle made structural — *accept* the share on the
hot path, *record* it off it.

ckpool encodes the same boundary differently, as the `unaccounted` / `accounted` split inside
`pool_stats_t`: shares are counted immediately and aggregated later, with the aggregation running
elsewhere.

## Where the paths cross, and why that hurts

Two documented failure modes are both consequences of a hot path touching state it shares with
something else:

- **Duplicate-share suppression** needs a `seen_shares` set on the submit path. That set must be
  large enough to defeat replay and bounded enough to survive a long-lived connection. SRI's 2026
  hardening release resolved the conflict with a configured cap — which means the safe size is now an
  operator's problem rather than a designed invariant.
- **Validating a late share against current state instead of its own job** is a pure revenue bug: the
  share is valid, and the pool rejects it for having the wrong target or extranonce. sv2-apps v0.8.0
  fixed exactly this in the translator proxy. The general rule: **a share is a claim about a specific
  past job, so the submit path must be able to reach that job's context, not just the current one.**
  That is a retention requirement imposed on the hot path by correctness.

## See Also

- [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](vardiff-as-control-loop.md)) — the per-miner controller that sets the submit rate.
- [[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](connection-layer-scaling.md)) — the fan-out side, and the component that actually saturates.
- [[share-accounting-and-durability|Share Accounting and Durability]] ([Share Accounting and Durability](share-accounting-and-durability.md)) — what comes off the path.
- [[pool-sizing-model|Pool Sizing Model]] ([Pool Sizing Model](../references/pool-sizing-model.md)) — the numbers behind the cost claims.
- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](../topics/optimal-pool-architecture.md)) — the synthesis that uses this as its organising principle.
