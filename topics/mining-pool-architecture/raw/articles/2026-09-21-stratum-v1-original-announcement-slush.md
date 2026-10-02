---
title: "Stratum mining protocol — original announcement (BitcoinTalk)"
source: "https://bitcointalk.org/index.php?topic=108533.0"
type: articles
ingested: 2026-09-21
tags: [stratum-v1, protocol-history, getwork, getblocktemplate, bip22, bip23, connection-scaling, asic-era, slush, de-facto-standard]
summary: "Marek Palatinus (slush0) announces the Stratum mining protocol on BitcoinTalk, 11 September 2012. States the design goals explicitly — server-driven load management for 10k+ connections at minimal CPU, reduced bandwidth and latency versus getwork, and readiness for ASIC hardware — and argues that BIP22/23 were too complex for immediate real-world deployment, so a complete implementable stack mattered more than a payload specification. BTC Guild's operator withdrew a near-identical competing proposal in the thread to avoid a 'VHS vs Betamax' split, which is the moment Stratum became the de facto standard over the technically more decentralising getblocktemplate."
authors: [Marek Palatinus (slush / slush0)]
published: 2012-09-11
venue: "BitcoinTalk — Mining / Pools"
credibility: high
credibility_rationale: "Primary source: the protocol author's own announcement, with contemporaneous replies from named pool operators and miner-software developers."
confidence: high
research_round: 1
research_agent: historical
extraction_note: "Structured extraction produced by a research subagent from the live thread; not a verbatim page dump. Quoted phrases are the subagent's transcription of the thread and should be re-verified against the URL before being quoted in published output."
---

# Stratum mining protocol — original announcement

**Marek Palatinus (slush, BitcoinTalk user 2167)** — BitcoinTalk, Mining/Pools —
**11 September 2012, 03:07:01 AM**

Documentation and reference code were published at `mining.bitcoin.cz/stratum-mining`
alongside open-source pool software and a mining proxy.

> **Provenance caveat.** The content below is a research subagent's structured extraction of the
> thread, not a byte-faithful capture. Dates and attributions were reported as verified against the
> post header. Treat the paraphrased design-goal statements as accurate in substance; re-fetch the
> URL before quoting any sentence verbatim in a published artifact.

## Stated design goals

- **Scalability via server-driven load management.** The protocol is designed so the *server*
  decides when a miner gets new work, rather than the miner polling. The announcement claims
  handling of **10k+ connections** with minimal CPU resources — a direct answer to getwork's
  request-rate problem.
- **Efficiency.** Reduced bandwidth and latency compared with getwork.
- **ASIC compatibility.** Written in anticipation of ASIC hardware, i.e. of hashrate per device
  rising far beyond what per-request work delivery could feed.

## The explicit rejection of BIP22/BIP23

Rather than adopting the already-published getblocktemplate standards, Palatinus argued for a
simpler, more practical specification:

- What mattered was a **"complete stack and step-by-step algorithm"** — an implementable protocol
  including the client and proxy sides — not just a definition of message payloads.
- BIP22/23 were characterised as lacking immediate real-world applicability: **too complex for
  rapid deployment**.

This is the pivotal architectural decision in pool history: a pragmatic, informally specified
protocol beat a formally specified one whose stated purpose (BIP23) was to counteract mining
centralisation by letting miners audit and modify templates.

## Reception in the thread

- **Eleuthria (BTC Guild operator)** withdrew a competing protocol proposal of his own, noting the
  two designs were **"almost identical"**, and advocated unified adoption explicitly to avoid a
  **"VHS vs Betamax"** standards war.
- Eleuthria requested additions for operational reality: **graceful restart notifications with a
  wait timer**, so a pool could signal planned maintenance rather than dropping connections. (Note
  the architectural theme — the first feature request on the first day is about connection
  lifecycle management under operator-initiated disruption.)
- Miner-software developers (poclbm, GUIminer) committed to native Stratum support in the thread.
- Rapid adoption by major pools (BTC Guild) followed.

## Architectural consequences

1. **Work push replaces work pull.** The server notifies; the miner does not poll. This is what
   makes 10k+ idle-but-latency-sensitive connections viable on one process, and it is why every
   later pool design is a fan-out broadcast problem rather than a request/response one.
2. **Pool-constructed templates became the norm for the next 7+ years.** Because Stratum V1 carries
   no mechanism for the miner to declare its own template, choosing Stratum over GBT handed
   transaction selection to pool operators as a side effect of a scalability decision.
3. **No BIP, no formal standard.** The protocol evolved by discussion and implementation. Later
   criticism (see the Bitcoin Wiki retrospective) is that this happened "behind closed doors"
   without wider development-community input — which is the process gap Stratum V2's public
   specification was meant to close.

## Open items from this source

- The "10k+ connections with minimal CPU" figure is an author claim in an announcement, not a
  measurement. No methodology, hardware, or share-rate context is given. It should not be carried
  into any sizing model as evidence.
- The bandwidth/latency improvement over getwork is asserted, not quantified, in this post.
