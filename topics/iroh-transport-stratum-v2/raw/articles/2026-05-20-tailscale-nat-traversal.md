---
title: "How NAT Traversal Works (Tailscale)"
source_url: https://tailscale.com/blog/how-nat-traversal-works
type: post
date: 2020 (rolling updates)
org: Tailscale
credibility: high
quality: 5
relevance: indirect
tags: [nat, hole-punching, stun, ice, baseline]
ingested: 2026-05-20
---

# How NAT Traversal Works (Tailscale)

The canonical, widely-cited public reference for what hole-punching can and
cannot do. Sets the realistic ceiling and tail.

## Headline number

> "If you stopped reading now and implemented just the above, I'd estimate you
> could get a direct connection over **90%** of the time."

Matches iroh's vendor claim of "9 out of 10".

## Birthday-paradox port discovery

For one hard NAT, given 256 open ports:

| Probes | Success |
|--------|---------|
| 174 | 50% |
| 256 | 64% |
| 1024 | 98% |
| 2048 | 99.9% |

At 100 packets/sec probe rate: ~2 sec to median, ~20 sec to 99.9%.

## Double hard NAT

Catastrophic — both sides hard-NAT'd:

> "after 20 seconds... our chance of success is… 0.01%"

99.9% success requires ~170,000 probes per side ≈ 28 minutes at 100 pps. In
practice: relay required.

## Firewall state-table risk

Juniper SRX 300 hard cap: **64,000 active sessions** — aggressive probing can
exhaust state tables and harm other traffic on the network.

## IPv6 sidesteps NAT entirely

IPv6 deployment ~33% globally (uneven by region). Where both peers have IPv6,
NAT traversal is moot.

## Implications for SV2

- **A pool with a stable public IP**: NAT is irrelevant on the pool side. Only
  miner-side NAT matters, and the pool publishes a reachable endpoint, so 100%
  direct connections to the pool.
- **P2Pool/Braidpool descendants**: peer-to-peer mining where neither side has
  a stable public IP hits the 70-90% / double-NAT-tail problem. Plan for relay
  fallback.
- **Probe rate hygiene**: don't blast 1000s of pps at NAT — risk of state-table
  exhaustion on the miner's home router. Iroh's NAT traversal already paces
  itself; manual probing schemes shouldn't exceed.
