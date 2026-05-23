---
title: Wiki — Iroh Integration for SV2
type: index
updated: 2026-05-20
---

# Wiki — Iroh Integration for SV2

## Topics (synthesizing reads)

- [[Why Iroh for SV2|topics/why-iroh-for-sv2.md]] — motivation, in 4 reasons
- [[Integration playbook|topics/sv2-iroh-transport-playbook.md]] — the deliverable
- [[Risks and tradeoffs|topics/risks-and-tradeoffs.md]] — steelman against

## Concepts (atomic reference reads)

### iroh side
- [[iroh: Endpoint and ALPN|concepts/iroh-endpoint-and-alpn.md]]
- [[iroh: Relays|concepts/iroh-relays.md]]
- [[iroh: Custom transports (Tor, Nym, BLE)|concepts/iroh-custom-transports.md]]
- [[Integration pattern — iroh-blobs and Delta Chat as templates|concepts/integration-pattern-iroh-blobs.md]]
- [[Fedimint as the reference implementation|concepts/fedimint-as-reference.md]] ⭐

### SV2 side
- [[SV2 Noise NX handshake|concepts/sv2-noise-nx.md]]
- [[SV2 framing|concepts/sv2-framing.md]]
- [[Erosion attack|concepts/erosion-attack.md]]

### Cross-cutting
- [[NAT traversal — empirical baseline|concepts/nat-traversal-baseline.md]]
- [[QUIC performance ceiling vs TCP|concepts/quic-performance-ceiling.md]]

## Reference

- [[Specs, crates, repos|reference/specs-and-crates.md]]

## Theses (candidates for follow-up research)

- [[Iroh mitigates Erosion|../theses/iroh-mitigates-erosion.md]]
- [[Dual transport beats iroh-only|../theses/dual-transport-vs-iroh-only.md]]

## Stats

- 20 raw sources ingested (3 papers, 13 articles, 4 repos)
- 12 wiki articles compiled (3 topics + 9 concepts + 1 reference)
- 2 candidate theses
- Last research session: 2026-05-20 (--deep, 8 parallel agents + 1 Fedimint follow-up)
