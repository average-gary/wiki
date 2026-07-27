---
title: Wiki — Iroh Integration for SV2
type: index
updated: 2026-05-20
---

# Wiki — Iroh Integration for SV2

## Topics (synthesizing reads)

- [[topics/why-iroh-for-sv2.md|Why Iroh for SV2]] — motivation, in 4 reasons
- [[topics/sv2-iroh-transport-playbook.md|Integration playbook]] — the deliverable
- [[topics/risks-and-tradeoffs.md|Risks and tradeoffs]] — steelman against

## Concepts (atomic reference reads)

### iroh side
- [[concepts/iroh-endpoint-and-alpn.md|iroh: Endpoint and ALPN]]
- [[concepts/iroh-relays.md|iroh: Relays]]
- [[concepts/iroh-custom-transports.md|iroh: Custom transports (Tor, Nym, BLE)]]
- [[concepts/integration-pattern-iroh-blobs.md|Integration pattern — iroh-blobs and Delta Chat as templates]]
- [[concepts/fedimint-as-reference.md|Fedimint as the reference implementation]] ⭐

### SV2 side
- [[concepts/sv2-noise-nx.md|SV2 Noise NX handshake]]
- [[concepts/sv2-framing.md|SV2 framing]]
- [[concepts/erosion-attack.md|Erosion attack]]

### Cross-cutting
- [[concepts/nat-traversal-baseline.md|NAT traversal — empirical baseline]]
- [[concepts/quic-performance-ceiling.md|QUIC performance ceiling vs TCP]]

## Reference

- [[reference/specs-and-crates.md|Specs, crates, repos]]

## Theses (candidates for follow-up research)

- [[../theses/iroh-mitigates-erosion.md|Iroh mitigates Erosion]]
- [[../theses/dual-transport-vs-iroh-only.md|Dual transport beats iroh-only]]

## Stats

- 20 raw sources ingested (3 papers, 13 articles, 4 repos)
- 12 wiki articles compiled (3 topics + 9 concepts + 1 reference)
- 2 candidate theses
- Last research session: 2026-05-20 (--deep, 8 parallel agents + 1 Fedimint follow-up)
