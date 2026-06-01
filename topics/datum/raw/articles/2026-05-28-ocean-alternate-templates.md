---
title: "Alternate Templates"
source: "https://ocean.xyz/docs/templateselection"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, block-template, mining-pool, decommissioned]
summary: "OCEAN's How-To page on alternate block template options. Documents the now-decommissioned (Dec 21, 2025) menu of pre-DATUM block-template choices that miners could opt into via separate stratum endpoints. Now positioned as a starting point for miners building their own DATUM templates."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "templateselection"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/templateselection"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# Alternate Templates

> OCEAN previously offered alternate block-template options for miners who
> desired different policies than the OCEAN default, before DATUM made it
> possible for miners to control their own block templates.

## Status

These alternate-template stratum endpoints were **decommissioned on December
21, 2025**. The page is preserved as a reference / starting point for miners
who want to build their own block templates against `datum_gateway`.

## Decommissioned Endpoints

All four legacy endpoints carried the same 2% pool fee.

| Template | Description | Stratum endpoints |
|----------|-------------|-------------------|
| OCEAN Recommended (default) | Includes only transactions and reasonably small data | `mine.ocean.xyz:3334`, `default.mine.ocean.xyz:3101` |
| Core+Antispam | Bitcoin Core + antispam patch | (decommissioned) |
| Core | Bitcoin Core defaults | (decommissioned) |
| Data-Free | Bitcoin Knots, no data carrier | (decommissioned) |

## Current Recommendation

> "Alternate template information below is provided for miners looking for a
> starting point to configure their own block templates."

i.e. miners now run `datum_gateway` against their own node (Bitcoin Knots
recommended) and set `blockmaxweight=3985000` (or stricter / looser policy
flags) to mirror whichever of the four legacy templates they want.

## Cross-Reference

- The four "templates" are documented as separate node-policy pages:
  Core+Antispam → `ordispolicy`, Core → `corepolicy`, Data-Free →
  `datafreepolicy`, OCEAN Recommended → `nodepolicy`.
