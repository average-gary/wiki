---
title: "DetectGPT: Zero-Shot Machine-Generated Text Detection using Probability Curvature"
source: https://arxiv.org/abs/2301.11305
authors: Eric Mitchell, Yoonho Lee, Alexander Khazatsky, Christopher D. Manning, Chelsea Finn
venue: ICML 2023; arXiv:2301.11305
type: paper
tags: [llm-writing-indicators, detection, zero-shot, perplexity, probability-curvature]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Foundational zero-shot detection method. LLM text sits in regions of negative curvature in the model's log-probability function — small rephrasings almost always lower log-prob for machine text but move human text both ways. 0.95 AUROC on GPT-NeoX vs 0.81 for prior baselines. Explains why LLM text is statistically distinguishable at all. Fast-DetectGPT (ICLR 2024) is ~340× faster.
---

# Mitchell et al. — DetectGPT

**Quality: 5/5.** Foundational, heavily-cited detection method.

## Core insight & method

- LLM-generated text occupies regions of **negative curvature** in the model's log-probability function; human text does not. Small perturbations (rephrasings) of machine text almost always *lower* log-probability; perturbations of human text move it in both directions.
- **Method:** perturb the candidate passage many times (using a generic model like **T5**), then compare the original's log-prob to the average of the perturbed versions. Requires **no training, no classifier, no watermark, no dataset** — only log-prob access to the source model.
- **Performance:** on **GPT-NeoX (20B)** fake-news detection, **0.95 AUROC vs 0.81** for the strongest prior zero-shot baseline. Evaluated across GPT-2, GPT-J, GPT-NeoX, GPT-3.
- **Limitation:** needs log-prob access to the candidate model (white-box-ish); degrades under paraphrase attacks.

## Follow-up: Fast-DetectGPT

Bao, Zhao, Teng, Yang, Zhang; **ICLR 2024** (arXiv:2310.05130). Replaces the perturbation step with a **conditional probability curvature** sampling step: **~340× faster** and more accurate. Same probability-curvature principle, production-viable.

## Why it matters for a reviewer

Explains *why* LLM text is statistically distinguishable: machines pick high-probability tokens, yielding a flat / negative-curvature signature humans lack. This is the theoretical basis for the perplexity/burstiness intuitions reviewers lean on — while also implying the signal weakens as models and editing make text less predictable.
