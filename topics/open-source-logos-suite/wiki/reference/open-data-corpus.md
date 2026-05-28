---
title: Open Data Corpus
type: reference
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [data, biblical-data, public-domain, corpus, reference]
sources:
  - "[[raw/articles/2026-05-27-data-stepbible]]"
  - "[[raw/articles/2026-05-27-data-oshb-wlc]]"
  - "[[raw/articles/2026-05-27-data-morphgnt-sblgnt]]"
  - "[[raw/articles/2026-05-27-data-strongs-pd]]"
  - "[[raw/articles/2026-05-27-data-web-ebible]]"
  - "[[raw/articles/2026-05-27-data-openbible-xrefs]]"
  - "[[raw/articles/2026-05-27-data-esv-api-wall]]"
  - "[[raw/articles/2026-05-27-logos-cascadia-macula-data-availability]]"
---

# Open Data Corpus

The actual datasets to ship in an OSS Logos suite. Quick-reference for engineering teams.

## Strategic dataset: STEPBible-Data

Tyndale House Cambridge's **STEPBible-Data** under CC BY 4.0 is the closest thing to a "complete free Logos study dataset." Contains:

- **TAHOT** — Translators Amalgamated Hebrew OT with morphology
- **TAGNT** — Translators Amalgamated Greek NT with morphology
- **TBESH / TBESG** — translators' brief lexicons (Hebrew/Greek)
- **TFLSJ** — free LSJ-derivative Greek lexicon (replaces locked LSJ for commercial use)
- **TIPNR** — translators' index of proper nouns and references
- **Versification mapping** — Hebrew/Greek/English/LXX numbering reconciliation

License: CC BY 4.0 (commercial-friendly with attribution).

GitHub: https://github.com/STEPBible/STEPBible-Data

## Original-language texts

| Asset | Source | License | Format |
|-------|--------|---------|--------|
| **OSHB / WLC** Hebrew OT | openscriptures/morphhb | Text PD; morph CC BY 4.0 | OSIS XML |
| **STEPBible TAHOT** Hebrew | STEPBible | CC BY 4.0 | TSV |
| **MorphGNT** Greek NT | morphgnt/sblgnt | CC BY-SA 3.0 | Text + morph files |
| **SBLGNT** Greek NT (text alone) | SBL | Custom EULA | Various |
| **STEPBible TAGNT** Greek NT | STEPBible | CC BY 4.0 | TSV |
| **Byzantine MT** Greek NT | Various | PD | Various |
| **MACULA Greek** syntax trees | Clear-Bible | CC BY 4.0 | LowFAT XML |
| **Septuagint (Swete, Brenton)** | eBible / Tufts | PD | XML / text |

**Recommendation for new builds**: ship **STEPBible TAHOT + STEPBible TAGNT** as the default tagged Hebrew/Greek (CC BY 4.0, commercial-friendly, includes lexicons). Add **OSHB** for users who want the strict WLC text. Avoid SBLGNT for commercial use due to its custom EULA.

## English translations (PD)

| Translation | Source | License | Year |
|-------------|--------|---------|------|
| **WEB** (World English Bible) | eBible.org | PD | Modern revision |
| **BSB** (Berean Standard Bible) | berean.bible | PD/CC0 | Modern, fully commercial-free |
| **KJV** (King James Version) | Various | PD | 1769 (most published) |
| **ASV** (American Standard Version) | Various | PD | 1901 |
| **Douay-Rheims** (Catholic) | Various | PD | 1899 |
| **RV** (Revised Version) | Various | PD | 1885 |

Recommendation: ship **WEB** as default (modern English, fully PD), with **KJV** and **ASV** included for users who want classic English.

## Walled translations (BYO API key)

| Translation | Holder | Free tier | Commercial |
|-------------|--------|-----------|------------|
| **ESV** | Crossway | API: 5k req/day, 500-verse cache cap, non-commercial only | Direct license |
| **NET Bible** | Bible.org | Free non-commercial; bibles.org API | Friendlier deal |
| **NIV** | Biblica/Zondervan | None | Per-user royalty |
| **NASB** | Lockman | None | Per-user royalty |
| **NLT** | Tyndale Publishers | None | Per-user royalty |
| **CSB** | Holman | None | Per-user royalty |

