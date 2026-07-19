---
title: "How AI Detection Works (Pangram Labs)"
source: https://www.pangram.com/research/how-it-works
author: Pangram Labs
venue: Pangram Labs; backing report arXiv:2402.14873 (2024)
type: article
tags: [llm-writing-indicators, detection, trained-classifier, hard-negative-mining]
quality: 4
confidence: medium
ingested: 2026-07-13
summary: Represents the trained-classifier detection paradigm (vs perplexity). A transformer classifier trained on ~1M documents, using hard-negative mining (folding its own false positives back into training) and synthetic "mirror" prompts (matched AI/human pairs) to key on AI-specific signatures rather than topic/style. Claims near-zero false-positive rate — but it's a black box and figures are self-reported.
---

# Pangram — How AI detection works

**Quality: 4/5.** Vendor doc + backing arXiv report; represents the trained-classifier paradigm.

## Findings

- Architecture: a **trained transformer classifier**, not a perplexity score. Text → token embeddings → neural net → classifier head outputs 0 (human) / 1 (AI).
- Trained on ~**1 million documents** of public + licensed human text plus AI content from GPT-4 and similar.
- **Hard-negative mining:** actively searches datasets for the classifier's own false positives and folds those back into training, iterating toward claimed ~99.999%.
- **Synthetic "mirror" prompts:** for each human doc, generate an AI example matched on topic/length/style, forcing the classifier to learn *AI-specific* signatures rather than surface style/topic differences.
- Positions itself **beyond perplexity** — learned semantic/linguistic patterns, targeting a "near-zero false positive rate."

## Why it matters for a reviewer

The dominant modern approach (supervised classifier + adversarial data curation) can beat perplexity detectors on false-positive rate — but it's a **black box**, and accuracy claims are on its own benchmarks. Contrast with Binoculars (zero-shot, interpretable) and GPTZero (perplexity/burstiness). No single human-readable tell — the classifier learns a distributed fingerprint.
