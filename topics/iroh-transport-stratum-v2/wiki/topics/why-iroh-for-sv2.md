---
title: "Why Iroh for Stratum v2"
type: topic
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-20-sri-discussion-1935-iroh-noise-connection.md
  - raw/papers/2024-erosion-routing-attacks-mining-pools.md
  - raw/articles/2026-05-20-iroh-paycode-case-study.md
  - raw/articles/2026-05-20-iroh-1-0-0-rc-0.md
tags: [iroh, sv2, motivation, design]
---

# Why Iroh for Stratum v2

A focused motivation document. The four reasons that hold up under scrutiny.

## 1. DNS is a censorship surface

SV2 today identifies a pool as `stratum2+tcp://thepool.com:34254/<authority-pubkey>`.
The hostname is in DNS. DNS is:

- **Centrally controllable**: a TLD operator, registrar, or court order can
  remove the name.
- **Single point of failure**: the pool is unreachable for everyone if DNS
  resolution breaks.
- **Network-blockable**: any layer-3 censor can null-route the IP returned by
  DNS, or block the DNS resolution itself.

Iroh dials by 256-bit pubkey (Ed25519 EndpointId). The pubkey is intrinsic to
the pool's authority key — it cannot be revoked by an outside party. Discovery
happens via pkarr/mainline DHT/relays in parallel; an attack must take down
many independent paths.

This is the **stated motivation** for SRI Discussion #1935 (the upstream RFC
this branch implements).

## 2. Erosion mitigation

Tran, von Arx, and Vanbever's "Erosion: Routing Attacks on Cryptocurrency
Mining Pools" (S&P 2024) demonstrated:

- 91% of mining pools across the top 10 cryptocurrencies vulnerable.
- A network adversary can persistently disrupt an SV2 connection via
  **single-packet tampering** of the framing/handshake.

iroh QUIC mitigates this class of attack:
- QUIC packets are individually AEAD-authenticated. A flipped bit drops the
  packet — no "single bad packet kills the session."
- QUIC connection IDs decouple session identity from 5-tuple → no RST-injection.
- The handshake is itself authenticated; tampering drops the packet rather
  than corrupting state.

This is the **strongest single security argument** for the integration. (See
[[Erosion attack|wiki/concepts/erosion-attack.md]].)

## 3. NAT-traversal as a feature

Today, an SV2 pool needs a stable public IP. Tomorrow, a miner-side proxy or
a small private pool can run **without one** because iroh's relay+hole-punching
makes both sides addressable by pubkey alone:

- ~90% of network configurations get a direct connection (vendor claim,
  consistent with Tailscale's "over 90%").
- Remaining ~10% fall back to relay (encrypted, unreadable to the relay).
- Permissionless P2P (libp2p baseline) is ~70%; iroh's curated relay set
  pulls this up to ~90%.

This unblocks decentralized-mining topologies (P2Pool/Braidpool descendants,
miner ↔ miner share-chain gossip) that current TCP+DNS can't model cleanly.

## 4. Production-grade, but pre-1.0

iroh hit **1.0.0-rc.0 in May 2026**. n0 claims production deployment on
"hundreds of thousands of devices." The Paycode case study shows iroh in
production at highway toll booths, with Rust core embedded into Kotlin Android
and a published .NET 6 NuGet — same kind of cross-language deployment story
SV2 needs (miners on many platforms).

Caveat: the integration should target **1.0+** API, not 0.9x. The naming churn
(Node→Endpoint, Discovery→AddressLookup) is mostly behind us as of 1.0-rc.

## Counter-arguments

These are real and addressed in [[Risks and tradeoffs|wiki/topics/risks-and-tradeoffs.md]]:

- QUIC has a 3.5× CPU penalty vs TCP+TLS without NIC offload (Späth et al.,
  NOMS 2026). Pools at scale need to plan for this.
- Some ISPs throttle UDP. Silent failure mode → must always provide TCP
  fallback (which SRI #1935 already specifies).
- Default n0 relays "carry no uptime guarantees" — production deployments
  must self-host relays.
- Iroh pre-1.0 had real silent regressions (issue #2951 — 6% silent transfer
  failure across multiple releases). Pin a known-good version, gate behind
  feature flag.

## See also

- [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]]
- [[Risks and tradeoffs|wiki/topics/risks-and-tradeoffs.md]]
- [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]]
- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
