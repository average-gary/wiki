---
title: Biblical Data Licensing
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [licensing, biblical-data, public-domain, copyright, esv, niv, stepbible, oshb]
sources:
  - "[[raw/articles/2026-05-27-data-stepbible]]"
  - "[[raw/articles/2026-05-27-data-oshb-wlc]]"
  - "[[raw/articles/2026-05-27-data-morphgnt-sblgnt]]"
  - "[[raw/articles/2026-05-27-data-strongs-pd]]"
  - "[[raw/articles/2026-05-27-data-web-ebible]]"
  - "[[raw/articles/2026-05-27-data-openbible-xrefs]]"
  - "[[raw/articles/2026-05-27-data-esv-api-wall]]"
---

# Biblical Data Licensing

The licensing landscape for biblical texts and study data in 2026 is more open than it has ever been — but the major commercial English translations remain walled. Engineering implication: **build text-agnostic; ship the open stack by default; let users BYO API key for commercial translations.**

## Freely shippable (the buildable stack)

### Original-language texts

| Asset | License | Format | Notes |
|-------|---------|--------|-------|
| **OSHB / WLC** (Westminster Leningrad Codex Hebrew OT) | Text PD; morphology CC BY 4.0 | OSIS XML | Most widely-used open Hebrew with full morphology tags |
| **MorphGNT** | CC BY-SA 3.0 | Text + morph | Open Greek NT with morphology |
| **SBLGNT** (text alone) | Custom EULA | XML/JSON | Non-commercial-leaning; **prefer alternatives for commercial use** |
| **STEPBible TAGNT** | CC BY 4.0 | TSV | Open commercial-friendly Greek NT — recommended over SBLGNT for new projects |
| **Byzantine Majority Text** | PD | Various | Fully open Greek NT alternative |
| **Septuagint (LXX)** | PD versions: Swete, Brenton; Rahlfs contested | XML | Use Swete or Brenton for safety |

### Translations

| Translation | License | Use |
|-------------|---------|-----|
| **WEB** (World English Bible) | PD | Default modern English |
| **BSB** (Berean Standard Bible) | PD/CC0 | Free even for commercial; modern translation |
| **KJV** | PD | Classic English |
| **ASV** | PD | Public-domain late-1800s |
| **Douay-Rheims** | PD | Catholic public-domain |
| **NETS** (New English Translation of Septuagint) | Open with attribution | Modern LXX English |

### Lexicons

| Lexicon | License | Use |
|---------|---------|-----|
| **Strong's Concordance** (1890) | PD | Strong's H/G numbers are the canonical Bible-search ID |
| **BDB** (Brown-Driver-Briggs, 1906) | PD | Standard Hebrew lexicon |
| **TFLSJ** (Tyndale House LSJ-derivative) | CC BY 4.0 | Free Greek lexicon — replaces locked LSJ in commercial contexts |
| **LSJ Perseus version** (1940) | CC BY-SA 4.0 | Greek lexicon via Perseus Digital Library |
| **Thayer's** (1889) | PD | Older Greek lexicon |

### Morphology, syntax, references

| Asset | License | Use |
|-------|---------|-----|
| **STEPBible-Data (TAHOT/TAGNT)** | CC BY 4.0 | **The strategic dataset** — disambiguated Strong's, morphology, lexicons, proper names, versification |
| **MACULA Greek** (Clear Bible) | CC BY 4.0 | Greek NT with full syntactic trees — collapses Logos's Cascadia moat |
| **OpenBible.info cross-references** | CC BY | ~340k cross-references |
| **TIPNR** (STEPBible proper nouns) | CC BY 4.0 | Factbook entity seed |

### Commentaries (public domain)

Matthew Henry, Jamieson-Fausset-Brown (JFB), John Calvin, Adam Clarke, John Gill — all PD via CCEL (Christian Classics Ethereal Library).

## Hard copyright walls

### Tier 1: Free for non-commercial, locked for commercial

**ESV (Crossway)** — Free API for non-commercial use only:
- 5,000 queries/day cap
- 500-verse cache cap (cannot store the full Bible client-side)
- No ads, donations, or charging permitted
- **Doctrinal-revocation clause**: Crossway can revoke if app contradicts Crossway's doctrinal positions
- Commercial use = direct license deal with Crossway

**NET Bible (Bible.org)** — Friendlier:
- Notes free for non-commercial
- Commercial requires a deal but lower-friction than ESV
- bibles.org API

### Tier 2: Royalty-bearing commercial licenses (no free tier)

| Translation | Holder | Notes |
|-------------|--------|-------|
| **NIV** | Biblica / Zondervan | Per-user royalty + minimum guarantee |
| **NASB / NASB95** | Lockman Foundation | Per-user royalty + minimum guarantee |
| **NLT** | Tyndale House Publishers | Per-user royalty + minimum guarantee |
| **CSB** | Holman / B&H | Per-user royalty + minimum guarantee |

For each: contracts review derivative usage (search index, audio, study notes).

### Tier 3: Avoid embedding entirely

- **G/K numbers** (Goodrick-Kohlenberger) — proprietary alternative numbering to Strong's
- **Enhanced Strong's** (Logos's curated derivative)
- **Logos Reverse Interlinear alignments** (per-translation, commissioned by Logos)

These are derivative IP. Don't ship.

## Engineering strategy

### 1. Text-agnostic core

The core data model treats Bible text as a pluggable resource. No translation is hardcoded. Default install ships:

- **English**: WEB, BSB, KJV, ASV
- **Hebrew**: WLC + STEPBible TAHOT
- **Greek**: Byzantine MT + STEPBible TAGNT + MACULA Greek (syntax)
- **Lexicons**: Strong's + BDB + TFLSJ
- **References**: OpenBible.info
- **Commentaries**: Matthew Henry + JFB

### 2. BYO-license plugins for walled translations

For ESV, NIV, NASB, NLT, CSB:

- Ship a plugin marketplace
- Plugin requests user's API key (or receipt of purchase)
- Plugin handles per-translation license terms (caching limits, attribution, etc.)
- License burden shifts to the user, not the OSS project

This is the **only legally-clean way** for an OSS project to support walled translations.

### 3. Strong's as the universal join key

Strong's H/G numbers are PD and are the de-facto canonical ID for cross-translation lookup. Every search and lemma operation should normalize through Strong's where possible.

### 4. Versification mapping

STEPBible's versification mapping (CC BY 4.0) handles the Hebrew/Greek/English numbering differences (e.g., Psalms numbered differently in MT vs LXX vs English) — use it instead of rolling your own.

## See Also

- [[../reference/open-data-corpus|Open data corpus]]
- [[../topics/engineering-playbook|Engineering playbook]]
- [[study-tool-ux-gap|Study-tool UX gap]]
