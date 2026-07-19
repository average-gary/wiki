---
title: Citation & fact anomalies — fabricated sources and broken references
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, citations, hallucination, fact-checking]
sources:
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
  - raw/papers/2026-07-13-liang-peer-reviews-ai-modified.md
---

# Citation & fact anomalies

When an LLM supplies references, they are a rich source of tells — because the model generates *plausible-looking* citations without checking they exist or say what it claims. [[../../raw/articles/2026-07-13-wikipedia-signs-of-ai-writing|Wikipedia editors]] treat citation problems as among the most actionable signals, since they double as substantive quality failures.

## What to look for

- **Fabricated sources.** Citations to papers, books, or URLs that don't exist. Wikipedia documents real cases of AI-inserted fake sources in Russian and Hungarian.
- **Broken or mismatched identifiers.** Invalid DOIs/ISBNs; DOIs that resolve to an unrelated article; dead external links.
- **Off-topic citations.** A real source cited for a claim it doesn't support — the model grabbed a plausible reference without reading it.
- **Missing granularity.** Book citations with no page numbers; vague "studies show" with no study.
- **Tracking-parameter residue.** URLs carrying `utm_source=` and similar, pasted from a search result.
- **Named-but-unused references.** A reference defined but never actually cited in the body.
- **Citation scarcity.** [[../../raw/papers/2026-07-13-liang-peer-reviews-ai-modified|Liang et al.]] found LLM-heavy peer reviews contained *fewer* specific citations (`et al.`) — a negative-space tell.

## Why it matters

This is the tell that is *also* the harm. Unlike an em dash, a fabricated citation is a substantive defect regardless of who wrote it. Checking a few references is one of the highest-yield verification steps a reviewer can take — and it converts a soft "this feels like AI" suspicion into a hard, defensible finding ("this source does not exist"). The [[../../raw/articles/2026-07-13-wikipedia-signs-of-ai-writing|AISIGNS]] guidance stresses: don't just fix the surface tell, check whether the underlying claims and sources are real.

## See also

- [[vagueness-and-missing-specifics|Vagueness & missing specifics]]
- [[../topics/reviewer-checklist|Reviewer checklist]] — verification is the load-bearing step.
