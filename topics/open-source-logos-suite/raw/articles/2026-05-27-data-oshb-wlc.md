---
title: "Open Scriptures Hebrew Bible (OSHB) / Westminster Leningrad Codex"
source_url: "https://hb.openscriptures.org/"
type: article
path: data
date_ingested: 2026-05-27
date_published: unknown
tags: [biblical-data, licensing, public-domain, hebrew, lexicon, morphology]
quality: 5
confidence: high
summary: "OSHB ships the Westminster Leningrad Codex Hebrew text (public domain) plus morphology and lemma data under CC BY 4.0 in OSIS XML — the canonical free Hebrew Bible stack."
---

# Open Scriptures Hebrew Bible (OSHB) / WLC

## Key findings
- WLC text itself is in the **public domain** (no attribution required).
- Lemma + morphology data is **CC BY 4.0** — must credit "Open Scriptures Hebrew Bible".
- Format is **OSIS XML**, the standard for Bible software interchange.
- Includes morphology codes, Strong's numbers, and cantillation marks (te'amim).
- Distributed via GitHub: `github.com/openscriptures/morphhb` (text+morph) and `github.com/openscriptures/HebrewLexicon` (lexicon glue).
- Companion tools OSHB Read (morph viewer) and OSHB Verse (cantillation visualizer) demonstrate the data model.

## Notable quotes / specifics
- "Lemma and morphology data are licensed under a Creative Commons Attribution 4.0 International" license; "the text of the WLC remains in the Public Domain."
- Morphology codes documented separately in repo (covers Hebrew/Aramaic POS, person, gender, number, state, stem, etc.).

## Source notes
- This is THE base layer for any open Hebrew OT product. No copyright wall.
- Ship-ready: clone repo, attribute OSHB for morph data, KJV/WEB for English alignment.
- Combine with STEPBible TAHOT for cleaner morphology and Strong's mapping.
