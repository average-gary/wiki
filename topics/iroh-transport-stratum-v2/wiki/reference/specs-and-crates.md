---
title: "Reference: specs, crates, repos"
type: reference
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
compiled-from: conversation
tags: [reference, links]
---

# Reference

Canonical pointers — keep these current.

## SV2 specs

- [Stratum V2 spec (canonical mirror)](https://github.com/stratum-mining/sv2-spec)
  - [03 Protocol Overview](https://github.com/stratum-mining/sv2-spec/blob/main/03-Protocol-Overview.md) — framing
  - [04 Protocol Security](https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md) — Noise NX
- Stratum spec website: https://stratumprotocol.org/specification/ (returns 403 for
  programmatic fetches; use the GitHub mirror)
- [SRI repository](https://github.com/stratum-mining/stratum) — protocol crates
- [SRI applications repository](https://github.com/stratum-mining/sv2-apps) — this repo

## SRI Discussion (the design RFC this branch implements)

- [#1935 — RFC: Iroh [Noise] Connection](https://github.com/stratum-mining/stratum/discussions/1935)

## Iroh

- Project: https://www.iroh.computer/
- Repo: https://github.com/n0-computer/iroh
- noq (Quinn fork): https://github.com/n0-computer/noq
- Docs root: https://docs.iroh.computer/
- API docs (current): https://docs.rs/iroh/latest/iroh/
- Concepts:
  - [Endpoints](https://docs.iroh.computer/concepts/endpoints)
  - [Relays](https://docs.iroh.computer/concepts/relays)
  - [Holepunching](https://docs.iroh.computer/concepts/holepunching)
- Examples: https://github.com/n0-computer/iroh-examples
- iroh-blobs: https://github.com/n0-computer/iroh-blobs
- iroh-gossip: https://github.com/n0-computer/iroh-gossip
- IRPC: https://www.iroh.computer/blog/irpc

## Production Iroh integrations

- Paycode (case study): https://www.iroh.computer/blog/paycode
- Delta Chat (`peer_channels.rs`): https://github.com/deltachat/deltachat-core-rust/blob/main/src/peer_channels.rs
- Sendme: https://github.com/n0-computer/sendme
- Dumbpipe (TCP-over-Iroh shim — useful for prototyping):
  https://github.com/n0-computer/dumbpipe

## SV2 crates touched by this work

- `stratum-apps` (this repo) — `network_helpers/{noise_connection, noise_stream}`
- `network_helpers_sv2` (upstream): https://docs.rs/network_helpers_sv2/
- `noise_sv2`: https://docs.rs/noise_sv2/
- `codec_sv2`: https://docs.rs/codec_sv2/

## Adjacent / alternatives

- libp2p: https://libp2p.io/
- rust-libp2p: https://docs.rs/libp2p/latest/libp2p/
- DCUtR spec: https://github.com/libp2p/specs/blob/master/relay/DCUtR.md
- libp2p hole punching post: https://blog.ipfs.tech/2022-01-20-libp2p-hole-punching/
- Punchr (DCUtR measurement): https://github.com/libp2p/punchr
- Tailscale NAT traversal: https://tailscale.com/blog/how-nat-traversal-works
- Hyperswarm / Pears: https://docs.pears.com/
- Veilid: https://veilid.com/

## Standards

- RFC 7250 (Raw Public Keys in TLS): https://datatracker.ietf.org/doc/html/rfc7250
- RFC 9000 (QUIC): https://datatracker.ietf.org/doc/html/rfc9000
- RFC 9001 (TLS 1.3 + QUIC): https://datatracker.ietf.org/doc/html/rfc9001
- RFC 9002 (QUIC loss detection): https://datatracker.ietf.org/doc/html/rfc9002
- draft-ietf-quic-multipath: https://datatracker.ietf.org/doc/draft-ietf-quic-multipath/
- draft-ietf-quic-address-discovery: (QAD)
- draft-seemann-quic-nat-traversal: https://datatracker.ietf.org/doc/draft-seemann-quic-nat-traversal/

## Adversarial baseline (security)

- Erosion (Tran et al., S&P 2024): https://ieeexplore.ieee.org/abstract/document/10646806/
- Trautwein et al. IMC 2026 (DCUtR @ scale): https://arxiv.org/abs/2604.12484 (companion preprint 2510.27500)
- Späth et al. NOMS 2026 (QUIC kernel bypass): https://zirngibl.github.io/files/spaeth2026quicbypass.pdf
- Noise NX formal analysis (Girol et al. USENIX Sec '20): https://www.usenix.org/system/files/sec20-girol_0.pdf
- Vernetti M.Sc. thesis on SV2: https://webthesis.biblio.polito.it/27678/

## SV2 deployments and pool ecosystem

- DMND (Demand): https://dmnd.work
- SRI Roadmap Q4 2025–Q1 2026: https://stratumprotocol.org/blog/sri-roadmap-2026/
- New SV2 Working Group members (May 2026): https://stratumprotocol.org/blog/new-members/
- DATUM / OCEAN: https://ocean.xyz/
