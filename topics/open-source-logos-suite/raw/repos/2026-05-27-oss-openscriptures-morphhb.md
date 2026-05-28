---
title: "Open Scriptures Hebrew Bible (morphhb)"
source_url: "https://github.com/openscriptures/morphhb"
type: repo
path: oss
date_ingested: 2026-05-27
date_published: 2021-12-13
tags: [oss, bible-software, open-scriptures, osis, hebrew, morphology, cc-by]
quality: 4
confidence: high
summary: "Open Scriptures' OSHB is the canonical CC-BY-licensed morphologically-tagged Hebrew Bible in OSIS XML. Excellent data, but core release frozen since Dec 2021 — effectively a stable archive, not an active project."
---

# Open Scriptures Hebrew Bible (morphhb)

## Key findings
- The Open Scriptures Hebrew Bible (OSHB) is a tagged Hebrew OT in **OSIS XML** with lemma + morphology markup keyed to augmented Strong's numbers and unique immutable per-word IDs.
- Underlying text: Westminster Leningrad Codex (WLC), public domain. Open Scriptures' added value is the lemma/morphology tagging layer.
- License split: WLC text is **public domain**; the lemma/morphology overlay is **CC BY 4.0** — easy to reuse in OSS or commercial.
- Latest release: **OSHB v2.2 on 2021-12-13.** 319 commits total. Effectively a maintained but slow-moving archive.
- Sister projects under the openscriptures GitHub org cover Greek (morphgnt-style), versification, and OSIS tooling, though activity is uneven across them.

## Notable quotes / specifics
> "Lemma and morphology data use Creative Commons Attribution 4.0 International. The underlying text (WLC) remains in the public domain."

> "OSHB Version 2.2 dated December 13, 2021, with 319 total commits."

## Source notes
- **Maintainer**: Open Scriptures community (originally founded by Weston Ruter; the live README didn't surface him, but it's well-documented in the project's history).
- **Last active**: Core data 2021; minor commits and issues continue but no major release in 4+ years.
- **License**: CC BY 4.0 (overlay) + public domain (text).
- **Format**: OSIS XML — the cleanest interchange format for biblical texts after USFM. OSIS is XML-based and great for indexing; USFM is markdown-like and great for translation workflows. Most OSS tools accept both.
- **What it does well**: Cleanest free morphologically-tagged Hebrew OT with permissive licensing. Stable IDs make it the right choice for cross-project linking.
- **Gaps**:
  - No corresponding maintained Greek NT under the same org with comparable activity (morphgnt is separate, James Tauber's work; SBLGNT is also a separate effort).
  - No tooling layer — it's data, not an app.
  - Stalled cadence raises the question of who fixes errata going forward.
- **Strategic read**: Use OSHB for Hebrew + a Greek tagged corpus (SBLGNT or morphgnt) + STEPBible-Data for lexicons. Together they form the open-data triad an OSS Logos competitor needs.
