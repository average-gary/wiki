---
title: "Measured SV1 vs SV2 benchmarks on real ASICs — and the published claims they do not match"
source: "https://github.com/average-gary/sv2-benchmarking-report"
related_sources: ["https://github.com/stratum-mining/benchmarking-tool"]
type: data
ingested: 2026-09-22
tags: [benchmark, sv1-vs-sv2, job-latency, block-propagation, stale-shares, bandwidth, testnet4, reusable-harness, retraction, claim-provenance, measurement-methodology]
summary: "RETRACTS round 1's claim that no benchmark of pool software exists. Two empirical SV1-vs-SV2 benchmarks were run on real ASICs with a public, reusable Docker harness (stratum-mining/benchmarking-tool, 171+ commits since Jan 2024). Sep 2024: 6x Antminer S19k Pro over ~10 days. Oct 2025: 10x Antminer S21Imm over ~3.8 days. Both on testnet4 with WAN latency simulated from live pool RTT sampled every minute, on a 16-vCPU/24GB VM, instrumented with Prometheus/Grafana/Loki and automated PDF output. Oct 2025 results: new-job latency 142 ms (SV1) vs 7.33 ms (SV2); new job after a block 158 ms vs 57.3 ms; block propagation 50.5 ms vs 1.43 ms; share acceptance 98.7% vs 100%; stale shares 1,114 vs 0. Sep 2024: 115 ms vs 16 ms; 102 ms vs 15 ms; 79 ms vs 1.5 ms; 99.7% vs 100%; 153 stale vs 0. Bandwidth is a genuine trade, not a win: SV2 used MORE at farm level (521 vs 245 B/s in Oct 2025) because more roles run locally, and LESS at pool level (402 vs 551 B/s). CRITICALLY, these numbers do NOT match the SV2 project's published marketing figures (228 -> 57.7 -> 2.44 ms job latency; 96.3 -> 3.44 ms propagation; 7.4% profit; 60/70% bandwidth reduction) — only '57.7 ms' appears at all, and there as an SV2 RESULT rather than a baseline. So the marketing claims have a different, unidentified provenance."
measurement_window: "2024-09-11 to 2024-09-20; 2025-10-06 to 2025-10-10"
credibility: medium
credibility_score: 4
credibility_rationale: "Real hardware, real mining, disclosed methodology, published Prometheus snapshots and PDFs in a public repo, and an open reusable harness — far stronger than any vendor claim. Held below high because the benchmark was run by a mining company rather than an independent party, it is testnet4-only at 6-10 ASICs, and this session read a subagent's summary rather than the PDFs directly."
confidence: medium
research_round: 2
research_agent: D1
retracts: "wiki/topics/optimal-pool-architecture.md, wiki/references/pool-sizing-model.md, topics/_index.md and _index.md all asserted that 'no benchmark of any pool software was found'. That claim is FALSE and is corrected wherever it appears."
independence_note: "Run by a mining company using a mix of its own proprietary firmware and Braiins OS, with a contact address at that company; the harness itself is maintained by the neutral stratum-mining organisation. Not an independent third-party evaluation — the party measuring SV2's benefit is a party with an interest in SV2. Recorded generically at the user's direction; the specific company is named in the public repo."
extraction_note: "Subagent read of two local checkouts of the same public upstream plus the harness repo. Result tables transcribed from the reports. Verify against the PDFs before quoting a figure externally."
---

# Measured SV1 vs SV2 — and a retraction

## The retraction

Round 1 stated, in four places: *"No benchmark of any pool software was found — every implementation
claims high performance and none substantiates it."*

**That is false.** Two empirical benchmarks exist, with real ASICs, disclosed methodology, published
data, and a reusable open-source harness. The claim has been corrected wherever it appeared.

What survives from round 1's scepticism, and is in fact strengthened: **the SV2 project's *published
marketing figures* still have no identified provenance**, and they do not match these measurements.
Round 1 was right to distrust the numbers and wrong to say no numbers existed.

## The harness

**`github.com/stratum-mining/benchmarking-tool`** — 171+ commits since January 2024, maintained by the
neutral Stratum Mining organisation.

- `./run-benchmarking-tool.sh`, interactive, auto-configures Docker Compose.
- Configuration **A** (with Job Declaration) or **C** (without); testnet4 / testnet3 / signet / mainnet.
- Miners point at `localhost:34255` (SV2) or `localhost:3333` (SV1).
- Grafana on `localhost:3000`; Prometheus metrics, Loki logs, PDF export.
- Custom proxies inserted at measurement points to time job delivery and share submission.
- **WAN latency simulated**: every minute it pings major public pools and applies the average to the
  pool↔miner links. So the latency is representative rather than arbitrary — but it is injected, not
  geographic.

That this exists and is runnable is arguably more valuable than either result: it makes the topic's
central evidential gap closable by anyone with a few ASICs.

## Results

### October 2025 — 10× Antminer S21Imm, ~3.8 days

| Metric | SV1 | SV2 | Ratio |
|---|---|---|---|
| New job latency (mean) | 142 ms | **7.33 ms** | ~19× |
| New job after block (mean) | 158 ms | **57.3 ms** | ~3× |
| Block propagation (mean) | 50.5 ms | **1.43 ms** | ~35× |
| Share acceptance | 98.7% | **100%** | +1.3 pp |
| Stale shares | 1,114 | **0** | — |
| Total shares | 82,870 | 164,408 | — |
| Blocks mined | 19 | 23 | — |

