---
title: "STEPBible-Data — Tagged Hebrew/Greek Bible Datasets (TAHOT, TAGNT)"
source_url: "https://github.com/STEPBible/STEPBible-Data"
type: repo
path: client
date_ingested: 2026-05-27
date_published: 2025-01-01
tags: [client, architecture, search, hebrew, greek, morphology, lemma]
quality: 5
confidence: high
summary: "STEPBible publishes the canonical open Hebrew (TAHOT) and Greek (TAGNT) tagged Bible texts with disambiguated Strong's, full morphology, and Robinson/OpenScriptures codes — CC BY 4.0. The de-facto open-source corpus for original-language search."
---

# STEPBible-Data — Tagged Hebrew/Greek Bible Datasets

## Key findings

- **TAHOT (Translators' Amalgamated Hebrew OT)**: every word, prefix, and suffix tagged with disambiguated Strong's numbers + full morphological + semantic tags. Backward-compatible with original Strong's numbering. Hebrew morphology follows **OpenScriptures format**, similar to Westminster codes used in BibleWorks. Includes sequential-perfective and gentilic distinctions.
- **TAGNT (Translators' Amalgamated Greek NT)**: every word from NA27/28, TR, and major editions tagged with disambiguated Strong's linked to LSJ + morphology. Greek morphology uses **Robinson codes** (originated for the Majority Text). Distinguishes possessive pronouns and deponent forms.
- **Companion lexica**: TEHMC (Hebrew morph codes expanded) and TEGMC (Greek morph codes expanded) decode the morph strings into human-readable grammatical features.
- **Format**: plain UTF-8 text, **tab-separated fields**, spreadsheet-friendly. Records are one-line or multi-line with headers. This trivializes ETL into SQLite FTS5 or Tantivy — no parser required.
- **License: CC BY 4.0** — usable in any open- or closed-source software with attribution to "STEP Bible" and www.STEPBible.org. Critically permissive for an OSS Logos competitor.
- **Schema implication**: a verse-document model can store columns like `surface_form`, `lemma`, `strongs_disambig`, `morph_code`, `gloss`. FTS5 column-filtered queries (`MATCH 'lemma : agapao*'`) become a first-class query language.

## Notable quotes / specifics

- License recommended attribution: "STEP Bible" with link to www.STEPBible.org.
- TAHOT/TAGNT use disambiguated Strong's (e.g., G2424A vs G2424B) — important: a search engine must store both the canonical Strong's and the disambiguator to support legacy and modern queries.
- No mention of OSHB (Open Scriptures Hebrew Bible) compatibility specifics; OSHB is the parallel resource and its morphology format influenced TAHOT but the docs don't claim a direct mapping.

## Source notes

This is the **most important single dependency** for a Logos-style suite's original-language layer. Without STEPBible (or the comparable OSHB + MorphGNT pair), an OSS suite would need to negotiate licensing with proprietary publishers (Logos's moat). Combined with SQLite FTS5 + custom tokenizer (lemma + morph code as separate indexed fields), this corpus enables:

- "Show me all uses of *agapaō* (G25) within 5 words of *theos* (G2316) in the Pauline corpus" — NEAR query with column filter on lemma.
- "All hiphil imperfects of *yada*" — combined morph + lemma query.

Crucially: morph codes are a **string field**, not natively a structured query language. The suite needs an internal grammar/morph-code DSL that compiles to FTS5 MATCH expressions. This is one of the moat-extending pieces a plugin system could expose to denominational/scholarly extensions.
