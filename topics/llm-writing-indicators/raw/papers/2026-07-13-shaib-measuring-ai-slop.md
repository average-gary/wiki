---
title: "Measuring AI 'Slop' in Text"
source: https://arxiv.org/html/2509.19163v1
authors: Chantal Shaib, Tuhin Chakrabarty, Diego Garcia-Olano, Byron C. Wallace
venue: arXiv:2509.19163 (Sept 2025)
type: paper
tags: [llm-writing-indicators, ai-slop, style-quality, structural-tells, detection-limits]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Defines and operationalizes "AI slop": generic, verbose, formulaic, low-information text. Taxonomy from 19 expert interviews + span annotation of 150 news articles + 100 QA passages, across Information Utility, Information Quality, and Style Quality (repetition, templatedness, verbosity, tone). Detection is hard: human agreement κ = −0.15 to 0.29; even GPT-5 span extraction scores 0.14 precision / 0.11 recall. Human review remains necessary.
---

# Shaib et al. — Measuring AI slop

**Quality: 5/5.** Primary study; gives a defensible vocabulary for the *structural* tells beyond single words.

## Findings

- Defines slop: "material produced using a large language model… generic, overly verbose, inaccurate, irrelevant," with "patterns of repetition, formulaic structure, vague language."
- Taxonomy from **19 expert interviews** + span-annotation of 150 news articles + 100 QA passages. Three themes: **Information Utility, Information Quality, Style Quality** (repetition, templatedness, verbosity, word complexity, tone).
- **Detection is hard:** human inter-annotator agreement κ = **−0.15 to 0.29**; automated linear models AUPRC ~**0.52–0.55** (barely above baseline); **GPT-5 span extraction: 0.14 precision, 0.11 recall.** Conclusion: reliable *automatic* slop detection doesn't yet exist; **human review remains necessary.**

## Why it matters for a reviewer

Supplies durable, structural descriptors of what makes prose read as slop — templatedness, verbosity, low information density, generic tone — which age better than any single lexical tell. Also shows even frontier models can't reliably flag slop automatically, so the reviewer's judgment is the tool.
