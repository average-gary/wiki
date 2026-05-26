---
title: "YHWH deity stat block — template & per-lens fills"
type: reference
created: 2026-05-25
updated: 2026-05-25
verified: 2026-05-25
volatility: medium
confidence: high
sources:
  - "[[2026-05-25-lost-omens-divine-mysteries-iomedae-sarenrae]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-pharasma-erastil]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-abadar-torag-asmodeus]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-yhwh-template-synthesis]]"
tags: [pf2e, remaster, deity-template, yhwh, reference, stat-block]
license_note: "Template uses Paizo terminology under fair-use commentary. A published reskin should paraphrase or use SRD/ORC-derived language only — see [[pf2e-licensing-posture]] in sister topic."
---

# YHWH deity stat block — template & per-lens fills

A drop-in stat block for the God of Christian Scripture, derived from Remaster *Lost Omens: Divine Mysteries* (Aug 2024) deity-entry patterns. The skeleton is constraint-aware (matches Paizo's actual field shapes); the per-lens fills (Catholic / Reformed / Pentecostal / Orthodox) make it usable across [[denominational-lens-decision]].

## Hard structural constraints (from Remaster precedent)

| Field | Length / shape | Source pattern |
|-------|----------------|----------------|
| Name + epithet | "YHWH (Lord of Hosts)" | Mandatory in Remaster style |
| Narrative blurb | 140–200 words | Pharasma ~190; Erastil ~140 |
| **Edicts** | **3–4 short imperative phrases**, comma-joined | Universal |
| **Anathema** | **3–4 short prohibitions**, comma-joined | Universal |
| Areas of Concern | 3–5 short nouns; "and" before final | "X, Y, Z, and W" |
| Divine Attribute | 1–2 attributes (Wis / Cha typical) | Used by Raised by Belief |
| Divine Font | Heal / Harm / Heal-or-Harm | Tracks sanctification |
| **Sanctification** | holy / unholy / both / **none** / can-choose-X | **Pharasma precedent: "none" is valid** |
| Divine Skill | exactly 1 | |
| Favored Weapon | exactly 1 | |
| Domains | **4 primary + 1–3 alternate** | From canonical PF2 list |
| Cleric Spells | **exactly 3, level-tagged** | Typical: 1st, 3rd, 5th |
| Religious symbol | 1 short phrase | Remaster-only field |
| Sacred animal | 1 noun | Remaster-only field |
| Sacred colors | 1–2 colors | Remaster-only field |

### The sanctification spectrum (5 values)

| Value | Example deity | When to use for YHWH |
|-------|---------------|----------------------|
| `must choose unholy` | Asmodeus | (Never for YHWH; reserved for fallen counter-deities) |
| `can choose unholy` | (mixed deities) | (Never) |
| `can choose holy or unholy` | Mixed-portfolio deities | (Never) |
| `can choose holy` | Iomedae, Sarenrae | **Default for YHWH in most lenses** |
| `none` | **Pharasma** | **Strict-monotheism escape hatch** — see below |

## Skeleton template

```
YHWH (Lord of Hosts)
[140–200 word narrative blurb: covenant with creation; covenantal pattern
across Hebrew Bible + NT; the Word made flesh; the Spirit poured out.]

Edicts: <3-4 imperatives>
Anathema: <3-4 prohibitions>
Areas of Concern: <3-5 short nouns>

Divine Attribute  Wisdom or Charisma
Divine Font       heal
Divine Sanctification  can choose holy   [or "none"; see below]
Divine Skill      Religion
Favored Weapon    longsword [see "open question" below]
Domains           Creation, Truth, Healing, Zeal
Alternate Domains Family, Knowledge, Soul, Vigil
Cleric Spells     1st: heal; 3rd: holy light; 5th: angelic messenger
Religious Symbol  cross / burning bush / shofar [lens-dependent]
Sacred Animal     lamb / dove / eagle [lens-dependent]
Sacred Colors     gold and white [+ red optional]
```

## Per-lens filled stat blocks

### Catholic fill

```
YHWH (The Holy Trinity, Lord of Hosts)

Edicts: love God with all your heart, love your neighbor as yourself,
        honor the sacraments, defend the Church and the poor
Anathema: deny the Real Presence, take innocent life,
          abandon the sacraments, despair of God's mercy
Areas of Concern: covenant, sacraments, the Church, justice, mercy

Sanctification    can choose holy
Divine Font       heal
Domains           Creation, Truth, Healing, Family
Alternate         Soul, Repose (purgatory), Zeal, Indulgence
Cleric Spells     1st: bless; 3rd: heal; 5th: angelic messenger
Religious Symbol  Crucifix
Sacred Animal     lamb
Sacred Colors     gold and white
```

### Reformed fill

```
YHWH (The Lord, the I AM)

Edicts: preach the Word in season and out, love God and neighbor,
        do justice, walk humbly with God
Anathema: worship images or doctrines as idols, despair of grace,
          oppress the poor, presume upon God's mercy
Areas of Concern: Word, covenant, justice, grace, providence

Sanctification    can choose holy   (use sparingly — minister-of-Word emphasis)
Divine Font       heal
Domains           Truth, Knowledge, Zeal, Vigil
Alternate         Creation, Healing, Soul
Cleric Spells     1st: bless; 3rd: holy light; 5th: command (the Word)
Religious Symbol  open Bible / cross
Sacred Animal     lamb
Sacred Colors     black and white   (Reformation pulpit gown)
```

**Reformed-specific note**: cessationism ([[denominational-lens-decision]]) makes routine Cleric magic theologically loaded; consider the Pharasma-precedent **`sanctification: none`** path if the table won't tolerate active charisms.

### Pentecostal / Charismatic fill

```
YHWH (The Lord, Father of the Spirit-Outpouring)

Edicts: obey the Spirit's leading, lay hands on the sick,
        proclaim freedom to captives, pursue holiness
Anathema: grieve the Spirit, deny the gifts,
          profane the gathered church, love money
Areas of Concern: Spirit, healing, prophecy, deliverance, evangelism

Sanctification    can choose holy
Divine Font       heal
Domains           Healing, Truth, Zeal, Vigil
Alternate         Knowledge, Family, Confidence
Cleric Spells     1st: heal; 3rd: holy light; 5th: banishment
Religious Symbol  cross with descending dove
Sacred Animal     dove
Sacred Colors     red (Spirit fire) and white
```

### Eastern Orthodox fill

```
YHWH (The All-Holy Trinity, Pantokrator)

Edicts: pursue union with God (theosis), keep the fasts,
        venerate the saints and icons, give alms
Anathema: blaspheme the icons, despair of theosis,
          schism from the Body, presume upon grace
Areas of Concern: theosis, liturgy, icons, ascesis, eucharist

Sanctification    can choose holy
Divine Font       heal
Domains           Healing, Truth, Soul, Vigil
Alternate         Creation, Knowledge, Zeal
Cleric Spells     1st: bless; 3rd: holy light; 5th: divine wrath
Religious Symbol  Christ Pantokrator icon
Sacred Animal     lamb (paschal) and eagle (John the Theologian)
Sacred Colors     gold and red (royal)
```

### Strict-monotheism / Pharasma-precedent fill (`sanctification: none`)

For a *strict* monotheistic reskin where the holy/unholy mechanic feels theologically wrong (refusing to mechanize the divine name as a damage trait): set `sanctification: none`, accept that no Champion path attaches directly to YHWH. Christian-themed Champions instead take a *named saint*, an *archangel*, or *the cause of righteousness* (abstracted) as their patron.

```
YHWH (The Most High; Sanctification: none)

Edicts: <as appropriate to the chosen lens>
Anathema: <as appropriate to the chosen lens>
Sanctification    none   (Pharasma-precedent: no holy/unholy trait)
Divine Font       heal
[other fields per lens]
```

This is **the most theologically rigorous option but the most mechanically restrictive**. Documented as a real Paizo precedent (Pharasma) so it doesn't break PF2e design contracts.

## Drafting heuristics for edicts and anathema

1. **3–4 items each**, never more, rarely fewer (Remaster discipline).
2. **Comma-joined imperative phrases**, not full sentences.
3. **Mix at least one positive duty with at least one prohibition of intent/character** ("tell lies", "abandon a companion", "despair of mercy") — this is what makes them playable, not just rule-following.
4. **Avoid Iron-Age literal phrasing** — abstract to the underlying ethical violation. **The Asmodeus precedent**: Paizo themselves moved from "free a slave" to "share power with the weak"; from "rob a tomb" to "take from the dead in bad faith." Apply this to the Decalogue in a Christian reskin: not "do not eat shellfish" but "violate the boundary set by your covenant community."
5. **At least one item should connect to the deity's specific cosmological role** (Sarenrae's "destroy Spawn of Rovagug" pattern). For YHWH: "proclaim the gospel to all nations" or "uphold the covenant" or "wait for the Day of the Lord."

