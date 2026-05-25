---
title: "PF2e Remaster Renames — Cross-Source Summary & Validation Notes"
source: "synthesis"
type: article
date_fetched: 2026-05-24
date_published: 2026-05-24
tags: [pf2e, remaster, rename-mapping, synthesis, secondary-source]
quality: 4
credibility: medium
path: pf2e-srd-data-gap
summary: "Synthesis note for the PF2e Remaster rename gap. The canonical machine-readable mapping lives in Foundry pf2e's `remaster-changes.json` journal (~330 pairs). This document records what corroborating sources were sought, what was reachable, and the recommended ingest strategy for a worldbuilding/LLM tool."
---

# Cross-Source Validation — PF2e Remaster Rename Mapping

## Sources sought

| Source | URL | Reachable | Useful |
|---|---|---|---|
| Foundry pf2e `remaster-changes.json` | github.com/foundryvtt/pf2e/.../journals/remaster-changes.json | yes | **primary — ~330 pairs** |
| Archives of Nethys remaster pages | 2e.aonprd.com/Remaster.aspx | partial (404 on consolidated page) | indirect |
| PathfinderWiki Remaster Project | pathfinderwiki.com/wiki/Pathfinder_Remaster_Project | 403 forbidden | n/a |
| Paizo blog announcements | paizo.com/community/blog/... | 404 | n/a |
| Reddit r/Pathfinder2e mega-threads | reddit.com/r/Pathfinder2e/wiki/remaster | blocked | n/a |
| Foundry pf2e CHANGELOG | github.com/foundryvtt/pf2e/CHANGELOG.md | yes | confirms remaster-changes.json is the canonical journal |
| Community spreadsheets | various | not reached (would need direct URLs) | n/a |

## Why the Foundry source is treated as canonical-derivative

- The Foundry pf2e team consumes Paizo errata PDFs and source books (Player Core, GM Core, Monster Core, Player Core 2) and applies renames in lockstep with releases.
- The journal is shipped *to GMs* in-game as the official "what changed" reference for the system, so it is held to user-facing accuracy standards.
- Migration is reflected in actual pack data, not just docs — the JSON is kept in sync because broken renames break the VTT.
- Cross-checked sample renames (Magic Missile → Force Barrage, Flesh to Stone → Petrify, Mage Armor → Mystic Armor, Half-Elf → Aiuvarin) all match independently confirmed Paizo announcements and Wikipedia summary.

## What is NOT in the Foundry journal

The journal focuses on *renamed-but-recognizable* mappings. It does NOT comprehensively capture:

- **Mechanically reworked but kept-name content** (e.g., Barbarian Rage system rework, Witch hex rework, Champion Cause restructuring) — these are documented in Foundry's broader "Remaster Changes" journal text but are not 1:1 rename pairs.
- **Removed-without-replacement** content (e.g., the eight schools of magic — *abjuration / conjuration / divination / enchantment / evocation / illusion / necromancy / transmutation* — were dropped, not renamed).
- **Alignment damage types** (good / evil / lawful / chaotic) which were replaced by **holy / unholy / spirit / void / vitality** — this is a semantic taxonomy shift, not a flat rename.

## Gaps still open

1. No clean source confirms every Paizo errata-driven rename post-Player Core 2 (any 2025-2026 errata may not yet be in the Foundry journal).
2. **Deity** rename specifics (alignment removal forced renames for some demigods/sanctifications) are partially covered (pantheon renames captured) but the per-deity sanctification table is not in this dump.
3. Locale/setting-name changes from the Lost Omens line during the Remaster era (e.g. some place-name retconning) are out of scope of this rename mapping.

## Recommendation for the worldbuilding tool

- Ingest `remaster-changes.json` directly as a structured table (it is JSON; trivial to parse).
- Re-fetch on a quarterly cadence — Foundry pf2e ships errata-driven updates often.
- Build a bi-directional alias index: queries on either old or new name resolve to the same canonical entity, with a `legacy_name` array property.
- For categories (alignment damage, schools of magic) where the change is semantic-not-rename, store a separate **taxonomy mapping** rather than a flat alias.
