---
title: "Large-Scale Measurement of NAT Traversal for the Decentralized Web (DCUtR in IPFS)"
source_url: https://arxiv.org/abs/2604.12484
secondary_url: https://arxiv.org/abs/2510.27500
type: paper
date: 2026-04-14
authors: ["Dennis Trautwein", "Cornelius Ihle", "Moritz Schubotz", "Corinna Breitinger", "Bela Gipp"]
venue: ACM Internet Measurement Conference (IMC '26), Karlsruhe
credibility: high
quality: 5
relevance: direct
tags: [dcutr, libp2p, hole-punching, quic, tcp, measurement]
ingested: 2026-05-20
---

# DCUtR / NAT-traversal at internet scale (Trautwein et al., IMC 2026)

The peer-reviewed venue version of the longitudinal IPFS measurement campaign.
Companion preprint at arxiv 2510.27500 covers the full 4.4M-attempt dataset.

## Headline numbers

- **4.4 million DCUtR traversal attempts** across **85,000+ networks** in
  **167 countries** from production IPFS data.
- **Hole-punching success rate: 70% ± 7.1%** in permissionless deployment.
- **TCP and QUIC are statistically indistinguishable (~70% each)** — refutes
  the long-held assumption that UDP/QUIC is inherently superior for hole
  punching.
- **97.6% of successful connections established on first attempt.**
- Success is independent of relay characteristics — validates permissionless
  relay design.

## Verbatim

> "DCUtR's high-precision, RTT-based synchronization yields statistically
> indistinguishable success rates for both TCP and QUIC (~70%)."

> "The mechanism is highly efficient, with 97.6% of successful connections
> established on the first attempt."

> "Success is independent of relay characteristics ... validating the protocol's
> design for permissionless environments."

## Implications for Iroh-as-SV2-transport

- **70% direct-connection success** is the empirical floor for permissionless
  P2P NAT traversal. The remaining ~30% sessions need relay fallback.
- Iroh's vendor-claimed **~90% direct connection rate** (docs.iroh.computer/concepts/holepunching)
  is _better than libp2p's measured rate_, plausibly because iroh's relay set
  is curated rather than permissionless.
- For SV2: a pool with a stable public IP eliminates the inbound-NAT problem
  entirely (the pool side is reachable, only the miner side is NATed; pool
  publishes its addr in the EndpointAddr).
- For miner-to-miner P2P scenarios (P2Pool/Braidpool descendants), the 70%
  permissionless floor is more relevant. Plan for ~30% relay-pinned sessions
  if the discovery layer is permissionless rather than n0-curated.
- **Relay = always in trust path**: even when traffic ends up going direct,
  the DCUtR protocol uses the relay to broker the simultaneous-open. So the
  relay is in the trust path even at 100% direct-connection rates.

## Pair with

- ProbeLab DCUtR success rate (similar number, smaller dataset, 72% / 13.3k)
- Tailscale "How NAT traversal works" (engineering perspective on why ~90%)
- iroh's own holepunching concept page (vendor 90% claim)
