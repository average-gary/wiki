---
title: "GPT detectors are biased against non-native English writers"
source: https://arxiv.org/abs/2304.02819
authors: Weixin Liang, Mert Yuksekgonul, Yining Mao, Eric Wu, James Zou
venue: Patterns (Cell Press), 2023; arXiv:2304.02819
type: paper
tags: [llm-writing-indicators, detection-limits, false-positives, non-native-english, perplexity, bias]
quality: 5
confidence: high
ingested: 2026-07-13
summary: The definitive bias finding. 7 GPT detectors misclassified 61.22% of non-native TOEFL essays as AI (vs ~5% for native US 8th-grade essays); 97.8% flagged by ≥1 detector. Mechanism is perplexity — non-native writers use predictable vocabulary → low perplexity → falsely flagged. Prompting ChatGPT to "elevate" the essays' vocabulary removed the misclassification.
---

# Liang et al. — Detectors biased against non-native writers

**Quality: 5/5.** Peer-reviewed (Patterns / Cell Press), most-cited primary source on detector bias. The single strongest datapoint against confident detection.

## Method & findings

- Tested **7 detectors:** Originality.AI, Quil.org, Sapling, OpenAI's classifier, Crossplag, GPTZero, ZeroGPT.
- **91 human-written TOEFL essays** (non-native): **61.22% average false-positive rate**; **97.8%** flagged by at least one detector; **19.78% (18 essays) unanimously** flagged by all 7.
- **88 US 8th-grade essays** (native): near-perfect accuracy, only **5.19%** average false positives.
- **Mechanism = perplexity.** Detectors treat low perplexity (predictable word choice) as an AI signal. Non-native writers have lower lexical diversity / syntactic range → low perplexity → falsely flagged. Zou: perplexity "correlates with the sophistication of the writing — something in which non-native speakers are naturally going to trail their U.S.-born counterparts."
- **The inversion:** prompting ChatGPT to rewrite the TOEFL essays to "enhance word choices to sound more like that of a native speaker" *raised* perplexity and dropped the false-positive rate to **11.77%** (a 49.5% reduction), only 1.10% unanimously flagged. **Sophisticated vocabulary evades detectors; simple predictable prose gets falsely flagged.**

## Why it matters for a reviewer

Perplexity-based detection is unreliable and discriminatory. It inverts a naive heuristic: "fancy vocabulary" evades detectors while plain/formulaic human writing gets flagged. Never treat detector output as ground truth, especially against non-native writers. Authors explicitly warn against deploying detectors in evaluative/educational settings.
