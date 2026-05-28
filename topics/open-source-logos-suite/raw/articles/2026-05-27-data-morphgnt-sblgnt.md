---
title: "MorphGNT / SBL Greek New Testament"
source_url: "https://github.com/morphgnt/sblgnt"
type: article
path: data
date_ingested: 2026-05-27
date_published: unknown
tags: [biblical-data, licensing, greek, morphology, sblgnt]
quality: 5
confidence: high
summary: "MorphGNT pairs the SBLGNT Greek text (custom SBL EULA — non-commercial-leaning) with morphological parsing under CC-BY-SA. Best free morph-tagged Greek NT, but check SBL EULA before commercial shipment."
---

# MorphGNT / SBLGNT

## Key findings
- **Text license**: SBLGNT EULA (custom, not a standard open license). Free for personal/scholarly use; commercial redistribution requires permission from SBL/Logos.
- **Morphology license**: CC-BY-SA — viral, requires share-alike for derivatives.
- 7-column TSV: ref, POS, parsing code, surface text w/ punctuation, surface w/o, normalized form, lemma.
- Encodes person, tense, voice, mood, case, number, gender, degree.
- GitHub: `github.com/morphgnt/sblgnt`.

## Notable quotes / specifics
- "The SBLGNT text follows the SBLGNT EULA"; "morphological parsing and lemmatization are available under CC-BY-SA License."
- The SBL EULA is the gotcha — many products embed SBLGNT without realizing it forbids selling the text as the primary product.

## Source notes
- For commercial / freely-redistributable Greek NT, prefer **Byzantine Majority Text (Robinson-Pierpont, public domain)** or **Tyndale House STEPBible TAGNT (CC BY 4.0)** instead.
- CC-BY-SA on morph data is a copyleft trap — downstream apps must release derived morph data under same license.
