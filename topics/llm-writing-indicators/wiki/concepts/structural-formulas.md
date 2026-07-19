---
title: Structural formulas — formulaic intros, conclusions, and section headings
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, structure, formatting]
sources:
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
  - raw/papers/2026-07-13-shaib-measuring-ai-slop.md
---

# Structural formulas

At the paragraph and document level, LLM prose follows recognizable templates. These "templatedness" tells are more durable than lexical ones ([[../../raw/papers/2026-07-13-shaib-measuring-ai-slop|Shaib et al.]] name templatedness a core dimension of AI "slop"), because RLHF rewards the appearance of thoroughness and structure.

## Formulaic section endings

Wikipedia's catalog flags a recurring closer: a section titled **"Challenges and Legacy," "Future Prospects," "Future Outlook," "Future Directions,"** or "Challenges and Future Directions," opening with the template **"Despite its … faces several challenges …"** and ending on vague positive speculation. It is analysis-shaped filler with no specific content.

## Over-signposting

The text narrates its own structure: "In this section we will explore…", "Let's break this down:", "Here's a breakdown:", "To summarize," — scaffolding that a human writer usually trims. Each point gets announced before it is made.

## The intro/body/conclusion symmetry

A too-neat opener that restates the prompt, a body of evenly-sized parallel chunks, and a conclusion that restates the body. Human writing has uneven emphasis; LLM writing distributes attention uniformly (the structural analogue of low [[perplexity-and-burstiness|burstiness]]).

## Heading patterns

- **Title Case For Every Heading** (capitalizing all major words) even where the house style is sentence case.
- **Skipped heading levels** — starting at level 3, skipping level 2 — an artifact of the model generating a subsection in isolation.
- Regular, evenly-spaced headers subdividing everything.

## Why it matters

These survive vocabulary drift. Even after a model stops saying "delve," it still builds the same intro-body-symmetric-conclusion scaffold and the same "Challenges and Future Directions" closer. For long-form review this is often the most reliable layer.

## See also

- [[markdown-and-formatting-tells|Markdown & formatting tells]] — the typographic surface of the same templating.
- [[rule-of-three|Rule of three]]
- [[perplexity-and-burstiness|Perplexity & burstiness]] — the statistical shadow of uniform structure.
- [[../topics/ai-slop-and-structural-tells|AI slop & structural tells]] (topic playbook).
