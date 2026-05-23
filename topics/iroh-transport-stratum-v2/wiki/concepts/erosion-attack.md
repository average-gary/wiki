---
title: "Erosion: single-packet tampering attack on SV2"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: cold
confidence: high
sources:
  - raw/papers/2024-erosion-routing-attacks-mining-pools.md
tags: [sv2, attack, security, transport]
---

# Erosion (Tran et al. S&P 2024)

Routing-attack class: a network adversary on the path between miner and pool
disrupts mining sessions to reduce effective hashrate.

## Findings

- **91% of mining pools across the top 10 cryptocurrencies vulnerable.**
- Mining centralization (small number of pools) means a network adversary can
  plausibly affect majority Bitcoin hashrate.
- **Single-packet tampering** can persistently disrupt a Stratum V2 connection.

> "We also discover a vulnerability in the Stratum V2 protocol that allows the
> adversary to persistently disrupt a connection by tampering with a single
> packet."

## How TCP enables this

TCP exposes raw bytes to on-path adversaries. Even when the SV2 payload is
Noise-encrypted, the TCP framing (sequence numbers, RST flags) and parts of
the SV2 handshake-discovery bytes are visible to and modifiable by the
attacker.

## Why iroh QUIC mitigates Erosion

- QUIC packets are individually authenticated. AEAD covers the entire QUIC
  packet payload including framing. A flipped bit in transit is detected and
  the packet silently dropped — no "single bad packet kills the session"
  primitive.
- QUIC connection IDs decouple session identity from 5-tuple. An attacker
  cannot reset by injecting RST equivalents.
- The handshake (TLS 1.3 + raw public keys) is itself authenticated; tampering
  drops the packet rather than corrupting state.

## Caveat

A UDP-blocking adversary can drop QUIC traffic entirely. That's a different
class of attack (denial-of-service vs. session corruption). Iroh's
fall-back-to-relay path is the mitigation — and the existing `feat/iroh-transport`
RFC's TCP fallback is the safety net for that case.

## Why this is the strongest single security argument for iroh transport

This is a **peer-reviewed, S&P-tier, recent, SV2-specific** paper. SRI
maintainers will recognize it. Frame the integration as "Erosion mitigation by
transport replacement" — that's the cleanest single-line motivation.

## See also

- [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]]
- [[Why Iroh|wiki/topics/why-iroh-for-sv2.md]]
- [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]]
