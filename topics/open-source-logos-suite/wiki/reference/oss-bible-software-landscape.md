---
title: OSS Bible Software Landscape
type: reference
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [oss, bible-software, sword, step-bible, landscape, reference]
sources:
  - "[[raw/articles/2026-05-27-oss-sword-project-crosswire]]"
  - "[[raw/articles/2026-05-27-oss-step-bible-tyndale]]"
  - "[[raw/articles/2026-05-27-oss-bible-apis-public]]"
  - "[[raw/repos/2026-05-27-oss-andbible-android]]"
  - "[[raw/repos/2026-05-27-oss-bibledit-cloud]]"
  - "[[raw/repos/2026-05-27-oss-openscriptures-morphhb]]"
  - "[[raw/repos/2026-05-27-oss-scrollmapper-bible-databases]]"
---

# OSS Bible Software Landscape

What exists, what's healthy, where the gaps are.

## Active projects (2024-2026)

### SWORD / CrossWire (engine)
- **What**: C++ library + module ecosystem for Bible texts in 100+ languages
- **License**: GPL
- **Last active**: 2026-05 (current)
- **Health**: Healthy; backbone of most OSS Bible apps
- **Powers**: BibleTime (Linux/cross-platform desktop), Xiphos (Linux), Pocket Sword (iOS, sleepy), And Bible (Android), Ezra Project, JSword (Java)
- **Strength**: module format is widely used; large ecosystem of translations
- **Weakness**: 1990s engine architecture; UI projects on top vary in quality

### STEP Bible / STEPBible-Data (Tyndale House Cambridge)
- **What**: Web app + tagged Greek/Hebrew, lexicons, morphology, proper-noun database, versification mapping
- **License**: CC BY 4.0
- **Web app**: actively maintained
- **Data**: frozen since 2021-05 (release tags), but content is the strategic open dataset for Bible-software
- **Datasets**: TAHOT (Hebrew morph), TAGNT (Greek morph), TBESH/TBESG/**TFLSJ** (free LSJ-derivative), TIPNR (proper nouns), versification map
- **Strength**: scholarly-grade tagged corpus; Tyndale House provenance
- **Weakness**: data hasn't been re-released in years (still useful; just not getting incremental updates)

### And Bible (Android)
- **What**: Mobile SWORD frontend, Kotlin
- **License**: GPL-3
- **Last active**: 2026-03 (v5.0.934, 620+ releases)
- **Health**: Very healthy
- **Strength**: best mobile OSS Bible reader; full SWORD module support
- **Weakness**: Android-only

### Bibledit Cloud
- **What**: OSS Paratext alternative — translation workbench, USFM, git versioning
- **License**: GPL-3
- **Last active**: 2026-03
- **Health**: Healthy (niche)
- **Strength**: real translation workflow; multi-user; version control
- **Weakness**: aimed at translators, not study; sermon/note features minimal

### Open Scriptures OSHB / morphhb
- **What**: Tagged WLC Hebrew OT in OSIS XML (Westminster Leningrad Codex with morphology)
- **License**: CC BY 4.0 + PD
- **Last active**: 2021-12 (v2.2)
- **Health**: Stable archive (not zombie — content is canonical and mostly complete)
- **Strength**: the open Hebrew Bible substrate

### scrollmapper / bible_databases
- **What**: 140 translations as SQLite/JSON/CSV + cross-references
- **License**: MIT
- **Last active**: 2025 schema rewrite
- **Health**: Healthy
- **Strength**: easy ingestion target; broad translation coverage (PD only)
- **Weakness**: PD-only translations; no commentaries

### Bible-API.com / wldeh/bible-api (free public APIs)
- **What**: Free public Bible JSON APIs
- **License**: MIT / mixed
- **Health**: Live; hobby-grade
- **Strength**: zero-setup API for prototypes
- **Weakness**: PD-only; can't serve commercial translations

## Sleepy / zombie projects

- **STEPBible-Data core**: frozen since 2021 (still useful; just not actively updated)
- **OSHB**: stable since 2021-12 (canonical, doesn't need much update)
- **Pocket Sword (iOS)**: reputed sleepy
- **Various legacy SWORD frontends**: BibleTime active but slower; Xiphos slower

## What the OSS landscape DOES well

- **Engine + module ecosystem**: SWORD covers reading + searching + lookups across 100+ languages
- **Tagged Hebrew + Greek**: OSHB + MorphGNT + STEPBible give complete tagged originals
- **Lexicons**: Strong's + BDB + TFLSJ cover the open lexicon stack
- **Translations (PD only)**: WEB, BSB, KJV, ASV, plus 140+ in scrollmapper
- **Cross-references**: OpenBible.info ~340k references
- **Translation workbench**: Bibledit is a real Paratext alternative
- **Mobile (Android)**: And Bible is competitive with commercial apps
- **Bible APIs**: free public APIs cover the hobby/prototype need

## What the OSS landscape DOESN'T do

- **Syntactic search UI**: data exists (MACULA Greek) but no app has clause-query UX
- **Sermon Builder**: nothing aimed at preachers
- **Curated knowledge graph (Factbook equivalent)**: nothing exists
- **Passage Guide auto-aggregation**: depends on library coverage
- **Cross-device sync of user data**: each app has its own (limited) approach
- **iOS reader**: Pocket Sword is sleepy; nothing actively maintained
- **AI / LLM Q&A**: nothing native
- **Visualizations** (timelines, atlases, family trees): nothing in OSS
- **Modern English translations**: NIV/ESV/NLT/NASB/CSB are absent (licensing wall)

## Gap analysis (the wedge)

The substrate (engine, data, basic reading) is solved. The wedge for an OSS Logos suite is:

1. **Integrated study UX** above the data — Passage Guide, Word Study Guide, Factbook seed
2. **Sermon Builder** — empty market in OSS
3. **Modern cross-device sync** — files-on-disk + Yjs + ATProto identity
4. **Modern iOS reader** — native shell over a Rust core
5. **Plugin economy** — sandboxed plugin system, marketplace for sermons / language packs / denominational extensions
6. **Syntactic search UX** — data is open (MACULA), product is missing
7. **AI assistant via plugin** — Ollama + BYO Anthropic key

## Strategic implication

Don't compete with SWORD / Bibledit / And Bible on what they do well. Build the **integrated study suite** that doesn't exist, sitting on top of the data they already produce.

## See Also

- [[logos-feature-surface|Logos feature surface]]
- [[../concepts/study-tool-ux-gap|Study-tool UX gap]]
- [[open-data-corpus|Open data corpus]]
- [[../topics/engineering-playbook|Engineering playbook]]
