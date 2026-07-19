---
title: False positives & fairness — the limits of tell-based judgment
type: topic
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, false-positives, fairness, bias, ethics]
sources:
  - raw/papers/2026-07-13-liang-detectors-biased-nonnative.md
  - raw/articles/2026-07-13-false-positive-harm-turnitin-constitution.md
  - raw/articles/2026-07-13-detector-arms-race-vanderbilt-openai-mit.md
  - raw/papers/2026-07-13-jakesch-human-heuristics-flawed.md
---

# False positives & fairness

The single most important thing a reviewer must internalize: **the tells detect statistical typicality, not authorship.** The humans most likely to be falsely flagged are the ones least able to afford it.

## The bias is measured, not hypothetical

[[../../raw/papers/2026-07-13-liang-detectors-biased-nonnative|Liang et al. (Patterns 2023)]] ran 7 detectors on human-written essays:
- **61.22%** of non-native TOEFL essays were misclassified as AI (vs **~5%** for native US 8th-grade essays).
- **97.8%** flagged by at least one detector; **19.78%** by all seven.
- Mechanism: non-native writers use predictable vocabulary → low [[../concepts/perplexity-and-burstiness|perplexity]] → read as machine.
- The perverse inversion: prompting ChatGPT to "elevate" the vocabulary *removed* the flag. **Sophisticated writing evades; plain honest writing gets caught.**

## Who else gets caught

- **Formal/legal/academic registers.** The **US Constitution** is rated "likely written entirely by AI" by GPTZero and ZeroGPT ([[../../raw/articles/2026-07-13-false-positive-harm-turnitin-constitution|folklore critique]]); Bible passages too. Formal, oft-quoted prose is low-perplexity.
- **Neurodivergent writers.** Margaret Mitchell: "humans can write with low perplexity, too, especially when imitating a formal style." Formulaic, structured human writing mimics the tells.
- **Anyone who legitimately writes with lists, em dashes, or tidy structure.**

## The human cost is real

- **Turnitin**: marketed <1% false positives; the vendor admitted **~4% at the sentence level**, document-level higher-but-undisclosed. At [[../../raw/articles/2026-07-13-detector-arms-race-vanderbilt-openai-mit|Vanderbilt's]] ~75,000 papers/year, even 1% = ~750 wrongful flags — so Vanderbilt disabled it.
- **Named students** falsely accused: Louise Stivers and William Quarterman (UC Davis) — investigations, grade harm, obligations to self-report to law schools/bar. Students now record hours of screen footage to prove innocence.

## Two cognitive traps for the reviewer

1. **Confirmation bias / base rates.** Once you *expect* em dashes and "delve," you notice them in AI text and discount them in human text. The features are common in good human writing; noticing them is not evidence.
2. **Invalid intuition.** [[../../raw/papers/2026-07-13-jakesch-human-heuristics-flawed|Jakesch et al.]]: humans detect at ~50% and rely on cues (typos, contractions, personal detail) that are invalid and fakeable.

## Practical fairness rules

- Never treat a tell or a detector score as proof, especially for **non-native speakers**.
- In high-stakes settings (academic integrity, publication, employment), **require corroborating evidence** beyond style — process metadata, version history, an admission, or a fabricated-source finding.
- State conclusions probabilistically and disclose the false-positive risk.
- Prefer verifying substance (fabricated citations, false facts) — those findings don't discriminate.

## See also

- [[detection-tools-and-limits|Detection tools & limits]]
- [[reviewer-checklist|Reviewer checklist]] — Step 4 guardrails.
- [[../concepts/perplexity-and-burstiness|Perplexity & burstiness]] — why the bias is structural.
