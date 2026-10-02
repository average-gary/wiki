---
title: mining-pool-architecture
type: topic-wiki
created: 2026-09-21
updated: 2026-09-23
compiled: 2026-09-23
status: active
sources: 30
articles: 11
rounds: 2
---

# mining-pool-architecture

> Software architecture and design of Bitcoin mining pool servers. Connection handling, work
> distribution, share validation and accounting pipelines, template sourcing, deployment topology,
> failure modes, and the measured numbers that constrain each choice.

Last updated: 2026-09-23

## Statistics

- Sources: 30 raw documents (6 papers, 6 articles, 9 repos, 4 notes, 5 data) covering ~80 distinct URLs
- Articles: 11 compiled wiki articles (6 concepts, 2 topics, 3 references)
- Outputs: 0 generated artifacts
- Last compiled: 2026-09-23
- Last lint: never
- Research rounds: 2 (8 agents each; round 2 read local public source checkouts as well as the web)

## Quick Navigation

- **[Optimal Pool Architecture](wiki/topics/optimal-pool-architecture.md)** — the synthesis, start here
- [All Articles](wiki/_index.md) (with a suggested reading order)
- [All Sources](raw/_index.md) (with a confidence distribution)
- [Concepts](wiki/concepts/_index.md) · [Topics](wiki/topics/_index.md) · [References](wiki/references/_index.md)
- [Outputs](output/_index.md) · [Configuration](config.md) · [Activity Log](log.md)

## Scope

See [config.md](config.md) for full scope. In brief: how pool *software* is built — the server that
aggregates miners, hands out work, validates shares and submits blocks — and what evidence supports one
design over another.

## Read This First

The topic name asks a normative question, and **optimality here is objective-dependent**. A pool
optimised for revenue per hashrate, one optimised for operator cost, and one optimised for template
decentralisation are different programs. Anything in this wiki that recommends a design names the
objective and the evidence; treat an unqualified "best" as a defect to fix.

Two further cautions specific to this corpus:

1. **No benchmark compares pool *implementations*.** Two empirical SV1-vs-SV2 **protocol** benchmarks do
   exist on real ASICs with a reusable harness, but nothing measures ckpool against sv2-apps against
   Miningcore under the same load. Implementation-choice arguments rest on architecture, not measurement.
2. **Several agent-supplied figures were corrected or retracted during ingest** rather than carried — a
   retraction, four corrections, one downgrade and one resolved agent conflict. See
   [raw/_index.md](raw/_index.md) § Corrections and § Round 2 corrections.

## Findings So Far

- **Share validation is not the bottleneck; the connection layer is.** Validating a standard-channel
  share is one double-SHA256 of an 80-byte header (~1 µs), and vardiff holds aggregate share rate to
  `connections / target interval` — **with no hashrate term**. A 23,000-connection pool at the largest
  pool's scale does ~2,300 shares/sec, roughly 0.2% of one core. Spend the complexity budget on sockets
  and on per-miner control-loop correctness.
