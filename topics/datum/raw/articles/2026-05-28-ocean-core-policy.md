---
title: "Core Node Policy"
source: "https://ocean.xyz/docs/corepolicy"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, bitcoin-core, node-policy, block-template]
summary: "OCEAN's Core template policy. Bitcoin Core v29.0 with a single deviation from defaults: blockmaxweight=3985000 (vs default 3996000), reserving template space for OCEAN's coinbase. All other Core defaults preserved."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "corepolicy"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/corepolicy"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# Core Node Policy

> Bitcoin Core v29.0 with a single deviation: a slightly reduced
> `blockmaxweight` to leave room for OCEAN's coinbase payout transaction.

## Configuration

| Parameter | Bitcoin Core default | OCEAN setting | Rationale |
|-----------|---------------------|---------------|-----------|
| `blockmaxweight` | 3996000 | **3985000** | Reserves a small amount of template space for our potentially large coinbase payout transactions |

> "Where OCEAN's settings differ from the Bitcoin Core defaults, the
> modified setting and rationale are shown."

All other settings track Bitcoin Core v29.0 defaults.

## Status

One of the four template options listed at `templateselection`; alternate
template endpoints decommissioned December 21, 2025. The policy doc remains
a reference for DATUM Gateway operators who want to recreate the old "Core"
template against their own node.

## Operator

OCEAN — Bitcoin Ocean, LLC (subsidiary of Mummolin, Inc., Wyoming).
