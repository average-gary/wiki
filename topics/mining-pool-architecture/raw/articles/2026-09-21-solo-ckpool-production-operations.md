---
title: "solo.ckpool.org — production operating parameters of a geographically distributed pool"
source: "https://solo.ckpool.org/"
type: articles
ingested: 2026-09-21
tags: [production-operations, geographic-distribution, latency-routing, minimum-difficulty, high-difficulty-ports, transaction-selection-transparency, rental-hashrate, solo-mining, node-connectivity, operational-minimalism]
summary: "The public operating parameters of Con Kolivas's solo pool — the only real production deployment documented in this round. Endpoints in USA (west and east), Germany, Singapore and Australia, with a main hostname that auto-selects the lowest-latency endpoint and fails over, plus manual per-region selection. Enforces a 10,000 minimum difficulty for share detection, with a cosmetic client-side floor of 1 available via client-diff in compatible software — i.e. the share stream a miner sees and the share stream that counts are deliberately decoupled. Separate high-difficulty ports (4334 for SV1, 4336 for SV2) for rental hashrate, to hold submission rates down for very large short-lived connections. Runs Stratum V1 on 3333, Stratum V2 on 3336, and experimental job-declaration services. Uses default Bitcoin Core transaction selection with NO filtering, and publishes the live template transaction list at /pool.txns so miners can verify it. No registration and no operator wallet — usernames are payout addresses — which is what lets the whole thing run on in-memory accounting with no account database. 2% fee."
authors: [Con Kolivas]
credibility: medium
credibility_score: 3
credibility_rationale: "Primary operator documentation for a pool that demonstrably finds blocks, but it is a public-facing service page: it states configuration and policy, not measurements, and discloses nothing about server counts, capacity, or incidents."
confidence: medium
research_round: 1
research_agent: applied
extraction_note: "Subagent extraction of the public site. Port numbers, region list and difficulty floors are as reported. The routing mechanism behind 'auto-selects lowest latency' is NOT documented — see open items."
---

# solo.ckpool.org — production operating parameters

The reference deployment of ckpool, run by its author. Useful because it is the only source in this
round that shows what a working pool's *externally visible configuration* actually looks like.

## Geographic distribution

- Endpoints across **USA, EU, Asia, Oceania** — specifically **US west, US east, Germany, Singapore,
  Australia**.
- A **main endpoint auto-selects the lowest-latency region with failover**; manual per-region
  hostnames are also published.
- The pool maintains "extensively connected nodes with high-speed, low-latency infrastructure" for
  rapid block notification and propagation — **so individual miners do not need to run their own
  node.** This is the deliberate opposite of the DATUM model, and it is the centralising trade stated
  as a feature: the pool absorbs the infrastructure burden.

**Open item — the routing mechanism is not disclosed.** "Auto-selects lowest latency" could be GeoDNS,
anycast, or client-side probing. No source in this round explained how any pool load-balances a
*stateful* TCP protocol across regions, and this is the single largest gap in the operational picture.
Stratum cannot be round-robined mid-session: a connection carries difficulty state, extranonce
assignment and job history.

## Difficulty policy — three tiers

1. **10,000 minimum difficulty for share detection.** The floor below which a share does not count.
2. **A cosmetic client-side floor of 1**, available via the `client-diff` option in compatible mining
   software. These shares do not affect block-finding probability; they exist so a small miner sees
   *some* feedback.
3. **Dedicated high-difficulty ports for rental hashrate: 4334 (SV1) and 4336 (SV2).** Rented
   hashrate arrives in very large short-lived blocks, and a high difficulty floor keeps its submission
   rate manageable.

**The architectural point.** Tier 2 is an explicit acknowledgement that *the share stream a miner
observes and the share stream the pool accounts for are different things*, and that miner-facing
feedback is a UX requirement to be served separately from accounting. Tiers 1 and 3 together confirm
the correction in the sizing file: difficulty is the operator's lever for holding share rate down, and
production pools reach for it (10,000 floor generally; far higher for rentals) rather than scaling the
validator.

Ports 3333 (SV1), 3336 (SV2), 4334/4336 (high-diff) also show the real-world pattern: **difficulty
tiers are expressed as separate listening ports**, because V1 has no way to negotiate one (the
`minimum-difficulty` extension of BIP 310 is the retrofit that would replace this).

## Transaction selection — transparency as policy

- Uses **default Bitcoin Core transaction selection, with no filtering.**
- Publishes the live template transaction list at **`solo.ckpool.org/pool.txns`** so miners can see
  current mempool contents and predict inclusion.

This is a distinct third position in the template-control design space, alongside pool-chosen-and-opaque
and miner-declared: **pool-chosen, default policy, and publicly auditable.** It obtains most of the
censorship-resistance argument at none of the operational cost of Job Declaration or DATUM — no miner
node, no template negotiation — while still leaving the pool in control. It is worth recording as the
cheap option that the decentralisation debate usually skips.

## Protocol support

Stratum V1 (3333), Stratum V2 (3336), and **experimental job declaration services**. Note this is a
V1-era C codebase carrying SV2 and JD alongside V1 on the same stratifier and share queue, which
matches the conditional `HAVE_SV2` modules in the repo.

## Operational model

- **2% fee**, covering maintenance and development.
- **No registration. No operator wallet as intermediary.** Usernames *are* payout addresses (ckpool
  solo mode requires a valid address as the username).
- 100% of a found block goes to the solver.

**Why this matters architecturally:** no accounts means no account database, no auth store, no
credential management, no password reset, no KYC surface — which is precisely what permits ckpool's
in-memory-only accounting with optional file logging. The absence of a user table is not a limitation
here; it is the design decision that removes the entire persistence tier. Any pool that adds accounts
re-acquires all of it.

## What it does not disclose

- Server count, connection counts, capacity headroom.
- The regional routing mechanism (see above).
- Monitoring, alerting, or any incident history.
- Whether template sources are per-region or centralised, and how a regional node failure is handled.
- Measured stale rates.
