---
title: "Vardiff controllers cannot see non-arrival — Eric Price's stranded-difficulty finding (Optech #423)"
source: "https://bitcoinops.org/en/newsletters/2026/09/18/"
type: articles
ingested: 2026-09-21
tags: [vardiff, control-loop, stranded-difficulty, share-arrival, timer-based-reduction, hashrate-estimation, revenue-distortion, proxy-placement, last-hop-principle, shaping-proxy, eric-price, anthony-towns]
summary: "Bitcoin Optech #423, 2026-09-18. Eric Price identifies an architectural limitation, not a tuning problem: a vardiff controller that updates only ON SHARE ARRIVAL cannot detect NON-arrival, so a miner that slows down keeps its now-too-high difficulty, produces almost no shares, and therefore never generates the event that would lower it. The miner is stranded at high difficulty indefinitely — underpaid relative to its actual contribution, and invisible to pool-side hashrate estimation, which cannot distinguish 'slowed' from 'disconnected'. Explicitly stated: no amount of parameter tuning fixes it. Remedy is a timer-based reduction (e.g. halve difficulty after N seconds of silence); SRI already implements this though recovery was noted as slow for long-lived connections that have ramped high, while ckpool was reported as recomputing difficulty only on share arrival. The placement conclusion matters more than the fix: Price — control must live at 'the last hop that still sees each miner's shares', and Anthony Towns — in SV2 and DATUM deployments that means the local proxy or gateway, not the upstream pool role, because upstream sees aggregated shares and cannot observe an individual miner's silence. Price published a shaping proxy that probabilistically drops shares so operators can test degraded-miner behaviour without touching production."
authors: [Eric Price, Anthony Towns]
venue: "Bitcoin Optech Newsletter #423"
published: 2026-09-18
credibility: high
credibility_score: 5
credibility_rationale: "Optech is an authoritative technical newsletter with named contributors; the finding is accompanied by a released testing tool and by on-record agreement from a Bitcoin Core contributor on placement. Three days old at ingestion."
confidence: high
confidence_rationale: "High on the mechanism and on the placement argument. The claim that ckpool updates only on share arrival is reported secondhand and should be confirmed against stratifier.c before being asserted."
research_round: 1
research_agent: news
cross_topic: "Eric Price is 'gimballock', whose marafoundation/stratum vardiff/simulation-framework branch is the primary reference of the mining-scale-test-sim hub topic. This finding is the substantive result that topic's harness was built to produce, and the shaping proxy is a new artifact for it."
extraction_note: "Subagent extraction of the newsletter item and its linked discussion. Quoted phrases are the agent's transcription."
---

# Vardiff controllers cannot see non-arrival

**Bitcoin Optech #423, 2026-09-18** — Eric Price, with Anthony Towns on placement.

## The mechanism

Vardiff sets each miner's share difficulty to hold a target submission interval (say one share per
10 s). The standard implementation updates the difficulty **when a share arrives**, using the observed
inter-arrival time.

That control loop has no input for *absence*. When a miner slows down:

1. It keeps its previous difficulty, which is now far too high for its reduced hashrate.
2. It therefore produces far fewer shares than the target rate.
3. Because the controller only runs on arrival, it **never gets the event that would lower the
   difficulty**.
4. The miner stays stranded at high difficulty **indefinitely**.

The loop is self-reinforcing in the wrong direction: the worse the slowdown, the fewer opportunities
the controller gets to correct it.

**Stated explicitly: no amount of parameter tuning can solve this.** It is a structural property of an
arrival-triggered controller, not a badly chosen time constant. That framing is what makes this an
architecture finding rather than an operations note.

## Consequences for a pool

- **Revenue distortion.** The slowed miner contributes real hashrate but is credited with
  disproportionately few shares — it is underpaid, through no fault of its own and with no error
  logged anywhere.
- **Hashrate estimation breaks.** Pool-side estimation cannot distinguish "slowed down" from
  "disconnected", because both look like an absence of shares at the current difficulty. Every
  dashboard built on share-rate-times-difficulty inherits the error.
- **It is silent.** Nothing rejects, nothing errors, nothing alerts. This is the characteristic
  signature of the most dangerous class of pool bug: the accounting is wrong and the system reports
  health.

## The fix, and where it goes

**Timer-based reduction.** Lower difficulty after a fixed interval of silence — e.g. halve it every
30 s without a submission. This gives the controller an input that does not depend on the miner
succeeding.

**Implementation status as reported:**

- **SRI already implements timer-based reduction**, but Price noted **recovery is slow for long-lived
  connections that have ramped up to high difficulty** — halving from a high value takes many
  intervals. So having the mechanism is not the same as having an adequate response time; the
  reduction schedule is itself a design parameter.
- **ckpool was reported as recomputing difficulty only on share arrival**, i.e. exposed. *(Reported
  secondhand — confirm against `stratifier.c`, which tracks `ssdc` (shares since diff change) and
  `ldc` (last diff change). The presence of `ldc` suggests time is at least recorded; whether it
  drives a reduction is the open question.)*

**Placement — the more general result.** Price: control must occur at **"the last hop that still sees
each miner's shares."** Anthony Towns: in Stratum V2 and DATUM deployments that means **the local proxy
or gateway**, not the upstream pool role.

The reasoning generalises beyond vardiff. In a multi-tier topology — miners → proxy/translator/gateway
→ pool — the upstream sees **aggregated** shares. Aggregation destroys exactly the signal needed here:
the absence of one miner's submissions is invisible once mixed with thousands of others' presence.

**Therefore**: any per-miner control loop must live at the deepest tier that still has per-miner
visibility. This is a placement rule that applies to vardiff, to per-miner health detection, to
hashrate estimation, and to stale-rate attribution. It is also an argument about *what a proxy is for*:
not merely connection aggregation, but the last point where per-miner control is possible.

Note the direct tension with ckpool's passthrough scaling model, where aggregation into a single
upstream socket is the whole mechanism for reaching "millions of clients." The finding says that
wherever you aggregate, you must also place the per-miner control loops on the downstream side of the
aggregation point.

## The tool

Price published a **shaping proxy** that simulates degraded miner performance by **probabilistically
dropping shares**, so an operator can evaluate difficulty handling under realistic slowdown without
disrupting production mining. This is the testable artifact: any pool can now determine empirically
whether it strands slowed miners.

## Why this is one of the most useful sources in the round

Most of the architecture material in this round is either a description of what an implementation does
or a vendor claim about performance. This is a *derived* result — a property of a class of control
loops, with a named failure mode, a named remedy, an explicit placement constraint, and a test
harness. It also lands on a component (vardiff) that every pool has and that no one treats as a
correctness-critical subsystem.
