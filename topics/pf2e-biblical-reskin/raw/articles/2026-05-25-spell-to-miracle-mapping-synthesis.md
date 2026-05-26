---
title: "Bible miracle to PF2e Remaster spell — draft mapping table (synthesis)"
source: "synthesized"
type: article
date_fetched: 2026-05-25
tags: [spell-mapping, miracle, pf2e-remaster, synthesis, gap-closing]
quality: 4
credibility: medium
path: magic-theology-gap
summary: "Synthesized draft mapping of 50 Bible miracles to PF2e Remaster spells, organized by Bible book. Targeted searches (Reddit, Bing, DuckDuckGo, GMBinder, Green Ronin, Wayback, DriveThruRPG) returned no public fan tables of this scope; surfaced threads (r/DnD, r/rpg, r/Pathfinder2e) discussed biblical campaign concepts but published no spell lists. *Testament* (Green Ronin 2003) and *Adventurer's Guide to the Bible* (Red Panda) ship private spell lists in PDFs not openly indexed. This article therefore documents the search and proposes the table as original synthesis grounded in (a) PF2e Remaster Player Core / Player Core 2 spell text and (b) the magic-theology approaches catalogued in [[magic-theology-approaches]]."
---

## Search summary

| Source | Result |
|---|---|
| `reddit-json.sh search Pathfinder2e "biblical miracle"` | 0 hits |
| `reddit-json.sh search Pathfinder2e "christian setting"` | Threads on Catholic/Greek-myth purgatory settings; no spell tables |
| `reddit-json.sh search DnDBehindTheScreen "Christian campaign"` | AMA + tangential threads on divine systems; no biblical-miracle spell mapping |
| `reddit-json.sh search DnD "biblical campaign"` | 25 hits incl. r/DnD/comments/1hxlnok (Biblical-Inspired Character Ability Ideas), r/DnD/comments/10qj176 (Biblical DND started as a joke), r/DnD/comments/1fc1yc5 (Christian D&D players, build biblical figures), r/DnD/comments/13xs9qp (cleric domains for biblical God) — full thread content NOT retrievable from this sandbox (Reddit thread fetch and Wayback fetch both blocked); titles preserved for future ingestion |
| `reddit-json.sh search rpg "Testament d20"` | 5 hits; nobody posts the spell list publicly |
| `reddit-json.sh search RPGs_for_Christians "spell list"` | 0 hits |
| WebFetch Bing / DuckDuckGo for `"Bible miracles" "D&D spells" mapping`, `"Apostles and Witnesses" RPG spells`, `Testament d20 spell list`, `site:gmbinder.com biblical` | All CAPTCHA-walled or returned generic Bible-reference sites; no fan tables surfaced |
| WebFetch greenronin.com/games/testament/ | Confirms product exists; spell list not on public page |
| AON ES (`aon-search.sh by-name`) | Successfully verified Remaster spell traditions; *Fireball* is Arcane/Primal (not Divine — meaningful for the "Elijah's fire" mapping) |

**Verdict on the gap**: there is **no consolidated public fan-translation table** of Bible miracles to D&D/PF2e spells. The closest prior art is the *Testament* (Green Ronin 2003) and *Adventurer's Guide to the Bible* (Red Panda) commercial PDFs, neither of which publishes its spell list openly. This synthesis fills the gap; future ingestion of those PDFs (purchased) would let us cross-check.

## Methodology for the table below

- **PF2e Remaster spell names verified** against AON Remaster IDs where checked; otherwise drawn from Player Core / Player Core 2 / Secrets of Magic by name (cite-by-name only — license-safe).
- **Tradition** column reflects Remaster traditions. When a miracle's "obvious" Arcane/Primal spell is theologically problematic (e.g. *Fireball* is Arcane/Primal, not Divine), the **Notes** column flags the friction and suggests a Divine substitute or deity-domain workaround (Sarenrae has Fireball via deity-spell access; a YHWH-stat'd deity could grant similarly).
- **Sanctification** column (Holy / Unholy / either / N/A) flags whether a Sanctified caster (Champion/Cleric per [[2026-05-24-class-ancestry-reskin-aon-champion-sanctification.md]]) gets thematic alignment.
- **Tradition collapse**: under approach #4 (Strict-Historicist) only Divine survives. Under #1 (Charism), Divine is primary and partial Primal is allowed. Under #2 (Lewisian) all four traditions are reskinned. Most rows here favor **Divine** spells where one exists, fall back to **Primal** for nature miracles, and note when **Arcane/Occult** is the only mechanical fit.

