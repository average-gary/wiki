---
title: "PF2e Remaster mechanical fit for monotheism"
type: concept
created: 2026-05-25
updated: 2026-05-25
verified: 2026-05-25
volatility: medium
confidence: high
sources:
  - "[[2026-05-24-remaster-fit-for-monotheism-aon-champion-class]]"
  - "[[2026-05-24-remaster-fit-for-monotheism-aon-cleric-class]]"
  - "[[2026-05-24-remaster-fit-for-monotheism-aon-deity-template]]"
  - "[[2026-05-24-remaster-fit-for-monotheism-foundry-pf2e-remaster-changes]]"
  - "[[2026-05-24-remaster-fit-for-monotheism-wikipedia-remaster-overview]]"
  - "[[2026-05-24-remaster-fit-for-monotheism-divine-tradition-analysis]]"
  - "[[2026-05-24-remaster-fit-for-monotheism-damage-types-energy]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-iomedae-sarenrae]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-pharasma-erastil]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-abadar-torag-asmodeus]]"
  - "[[2026-05-25-lost-omens-divine-mysteries-yhwh-template-synthesis]]"
tags: [pf2e, remaster, sanctification, holy-unholy, alignment, monotheism, mechanical-fit, deity-template]
---

# PF2e Remaster mechanical fit for monotheism

The PF2e Remaster (2023–2024) **accidentally did most of the structural work** for a Christian-Biblical reskin. Pre-Remaster PF2e (and D&D 5e) had built-in pluralism — alignment damage on a Lawful/Chaotic/Good/Evil grid, polytheistic deity slots tied to alignment, schools of magic mirroring D&D's polytheistic cosmology. The Remaster removed the alignment grid, swapped to typed energy (holy/unholy/spirit/vitality/void), decoupled deity slots from alignment, and replaced schools with traits. Result: a **monotheistic reskin needs ~5 short reflavor paragraphs and ~2 small homebrew rules**, where pre-Remaster it needed extensive surgery.

## What just works (~70% of relevant mechanics)

These need **zero rules change** for a monotheistic reskin:

- **Sanctification** (holy / unholy / none) — replaces alignment-locked causes. Holy = aligned with the divine; unholy = aligned against. Maps cleanly to Christian "in Christ" / "in the world" categories without invoking the four-axis grid.
- **Divine font** (heal or harm pool) — mechanically clean; no theological friction (see "minor rule change" below for `harm` font).
- **Doctrine choice** (cloistered vs warpriest) — purely mechanical; reskins as monastic vs warrior-priest.
- **Edicts / anathema framework** on deities — already deity-customizable. Just write the YHWH covenant entries.
- **Atone ritual** — restores lapsed devotion. Maps to confession/repentance.
- **Holy/unholy damage interactions** — work across all four traditions.
- **Spirit / vitality / void damage types** — vitality vs void echoes Augustinian privation-of-being metaphysics; spirit handles soul-affecting attacks.
- **Deity stat block fields** — pure data; **nothing in the template forces polytheism**; one deity entry suffices. Per *Lost Omens: Divine Mysteries* (Aug 2024) precedent, the Remaster shape is:

  | Field | Length / shape |
  |---|---|
  | Edicts | **3–4 short imperatives**, comma-joined |
  | Anathema | **3–4 short prohibitions**, comma-joined |
  | Sanctification | **5 values**: holy / unholy / both / **none** / can-choose-X |
  | Divine Font | heal / harm / heal-or-harm |
  | Domains | **4 primary + 1–3 alternate** |
  | Cleric Spells | **exactly 3, level-tagged** |
  | Religious symbol / Sacred animal / Sacred colors | new fields in Remaster (absent from legacy CRB) |

  **Anathema tone-shift design lesson** (Asmodeus precedent): Paizo themselves moved from archaic literal phrasings ("free a slave") to abstract ethical phrasings ("share power with the weak"). Apply this to the Decalogue in a Christian reskin — not "do not eat shellfish" but "violate the boundary set by your covenant community."

  **The Pharasma escape hatch**: Pharasma's Remaster entry ships with `sanctification: none` — major canonical deity, no holy/unholy mechanic. **This is a real Paizo precedent for a strict-monotheism reskin** that refuses to mechanize the divine name as a damage trait. See [[yhwh-deity-template]] for the four denominational fills (Catholic / Reformed / Pentecostal / Orthodox) and the Pharasma-precedent variant.
