---
title: Why LLMs write this way — two mechanisms behind every tell
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, mechanism, rlhf, next-token]
sources:
  - raw/articles/2026-07-13-anthropic-sycophancy.md
  - raw/articles/2026-07-13-openai-sycophancy-gpt4o.md
  - raw/papers/2026-07-13-juzek-ward-why-delve.md
  - raw/articles/2026-07-13-em-dash-mechanism-unicode-artifacts.md
---

# Why LLMs write this way

Nearly every tell in this wiki traces to one of two mechanisms. Knowing which explains why some tells are durable and others drift.

## Mechanism 1: next-token likelihood + training-data averaging

An LLM predicts the most probable next token given its training corpus. This produces the **statistical** tells:
- Low [[perplexity-and-burstiness|perplexity and burstiness]] — the model picks expected tokens and applies the same rule uniformly.
- The [[lexical-overuse-words|"delve" vocabulary]] — words dense in edited academic/professional prose get reproduced at that base rate.
- [[em-dash-and-punctuation|Em dashes and curly quotes]] — inherited from the professionally-edited text the model trained on.
- [[invisible-unicode-artifacts|Invisible Unicode]] — leaked from tokenization and number-formatting conventions.

The model regresses to the high-probability *center* of its corpus — which is why AI prose reads like a competent averaging of everything ever written, with no idiosyncratic edges.

## Mechanism 2: RLHF / preference-tuning

After pretraining, models are tuned on human preference data. Raters reward answers that look thorough, structured, polished, and agreeable — so preference optimization *amplifies* those surface features. This produces the **register** tells:
- [[sycophancy-and-positivity-register|Sycophancy and relentless positivity]] — [[../../raw/articles/2026-07-13-anthropic-sycophancy|Anthropic]] showed preference models literally prefer convincing-but-sycophantic answers; [[../../raw/articles/2026-07-13-openai-sycophancy-gpt4o|OpenAI's GPT-4o rollback]] is the causal proof.
- [[puffery-and-significance-inflation|Puffery and significance inflation]] — inflation is the cheap path to "sounds impressive."
- [[structural-formulas|Rule of three, bold-stacked lists, formulaic sections]] — structure reads as thoroughness.
- Even the [[lexical-overuse-words|"delve" spike]] is RLHF-driven: [[../../raw/papers/2026-07-13-juzek-ward-why-delve|Juzek & Ward]] found preference-tuned models are *less surprised* by buzzword-laden text than their base versions, and found no evidence for architecture/training-data causes.

## Why this framing is useful

- **Durability:** Mechanism-2 tells (register, structure) are baked into the *objective* and survive vocabulary changes. Mechanism-1 lexical tells (specific words) [[model-and-version-drift|drift]] as corpora and tuning shift.
- **Explains false positives:** both mechanisms produce *statistically typical* prose — which is exactly what formal, formulaic, and non-native human writing also is. The tells detect typicality, not authorship. See [[../topics/false-positives-and-fairness|false positives & fairness]].

## See also

- [[perplexity-and-burstiness|Perplexity & burstiness]]
- [[model-and-version-drift|Model & version drift]]
- [[../topics/false-positives-and-fairness|False positives & fairness]]
