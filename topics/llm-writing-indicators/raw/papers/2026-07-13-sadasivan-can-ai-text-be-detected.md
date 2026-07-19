---
title: "Can AI-Generated Text be Reliably Detected?"
source: https://arxiv.org/abs/2303.11156
authors: Vinu Sankar Sadasivan, Aounon Kumar, Sriram Balasubramanian, Wenxiao Wang, Soheil Feizi
venue: arXiv:2303.11156 (Mar 2023, rev. through 2025); TMLR
type: paper
tags: [llm-writing-indicators, detection-limits, impossibility, spoofing, theory]
quality: 5
confidence: high
ingested: 2026-07-13
summary: The canonical theoretical-impossibility argument. As LLMs improve, the total-variation distance between human and AI text distributions shrinks, driving the best-possible detector's AUROC toward 0.5 (coin flip). Empirically breaks detectors with recursive paraphrasing and demonstrates spoofing attacks (framing human text as AI).
---

# Sadasivan et al. — Can AI-generated text be reliably detected?

**Quality: 5/5.** The canonical theoretical-impossibility paper.

## Findings

- **Impossibility-style result:** as LLMs improve, the total-variation distance between human-text and AI-text distributions shrinks; the paper ties the **AUROC of even the best possible detector** to that distance. As distributions converge, the best achievable detector approaches a **coin flip (AUROC → 0.5)**.
- Consequence: any detector buys a higher true-positive rate only by accepting a higher false-positive rate — a **fundamental tradeoff**, not an engineering bug.
- Empirically stress-tested watermarking, neural, zero-shot, and retrieval detectors with **recursive paraphrasing**; paraphrasing "significantly reduces detection rates" with only slight quality loss.
- Demonstrates **spoofing attacks**: adversaries can generate human-like text that trips watermark detectors — i.e., framing a human as an AI, weaponizing false positives.

## Why it matters for a reviewer

There is a mathematical ceiling on detection accuracy, and it *drops* as models improve. Confidence in any single tell contradicts the theory. The correct posture is probabilistic and low-confidence — never "this is definitely AI."
