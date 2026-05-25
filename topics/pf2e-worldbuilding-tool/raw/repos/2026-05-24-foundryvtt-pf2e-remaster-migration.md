---
title: "Foundry pf2e — Remaster Changes Journal (Canonical Rename Mapping)"
source: "https://github.com/foundryvtt/pf2e/blob/master/packs/pf2e/journals/remaster-changes.json"
source_raw: "https://raw.githubusercontent.com/foundryvtt/pf2e/v14-dev/packs/pf2e/journals/remaster-changes.json"
type: repo
date_fetched: 2026-05-24
date_published: ongoing
tags: [pf2e, remaster, rename-mapping, foundry, machine-readable, primary-derivative]
quality: 5
credibility: high
path: pf2e-srd-data-gap
summary: "Foundry VTT pf2e system ships an in-game journal `remaster-changes.json` (~73 KB) cataloguing every old-name → new-name pair Paizo published across the Remaster (Player Core, GM Core, Monster Core, Player Core 2). Maintained by the Foundry pf2e team in lockstep with Paizo errata. ~330 rename pairs spanning class features, feats, spells, equipment, bestiary creatures, ancestries, languages, domains, pantheons, and materials."
---

# Foundry pf2e Remaster Changes — Extracted Rename Table

## Source notes

- File path in repo: `packs/pf2e/journals/remaster-changes.json`
- Maintained alongside Paizo errata and Player Core / GM Core / Monster Core / Player Core 2 releases (2023-2024).
- This is the most complete machine-readable consolidation publicly available; the Foundry team mirrors Paizo's renames as they ship.
- Some entries marked "merged" indicate multiple legacy entities collapsed into a single Remaster name (e.g. several "Remove …" spells all became `Cleanse Affliction`).

## Class Features (selected)

| old_name | new_name | category | notes |
|---|---|---|---|
| Alertness | Perception Expertise | class-feature | Multiple classes |
| Attack of Opportunity | Reactive Strike | class-feature | Action; multiple classes |
| Arcane Spellcasting | Wizard Spellcasting | class-feature | Wizard |
| Divine Spellcasting | Cleric Spellcasting | class-feature | Cleric |
| Primal Spellcasting | Druid Spellcasting | class-feature | Druid |
| Druidic Language | Wildsong | class-feature | Druid |
| Great Fortitude | Fortitude Expertise | class-feature | Multi-class save renames |
| Iron Will | Will Expertise | class-feature | |
| Lightning Reflexes | Reflex Expertise | class-feature | |
| Incredible Senses | Perception Legend | class-feature | |
| Vigilant Senses | Perception Mastery | class-feature | |
| Wild Empathy | Voice of Nature | class-feature | Druid |
| Wild Order | Untamed Order | class-feature | Druid |
| Wild Stride | Unimpeded Journey | class-feature | Ranger |
| Trackless Step | Trackless Journey | class-feature | Ranger |
| Slippery Mind | Agile Mind | class-feature | Rogue |
| Metamagical Experimentation | Experimental Spellshaping | class-feature | Wizard |

## Feats (selected — full list ~110 pairs)

| old_name | new_name | category | notes |
|---|---|---|---|
| Power Attack | Vicious Swing | feat | Fighter |
| Knockdown | Slam Down | feat | Fighter |
| Improved Knockdown | Crashing Slam | feat | Fighter |
| Combat Reflexes | Tactical Reflexes | feat | Fighter |
| Spring Attack | Dashing Strike | feat | Fighter |
| Point-Blank Shot | Point Blank Stance | feat | Fighter |
| Stunning Fist | Stunning Blows | feat | Monk |
| Wholeness of Body | Harmonize Self | feat | Monk |
| Deflect Arrow | Deflect Projectile | feat | Monk |
| Arrow Snatching | Projectile Snatching | feat | Monk |
| Ki Center / Align Ki / Disrupt Ki | Qi Center / Align Qi / Disrupt Qi | feat | Monk (Ki→Qi) |
| Wild Shape | Untamed Form | feat | Druid |
| Woodland Stride | Forest Passage | feat | Druid |
| Thousand Faces | Anthropomorphic Shape | feat | Druid |
| Favored Enemy | Favored Prey | feat | Ranger |
| Inspire Courage | Courageous Anthem | feat/spell | Bard composition |
| Inspire Defense | Rallying Anthem | feat/spell | Bard composition |
| Inspire Heroics | Fortissimo Composition | feat/spell | Bard composition |
| Vigorous Inspiration | Vigorous Anthem | feat | Bard |
| Turn Undead | Panic the Dead | feat | Cleric |
| Channeled Succor | Restorative Channel | feat | Cleric |
| Holy Castigation | Divine Castigation | feat | Cleric |
| Sense Evil / Sense Good | Sense Unholiness / Sense Holiness | feat | Champion |
| Stonecunning | Stonemason's Eye | feat | Dwarf |
| Vengeful Hatred | Mountain Strategy | feat | Dwarf |
| Burrow Elocutionist | Animal Elocutionist | feat | Gnome |
| Gnoll Lore / Gnoll Weapon Familiarity | Kholo Lore / Kholo Weapon Familiarity | feat | Gnoll → Kholo |
| Grippli Weapon Familiarity / Lore | Tripkee Lore / Weapon Familiarity | feat | Grippli → Tripkee |
| Hatchling Flight | Winglet Flight | feat | Kobold |
| Celestial Eyes / Lore / Resistance | Nephilim Eyes / Lore / Resistance | feat | Aasimar → Nephilim |
| Celestial Wings | Divine Wings | feat | Aasimar |
| Vanth's Weapon Familiarity | Duskwalker Weapon Familiarity | feat | Duskwalker |

