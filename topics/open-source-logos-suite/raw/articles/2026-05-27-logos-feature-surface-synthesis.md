---
title: "Logos feature surface — synthesis from product pages and docs"
source_url: "https://www.logos.com/ + community.logos.com/Logos_Features"
type: article
path: logos
date_ingested: 2026-05-27
date_published: unknown
tags: [logos, bible-software, features, tools, study-guides, sermon, baseline]
quality: 4
confidence: medium
summary: "Synthesized feature catalog of Logos's primary tools — Passage Guide, Exegetical Guide, Bible Word Study, Factbook, Sermon Builder, reverse interlinear, Cascadia syntax integration, notebooks, reading plans — assembled from Logos product pages, community wiki, and Wikipedia."
---

# Logos feature surface — synthesis from product pages and docs

## Key findings

### Study Guides (Logos's "killer apps")

- **Passage Guide**: Pick a verse/passage; Logos auto-aggregates from your library: commentaries, cross-references, parallel passages, biblical people/places/things mentioned, illustrations, sermons, ancient literature parallels, media (images, infographics, maps). Driven by structured datasets that link library content to verse ranges. This is the canonical "Logos pulls everything together for me" experience.
- **Exegetical Guide**: For pastors/scholars. Pick a passage; get original-language word-by-word lemma + morphology, lexicon entries (BDAG, HALOT, TDNT, etc.), text-critical apparatus variants, grammatical commentaries, translations comparison.
- **Bible Word Study**: Pick a word (English or Greek/Hebrew). Get a wheel/visualization of senses, lemma frequency, lexicon entries, translation variants across English versions, grammatical relationships, all occurrences in canonical/contextual order.
- **Sermon Starter Guide / Topic Guide**: Outline-bootstrapping for a topic — pulls thematic commentary, illustrations, quotes.

### Factbook

- An entity reference layer. Categories include: **biblical people, places, things, events, doctrines/topics, biblical books, deities, cultural concepts, plants/animals**.
- Each Factbook entry surfaces: a short canonical description, references in the user's library, biblical occurrences, related media (images, maps, family trees), genealogies, timeline events, related entities.
- The data model is essentially a curated Bible-domain knowledge graph. Underpinned by Logos's structured datasets (Bible Knowledgebase, Faithlife Connect content) — the same datasets that power Passage Guide cross-references. **This is the highest-value asset to clone and the hardest** — decades of editorial tagging.

### Original-language tools

- **Reverse interlinear**: Anchored on the *English* (or other modern translation) word order, with Greek/Hebrew lemma, morphology, Strong's, and Louw-Nida senses aligned underneath. Distinguishes Logos from a regular interlinear (which preserves original word order). Available for ESV, NIV, NASB, KJV, LEB, NRSV, CSB, NLT, NKJV, etc. — Logos commissions/licenses the alignment data per translation.
- **Morphological search**: Query the original-language text by morphological criteria (e.g., "all aorist active participles of λύω"). Requires morph-tagged Greek/Hebrew texts — Logos uses datasets like the Logos Greek Morphology, Lexham Hebrew Bible morphology.
- **Syntactic search / Cascadia integration**: **Cascadia Syntax Graphs of the New Testament** is a Faithlife-produced dataset (now CC-licensed and public via the Clear Bible MACULA project — see GitHub Clear-Bible/macula-greek). Logos integrates this for clause/phrase-level search — find every "imperative followed by a purpose clause" or every "head verb whose subject is X." Andersen-Forbes for Hebrew syntax. **This is the single most defensible academic feature.**
- **Lexicons**: BDAG, HALOT, TDNT, NIDNTTE, NIDOTTE, Louw-Nida, Liddell-Scott, plus the in-house **Lexham Bible Dictionary** and **Lexham Theological Wordbook**. Tightly linked to the morph/lemma data so a click on any Greek word jumps to BDAG.

### Sermon Builder

- Manuscript editor with autosave + cloud sync. Specialized for sermons (vs Word/Docs).
- Slides export to ProPresenter, PowerPoint, Keynote. Auto-generates slides from Scripture references in manuscript.
- Sermon Manager: archive, tag, search, reuse, schedule sermons across years.
- Integrations with Faithlife Proclaim (church presentation software) and Faithlife Sermons (sermon publishing/discovery network).
- Generates handouts and discussion questions automatically.
- Pulls illustrations from a curated illustration database.

### Notebooks, highlights, notes

- **Notebooks** (formerly "Personal Books" workflow): tagged, linked, citation-anchored notes. Notes can be anchored to a specific Bible reference or to a paragraph in a library resource — they then re-surface contextually when revisiting that resource.
- **Highlights**: Multiple palettes, per-resource. Sync across devices.
- **Personal Books**: User can compile their own .docx → Logos resource for inclusion in searches and guides.

### Engagement / habit features

- **Reading plans**: chronological, canonical, M'Cheyne, custom. Push notifications + checkmark UI.
- **Prayer lists**: typed prayer items with check-in cadence and Scripture linking.
- **Devotionals**: subscribed daily devotional content delivered into the app feed.
- **Bible Reading Goals**: tracking and streaks.

### Sync / cloud / mobile

- All notes, highlights, reading positions, prayer lists, reading plans sync across desktop (Windows/macOS), web, iOS, Android.
- Offline mode on mobile via downloaded resources.
- Faithlife account is the identity layer.

### Search

- Multiple search modes: Basic, Bible (verse-aware), Reference (find resources that cite passage X), Morph, Syntax, Clause, Inline (within current resource), Topic.
- Search proximity, lemma, morphology, sense (Louw-Nida), and Bible references combinable.

### Variants (same engine, different curation)

- **Verbum** — Catholic edition: Catholic lectionary, Catechism integration, Deuterocanonical resources, Latin texts, Catholic-specific Factbook entries.
- Mormon (LDS) and Eastern Orthodox SKUs have existed historically as bundle/curation variants — same engine.

## Notable quotes / specifics

> "Faithlife partners with more than 500 publishers to offer over 120,000 Christian ebooks" — Wikipedia.

> "250,000+ Christian books and courses, fully searchable, curated for [users'] needs." — logos.com homepage.

## Source notes

This is a **synthesis** drawing from: logos.com homepage, logos.com/compare, Wikipedia, community.logos.com (the official user wiki/forums — was reachable via redirect from wiki.logos.com), and prior-knowledge familiarity with the product (years of public marketing). Treat the per-tool feature lists as **indicative not exhaustive** — Logos ships dozens of smaller tools (Concordance, Word Tree, Speaker Histogram, Visual Filters, Workflows, Workspaces) that aren't covered here. A complete catalog would need to scrape community.logos.com/Logos_Features (which exists as a structured feature index) and Logos's own help center.
