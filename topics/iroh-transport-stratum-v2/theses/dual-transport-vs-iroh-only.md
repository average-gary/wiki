---
title: "Thesis: a dual-transport (TCP+iroh) deployment outperforms iroh-only at the long tail of consumer ISPs"
type: thesis
status: candidate
created: 2026-05-20
verdict: pending
confidence: medium
core_claim: "Across a representative population of residential miner ISPs, a Stratum V2 deployment offering both TCP and iroh transports has lower stale-share rates than an iroh-only deployment, because some non-trivial fraction of ISPs throttle UDP silently."
key_variables: [UDP throttling, ISP middlebox behavior, iroh QUIC throughput, stale share rate, share submission RTT]
falsification: "An iroh-only deployment with measured stale-share rates equal to or better than dual-transport across a representative geographic and ISP distribution of miners over a 30-day period."
---

# Thesis: dual transport beats iroh-only at the long tail

## Core claim

A dual-transport (TCP+iroh) SV2 deployment has lower stale-share rates than an
iroh-only deployment because some ISPs silently throttle UDP and miners on
those ISPs benefit from TCP fallback.

## Suggested follow-up

Run a 30-day A/B test with a real miner population once the integration ships.
Or: compile observed UDP-throttling-rate data across CDNs (Cloudflare, Akamai)
to estimate the affected population.

## Related

- [[QUIC performance ceiling|wiki/concepts/quic-performance-ceiling.md]]
- [[Risks and tradeoffs|wiki/topics/risks-and-tradeoffs.md]]