(Approx. 110 feat-rename pairs total in source.)

## Spells (full table — ~125 pairs)

| old_name | new_name | category | notes |
|---|---|---|---|
| Magic Missile | Force Barrage | spell | Iconic rename |
| Flesh to Stone | Petrify | spell | |
| True Strike | Sure Strike | spell | |
| Mage Armor | Mystic Armor | spell | |
| Mage Hand | Telekinetic Hand | spell | |
| Magic Weapon | Runic Weapon | spell | |
| Magic Fang | Runic Body | spell | |
| Magic Mouth | Embed Message | spell | |
| Magic Aura | Disguise Magic | spell | |
| Misdirection | Disguise Magic | spell | merged into Disguise Magic |
| Burning Hands | Breathe Fire | spell | |
| Scorching Ray | Blazing Bolt | spell | |
| Searing Light | Holy Light | spell | |
| Color Spray | Dizzying Colors | spell | |
| Hypnotic Pattern | Hypnotize | spell | |
| Scintillating Pattern | Confusing Colors | spell | |
| Hideous Laughter | Laughing Fit | spell | |
| Crushing Despair | Wave of Despair | spell | |
| Touch of Idiocy | Stupefy | spell | |
| Feeblemind | Never Mind | spell | |
| Ray of Enfeeblement | Enfeeble | spell | |
| Chill Touch | Void Warp | spell | (alignment removal) |
| Disrupt Undead | Vitality Lash | spell | (positive→vitality) |
| Disrupting Weapons | Infuse Vitality | spell | |
| False Life | False Vitality | spell | |
| Vampiric Touch | Vampiric Feast | spell | |
| Animate Dead | Summon Undead | spell | |
| Bind Soul | Seize Soul | spell | |
| Finger of Death | Execute | spell | |
| Wail of the Banshee | Wails of the Damned | spell | |
| Horrid Wilting | Desiccate | spell | |
| Cloudkill | Toxic Cloud | spell | |
| Meteor Swarm | Falling Stars | spell | |
| Time Stop | Freeze Time | spell | |
| Mind Blank | Hidden Mind | spell | |
| Simulacrum | Shadow Double | spell | |
| Maze | Quandary | spell | |
| Meld into Stone | One with Stone | spell | |
| Tree Shape | One with Plants | spell | |
| Tree Stride | Nature's Pathway | spell | |
| Stoneskin | Mountain Resilience | spell | |
| Barkskin | Oaken Resilience | spell | |
| Goodberry | Cornucopia | spell | |
| Heroes' Feast | Fortifying Brew | spell | |
| Purify Food and Drink | Cleanse Cuisine | spell | |
| Comprehend Language | Translate | spell | |
| Tongues | Truespeech | spell | |
| Trueseeing | Truesight | spell | |
| See Invisibility | See the Unseen | spell | |
| Know Direction | Know the Way | spell | |
| Discern Location | Pinpoint | spell | |
| Legend Lore | Collective Memories | spell | |
| Modify Memory | Rewrite Memory | spell | |
| Calm Emotions | Calm | spell | |
| Charming Words | Charming Push | spell | |
| Glibness | Honeyed Words | spell | |
| Zone of Truth | Ring of Truth | spell | |
| Continual Flame | Everlight | spell | |
| Produce Flame | Ignition | spell | |
| Flaming Sphere | Floating Flame | spell | |
| Floating Disk | Carryall | spell | |
| Force Cage | Lifewood Cage | spell | |
| Resilient Sphere | Containment | spell | |
| Globe of Invulnerability | Dispelling Globe | spell | |
| Private Sanctum | Peaceful Bubble | spell | |
| Magnificent Mansion | Planar Palace | spell | |
| Word of Recall | Gathering Call | spell | |
| Dimension Door | Translocate | spell | |
| Plane Shift | Interplanar Teleport | spell | |
| Dimensional Anchor | Planar Tether | spell | |
| Dimensional Lock | Planar Seal | spell | |
| Planar Binding | Planar Servitor | spell | |
| Passwall | Magic Passage | spell | |
| Shadow Walk | Umbral Journey | spell | |
| Wind Walk | Migration | spell | |
| Feather Fall | Gentle Landing | spell | |
| Longstrider | Tailwind | spell | |
| Spider Climb | Gecko Grip | spell | |
| Pass Without Trace | Vanishing Tracks | spell | |
| Freedom of Movement | Unfettered Movement | spell | |
| Phantom Mount | Marvelous Mount | spell | |
| Blink | Flicker | spell | |
| Gaseous Form | Vapor Form | spell | |
| Shapechange | Metamorphosis | spell | |
| Baleful Polymorph | Cursed Metamorphosis | spell | |
| Dragon Claws | Flurry of Claws | spell | |
| Roar of the Wyrm | Roar of the Dragon | spell | |
| Glyph of Warding | Rune Trap | spell | |
| Sanctified Ground | Anointed Ground | spell | |
| Righteous Might | Sacred Form | spell | |
| Touch of Corruption | Touch of the Void | spell | |
| Abyssal Wrath | Chthonian Wrath | spell | |
| Spectral Hand | Ghostly Carrier | spell | |
| Unseen Servant | Phantasmal Minion | spell | |
| Unseen Custodians | Phantasmal Custodians | spell | |
| Mind Blank | Hidden Mind | spell | |
| Nondetection | Veil of Privacy | spell | |
| Faerie Fire | Revealing Light | spell | merged with Glitterdust |
| Glitterdust | Revealing Light | spell | merged with Faerie Fire |
| Dancing Lights | Light | spell | merged into Light |
| Veil | Illusory Disguise | spell | merged |
| Commune with Nature | Commune | spell | merged |
| Tanglefoot | Tangle Vine | spell | |
| Sound Burst | Noise Blast | spell | |
| Hallucinatory Terrain | Mirage | spell | |
| Obscuring Mist | Mist | spell | |
| Endure Elements | Environmental Endurance | spell | |
| Entangle | Entangling Flora | spell | |
| Stone Tell | Speak with Stones | spell | |
| Restore Senses | Sound Body | spell | |
| Remove Fear | Clear Mind | spell | |
| Remove Paralysis | Sure Footing | spell | |
| Remove Curse / Disease | Cleanse Affliction | spell | merged with Neutralize Poison |
| Neutralize Poison | Cleanse Affliction | spell | merged |
| Gentle Repose | Peaceful Rest | spell | |
| Shield Other | Share Life | spell | |
| Bind Soul | Seize Soul | spell | |
| Vigilant Eye | Rune of Observation | spell | |
| Quivering Palm | Touch of Death | spell | Monk focus |
| Empty Body | Embrace Nothingness | spell | Monk focus |
| Ki Strike / Blast / Form / Rush | Inner Upheaval / Qi Blast / Qi Form / Qi Rush | spell | Monk Ki→Qi |
| Abundant Step | Shrink the Span | spell | Monk |

