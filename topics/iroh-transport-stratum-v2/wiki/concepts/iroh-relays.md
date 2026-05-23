---
title: "iroh: Relays (DERP-style)"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-20-iroh-relays-concept.md
  - raw/articles/2026-05-20-tailscale-nat-traversal.md
  - raw/articles/2026-05-20-probelab-dcutr-success-rate.md
  - raw/papers/2026-trautwein-dcutr-imc-measurement.md
tags: [iroh, relay, nat, derp]
---

# iroh Relays

Relays serve **two functions**:

1. **NAT-traversal coordination**: peers exchange address info via the relay
   and try to upgrade to a direct path.
2. **Encrypted-traffic fallback**: when no direct path is reachable, traffic
   flows through the relay. Relay cannot decrypt.

## Direct-connection rate

| Source | Rate | Setting |
|--------|------|---------|
| iroh docs (vendor) | ~90% | n0's curated relay set |
| Tailscale (engineering) | "over 90%" | similar curated overlay |
| ProbeLab DCUtR (libp2p, measurement) | ~72% | permissionless |
| Trautwein et al. IMC 2026 | 70% ± 7.1% | permissionless, 4.4M attempts |

Permissionless P2P (libp2p-style) gets ~70%. Curated (iroh/Tailscale) gets ~90%.
The curated relay set is doing the work — confirms the relay layer is
load-bearing for hole-punching, not just data fallback.

## Production caveat (vendor admission)

n0's hardcoded public relays:

> "Carry no uptime or performance guarantees"
> "Are shared across all iroh developers worldwide"
> "Public relays are suitable for development and testing"
> "For production, use dedicated relays"

So a serious SV2 deployment **must self-host relays**. The `iroh-relay` binary
is the reference implementation. Wire format as of 0.91 (Aug 2025): WebSocket
exclusively, with RFC 5705 keying material exporters and RFC 9729 HTTP
Concealed Authentication.

## Pool deployment scenarios

| Scenario | Relay needed? |
|----------|---------------|
| Pool with public IP, miners on residential | **No relay needed** — pool publishes static external addr; miners always reach it directly |
| Pool with public IP, miners behind CGNAT | Pool publishes static addr — miners reach it directly |
| Pool behind NAT (rare; small/private pool) | Yes — relay needed for inbound coordination |
| Miner ↔ miner P2P (Braidpool successors) | Yes for ~30% of sessions in permissionless setting |

## Relay = always in the trust path during setup

Even for sessions that end up direct, the relay brokers the simultaneous-open
during connection establishment. It cannot decrypt data, but it knows which
peer is talking to which peer. This is metadata leakage and a privacy
consideration — not equivalent to TCP's "any on-path observer can see
metadata", but not zero either.

## See also

- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
- [[NAT traversal: hole-punching baseline|wiki/concepts/nat-traversal-baseline.md]]
- [[QUIC performance ceiling|wiki/concepts/quic-performance-ceiling.md]]
