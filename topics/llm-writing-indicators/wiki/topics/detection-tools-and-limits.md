---
title: Detection tools & their limits — why reliable detection is hard
type: topic
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, detection, tools, limits, playbook]
sources:
  - raw/papers/2026-07-13-mitchell-detectgpt.md
  - raw/papers/2026-07-13-hans-binoculars.md
  - raw/papers/2026-07-13-kirchenbauer-watermark.md
  - raw/papers/2026-07-13-krishna-dipper-paraphrase-evasion.md
  - raw/papers/2026-07-13-sadasivan-can-ai-text-be-detected.md
  - raw/articles/2026-07-13-gptzero-perplexity-burstiness.md
  - raw/articles/2026-07-13-pangram-how-detection-works.md
  - raw/articles/2026-07-13-detector-arms-race-vanderbilt-openai-mit.md
---

# Detection tools & their limits

What automated detectors do, how they work, and why none of them is trustworthy enough to be a verdict.

## The four families

| Family | How it works | Examples | Strength / weakness |
|---|---|---|---|
| **Perplexity/burstiness** | One reference model scores predictability & its variance | [[../../raw/articles/2026-07-13-gptzero-perplexity-burstiness|GPTZero]] | Interpretable; prompt-sensitive; biased against low-perplexity human writing |
| **Probability curvature** | Perturb text, compare log-prob | [[../../raw/papers/2026-07-13-mitchell-detectgpt|DetectGPT]], Fast-DetectGPT | Zero-shot; needs model log-prob access; degrades under paraphrase |
| **Perplexity ratio (2-model)** | perplexity ÷ cross-perplexity | [[../../raw/papers/2026-07-13-hans-binoculars|Binoculars]] | SOTA zero-shot: >90% TP @ 0.01% FP; normalizes prompt difficulty |
| **Trained classifier** | Supervised transformer on human/AI corpus | [[../../raw/articles/2026-07-13-pangram-how-detection-works|Pangram]], Originality.ai, Turnitin | Lowest claimed FP (hard-negative mining); black box; self-reported |

**Watermarking** ([[../../raw/papers/2026-07-13-kirchenbauer-watermark|Kirchenbauer et al.]]) is a separate, *proactive* approach: the generating model biases token choice toward a pseudo-random "green list," detectable by a z-test from ~25 tokens with no model access. Gold standard for provenance — but only works if the generator opts in and the text isn't paraphrased. Useless for arbitrary published prose.

## Why detection is fundamentally hard

1. **Theoretical ceiling.** [[../../raw/papers/2026-07-13-sadasivan-can-ai-text-be-detected|Sadasivan et al.]]: as LLMs improve, human and AI text distributions converge, driving the best-possible detector's AUROC toward **0.5 (a coin flip)**. Better models make detection *harder*, not easier.
2. **Trivial evasion.** [[../../raw/papers/2026-07-13-krishna-dipper-paraphrase-evasion|DIPPER]] paraphrasing dropped DetectGPT from **70.3% → 4.6%** at 1% FP, defeating every major detector. [[../../raw/articles/2026-07-13-detector-arms-race-vanderbilt-openai-mit|MIT Tech Review]]: 14 tools fell from 74% on raw ChatGPT to **42%** on lightly-edited text.
3. **Spoofing.** Sadasivan et al. also showed adversaries can make *human* text trip watermark detectors — weaponizing false accusations.
4. **The vendor's own admission.** OpenAI **shut down its own classifier** (26% true-positive, 9% false-positive) as too inaccurate.

## How to use detectors responsibly

- As **one weak input**, never a verdict. A "98% AI" score is not evidence.
- Understand the FP profile: perplexity tools over-flag non-native and formal writers ([[false-positives-and-fairness|false positives & fairness]]).
- Prefer **interpretable** signals you can inspect (Binoculars-style, or the human tells in this wiki) over black-box percentages.
- In high stakes, corroborate with non-stylistic evidence (metadata, version history, admission, fabricated sources).

## The gap this creates

Because automated detection is unreliable and evadable, and because [[../../raw/papers/2026-07-13-shaib-measuring-ai-slop|even GPT-5 can't reliably flag slop]], **calibrated human review remains the tool** — which is what the rest of this wiki equips. But human review must respect the same limits: it detects typicality, not authorship.

## See also

- [[false-positives-and-fairness|False positives & fairness]]
- [[../concepts/perplexity-and-burstiness|Perplexity & burstiness]]
- [[reviewer-checklist|Reviewer checklist]]
