---
title: LDK Server — Wiki
type: wiki-root
created: 2026-05-26
updated: 2026-05-26
scope: hub-topic
---

# LDK Server — Wiki

Topic wiki for [LDK Server](https://github.com/lightningdevkit/ldk-server) — a ready-to-use Lightning Network node binary built on top of LDK Node, exposing a gRPC API.

## Layout

- `wiki/concepts/` — atomic concept articles
- `wiki/topics/` — synthesizing topic articles
- `wiki/reference/` — pointers to specs, crates, related projects
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts (playbooks, design notes)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: 5 (3 articles, 2 repos)
- Articles compiled: 4 (3 concepts, 1 topic)
- Outputs: 0
- Theses: 0
- Last research session: 2026-05-26 (standard, 5 parallel agents)

## Start here

- [[wiki/concepts/ldk-vs-ldk-node-vs-ldk-server.md|LDK vs LDK Node vs LDK Server]] — the three-layer architecture
- [[wiki/topics/should-i-use-ldk-server.md|Should I use LDK Server? — decision guide]] — the deliverable
- [[wiki/concepts/grpc-api-surface.md|gRPC API surface]] — what it does
- [[wiki/concepts/persistence-and-backup.md|Persistence and backup]] — operator footguns

## Open questions

- When does LDK Server tag its first beta / 1.0?
- Will VSS become a first-class config option in LDK Server (vs only LDK Node)?
- Is there a published HA / multi-instance story planned, or is the hot-wallet-singleton model permanent?
- Who is running LDK Server (the daemon, not just LDK Node embedded) in production?
- How does the MCP bridge interact with HMAC auth — what is the agent permission model?

## Adjacent wikis

- [[../iroh-transport-stratum-v2/_index.md|iroh-transport-stratum-v2]] — SV2 transport (mining-side, not LN-side; no overlap)
- [[../sv2-p2pool-integration/_index.md|sv2-p2pool-integration]] — mining-side
- [[../bitcoin-mining-payout-schemas/_index.md|bitcoin-mining-payout-schemas]] — mining-side
