---
title: "The SWORD Project (CrossWire Bible Society)"
source_url: "https://crosswire.org/sword/index.jsp"
type: article
path: oss
date_ingested: 2026-05-27
date_published: 2026-05-27
tags: [oss, bible-software, sword, crosswire, gpl, modules]
quality: 5
confidence: high
summary: "SWORD is the granddaddy OSS Bible engine: GPL C++ library, ~100 languages, hundreds of modules, and a fleet of frontends (BibleTime, Xiphos, Pocket Sword, Ezra, And Bible adjacent). Active in 2026."
---

# The SWORD Project (CrossWire Bible Society)

## Key findings
- CrossWire Bible Society's flagship project: a cross-platform, GPL-licensed engine for serving Bible texts, commentaries, lexicons, and reference works to client apps.
- Module catalog covers "many hundred texts in around 100 languages." Modules are the lingua franca of OSS Bible software — install once, read in any SWORD-compatible frontend.
- Active in 2026: Ezra Bible App 1.19 (March 2026), BibleTime 3.2.0 (February 2026). News page bears a 2026-05-27 timestamp.
- Frontends mentioned/known: BibleTime (Qt cross-platform), Xiphos (GTK/Linux), Pocket Sword (iOS), Ezra Bible App (Electron), Eloquent (macOS), PocketBible-style and Android wrappers.
- Diatheke is the SWORD project's command-line tool for querying installed modules — useful for scripting and pipeline integration but the homepage page didn't elaborate; verified separately as part of the SWORD utility suite.
- License: GNU GPL — strong copyleft. This is both the strength (huge module ecosystem builds on it) and a constraint for commercial reuse.

## Notable quotes / specifics
> "The SWORD Project is the CrossWire Bible Society's free Bible software project. Its objective is to create cross-platform open-source tools... to develop Bible software more efficiently."

> "A growing collection of many hundred texts in around 100 languages."

## Source notes
- **Maintainer**: CrossWire Bible Society, volunteer-run nonprofit, decades of operation.
- **Last active**: Active 2026 — frontend releases this year, news on homepage current.
- **Language**: Core library in C++; bindings exist for Java (JSword), Python, Perl.
- **License**: GPL (library and most utilities). Modules vary — some public domain, some copyrighted but freely distributable, some "lockable" pay-modules.
- **What it does well**: De-facto standard module format. Massive translation catalog. Cross-platform reach via frontends. Solid Hebrew/Greek and Strong's lexicon support.
- **Gaps vs. Logos**:
  - No syntactic/grammatical search (Logos has Cascadia/SBL syntactic search trees).
  - No sermon-builder or note-graph UI; notes live per-frontend, not as a unified personal library.
  - Visualizations (timelines, atlases, family trees) are minimal-to-absent.
  - Search is mostly lexical/Strong's; no semantic search, no AI-assisted Q&A.
  - Discoverability of modules is poor (raw repo browser); no curated study paths.
  - Frontends are fragmented — UX varies wildly between BibleTime, Xiphos, Pocket Sword.
- **Strategic read**: For a new OSS Logos competitor, SWORD is *the* substrate to build on for module/text delivery. The differentiation must come at the study-tool layer, not at the text-retrieval layer.
