---
title: "Too many em dashes? Weird words like 'delves'? Spotting text written by ChatGPT is still more art than science"
source: https://theconversation.com/too-many-em-dashes-weird-words-like-delves-spotting-text-written-by-chatgpt-is-still-more-art-than-science-259629
author: Roger J. Kreuz (University of Memphis)
venue: The Conversation (30 Jul 2025)
type: article
tags: [llm-writing-indicators, model-drift, detection-limits, sycophancy, stylometry]
quality: 4
confidence: high
ingested: 2026-07-13
summary: Psycholinguist's overview arguing tell-spotting is "more art than science." Inventory of markers (uncommon words like "crucial", excessive em dashes, hedges, predictable adjectives, redundancy, list overreliance). Documents the early-2025 ChatGPT "obsequious" episode (calling mundane queries "amazing") that OpenAI rolled back — direct evidence tells are a moving target. Detection unreliable: 94% of undergrad ChatGPT exam answers went undetected; stylometry needs ≥1,000 words.
---

# Kreuz (The Conversation) — More art than science

**Quality: 4/5.** Named academic author; the best single source for the "tells are version-specific and drifting" thesis.

## Findings

- Marker inventory beyond delve: uncommon words ("crucial"), excessive em dashes, hedges ("often," "generally"), predictable adjectives ("significant," "notable"), academic terms, redundancy, overreliance on lists.
- **Markers shift with model updates:** early 2025 ChatGPT became "overly obsequious" (calling mundane queries "amazing"/"fantastic"), prompting **OpenAI to roll back** that update — direct evidence tells are tied to RLHF tuning and drift.
- **Detection unreliable:** BERT detectors 80–98% in controlled settings, but **94% of undergrad ChatGPT exam answers went undetected**; stylometry needs ≥1,000 words. GPT-4o itself notes "none [of these tells] are definitive on their own."

## Why it matters for a reviewer

Best articulation that any static checklist ages fast — the em-dash tell plus the 2025 sycophancy episode show fingerprints move with each RLHF update. Spotting AI is judgment, not a formula.
