---
title: "Archives of Nethys — public Elasticsearch endpoint (de-facto API)"
source: "https://elasticsearch.aonprd.com/aon/_search"
type: article
date_fetched: 2026-05-24
date_published: unknown
tags: [pf2e, aon, archives-of-nethys, api, elasticsearch, scraping, data-export, primary-source]
quality: 5
credibility: high
path: pf2e-srd-data-gap
summary: "AoN exposes a publicly-reachable Elasticsearch instance at elasticsearch.aonprd.com that powers the site's search UI. /aon/_search returns full JSON records (name, description, source, traits, mechanics) without authentication. There is no documented API contract, rate limit policy, or terms of use; the endpoint is the same one the site's JavaScript search calls. This is the closest thing to an 'API' or 'data export' AoN offers."
---

# AoN Elasticsearch endpoint

## What it is

`https://elasticsearch.aonprd.com/aon/_search` is a public Elasticsearch HTTP endpoint that backs the search functionality on `2e.aonprd.com`. The site's client-side search JavaScript queries this host directly; no proxy, no auth header, no token. This makes it the **de-facto AoN API** even though AoN does not advertise it as one.

## Verified behavior (2026-05-24)

- `GET /aon/_search` — returns JSON: standard Elasticsearch response shape (`took`, `timed_out`, `_shards`, `hits.total`, `hits.hits[]`).
- `GET /aon/_search?q=fireball` — returns Fireball spell records (Core Rulebook + Player Core entries), plus magical staves and themed spell lists that reference Fireball.
- Records contain: name, full description text, source book, traits, mechanical fields (level, school, traditions, casting, range, area, damage), and version metadata distinguishing pre-Remaster / Remaster entries.
- Hit count exceeds 10,000 documents per query class — the index covers actions, ancestries, archetypes, backgrounds, classes, conditions, creatures, equipment, feats, hazards, rules, setting entries, skills, spells, rituals, and traits (matching the site's nav structure).
- Standard ES query DSL accepted via POST body (`query`, `aggs`, `size`, `from`, etc.), since this is an unmodified Elasticsearch HTTP API surface.

## What this is NOT

- **Not a documented API.** No swagger, no OpenAPI, no published schema, no client library, no versioning commitment, no rate-limit headers documented.
- **Not a sanctioned data export.** AoN has not published JSON/CSV/SQLite dumps. The only "export" is whatever an arbitrary `_search` query returns.
- **Not legally bundled with AoN's commercial license.** AoN's Licenses page says Paizo PI is "used by Archives of Nethys under commercial license"; that license is between Rose-Winds LLC and Paizo. A third-party tool that pulls from this Elasticsearch endpoint **does not inherit** AoN's commercial license — its redistribution posture must come from Paizo's public licenses (ORC, Community Use, OGL) directly.

## Stability risk

Because this is undocumented, AoN can:

- Add Cloudflare / WAF / IP rate limiting at any time
- Move the endpoint behind auth
- Change the index name (`/aon/`) or shape
- Take it down without notice

A tool that depends on this endpoint at runtime takes on a hard third-party liveness dependency on a hobbyist-operated infra. **Bulk-pull-then-cache** is safer than runtime querying, and **using Foundry VTT pf2e's Apache-2.0 JSON packs as the primary source** is safer than either.

## Comparable community projects

- **`foundryvtt/pf2e`** (GitHub) — JSON packs, Apache 2.0 code license, per-pack license provenance metadata. Cleaner ingestion path than AoN.
- **`pf2etools/pf2etools`** (community fork of 5e.tools pattern) — separate ingestion lineage; not AoN-derived.
- No evidence of an **`aonprd`** or **`AonNethys`** GitHub org publishing data tooling (both URLs 404 as of 2026-05-24).

## Implication for a worldbuilding tool

Three options, in order of recommended preference:

1. **Use Foundry VTT pf2e packs as primary source.** Apache-2.0 code, ORC/OGL content per record, provenance preserved.
2. **Use AoN's Elasticsearch endpoint for fields Foundry doesn't expose** (e.g., AoN's flavor text edits, AoN-specific category groupings) — but only as a secondary, opt-in enrichment layer, with caching, and with full awareness that this is undocumented and revocable.
3. **Avoid AoN entirely** if the tool wants a clean license story. Derive from Paizo's published ORC content directly.

In all three cases: the tool's redistribution posture comes from **ORC + Community Use** (or **OGL legacy** for pre-Remaster content), **never from AoN**.

## Related

- [[2026-05-24-aon-licenses-page-commercial-license]] — AoN's own license stance
- [[2026-05-24-pf2e-srd-data-foundryvtt-pf2e]] — recommended primary ingestion source