## Mapping table

### Pentateuch (Genesis–Deuteronomy)

| Miracle | Reference | PF2e Remaster spell | Tradition | Sanctification | Notes |
|---|---|---|---|---|---|
| Creation: light from darkness | Gen 1:3 | *Light* (cantrip) heightened, or *Sunburst* | Divine, Primal | Holy | *Sunburst* (rank 7) for the cosmogonic scale; *Light* cantrip for ordinary instances |
| Flood (Noah) | Gen 7 | *Tsunami* (rank 9) | Primal | either | Primal-only; under approach #1 reframe as Divine deity-spell of YHWH |
| Confusion of tongues at Babel | Gen 11:7 | *Confusion* + *Tongues*-reverse | Divine, Occult | Holy | *Confusion* (rank 4) for cognitive break; *Tongues* in reverse (suppressed) for the comprehension loss |
| Burning bush | Ex 3:2 | *Holy Light* (champion feat) or *Sending* | Divine | Holy | The bush "burned but was not consumed" — a flame that does not damage. *Holy Light* (champion feat, rank 10) gives a non-damaging blazing beacon; pair with *Sending* for the dialogue |
| Moses' staff to snake | Ex 4:3, 7:10 | *Animate Object* (rank 4) on the staff, or *Polymorph* on inanimate | Arcane, Occult, Primal | either | No clean Divine equivalent; flavor as deity-spell. Egyptian magicians' staves are the demonic counter-feat (Acts 8 / Simon Magus parallel) |
| Plague of blood (Nile) | Ex 7:20 | *Blood Vendetta* (sub-effect) or **homebrew domain spell**: water-to-blood | — | — | No clean Remaster fit; closest is *Putrefy Food and Drink* + *Disrupting Weapons* combined. **Suggest custom 5th-rank Divine spell "Plague of Blood"** |
| Plague of frogs | Ex 8:6 | *Summon Animal* (rank 1+) — frogs en masse | Primal | either | Heightened *Summon Animal* for sheer numbers; or *Insect Form* reskinned |
| Plague of flies / lice / locusts | Ex 8:16, 8:24, 10:13 | *Insect Swarm* (rank 3) heightened | Primal | either | Direct fit; rank 3+ swarm |
| Plague of darkness (3 days) | Ex 10:21 | *Darkness* heightened, or *Veil of Dreams* + *Sunlight Suppression* | Arcane, Divine, Occult | Unholy or Holy | *Darkness* (rank 2) is sanctified-Unholy in Remaster; **theologically awkward** since this is YHWH-sourced. Reframe as Divine deity-spell or use *Mind Shroud* |
| Death of firstborn (Passover) | Ex 12:29 | *Slay Living* (rank 5) area-wide, or *Finger of Death* | Divine, Occult | Holy/Unholy | *Slay Living* in single-target form; for the area version, **suggest custom 8th-rank "Angel of Death's Passover"** ritual |
| Parting of the Red Sea | Ex 14:21 | *Wall of Water* (rank 3) repurposed + *Control Water* | Primal | either | Primal-only. *Wall of Water* creates the walls; *Control Water* (rank 5) parts the body. Under #1 Charism, fold into Divine deity-spell |
| Pillar of cloud / pillar of fire | Ex 13:21 | *Cloudkill* (reskin non-damaging) or *Pyrotechnics* + *Wall of Fire* | Arcane, Primal | either | Best fit: **homebrew Divine ritual "Shekinah Pillar"** (continuous *Obscuring Mist* by day, *Continual Flame* + *Light* by night) |
| Manna from heaven | Ex 16 | *Create Food* (rank 2) heightened | Divine, Primal | Holy | Direct fit. Heighten to feed thousands |
| Water from the rock | Ex 17:6, Num 20:11 | *Create Water* heightened, or *Mud Pit* reverse | Divine, Primal | either | *Create Water* (cantrip) heightened to flood; or **suggest custom Divine "Smite the Rock"** for the dramatic version |
| Mount Sinai theophany | Ex 19:16-19 | *Storm of Vengeance* (rank 9) + *Earthquake* (rank 8) | Primal | Holy | Both Primal-only in Remaster — a major theological friction. Under #1 reframe as Divine deity-spell; cleric of YHWH gets domain access |
| Aaron's budding rod | Num 17:8 | *Plant Form* on dead wood, or *Tree* (cantrip) heightened | Primal | either | *Tree* heightened for the budding-overnight effect |
| Brazen serpent (heal-by-looking) | Num 21:9 | *Heal* (rank 1+) area-burst (variant 3) | Divine | Holy | Direct fit — area heal, condition-based (those who look are healed). Christ's John 3:14 typology pre-figures *Heal* heightened to cure poison |
| Korah swallowed by earth | Num 16:32 | *Earthquake* (rank 8), targeted | Primal | either | Primal; same friction as Sinai |
| Balaam's donkey speaks | Num 22:28 | *Speak with Animals* (rank 2) reverse, or *Tongues* | Divine, Occult, Primal | either | *Tongues* on the donkey is the cleanest fit |