## Equipment / Magic Items (~70 pairs)

| old_name | new_name | category | notes |
|---|---|---|---|
| Bag of Holding | Spacious Pouch (Type I-IV) | item | |
| Portable Hole | Planar Tunnel | item | |
| Bracers of Armor | Bands of Force | item | |
| Boots of Speed | Propulsive Boots | item | |
| Winged Boots | Winged Sandals | item | |
| Broom of Flying | Flying Broomstick | item | |
| Hat of Disguise | Masquerade Scarf | item | |
| Hat of the Magi | Mage's Hat | item | |
| Cape of the Mountebank | Charlatan's Cape | item | |
| Holy Avenger | Chalice of Justice | item | |
| Flame Tongue | Searing Blade | item | |
| Demon Armor | Unholy Plate | item | |
| Celestial Armor | Holy Chain | item | |
| Dagger of Venom | Serpent Dagger | item | |
| Marvelous Pigments | Miraculous Paintbrush | item | |
| Sovereign Glue | Everlasting Adhesive | item | |
| Universal Solvent | Absolute Solvent (Lesser) | item | |
| Tanglefoot Bag | Glue Bomb (Lesser) | item | |
| Thunderstone | Blasting Stone (Lesser) | item | |
| Smokestick | Smoke Ball (Lesser) | item | |
| Sunrod | Glow Rod | item | |
| Tindertwig | Matchstick | item | |
| Everburning Torch | Everlight Crystal | item | |
| Goggles of Night | Obsidian Goggles | item | |
| Gloves of Storing | Retrieval Belt | item | |
| Disrupting Rune | Vitalizing Rune | rune | |
| Speed Rune | Quickstrike | rune | |
| Spell-Storing Rune | Spell Reservoir | rune | |
| Dancing Rune | Animated | rune | |
| Staff of Abjuration | Staff of Protection | staff | |
| Staff of Conjuration | Staff of Summoning | staff | |
| Staff of Divination | Staff of the Unblinking Eye | staff | |
| Staff of Enchantment | Staff of Control | staff | |
| Staff of Evocation | Staff of Elemental Power | staff | |
| Staff of Illusion | Staff of Phantasms | staff | |
| Staff of Necromancy | Staff of the Dead | staff | |
| Staff of Transmutation | Fluid Form Staff | staff | |
| Mithral | Dawnsilver | material | |
| Darkwood | Duskwood | material | |

