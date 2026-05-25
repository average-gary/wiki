---
title: "LLM integration architecture for a PF2e GM tool"
type: concept
created: 2026-05-24
updated: 2026-05-24
verified: 2026-05-24
volatility: high
confidence: high
sources:
  - "[[2026-05-24-llm-integration-patterns-anthropic-prompt-caching]]"
  - "[[2026-05-24-llm-integration-patterns-sqlite-vec]]"
  - "[[2026-05-24-llm-integration-patterns-llamacpp-grammars]]"
  - "[[2026-05-24-llm-integration-patterns-qwen3-overview]]"
  - "[[2026-05-24-llm-integration-patterns-ollama-blog-roundup]]"
  - "[[2026-05-24-llm-integration-patterns-designing-agentic-loops]]"
  - "[[2026-05-24-llm-integration-patterns-llm-schemas-structured-output]]"
  - "[[2026-05-24-llm-integration-patterns-lancedb-overview]]"
tags: [llm, rag, ollama, anthropic, prompt-caching, structured-output, agent-loops, local-llm, qwen3, sqlite-vec]
---

# LLM integration architecture for a PF2e GM tool

Provider-agnostic, local-default, cloud-optional. The wiki is the canon; the LLM is the orchestrator.

## Local LLM stack (2026 GM laptop)

**[[2026-05-24-llm-integration-patterns-ollama-blog-roundup]]** + **[[2026-05-24-llm-integration-patterns-qwen3-overview]]**:

| RAM | Default model | Fallback |
|-----|---------------|----------|
| 16 GB | `qwen3:4b` or `qwen3:8b` | `gemma3:4b` |
| 32 GB | `qwen3:14b` or `qwen3:30b-a3b` (MoE) | `mistral-small:24b` |
| 64 GB | `qwen3:32b` (with `<think>` mode) | `llama4:scout` |

- **Runtime**: Ollama for the desktop default (lowest-friction, native macOS/Win app since Jul 2025, structured outputs Dec 2024, tool calling Jul 2024, streaming+tools May 2025, cloud models same API surface Sept 2025).
- **Drop down to llama.cpp directly** when GBNF grammar control is needed for hard schema enforcement.
- **Embeddings**: `nomic-embed-text` or `bge-m3` (768-dim, multilingual).
- **Hybrid `<think>` mode** on Qwen3 for rules adjudication; off for fast lookups.

## Cloud LLM stack

**[[2026-05-24-llm-integration-patterns-anthropic-prompt-caching]]**:
- **Sonnet 4.6** for at-table real-time use (latency + reasoning quality matter).
- **Opus 4.7** for hard rules judgments and complex encounter design.
- **Prompt caching**: 5-min cache (1.25× write) and 1-hour cache (2× write); reads at 0.1× base. Min cacheable tokens: 4,096 for Opus 4.5+ / Haiku 4.5; 1,024 for Sonnet 4.6/4.5. 4 explicit breakpoints per request, 20-block lookback. Pre-warm via `max_tokens: 0` to eliminate first-call latency. Workspace-level cache isolation rolled out Feb 2026.
- **Caching strategy**: place the static world bible + PF2e rules digest in `system` with `cache_control: {type: "ephemeral", ttl: "1h"}`. For 60K-token canon: ~$0.018/call cached read vs $0.18/call uncached on Sonnet 4.6 → ~10× reduction makes always-on canon feasible.

## RAG architecture

**[[2026-05-24-llm-integration-patterns-sqlite-vec]]** is the embedded vector layer (also chosen in [[desktop-app-stack-recommendation]]).

```
World canon (markdown vault)
   │
   ├─→ chunker (semantic boundary: NPC, location, scene; 500–800 tok, 100 overlap)
   │
   ├─→ embedder (bge-m3 or nomic-embed-text, 768d)
   │
   └─→ sqlite-vec vec0 vtable (alongside relational metadata: campaign_id, region,
                                canon_status, last_updated, license_provenance)
```

**Query path**: SQL filter first (campaign + canon-only + non-spoiler) → vector search → optional rerank with a stronger model. Single SQLite file ships with the campaign ([[world-data-model-recommendation]]).

## Structured output for PF2e statblocks

