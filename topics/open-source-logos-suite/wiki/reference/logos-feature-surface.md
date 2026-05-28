---
title: Logos Feature Surface
type: reference
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [logos, faithlife, features, reference]
sources:
  - "[[raw/articles/2026-05-27-logos-wikipedia-overview]]"
  - "[[raw/articles/2026-05-27-logos-homepage-product-pitch]]"
  - "[[raw/articles/2026-05-27-logos-pricing-tiers-subscription-shift]]"
  - "[[raw/articles/2026-05-27-logos-feature-surface-synthesis]]"
  - "[[raw/articles/2026-05-27-logos-cascadia-macula-data-availability]]"
---

# Logos Feature Surface

What Logos Bible Software (logos.com) actually is, in concrete terms. Reference catalog for an OSS suite trying to compete or differentiate.

## Company / origin

- **Founded**: 1992 in Bellingham, WA, by ex-Microsoft engineers Bob and Dale Pritchett + Kiernan Reiniger
- **Acquisition seed**: Dallas Theological Seminary's CDWord HyperCard Bible
- **Rebrand**: Faithlife Corporation, 2014
- **Current ownership**: Cove Hill Partners (private equity), 2022
- **Variants**: Logos (Protestant/general), Verbum (Catholic), Noet (academic non-religious — discontinued), separate LDS and Eastern Orthodox SKUs
- **Tech stack**: C# / WPF on Windows, native macOS, native iOS, native Android, web (recent)
- **Library**: 120,000–250,000 ebooks (Wikipedia / marketing claims diverge)
- **User base**: ~6 million claimed (marketing)

## Pricing (2026)

### Subscription tiers (current direction)
- **Premium** — $9.99/month
- **Pro** — $14.99/month
- **Max** — $19.99/month

### Legacy perpetual packages (still sold)
- **Bronze** — ~$300
- **Silver** — ~$600
- **Gold** — ~$1,500
- **Platinum** — ~$2,500
- **Diamond** — ~$4,000
- **Portfolio** — $5,000+

## Feature surface (the moat)

### 1. Library / digital book platform

- 120k–250k ebooks across ~500 publishers
- Proprietary `.logos` / `.logosres` book format
- Books non-portable to other apps (the lock-in)
- License to read, not own — though traditional "purchase" model still available

### 2. Reverse interlinear (per translation)

- Aligns each English word in major translations (ESV, NIV, NASB, etc.) to its Greek/Hebrew source
- Commissioned alignment data per translation
- Hover over English word → see lemma, Strong's, morphology
- **Moat**: per-translation alignment data is proprietary (different from Strong's-tagged KJV which is open)

### 3. Original-language tools

- Morphological search (verb forms, noun cases, etc.)
- Lemma search (Strong's H/G or original lemma)
- Lexicons: BDAG, HALOT, LSJ (commercial); Strong's, BDB (open)
- **Cascadia Syntax Graph** for syntactic search
  - **Important**: MACULA Greek (Clear Bible) now openly republishes SBLGNT with full syntax data under CC BY 4.0 — Logos's data moat collapsed; UX moat persists

### 4. Passage Guide

- User looks up a passage (e.g., Romans 8:28)
- App auto-aggregates from user's library: every commentary section, every cross-reference, every relevant lexicon entry, every relevant scholarly journal article
- Power scales with library size

### 5. Exegetical Guide

- Verse-by-verse breakdown for original-language study
- Aligned word, lemma, parsing, lexicon, similar uses
- For each verse: word study cards

### 6. Word Study Guide

- Pick a word; see frequency, distribution, lexicon entries, key passages
- Cross-translation usage
- Senses and ranges of meaning

### 7. Factbook

- Curated entity graph: people, places, topics, doctrines
- For each entity: biographical / definitional sketch + linked verses + linked library articles + maps + timeline + image gallery
- Decades of editorial tagging
- **Moat**: nobody else has this curated entity graph at this depth

### 8. Sermon Builder + Sermon Manager

- Sermon outlines with Bible references that auto-resolve
- Slide deck export (PowerPoint, Keynote, Faithlife Proclaim)
- Sermon library (search across years of past sermons)
- Reading-plan integration
- **One of the most-used features for Logos's pastor user base**

### 9. Notebooks + highlights + notes

- Free-form notes attached to passages or topics
- Visual highlights (multiple colors)
- Tagged notes for cross-passage themes
- Sync across devices

### 10. Reading plans

- Multiple plans (Bible-in-a-year, M'Cheyne, custom)
- Track progress
- Bridge to devotional content

### 11. Cross-device sync

- Desktop (Win/Mac/Linux), Web, iOS, Android
- Offline mobile
- Notes, highlights, reading position, sermon drafts all sync

### 12. AI Research Assistant (added 2024-2025)

- Natural-language Q&A over the user's library
- Summarization features
- Semantic search

### 13. Faithlife ecosystem integration

- **Faithlife Proclaim** — church presentation software
- **Faithlife Sermons** — sermon hosting/sharing
- **Faithlife.com** — community / social features (declining)
- **Faithlife Equip** — small-group / discipleship tools

## What Logos is NOT (and where the gap is)

- Not extensible by third-party developers (no public plugin SDK)
- Not user-portable (proprietary library format)
- Not affordable (entry tier is $9.99/mo; full perpetual library is $5,000+)
- Not cross-account collaborative (sermons don't share well between accounts)
- Not theologically neutral (heavy Protestant evangelical default; Verbum Catholic SKU exists but is a different product)

## What an OSS suite can realistically deliver

Per [[../concepts/study-tool-ux-gap|Study-tool UX gap]]:

| Feature | OSS suite Phase 0-3 plan |
|---------|--------------------------|
| Library | NOT cloning Logos's library — let users BYO licensed translations and commentaries via plugins |
| Reverse interlinear | KJV (Strong's) + open translations (WEB, BSB, ASV) via STEPBible alignments |
| Morphology / lemma search | Fully buildable on STEPBible TAHOT/TAGNT |
| Syntactic search | Buildable on MACULA Greek; UX is the work |
| Passage Guide | Plugin-driven aggregation of user's installed resources |
| Sermon Builder | Buildable; Bibledit is a starting data model |
| Factbook | v0 from STEPBible TIPNR + Wikidata; deeper requires editorial work |
| Notebooks / highlights | Markdown + Yjs sync |
| Reading plans | Trivial |
| Cross-device sync | Yjs/yrs + ATProto identity |
| AI assistant | Plugin via Ollama / BYO Anthropic key |

## See Also

- [[../concepts/study-tool-ux-gap|Study-tool UX gap]]
- [[../concepts/biblical-data-licensing|Biblical data licensing]]
- [[oss-bible-software-landscape|OSS Bible software landscape]]
- [[../topics/engineering-playbook|Engineering playbook]]
