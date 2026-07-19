---
title: "The detector arms race: Vanderbilt disables Turnitin, OpenAI scuttles its classifier, MIT TR finds detectors easy to fool"
source: https://www.vanderbilt.edu/brightspace/2023/08/16/guidance-on-ai-detection-and-why-were-disabling-turnitins-ai-detector/
authors: Vanderbilt University; Rhiannon Williams (MIT Technology Review); Devin Coldewey (TechCrunch)
venue: Vanderbilt (16 Aug 2023) + MIT Tech Review (7 Jul 2023) + TechCrunch (25 Jul 2023)
type: article
tags: [llm-writing-indicators, detection-limits, detectors, false-positives, arms-race]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Three institutional/journalistic sources on why detection failed. Vanderbilt disabled Turnitin's detector: at a claimed 1% FPR across ~75,000 papers/year, ~750 papers could be wrongly flagged. OpenAI shut down its own classifier (26% true-positive, 9% false-positive). MIT TR: 14 tools ~96% on human text but 74% on unmodified ChatGPT collapsing to 42% on lightly edited text; broken by paraphrasing/translation.
---

# Detector arms race — Vanderbilt / OpenAI / MIT Tech Review

**Quality: 5/5.** Institutional primary source + two named outlets.

## Vanderbilt — "Why We're Disabling Turnitin's AI Detector" (16 Aug 2023)

- **The load-bearing math:** Turnitin advertised a **1% false-positive rate**; Vanderbilt processed ~**75,000 papers in 2022**, so even at 1%, ~**750 papers** could be wrongly flagged.
- "AI detection is already a very difficult task for technology to solve (if it is even possible)." Cites bias against **non-native English speakers.**

## OpenAI scuttles its own classifier (TechCrunch, 25 Jul 2023)

- OpenAI **shut down its AI Text Classifier on 20 Jul 2023** for "low rate of accuracy." Launch metrics: caught only **26%** of AI text ("likely AI"), with a **9%** false-positive rate. TechCrunch's test: 1 of 7 correct.
- The vendor with the most data and incentive concluded it couldn't reliably detect its own output; pivoted toward watermarking/provenance.

## MIT Technology Review — "AI-text detection tools are really easy to fool" (7 Jul 2023)

- Study of 14 tools: ~**96% accuracy on human text, 74% on unmodified ChatGPT, collapsing to 42% on lightly edited ChatGPT.** Broken by paraphrasing (Quillbot), reordering, round-trip translation.
- Debora Weber-Wulff: "These tools don't work… They're not detectors of AI." Daphne Ippolito (Google): false positives carry "dire consequences."

## Recent (2025)

- **Dik et al., arXiv 2506.23517 (30 Jun 2025):** GPTZero catches purely-AI essays at 91–100% but produces false positives on human essays; "reliability in distinguishing human-authored texts is limited." GPTZero claims retraining across "15 model releases in 2025" — detectors in constant retraining to chase drift.

## Why it matters for a reviewer

A detector "hit" is not evidence. Even at a marketed 1% FPR, scale produces hundreds of false accusations; accuracy collapses under trivial editing; and the LLM's own maker couldn't detect its own text. Use detectors, if at all, as one weak input among many — never as a verdict.
