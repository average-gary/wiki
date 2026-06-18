---
title: "Playing a Strategy Game with Knowledge-Based Reinforcement Learning"
source: https://arxiv.org/abs/1908.05472
doi: 10.1007/s42979-020-0087-8
journal: SN Computer Science
authors: [Viktor Voss, Liudmyla Nechepurenko, Rudi Schaefer, Steffen Bauer]
year: 2019
type: paper
ingested: 2026-06-18
quality: 3
confidence: medium
tags: [freeciv, RL, knowledge-based-RL, historical-baseline, peer-reviewed]
---

# Playing a Strategy Game with Knowledge-Based Reinforcement Learning

2019 paper, peer-reviewed in *SN Computer Science* (Springer Nature). One of
the earliest peer-reviewed Freeciv-as-AI-testbed results.

## Key claims

- **Knowledge-Based RL (KB-RL) framework**: combines multiple expert
  knowledge sources, uses RL to resolve their conflicts.
- **Demonstrated full-game completion of Freeciv** — wins against built-in
  AI in various game settings.
- Performance improves over time (fewer rounds to win) — a learning-curve
  result on a *full* civ game, not just mini-games.

## Significance

Pre-LLM-era landmark showing Freeciv was already an academic testbed.
Provides historical depth for the wiki and a key methodological contrast:
> Voss et al. (2019) report full-game wins vs. built-in AI, while CivRealm
> (ICLR 2024) reports the full game remains unsolved.

The two claims are not directly contradictory — CivRealm targets multi-agent
self-play, Voss targets a fixed scripted opponent — but the discrepancy is
worth flagging in any wiki article that cites both.
