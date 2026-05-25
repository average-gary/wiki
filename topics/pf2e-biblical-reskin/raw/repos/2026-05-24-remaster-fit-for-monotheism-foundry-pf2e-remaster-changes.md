---
title: "Foundry pf2e remaster-changes journal"
source: "https://github.com/foundryvtt/pf2e/blob/master/packs/journals/remaster-changes.json"
type: repo
date_fetched: 2026-05-24
date_published: "2024-09-01"
tags: [pf2e, remaster, foundry, alignment, schools, sanctification, primary-source]
quality: 5
credibility: high
path: remaster-fit-for-monotheism
summary: "Foundry-VTT's official Remaster migration journal — the most accurate community-maintained mirror of Paizo's structural changes. Confirms alignment fully removed (legacy alignments stay as inert traits), seven of eight schools removed (Illusion retained), holy/unholy traits replace alignment damage, evil/good damage on NPCs becomes spirit damage with traits."
---

# Foundry pf2e Remaster journal — key extracts

## Alignment

- "Alignment has been removed from the system. Alignment that had been set before on actors is still in actor data in the form of inert traits."
- Pre-Remaster NPC strikes that dealt evil/good damage now deal **spirit** damage, with the holy or unholy trait attached.
- Evil fiends auto-gain unholy trait; good celestials auto-gain holy trait.

## Schools of magic

- "Seven of the eight spell schools have been removed: Abjuration, conjuration, divination, enchantment, evocation, necromancy, and transmutation."
- **Illusion** is retained as the lone surviving trait. (Significant for monotheism: necromancy-as-school is gone, so "necromancy is anathema" no longer has a rules hook — must be reframed via void traits or specific spell lists.)

## Pantheon renames

- Dwarven Pantheon → Stone's Blood
- Elven Pantheon → Sovyrian Conclave
- Followers of Fate → Norns
- The Prismatic Ray → Radiant Prism
- Note: full per-deity remaster awaits *Lost Omens: Divine Mysteries* (released 2024).

## Champion / cleric changes

- Multiple champion feats removed: Litany spells (most), Celestial Mount, Blade of Justice.
- "Sense Evil" → "Sense Unholiness"; "Sense Good" → "Sense Holiness." (Important: these still work in monotheism with one renaming pass — sensing demonic taint = unholy, sensing divine grace = holy.)

## Damage type table (synthesized from journal + Player Core)

- **holy** — energy type, double damage to creatures with unholy trait
- **unholy** — energy type, double damage to creatures with holy trait
- **spirit** — affects souls/incorporeal/spiritual entities; not physical
- **vitality** — formerly positive energy; heals living, harms undead
- **void** — formerly negative energy; harms living, heals undead

## Monotheism implications

- The energy-type system is theologically cleaner than the four-axis alignment grid: holy/unholy is binary (God vs. anti-God), spirit damage handles soul-affecting attacks, vitality/void handle the life/anti-life axis. Maps closely onto Christian metaphysics (life vs. death, God vs. demons) without the L/C axis baggage.
- Removal of the Necromancy school is a mixed bag: it removes a polytheistic "necromancy is just another tool" framing, but you also lose the easy "necromancy = anathema" rules hook. Replace with: spells with the **void** trait are anathema for canonical clergy.
