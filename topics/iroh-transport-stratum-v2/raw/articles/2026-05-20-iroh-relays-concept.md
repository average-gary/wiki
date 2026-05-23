---
title: "iroh Relays concept page"
source_url: https://docs.iroh.computer/concepts/relays
type: docs
date: 2026-05-20
org: n0-computer
credibility: high
quality: 4
relevance: direct
tags: [iroh, relay, derp, nat-traversal, deployment]
ingested: 2026-05-20
---

# iroh Relays — Concept

## Two functions

1. **NAT-traversal coordination** — exchange address info to attempt direct P2P.
2. **Encrypted-traffic fallback** — when direct path fails, traffic flows through
   the relay. Relay cannot decrypt (E2EE).

## Headline numbers (vendor-stated)

> "roughly 9 out of 10 networking conditions allow a direct connection"

Implies ~10% of sessions remain relay-pinned by the vendor's own claim. Holds
across sessions: "if it works between two devices once, it will continue to work
as long as their networking setup stays stable".

## Default relay tier — production unsuitable

n0's hardcoded public relays:

> "Carry no uptime or performance guarantees"
> "Are shared across all iroh developers worldwide"
> "Public relays are suitable for development and testing"
> "For production, use dedicated relays"

For SV2 this means an integrator MUST self-host relays for any non-toy deployment.
This doubles infra burden vs. keeping plain TCP ingress.

## Relay properties

- Stateless, no persistent storage.
- Cannot read traffic (E2EE encryption is on the iroh QUIC channel).
- Source/binaries on GitHub as `iroh-relay`.
- Wire format: as of iroh 0.91 (Aug 2025), exclusively WebSocket; raw TCP relay
  path was removed. RFC 5705 keying material exporters and RFC 9729 HTTP
  Concealed Authentication Scheme adopted.

## Implications for SV2

- A pool's existing infrastructure (a public IP for stratum2+tcp ingress) is
  ALSO a workable iroh deployment — just register that IP as the endpoint's
  static external addr (`Endpoint::add_external_addr`) and skip the relay path
  for inbound miners.
- Mobile/home-mining deployments where neither side has a public IP rely on
  relays for ~10% of sessions. For those, self-hosted relays are the only
  acceptable production choice.
- Self-hosted relay binary (`iroh-relay`) speaks WebSocket + custom datagram
  framing; not a standalone STUN/TURN server replacement.
