---
title: Topical verse categorization
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: medium
tags: [his-words-app, content, personalization, taxonomy]
sources:
  - raw/articles/2026-06-23-competitors-psalmo.md
  - raw/articles/2026-06-23-bible-api-bible-pricing-tiers.md
  - raw/articles/2026-06-23-bible-esv-api-crossway-terms.md
  - raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md
---

# Topical verse categorization

The pause should serve a verse that is *relevant to the user's current state*, not a uniformly random selection from the canon. The mechanism is a topical taxonomy — anxiety, hope, marriage, grief, forgiveness, gratitude, doubt, etc. — that lets the user (or a default-rotating algorithm) match the moment to the text.

## Why topical, not random

[[../raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024|Haliburton CHI 2024]] explicitly identified content variation as a habituation slowdown lever: the same prompt every time accelerates dismissal; varied content sustains attention. Topical selection is one form of variation, and it is the one that makes the variation *personally meaningful* rather than merely novel.

[[../raw/articles/2026-06-23-competitors-psalmo|Psalmo]] ships **50+ verse categories** including anxiety, grief, gratitude, hope. This is the de-facto category-set for the niche. His Words should match or exceed this taxonomy.

## Source: openbible.info topical tags

The openbible.info project has published a CC-BY-licensed topical-verse mapping. Verses are tagged across hundreds of topics, vote-ranked by community input. This is the practical source for an MVP topical layer:

- License: CC-BY 4.0 — attribution required, derivative works permitted.
- Coverage: ~10,000+ topics, mapped to canonical references.
- Format: bulk download as CSV/JSON.

For an MVP, scope to **20-30 high-leverage topics** rather than the full 10,000 — anxiety, fear, depression, marriage, parenting, work, doubt, grief, forgiveness, hope, gratitude, peace, comfort, money, anger, patience, identity, suffering, joy, prayer, wisdom, weariness, rest, perseverance, friendship, conflict, temptation, calling. These map to the most-searched topics in YouVersion's public engagement data and to the categories Psalmo highlights.

## Curation, not just retrieval

A pure tag-based retrieval will produce uneven results: some topics return verses that are tangentially related rather than central. Recommendation:

1. Start with openbible.info raw tags.
2. Manually curate a **shortlist of ~10-30 verses per topic** for the MVP launch corpus.
3. Use the curated shortlist for default rotation; let power users browse the long tail later.

This is editorial work — not LLM work. See [[wiki/decisions/2026-06-24-no-ai-generated-content|decision: no AI-generated content]]. The curated shortlist *is* the credibility moat.

## Topical selection at runtime

Three modes, in order of sophistication:

1. **User-pinned topic**: user picks "anxiety" as the active topic; rotation pulls from that list. Simplest; gives the user agency.
2. **Day-of-week rotation**: Mon = peace, Tue = patience, etc. Eliminates choice fatigue.
3. **Adaptive (v2+)**: time of day, day of week, or limited contextual signals (e.g., user opens app at 11pm = "rest" topic). Avoid surveillance-feeling personalization; users will distrust it.

Default v1 should be option 2 (day-of-week), with option 1 available in settings. Adaptive is v2+ and should remain optional even then.

## Translation interaction

Topical lists collapse cleanly across translations: Psalm 23:1 is Psalm 23:1 in KJV, WEB, ESV, NIV. The topical layer is a *reference list*, not a text bundle. The text rendering is a separate layer.

This means topical curation is a one-time content effort that pays off across every translation His Words ever ships. See [[wiki/topics/bible-content-licensing|bible content licensing]] for the translation-tier strategy.

## Risk: thin theology of "topical"

Some confessional Protestants (Reformed, Lutheran) prefer canonical / sequential reading over topical sampling — the concern is that topical selection turns the Bible into a self-help concordance. Mitigation:

- Frame the topical layer as the *interrupt content*, not the primary reading mode.
- Offer canonical-sequential as an alternative mode (read through Proverbs / Psalms / a Gospel one verse at a time).
- Cite the historical Lectio Divina pattern of reading a single verse meditatively — that *is* topical-when-relevant Christian practice.

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — what the topical content fills.
- [[wiki/topics/bible-content-licensing|bible content licensing]] — the text layer below the taxonomy.
- [[wiki/tools/bible-data-sources|bible data sources]] — where the tag data comes from.
