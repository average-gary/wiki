---
title: AI slop & the durable structural tells
type: topic
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, slop, structure, playbook]
sources:
  - raw/papers/2026-07-13-shaib-measuring-ai-slop.md
  - raw/articles/2026-07-13-language-flattening-sciam-zme.md
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
  - raw/articles/2026-07-13-em-dash-discourse-rollingstone-techcrunch.md
---

# AI slop & the durable structural tells

As lexical and punctuation tells decay ([[../concepts/model-and-version-drift|drift]]), the tells that survive are structural and content-level — what practitioners call "AI slop." This playbook consolidates the durable signals for the long term.

## Defining slop

[[../../raw/papers/2026-07-13-shaib-measuring-ai-slop|Shaib et al.]] operationalized "AI slop" from 19 expert interviews as text that is "generic, overly verbose, inaccurate, irrelevant," across three dimensions:
- **Information Utility** — does it actually help / say anything?
- **Information Quality** — is it accurate and grounded?
- **Style Quality** — repetition, **templatedness**, verbosity, tone.

Crucially, slop is *hard* to detect automatically: human inter-annotator agreement was κ = −0.15 to 0.29, and **GPT-5 scored 0.14 precision / 0.11 recall** at flagging slop spans. This is a human-judgment problem.

## The durable tells (survive drift and paraphrasing)

1. **Templatedness / structural formulas** — the formulaic intro→symmetric-body→restated-conclusion, the "Challenges and Future Directions" closer, over-signposting. See [[../concepts/structural-formulas|structural formulas]]. A paraphraser changes words, not skeleton.
2. **Verbosity / low information density** — many words, little content.
3. **Vagueness / no specifics / no lived experience** — the deepest tell. Rolling Stone's editors named it directly: "the absence of original ideas." See [[../concepts/vagueness-and-missing-specifics|vagueness & missing specifics]].
4. **Uniformity** — even rhythm, even emphasis, no idiosyncratic edges (the visible face of low [[../concepts/perplexity-and-burstiness|burstiness]]).
5. **Register flatness** — [[../concepts/sycophancy-and-positivity-register|relentless positivity]], no strong stance, false balance.

## Why these outlast the lexical tells

The [[../../raw/articles/2026-07-13-language-flattening-sciam-zme|language-flattening]] literature shows the *words* (delve, realm) are diffusing into human writing at 25–50%/year, so lexical tells lose power. But the deeper properties — no original ideas, no specific knowledge, templated structure — a model cannot fake, because it never had the underlying experience or expertise. A "humanizer" can swap vocabulary and delete em dashes; it cannot supply what the model doesn't know.

## The reviewer's durable question

When the surface tells are ambiguous or scrubbed, fall back to: **"Does this text know anything specific and true, argued with a real point of view — or is it fluent, structured, agreeable content about nothing?"** That question ages well.

## See also

- [[../concepts/structural-formulas|Structural formulas]]
- [[../concepts/vagueness-and-missing-specifics|Vagueness & missing specifics]]
- [[reviewer-checklist|Reviewer checklist]]
