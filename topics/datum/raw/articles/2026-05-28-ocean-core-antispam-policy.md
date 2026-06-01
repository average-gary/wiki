---
title: "Core Antispam Node Policy"
source: "https://ocean.xyz/docs/ordispolicy"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, bitcoin-core, antispam, node-policy, block-template]
summary: "OCEAN's Core+Antispam template policy. A Bitcoin Core v25.0 node with an antispam patch and one tweak: blockmaxweight=3985000 (vs Core default 3996000), reserving template space for OCEAN's potentially large coinbase payout transactions."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "ordispolicy"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/ordispolicy"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# Core Antispam Node Policy

> Bitcoin Core v25.0 + an antispam patch (referenced via GitHub) configured
> with one deliberate deviation from defaults to leave room for OCEAN's
> coinbase.

## Configuration

| Parameter | Bitcoin Core default | OCEAN setting | Rationale |
|-----------|---------------------|---------------|-----------|
| `blockmaxweight` | 3996000 | **3985000** | Reserves template space for potentially large coinbase payout transactions |

All other settings track Bitcoin Core v25.0 defaults plus the antispam patch.

## Status

This is one of the four template options listed at `templateselection`; the
endpoints serving these alternate templates were decommissioned on
December 21, 2025. The policy doc itself is preserved as a reference for
miners building their own DATUM Gateway block templates that mirror the
old "Core+Antispam" behavior.

## Operator

OCEAN — Bitcoin Ocean, LLC (subsidiary of Mummolin, Inc., Wyoming).
