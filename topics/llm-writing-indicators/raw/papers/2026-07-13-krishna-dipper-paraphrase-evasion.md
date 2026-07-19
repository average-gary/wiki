---
title: "Paraphrasing Evades Detectors of AI-Generated Text, but Retrieval is an Effective Defense (DIPPER)"
source: https://arxiv.org/abs/2303.13408
authors: Kalpesh Krishna, Yixiao Song, Marzena Karpinska, John Wieting, Mohit Iyyer
venue: NeurIPS 2023; arXiv:2303.13408
type: paper
tags: [llm-writing-indicators, detection-limits, paraphrase-evasion, adversarial]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Built DIPPER, an 11B-parameter paraphraser that rewrites AI text preserving meaning. Drops DetectGPT accuracy from 70.3% to 4.6% at a 1% false-positive rate, and evades watermarking, GPTZero, and OpenAI's classifier. A retrieval defense (storing ~15M prior generations) recovers 80–97% but requires the provider to log every generation.
---

# Krishna et al. — DIPPER paraphrase evasion

**Quality: 5/5.** Peer-reviewed (NeurIPS 2023); precise numbers.

## Findings

- **DIPPER**: an **11-billion-parameter** paraphraser that rewrites AI text while preserving meaning ("without appreciably modifying the input semantics").
- Headline: DIPPER **drops DetectGPT's detection accuracy from 70.3% to 4.6%** at a fixed **1% false-positive rate**.
- Paraphrasing evaded **watermarking, DetectGPT, GPTZero, and OpenAI's classifier** — every major detector class.
- Their proposed defense (a **retrieval** approach storing ~**15 million** prior generations) recovers only **80–97%** detection, and requires the LLM API provider to log every generation — impractical for third-party reviewers and privacy-fraught.

## Why it matters for a reviewer

A single cheap paraphrasing pass erases the tells entirely. Detection catches the naive and the honest-but-formulaic, not the determined bad actor — an adverse-selection failure. Absence of tells means nothing; the text may have been paraphrased.