- **Champion's Aura** + reaction system — mechanically clean.
- **Sense Holiness / Sense Unholiness feats** (renamed from Sense Good / Sense Evil) — work directly.

## What needs minor reframing (reflavor only, no rules)

- **Deity edicts/anathema** → YHWH covenant: Decalogue + Sermon on the Mount as anathema/edicts. See [[denominational-lens-decision]] for how the specific list shifts by denomination (Catholic adds sacramental edicts; Reformed leans more Decalogue-heavy).
- **Champion causes** → covenantal vocations: paladin = warrior of justice; redeemer = mercy/repentance ministry; liberator = exodus/freedom-from-bondage. The Remaster already decoupled these from alignment, so any cause label works as long as the player picks a sanctification.
- **Pantheon field** → set to "none" or repurpose as "rite/order" (Benedictine, Franciscan, Dominican) for sub-traditions within a denominational frame.
- **Four traditions reflavored**: divine = sacramental/charismatic; primal = creation-mysticism / Edenic-stewardship; occult = contemplative / discernment-of-spirits; arcane = natural philosophy / Solomonic wisdom. See [[magic-theology-approaches]] for which approach actually keeps which tradition.

## What needs minor rule change (homebrew)

- **Deity-selection wording** in Cleric/Champion ("choose a deity") becomes "you serve the Lord (or, in apostasy, a fallen patron)." This is a one-line rewrite; the underlying deity stat block is reused.
- **Harmful divine font** (`harm` pool) → reserve for explicitly fallen/apostate clergy or cut entirely from canonical clergy. Lay clergy of YHWH should default to `heal`; the `harm` font is theologically loaded (cursing as a clerical power) and is best used as a villain/fallen-prophet hook (Balaam, Saul-after-Endor).
- **Void-trait spells** = anathema for canonical clergy (replaces the lost "necromancy school is anathema" hook from pre-Remaster). The `void` damage type and necromantic effects still exist; just designate them as edicts-violating.

## What to cut entirely

- **Legacy alignment damage rules** in any pre-Remaster supplements imported (already gone in Remaster but flag in any pre-Remaster supplements imported per [[pf2e-licensing-posture]] OGL/ORC mixing rules — see sister wiki).
- **Polytheistic pantheon assumptions** in Lost Omens setting material — just don't use Golarion. The reskin replaces the setting entirely, which is also the licensing-clean choice (Golarion content requires Community Use → must be free; pure ORC mechanics with custom setting is monetizable — see [[pf2e-licensing-posture]] in sister topic).
- **Inner Sea Pantheon-as-cosmology lore**.

## The biggest remaining friction

The **four-tradition split** (arcane / divine / primal / occult) is metaphysically pluralist by default. The Remaster did not change this. **Fix**: a single setting paragraph asserting "all magic ultimately derives from God; mortals access it through different disciplines (Spirit-given charisms, creation-stewardship wisdom, contemplative discernment, natural philosophy)." This converts the pluralism from cosmological to anthropological — many disciplines, one source. See [[magic-theology-approaches]].

## The biggest pleasant surprise

The **holy/unholy/spirit/vitality/void taxonomy** is theologically *richer* than 5e or legacy PF2e:

- **Holy/unholy** — clean binary aligned with divine vs anti-divine.
- **Vitality vs void** — echoes Augustine's privation theory: evil is not a substance but a hollowing-out of being (*privatio boni*). Void damage = literal anti-existence; vitality = participation in life. This is unusually theologically literate for a TTRPG mechanic.
- **Spirit damage** — handles soul-affecting attacks cleanly without conflating them with mind/morale.

The mapping suggests itself: **Holy** = aligned with God (Champion sanctified); **Unholy** = aligned against (Champion fallen, Antichrist NPCs); **Vitality** = participation-in-being (healing, light); **Void** = privation (curse, death, anti-being); **Spirit** = soul-affecting (deliverance, possession, exorcism).

## Effort estimate

A monotheistic reskin needs roughly:
- 1 deity entry (one stat block with extensive edicts/anathema) — plus per-saint entries if Catholic/Orthodox.
- ~5 short reflavor paragraphs (one per tradition + one for causes).
- 2 small homebrew rules (void-trait spells = anathema for canonical clergy; harmful font restricted/cut from canon).
- 0 rule rewrites of mechanical core.