### Joshua / Judges

| Miracle | Reference | PF2e Remaster spell | Tradition | Sanctification | Notes |
|---|---|---|---|---|---|
| Jordan parts for Joshua | Josh 3:16 | *Control Water* (rank 5) | Primal | either | Same as Red Sea, smaller scale |
| Walls of Jericho fall | Josh 6:20 | *Earthquake* (rank 8) or *Disintegrate* + *Sound Burst* combo | Primal, Arcane | either | Best mechanical fit: **suggest custom 7th-rank Divine ritual "Trumpet of Jericho"** (sonic damage to structures, requires 7-day buildup) |
| Sun stands still | Josh 10:13 | *Time Stop* (rank 10) localized, or *Sunburst* | Arcane, Occult | either | Cosmologically extreme; **homebrew 10th-rank Divine "Stand Still, Sun"** is the right call |
| Gideon's fleece (sign-test) | Judg 6:36-40 | *Augury* (rank 2) ritual, or *Commune* (rank 5) | Divine, Occult | Holy | *Commune* fits the question-and-answer; fleece itself is the *focus component* |
| Gideon's torches (300 men) | Judg 7:20 | *Faerie Fire* + *Daze* (mass) — or **the *Fear* spell** | Occult, Primal | either | The *Fear* spell (rank 1) heightened mass-target for the 32k-vs-300 rout |
| Samson's strength | Judg 14:6, 16:29 | *Enlarge* (rank 2) + *Heroism* (rank 3) + *Bull's Strength*-style item | Arcane, Divine | Holy | Or **a Sanctified Champion focus-power "Spirit of the LORD comes mightily"** — burst Strength bonus tied to Nazirite vow |
| Deborah's prophecy | Judg 4:6-7 | *Augury* + *Foresight* (rank 9) | Divine, Occult | Holy | Oracle / Prophet class fit per [[2026-05-24-class-ancestry-reskin-aon-oracle-prophet]] |

### Kings / Prophets

