---
title: "OpenBible.info Cross-References (TSK-derived)"
source_url: "https://www.openbible.info/labs/cross-references/"
type: article
path: data
date_ingested: 2026-05-27
date_published: unknown
tags: [biblical-data, licensing, cross-references, tsk, cc-by]
quality: 4
confidence: high
summary: "~340,000 cross-references (~2 MB zip) under CC BY, derived primarily from the public-domain Treasury of Scripture Knowledge plus topical/community contributions. The standard open cross-reference dataset."
---

# OpenBible.info Cross-References

## Key findings
- **License**: Creative Commons Attribution (CC BY) — must credit OpenBible.info.
- ~**340,000** cross-references; downloadable as a single ~2 MB zip.
- Sourced primarily from **Treasury of Scripture Knowledge (TSK)** — itself public domain (1830s).
- Augmented with OpenBible.info's Topical Bible and Twitter Bible Search community signal.
- Format: simple TSV (from-ref, to-ref, votes/score) — trivial to load.
- Includes a "votes" / popularity score so you can threshold to top-N references per verse.

## Notable quotes / specifics
- "Download all the cross-reference data (2 MB .zip)."
- Cross-references are version-agnostic (book/chapter/verse), so they layer on top of WEB, ESV, NET, KJV, etc.

## Source notes
- TSK-only (no community votes) is fully PD if you want to drop attribution — but OpenBible.info's curated/scored version is significantly more useful.
- Pair with public-domain TSK directly (e.g., from CCEL or eBible.org) if you need belt-and-suspenders PD-only sourcing.
- Critical UX feature for any Bible study product — chain references are how serious study works.
