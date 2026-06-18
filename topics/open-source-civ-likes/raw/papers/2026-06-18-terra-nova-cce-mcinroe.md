---
title: "Terra Nova: A Comprehensive Challenge Environment for Intelligent Agents"
source: https://arxiv.org/abs/2511.15378
authors: [Trevor McInroe]
year: 2025
type: paper
ingested: 2026-06-18
quality: 3
confidence: medium
tags: [civ5-inspired, RL-benchmark, CCE, theoretical-framing]
---

# Terra Nova: A Comprehensive Challenge Environment for Intelligent Agents

November 2025 solo-authored arxiv preprint. Proposes Terra Nova, a Civ-V-
inspired environment, as a new class of "comprehensive challenge environment"
(CCE) for intelligent agents.

## Key claims

- **CCE vs. multitask aggregate benchmarks**: Argues mainstream multitask
  benchmarks only test "policy switching" — Terra Nova instead tests
  **integrated, long-horizon reasoning** across interacting variables.
- Combines partial observability + credit assignment + representation
  learning + huge action spaces in a single environment.
- Civilization-like games are framed as a *distinct RL frontier*, not just
  another testbed.

## Relevance to OSS civ-likes

Useful conceptual grounding for the wiki's "why civ-likes matter for AI
research" section. Doesn't ship as open source itself but the **framing**
(CCE vs. multitask) explains why CivRealm and CivAgent are not redundant
with Atari benchmarks.

## Caveats

- Solo-authored, not peer-reviewed.
- "Inspired by Civ V" — not an actual implementation atop Civ V or Freeciv.
- Status of any released code unclear from the abstract surface.
