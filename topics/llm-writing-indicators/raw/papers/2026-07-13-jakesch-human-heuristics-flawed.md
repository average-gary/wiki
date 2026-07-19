---
title: "Human heuristics for AI-generated language are flawed"
source: https://arxiv.org/abs/2206.07271
doi: 10.1073/pnas.2208839120
authors: Maurice Jakesch, Jeffrey T. Hancock, Mor Naaman
venue: PNAS Vol. 120 No. 11 (2023); preprint arXiv:2206.07271
type: paper
tags: [llm-writing-indicators, human-detection, heuristics, false-cues]
quality: 5
confidence: high
ingested: 2026-07-13
summary: Definitive human-detection study (N=4,600, six experiments). Humans detect AI text at ~50–52% — chance. The cues people wrongly associate with human authorship (first-person pronouns, contractions, family topics, typos, informal wording) are exactly what a prompted LLM can fake, producing text rated "more human than human."
---

# Jakesch, Hancock & Naaman — Human heuristics are flawed

**Quality: 5/5.** Peer-reviewed in PNAS, large N, definitive human-detection study.

## Findings

- **N = 4,600 participants** across **six experiments**, judging AI- vs human-written self-presentations (professional, Airbnb hospitality, dating).
- **Humans detect AI text at ~50–52% — essentially chance.** People cannot reliably tell.
- **The heuristics humans wrongly use** (they associate these with *human* authorship): **first-person pronouns, contractions, family-topic mentions, grammatical errors/typos, and spontaneous/informal wording.** Intuitive but invalid.
- Because these heuristics are predictable, AI text can be tuned to trigger them → output rated **"more human than human."** Authors propose "AI accents" (deliberate detectable markers) as a mitigation.

## Named signals (as *misleading* cues, not valid ones)

Presence of first-person pronouns, contractions, informal/spontaneous phrasing, and minor grammatical errors are **NOT** reliable indicators of human authorship.

## Why it matters for a reviewer

Empirically demolishes the assumption that a careful human can spot LLM prose by feel. The intuitive cues (typos, casual tone, personal detail) are exactly what a prompted LLM fakes — so lean on statistical/lexical signals, not gut instinct.