## Open questions

1. **Favored weapon**: longsword ("sword of the Word", Heb 4:12) is the strongest mechanical fit; sling (David), shepherd's crook (staff/club stats), shofar (exotic) are flavor alternatives. **Recommended default: longsword**.
2. **Divine attribute**: Wis matches the prophetic archetype; Cha matches the kingly/Davidic archetype. **Recommended default: Wisdom**, with Cha as alternate.
3. **The Trinity question**: one entry with three personae? Three entries (Father / Son / Spirit)? A "pantheon" of one (Pharasma is sometimes treated as a soft pantheon)? **Recommended default**: one entry with the three personae as in-fiction depth, not separate stat blocks. Keep mechanical simplicity. The Catholic and Orthodox lenses are most natural here; Reformed prefers single-entry too.
4. **Religious symbol** lens-dependence: Catholic favors crucifix; Reformed favors plain cross + open Bible; Orthodox favors Christ Pantokrator icon; Pentecostal favors cross-with-dove; Lewisian favors plain cross.
5. **Saint patrons as additional entries**: Catholic and Orthodox lenses should ship per-saint sub-entries (St Michael, St George, St Raphael, etc.) usable as Champion patrons. Reformed and Pentecostal don't need these.

## See also

- [[remaster-monotheism-fit]] — sanctification spectrum, anathema tone-shift, the "deity stat block" mechanics layer
- [[denominational-lens-decision]] — which lens to commit to before filling this template
- [[biblical-cosmology-pf2e-mapping]] — what the deity's Areas of Concern actually populate (planes, archangels, demons, eschaton)
- [[class-ancestry-reskin-verdicts]] § Champion — the class that consumes this stat block most heavily
- [[pf2e-licensing-posture]] (sister `pf2e-worldbuilding-tool` topic) — published-reskin language must be ORC + paraphrase, not Paizo-text-verbatim
