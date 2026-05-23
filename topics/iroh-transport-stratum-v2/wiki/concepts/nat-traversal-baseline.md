---
title: "NAT traversal — empirical baseline"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: cold
confidence: high
sources:
  - raw/articles/2026-05-20-tailscale-nat-traversal.md
  - raw/articles/2026-05-20-probelab-dcutr-success-rate.md
  - raw/papers/2026-trautwein-dcutr-imc-measurement.md
tags: [nat, hole-punching, dcutr, baseline]
---

# NAT traversal — what to expect

## Direct-connection success rates

| Setting | Rate | Source |
|---------|------|--------|
| Curated overlay (iroh, Tailscale) | ~90% | vendor docs / engineering blog |
| Permissionless P2P (libp2p / IPFS) | 70-72% | Trautwein et al. IMC '26 (4.4M attempts), ProbeLab |
| 1× hard NAT, well-tuned | 99.9% | Tailscale (within 20s, 100 pps probes) |
| 2× hard NAT, default budget | ~0.01% | Tailscale (after 20s) |

## Key observations

- TCP and QUIC are **statistically indistinguishable** for hole-punch success
  rate (~70% each in the IMC 2026 measurement). UDP is not magically better
  for traversal — what matters is the protocol design (DCUtR-style RTT
  synchronization).
- 97.6% of successful punches succeed on **first attempt** — failures fail
  fast.
- VPN'd clients have significantly lower success rates.
- Double hard NAT effectively requires relay.

## What this means for SV2

Most SV2 deployments are **pool ↔ miner**, where the pool has a stable public
IP. NAT is irrelevant on the pool side. So:

- **Pool with public IP + miners on residential**: 100% direct. The pool
  publishes its `EndpointAddr` with the static external addr.
- **Pool ingress for VPN'd or CGNAT'd miners**: still works — the pool side is
  reachable, miner side does the outbound dial.
- **Miner ↔ miner P2P (Braidpool descendants)**: ~30% relay-pinned in
  permissionless setting. Plan for self-hosted relays.

## See also

- [[iroh: Relays|wiki/concepts/iroh-relays.md]]
- [[QUIC performance ceiling|wiki/concepts/quic-performance-ceiling.md]]
