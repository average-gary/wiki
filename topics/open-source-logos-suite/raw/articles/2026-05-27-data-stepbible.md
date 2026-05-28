---
title: "STEPBible-Data (Tyndale House)"
source_url: "https://github.com/STEPBible/STEPBible-Data"
type: article
path: data
date_ingested: 2026-05-27
date_published: unknown
tags: [biblical-data, licensing, hebrew, greek, lexicon, morphology, cc-by]
quality: 5
confidence: high
summary: "Tyndale House's STEPBible data — TAHOT (Hebrew morph), TAGNT (Greek morph), TBESH/TBESG/TFLSJ lexicons, proper names, versification — all CC BY 4.0. Likely the most underrated free dataset in the space."
---

# STEPBible-Data

## Key findings
- **License**: CC BY 4.0 across the board. Single attribution: "STEP Bible" linked to STEPBible.org.
- **Format**: tab-separated text — drop-in for spreadsheets, pandas, SQL.
- **Lexicons**: TBESH (Hebrew brief), TBESG (Greek brief), **TFLSJ** (free Liddell-Scott-Jones derivative — clean LSJ alternative).
- **Morphology**: TAHOT for Hebrew, TAGNT for Greek — both with Strong's numbers.
- **Tagged Bibles**: includes ESV-tagged data (the ESV text itself is still Crossway's, but the tagging layer is free).
- **Proper names** database with genealogy/references.
- **Versification mapping** across Bible versioning traditions — solves the Psalm-numbering, deuterocanon-ordering, MT-vs-LXX-vs-Vulgate alignment problem.

## Notable quotes / specifics
- "Includes the data in software or publications without requesting permission, provided they credit 'STEP Bible' linked to www.STEPBible.org."
- TFLSJ matters because Perseus LSJ is CC BY-SA (copyleft); TFLSJ is CC BY (permissive) — easier to embed.

## Source notes
- This is the strategic dataset: covers everything OSHB+MorphGNT cover, plus lexicons, plus versification, all under one permissive license.
- Recommended baseline for any greenfield Logos-alternative.
