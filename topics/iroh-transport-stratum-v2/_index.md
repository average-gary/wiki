---
title: Iroh Integration for Stratum v2 — Wiki
type: wiki-root
created: 2026-05-20
updated: 2026-05-20
scope: project-local
project_repo: sv2-apps-iroh-transport
---

# Iroh Integration for Stratum v2 — Wiki

Project-local wiki for the `feat/iroh-transport` branch of `sv2-apps`. Captures research,
design notes, and integration playbooks for replacing/augmenting the existing Noise-over-TCP
transport with [Iroh](https://github.com/n0-computer/iroh) (QUIC + raw-public-key TLS,
relays, hole-punching, peer addressing via NodeId).

## Layout

- `wiki/concepts/` — atomic concept articles (Iroh primitives, SV2 transport requirements, etc.)
- `wiki/topics/` — synthesizing topic articles (the integration playbook lives here)
- `wiki/reference/` — pointers to specs, crates, similar projects
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts (playbooks, design notes)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: 21 (3 papers, 14 articles, 4 repos)
- Articles compiled: 12 (3 topics, 9 concepts, 1 reference)
- Outputs: 2 plans ([iroh-rc-1-bump-2026-05-27](output/plan-iroh-rc-1-bump-2026-05-27.md), [sv2-transport-abstraction-pr-2026-05-26](output/plan-sv2-transport-abstraction-pr-2026-05-26.md))
- Theses: 2 candidates
- Last research session: 2026-05-27 (rc.1 release-notes ingest; iroh-endpoint-and-alpn + iroh-relays re-verified)
- Last plan: 2026-05-27 (iroh rc.0 → rc.1 bump)

## Start here

- [[wiki/topics/why-iroh-for-sv2.md|Why Iroh for SV2]] — motivation
- [[wiki/topics/sv2-iroh-transport-playbook.md|Integration playbook]] — the deliverable
- [[wiki/topics/risks-and-tradeoffs.md|Risks and tradeoffs]] — steelman against

## Open questions

- Does Iroh's QUIC + 0-RTT handshake meet SV2 latency goals on a worldwide pool?
- How does Iroh's connection migration interact with mining session continuity?
- Can Iroh's relays substitute for the role of a publicly-routable pool address?
- Is it worth keeping Noise inside an Iroh tunnel, or is Iroh's TLS sufficient?