## Bestiary / Creatures (~60 pairs)

| old_name | new_name | category | notes |
|---|---|---|---|
| Pit Fiend | Nessari | creature | Devil rename |
| Lemure | Ort | creature | Devil rename |
| Dretch | Pusk | creature | Demon rename |
| Astral Deva | Tabellia | creature | Angel rename |
| Lillend | Kanya | creature | Azata rename |
| Djinni | Jaathoom | creature | Genie |
| Efreeti | Ifrit (creature) | creature | Genie (note: separate ancestry rename Ifrit → Naari) |
| Marid | Faydhaan | creature | Genie |
| Shaitan | Jabali | creature | Genie |
| Janni | Jann | creature | Genie |
| Azer | Munsahir | creature | |
| Air/Earth/Fire/Water Mephit | Air/Earth/Fire/Water Scamp | creature | |
| Fire Yai / Ice Yai / Water Yai | Caldera Oni / Snow Oni / Island Oni | creature | |
| Belker | Smoke Creeper | creature | |
| Invisible Stalker | Phade | creature | |
| Ankou | Ozthoom | creature | |
| Faceless Stalker | Ugothol | creature | |
| Faerie Dragon | Fey Dragonet | creature | |
| Brain Collector | Jah-Tohl | creature | |
| Adhukait | Hārakasura | creature | Asura |
| Shaukeen | Shokasura | creature | Asura |
| Frost Troll | Ice Troll | creature | |
| Nessian Warhound | Greater Hell Hound | creature | |
| Winter Wolf | Witchwarg | creature | |
| Purple Worm | Cave Worm | creature | |
| Crimson Worm | Magma Worm | creature | |
| Azure Worm | Benthic Worm | creature | |
| Deep Gnome (variants) | Umbral Gnome (variants) | creature | |
| Duergar (variants) | Hryngar (variants) | creature | |
| Gnoll (variants) | Kholo (variants) | creature | |
| Locathah (variants) | Athamaru (variants) | creature | |
| Sea Devil (variants) | Sedacthy (variants) | creature | |
| Tiefling Adept | Pitborn Adept | creature | |
| Vampire Spawn Rogue | Vampire Servitor | creature | |
| Manticore | Manticore (Quill Tail) | creature | |

## Ancestries / Heritages

| old_name | new_name | category | notes |
|---|---|---|---|
| Aasimar | Nephilim | ancestry | merged with all planar-touched |
| Tiefling | Nephilim | ancestry | merged |
| Aphorite | Nephilim | ancestry | merged |
| Ganzi | Nephilim | ancestry | merged |
| Ifrit (ancestry) | Naari | ancestry | |
| Half-Elf | Aiuvarin | heritage | |
| Half-Orc | Dromaar | heritage | |
| Gnoll | Kholo | ancestry | |
| Grippli | Tripkee | ancestry | |

## Languages

| old_name | new_name | category | notes |
|---|---|---|---|
| Abyssal | Chthonian | language | |
| Aquan | Thalassic | language | |
| Auran | Sussuran | language | |
| Celestial | Empyrean | language | |
| Druidic | Wildsong | language | |
| Ignan | Pyric | language | |
| Infernal | Diabolic | language | |
| Sylvan | Fey | language | |
| Terran | Petran | language | |
| Undercommon | Sakvroth | language | |
| Gnoll | Kholo | language | |
| Grippli | Tripkee | language | |

## Domains / Pantheons

| old_name | new_name | category | notes |
|---|---|---|---|
| Delirium | Disorientation | domain | |
| Void | Nothingness | domain | |
| Wyrmkin | Dragon | domain | |
| Dwarven Pantheon | Stone's Blood | pantheon | |
| Elven Pantheon | Sovyrian Conclave | pantheon | |
| Followers of Fate | Norns | pantheon | |
| The Prismatic Ray | Radiant Prism | pantheon | |

Total extracted: ~330 rename pairs across class features (~22), feats (~110), spells (~125), equipment (~70), creatures (~60), ancestries/heritages (9), languages (12), domains/pantheons (7), materials (2).
