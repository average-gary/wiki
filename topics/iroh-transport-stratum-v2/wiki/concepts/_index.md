---
title: iroh-transport-stratum-v2 — concepts
type: index
updated: 2026-07-27
---

# concepts

- [[erosion-attack.md|Erosion: single-packet tampering attack on SV2]] — Routing-attack class: a network adversary on the path between miner and pool disrupts mining sessions to…
- [[fedimint-as-reference.md|Fedimint as the reference implementation]] — SRI Discussion #1935 cites Fedimint as prior art. The Fedimint codebase is directly portable to SV2 — the…
- [[integration-pattern-iroh-blobs.md|Integration pattern — iroh-blobs and Delta Chat as templates]] — The shape of an iroh transport integration is well-established across multiple production codebases.
- [[iroh-custom-transports.md|iroh: Custom transports (Tor, Nym, BLE)]] — Since iroh 0.97 (March 2026), iroh's transport layer is pluggable for any \"unreliable datagram transport…
- [[iroh-endpoint-and-alpn.md|iroh: Endpoint and ALPN]] — The two primitives an SV2 integrator wires to.
- [[iroh-relays.md|iroh: Relays (DERP-style)]]
- [[nat-traversal-baseline.md|NAT traversal — empirical baseline]] — rate (~70% each in the IMC 2026 measurement). UDP is not magically better for traversal — what matters is the…
- [[quic-performance-ceiling.md|QUIC performance ceiling vs TCP]] — Peer-reviewed evidence (Späth et al., NOMS 2026) that QUIC's userspace design imposes a structural…
- [[sv2-framing.md|SV2 framing (codec_sv2)]] — extension_type U16 msg_type U8 msg_length U24
- [[sv2-noise-nx.md|SV2 Noise NX handshake]] — The current authenticated-encryption layer for Stratum v2 connections.
