---
title: "Data-Free Node Policy"
source: "https://ocean.xyz/docs/datafreepolicy"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, bitcoin-knots, data-carrier, node-policy, block-template]
summary: "OCEAN's Data-Free template policy. Bitcoin Knots v28.1 (20250305) with three OCEAN-specific deviations: datacarriersize=0 (no data-carrier transactions in the template), blockmaxsize=3985000, blockmaxweight=3985000, and blockprioritysize=0. All other Knots defaults preserved (full RBF, P2SH-only multisig, etc)."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "datafreepolicy"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/datafreepolicy"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# Data-Free Node Policy

> Based on **Bitcoin Knots v28.1 (20250305)**. Settings differing from Knots
> defaults are prefixed "OCEAN" in the upstream doc; defaults are preserved
> elsewhere.

## Transaction Relay & Mining

| Parameter | Default | OCEAN setting | Notes |
|-----------|---------|---------------|-------|
| `acceptnonstdtxn` | 0 | 0 | Does not relay non-standard txs |
| `datacarrier` | 1 | 1 | Relays data-carrier txs |
| `datacarriercost` | 1 | 1 | Treats extra data as ≥1 vbyte/byte |
| `datacarriersize` | 42 | **0** | No data-carrier data in our template/relay |

## Block Construction

| Parameter | Default | OCEAN setting | Notes |
|-----------|---------|---------------|-------|
| `blockmaxsize` | 300000 | **3985000** | Template size in bytes |
| `blockmaxweight` | 1500000 | **3985000** | BIP141 weight |
| `blockprioritysize` | 100000 | **0** | No high-priority/low-fee reserve |

## Defaults Preserved

| Parameter | Default | Effect |
|-----------|---------|--------|
| `bytespersigop` | 20 | |
| `maxscriptsize` | 1650 | |
| `minrelaytxfee` | 0.00001 BTC/kvB | |
| `mempoolreplacement` | `fee,-optin` | Full RBF enabled |
| `mempoolmultisig` | 0 | Does not relay non-P2SH multisig |

## Notable Properties

- Increased block-size capacity (≈4MB-class template) **vs**
- Eliminated data-carrier (OP_RETURN) carrying transactions via
  `datacarriersize=0`, in line with the "Data-Free" name.

## Status

One of the four legacy template options. Endpoints decommissioned
December 21, 2025. Reference for DATUM Gateway operators who want a
data-light block template against Bitcoin Knots.
