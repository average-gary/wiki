---
title: "SRI translator-proxy role (forward only)"
source: https://github.com/stratum-mining/sv2-apps/tree/main/miner-apps/translator
type: repos
tags: [sri, sv2-apps, translator-proxy, forward-only]
summary: "The SRI reference translator-proxy in sv2-apps. Hard-coded forward direction: src/lib/sv1/ for downstream miner-side, src/lib/sv2/ for upstream pool-side. README explicitly disclaims reverse direction. Reverse-translator template is here, but inverted."
confidence: high
ingested: 2026-05-28
ingested_by: path2
quality_score: 5
---

# SRI translator-proxy role

## Direction (forward only)

- `src/lib/sv1/` — *downstream*, faces the SV1 miner.
- `src/lib/sv2/` — *upstream*, talks to the SV2 pool.

The role binary is structured around this single direction. README and crate docs do not mention a reverse mode.

## Reverse-translator template

A reverse translator inverts the role binary structure:
- `src/lib/sv2/` — *downstream*, faces the SV2 client.
- `src/lib/sv1/` — *upstream*, talks to the SV1 pool.

The async task layout, mpsc channels, and shared-state Arcs are likely identical in shape — only the message-direction handlers and the translation helper choices differ.

## Why this matters

- A reverse translator does not need a new architecture; it needs the existing one mirrored.
- The cleanest first step is `cargo new sv2-apps/roles/reverse-translator` parallel to `miner-apps/translator`, copy the task scaffolding, swap the inner message handlers.
- Rust crate boundaries already allow this: `stratum-translation` exposes both `sv1_to_sv2` and `sv2_to_sv1` modules, and `handlers-sv2` exposes both `FromClient` and `FromServer` async traits.

## See also

- [[2026-05-28-path2-sv2-spec-issue-102-proxy-annex]] — canonical concept reference
- [[2026-05-28-path1-sri-stratum-translation-crate]] — the bidirectional translation helpers
- [[2026-05-28-path4-handlers-sv2-bidirectional]] — FromClient/FromServer trait split
