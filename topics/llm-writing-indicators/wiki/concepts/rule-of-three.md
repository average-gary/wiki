---
title: Rule of three — reflexive triads
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: medium
tags: [llm-writing-indicators, structure, rhetoric]
sources:
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
---

# Rule of three

LLMs default to three-item parallel structures — three adjectives, three examples, three clauses — to make superficial analysis *feel* comprehensive. Humans use triads too (it is a genuine rhetorical device), so this is a medium-confidence tell that matters in aggregate.

## What it looks like

- Adjective triads: "a robust, scalable, and efficient solution."
- List triads padding a sentence: real examples from Wikipedia's catalog — "tiles, metals, and plastics" / "drywall, plywood, and other construction materials" / "electrical outlets, switches, and plumbing fixtures."
- Three parallel clauses each doing the same rhetorical work.

## The tell is the reflexiveness

One triad is good writing. The signal is when *nearly every* enumeration lands on exactly three items regardless of whether reality has three — the model reaches for the cadence, not the count. Combined with the completeness illusion: three items presented as if they exhaust the topic when they are just the three most probable tokens.

## Why it happens

The triad is a high-probability rhetorical pattern in the edited prose LLMs train on, amplified by RLHF's reward for output that reads polished and complete. See [[why-llms-write-this-way|why LLMs write this way]].

## See also

- [[structural-formulas|Structural formulas]] — larger-scale version of the same "feel complete" pressure.
- [[not-x-but-y-antithesis|"Not X but Y" antithesis]] — another reflexive rhetorical shape.
