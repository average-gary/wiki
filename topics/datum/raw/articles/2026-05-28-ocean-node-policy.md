---
title: "OCEAN Node Policy"
source: "https://ocean.xyz/docs/nodepolicy"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, bitcoin-knots, node-policy, block-template, parasitic-protocols]
summary: "OCEAN's recommended node policy. Bitcoin Knots v29.2 with: blockmaxsize=3985000 (vs default 300000), blockmaxweight=3985000 (vs 1500000), blockprioritysize=0 (vs 100000). Standard Knots defaults preserved for transaction-relay standards, data-carrier, RBF, parasitic-protocol rejection, and minrelaytxfee."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "nodepolicy"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/nodepolicy"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# OCEAN Node Policy

> The default OCEAN-recommended template, based on **Bitcoin Knots v29.2**.
> Sits between "Core" (Bitcoin Core defaults) and "Data-Free" (Knots with
> `datacarriersize=0`) — Knots-style parasitic-protocol rejection is enabled
> via Knots defaults, but `datacarrier` is left on (Knots default).

## Block Construction

| Parameter | Default | OCEAN setting | Notes |
|-----------|---------|---------------|-------|
| `blockmaxsize` | 300000 | **3985000** | bytes |
| `blockmaxweight` | 1500000 | **3985000** | reserves space for large coinbase |
| `blockprioritysize` | 100000 | **0** | no high-priority/low-fee reserve |

## Defaults Maintained

- Transaction-relay standards (Knots default).
- Data-carrier handling (Knots default — relayed but bounded).
- Replace-by-fee policy (Knots default).
- Parasitic-protocol rejection (Knots default).
- `maxscriptsize=1650`.
- `minrelaytxfee=0.00001 BTC/kvB`.

## Status

> "[We] decommissioned our alternative template options on December 21st,
> 2025."

This page is the canonical OCEAN-recommended policy and remains the
template behavior matched by `mine.ocean.xyz:3334` (post-decommission, this
is the only OCEAN-served template; everything else must be self-hosted via
DATUM Gateway).

## Operator

OCEAN — Bitcoin Ocean, LLC (subsidiary of Mummolin, Inc., Wyoming).
Copyright © 2023–2026.
