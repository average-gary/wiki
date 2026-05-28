---
title: "STEP Bible (Tyndale House) and STEPBible-Data"
source_url: "https://github.com/STEPBible/STEPBible-Data"
type: article
path: oss
date_ingested: 2026-05-27
date_published: 2026-05-27
tags: [oss, bible-software, step-bible, tyndale-house, lexicon, morphology, cc-by]
quality: 5
confidence: high
summary: "STEP Bible is Tyndale House Cambridge's web-based study Bible with tagged Hebrew/Greek, lexicons, morphology, and proper-noun database, all CC-BY licensed. Strong scholarly data, dated UI, data updates lagged after 2021."
---

# STEP Bible (Tyndale House) and STEPBible-Data

## Key findings
- STEP = Scripture Tools for Every Person. Free web app at stepbible.org, also downloadable for offline use; runs on a Java backend originally from Tyndale House Cambridge, a respected biblical-studies research institute.
- Underlying scholarly datasets are published on GitHub (STEPBible/STEPBible-Data) under **CC BY 4.0** — this is the most reusable Hebrew/Greek tagged data outside of paywalled academic sets.
- Dataset includes: tagged Greek NT, tagged Hebrew OT, tagged ESV, expanded Strong's-based Hebrew & Greek lexicons, morphology codes with explanations, proper-noun database (with genealogy), versification tables, SWORD-compatible modules.
- App features: multiple translations (incl. ESV), cross-references, footnotes, Harmony of the Gospels, miracle/prophet topical lists, grammar annotation, multilingual UI via Crowdin.
- Translations crowdsourced through Crowdin — broad UI language support.

## Notable quotes / specifics
> "Data created initially by Tyndale House Cambridge" and now jointly maintained with STEPBible.org.

> "Use under CC BY 4.0... permitting use in software and publications without permission, provided proper attribution to 'STEP Bible' linked to www.STEPBible.org."

> Most recent data release dated **May 30, 2021** ("Data developed by Tyndale House up to 2021"), 1,168 commits total — repo shows ongoing maintenance but core scholarly data is frozen.

## Source notes
- **Maintainer**: Tyndale House Cambridge + STEPBible.org volunteer/staff team.
- **Last active**: Web app updated through 2026; **core tagged-data set last major release 2021** — modest drift risk for serious scholarly use.
- **License**: CC BY 4.0 on data. App code mixed; web client open enough to download and self-host.
- **What it does well**:
  - Best free, attribution-only tagged Hebrew/Greek dataset.
  - Lexicons and morphology with expanded explanations rather than raw codes.
  - Proper-noun + genealogy database is genuinely unique among free resources.
  - Versification mapping across traditions (Masoretic, LXX, Vulgate) — non-trivial to recreate.
- **Gaps vs. Logos**:
  - UI is dated (~2014-era web app feel); discoverability of features is poor.
  - No personal note system, no sermon prep, no integrated commentary library.
  - No syntactic search trees; morphology only.
  - No mobile-native app; mobile web works but isn't first-class.
  - Data updates have stalled since 2021 — risk of falling behind newer scholarship.
- **Strategic read**: STEPBible-Data should be a foundational ingest source for any OSS Logos competitor. Pair it with SWORD modules for translations, and you've got the academic data layer for free. UI/UX layer is where to differentiate.
