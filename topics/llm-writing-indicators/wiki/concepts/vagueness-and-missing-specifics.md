---
title: Vagueness & missing specifics — the absence tell
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, content, vagueness, hallucination]
sources:
  - raw/papers/2026-07-13-shaib-measuring-ai-slop.md
  - raw/papers/2026-07-13-liang-peer-reviews-ai-modified.md
  - raw/articles/2026-07-13-em-dash-discourse-rollingstone-techcrunch.md
---

# Vagueness & missing specifics

The deepest and most durable tell is not a word or a mark — it is what the text *lacks*. LLM prose tends to be confidently general, low in concrete detail, and devoid of lived experience. Rolling Stone's editors, dismissing the em-dash panic, named the real signal: "the flat quality, the formulaic sentences, **the absence of original ideas**."

## What to look for

- **No specific numbers, names, dates, or citations** where a knowledgeable human would supply them. [[../../raw/papers/2026-07-13-liang-peer-reviews-ai-modified|Liang et al.]] found LLM-heavy peer reviews specifically lacked scholarly citations (`et al.`) and engaged less with specifics.
- **Confident generality** — claims that sound authoritative but could apply to almost anything ("plays an important role in modern society").
- **No lived detail** — no anecdote, sensory specific, or first-hand observation that a real practitioner would include.
- **Low information density / verbosity** — many words conveying little. [[../../raw/papers/2026-07-13-shaib-measuring-ai-slop|Shaib et al.]] make verbosity and low information utility defining dimensions of AI "slop."
- **Fabricated specifics** — when an LLM *does* supply a citation, statistic, or quote, it may be invented. Broken DOIs, page-less book citations, and sources that don't say what they're cited for are high-value tells (see [[citation-and-fact-anomalies|citation & fact anomalies]]).

## Why it matters

This is the tell that survives paraphrasing, model drift, and vocabulary changes. A "humanizer" tool can strip em-dashes and swap out "delve," but it cannot inject the specific knowledge and lived detail the model never had. When lexical tells are ambiguous, ask: *does this text know anything specific, or is it fluent about nothing?*

## Caveat

Plenty of human writing is also vague and generic — junior writers, content-mill SEO, corporate boilerplate. Vagueness raises suspicion; it does not prove authorship. Weight it alongside the other tells and, above all, verify the factual claims.

## See also

- [[citation-and-fact-anomalies|Citation & fact anomalies]]
- [[../topics/ai-slop-and-structural-tells|AI slop & structural tells]]
- [[../topics/reviewer-checklist|Reviewer checklist]]
