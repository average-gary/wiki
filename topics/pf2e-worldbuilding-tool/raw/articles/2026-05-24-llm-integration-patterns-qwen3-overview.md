---
title: "Qwen 3 offers a case study in effective model release"
source: "https://simonwillison.net/2025/Apr/29/qwen-3/"
type: article
date_fetched: 2026-05-24
date_published: "2025-04-29"
tags: [llm, local-llm, qwen3, mlx, ollama, llama-cpp]
quality: 4
credibility: high
path: llm-integration-patterns
summary: "Simon Willison's hands-on Qwen3 launch coverage. Six dense sizes (0.6B-32B) + two MoE (30B-A3B, 235B-A22B), 128K context (4B+), MCP-trained, hybrid <think> reasoning. 32B fits in 64GB Mac with headroom; this is the practical 2026 baseline for local PF2e GM use."
---

# Qwen 3 - Practical Local LLM Baseline for 2026 GM Laptop

## Model Lineup
**Dense**: 0.6B, 1.7B, 4B, 8B, 14B, 32B
**MoE**: Qwen3-30B-A3B (30B params, 3B active), Qwen3-235B-A22B (235B/22B active)

## Context Windows
- 0.6B, 1.7B: 32,768 tokens
- 4B and larger: 131,072 tokens (YaRN-extended)

## Hardware Sizing (Simon's machine: 64GB Mac)
- 0.6B / 1.7B: "should run fine on an iPhone"
- 32B dense: "will fit on my 64GB Mac with room to spare for other applications"
- Implication for our tool's GM-laptop tiers:
  - **16GB**: Qwen3-4B (Q4) or 8B (Q4_K_S, tight)
  - **32GB**: Qwen3-14B (Q4) comfortably; 30B-A3B MoE viable
  - **64GB**: Qwen3-32B (Q4-Q5) with apps running; 30B-A3B fast

## Performance Claims
"Qwen3-1.7B/4B/8B/14B/32B-Base performs as well as Qwen2.5-3B/7B/14B/32B/72B-Base, respectively." Strong STEM/coding focus.

## Capabilities for PF2e Tool
- **Hybrid thinking**: optional `<think>` reasoning block - useful for rules adjudication where step-by-step matters; toggleable per query
- **MCP**: first models specifically trained for Model Context Protocol - lowers integration cost for tool-using GM agents
- **Day-1 ecosystem support**: llama.cpp, Ollama, LMStudio, mlx-lm, SGLang, vLLM all shipped support at launch

## Why This Matters
Qwen3 is the only family that simultaneously satisfies (a) good-enough rules reasoning, (b) 128K context for whole-book canon stuffing, (c) tool/MCP capability, (d) sizes that span the GM laptop spectrum, (e) liberal license. As of mid-2026 it remains the default recommendation for "open-weight model that runs on a GM's laptop."

## Caveats
- Hybrid `<think>` mode adds latency; disable for fast lookups, enable for rules judgments
- Apache-2.0 license but still verify per-deployment if shipping commercially