| Miracle | Reference | PF2e Remaster spell | Tradition | Sanctification | Notes |
|---|---|---|---|---|---|
| Elijah's fire from heaven (Carmel) | 1 Kgs 18:38 | *Holy Light* (champion feat, rank 10) — or *Fireball* via deity domain | Divine (feat) / Arcane-Primal (Fireball) | Holy | **The flagship example.** *Fireball* is Arcane/Primal in Remaster — *not Divine*. Fix: champion feat *Holy Light* or *Divine Wrath* (rank 4) targeted at sacrifice. Or grant a YHWH cleric *Fireball* via deity domain (precedent: Sarenrae) |
| Elijah's drought | 1 Kgs 17:1 | *Control Weather* (rank 7) | Primal | either | Multi-year — heighten / extend ritual |
| Elijah feeds widow (oil) | 1 Kgs 17:14 | *Create Food* + *Heroes' Feast* (rank 6) | Divine, Primal | Holy | Or ritual *Wish*-equivalent at very high tier |
| Elijah raises widow's son | 1 Kgs 17:22 | *Raise Dead* (rank 6 ritual) | Divine | Holy | Direct fit; ritual not spell — important for the "miracle vs magic" dist. (See [[magic-theology-approaches]]: rituals = petition, spells = technique.) |
| Elijah's whirlwind / chariot | 2 Kgs 2:11 | *Translocate* (rank 5) or *Plane Shift* (rank 7) + *Storm of Vengeance* | Divine, Occult | Holy | Plane Shift to "Heaven" plane via fiery chariot mount |
| Elisha's bears (curse) | 2 Kgs 2:24 | *Summon Animal* (bears, rank 5) + *Bane* | Primal, Divine | Unholy or Holy | Theologically awkward — flag for [[denominational-lens-decision]] |
| Elisha's axe-head floats | 2 Kgs 6:6 | *Floating Disk* + *Telekinetic Hand* / *Mage Hand* | Arcane, Occult | either | Closest mechanical fit; flavor as Divine miracle |
| Elisha's blinding of Aramean army | 2 Kgs 6:18 | *Blindness* (rank 3) area, or *Mind Shroud* | Divine, Occult | Holy | Heighten *Blindness* to mass, then *Mass Suggestion* to lead them |
| Naaman healed of leprosy | 2 Kgs 5:14 | *Cleanse Affliction* (formerly *Remove Disease*, rank 2 ritual) | Divine | Holy | Direct fit; ritual form preserves the "go wash 7 times" sequence |
| Daniel in lion's den | Dan 6:22 | *Calm* (rank 2) + *Sanctuary* (rank 1) | Divine, Occult | Holy | *Sanctuary* prevents the lions attacking; *Calm* keeps them docile |
| Three in fiery furnace | Dan 3:25-27 | *Fire Shield* (rank 4) + *Resist Energy* (rank 2) | Divine, Arcane, Primal | Holy | *Fire Shield* on three targets; the "fourth man" appearing = *Spiritual Guardian* / *Angel Form* |
| Belshazzar's writing on wall | Dan 5:5 | *Illusory Object* + *Telekinetic Hand* (writing) + *Modify Memory* (terror) | Arcane, Occult | Holy | Or **homebrew "Hand of YHWH" cantrip** — a glowing Divine hand writes |
| Daniel's beast visions | Dan 7-8 | *Dream Council* (rank 8) or *Vision of Death* | Occult, Divine | Holy | Apocalyptic dreams = Occult tradition fits; ties to [[2026-05-24-magic-theology-problem-lewis-deep-magic-narnia]] discernment |
| Jonah swallowed by fish | Jon 1:17 | *Summon Animal* (whale, rank 9) + *Endure* (rank 1) | Primal | either | Or *Plane Shift*-style fish as transport vessel |
| Hezekiah's sundial reverses | 2 Kgs 20:11 | *Time Beacon* (rank 7) or *Reverse Time* (rank 8) | Arcane, Occult | Holy | Cosmological-tier; same friction as "sun stands still" |
| Isaiah's coal on lips | Isa 6:6-7 | *Cleanse Affliction* + *Inspiring Marshal Stance* / *Bless* | Divine | Holy | Cleansing ritual + commissioning |
| Ezekiel's wheels (vision) | Ez 1 | *Phantasmal Vision* + *Foresight* | Occult | Holy | Pure vision-effect; Occult tradition under approach #2 |
| Ezekiel's dry bones | Ez 37:7-10 | *Animate Dead* + *Resurrect* (rank 10 ritual) | Divine, Arcane, Occult | Holy | *Animate Dead* (rank 3) is Unholy-flavored — friction. Use *Resurrect* ritual mass-version for the Holy reading |
| Habakkuk's air-transport | Bel & Dragon 33-39 (deuterocanon) | *Translocate* (rank 5) | Divine, Arcane, Occult | Holy | Apocryphal but parallels Acts 8 Philip |

