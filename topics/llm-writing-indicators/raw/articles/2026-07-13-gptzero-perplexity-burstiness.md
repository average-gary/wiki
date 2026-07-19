---
title: "What is perplexity & burstiness for AI detection?"
source: https://gptzero.me/news/perplexity-and-burstiness-what-is-it/
author: GPTZero (Edward Tian et al.)
venue: GPTZero (2023–2024)
type: article
tags: [llm-writing-indicators, detection, perplexity, burstiness, mechanism]
quality: 4
confidence: high
ingested: 2026-07-13
summary: Clearest plain-language definition of the two core perplexity-based detection signals. Perplexity = how surprised a reference model is by the text (low = predictable = AI-ish); burstiness = how much perplexity/sentence-structure varies across the document (humans vary; LLMs are uniform → low burstiness). GPTZero uses a rough heuristic of perplexity > ~85 suggesting human.
---

# GPTZero — Perplexity & burstiness

**Quality: 4/5.** Vendor doc, but the clearest plain-language definition of the two core signals.

## Findings

- **Perplexity** = how surprised a reference model is by the text — operationally, "how likely an AI model would have chosen the exact same set of words," per sentence. Low perplexity = highly predictable = likely AI. Example: "Hi there, I am an AI ___" → "assistant" (low perplexity) vs "potato" (high, human-like). Token probabilities compound across the document.
- GPTZero heuristic: **perplexity above ~85 suggests human** writing.
- **Burstiness** = how much perplexity (and sentence structure/length) *varies across the whole document*. Humans vary sentence length and unpredictability (short punchy sentence next to a long winding one); LLMs "formulaically use the same rule to choose the next word" → "very consistent level of AI-likeness" = low burstiness.
- Mechanistic reason humans score higher on both: memory/attention introduce intentional variation and avoid self-repetition; next-token sampling produces uniform local predictability. Burstiness is GPTZero's differentiator for long-form documents.

## Tells explained

Uniform sentence rhythm / low variance → low burstiness; predictable word choice → low perplexity. Both flow from next-token likelihood maximization producing locally high-probability, globally uniform text.

## Why it matters for a reviewer

Explains the two metrics every perplexity-based detector rests on, and why AI prose reads "flat/even." But: these are exactly the signals that misfire on non-native and formulaic human writing (see Liang detector-bias paper).
