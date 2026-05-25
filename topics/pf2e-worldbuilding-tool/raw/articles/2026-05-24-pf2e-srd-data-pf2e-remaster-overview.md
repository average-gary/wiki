---
title: "Pathfinder 2e Remaster Project — Overview & Licensing Shift"
source: "https://en.wikipedia.org/wiki/Pathfinder_Roleplaying_Game"
type: article
date_fetched: 2026-05-24
date_published: unknown
tags: [pf2e, remaster, player-core, gm-core, monster-core, ogl-to-orc, secondary-source]
quality: 4
credibility: high
path: pf2e-srd-data
summary: "Pathfinder 2e Remaster (announced April 2023) replaces the original Core Rulebook/Bestiary with Player Core, GM Core, Monster Core, and Player Core 2. The Remaster removes OGL/D&D-derived content (alignments, schools of magic, named monsters/spells) and republishes everything under ORC. Backwards-compatible with existing 2e supplements."
---

# PF2e Remaster — Notes from Wikipedia + Cross-References

## Timeline

- **April 2023**: Paizo announces the Remaster Project.
- **Late 2023**: *Player Core* and *GM Core* release.
- **2024**: *Monster Core* and *Player Core 2* release.
- All future Paizo PF2e publications are ORC-licensed (not OGL).

## What the Remaster Replaces

- The original **Core Rulebook (2019)** — OGL-licensed.
- The original **Bestiary (2019)** — OGL-licensed.
- These books **will not be reprinted**; they remain legally usable but are the legacy stream.

## Content Changes Driven by the License Shift

Items removed or replaced because they are tied to D&D / WotC IP via the OGL:

- **Alignment mechanics** (the 9-point alignment system) — removed/replaced with sanctification-style mechanics for relevant abilities.
- **Eight schools of magic** (abjuration, conjuration, etc.) — replaced with the 4-tradition system already in PF2e plus new categorization.
- **Specific spell names** (e.g., "magic missile" became "force barrage", "fireball" stays but others rebrand).
- **Specific monster names** tied to D&D (devils with proper names like "pit fiend" — many renamed; demons, drow, etc.).
- **Magic items** with D&D-derived names.

## Backwards Compatibility

> "The new books remain backwards-compatible with existing Second Edition supplements."

Mechanically, characters built under the original CRB still work with Remaster supplements; it's primarily a naming/ownership migration plus targeted rules cleanup.

## Licensing Implications

- **Post-Remaster (ORC)**: Player Core, GM Core, Monster Core, Player Core 2, and all 2024+ books.
- **Pre-Remaster (OGL 1.0a)**: Original CRB, original Bestiaries 1-3, Advanced Player's Guide, Secrets of Magic, Guns & Gears (pre-Remaster), most 2019-2023 books. These remain available under OGL but cannot be combined into ORC products.

## Implications for a PF2e Worldbuilding/LLM Tool

A tool starting today (2026) should target the **Remaster (ORC) corpus as primary**: cleaner license posture, future-proof, and Paizo's official direction. Pre-Remaster OGL content can be ingested *separately* if needed for adventures published before 2024, but mixing OGL and ORC content in a single output is forbidden by both licenses. The renaming churn (force barrage vs. magic missile, etc.) means data ingestion must track per-source-book license version and probably present the Remaster nomenclature by default with legacy aliases for search.