### September 2024 — 6× Antminer S19k Pro, ~10 days

| Metric | SV1 | SV2 | Ratio |
|---|---|---|---|
| New job latency (mean) | 115 ms | **16 ms** | ~7× |
| New job after block (mean) | 102 ms | **15 ms** | ~7× |
| Block propagation (mean) | 79 ms | **1.5 ms** | ~53× |
| Share acceptance | 99.7% | **100%** | +0.3 pp |
| Stale shares | 153 | **0** | — |
| Total shares | 50,698 | 49,188 | — |
| Blocks mined | 103 | 79 | — |

### Bandwidth is a trade, not a win

| | SV1 | SV2 |
|---|---|---|
| Farm level (Oct 2025) | 245 B/s | **521 B/s** |
| Pool level (Oct 2025) | 551 B/s | **402 B/s** |
| Farm level (Sep 2024) | 111 B/s | **635 B/s** |
| Pool level (Sep 2024) | 626 B/s | **507 B/s** |

SV2 uses **more** bandwidth at the farm and **less** at the pool, because Job Declaration moves roles
(JDC, Template Provider) onto the miner's premises. That is architectural, not a defect — and it is a
more honest framing than a single "60/70% reduction" figure. It also matters not at all in practice:
these are **hundreds of bytes per second**, confirming this topic's finding that bandwidth was never a
binding constraint.

## The 0% stale result, revisited

Round 1 argued on principle that a 100% share-acceptance rate is impossible, since staleness comes from
network propagation rather than wire format. **Both benchmarks measured exactly 0 stale shares for SV2.**

The reconciliation is in the numbers rather than in the principle. These runs covered ~4–10 days with
19–103 blocks at 6–10 ASICs — tens of thousands of shares, not millions. A stale rate low enough to
produce zero events in 164,408 shares is entirely consistent with being non-zero: the SV1 arm's 1,114
stales out of 82,870 is 1.34%, so if SV2 cuts the stale window by ~20× the expected SV2 count is single
digits, and zero is an unremarkable draw. **"0 stale observed in this window" is a sound measurement;
"0% stale" as a protocol property is not.** Round 1's objection to the *claim* stands; its implication
that the measurement must be wrong does not.

## Claim provenance: the marketing figures are unexplained

The SV2 project publishes: job latency **228 ms → 57.7 ms → 2.44 ms**, block propagation
**96.3 ms → 3.44 ms**, share acceptance **99.8% → 100%**, **7.4% profit increase**, **60%/70% bandwidth
reduction**.

**None of these numbers appears in either benchmark report**, with one coincidence: `57.7 ms` does
appear in the Oct 2025 report — as the **SV2 result** for "new job after block", not as a baseline or an
intermediate step. Every other figure is absent.

So the marketing figures come from somewhere else: a simulation, a theoretical model, an unreleased
third measurement, or a CPU-miner proof-of-concept (the harness's own overview PDF includes a 16.5-hour
CPU-miner demo showing 99.6% vs 100% acceptance — explicitly a demo, not the ASIC benchmark). **The
published claims remain unsourced, and they are not these benchmarks.** They should still not be cited.

Note too that the real measurements are in places *more* favourable to SV2 than the marketing (19–53×
on propagation and job latency), which makes the decision to publish different numbers harder to explain.

## Stated limitations

1. **testnet4 only** — irregular during the period due to a timewarp attack, minimal fees, atypical
   mempool behaviour. Mainnet may differ, and fee-driven template churn is exactly what SV2's
   `fee_threshold` interacts with.
2. **Small scale** — 6–10 ASICs over 4–10 days, not a multi-PH/s fleet over months.
3. **Simulated latency**, not real geographic distribution.
4. **Mid-test interruptions** — the SV1 pool was patched during the Oct 2025 run (timewarp); the Sep 2024
   run had two full-suite restarts.
5. **Asymmetric implementations** — SV1 served by Public Pool (a *solo* pool) against custom SRI roles
   for SV2. Not a like-for-like pool comparison, and the SV1 arm's implementation quality bounds the
   baseline.
6. **No profitability model** — latency and stale rates were measured; no profit percentage was computed.
   So the "7.4% profit" claim has no basis here either.
7. **Not independent** — see `independence_note` in the frontmatter.

## The accurate replacement for the retracted claim

> Two empirical SV1-vs-SV2 benchmarks have been published using real ASICs on testnet4, with a public
> reusable Docker harness (`stratum-mining/benchmarking-tool`): September 2024 (6× S19k Pro, ~10 days)
> and October 2025 (10× S21Imm, ~3.8 days). They measured job latency, block propagation, stale rate and
> bandwidth, finding SV2 7–19× faster on job delivery, 35–53× faster on block propagation, and zero stale
> shares observed against 1.34% for SV1 — while using *more* bandwidth at the farm and *less* at the
> pool. Limitations: testnet4, 6–10 ASICs, simulated WAN latency, a solo pool as the SV1 arm, and a
> non-independent evaluator. **No benchmark comparing pool *implementations* to each other exists**, and
> the SV2 project's published performance figures do not match these reports and remain unsourced.

The narrower surviving gap is real and worth keeping: **nothing measures ckpool against sv2-apps against
Miningcore against public-pool** on the same load. Protocol comparison exists; implementation comparison
does not.
