---
title: "Delving into LLM-assisted writing in biomedical publications through excess vocabulary"
source: https://arxiv.org/abs/2406.07016
doi: 10.1126/sciadv.adt3813
authors: Dmitry Kobak, Rita González-Márquez, Emőke-Ágnes Horvát, Jan Lause
venue: Science Advances (Vol. 11 No. 27, 2 Jul 2025); preprint arXiv:2406.07016 (2024)
type: paper
tags: [llm-writing-indicators, corpus-study, excess-vocabulary, lexical-tells, pubmed, delve]
quality: 5
confidence: high
ingested: 2026-07-13
summary: The definitive "excess vocabulary" corpus study. Analyzed all ~15.3M PubMed abstracts (2010–2024) with no prior assumptions about which words to look for, and found an abrupt post-ChatGPT spike in style words (delves ×28, underscores ×10.9, showcasing ×10.2). Lower bound: ≥13.5% of 2024 biomedical abstracts were LLM-processed; up to ~40% in some subcorpora.
---

# Kobak et al. — Excess vocabulary in biomedical abstracts

**Quality: 5/5.** Peer-reviewed landmark (Science Advances), primary data, the canonical methodology for quantifying LLM vocabulary shift. The paper that grounds the whole "delve" phenomenon in hard numbers.

## Corpus & method

- Corpus: **all ~15.3 million PubMed abstracts, 2010–2024** (14M+ used in analysis). Fully data-driven — no assumptions about which words to look for.
- **"Excess words" method** (analogous to COVID "excess mortality"): for each word, compute a counterfactual expected 2024 frequency *q* by linear extrapolation from pre-ChatGPT years (2021–2022), then compare to observed 2024 frequency *p*.
  - **Excess frequency ratio r = p/q** — highlights rarer words.
  - **Excess frequency gap δ = p − q** — highlights common words.

## Key findings

- **Marker words & 2024 excess ratios:** `delves` **r ≈ 28** (spiked hardest, was near-absent before), `showcasing` **r ≈ 10.2**, `underscores` **r ≈ 10.9**.
- **High-gap common words:** `potential` **δ ≈ 0.045**, `findings` **δ ≈ 0.031**, `crucial` **δ ≈ 0.029**.
- **The signal is a part-of-speech flip.** Pre-LLM, excess words were overwhelmingly *content words / nouns* (driven by topics: "covid," "pandemic," "lockdown"). In 2024 they flipped to *style words* — verbs, adjectives, adverbs: delve, showcase, underscore, intricate, meticulous, notably, comprehensive, pivotal, realm, enhancing, exhibited, insights, particularly, within, across, additionally. **This flip is itself the tell.**
- **319 excess style words** identified for 2024, predominantly **verbs (66%)** and **adjectives (16%)**.
- **Prevalence lower bound: ≥13.5% of 2024 abstracts** were LLM-processed. Derived from 222 rare "excess style words" (Δ_rare = 0.111); cross-validated by a *non-overlapping* set of 10 common words (across, additionally, comprehensive, crucial, enhancing, exhibited, insights, notably, particularly, within) giving Δ_common = 0.110 — nearly identical, confirming robustness.
- **Subcorpus variation up to ~30–40%**; highest in computational / less-edited fields, and varied strongly by country, journal, discipline.
- The vocabulary shift's magnitude and abruptness **exceeded even the COVID-19 pandemic's** effect on scientific vocabulary.

## Named signals

delve/delves/delving, showcasing/showcase, underscore(s), intricate, meticulous(ly), comprehensive, pivotal, realm, notably, crucial, potential, enhancing, insights, exhibited, particularly, additionally, within, across.

## Why it matters for a reviewer

Hardest empirical proof that a specific, nameable word list is statistically over-represented in post-2022 text, with a transparent, reproducible method. It supplies the canonical "tell" vocabulary — and a way to measure it rather than intuit it.

## Companion dataset

`berenslab/chatgpt-excess-words` (GitHub) publishes the machine-generated master list of ~900 excess words 2013–2024, each tagged content/style/other + part of speech. See the article-layer ingest of that dataset for the full enumerated word bank.