Engineering implication: build a plugin-API where the user enters their API key (or proof of license); plugin handles per-translation license terms.

## Lexicons (open)

| Lexicon | License | Notes |
|---------|---------|-------|
| **Strong's Concordance** (1890) | PD | The universal join key — H/G numbers map across translations |
| **BDB** (Brown-Driver-Briggs, 1906) | PD | Standard Hebrew lexicon |
| **TFLSJ** (Tyndale free LSJ-derivative) | CC BY 4.0 | Free Greek lexicon — replaces locked LSJ |
| **LSJ Perseus version** (1940) | CC BY-SA 4.0 | Greek lexicon via Perseus Digital Library |
| **Thayer's Greek-English** (1889) | PD | Older Greek lexicon |

## Cross-references

| Asset | Source | License | Coverage |
|-------|--------|---------|----------|
| **OpenBible.info x-refs** | OpenBible.info | CC BY | ~340k cross-references |
| **Treasury of Scripture Knowledge (TSK)** | Various | PD | Older but extensive |

Recommendation: OpenBible.info for primary; TSK as backup data source.

## Public-domain commentaries (CCEL)

Christian Classics Ethereal Library hosts:

- **Matthew Henry's Commentary on the Whole Bible** (1708-1714) — devotional, widely-used
- **Jamieson, Fausset, Brown (JFB)** — popular 19th-century commentary
- **John Calvin's Commentaries** — Reformed perspective
- **Adam Clarke's Commentary** — Methodist, 19th century
- **John Gill's Exposition** — Reformed Baptist
- **Wesley's Notes on the Whole Bible**
- **Pulpit Commentary** — multi-author Victorian
- **Spurgeon's Treasury of David** (Psalms commentary)

All PD. Available as XML / HTML / text from CCEL.

## Audio Bibles

- **Faith Comes By Hearing (FCBH)** — many languages, free streaming and download with attribution
- **Digital Bible Society** — various
- **WEB audio** — multiple narrators in PD

## Versification mapping

- **STEPBible versification mapping** (CC BY 4.0) — handles Hebrew/Greek/English numbering differences (e.g., Psalms numbered differently in MT/LXX/English)

## Specialized academic data

- **Cascadia Syntax Graph** — Logos's proprietary syntactic data (NOT open)
- **MACULA Greek** (Clear Bible) — open replacement for Cascadia Greek (CC BY 4.0)
- **MACULA Hebrew** — partial coverage in 2026
- **OpenText.org clause analysis** — academic, restricted use
- **Accordance syntactic data** — proprietary

## What to ship as the default install

For a 1-2 GB default install:

```
Translations (English):
  WEB, KJV, ASV (~20 MB)

Original languages:
  WLC + STEPBible TAHOT (~50 MB)
  Byzantine MT + STEPBible TAGNT (~30 MB)
  MACULA Greek syntax (~50 MB)
  Septuagint Swete edition (~30 MB)

Lexicons:
  Strong's, BDB, TFLSJ, Thayer's (~50 MB)

Cross-references:
  OpenBible.info (~10 MB)

Commentaries (PD):
  Matthew Henry, JFB, Calvin (~250 MB)

Versification mapping:
  STEPBible (~5 MB)

Proper nouns / Factbook seed:
  STEPBible TIPNR + Wikidata extract (~20 MB)

FTS5 search index:
  ~150-300 MB

Total: ~700-900 MB
```

Mobile-friendly. Ship via Iroh-blobs HashSeq + HTTPS mirrors per [[../concepts/decentralized-text-distribution|Decentralized text distribution]].

## See Also

- [[../concepts/biblical-data-licensing|Biblical data licensing]]
- [[oss-bible-software-landscape|OSS Bible software landscape]]
- [[../topics/engineering-playbook|Engineering playbook]]
