---
title: llm-writing-indicators config
type: config
created: 2026-07-13
sensitivity: public-oss
---

# llm-writing-indicators config

## Scope

**In scope:**
- Surface-level lexical tells of LLM-generated prose: overused words ("delve", "tapestry", "testament", "underscore", "boasts", "realm", "leverage"), intensifier/hedge patterns, "not only… but also", "it's important to note".
- Structural/rhetorical tells: rule-of-three lists, formulaic intros/conclusions, the "It's not X, it's Y" antithesis, section-header regularity, over-signposting, balanced "on one hand / on the other".
- Punctuation and typography tells: em-dash overuse, curly quotes, title-case headings, emoji-bulleted lists, bold-key-term density.
- Tone/register tells: relentless positivity, sycophancy, false balance, vagueness, absence of concrete detail or lived experience, over-qualification.
- Empirical/quantitative evidence: corpus studies of word-frequency shifts post-ChatGPT (e.g., scientific-abstract studies), detector research, human-detection studies.
- Model-specific and version drift: how tells differ across GPT-4/4o, Claude, Gemini, and how they shift with model updates and RLHF.
- Practical reviewer guidance: checklists, heuristics, what is reliable vs. unreliable, false-positive risks for non-native English writers.
- Detector tools and their limits (GPTZero, Turnitin, Pangram, Binoculars, DetectGPT), why detection is fundamentally hard, adversarial paraphrasing.

**Out of scope:**
- Building an LLM detector / classifier codebase — that belongs in a repo-local `.wiki/` if implementation starts.
- Academic-integrity policy debates and institutional enforcement decisions (mentioned only as context).
- Prompt-engineering to *evade* detection framed as a how-to for deception (covered only descriptively re: reviewer awareness).
- General writing-quality advice unrelated to AI provenance.

## Sensitivity

`public-oss`. The hub is publishable; this is a general research compilation with no employer-proprietary content, suitable for open sharing.

## Created

2026-07-13
