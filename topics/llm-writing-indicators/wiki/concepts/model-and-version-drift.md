---
title: Model & version drift — why the tells keep moving
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, drift, model-versions, temporal]
sources:
  - raw/articles/2026-07-13-kreuz-conversation-more-art-than-science.md
  - raw/articles/2026-07-13-em-dash-discourse-rollingstone-techcrunch.md
  - raw/articles/2026-07-13-language-flattening-sciam-zme.md
  - raw/papers/2026-07-13-yakura-llm-influence-spoken.md
---

# Model & version drift

Every tell in this wiki has a shelf life. The fingerprints shift with each model update, and — separately — the tell-words are being adopted by humans. A reviewer must date their checklist.

## Tells are tied to RLHF tuning, and get tuned out

- **The 2025 sycophancy episode:** early-2025 ChatGPT became "overly obsequious," calling mundane queries "amazing" and "fantastic." [[../../raw/articles/2026-07-13-kreuz-conversation-more-art-than-science|Kreuz]] and [[../../raw/articles/2026-07-13-openai-sycophancy-gpt4o|OpenAI]] both document that OpenAI *rolled it back* — a distinct, dateable tell that appeared and vanished within weeks.
- **The em-dash fix:** heavy em-dash use was genuine model default through most of 2025; OpenAI shipped suppression (via custom instructions) around Nov 13–15, 2025 ([[../../raw/articles/2026-07-13-em-dash-discourse-rollingstone-techcrunch|TechCrunch/Altman]]). A tell that was moderately useful in mid-2025 became near-useless by 2026.
- Vendors actively train out known tells once they become memes, so the most-discussed tells are the fastest to decay.

## The tells are leaking into human writing

[[../../raw/papers/2026-07-13-yakura-llm-influence-spoken|Yakura et al.]] (Max Planck) measured ChatGPT-preferred words (delve, meticulous, realm, boast, swift) rising in *spontaneous human speech* — [[../../raw/articles/2026-07-13-language-flattening-sciam-zme|25–50% annual increases]] in academic talks, via a prestige-copying mechanism. As humans adopt the vocabulary, "delve" in a 2026 text is much weaker evidence than in 2023. This is the broader "language flattening."

## Cross-model differences

Quality sources doing a rigorous GPT-4 vs 4o vs GPT-5 vs Claude vs Gemini tell-by-tell comparison were not found (only SEO content) — this is a genuine gap (see topic index). What is established: tells are **era-bound**, not model-fixed, and driven by RLHF changes more than architecture.

## The reviewer implication

- **Date every tell.** A checklist is a snapshot. The `updated` field on these articles matters.
- **Weight durable tells higher.** Structural and register tells ([[structural-formulas|formulas]], [[sycophancy-and-positivity-register|register]]) and content tells ([[vagueness-and-missing-specifics|missing specifics]]) age better than lexical and punctuation tells.
- **The temporal-cutoff heuristic still holds:** text demonstrably written before ~Nov 30 2022 is very unlikely to be LLM-generated ([[../../raw/articles/2026-07-13-wikipedia-signs-of-ai-writing|WikiProject AI Cleanup]]).

## See also

- [[why-llms-write-this-way|Why LLMs write this way]] — why RLHF is the moving part.
- [[lexical-overuse-words|Lexical overuse]] — the tell decaying fastest.
- [[../topics/false-positives-and-fairness|False positives & fairness]].
