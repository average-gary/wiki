---
title: Reviewer checklist — how to review suspected LLM prose
type: topic
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, checklist, playbook, review]
sources:
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
  - raw/papers/2026-07-13-jakesch-human-heuristics-flawed.md
  - raw/papers/2026-07-13-liang-detectors-biased-nonnative.md
  - raw/articles/2026-07-13-grammarly-common-ai-words.md
---

# Reviewer checklist

A practical procedure for reviewing prose you suspect is LLM-generated. The governing principle: **no single tell is proof — score the cluster, then verify substance.** Both the [[../../raw/articles/2026-07-13-wikipedia-signs-of-ai-writing|Wikipedia catalog]] and [[../../raw/articles/2026-07-13-grammarly-common-ai-words|Grammarly]] lead with this caveat, and [[../../raw/papers/2026-07-13-jakesch-human-heuristics-flawed|Jakesch et al.]] proved humans guess at ~50% when they rely on feel.

## Step 1 — Scan the deterministic tells first (highest confidence)

These are near-conclusive *when present*; go straight for them:
- [[../concepts/invisible-unicode-artifacts|Invisible Unicode]] — grep for U+200B, U+FEFF, U+00A0, U+202F.
- [[../concepts/markdown-and-formatting-tells|Leaked tool tokens]] — `oaicite`, `contentReference`, `turn0search0`, `grok_card`, stray `**` in non-markdown.
- Chatbot residue — "I hope this helps," "As of my last knowledge update," "Would you like…".

A hit here nearly settles it. A miss means nothing (they're trivially stripped) — continue.

## Step 2 — Score the soft-tell cluster (weight of evidence)

Tally how many co-occur. None alone is decisive; density is the signal.

| Layer | What to check | Article |
|---|---|---|
| Lexical | Density of delve/underscore/showcasing/intricate/pivotal/realm/meticulous | [[../concepts/lexical-overuse-words|Lexical overuse]] |
| Phrasal | "It's important to note," "stands as a testament," vague attribution | [[../concepts/formulaic-phrases|Formulaic phrases]] |
| Rhetorical | Rule of three, "not X but Y", significance inflation | [[../concepts/rule-of-three|Rule of three]] · [[../concepts/not-x-but-y-antithesis|Antithesis]] · [[../concepts/puffery-and-significance-inflation|Puffery]] |
| Structural | Formulaic intro/body/conclusion, "Challenges & Future Directions," over-signposting | [[../concepts/structural-formulas|Structural formulas]] |
| Formatting | Bold-stacked lists, title-case headings, emoji bullets | [[../concepts/markdown-and-formatting-tells|Formatting tells]] |
| Punctuation | Em-dash overuse, curly quotes (weak, time-sensitive) | [[../concepts/em-dash-and-punctuation|Em-dash & punctuation]] |
| Register | Relentless positivity, sycophancy, false balance, over-hedging | [[../concepts/sycophancy-and-positivity-register|Positivity register]] |

## Step 3 — The load-bearing step: verify substance

This is where a defensible finding is made, and it survives every form of drift and evasion:
- **Check the citations.** Do the sources exist? Do they say what's claimed? Broken DOIs, page-less books, off-topic refs. See [[../concepts/citation-and-fact-anomalies|citation & fact anomalies]].
- **Probe for specifics.** Does the text know concrete facts, or is it fluent about nothing? [[../concepts/vagueness-and-missing-specifics|Vagueness & missing specifics]].
- **Fact-check surprising claims.** LLMs fabricate confidently.

A fabricated citation is a finding regardless of authorship — and it converts a soft suspicion into a hard defect.

## Step 4 — Apply the guardrails before concluding

- **Do NOT trust detector scores as verdicts.** See [[detection-tools-and-limits|detection tools & limits]].
- **Check for false-positive risk.** Is the author a non-native English speaker, writing in a formal/legal register, or neurodivergent? All produce low-perplexity, formulaic prose that mimics the tells. [[../../raw/papers/2026-07-13-liang-detectors-biased-nonnative|61% of non-native essays are misflagged]]. See [[false-positives-and-fairness|false positives & fairness]].
- **Date your checklist.** Tells drift; a mid-2025 em-dash rule is stale by 2026. [[../concepts/model-and-version-drift|Model & version drift]].
- **Ignore the invalid human cues.** [[../../raw/papers/2026-07-13-jakesch-human-heuristics-flawed|Jakesch et al.]]: typos, contractions, first-person, and casual tone are NOT evidence of human authorship — a prompted LLM fakes all of them.

## Step 5 — Calibrate the conclusion to the stakes

- **Low stakes** (is this blog post AI?): the cluster score is enough for an informal judgment.
- **High stakes** (accusing a student/author): tells are *never* sufficient. Require an admission, process metadata, or a fabricated-source finding. A false accusation is a serious harm ([[false-positives-and-fairness|false positives & fairness]]).

Phrase findings probabilistically: "shows multiple indicators consistent with LLM generation," never "this is AI."

## See also

- [[false-positives-and-fairness|False positives & fairness]]
- [[detection-tools-and-limits|Detection tools & limits]]
- [[../reference/overused-words-and-phrases|Reference: overused words & phrases]]
