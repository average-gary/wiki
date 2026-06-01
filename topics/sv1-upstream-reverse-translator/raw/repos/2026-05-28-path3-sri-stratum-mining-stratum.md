---
title: "SRI — stratum-mining/stratum repository"
url: https://github.com/stratum-mining/stratum
type: repo
source: github.com
captured: 2026-05-28
quality: 8
path: 3
tags: [sri, reference-implementation, translator, crates, no-reverse-translator, rust]
---

# SRI — stratum-mining/stratum

## Why this matters for the reverse translator

The Stratum Reference Implementation (SRI) is the canonical Rust codebase for SV2. **It does not ship a v2→v1 reverse translator.** Anyone building one starts from SRI's primitives but writes the bridge themselves.

## Key crates

| Crate | Responsibility |
|---|---|
| `sv2/codec-sv2/` | Message codec with encryption capabilities |
| `sv2/noise-sv2/` | Noise protocol implementation |
| `sv2/binary-sv2/` | Binary encoding/decoding for SV2 messages |
| `sv2/channels-sv2/` | Channel management infrastructure |
| `sv2/subprotocols/` | SV2 sub-protocol implementations (mining, JD, template) |
| `stratum-translation` | "Stratum V1 ↔ Stratum V2 translation utilities" |

## Translation direction

SRI ships **v1→v2** (the forward direction):
- `roles/translator/` — SV1 miner downstream, SV2 pool upstream
- This is the inverse of what path-3 covers

## Reverse translator (v2→v1)

- **Not present in `roles/`**
- Spec does not define it (see [[../papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios.md]])
- The `stratum-translation` crate's bidirectional naming hints at primitives reusable for the reverse direction, but no reference role wires it up
- Application-level deployments are directed to the separate `sv2-apps` repository (alpha)

## What an implementer would have to build

- Reverse-translator role wiring (analogous to `roles/translator` but reversed)
- Channel-collapse logic: many SV2 channels → one SV1 connection per worker
- Extranonce remapping: SV2 hierarchical → SV1 flat extranonce1 (lossy)
- Async-to-sync share submit converter (with sequence-number reconciliation)
- Per-channel SetTarget → single-difficulty SV1 mining.set_difficulty
- Rejection of JDP messages from downstream (no upstream to forward to)
- Plaintext-or-stunnel egress to SV1 pool (no Noise on SV1 side)

## Feature-survival verdict

| Feature | Status | Why |
|---|---|---|
| Reuse of SRI codec/noise/binary crates | **survives** | Internal SV2 plumbing reusable |
| Reuse of channel management | **partially-lost** | Channel concept must be flattened at egress |
| Reuse of `stratum-translation` | **partially-survives** | Forward path covered; reverse path largely DIY |
| Reference implementation conformance | **lost** | No v2→v1 reference exists |

## Ingest justification

The codebase reality check: SRI gives you everything for the v1→v2 direction, but the v2→v1 reverse translator is greenfield work. Critical for migration-economics analysis — the engineering cost is non-trivial.
