---
title: "libp2p NAT Hole-Punching Success Rate (ProbeLab)"
source_url: https://probelab.io/talks/libp2p-nat-hole-punching-success-rate/
type: measurement
date: 2022-2024
org: ProbeLab (Protocol Labs)
credibility: high
quality: 5
relevance: indirect
tags: [dcutr, libp2p, hole-punching, measurement, contrarian]
ingested: 2026-05-20
---

# libp2p hole-punching success rate (ProbeLab)

Strongest empirical baseline for permissionless P2P hole punching. Steelman
data point against the "Iroh just works" narrative.

## Numbers

- **~72% success rate** across ~13,300 attempts to ~2,500 unique peers.
- 97% of *successful* punches succeed on first attempt; median duration ~0.9 s.
- The **28% non-success tail is operationally relevant** for mining — that's
  the % of sessions that depend on the relay being reliable.
- VPN'd clients have a "significantly lower" success rate.

## Mechanism

> DCUtR requires a relay at all times to broker the Connect/Sync exchange.

So the relay is in the trust path during connection setup **even when traffic
later goes direct**. This is true of iroh too — the relay coordinates the
hole-punch, then the data flow goes direct.

## Implications

- **For SV2 miner ↔ pool**: pool runs a public iroh endpoint. No hole-punch
  needed. 100% direct.
- **For miner ↔ miner P2P (Braidpool/P2Pool descendants)**: ~28% relay-dependent
  is unacceptable centralization risk if the relay is a single n0-operated
  service. Pair with self-hosted relays.
- **VPN'd miners**: a non-trivial population of miners use VPNs (privacy,
  circumventing pool-blocking). They will hit the lower-success tail.
