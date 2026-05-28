---
title: "Public Free Bible APIs: bible-api.com and wldeh/bible-api"
source_url: "https://bible-api.com/"
type: article
path: oss
date_ingested: 2026-05-27
date_published: 2026-05-27
tags: [oss, bible-software, api, json, public-domain, mit]
quality: 4
confidence: high
summary: "Two leading free Bible JSON APIs: Tim Morgan's bible-api.com (18 versions, 8 langs, hobby-grade reliability) and wldeh/bible-api (200+ versions, MIT, CDN-served via jsDelivr). Both serve only public-domain texts."
---

# Public Free Bible APIs: bible-api.com and wldeh/bible-api

## Key findings

### bible-api.com (Tim Morgan)
- Free JSON API for Bible passages. Source on GitHub: **seven1m/bible_api**.
- **18 translations across 8 languages**: KJV, WEB (default), ASV, Darby, YLT, plus Chinese, Czech, Portuguese, Romanian, Latin, Cherokee.
- **Rate limit: 15 requests / 30 seconds** per IP. Hobby project, no SLA.
- Maintainer explicitly discourages downloading whole Bibles via API — points users to the open data on GitHub.
- License: public-domain or freely-licensed translations only. App code is open enough to self-host.

### wldeh/bible-api
- More ambitious successor. **MIT-licensed**, claims "200+ versions and languages," aspirational target of 300+.
- Served as static JSON via **jsDelivr CDN** — no rate limiting, no server to maintain. URL pattern: `https://cdn.jsdelivr.net/gh/wldeh/bible-api/bibles/{version}/books/{book}/chapters/{chapter}/verses/{verse}.json`
- 479 stars, 119 forks, 29 open issues. Activity timeline not visible from README; community-driven.

## Notable quotes / specifics
> "15 requests every 30 seconds (based on IP address)... a hobby project with no availability guarantees." — bible-api.com

> "Lightning-fast response times... uses public domain Bible versions without copyright restrictions." — wldeh/bible-api

## Source notes
- **What they do well**:
  - Zero-friction access. Drop a fetch call into any prototype.
  - CDN-served (wldeh) means infinite scale on someone else's dime.
  - MIT license (wldeh) is unbeatable for permissiveness.
- **Gaps**:
  - **Public-domain translations only**. No NIV, ESV, NLT, NASB, CSB, NRSV. This is the recurring ceiling on free Bible APIs.
  - No morphology, no lemmas, no Strong's, no commentary.
  - bible-api.com has no SLA; wldeh relies on jsDelivr's free CDN — neither is enterprise-grade.
  - No search endpoint of substance; passage retrieval only.
- **Strategic read**: Free APIs solve "give me a verse" trivially. They do not solve "help me study a verse." For an OSS Logos competitor, treat them as a fallback delivery mechanism, not as a feature. The interesting differentiation is everything *above* verse retrieval.
