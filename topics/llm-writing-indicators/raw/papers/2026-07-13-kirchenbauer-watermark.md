---
title: "A Watermark for Large Language Models"
source: https://arxiv.org/abs/2301.10226
authors: John Kirchenbauer, Jonas Geiping, Yuxin Wen, Jonathan Katz, Ian Miers, Tom Goldstein
venue: ICML 2023 (Outstanding Paper); arXiv:2301.10226
type: paper
tags: [llm-writing-indicators, watermarking, provenance, detection]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Award-winning landmark defining the dominant LLM-watermarking paradigm. Before each token, a hash of the previous token seeds a green/red split of the vocabulary; logits are softly biased toward green tokens. Detection is a z-test on green-token proportion, needing no model/API/prompt access, from as little as ~25 tokens. Diluted by paraphrasing.
---

# Kirchenbauer et al. — A Watermark for LLMs

**Quality: 5/5.** ICML 2023 Outstanding Paper; defines the dominant watermarking paradigm.

## Method — green/red list

- Before generating each token, a hash of the previous token seeds a pseudo-random split of the vocabulary into a **"green list"** and **"red list."** The model's logits are softly biased toward green-list tokens. Watermarked text therefore contains statistically **more green tokens than chance (~50%)** predicts.
- **Detection:** compute a **z-statistic** on the proportion of green tokens — needs **no access to the model, API, or prompt**. Detectable from **~25 tokens**; longer spans give overwhelming confidence.
- **Quality impact:** the "soft" watermark biases only low-entropy positions minimally, so perplexity/quality degradation is small.
- Tested on billion-parameter OPT models. **Known vulnerability: paraphrasing / heavy editing** dilutes the green-token signal.

## Why it matters for a reviewer

Watermarking is *proactive, opt-in provenance* — the "gold standard" future signal — but it only works if the *generating* model watermarks and the text isn't paraphrased. It does nothing to detect arbitrary already-published prose, so it doesn't help a reviewer facing unlabeled text today.
