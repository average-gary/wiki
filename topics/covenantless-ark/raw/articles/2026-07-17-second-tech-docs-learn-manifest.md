---
title: "Collection manifest — Second (Bark) docs, Learn section"
source: "https://second.tech/docs (redirected from https://docs.second.tech/); index https://second.tech/docs/llms.txt"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, second, collection-manifest, docs, hark]
summary: "Manifest for a collection ingest of the Learn section of Second's Bark documentation (the clArk/hArk reference implementation). 14 protocol-mechanics pages ingested as raw children; the ~76 API-reference / SDK-language / setup / changelog pages were excluded as out of scope for this protocol-mechanics wiki."
---

# Collection manifest — Second (Bark) docs, Learn section

`docs.second.tech/` 301-redirects to `second.tech/docs`, the root of **Bark**'s multi-page documentation. Bark is Second's Rust reference implementation of Ark (clArk lineage; **hArk enhancement live since Jan 2026**). Full page index: `second.tech/docs/llms.txt` (~90 pages).

## Scope decision

This wiki (`covenantless-ark`) scopes to **Ark protocol round/transaction mechanics**, not client API surface. Accordingly:

**INGESTED — Learn section (14 pages)**, each as a raw child below.
**EXCLUDED (documented, not silently dropped):**
- **barkd API reference (~60 pages)** — REST endpoints (`get-bitcoin-tip-height`, `create-a-bolt11-invoice`, wallet/boards/exits/fees/lightning/onchain/notifications). Client integration surface, out of protocol scope.
- **Bark SDK (8 pages)** — per-language getting-started (Rust/Go/Kotlin/Swift/Dart/React-Native/WASM/index).
- **barkd setup (5 pages)**, **ark-server setup (5 pages)**, **getting-started/bark-cli (5 pages)** — install/config/run guides.
- **agents.md, backups.md, built-with-bark.md, changelog/index.md, api-reference/openapi.json** — operational/meta.

If the API/SDK surface is later needed, re-run `/wiki:ingest-collection` targeting the `barkd/` and `bark-sdk/` subtrees.

## Ingested children (raw/articles/)

1. [[2026-07-17-second-docs-learn-intro.md]] — Intro to the Ark protocol
2. [[2026-07-17-second-docs-learn-rounds.md]] — Ark rounds
3. [[2026-07-17-second-docs-learn-vtxo.md]] — Ark VTXOs (quad-tree, script policies)
4. [[2026-07-17-second-docs-learn-forfeits.md]] — Ark forfeits (hash-lock + connector)
5. [[2026-07-17-second-docs-learn-exit.md]] — Ark emergency exits
6. [[2026-07-17-second-docs-learn-lifetime.md]] — VTXO lifetime
7. [[2026-07-17-second-docs-learn-board.md]] — Ark boarding
8. [[2026-07-17-second-docs-learn-payments.md]] — Ark payments (arkoor)
9. [[2026-07-17-second-docs-learn-offboard.md]] — Ark offboarding
10. [[2026-07-17-second-docs-learn-liquidity.md]] — Ark liquidity (cost formula)
11. [[2026-07-17-second-docs-learn-fees.md]] — Ark fees
12. [[2026-07-17-second-docs-learn-payments-lightning.md]] — Lightning payments
13. [[2026-07-17-second-docs-learn-payments-on-chain.md]] — On-chain payments
14. [[2026-07-17-second-docs-learn-glossary.md]] — Ark protocol glossary

## Supersedes

Replaces the single-file summary [[2026-07-16-implementations-second-bark-docs.md]] (yesterday's research-session ingest), which covered the same docs at lower granularity and predates the hArk-live finding. That file is retained but marked superseded.

## Notable NEW findings vs the superseded file

- **hArk is LIVE** since the **January 2026 hArk update** — not a proposal. On-chain payments now "broadcast immediately upon completion (as of the January 2026 hArk update)."
- Bark refresh VTXO trees are **quad trees** (radix 4, "each branch transaction splits into four outputs") — contrast arkd's binary VTXO tree (radix 2).
- Exact spend-path scripts: **CLTV** `<expiry-height> OP_CHECKLOCKTIMEVERIFY` (root/branch recovery) + relative **CSV** `<144> OP_CHECKSEQUENCEVERIFY` (~1 day) for user emergency exit.
- Standard round VTXO lifetime stated as **~28 days**; Lightning-receive VTXOs **~3 days**.
- Liquidity cost formula: `amount × (expiry_delta ÷ 365 days) × opportunity_rate` (worked example: 100k sat, 5 d, 5% → 68 sats).
- **Delegated refresh** (co-signers sign on the user's behalf; for mobile).
