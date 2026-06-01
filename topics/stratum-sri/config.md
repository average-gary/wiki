---
title: "stratum-sri"
description: "Stratum Reference Implementation (SRI) — the upstream stratum-mining/stratum repo: low-level SV2 protocol crates plus the stratum-core workspace umbrella."
created: 2026-05-28
freshness_threshold: 70
---

# Wiki Configuration

## Scope

Research and notes on the SRI low-level codebase at `github.com/stratum-mining/stratum`, locally checked out at `~/repos/stratum`. Covers:

- Workspace layout: `stratum-core` (workspace root), `sv1/`, `sv2/*`, `protocols/`, `roles/`, `benches/`, `fuzz/`, `scripts/`.
- SV2 crate surface: `binary-sv2`, `buffer-sv2`, `codec-sv2`, `framing-sv2`, `noise-sv2`, `channels-sv2`, `handlers-sv2`, `parsers-sv2`, `extensions-sv2`, `subprotocols/`.
- `stratum-translation` (SV1 ↔ SV2 translation).
- Release flow, MSRV, toolchain, contributing/security policy.
- PR/commit history as observed from `main`.

Out of scope for this topic (covered elsewhere):

- Application-level wiring (`sv2-apps`) → see `topics/sv2-p2pool-integration` and the future sv2-apps notes.
- p2pool / share-chain integration questions → see `topics/sv2-p2pool-integration`.
- `user_identity` / coinbase tagging thesis → see `topics/sv2-coinbase-identity`.
- MARA-internal deployment plans → live in repo-local `.wiki/` (e.g. `pool-v4-infra`), never here.

## Conventions

- Hub-publishable. Nothing employer-confidential goes in this topic. If a note becomes MARA-flavored, move it to a repo-local `.wiki/`.
- Source-of-truth for code is the upstream repo at the recorded commit SHA, not the local working tree.
- When ingesting upstream files, prefer `/wiki:ingest-collection --adapter git` over single-file ingest; one-shot raw repo ingest captures repo-level metadata only.