- **Per-miner control loops must live downstream of every aggregation point.** Eric Price's finding
  (Optech #423, 2026-09-18): an arrival-triggered vardiff controller cannot detect non-arrival, so a
  slowed miner is stranded at too-high difficulty — silently underpaid and indistinguishable from
  disconnected. No tuning fixes it. This reframes the proxy/gateway from a fan-in device into the
  pivotal component, and sits in direct tension with ckpool's aggregate-to-scale model.
- **The highest-consequence failure is a found block that pays zero.** SRI's 2026 hardening fixed
  coinbase construction defects — missing 100-byte scriptSig budget enforcement, custom job paths with no
  check at all — that produced consensus-invalid blocks: rejected by every node, presenting as orphans,
  paying nothing.
- **The dangerous failures are silent.** Stranded vardiff, late shares validated against current instead
  of their own job, and block withholding all produce no error and no alert. The pool needs
  expected-versus-actual reconciliation per worker, which is a retention requirement imposed by
  adversaries rather than by payout arithmetic.
- **SV2's honest case is security, not performance.** The encryption/authentication argument rests on
  peer-reviewed work (Recabarren & Carbunar, PETS 2017: working passive hashrate inference at −9.49% mean
  error from packet metadata alone, plus active share hijacking). The published performance figures are
  vendor self-reports with no methodology, and two are implausible on their face.
- **Template decentralisation was never a capability problem.** BIP 23 specified miner template auditing
  in February 2012 and it went unused for twelve years. What changed by 2026 was cost (`checkBlock()`,
  batched wtxid lookup, official multiprocess binaries) and payment (DMND's SLICE fee scoring, Ocean's
  50% fee discount). First SV2 Job Declaration block: 2026-06-26, seven years after the spec.
- **Nobody in production writes one durable row per share** — and the single design that does (MPOS: a
  primary key plus four secondary indexes, no batching) is the only one with a documented scaling failure,
  reported to struggle above 1–2k miners. Others aggregate (public-pool's 10-minute buckets at ~1 UPDATE
  per session per minute; BTCPool's hourly MySQL rows), batch (Miningcore's binary `COPY` into a `shares`
  table with **no PRIMARY KEY**), buffer (BTCPool's Kafka, with shares at 1 s/Snappy and `SolvedShare` at
  **1 ms uncompressed**), or keep it in RAM (ckpool, Redis pools). Raw per-share history is transient
  everywhere — 24 h, 7 days, or deleted at payment — **so the long-horizon retention that withholding
  detection needs exists in no open implementation.** Blitzpool comes closest, with never-pruned lifetime
  per-worker totals, but they have no time axis.
- **The SRI reference pool persists nothing.** No database crate, no file I/O; counters live in RAM behind
  an HTTP polling API, and a restart zeroes them **including `seen_shares`, so replay protection does not
  survive a restart** — an adversary who can trigger one rolls over the dedup window deliberately. It is a
  share-validation frontend, not a complete pool.
- **Pools solve regional routing by outsourcing it.** AntPool, F2Pool, ViaBTC, Foundry, Braiins, Poolin and
  SpiderPool all resolve into Cloudflare ranges, returning the same IP from different resolvers — BGP
  anycast with **edge TCP termination**, so session state never has to move. Meanwhile **migrating an
  established connection between servers is unsolved** without application-layer resumption, which Stratum
  lacks; `SO_REUSEPORT` moves only *new* connections. So every design ends in a reconnect, and the real
  problem is keeping reconnects cheap and **unsynchronised**. The one proxy found that *can* swap upstreams
  under a live miner (Blitzpool's rental proxy) forces a reconnect in production anyway.
- **`share-accounting-ext` makes pool accounting miner-auditable.** Extension type 32 commits each
  accounting slice to a merkle root over its shares, and `GetWindow`/`GetShares` let a miner sample the
  PPLNS window and verify difficulty and fee sums — SmartPool's probabilistic verification arriving on
  Bitcoin without a smart contract, though with detection but no enforcement.
- **The same bugs recur across fourteen years.** Job-ID collision, missing `nTime` upper bounds and
  per-connection difficulty appear in slush0's own 2012 implementation and again in SRI in 2026 —
  different languages, different authors, the protocol's inventor on one end. Job identity is a small
  shared namespace with independent client lifetimes; submitted time is attacker-controlled input. Test
  both first.

## Open Questions

Targets for the next round, roughly in order of how much they would change the conclusions:

- **What is ckpool's own auto-selection mechanism?** The major pools' routing is now explained (CDN
  anycast), but `solo.ckpool.org` resolves to a *single* IP, so its advertised "automatic lowest latency
  connection" is not anycast and remains unexplained.
- **Does ckpool strand slowed miners?** `stratifier.c` tracks `ldc` (last diff change) as well as `ssdc`
  (shares since diff change), so time is recorded — but whether it drives a reduction is unresolved, and
  Price's shaping proxy now makes it testable.
- **Can a downstream induce arbitrary `error_code` strings in SRI?** The pool server's `rejected_shares`
  is an unbounded `HashMap` keyed on that string, so the answer decides whether it is a live
  memory-exhaustion DoS or a latent one. Also: are `stale_jobs` pruned anywhere outside `job_store.rs`?
- **Is per-worker aggregate history sufficient for withholding detection**, or does the test genuinely
  require raw per-share rows? This decides whether the retention requirement is affordable at all, since
  no pool keeps raw history for long.
- **Does any benchmark compare pool implementations?** The protocol-comparison harness exists and is
  reusable; nothing has been run implementation-against-implementation.
- **Are reconnect storms and stratum DDoS real in practice?** Every implementation designs against them
  (token buckets, `Banning/`, socket handover) and **no public postmortem of either was found.**
- **Is the database ever actually the bottleneck?** No postmortem found, and ckpool avoids a database
  entirely — so the hypothesis is untested rather than confirmed.
- **What do the SV2 performance claims actually measure?** Each has a stated verification path. The
  2.44 ms job latency most plausibly compares a local Job Declaration path against a WAN V1 path.
- **Do the 2026 SRI hardening figures and issue numbers check out?** The release-notes detail was read
  secondhand, and the reporting agent's timeline double-listed the release series under both 2025 and
  2026 dates.
- **Which pools actually run SV2 in production, at what share of hashrate?** No adoption figures were
  found for SV2, Job Declaration or DATUM — all three are undisclosed by their operators.

## Neighbouring Topics

This topic deliberately does not duplicate work owned elsewhere in the hub:

- [bitcoin-mining-payout-schemas](../bitcoin-mining-payout-schemas/_index.md) — PPLNS/FPPS/PPS+, ecash
  redenomination, share-chain accounting. Referenced here only where a schema forces an architectural
  choice.
- [stratum-sri](../stratum-sri/_index.md) — SV2 crate internals: codec, framing, Noise, channels.
- [sv2-p2pool-integration](../sv2-p2pool-integration/_index.md) — p2poolv2 ↔ sv2-apps integration.
- [datum](../datum/_index.md) — Ocean's DATUM gateway internals.
- [mining-scale-test-sim](../mining-scale-test-sim/_index.md) — vardiff simulation and scale-test harness
  methodology. **Closely coupled**: its thesis (vardiff smooths share-validation rate, so the connection
  layer saturates first) is independently reproduced by the arithmetic in this topic's sizing model, and
  Eric Price's vardiff finding is the substantive result that line of work produced.

Employer-specific deployment stays in `~/repos/pool-v4-infra/.wiki`, never here.

## Recent Changes

- 2026-09-23: Blitzpool (server + rental proxy) source read added. Round 2 had excluded it as possibly
  employer-internal without checking, but its upstreams are public.

- 2026-09-21: Topic wiki created; research round 1 run with 8 parallel agents; 21 sources ingested and
  9 articles compiled.
