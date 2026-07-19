---
title: "Spotting LLMs With Binoculars: Zero-Shot Detection of Machine-Generated Text"
source: https://arxiv.org/abs/2401.12070
authors: Abhimanyu Hans, Avi Schwarzschild, Valeriia Cherepanova, Hamid Kazemi, Aniruddha Saha, Micah Goldblum, Jonas Geiping, Tom Goldstein
venue: ICML 2024; arXiv:2401.12070
type: paper
tags: [llm-writing-indicators, detection, zero-shot, perplexity-ratio, cross-perplexity]
quality: 5
confidence: high
ingested: 2026-07-13
summary: State-of-the-art zero-shot detector. Uses two paired models (observer + performer) and computes perplexity ÷ cross-perplexity (the "Binoculars ratio"). The ratio normalizes for prompt difficulty (the "capybara problem"), so it works without seeing the prompt. >90% true-positive rate at just 0.01% false-positive rate on ChatGPT text; generalizes to unseen LLMs. No training data.
---

# Hans et al. — Binoculars

**Quality: 5/5.** Peer-reviewed (ICML 2024); current SOTA zero-shot detector; gives exact formulas.

## Method

- Uses **two closely-paired models**: an **observer** ℳ₁ (Falcon-7B) and a **performer** ℳ₂ (Falcon-7B-Instruct).
- **Log-perplexity** = average negative log-likelihood the observer assigns to actual tokens: `log PPL_ℳ₁(s) = −(1/L) Σ log P(xᵢ)`.
- **Cross-perplexity** = cross-entropy between the two models' output distributions: `log X-PPL = −(1/L) Σ ℳ₁(s)ᵢ · log ℳ₂(s)ᵢ` — how surprising one model's predictions are to the other.
- **Binoculars score = log-PPL / log-X-PPL** (a ratio, not raw perplexity).

## Why the ratio matters — the "capybara problem"

Raw perplexity is confounded by the prompt: an unusual prompt ("a capybara that is an astrophysicist") makes even machine text look high-perplexity / human-like. Dividing by cross-perplexity **normalizes for that contextual difficulty** — machine text diverges *less* from other machine predictions than human text does, so the ratio isolates the machine signature regardless of topic exoticism, and works **without seeing the prompt**.

## Performance

- **>90% true-positive rate at a 0.01% false-positive rate** on ChatGPT text across News, Creative Writing, Student Essay datasets.
- **Zero-shot** (no ChatGPT training data); generalizes to LLaMA-2 / Falcon without retraining. Beat GPTZero and Ghostbuster in the paper's tests.

## Why it matters for a reviewer

The strongest current detectors are perplexity-*ratio* based, not word-list based — the technical anchor for why "burstiness / perplexity" are the load-bearing statistical signals, and why naive single-model perplexity is unreliable (prompt sensitivity).
