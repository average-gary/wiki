---
title: The empirical evidence base — are the tells real?
type: topic
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, evidence, corpus-studies, playbook]
sources:
  - raw/papers/2026-07-13-kobak-excess-vocabulary-pubmed.md
  - raw/papers/2026-07-13-liang-peer-reviews-ai-modified.md
  - raw/papers/2026-07-13-liang-scientific-papers-mapping.md
  - raw/papers/2026-07-13-juzek-ward-why-delve.md
  - raw/papers/2026-07-13-yakura-llm-influence-spoken.md
---

# The empirical evidence base

Are the tells folklore or fact? For the lexical tells specifically, the evidence is unusually strong — multiple large, independent corpora converge. This article separates what's measured from what's anecdotal.

## What is solidly measured

**Vocabulary shift is real and large.** [[../../raw/papers/2026-07-13-kobak-excess-vocabulary-pubmed|Kobak et al.]] (all 15.3M PubMed abstracts, *Science Advances*) found an abrupt post-ChatGPT spike in style words — `delves` ×28, `underscores` ×10.9, `showcasing` ×10.2 — whose magnitude *exceeded the COVID pandemic's* effect on scientific vocabulary. Lower bound: **≥13.5% of 2024 abstracts** were LLM-processed, up to ~40% in some subcorpora.

**It replicates across independent corpora.** [[../../raw/papers/2026-07-13-liang-peer-reviews-ai-modified|Liang et al.]] found the same adjective signature in ML peer reviews (`meticulous` ×34.7, `intricate` ×11.2), estimating 6.5–16.9% LLM-modified. [[../../raw/papers/2026-07-13-liang-scientific-papers-mapping|A companion study]] of 950k papers found CS highest (~17.5%), Math lowest (~6.3%). **Different teams, different corpora, same word list** — the strongest claim available.

**Prevalence anchors** (quote these):
- ≥13.5% of 2024 PubMed abstracts (Kobak).
- 6.5–16.9% of AI-conference review sentences (Liang).
- Up to 17.5% of CS paper sentences (Liang).
- "delves" per-million: 0.21 (2020) → 14.38 (2024), ~6,700% ([[../../raw/papers/2026-07-13-juzek-ward-why-delve|Juzek & Ward]]).

## What is established about mechanism

The "delve" spike is **RLHF-driven**, per [[../../raw/papers/2026-07-13-juzek-ward-why-delve|Juzek & Ward]]: they found no evidence for architecture/algorithm/training-data causes but found preference-tuned models measurably *less surprised* by buzzword-laden text. See [[../concepts/why-llms-write-this-way|why LLMs write this way]].

## What is contested or folklore

- **The "Nigerian-English annotators → delve" story** is a *plausible-but-unconfirmed* hypothesis (Hern/Willison, April 2024), and Juzek & Ward's ICE-corpus test **does not support** it. The RLHF-labor reporting is real; the specific dialect link is not established. Don't present it as fact.
- **Em dashes** as a tell are weak and contested (see [[../concepts/em-dash-and-punctuation|em-dash]]).
- **Human intuition** is at chance ([[../../raw/papers/2026-07-13-jakesch-human-heuristics-flawed|Jakesch et al.]], ~50%).

## The decay caveat

[[../../raw/papers/2026-07-13-yakura-llm-influence-spoken|Yakura et al.]] (Max Planck, 740k hours of speech) show the tell-words are leaking into human *speech* at 25–50%/year. The evidence that the tells *were* real is strong; the evidence that they *remain* diagnostic weakens every year. This is the core tension a reviewer holds: real signal, decaying value. See [[../concepts/model-and-version-drift|model & version drift]].

## See also

- [[../reference/corpus-study-citations|Reference: corpus-study citations]]
- [[../concepts/lexical-overuse-words|Lexical overuse]]
- [[false-positives-and-fairness|False positives & fairness]]
