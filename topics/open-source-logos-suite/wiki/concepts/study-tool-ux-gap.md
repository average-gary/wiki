---
title: Study-Tool UX Gap
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [logos, oss, ux, gap-analysis, sermon-builder, factbook, syntactic-search]
sources:
  - "[[raw/articles/2026-05-27-logos-feature-surface-synthesis]]"
  - "[[raw/articles/2026-05-27-logos-cascadia-macula-data-availability]]"
  - "[[raw/articles/2026-05-27-oss-sword-project-crosswire]]"
  - "[[raw/articles/2026-05-27-oss-step-bible-tyndale]]"
---

# Study-Tool UX Gap

The OSS Bible-software landscape has solved the data and reading layers. What it has not solved — and what Logos charges $9.99–$19.99/month for — is the integrated study-tool UX above the text. This article catalogs the gap.

## What OSS already does well

| Layer | OSS coverage |
|-------|--------------|
| **Engine + module ecosystem** | SWORD (CrossWire) — C++ engine, 100-language modules, JSword (Java), And Bible (Android), BibleTime (Linux), Xiphos, Pocket Sword |
| **Tagged Hebrew + Greek** | OSHB / WLC, MorphGNT, STEPBible TAHOT/TAGNT |
| **Lexicons** | Strong's (PD), BDB (PD 1906), TFLSJ (CC BY 4.0 LSJ derivative) |
| **Translations** | WEB, BSB, KJV, ASV, plus 140+ in scrollmapper databases |
| **Cross-references** | OpenBible.info ~340k refs |
| **Translation workbench** | Bibledit (Paratext alternative) — actively developed |
| **Multi-translation databases** | scrollmapper/bible_databases (MIT, 140 translations as SQLite/JSON/CSV) |
| **Bible APIs** | bible-api.com, wldeh/bible-api (free, public-domain only) |

The reading + searching + word-lookup primitives are essentially solved.

## What OSS lacks

### 1. Syntactic search

Logos's Cascadia Syntax Graph and Logos High Definition Old Testament let users search for grammatical patterns: *"find every verbless clause where the subject is a divine name."* No OSS Bible app has the UX for this.

**Status of the data**: The hard part — the syntactic trees themselves — is now openly available. **MACULA Greek (Clear Bible)** republishes SBLGNT with full syntactic data under CC BY 4.0. MACULA Hebrew is coming. The data moat collapsed; the UX moat persists.

**What needs to be built**: a clause-query language + UI + index that lets users compose queries against syntactic-tree XML.

### 2. Sermon Builder workflow

Logos's Sermon Builder and Sermon Manager ties:
- Sermon outlines (with Bible references that auto-resolve)
- Slide deck export (PowerPoint, Faithlife Proclaim, Keynote)
- Sermon library (search across years of past sermons)
- Reading-plan integration

**OSS state**: Bibledit serves Bible *translators*, not preachers. There is no OSS sermon-builder. This is one of the highest-leverage features for the target user (pastors, lay teachers).

### 3. Factbook (curated entity graph)

Logos's Factbook is an editorial knowledge graph: "Pontius Pilate" → biographical sketch + linked verses + linked library articles + maps + timeline + image gallery. Same for places, topics, doctrines. Decades of editorial tagging.

**OSS state**: nothing equivalent. STEPBible TIPNR (proper-noun database) is a seed but not a graph. Wikidata has some entity coverage but isn't biblically curated.

**What needs to be built**: an entity graph schema + ingestion pipeline that combines TIPNR + Wikidata + manual curation + plugin contributions.

### 4. Passage Guide (auto-aggregation)

Logos's Passage Guide says "I'm reading Romans 8:28" and aggregates *across the user's library*: every commentary's section, every cross-reference, every relevant lexicon entry, every scholarly journal article the user owns. This is a search UI plus library coverage.

**OSS state**: nothing equivalent. The blocker is library — OSS libraries are tiny.

### 5. Reverse interlinears per translation

Each major English translation has its own commissioned reverse-interlinear alignment to original-language texts. Strong's-tagged KJV is the only open-source equivalent.

**Status**: STEPBible's TAHOT/TAGNT include alignment data for some translations, but the per-translation reverse interlinear (how *this specific English wording* maps to *this specific Greek word*) is mostly not open.

**What needs to be built**: alignment pipelines for the open translations (WEB, BSB, ASV, NETS LXX). For walled translations, BYO-API-key approach.

### 6. Cross-device sync

Logos syncs notes, highlights, reading position, sermon drafts across desktop / web / iOS / Android with offline mobile.

**OSS state**: And Bible (Android) is best-in-class for mobile reading. Nobody has integrated cross-platform sync of user data.

**Solvable**: Yjs/yrs CRDT with hosted sync server (see [[decentralized-sync|Decentralized sync]]).

### 7. AI / LLM-assisted research

Logos shipped an "AI Research Assistant" feature in 2024-2025 that does semantic search across the library + Q&A. Modern feature, lots of hype.

**OSS state**: nothing native. Plugin opportunity (Ollama integration, Anthropic BYO key).

## The "good enough" threshold

To be a credible Logos alternative, the OSS suite needs to deliver:

1. ✅ **Reading + search** (already there in SWORD-based apps)
2. ✅ **Word study** (already there with Strong's + BDB + TFLSJ)
3. ✅ **Cross-references** (already there with OpenBible.info)
4. ⚠️ **Cross-device sync** of user data — gap
5. ⚠️ **Syntactic search** UI — gap (data is open)
6. ⚠️ **Sermon builder** — gap
7. ⚠️ **Factbook v0** — gap (data partially open)
8. ⚠️ **Passage Guide v0** — gap (depends on plugin/library coverage)

Items 4-8 are the buildable wedge.

## Why this gap exists

OSS Bible software is built mostly by:
- Translation organizations (SIL, Tyndale House, CrossWire) optimizing for *translation workflows*, not Bible *study*
- Hobbyists building reader apps (And Bible, Pocket Sword), not study suites
- Academic projects (MACULA, MorphGNT) producing data, not products

There is no OSS organization with a sustained pastor/lay-teacher product focus. That's the seam.

## See Also

- [[../topics/engineering-playbook|Engineering playbook]]
- [[../reference/logos-feature-surface|Logos feature surface]]
- [[../reference/oss-bible-software-landscape|OSS Bible software landscape]]
- [[biblical-data-licensing|Biblical data licensing]]
