---
title: "Why LLMs overuse em-dashes, and invisible Unicode artifacts as tells"
source: https://medium.com/@raj-srivastava/how-llms-turned-the-em-dash-into-a-villain-technical-nuances-b564857adc3b
authors: Raj Srivastava (Medium); Clemens Jarnach
venue: Medium (2025) + clemensjarnach.github.io (24 Apr 2025)
type: article
tags: [llm-writing-indicators, em-dash, unicode, typography, mechanism, watermark-myth]
quality: 3
confidence: medium
ingested: 2026-07-13
summary: Explains why LLMs overuse em-dashes (training-data base rate in edited prose + RLHF polish reward + speculative tokenization efficiency) and catalogs invisible Unicode characters that leak into ChatGPT output (NBSP U+00A0, zero-width space U+200B, ZWNJ/ZWJ U+200C/D, BOM U+FEFF, narrow NBSP U+202F). Invisible chars are near-deterministic tells; em-dashes/curly quotes are weak base-rate tells.
---

# Em-dash mechanism + invisible Unicode artifacts

**Quality: 3/5.** Medium post (reasoned but hedged) + a concrete Unicode companion.

## Why LLMs overuse em-dashes (three proposed causes)

- **Training-data inheritance (strongest):** em-dashes are dense in the professionally-edited prose LLMs train on — classic literature (Dickens, Dickinson), modern fiction, journalism, academia. Next-token likelihood reproduces that base rate. (Grammar Girl: em-dashes appear "because they were in the training data, which was written by humans.")
- **RLHF reinforcement:** raters reward the polish/rhythm em-dashes create → preference-tuning amplifies an already-elevated base rate (same mechanism as sycophancy, applied to punctuation).
- **Tokenization (speculative):** the em-dash's 3-byte UTF-8 sequence may merge into a single BPE token, giving an efficiency edge; flagged as unproven.
- **Limitation:** models learn the statistical *association* between em-dashes and "good writing" with no grammatical understanding → overuse in wrong contexts, often space-surrounded. Curly/smart quotes leak by the same base-rate mechanism.

## Invisible Unicode artifacts (Jarnach)

- Characters appearing in ChatGPT output: **U+00A0** non-breaking space, **U+200B** zero-width space, **U+200C/U+200D** zero-width (non-)joiners, **U+FEFF** byte-order mark; also **U+202F** narrow no-break space (common around numbers/units, French typography).
- Assessed as **artifacts, not deliberate watermarks** — inherited from training data and tokenization/number-formatting conventions.
- **Detection:** trivial to reveal with a script flagging each character by line/column, rendering as `[NBSP]`/`[ZWSP]`. Near-zero false positives when present — humans essentially never type U+200B/U+FEFF by hand.

## Why it matters for a reviewer

Em-dashes and smart quotes are *base-rate* tells (weak individually — many humans use them — stronger in aggregate/context). Invisible Unicode characters are **near-deterministic** tells because humans almost never insert them manually. Combined with leaked markup tokens (`oaicite`, `turn0search0`), these are the highest-confidence deterministic signals available.
