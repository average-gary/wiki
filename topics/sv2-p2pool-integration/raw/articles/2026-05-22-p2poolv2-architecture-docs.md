---
title: "p2poolv2 docs/architecture/"
source_url: https://github.com/p2poolv2/p2poolv2/tree/main/docs/architecture
type: design-doc
ingested: 2026-05-22
quality: 4
confidence: medium
tags: [p2poolv2, architecture, share-pipeline, async]
---

# p2poolv2 docs/architecture/

Closest thing p2poolv2 has to internal architecture documentation. README.md explicitly notes: docs are "largely LLM-generated to help newcomers and other LLMs."

## Files
- `README.md` — overview
- `async-flow.md` — tokio async task topology
- `share-processing-pipeline.md` — share-receive → validate → store → gossip flow
- `store-architecture.md` — rocksdb usage patterns
- `store-schema.md` — rocksdb keyspace design

## Adjacent docs (top-level `docs/`)
- `atomic-swap/` — atomic swap design for paying small miners
- `difficulty_adjustment/` — share-difficulty target adjustment
- `tower-layer/` — tower middleware patterns (parallels sv2-apps's tower usage)
- `share-windows.excalidraw` + PNG — visual share-chain window diagram

## Confidence note
Because the architecture docs are LLM-generated rather than written by maintainers, they should be cross-checked against the actual code (`p2poolv2_lib/src` module map) before being treated as authoritative for design decisions.
