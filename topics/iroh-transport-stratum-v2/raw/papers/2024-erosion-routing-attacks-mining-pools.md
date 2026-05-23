---
title: "Erosion: Routing Attacks on Cryptocurrency Mining Pools"
source_url: https://ieeexplore.ieee.org/abstract/document/10646806/
type: paper
date: 2024
authors: ["Muoi Tran", "Theo von Arx", "Laurent Vanbever"]
venue: IEEE Symposium on Security and Privacy (Oakland S&P) 2024
credibility: high
quality: 5
relevance: direct
tags: [sv2, security, attack, transport, framing]
ingested: 2026-05-20
---

# Erosion (Tran, von Arx, Vanbever — S&P 2024)

A network-level attack that disrupts miner-to-pool sessions to reduce effective
hashrate. **Identifies a Stratum V2 vulnerability allowing persistent connection
disruption via single-packet tampering of the framing/handshake.**

## Key claims

- 91% of mining pools across the top 10 cryptocurrencies vulnerable.
- A network adversary on the path between miner and pool can plausibly affect
  majority Bitcoin hashrate (mining centralization → small number of pools to
  target).
- Single-packet tampering can persistently disrupt a Stratum V2 connection.

## Verbatim

> "Recently, the blockchain community has been promoting the adoption of a more
> secure Stratum protocol known as Stratum V2."

> "We also discover a vulnerability in the Stratum V2 protocol that allows the
> adversary to persistently disrupt a connection by tampering with a single
> packet."

## Why this is load-bearing for the Iroh integration

- TCP exposes raw bytes to on-path adversaries. Even when the SV2 payload is
  Noise-encrypted, the TCP framing (sequence numbers, RST flags) and the
  handshake-discovery bytes are not. Erosion exploits exactly this surface.
- Switching to **iroh QUIC** would mitigate Erosion's specific class of attack:
  - QUIC packets are individually authenticated (AEAD over the entire QUIC
    packet payload including framing). A flipped bit in transit is detected and
    the packet is silently dropped — there is no "single bad packet kills the
    session" primitive.
  - Connection IDs decouple session identity from 5-tuple, so an attacker
    cannot reset by injecting RST equivalents.
  - The handshake (TLS 1.3 + raw public keys) is itself authenticated; tampering
    drops the packet rather than corrupting state.
- This is the strongest single security argument for the iroh transport.
- Caveat: a UDP-blocking adversary can still drop QUIC traffic entirely. That's
  a different class of attack (denial-of-service, not session corruption). The
  fall-back-to-relay path is the mitigation Iroh provides.

## Cite when arguing transport choice

This is a peer-reviewed S&P-tier paper, recent, and specifically against SV2.
Any SRI maintainer evaluating the Iroh transport will recognize Erosion — frame
the integration as an Erosion mitigation.
