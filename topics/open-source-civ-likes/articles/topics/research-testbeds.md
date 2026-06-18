---
title: Civ-Likes as AI Research Testbeds
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/papers/2026-06-18-civrealm-iclr-2024.md
  - raw/papers/2026-06-18-civagent-digital-player-unciv.md
  - raw/papers/2026-06-18-vox-deorum-llm-civ5.md
  - raw/papers/2026-06-18-terra-nova-cce-mcinroe.md
  - raw/papers/2026-06-18-forecastbench-sim-freeciv.md
  - raw/papers/2026-06-18-kbrl-freeciv-voss.md
---

# Civ-Likes as AI Research Testbeds

Civilization-like games sit in an unusual research sweet spot:
imperfect-information, general-sum, variable-player-count, with
diplomacy / negotiation / long-horizon planning all first-class. Atari
benchmarks, Go, and even StarCraft don't cover the same ground.

Two open-source civ-likes carry essentially all the academic weight:
**Freeciv** (via Freeciv-web) and **Unciv**. Civ V (proprietary) gets the
most LLM attention, but only mod-mediated — see
[Vox Deorum (Civ V)](#vox-deorum-civ-v-2025) below.

This article is a chronological landscape rather than a deep methodology
review.

## Voss et al. — KB-RL on Freeciv (2019)

Source: [arxiv.org/abs/1908.05472](https://arxiv.org/abs/1908.05472), DOI
10.1007/s42979-020-0087-8 (peer-reviewed in *SN Computer Science*).

**Knowledge-Based RL** (KB-RL) — combines multiple expert knowledge
sources, uses RL to resolve their conflicts. Demonstrated **full-game
completion of Freeciv** with wins against built-in AI in various game
settings. Performance improves over time (fewer rounds to win) — a
learning-curve result on a *full* civ game, not just mini-games.

**Significance**: Pre-LLM-era landmark showing Freeciv was already an
academic testbed.

## CivRealm (ICLR 2024)

Source: [arxiv.org/abs/2401.10568](https://arxiv.org/abs/2401.10568)

The keystone paper. Beijing Institute for General Artificial Intelligence
(BIGAI) and collaborators, peer-reviewed at ICLR 2024 — top-tier ML venue.

- Builds directly on **Freeciv-web / Freeciv** as the engine
- Frames the problem as imperfect-information, general-sum, variable-
  player-count game; emphasizes diplomacy and negotiation
- **Dual interface**: Gymnasium-style tensor API (RL agents) AND a
  language interface (LLM agents) on the same engine
- Reports that RL agents reach reasonable performance on mini-games but
  **both RL- and LLM-based agents struggle on full games** — the full
  game remains an open challenge
- GPL-3.0; depends on freeciv-web, FCIV-NET, freeciv-bot

**Significance**: Bridges open-source civ-game world to top-tier ML
research. Validates that Freeciv's age (1996+) and coverage are not
handicaps but rather *advantages* for reproducibility.

### Note: tension with Voss et al. (2019)

Voss reports full-game wins; CivRealm reports the full game is unsolved.
The methodological frames differ:
- **Voss**: KB-RL vs. fixed scripted opponent (built-in Freeciv AI)
- **CivRealm**: multi-agent self-play, different evaluation regime

The discrepancy is not a contradiction; it's a useful contrast for any
wiki article that cites both.

## CivAgent / Digital Player (2025)

Source: [arxiv.org/abs/2502.20807](https://arxiv.org/abs/2502.20807) ·
Repo: [github.com/fuxiAIlab/CivAgent](https://github.com/fuxiAIlab/CivAgent)

NetEase Fuxi AI Lab. Submitted to NeurIPS Datasets & Benchmarks 2024
(rejected); still substantive infrastructure contribution.

- Built on **[Unciv](unciv.md)** — the only Unciv-as-research-testbed paper
  found. Goal: human-like, not optimal — agents capable of diplomatic
  negotiation, deception, in-character play rather than min-maxing.
- Identified problem set: large action space, numerical reasoning, long-
  horizon planning, social interaction.
- Open-sourced as CivAgent — practical scaffolding others can fork.
- Industry credibility: NetEase Fuxi is a major Chinese game studio's AI
  lab.

**Significance**: Establishes Unciv as a viable academic testbed alongside
Freeciv. Unciv's deterministic JSON rules and Kotlin codebase are arguably
easier to reason about than Freeciv-web's
C-server/JS-client/Python-proxy stack — shorter loop for prompt-engineering
experiments with LLM agents.

## Terra Nova / CCE (2025)

Source: [arxiv.org/abs/2511.15378](https://arxiv.org/abs/2511.15378)

Trevor McInroe, solo-authored arxiv preprint. Proposes **Terra Nova**, a
Civ-V-inspired environment, as a new class of "comprehensive challenge
environment" (CCE) for intelligent agents.

- **CCE vs. multitask aggregate benchmarks**: argues mainstream multitask
  benchmarks only test "policy switching" — Terra Nova instead tests
  *integrated*, long-horizon reasoning across interacting variables.
- Combines partial observability + credit assignment + representation
  learning + huge action spaces in a single environment.
- Civilization-like games are framed as a *distinct RL frontier*.

**Significance**: Articulates the *theoretical case* for why civ-likes are
a distinctive RL frontier. Useful conceptual grounding for the wiki's
"why civ-likes matter for AI research" argument.

## Vox Deorum (Civ V, 2025)

Source: [arxiv.org/abs/2512.18564](https://arxiv.org/abs/2512.18564)

Chen, Cheng, Gurkan, Lay, Salahuddin (Dec 2025).

The most rigorous LLM-in-4X study to date — but **on Civ V, not on an
OSS civ-like**.

- **Layered hybrid LLM+algorithmic architecture**: LLMs handle macro-
  strategic reasoning; tactical execution delegated to algorithmic / RL
  subsystems
- **2,327 complete games of Civ V** with the Vox Populi mod — unusually
  large N for this space
- **Two open-source LLMs achieved competitive performance** vs. Vox Populi
  baseline
- **Distinct LLM "play styles"** diverge from algorithmic AI and from each
  other → genuine strategic diversity, not pure imitation
- Latency / cost framed for industry feasibility

**Significance**: The hybrid architecture pattern (LLM macro + algorithmic
micro) generalizes to Freeciv's Lua AI hooks and Unciv's JSON-driven
rulesets. Open question: what's the smallest-API reproduction of Vox
Deorum on top of [CivRealm](#civrealm-iclr-2024)'s Freeciv-web interface
or [CivAgent](#civagent-digital-player-2025)'s Unciv scaffold?

## ForecastBench-Sim (Freeciv, 2026)

Source: [arxiv.org/abs/2606.18686](https://arxiv.org/abs/2606.18686)

Lee, Merrill, Karger (June 2026). Uses **Freeciv as a substrate for
forecasting evaluation** — distinct from the usual game-playing-agent
angle.

- Freeciv rollouts generate forecasting questions with controlled, fast
  resolution — sidestepping real-world forecasting's slow-resolution and
  rare-tail-event problems.
- Forecasters get a structured "world report" snapshot, asked to predict
  hidden future states.
- **Counterfactual / paired "intervention world" comparisons** enable
  causal evaluation of probabilistic reasoning.
- Combines model evaluations with human pilot studies.

**Significance**: Demonstrates Freeciv's research utility *beyond*
game-playing agents — as a substrate for forecasting and probabilistic-
reasoning evaluation.

## Cross-paper observations

1. **Two engines dominate**: Freeciv (CivRealm, ForecastBench-Sim, KB-RL)
   and Unciv (CivAgent). No published academic work uses
   [Freeciv21](freeciv21.md) — opportunity gap for any researcher who
   wants a less-explored testbed.
2. **2025–2026 wave is LLM-driven** (Vox Deorum, CivAgent), shifting the
   angle from pure RL to LLM-agent / hybrid architectures and from
   "winning" to "human-like / ethical / diplomatic" behavior.
3. **Civ V (proprietary) gets more LLM attention than OSS civ-likes** via
   the Vox Populi mod. Opportunity gap: open-source engines (Freeciv,
   Unciv) are uniquely suitable for *reproducible* research, but
   commercial Civ V still attracts more LLM work because Vox Populi is the
   highest-quality 4X AI baseline available.
4. **No academic Freeciv21 work, no academic 0 A.D. work, no academic
   openage work.** All are research opportunities.

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
- [Freeciv-web](freeciv-web.md) — engine underneath CivRealm
- [Unciv](unciv.md) — engine underneath CivAgent
- [Freeciv21](freeciv21.md) — *no* published research; opportunity
- [hub: bevy-game-engine](../../../bevy-game-engine/_index.md) —
  Rust/ECS game engine (useful framing for new civ-like engine projects)
- [hub: nostr-ecash-gaming](../../../nostr-ecash-gaming/_index.md) —
  decentralized game-state primitives (potential P2P civ-like backbone)
