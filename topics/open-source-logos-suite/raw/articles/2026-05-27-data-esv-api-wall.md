---
title: "ESV API (Crossway) — Copyright Wall"
source_url: "https://www.esv.org/api/"
type: article
path: data
date_ingested: 2026-05-27
date_published: unknown
tags: [biblical-data, licensing, copyright-wall, esv, crossway, api]
quality: 5
confidence: high
summary: "ESV API is free for non-commercial personal/ministry use with strict caching, attribution, and modification limits. Commercial use is prohibited at the free tier — any monetized product needs a separate Crossway license."
---

# ESV API — Copyright Wall

## Key findings
- **Free tier**: personal, church, Christian-ministry use only.
- **Quotas**: 5,000 queries/day, 1,000/hour, 60/minute. Max 500 verses per query OR half a book (whichever smaller).
- **Caching**: ≤500 verses cached locally; ≤500 verses per page render.
- **Attribution**: "ESV" tag on every quote; link to esv.org on every page; standard copyright notice on dedicated copyright page.
- **Commercial restriction**: explicitly excludes sites that "motivate purchases, charge for services, solicit donations, or accept advertising." Even ad-supported free apps fail this test.
- **Modification**: forbidden. Cannot alter the text. Cannot create derivative works of the translation.
- **Doctrinal clause**: must respect Crossway's statement of faith — they reserve the right to revoke access at will.
- **Key sharing**: forbidden. One key per app/org.

## Notable quotes / specifics
- "Intended primarily for personal, church, and Christian ministry organization use."
- Crossway "reserves the right to revoke access" without warranty of service.

## Source notes
- This is the canonical hard wall. NIV (Biblica), NASB (Lockman), NLT (Tyndale), CSB (Holman) have similar or stricter regimes.
- For a commercial product wanting ESV: contact Crossway licensing — typical terms are per-user royalty + minimum guarantee, often requiring distribution review.
- Engineering implication: build the app text-agnostic. Default to WEB/PD, allow users to BYO an ESV key (shifts liability/license to user), or licensed offering as paid SKU.
- NET Bible is a friendlier paid path — translation notes and text both more permissive, though still not fully open. Berean Standard Bible (BSB) is fully free for any use including commercial — worth pairing as a "modern English" alternative to WEB.