Pre-Remaster, the same reskin would have needed: alignment damage replacement, alignment-locked-cause replacement, deity-alignment decoupling, school-of-magic re-engineering, plus all the above. The Remaster's structural changes save **months of design work** for this kind of reskin.

## See also

- [[biblical-cosmology-pf2e-mapping]] — what the deity edicts and planar map should actually contain
- [[magic-theology-approaches]] — how to fix the four-tradition pluralism
- [[class-ancestry-reskin-verdicts]] — class-by-class which mechanics survive untouched
- [[denominational-lens-decision]] — which sanctification flavor and edicts list to pick
- [[pf2e-remaster-name-mapping]] (sister `pf2e-worldbuilding-tool` topic) — the canonical ~330 rename pairs; the theology-loaded ones (Sense Evil → Sense Unholiness, Holy Avenger → Chalice of Justice, pantheon renames) are documented there
- [[pf2e-licensing-posture]] (sister topic) — ORC-only + Golarion-replaced is the monetization-clean posture for shipping a reskin

## Open questions

- Primary rule text for holy/unholy traits and spirit damage from AoN — Rules.aspx ID lookups returned navigation chrome; Foundry journal is the working substitute.
- *Lost Omens: Divine Mysteries* (Aug 2024) per-deity remasters not directly fetched. Note: Loza confirms it was conceived *before* the OGL fiasco (see [[2026-05-25-sanctification-designer-commentary-loza-divine-mysteries-interview]]) — it is in-flight Golarion expansion retrofitted to the new mechanics, not a theological response to alignment removal.
- Reddit/forum community discussion on monotheistic homebrew — Reddit JSON tooling now works; deeper dive deferred.

## Designer commentary on sanctification — closed (negative finding)

**Question (resolved 2026-05-25):** Did any Paizo designer (Logan Bonner, Mark Seifter, Luis Loza, James Case) publicly give a *theological* rationale for choosing the holy/unholy/spirit/vitality/void taxonomy or the sanctification framework?

**Answer: No. Public commentary is exclusively licensing-driven and mechanical.**

Three primary-source designer statements were located:

1. **Logan Bonner, Player Core 2 Champion Preview** (Paizo blog, June 2024 — [[2026-05-25-sanctification-designer-commentary-bonner-champion-preview]]). Frames the sanctification redesign as *roleplaying flexibility*: replacing "an unbendable code" of alignment with edicts/anathema "tied to character choices" for "more well-rounded, nuanced characters." Sanctification is presented as an *optional* deity-driven flavor layer that adds an edict, anathema, and damage trait. **No theological framing whatsoever.**
2. **Original Remaster Project announcement** (Paizo blog, April 2023 — [[2026-05-25-sanctification-designer-commentary-paizo-remaster-announcement]]). Alignment removal is grouped with "a small number of nostalgic creatures, spells, and magic items exclusive to the OGL" — pure license-flight surgery. **No design philosophy or worldbuilding rationale offered.**
3. **Luis Loza, BadLuckGamer interview** (May 2024 — [[2026-05-25-sanctification-designer-commentary-loza-divine-mysteries-interview]]). Loza, the Creative Director responsible for *Lost Omens: Divine Mysteries*, calls "sanctification and wizard schools" the **"most egregious changes"** — i.e., backward-compatibility breaks to manage, not theological breakthroughs to celebrate. He also confirms Divine Mysteries was conceived *before* the OGL crisis.

Cross-confirmed by community essay ([[2026-05-25-sanctification-designer-commentary-community-change-mgmt-essay]]): the holy/unholy/spirit traits were *expected* and *unsurprising* in the preview cycle — debated only by players who wanted to keep mechanical alignment, never as a theological/metaphysical reframing.

**Why "spirit" damage exists** — no designer has publicly defined it in metaphysical terms. The official mechanical scope (a damage type that affects souls/incorporeal entities and bypasses certain physical resistances) is the only level at which it has been described.

**Implication for this wiki's thesis:** The PF2e Remaster's monotheistic fit is genuinely *accidental* — emergent from designers reaching for the most generic divine/anti-divine vocabulary available once alignment terminology had to go. The Augustinian privation echo (vitality vs void) and the sanctification-as-deity-conformity structure are not authorial intent; they are the structural shadow cast by *removing* a polytheistic-pluralist alignment grid without replacing it with a different cosmology. This *strengthens* the reskin pitch: a Christian-Biblical reskin is not "fighting against" a designed pluralist intent; it is filling in a vacuum the Remaster left behind.
