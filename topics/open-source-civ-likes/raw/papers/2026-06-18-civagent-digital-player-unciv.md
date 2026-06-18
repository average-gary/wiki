---
title: "Digital Player: Evaluating Large Language Models based Human-like Agent in Games (CivAgent / Unciv)"
source: https://arxiv.org/abs/2502.20807
repo: https://github.com/fuxiAIlab/CivAgent
authors: [Jiawei Wang, Kai Wang, Shaojie Lin, Runze Wu, Bihan Xu, Lingeng Jiang, Shiwei Zhao, Renyu Zhu, Haoyu Liu, Zhipeng Hu, Zhong Fan, Le Li, Tangjie Lyu, Changjie Fan]
year: 2025
type: paper
ingested: 2026-06-18
quality: 3
confidence: medium
tags: [unciv, LLM, human-like-agent, NetEase-Fuxi, CivAgent]
---

# Digital Player: Evaluating LLM-based Human-like Agents in Games (CivAgent / Unciv)

February 2025 arxiv preprint from NetEase Fuxi AI Lab. Submitted to NeurIPS
Datasets & Benchmarks 2024 but not accepted; still substantive infrastructure
contribution.

## Key claims

- **Built on Unciv** — the Kotlin/libGDX open-source Civ V clone. The only
  paper found that uses Unciv as a research testbed (vs. Freeciv).
- **Goal: human-like, not optimal** — agents capable of diplomatic
  negotiation, deception, and "playing in character" rather than min-maxing.
- **Identified problem set**: large action space, numerical reasoning,
  long-horizon planning, social interaction.
- **Open-sourced as CivAgent** at github.com/fuxiAIlab/CivAgent — practical
  scaffolding others can fork.
- **Industry credibility**: NetEase Fuxi is a major Chinese game studio's
  AI lab.

## Why this matters

Establishes Unciv as a viable academic testbed alongside Freeciv. The
combination of Unciv (data-driven Civ V clone) + LLM agents (CivAgent) gives
researchers a much shorter-loop testbed than CivRealm/Freeciv-web for
prompt-engineering experiments — Unciv's deterministic JSON rules and Kotlin
codebase are arguably easier to reason about than Freeciv-web's
C-server/JavaScript-client/Python-proxy stack.

## Limitations

- Not peer-reviewed (NeurIPS D&B rejection).
- Unciv copyright posture — see [Unciv: Copyright posture](#) — means
  researchers building on CivAgent inherit Unciv's legal stance.
