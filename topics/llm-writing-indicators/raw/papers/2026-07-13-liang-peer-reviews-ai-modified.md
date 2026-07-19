---
title: "Monitoring AI-Modified Content at Scale: A Case Study on the Impact of ChatGPT on AI Conference Peer Reviews"
source: https://arxiv.org/abs/2403.07183
authors: Weixin Liang, Zachary Izzo, Yaohui Zhang, Haley Lepp, Hancheng Cao, Xuandong Zhao, Lingjiao Chen, Haotian Ye, Sheng Liu, Zhi Huang, Daniel A. McFarland, James Y. Zou
venue: ICML 2024; arXiv:2403.07183 (2024)
type: paper
tags: [llm-writing-indicators, corpus-study, peer-review, adjectives, distributional-estimation]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Stanford distributional-estimation study of AI-modified text in ML-conference peer reviews. 6.5–16.9% of review sentences post-ChatGPT were substantially LLM-modified. Signature adjectives spiked hugely (meticulous ×34.7, intricate ×11.2, commendable ×9.8). Higher AI usage correlated with rushed, low-confidence, low-specificity reviews.
---

# Liang et al. — AI-modified content in peer reviews

**Quality: 5/5.** Peer-reviewed (ICML 2024), large-scale primary data, novel distributional method. Independently corroborates Kobak's adjective list on a *different corpus*.

## Method

- **Distributional / maximum-likelihood estimation**: rather than classify individual documents, estimate the *fraction* of a corpus produced/substantially modified by an LLM, by fitting token/word-usage distributions against reference human vs. AI corpora. More robust than per-document detectors.

## Key findings

- **Headline: 6.5%–16.9%** of sentences in post-ChatGPT reviews were substantially LLM-modified. Per venue: **EMNLP 2023 = 16.9%**, **ICLR 2024 = 10.6%**, **NeurIPS 2023 = 9.1%**, **CoRL 2023 = 6.5%**. Near-zero before ChatGPT.
- **Signature adjectives (fold-increase in per-sentence occurrence):** `meticulous` **×34.7**, `intricate` **×11.2**, `commendable` **×9.8**. The "Top 100 adjectives/adverbs disproportionately used by AI" tables include commendable, meticulous, intricate, notable, versatile, innovative, comprehensive, invaluable, pivotal, noteworthy, seamless; adverbs meticulously, thoroughly, seamlessly, notably.
- **Behavioral correlates of higher AI usage:** reviews submitted **within ~3 days of the deadline**; reviewers reporting **low confidence (≤2/5)**; reviews that were **less specific** and engaged less with author rebuttals.
- **Negative signal:** reviews containing scholarly citations (`et al.`) showed *lower* AI-modification estimates — LLM reviews tend to lack specific references.

## Why it matters for a reviewer

Corroborates the Kobak word list on an independent corpus, and maps the *behavioral contexts* where LLM text concentrates: rushed, low-confidence, low-specificity, citation-poor writing. Those contexts are themselves a meta-tell.
