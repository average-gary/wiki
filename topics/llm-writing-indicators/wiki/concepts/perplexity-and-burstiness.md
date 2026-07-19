---
title: Perplexity & burstiness — the statistical signature
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, statistics, perplexity, burstiness, detection]
sources:
  - raw/articles/2026-07-13-gptzero-perplexity-burstiness.md
  - raw/papers/2026-07-13-mitchell-detectgpt.md
  - raw/papers/2026-07-13-hans-binoculars.md
  - raw/papers/2026-07-13-liang-detectors-biased-nonnative.md
---

# Perplexity & burstiness

Beneath the visible tells sits the statistical signature that automated detectors actually measure. Understanding it explains both why detection works at all and why it fails.

## Perplexity — how "surprised" a model is

[[../../raw/articles/2026-07-13-gptzero-perplexity-burstiness|Perplexity]] measures how predictable text is to a reference language model: "how likely an AI model would have chosen the exact same set of words." LLMs pick high-probability tokens, so their output has **low perplexity** — it is exactly what the model expected. Human writing is more surprising (higher perplexity). GPTZero's rough heuristic: perplexity above ~85 suggests human.

[[../../raw/papers/2026-07-13-mitchell-detectgpt|DetectGPT]] formalized *why*: machine text sits in regions of **negative curvature** in the model's log-probability function — small rephrasings almost always lower its probability, whereas human text moves both ways.

## Burstiness — variance across the document

Humans vary: a short punchy sentence next to a long winding one, a surprising word amid ordinary ones. LLMs "formulaically use the same rule to choose the next word," yielding uniform local predictability = **low burstiness**. This is the statistical shadow of the [[structural-formulas|structural uniformity]] you can see with the naked eye.

## The state of the art: perplexity *ratios*

Naive single-model perplexity is confounded by the prompt (the "capybara problem": an exotic topic makes even machine text look surprising). [[../../raw/papers/2026-07-13-hans-binoculars|Binoculars]] fixes this with a **perplexity ÷ cross-perplexity** ratio between two models, hitting >90% detection at a 0.01% false-positive rate — the current SOTA. See [[../topics/detection-tools-and-limits|detection tools & limits]].

## Why this matters to a human reviewer

You cannot compute perplexity by eye, but you can recognize its symptoms: even rhythm, no surprising turns, predictable word choice. More importantly, knowing the mechanism reveals the **fatal flaw**: perplexity measures *predictability, not authorship*. [[../../raw/papers/2026-07-13-liang-detectors-biased-nonnative|Liang et al.]] showed detectors misclassify 61% of non-native TOEFL essays as AI precisely because those writers use predictable (low-perplexity) vocabulary — and the [[../../raw/articles/2026-07-13-false-positive-harm-turnitin-constitution|US Constitution reads as "AI"]] for the same reason. Low perplexity is a property of formal, formulaic, and second-language human writing too.

## See also

- [[../topics/detection-tools-and-limits|Detection tools & limits]]
- [[../topics/false-positives-and-fairness|False positives & fairness]]
- [[why-llms-write-this-way|Why LLMs write this way]]
