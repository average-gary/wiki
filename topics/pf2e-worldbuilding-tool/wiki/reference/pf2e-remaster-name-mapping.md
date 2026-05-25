---
title: "PF2e Remaster name mapping (legacy ↔ Remaster)"
type: reference
created: 2026-05-24
updated: 2026-05-24
verified: 2026-05-24
volatility: medium
confidence: high
sources:
  - "[[2026-05-24-foundryvtt-pf2e-remaster-migration]]"
  - "[[2026-05-24-pf2e-remaster-renames-summary]]"
  - "[[2026-05-24-pf2e-srd-data-pf2e-remaster-overview]]"
tags: [pf2e, remaster, rename-mapping, reference, legacy-compat, ogl-to-orc, foundry]
---

# PF2e Remaster name mapping

Bidirectional alias index for legacy ↔ Remaster lookups. Used by the worldbuilding tool's lookup layer to (a) resolve user queries written in either edition, (b) auto-rewrite legacy notes on demand, (c) emit both legacy and Remaster names in tooltips/links.

## Purpose

Players and GMs accumulate notes across the OGL/Remaster cliff (2023–2024). A useful tool must:

- Accept "Magic Missile" as a query and return Force Barrage with a "renamed in Remaster" annotation.
- Detect legacy names in user-imported markdown and offer one-click upgrade.
- Emit both names in player-facing exports during the transition period.
- Track per-record license provenance ([[pf2e-licensing-posture]]) — pre-Remaster records stay OGL, post-Remaster records are ORC. **Names cannot be silently rewritten without flipping license provenance**.

## Source attribution

