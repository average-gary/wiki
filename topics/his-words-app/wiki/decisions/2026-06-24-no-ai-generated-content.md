---
title: "Decision: no AI-generated content — scripture only"
type: decision
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, decision, content, theology, positioning]
sources:
  - raw/articles/2026-06-23-competitors-prayer-lock.md
  - raw/articles/2026-06-23-competitors-bible-mode.md
  - raw/articles/2026-06-23-competitors-faithlock-variants.md
  - raw/articles/2026-06-23-competitors-hallow-and-adjacents.md
  - raw/articles/2026-06-23-competitors-psalmo.md
---

# Decision: no AI-generated content

**Decision**: His Words ships **canonical scripture text only**. No AI-generated prayers. No AI Bible chat companion. No LLM-summarized devotionals. No AI mood-matched reflection generators. The verse the user sees at minute 5 is exactly what the human translators committed to print, no model interpolation.

This is the cleanest credibility moat available against a market in which every competitor ships AI content.

## Context

Per [[../raw/articles/2026-06-23-competitors-prayer-lock|Prayer Lock]], [[../raw/articles/2026-06-23-competitors-bible-mode|Bible Mode]], [[../raw/articles/2026-06-23-competitors-faithlock-variants|FaithLock variants]], [[../raw/articles/2026-06-23-competitors-psalmo|Psalmo]] (premium tier), and [[../raw/articles/2026-06-23-competitors-hallow-and-adjacents|Bible Chat / Creed]]:

- Prayer Lock's core mechanic is mood-input → AI-generated "Bible-rooted" prayer.
- Bible Mode ships a separate "Bible Chat" AI companion.
- FaithLocked, Faith Lock (Evolve AI), Faith Lock (Markovic) all advertise AI-personalized prayers or AI reflection companions.
- Psalmo's premium tier includes AI prayer and reflection generation.
- Creed (Lemon Tree Labs) and Bible Chat (Book Vitals) are AI-Bible-companion products at scale (30k-340k ratings).

**Every meaningful competitor ships AI content.** The category convergence is total.

## Rationale

### 1. Theological credibility moat for the Reformed/confessional segment

Reformed, Lutheran, and broader confessional Protestant audiences distrust LLM-generated religious content. The concerns are not silly:

- LLMs interpolate plausibility, not orthodoxy. A model trained on the open internet will generate prayers that subtly contradict confessional theology without flagging the contradiction.
- The historical Christian discipline of *prayer* is communion with God; an LLM prayer is not the user's prayer, nor is it a fellow believer's prayer. It is a statistical artifact dressed in scriptural diction.
- The Reformed framing — *sola scriptura* — explicitly elevates canonical text over derivative spiritual products. AI-generated devotionals violate this sensibility.

This audience (~30-40M in the US per [[wiki/reference/christian-app-market-snapshot|market snapshot]]) is over-indexed for the digital-wellness use case AND has zero good options in the current market. They are the cleanest audience-product fit.

### 2. Marketing differentiation that does not depreciate

"No AI" is uniquely durable as a marketing claim because:

- AI features in competitors will only proliferate (no one is *removing* AI prayers).
- The trust deficit around AI content will only deepen as model output saturates.
- Christian buyers increasingly distrust AI in religious contexts (per general 2024-2026 polling on AI + religion).
- The claim does not require iteration; "we ship what the translators wrote" is true at v1, v5, v10.

Compare this to feature-claim differentiation (Strict Mode, coin economy, sheep gamification, Bible Chat) — every one is rapidly cloned. "No AI" is not cloneable; you either ship it or you don't.

### 3. Technical and legal simplicity

Shipping AI content costs in three dimensions that "no AI" does not pay:

- **Latency**: model inference adds 1-5s per request. The shield must render instantly.
- **Cost**: per-call inference costs add ~$0.001-0.01 per interrupt. At scale (1M interrupts/day), this is non-trivial operating cost.
- **Liability**: model output is the operator's responsibility. A theologically-wrong prayer the LLM generates is *His Words'* prayer in user perception. No insurer will cover this.
- **Privacy**: every AI prayer call leaks user mood / context to the model provider. "No data collection" positioning is incompatible with model API usage.

### 4. Reactance reduction

Per [[wiki/concepts/psychological-reactance-and-rebound|reactance]]: prompts that *diagnose* the user's mood ("you seem distracted today, here is a prayer for that") activate defensiveness. Mood-matched AI prayers run exactly this risk. Static, topical, user-selected scripture is autonomy-supportive in a way that adaptive AI content fundamentally is not.

## What "no AI" specifically forbids

- LLM-generated prayers (Prayer Lock's core mechanic).
- AI Bible chat companion (Bible Mode, Bible Chat, Creed).
- AI mood-matched devotional selection.
- LLM-generated commentary or summaries.
- AI-generated cover art / thumbnails for verses (visible model output).
- Any feature where model inference is in the critical path of user-facing content.

## What "no AI" does NOT forbid

- Algorithmic verse rotation (deterministic — pick from curated list by date / topic).
- Search using non-LLM matching (lexical search over verse text).
- Recommendation features that use simple heuristics (time-of-day → topic mapping).
- Spam filtering / abuse detection in user-generated content (if v3+ ships any).
- Internal LLM use for *operations* (drafting marketing copy, summarizing user feedback) — out of user surface.

The line is: **anything the user sees as "from His Words" must be human-curated canonical text.**

## Risks accepted

- **Smaller addressable audience**: AI-curious users will prefer Prayer Lock / Creed. We lose them. Acceptable given the differentiation moat.
- **Slower personalization**: cannot offer "verse for your specific mood today" beyond user-selected topical buckets. Acceptable.
- **Marketing pressure**: VCs / advisors will push for AI features. Hold the line.

## Risks rejected

- **"AI is necessary for personalization."** False. Topical taxonomy + user-selected categories deliver real personalization without LLM inference.
- **"AI prayers help users who don't know how to pray."** Theologically: a sample written prayer (human-authored, in the public domain — Book of Common Prayer, Spurgeon's Morning and Evening) does this without LLM. Ship a curated human-written prayer collection instead.

## Cross-references

- [[wiki/topics/positioning-and-differentiation|positioning]] — differentiator 3.
- [[wiki/topics/mvp-feature-set|MVP]] — explicit non-features.
- [[wiki/concepts/topical-verse-categorization|topical categorization]] — the human-curated alternative.
- [[wiki/concepts/psychological-reactance-and-rebound|reactance]] — why "diagnose-and-respond" content backfires.