**[[2026-05-24-llm-integration-patterns-llm-schemas-structured-output]]** + **[[2026-05-24-llm-integration-patterns-llamacpp-grammars]]**:

- **Define Pydantic models once**: `Monster`, `Spell`, `Encounter`, `NPC`, `Hazard`, `Location`. Provider-agnostic; swap providers without rewrites.
- **Cloud path**: Anthropic tool-use OR OpenAI Structured Outputs (both consume JSON Schema directly).
- **Local path**: convert schema → GBNF via llama.cpp's `json_schema_to_grammar.py` OR pass the schema to Ollama's `format` field.
- **Critical caveat (llama.cpp grammars)**: schema is NOT injected into the prompt — must describe in text. Use `x{0,N}` syntax over repeated optionals for perf.
- **Two-stage pattern**: structured fields first (mechanically valid statblock), then unconstrained "flavor prose" second (description, motivations, hooks). This separates correctness from creativity.

## Agent loop pattern (PF2e GM assistant)

**[[2026-05-24-llm-integration-patterns-designing-agentic-loops]]** (Willison): "tools in a loop." Works only with **clear, mechanically checkable success criteria**.

Tools to expose:
- `lookup_rule(id)` — PF2e rules digest
- `lookup_monster(name|level|trait)` — Monster Core / Bestiary search
- `xp_budget(party_level, party_size, encounter_difficulty)` — encounter math
- `level_curve_check(stat, level)` — verify a generated NPC sits in PF2e's expected band
- `validate_statblock(json)` — schema + math + trait-coherence
- `search_canon(query)` — wiki RAG (see above)
- `write_canon(entity_id, patch)` — wrap in dry-run + diff; eval before commit

**Constraints**:
- Bound iterations (5–10) and token spend per task.
- Three risks per Willison: destructive ops, exfiltration, attack proxy. The Tauri capability layer ([[desktop-app-stack-recommendation]]) is the runtime answer to all three.
- Without evals, agent loops are unbounded model calls. Build an eval harness early (held-out QA over canon + statblock validity scores).

## Honest assessment of existing AI-GM tools

Existing AI-DM products (AI Dungeon, Friends & Fables, Chronicles, Chatbot DMs) handle narrative improv well but **fail at PF2e specifically** because:

1. **Action economy and degrees-of-success math** need symbolic computation, not next-token prediction.
2. **Trait-based interactions** (e.g., "fire vs cold-iron resistance with persistent damage") require a structured rule engine.
3. **Encounter XP budgeting** is arithmetic, not narrative.

**The unsolved gap**: structured PF2e rules as tools + LLM as orchestrator/narrator. None of the AI-DM products do this well today. This is the wedge for a PF2e-native tool.

## Provider strategy

- **Local-default for prep work** (cost, privacy of homebrew, offline at the table).
- **Cloud (Anthropic Sonnet 4.6 with 1h cache) for hard rules judgments** and at-table real-time when latency / reasoning quality matter.
- **BYO-key architecture** — copy the [[2026-05-24-wb-tool-landscape-novelcrafter]] model. User pays for inference directly; product takes no margin on tokens.
- **Provider-agnostic Pydantic schemas** ([[2026-05-24-llm-integration-patterns-llm-schemas-structured-output]]) keep provider lock-in low.

## See also

- [[desktop-app-stack-recommendation]] — sqlite-vec lives in the same SQLite file as relational data
- [[world-data-model-recommendation]] — chunking strategy follows the entity model
- [[pf2e-licensing-posture]] — what canon can be shipped vs what users must supply
- [[worldbuilding-tool-landscape-2026]] — NovelCrafter as the BYO-key reference
- [[recommended-stack]] — full integrated stack

## Open questions

- r/Pathfinder2e community sentiment on AI-DM tools (Reddit blocked this round).
- MTEB leaderboard 2026 specifics (HuggingFace blog 404'd) — embedding picks are general 2025 reputation, not freshly verified.
- Direct AI-DM product reviews (Friends & Fables, Chronicles).
- Concrete chunking benchmarks for fiction/worldbuilding text — current rec is general RAG practice, not PF2e-tested.
- mistral.rs / vLLM 2026 positioning (no dedicated source this round).
