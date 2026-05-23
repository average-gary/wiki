---
title: "Thesis: an Iroh QUIC transport for SV2 mitigates the Erosion (S&P 2024) single-packet attack class"
type: thesis
status: candidate
created: 2026-05-20
verdict: pending
confidence: medium
core_claim: "Routing the SV2 wire protocol over iroh QUIC eliminates the single-packet-tampering primitive that Erosion (Tran et al., S&P 2024) demonstrated against SV2 over TCP, because QUIC packets are AEAD-authenticated as a unit and connection IDs decouple session identity from 5-tuple."
key_variables: [QUIC AEAD packet protection, connection ID, on-path adversary, Erosion attack primitive, SV2 framing]
falsification: "A demonstrated single-packet attack against the iroh QUIC transport that disrupts an SV2 session in the same persistent way Erosion does over TCP."
---

# Thesis: Iroh transport mitigates Erosion

## Core claim

Routing the SV2 wire protocol over iroh QUIC eliminates the single-packet
tampering primitive Erosion exploits against SV2-over-TCP.

## Suggested follow-up

Run with `/wiki:research --mode thesis "..."` after implementing the transport.
Specifically: simulate the Erosion primitive against an iroh-transported
session and measure persistence.

## Related

- [[Erosion attack|wiki/concepts/erosion-attack.md]]
- [[Why Iroh|wiki/topics/why-iroh-for-sv2.md]]