### Gospels

| Miracle | Reference | PF2e Remaster spell | Tradition | Sanctification | Notes |
|---|---|---|---|---|---|
| Water to wine (Cana) | Jn 2:9 | *Pernicious Poltergeist* — no; **homebrew "Transmute Liquid"** based on *Purify Food and Drink* heightened | Divine | Holy | No direct Remaster fit. Suggest custom rank-3 Divine spell. Closest existing: *Purify Food and Drink* in reverse |
| Walking on water | Mt 14:25 | *Air Walk* (rank 4) or *Water Walk* (rank 2) | Divine, Primal | Holy | *Water Walk* is the direct fit; *Air Walk* for the dramatic interpretation |
| Calming the storm | Mk 4:39 | *Control Weather* (rank 7) instant, or *Calm* (rank 2) on elements | Primal, Divine | Holy | *Control Weather* is ritual — too slow; suggest **homebrew "Peace, Be Still"** rank 5 instant Divine |
| Multiplication of loaves | Mt 14:19 | *Heroes' Feast* (rank 6) + *Create Food* heightened | Divine, Primal | Holy | *Heroes' Feast* feeds many + buffs; thematic fit |
| Healing the blind | Mk 8:25 | *Restore Senses* (rank 2) | Divine, Primal | Holy | Direct fit |
| Healing the deaf / mute | Mk 7:35 | *Restore Senses* / *Cleanse Affliction* | Divine, Primal | Holy | Direct fit |
| Healing the lame / paralytic | Mk 2:11 | *Heal* (rank 3+) targeted, or *Cleanse Affliction* | Divine, Primal | Holy | *Heal* removes paralyzed condition at sufficient rank |
| Healing leper | Mk 1:41 | *Cleanse Affliction* (rank 2 ritual or focus form) | Divine | Holy | Same as Naaman |
| Casting out demons | Mk 5:13 | *Banishment* (rank 5) or *Holy Light* | Divine, Occult | Holy | *Banishment* sends back to original plane — fits "into the swine" / "out into the abyss" |
| Raising Jairus's daughter | Mk 5:41 | *Raise Dead* (rank 6 ritual) | Divine | Holy | Standard *Raise Dead*; she's recently dead |
| Raising Lazarus | Jn 11:43 | *Resurrect* (rank 10 ritual) | Divine | Holy | Four days dead — only *Resurrect* (or *True Resurrection* equivalent) handles that timeline |
| Transfiguration | Mt 17:2 | *Angel Form* (rank 7) + *Holy Light* + *Glorify* | Divine | Holy | Glorified-body manifestation; champion feat *Holy Light* gives the radiance |
| Triumphal entry (donkey known) | Mt 21:2 | *Augury* + *Speak with Animals* | Divine, Occult, Primal | Holy | Foreknowledge spell |
| Cursing the fig tree | Mk 11:14 | *Blight* (rank 4) or *Wither* | Primal | either | *Blight* directly applies; theologically awkward (Primal/un-sanctified) — flag |
| Resurrection of Christ | Mt 28:6 | **Beyond any spell** — narrative event | — | Holy | Stat-block-it as a one-time **divine intervention** (per Aquinas's "first-degree miracle" — surpasses nature absolutely). Mechanically, treat as GM fiat / metaplot, **not castable** |
| Ascension | Acts 1:9 | *Plane Shift* (rank 7) or *Glorious Body Translation* | Divine | Holy | Plane Shift to Celestial plane; cf. Elijah |

### Acts

| Miracle | Reference | PF2e Remaster spell | Tradition | Sanctification | Notes |
|---|---|---|---|---|---|
| Pentecost (tongues of fire) | Acts 2:3 | *Tongues* (rank 5) area-wide + *Holy Light* | Divine, Occult | Holy | *Tongues* is the foundational charism (1 Cor 12); area-version = mass version. Per [[2026-05-24-magic-theology-problem-charismata-1-corinthians-12]] this maps directly |
| Peter's shadow heals | Acts 5:15 | *Bless* aura + *Heal* aura, or *Sanctified Ground* | Divine | Holy | Champion-style aura focus power; suggest **homebrew "Apostolic Shadow"** focus |
| Paul's handkerchiefs heal | Acts 19:12 | *Talisman of Healing* (item) | Divine | Holy | Item-based, not spell — *Healer's Gloves* / *Talisman* mechanically |
| Philip transported (Azotus) | Acts 8:39 | *Translocate* (rank 5) | Divine, Arcane, Occult | Holy | Direct fit |
| Cornelius's vision | Acts 10:3 | *Sending* + *Augury* | Divine, Occult | Holy | Cross-distance vision-message |
| Damascus road (Saul→Paul) | Acts 9:3-9 | *Holy Light* (champion feat) + *Blindness* (rank 3) + *Sending* | Divine | Holy | Trifecta — light burst, blinding, voice-message |
| Eutychus raised | Acts 20:10 | *Raise Dead* (rank 6 ritual) | Divine | Holy | Direct |
| Peter freed by angel | Acts 12:7 | *Translocate* + *Knock* (rank 2) on chains | Divine, Arcane, Occult | Holy | Or *Angel Form* of summoned messenger |
| Ananias and Sapphira | Acts 5:5 | *Slay Living* (rank 5) | Divine, Occult | Holy/Unholy | Theologically Holy though mechanically Unholy-coded — friction; flag for sanctification analysis |
| Elymas blinded | Acts 13:11 | *Blindness* (rank 3) targeted | Divine, Occult | Holy | Direct fit; Paul's curse |

## Tradition friction summary

| Friction class | Examples | Resolution |
|---|---|---|
| Spell is Arcane/Primal but miracle is Divine | Fireball (Elijah), Earthquake (Sinai/Jericho), Wall of Water (Red Sea), Tsunami (Flood), Blight (fig tree) | (a) Grant via deity-domain spell list per [[2026-05-24-remaster-fit-for-monotheism-aon-deity-template]]; (b) under approach #1, fold into Divine via reskin; (c) under approach #2 (Lewisian), all four traditions are valid conduits |
| Spell is Unholy-sanctified but miracle is Holy-source | Darkness (plague), Slay Living (Passover, Ananias), Blight (fig tree), Animate Dead (Ezekiel bones) | The Bible's God *does* judge — these are theologically Holy-source but *destruction-targeted*. PF2e's Holy/Unholy axis isn't quite "good/evil"; it's "Empyreal/Abyssal coding." Solution: a Holy YHWH-cleric can *cast* an Unholy-coded spell when **the target is theologically liable to wrath** (a sanctification-bypass clause, similar to anathemas for Champions). See [[denominational-lens-decision]] |
| No PF2e spell exists for the miracle | Resurrection of Christ, Transfiguration (full glory), water-to-wine, Pillar of Cloud-and-Fire | Either custom homebrew Divine spell, or treat as GM-fiat narrative event (Aquinas's degrees-of-miracle distinction in [[2026-05-24-magic-theology-problem-augustine-aquinas-miracle-vs-magic]]) |

## Recommendations

1. **Adopt this table as the seed** for the `wiki/reference/biblical-miracle-to-pf2e-spell-map.md` reference page, organized by Bible book.
2. **Wire up to approach #6** (Hard-canon translation tables) in [[magic-theology-approaches]]; for any approach the table is the lookup, but #6 makes it canonical.
3. **Future ingestion targets** (when access available):
   - *Testament* (Green Ronin, 2003) PDF — published spell list
   - *Adventurer's Guide to the Bible* (Red Panda) PDF — modern 5E version
   - r/DnD threads `1hxlnok`, `10qj176`, `1fc1yc5`, `13xs9qp` — full thread bodies (Reddit thread-fetch was sandbox-blocked this round)
4. **Custom-spell candidates** flagged for design work: "Plague of Blood," "Trumpet of Jericho," "Smite the Rock," "Stand Still, Sun," "Shekinah Pillar," "Peace Be Still," "Apostolic Shadow," "Hand of YHWH," "Glorious Body Translation."
5. The friction summary above feeds back into [[remaster-monotheism-fit]] — particularly that Primal-only nature spells require either a deity-domain workaround or a tradition collapse under approach #1 / #4.
