---
title: "scrollmapper/bible_databases"
source_url: "https://github.com/scrollmapper/bible_databases"
type: repo
path: oss
date_ingested: 2026-05-27
date_published: unknown
tags: [oss, bible-software, scrollmapper, mit, sql, json, translations, cross-references]
quality: 4
confidence: high
summary: "Scrollmapper packages 140 Bible translations as MySQL/SQLite/CSV/JSON/YAML/MD with cross-references — MIT license. The default 'just give me Bible text in a database' resource for hackers."
---

# scrollmapper/bible_databases

## Key findings
- Repository of **140 Bible translations** in many database/text formats: MySQL, SQLite, CSV, JSON, YAML, TXT, Markdown.
- Cross-reference table sourced from **OpenBible.info** — another important free resource for inter-verse linking.
- **MIT licensed** — the most permissive in this landscape. Trivial to embed in any project, OSS or commercial, without copyleft concerns.
- Translations span ancient (Geneva 1599, KJV) to modern (Berean Standard Bible). Covers English, French, German, Spanish, Russian, Chinese, Japanese, Greek, Hebrew, more.
- 1.6k stars, 516 forks — popular, used in many downstream projects.
- Schema includes books, verses, translations, cross-references. 2024 legacy branch retained; 2025 schema is current.

## Notable quotes / specifics
> "140 Bible translations across numerous languages, spanning from classical versions like the King James Version and Geneva Bible (1599) to modern translations such as the Berean Standard Bible."

> "Cross-reference database sourced from OpenBible.info."

## Source notes
- **Maintainer**: scrollmapper (GitHub user, individual project lead).
- **Last active**: Recent — schema rewrite in 2025 indicates active stewardship.
- **License**: MIT for the repo; individual translations carry their own copyright (mostly public-domain or freely-redistributable; commercial translations like ESV/NIV are NOT here).
- **What it does well**:
  - Trivially embeddable. SQLite file = drop-in Bible engine.
  - Cross-references included by default — this saves serious work.
  - Permissive license is rare in this space.
- **Gaps**:
  - No morphology, no lemmas, no Strong's tagging. Pair with STEPBible-Data or OSHB for that layer.
  - No commentaries, no lexicons.
  - No copyrighted modern English translations (NIV, ESV, NLT, CSB) — that's a license issue, not a project flaw, but it's a real gap for Western users.
  - No commentary on text-critical decisions (uses what each translation publishes).
- **Strategic read**: This is the right "bootstrap" data layer for a new OSS Bible app — fastest path to "user can read 140 translations on day 1." Commercial translations remain the unsolved licensing problem for everyone in OSS Bible-tooling.