**Primary**: [`foundryvtt/pf2e`](https://github.com/foundryvtt/pf2e) `packs/pf2e/journals/remaster-changes.json` — pinned via raw URL (see [[2026-05-24-foundryvtt-pf2e-remaster-migration]]). Maintained by the Foundry pf2e team in lockstep with Paizo errata as Remaster volumes ship. ~330 rename pairs covering class features, feats, spells, equipment, creatures, ancestries, languages, domains, pantheons, materials.

**Validated against**: Paizo announcements summarized in [[2026-05-24-pf2e-srd-data-pf2e-remaster-overview]] (Wikipedia / Paizo blog references).

**Implementation note**: store as JSON in the tool's `data/` directory and serve as a runtime lookup layer. **Refresh quarterly** by re-pulling the Foundry source — Paizo continues to ship errata that Foundry mirrors. Pin to a commit when shipping a release; update the pin during dependency-bump cycles.

## Class features (selected — ~22 total)

| Legacy | Remaster | Notes |
|---|---|---|
| Alertness | Perception Expertise | Multiple classes |
| Attack of Opportunity | Reactive Strike | Action; multiple classes |
| Druidic Language | Wildsong | Druid |
| Wild Empathy | Voice of Nature | Druid |
| Wild Order | Untamed Order | Druid |
| Wild Stride | Unimpeded Journey | Ranger |
| Trackless Step | Trackless Journey | Ranger |
| Slippery Mind | Agile Mind | Rogue |
| Great Fortitude / Iron Will / Lightning Reflexes | Fortitude / Will / Reflex Expertise | Multi-class save renames |

## Feats (selected — ~110 total)

| Legacy | Remaster | Class |
|---|---|---|
| Power Attack | Vicious Swing | Fighter |
| Knockdown | Slam Down | Fighter |
| Spring Attack | Dashing Strike | Fighter |
| Combat Reflexes | Tactical Reflexes | Fighter |
| Wild Shape | Untamed Form | Druid |
| Woodland Stride | Forest Passage | Druid |
| Favored Enemy | Favored Prey | Ranger |
| Inspire Courage | Courageous Anthem | Bard composition |
| Inspire Defense | Rallying Anthem | Bard composition |
| Inspire Heroics | Fortissimo Composition | Bard composition |
| Turn Undead | Panic the Dead | Cleric |
| Channeled Succor | Restorative Channel | Cleric |
| Sense Evil / Sense Good | Sense Unholiness / Sense Holiness | Champion |
| Stunning Fist | Stunning Blows | Monk |
| Wholeness of Body | Harmonize Self | Monk |
| Deflect Arrow | Deflect Projectile | Monk |
| Ki Center / Align Ki / Disrupt Ki | Qi Center / Align Qi / Disrupt Qi | Monk (Ki→Qi) |
| Burrow Elocutionist | Animal Elocutionist | Gnome |
| Hatchling Flight | Winglet Flight | Kobold |
| Celestial Eyes / Lore / Resistance | Nephilim Eyes / Lore / Resistance | Aasimar→Nephilim |

## Spells (selected — ~125 total, full table in raw source)

| Legacy | Remaster |
|---|---|
| Magic Missile | Force Barrage |
| Flesh to Stone | Petrify |
| Mage Armor | Mystic Armor |
| Magic Weapon | Runic Weapon |
| Magic Fang | Runic Body |
| True Strike | Sure Strike |
| Burning Hands | Breathe Fire |
| Scorching Ray | Blazing Bolt |
| Searing Light | Holy Light |
| Stoneskin | Mountain Resilience |
| Barkskin | Oaken Resilience |
| Animate Dead | Summon Undead |
| Time Stop | Freeze Time |
| Dimension Door | Translocate |
| Plane Shift | Interplanar Teleport |
| Meteor Swarm | Falling Stars |
| Tongues | Truespeech |
| Trueseeing | Truesight |
| Comprehend Language | Translate |
| See Invisibility | See the Unseen |
| Calm Emotions | Calm |
| Zone of Truth | Ring of Truth |
| Continual Flame | Everlight |
| Floating Disk | Carryall |
| Resilient Sphere | Containment |
| Globe of Invulnerability | Dispelling Globe |
| Magnificent Mansion | Planar Palace |
| Feather Fall | Gentle Landing |
| Spider Climb | Gecko Grip |
| Pass Without Trace | Vanishing Tracks |
| Freedom of Movement | Unfettered Movement |
| Chill Touch | Void Warp |
| Vampiric Touch | Vampiric Feast |
| False Life | False Vitality |
| Cloudkill | Toxic Cloud |
| Horrid Wilting | Desiccate |
| Wail of the Banshee | Wails of the Damned |
| Mind Blank | Hidden Mind |
| Simulacrum | Shadow Double |
| Tree Stride | Nature's Pathway |
| Goodberry | Cornucopia |
| Heroes' Feast | Fortifying Brew |
| Modify Memory | Rewrite Memory |
| Glibness | Honeyed Words |
| Hideous Laughter | Laughing Fit |
| Touch of Idiocy | Stupefy |
| Feeblemind | Never Mind |
| Color Spray | Dizzying Colors |
| Hypnotic Pattern | Hypnotize |
| Bind Soul | Seize Soul |
| Finger of Death | Execute |
| Quivering Palm | Touch of Death |

### Merged spells (note for tool authors)

Several legacy spells collapsed into one Remaster name. The lookup must surface "merged" as a flag, not a 1:1 alias.

- `Remove Curse` + `Remove Disease` + `Neutralize Poison` → **Cleanse Affliction**
- `Faerie Fire` + `Glitterdust` → **Revealing Light**
- `Dancing Lights` → merged into **Light**
- `Magic Aura` + `Misdirection` → **Disguise Magic**

## Equipment / Magic Items (selected — ~70 total)

| Legacy | Remaster |
|---|---|
| Bag of Holding | Spacious Pouch (Type I–IV) |
| Portable Hole | Planar Tunnel |
| Bracers of Armor | Bands of Force |
| Boots of Speed | Propulsive Boots |
| Winged Boots | Winged Sandals |
| Holy Avenger | Chalice of Justice |
| Flame Tongue | Searing Blade |
| Demon Armor | Unholy Plate |
| Celestial Armor | Holy Chain |
| Sovereign Glue | Everlasting Adhesive |
| Universal Solvent | Absolute Solvent (Lesser) |
| Sunrod | Glow Rod |
| Tindertwig | Matchstick |
| Everburning Torch | Everlight Crystal |
| Mithral | Dawnsilver |
| Darkwood | Duskwood |

### Staves (entire category renamed)

| Legacy | Remaster |
|---|---|
| Staff of Abjuration | Staff of Protection |
| Staff of Conjuration | Staff of Summoning |
| Staff of Divination | Staff of the Unblinking Eye |
| Staff of Enchantment | Staff of Control |
| Staff of Evocation | Staff of Elemental Power |
| Staff of Illusion | Staff of Phantasms |
| Staff of Necromancy | Staff of the Dead |
| Staff of Transmutation | Fluid Form Staff |

## Bestiary / Creatures (selected — ~60 total)

| Legacy | Remaster | Group |
|---|---|---|
| Pit Fiend | Nessari | Devil |
| Lemure | Ort | Devil |
| Dretch | Pusk | Demon |
| Astral Deva | Tabellia | Angel |
| Lillend | Kanya | Azata |
| Djinni / Efreeti / Marid / Shaitan / Janni | Jaathoom / Ifrit (creature) / Faydhaan / Jabali / Jann | Genie |
| Air/Earth/Fire/Water Mephit | Air/Earth/Fire/Water Scamp | Mephit |
| Fire Yai / Ice Yai / Water Yai | Caldera Oni / Snow Oni / Island Oni | Yai → Oni |
| Frost Troll | Ice Troll | |
| Winter Wolf | Witchwarg | |
| Purple Worm / Crimson Worm / Azure Worm | Cave Worm / Magma Worm / Benthic Worm | Worms |
| Deep Gnome | Umbral Gnome | |
| Duergar | Hryngar | |
| Gnoll | Kholo | |
| Locathah | Athamaru | |
| Sea Devil | Sedacthy | |

## Ancestries / Heritages

| Legacy | Remaster | Notes |
|---|---|---|
| Aasimar | Nephilim | merged into Nephilim |
| Tiefling | Nephilim | merged |
| Aphorite | Nephilim | merged |
| Ganzi | Nephilim | merged |
| Ifrit (ancestry) | Naari | distinct from Ifrit (creature) |
| Half-Elf | Aiuvarin | heritage |
| Half-Orc | Dromaar | heritage |
| Gnoll | Kholo | ancestry |
| Grippli | Tripkee | ancestry |

## Languages (complete — 12 pairs)

| Legacy | Remaster |
|---|---|
| Abyssal | Chthonian |
| Aquan | Thalassic |
| Auran | Sussuran |
| Celestial | Empyrean |
| Druidic | Wildsong |
| Ignan | Pyric |
| Infernal | Diabolic |
| Sylvan | Fey |
| Terran | Petran |
| Undercommon | Sakvroth |
| Gnoll | Kholo |
| Grippli | Tripkee |

## Domains / Pantheons (complete — 7 pairs)

| Legacy | Remaster | Type |
|---|---|---|
| Delirium | Disorientation | domain |
| Void | Nothingness | domain |
| Wyrmkin | Dragon | domain |
| Dwarven Pantheon | Stone's Blood | pantheon |
| Elven Pantheon | Sovyrian Conclave | pantheon |
| Followers of Fate | Norns | pantheon |
| The Prismatic Ray | Radiant Prism | pantheon |

## Taxonomy shifts (NOT renames)

These are **structural changes**, not 1:1 renames. The lookup layer must handle them differently.

### Alignment damage → typed energy

Alignment was removed entirely. Damage types remap:

- **Good** → **holy**
- **Evil** → **unholy**
- **Lawful** → no direct successor (mostly removed)
- **Chaotic** → no direct successor
- **Positive (energy)** → **vitality**
- **Negative (energy)** → **void**
- **Neutral healing/harm** → spirit (case-by-case)

### Schools of magic — removed

The eight schools (Abjuration, Conjuration, Divination, Enchantment, Evocation, Illusion, Necromancy, Transmutation) were **removed entirely**. Spells now use traits instead. The lookup must NOT alias school names to anything; user queries that filter by school should return "deprecated; filter by trait instead" with a suggested trait list.

### Mechanical reworks — not renames

These keep their names but the rules behind them changed substantively. They need a separate "rules-rework" tracking table, not aliasing:

- **Barbarian Rage** — economy and damage scaling reworked
- **Witch Hexes** — restructured
- **Champion Cause** — replaced alignment-locked cause picks with sanctified vs anointed framework
- Multiple class features rebalanced without renaming

## Open gaps

1. **Post-2024 errata** beyond what's in the Foundry journal as of 2026-05-24 fetch — refresh quarterly.
2. **Per-deity sanctification table** — alignment removal forced per-deity changes; this article covers pantheon-level renames only.
3. **Lost Omens setting/place renames** during the Remaster era — out of scope of the Foundry journal; needs separate research.
4. **Schools-of-magic → traits mapping** — removal not aliased; needs a "trait recommendation given legacy school" sub-table.
5. **Mechanical-rework tracking** (Rage, Hexes, Causes) — separate table, not yet written.

## See also

- [[pf2e-licensing-posture]] — pre-Remaster (OGL) vs post-Remaster (ORC) provenance
- [[world-data-model-recommendation]] — license-provenance field on every record
- [[2026-05-24-foundryvtt-pf2e-remaster-migration]] — full ~330-pair raw extraction
- [[2026-05-24-pf2e-srd-data-pf2e-remaster-overview]] — Remaster timeline + scope
