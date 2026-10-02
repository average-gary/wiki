---
title: "stratum-sri"
type: topic-wiki
created: 2026-05-28
updated: 2026-09-02
---

# stratum-sri

> Stratum Reference Implementation (SRI) — the `stratum-mining/stratum` repo of low-level SV2 crates: codec, framing, noise, channels, subprotocols, and the `stratum-core` workspace umbrella.

## Statistics

- Sources: 31 raw documents (28 articles, 2 repos including the git collection manifest, 1 note)
- Articles: 18 compiled wiki articles (10 concepts, 4 topics, 4 references incl. the lint-generated coverage backlog)
- Last compiled: 2026-09-02
- Last lint: 2026-05-28

## Quick Navigation

- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Theses](wiki/theses/_index.md)
- [Outputs](output/_index.md)

## Recent Changes

- 2026-09-02: Compiled the new concept `spec-as-security-surface` (spec ambiguity as attack surface, worked through sv2-spec #95 + the 0x0001 field-name drift + SECURITY.md's code-only scope) and added Core's Cap'n Proto mining IPC to the TDP article. Coverage backlog 2 → 1.
- 2026-09-02: Ingested Vinteum's mining Deep Dive report (Aug 24–28, 2026) — first secondary/ecosystem source in this wiki: SV2 role vocabulary (device/proxy/pool service/template provider/JDC/JDS), "specifications are part of the security surface", Bitcoin Core's Cap'n Proto mining IPC, a P2Pool v2 security edge case, and the BM13xx/Mujina/Bitaxe hardware layer.
- 2026-07-17: Incremental compile of 2 new sv2-spec sources → new concept `sv2-extensions-negotiation` (extension 0x0001 RequestExtensions handshake, the positive-ACK resolution of sv2-spec issue #95) and updated `sv2-extensions`.
- 2026-05-28: Topic wiki initialized; ingested SRI repo at HEAD `65c9688c` (origin: stratum-mining/stratum, branch main).
- 2026-05-28: Collection ingest via `git` adapter at the same HEAD — 26 child docs (root policy files + per-crate READMEs/BENCHES) into `raw/articles/`, manifest in `raw/repos/`.
- 2026-05-28: First compile — 15 wiki articles synthesized from the git collection. Concepts cover the SV2 wire stack (binary encoding, framing, codec, Noise, buffer pool) plus channel state, message handlers, and extensions; topics cover the umbrella crate and the four subprotocols; references cover the crate map, release process, and recent-PR themes.
