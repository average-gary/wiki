---
title: "Why Does ChatGPT 'Delve' So Much? Exploring the Sources of Lexical Overrepresentation in Large Language Models"
source: https://arxiv.org/abs/2412.11385
authors: Tom S. Juzek, Zina B. Ward
venue: COLING 2025; aclanthology.org/2025.coling-main.426; arXiv:2412.11385 (Dec 2024)
type: paper
tags: [llm-writing-indicators, delve, rlhf, lexical-tells, nigerian-english, frequency-data]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Tests the causes of ChatGPT's lexical overrepresentation. Identifies 21 overrepresented "focal" words (delves, showcasing, boasts, underscores, intricacies, realm…). "delves" per-million in PubMed rose 0.21 (2020) → 14.38 (2024), ~6,700%. Finds evidence consistent with RLHF as the cause; explicitly does NOT support the viral "Nigerian-English annotators" hypothesis via ICE corpus analysis.
---

# Juzek & Ward — Why does ChatGPT "delve" so much?

**Quality: 5/5.** Peer-reviewed (COLING 2025); the empirical anchor for the "delve" tell and its causes.

## Findings

- **21 overrepresented "focal" words** in scientific abstracts: delves, delved, delving, showcasing, delve, boasts, underscores, comprehending, intricacies, surpassing, intricate, underscoring, garnered, showcases, emphasizing, underscore, realm, surpasses, groundbreaking, advancements, aligns.
- **Frequency data (PubMed, per million):** "delves" rose from **0.21 (2020) → 14.38 (2024)** (~6,700% jump); "delve" **0.58 → 8.50**. In raw ChatGPT-3.5 output, "delves" hit **183.17 opm** vs 0.32 in 2024 PubMed. Corpus: 26.7M abstracts / 5.2B tokens.
- **On the Nigerian-English theory — tested and doubted.** They cite the hypothesis (that "delve" is common in Nigerian English spoken by fine-tuning evaluators, per Hern 2024) then conclude: **"Our initial analysis of ICE [International Corpus of English] does not support this hypothesis."**
- **On RLHF (the mechanism they DO support):** "fail to find evidence" it's caused by architecture/algorithm/training data, but "Model testing is consistent with RLHF playing a role." Meta's preference-trained Llama was *less surprised* by buzzword-laden abstracts than the base model.
- **Human experiment** (201 India-based participants): inconclusive overall, but participants **preferred versions without "delve"** (p=0.023) — people react more negatively to "delve" than other buzzwords.

## Why it matters for a reviewer

Confirms "delve" is a real, quantifiable, RLHF-driven tell — while explicitly *weakening* the viral "Nigerian annotators" story. Don't present that folk theory as settled; the corpus evidence points at RLHF, not a specific annotator dialect.
