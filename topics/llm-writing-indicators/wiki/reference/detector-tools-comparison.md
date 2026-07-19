---
title: "Reference: detector tools comparison"
type: reference
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, reference, detectors, tools]
sources:
  - raw/papers/2026-07-13-mitchell-detectgpt.md
  - raw/papers/2026-07-13-hans-binoculars.md
  - raw/papers/2026-07-13-kirchenbauer-watermark.md
  - raw/papers/2026-07-13-krishna-dipper-paraphrase-evasion.md
  - raw/articles/2026-07-13-pangram-how-detection-works.md
  - raw/articles/2026-07-13-gptzero-perplexity-burstiness.md
  - raw/articles/2026-07-13-detector-arms-race-vanderbilt-openai-mit.md
---

# Reference: detector tools comparison

Quick-reference table. Full analysis in [[../topics/detection-tools-and-limits|detection tools & limits]]. **No tool listed here is reliable enough to be a verdict.**

| Tool / method | Approach | Reported performance | Key weakness |
|---|---|---|---|
| **GPTZero** | Perplexity + burstiness (single model) | Heuristic (perplexity >~85 → human) | Over-flags non-native & formal writers; false positives on human essays (Dik 2025) |
| **DetectGPT** | Probability curvature (perturb & compare) | 0.95 AUROC on GPT-NeoX | Needs model log-prob access; paraphrase drops it to 4.6% (DIPPER) |
| **Fast-DetectGPT** | Conditional curvature sampling | ~340× faster than DetectGPT, higher accuracy | Same paraphrase vulnerability |
| **Binoculars** | Perplexity ÷ cross-perplexity (2 models) | >90% TP @ 0.01% FP, zero-shot | Research tool; still evadable by heavy paraphrase |
| **Pangram** | Trained transformer classifier | Claims ~99.99% (self-reported) | Black box; benchmark self-reported; classifier-era-specific |
| **Turnitin** | Trained classifier | Marketed <1% FP | Admitted ~4% sentence FP; disabled by Vanderbilt et al. |
| **Originality.ai / ZeroGPT / Crossplag / Sapling** | Classifier / perplexity | Vendor claims | Flagged 61% of non-native essays (Liang); ZeroGPT called US Constitution "AI" |
| **OpenAI AI Text Classifier** | Trained classifier | 26% TP / 9% FP | **Discontinued Jul 2023** for low accuracy |
| **Watermarking** (Kirchenbauer) | Green/red token biasing at generation | Detectable from ~25 tokens, no model access | Opt-in only; defeated by paraphrase; useless on arbitrary text |

## Cross-cutting facts

- **Theoretical ceiling:** best-possible detector AUROC → 0.5 as models improve ([[../../raw/papers/2026-07-13-sadasivan-can-ai-text-be-detected|Sadasivan et al.]]).
- **Evasion:** [[../../raw/papers/2026-07-13-krishna-dipper-paraphrase-evasion|DIPPER]] paraphrasing collapses detection; light editing drops 14-tool accuracy to 42% ([[../../raw/articles/2026-07-13-detector-arms-race-vanderbilt-openai-mit|MIT Tech Review]]).
- **Bias:** perplexity-based tools systematically over-flag non-native, formal, and neurodivergent human writers.
- **Constant retraining:** GPTZero claims retraining across "15 model releases in 2025" — a treadmill against [[../concepts/model-and-version-drift|drift]].

## Bottom line

Use as one weak input, prefer interpretable methods, never as proof — especially against non-native writers or in high-stakes settings. See [[../topics/false-positives-and-fairness|false positives & fairness]].
