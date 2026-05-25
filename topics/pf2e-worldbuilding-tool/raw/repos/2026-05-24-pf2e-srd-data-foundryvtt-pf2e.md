---
title: "foundryvtt/pf2e — Pathfinder 2e System for Foundry VTT"
source: "https://github.com/foundryvtt/pf2e"
type: repo
date_fetched: 2026-05-24
date_published: 2019-01-01
tags: [pf2e, foundry-vtt, json-data, apache-2, paizo-partnership, primary-source]
quality: 5
credibility: high
path: pf2e-srd-data
summary: "The most comprehensive structured PF2e data dump in the open-source world — JSON compendium packs covering ancestries, classes, spells, equipment, hazards, bestiaries, and more. Code is Apache 2.0; game content is published under a Paizo–Foundry partnership agreement, with content under OGL/ORC as appropriate."
---

# foundryvtt/pf2e — Repository Notes

## Purpose

Community-developed Pathfinder Second Edition game system module for Foundry Virtual Tabletop. Officially endorsed by Foundry Gaming LLC and authorized through a Paizo–Foundry partnership agreement.

## Tech & Composition

- **TypeScript** 85.3%
- **Handlebars** 7.6%
- **SCSS** 5.4%
- **Svelte** 1.7%
- Data lives in `packs/` directory as JSON compendium files.

## Compendium Pack Categories

**Core character data**:
- `ancestries`, `ancestryfeatures`, `heritages`
- `classes`, `classfeatures`
- `backgrounds`, `deities`
- `actions`, `feats`, `feat-effects`
- `spells`, `spell-effects`
- `equipment`, `equipment-effects`
- `conditions`, `hazards`, `vehicles`

**Bestiaries** (split per published book):
- `pathfinder-bestiary`, `pathfinder-bestiary-2`, `pathfinder-bestiary-3`
- Adventure-path-specific: `age-of-ashes-bestiary`, `kingmaker-bestiary`, etc.

**Supplementary**:
- `macros`, `action-macros`
- `familiar-abilities`
- `boons-and-curses`
- `npc-gallery`
- `journals`
- `rollable-tables`
- `campaign-effects`

## Licensing Stack

| Layer | License |
|---|---|
| HTML/CSS/JavaScript/TypeScript code | **Apache 2.0** |
| Game mechanics data | **OGL v1.0a** (legacy) and **ORC** (post-Remaster). Per CONTRIBUTING.md: "New OGL and ORC content from Paizo can be incorporated upon street release." |
| Art assets | License info stored alongside JSON references in `packs/` |
| Foundry VTT platform | Foundry's "Limited License Agreement for module development 09/02/2020" |
| Paizo IP usage | Authorized via Paizo–Foundry partnership agreement; developers directed to Paizo Community Use Policy |

LICENSE file (root) is **Apache 2.0** (2019 copyright "Hooking"). The Apache license covers *the code*; the data/IP is governed by the layered agreement above.

## Contribution Conventions (from CONTRIBUTING.md)

- **Naming**: Entities named exactly as in source material; replace `[` `]` with parentheses or omit.
- **Cross-references**: `@Compendium[pf2e.pack-name.Entity Name]` — by name, not ID, for maintainability.
- **No copyrighted graphics** without explicit clearance.
- PR target: `master` branch.

## Implications for a PF2e Worldbuilding/LLM Tool

This repo is the de facto canonical structured PF2e dataset and the realistic ingestion source for any tool builder. It's actively maintained, broad in coverage (every published book), licensed Apache 2.0 on the code/schema (so the JSON shape can be used freely), and the *content* inherits from OGL/ORC + the Paizo–Foundry partnership. **A third-party tool that copies this JSON inherits the OGL/ORC obligations on the underlying mechanics, but cannot necessarily lean on the Foundry–Paizo partnership for its own product.** The tool would need to re-derive its license posture from ORC/OGL/Community Use directly. The schema, however, is reusable.
