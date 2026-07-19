---
title: Bible data sources — repos, APIs, topical datasets
type: tool
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, bible, data-sources, tools]
sources:
  - raw/articles/2026-06-23-bible-api-bible-pricing-tiers.md
  - raw/articles/2026-06-23-bible-esv-api-crossway-terms.md
  - raw/articles/2026-06-23-bible-commercial-translations-licensing.md
---

# Bible data sources

Practical tool catalog for sourcing Bible text and topical-tag data. See [[wiki/topics/bible-content-licensing|content licensing strategy]] for the legal layer; this is the *where to actually get the data* layer.

## Primary repos for offline-bundled public-domain text

### scrollmapper/bible_databases (GitHub)

- License: **MIT**.
- Coverage: ~140 translations bundled as SQLite, JSON, XML, CSV.
- Includes: KJV, WEB, ASV, YLT, BBE, multi-language editions.
- Pre-segmented by book/chapter/verse; works offline with no API call.
- **Recommended primary source for v1 KJV + WEB.**

### wldeh/bible-api (GitHub)

- License: MIT.
- Coverage: 200+ versions across many languages.
- JSON-formatted; easy to bundle.
- Some translations may have downstream licensing constraints despite repo presence — verify per-translation before redistribution.

### Crossway ESV API (api.esv.org)

- License: free for non-commercial mobile apps; commercial requires Crossway organizational license.
- Rate limits: 5,000 queries/day, 1,000/hr, 60/min. Cache up to 500 verses/device.
- Per [[../raw/articles/2026-06-23-bible-esv-api-crossway-terms|ESV API terms]].
- **v2 path**: ship ESV via API once entity exists.

### API.Bible (American Bible Society)

- Pricing: **Starter $0** (5k calls/mo, no commercial use, no freemium); **Pro $29+/mo** (150k calls/mo, copyrighted Bibles ~$10/mo each).
- Per [[../raw/articles/2026-06-23-bible-api-bible-pricing-tiers|API.Bible pricing]].
- **Critical**: Starter explicitly forbids ANY monetization on the calling app, including freemium. His Words on Starter is policy-incompatible.
- **v2.5 path**: API.Bible Pro for NIV, NLT, NKJV.

## Topical-tag datasets

### openbible.info topical Bible

- License: **CC-BY 4.0**.
- Coverage: ~10,000+ topics, vote-ranked by community input.
- Format: bulk download as CSV / JSON; mappings of topic → list of verse references.
- **Recommended primary source for v1 topical taxonomy.**

For an MVP, do not ship the full 10k-topic surface. Curate ~20-30 high-leverage topics (anxiety, hope, marriage, grief, forgiveness, gratitude, doubt, etc.) and manually shortlist ~10-30 verses per topic. The curated shortlist is the credibility moat (per [[wiki/decisions/2026-06-24-no-ai-generated-content|no-AI decision]]).

## Audio Bible sources (defer to v2+)

- Crossway ESV audio (subject to ESV license).
- Faith Comes By Hearing (FCBH) — partner license required.
- Public-domain KJV audio (LibriVox, multiple recordings of varying quality).

His Words v1 is text-only. Audio is v2+ if engagement data warrants it.

## Reference Bible / commentary

- **Public-domain commentaries**: Matthew Henry, Charles Spurgeon (Treasury of David), Adam Clarke, Albert Barnes — all public domain.
- **Reformed confessions**: Westminster, Heidelberg, Three Forms of Unity — all public domain.
- **Book of Common Prayer**: 1662 BCP fully public domain; modern revisions (2019 ACNA) are proprietary.

For v3+ "verse + commentary card" feature, public-domain Spurgeon / Henry is the cleanest source.

## What NOT to use

- Wikipedia translation samples (incomplete, not source-of-truth).
- Bible Gateway scraped HTML (terms forbid scraping; HarperCollins-owned).
- LLM-generated translations or paraphrases (theologically and legally risky).
- BibleHub scraped content (similar terms-of-service issue).

## Data preparation checklist for v1

1. Pull KJV from scrollmapper/bible_databases (MIT).
2. Pull WEB from same repo.
3. Cross-validate against ebible.org (separate publisher of WEB).
4. Run a script to verify completeness: 31,102 verses for KJV (66 books).
5. Pull openbible.info CC-BY topical mapping CSV.
6. Curate ~25 topics, ~15 verses per topic = ~375-400 curated verse references.
7. Bundle as SQLite into the app binary; load on first launch.
8. Surface attribution: "Topical mappings from openbible.info, CC-BY 4.0."

## Cross-references

- [[wiki/topics/bible-content-licensing|content licensing]] — legal strategy.
- [[wiki/reference/bible-translation-licensing-matrix|licensing matrix]] — translation × license × cost.
- [[wiki/concepts/topical-verse-categorization|topical categorization]] — how the topical layer is used.
