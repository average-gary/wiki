---
title: "What Nobody Tells You About HTTP/3: UDP Throttling"
source_url: https://loke.dev/blog/what-nobody-tells-you-about-http3-udp-throttling
type: blog
date: 2024-2025
org: independent
credibility: medium
quality: 4
relevance: indirect
tags: [quic, http3, udp, throttling, contrarian, isp]
ingested: 2026-05-20
---

# UDP throttling in the wild (Loke)

Concrete production observations of UDP throttling and silent QUIC degradation.

## Findings

> "Some consumer ISPs use a strategy called 'UDP Policing.' They allocate a
> specific bucket of bandwidth for UDP traffic" — capping throughput "to a
> fraction of the available bandwidth."

One observed scenario: throttled to ~1 Mbps on otherwise high-capacity links.

> Middleboxes mistake bursty inbound UDP for "a DNS amplification attack" and
> either drop or rate-limit it.

> P99 latency *spiked* after enabling HTTP/3, and "H2 connections are
> consistently 2x faster than your H3 connections."

> "it won't 'fail,' so your error logs will look perfectly green"

Browser/Alt-Svc caching can pin clients to broken QUIC paths across network
changes; conservative `ma` of 60 seconds recommended during rollout.

## Implications for SV2

- A miner on a residential ISP that polices UDP might silently get a slow iroh
  connection while its TCP-over-Noise SV2 connection works fine. Stale-share
  rate climbs, miner blames the pool.
- Mitigations:
  1. **Always provide a TCP fallback** (already in SRI #1935 — server-side dual
     transport). Miners auto-detect: try iroh first, fall back to TCP if
     measured throughput falls below a floor.
  2. **Telemetry**: log path RTT and throughput per connection so a miner can
     tell their ISP is throttling them, not the pool.
  3. **Documentation**: warn pool operators that some miners on UDP-policed
     ISPs may need TCP transport. This is not a defect — it's reality.
- The silent-failure mode is the worst class of bug. Build alerts on unexpected
  RTT regressions per-connection from day one.
