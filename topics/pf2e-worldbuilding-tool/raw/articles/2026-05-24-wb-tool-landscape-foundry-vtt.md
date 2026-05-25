---
title: "Foundry Virtual Tabletop — Overview"
source: "https://foundryvtt.com/"
type: article
date_fetched: 2026-05-24
date_published: "unknown"
tags: [worldbuilding, tool-comparison, foundry-vtt, pf2e]
quality: 5
credibility: high
path: wb-tool-landscape
summary: "Foundry VTT is a one-time-purchase ($50, 20% off in May 2026 anniversary), self-hosted VTT supporting 200+ systems including a beloved community-built pf2e system. JournalEntries + Compendium + scenes give it surprisingly strong worldbuilding capability, but the UX is combat-first."
---

# Foundry VTT

## Pricing
**One-time purchase, no subscription** — typically $50, currently 20% off through May 31, 2026 (anniversary celebration). Players join free in-browser.

## Architecture
- Self-hosted (Windows/Mac/Linux) or paid third-party hosts (The Forge, Molten Hosting).
- Modern web stack — JS/HTML/CSS modules, robust API.
- "Thousands" of community modules.
- Free starter content packs (battlemaps, tokens, audio, adventures).

## V14 (current)
- Scene Levels (multi-floor scenes).
- Continued investment in the core engine.

## Worldbuilding angle
- **JournalEntries** — multi-page rich-text articles, with cross-links and embedded actors/items.
- **Compendia** — reusable libraries of NPCs, locations, lore.
- **pf2e system module** (community-maintained) is the *gold standard* of TTRPG VTT system support: full Archives of Nethys integration, automated condition handling, action economy, encounter budget calculator.

## Honest critique
- Worldbuilding via Journal Entries is functional but cramped — narrow column, modal-heavy UI; not a proper wiki.
- Search is OK but cross-world linking is limited (you can't easily share a single setting wiki across multiple campaigns/worlds without duplication).
- Self-hosting is non-trivial for casual GMs (port forwarding, Docker, etc.); paid hosts add ~$5/mo and recreate a SaaS dependency.
- No AI/LLM features in core — module ecosystem has experiments but nothing standardized.

## Relevance
Foundry's pf2e system is the quality bar for "how PF2e mechanics should be modeled in software." A worldbuilding tool that can *export to* or *interoperate with* a Foundry pf2e world (e.g. produce JournalEntry packs + Actor JSON) would slot directly into existing GM workflows instead of competing with them.
