---
title: Lexical overuse — the "delve/underscore/tapestry" vocabulary
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, lexical, vocabulary, delve]
sources:
  - raw/papers/2026-07-13-kobak-excess-vocabulary-pubmed.md
  - raw/papers/2026-07-13-liang-peer-reviews-ai-modified.md
  - raw/papers/2026-07-13-juzek-ward-why-delve.md
  - raw/articles/2026-07-13-berenslab-excess-words-dataset.md
---

# Lexical overuse — the AI vocabulary

The best-evidenced single indicator. A cluster of words is measurably over-represented in post-ChatGPT text, and their frequencies jumped abruptly and simultaneously in late 2022 — a signature no gradual human trend produces.

## The hard numbers

[[../../raw/papers/2026-07-13-kobak-excess-vocabulary-pubmed|Kobak et al.]] analyzed all ~15.3M PubMed abstracts (2010–2024) and measured each word's 2024 frequency against a counterfactual extrapolated from pre-ChatGPT years:

| Word | Excess ratio (2024 freq ÷ expected) |
|---|---|
| `delves` | ≈ 28× |
| `underscores` | ≈ 10.9× |
| `showcasing` | ≈ 10.2× |

[[../../raw/papers/2026-07-13-liang-peer-reviews-ai-modified|Liang et al.]] found the same pattern in ML-conference peer reviews on an entirely independent corpus: `meticulous` ×34.7, `intricate` ×11.2, `commendable` ×9.8. **Two unrelated corpora converging on the same word list is the strongest empirical claim in this whole topic.**

[[../../raw/papers/2026-07-13-juzek-ward-why-delve|Juzek & Ward]] pinned exact rates: "delves" rose from 0.21 per million words (2020) to 14.38 (2024) — roughly a 6,700% jump.

## The part-of-speech flip

The deeper signal is not any one word but a *category shift*. Before LLMs, excess words in scientific text were content nouns (driven by topics — "covid," "pandemic"). In 2024 they flipped to **style words: verbs, adjectives, adverbs** (delve, showcase, underscore, intricate, meticulous, notably, comprehensive, pivotal, realm). Kobak found 319 excess style words for 2024, 66% verbs and 16% adjectives. The flip itself is the tell.

## The quick-scan set

For a reviewer eyeballing prose, the highest-signal words are the rare, high-ratio ones: **delve, underscore, showcasing, intricate, pivotal, realm, boasts, meticulous, tapestry, testament, leverage, harness, seamless, multifaceted, nuanced, comprehensive.** The full ~900-word bank is in [[../reference/overused-words-and-phrases|overused words & phrases]].

## The catch

- **One hit is nothing.** Every one of these is a legitimate English word. The signal is *density* — many of them clustered in a short passage — not a single occurrence. See [[../topics/false-positives-and-fairness|false positives & fairness]].
- **The signal is decaying.** These words are now bleeding into human speech and writing at 25–50%/year (see [[model-and-version-drift|drift]] and [[../../raw/papers/2026-07-13-yakura-llm-influence-spoken|Yakura et al.]]). "Delve" in a 2026 document is weaker evidence than it was in 2023.
- **It flags non-native writers and formal registers unfairly** — "delve" is common in Nigerian English and academic prose predating ChatGPT.

## Why it happens

Traced to RLHF preference-tuning, not architecture or training data — preference-trained models are measurably *less surprised* by buzzword-laden text than their base versions ([[../../raw/papers/2026-07-13-juzek-ward-why-delve|Juzek & Ward]]). See [[why-llms-write-this-way|why LLMs write this way]].

## See also

- [[formulaic-phrases|Formulaic phrases]] — the multi-word cousin of this tell.
- [[puffery-and-significance-inflation|Puffery & significance inflation]] — where these words cluster.
- [[../reference/overused-words-and-phrases|Reference: overused words & phrases]].
