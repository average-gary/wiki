---
title: "PF2e Worldbuilding Tool — recommended stack (synthesis)"
type: topic
created: 2026-05-24
updated: 2026-05-24
verified: 2026-05-24
volatility: high
confidence: high
compiled-from: research-round-2026-05-24
sources:
  - all 38 raw sources from round 2026-05-24
tags: [pf2e, worldbuilding, desktop-app, llm, tauri, sqlite-vec, ollama, anthropic, markdown, automerge, synthesis]
---

# PF2e Worldbuilding Tool — recommended stack

Single-page synthesis across 5 research paths. Each section links to the deep concept article.

## TL;DR

> A **Tauri 2 desktop app**, with a **markdown-vault as canonical** + **SQLite + FTS5 + sqlite-vec mirror**, **Ollama (Qwen3) local-default + Anthropic cloud-optional** with **prompt caching for the world bible**, **Foundry pf2e schema** as the data-ingestion target, **ORC-only mechanics + opt-in Community Use Golarion pack** as the licensing posture, and **NovelCrafter's BYO-key model** as the LLM commercial pattern. Mobile is v2.

## The five decisions

| # | Decision | Recommendation | Concept article |
|---|----------|----------------|-----------------|
| 1 | Licensing posture | ORC-only binary (monetizable) + opt-in Community Use Golarion pack (free, properly attributed). Inherit Foundry pf2e's per-pack provenance metadata. | [[pf2e-licensing-posture]] |
| 2 | Market position | PF2e-native + LLM-native, Obsidian-vault-friendly. Either lifetime/$50 one-time + BYO key, or $5–$8/mo all-in with free local-LLM tier. | [[worldbuilding-tool-landscape-2026]] |
| 3 | Desktop stack | Tauri 2 + Sveltekit/React + SQLite + FTS5 + sqlite-vec + capability-gated plugin model copied from Obsidian's vault layout. | [[desktop-app-stack-recommendation]] |
| 4 | LLM integration | Ollama (Qwen3 4B/14B/32B by RAM tier) local-default + Anthropic Sonnet 4.6 cloud-optional with 1h prompt caching. RAG via sqlite-vec. Pydantic schemas → cloud structured output OR llama.cpp GBNF locally. Tools-in-a-loop agent pattern with mechanically checkable PF2e validators. | [[llm-integration-architecture]] |
| 5 | World data model | Markdown + YAML frontmatter as canonical; SQLite mirror for query; optional SurrealDB embedded for graph queries. Two-tier schema: schemaful mechanics (Foundry-style DataModel-per-subtype), schemaless lore (Obsidian-style frontmatter). Typed relations. Automerge as v2 sync. | [[world-data-model-recommendation]] |

## Architecture diagram (text)

```
┌─────────────────── User vault (filesystem folder) ───────────────────┐
│                                                                       │
│   campaigns/                                                          │
│     example/                                                          │
│       npcs/cassian.md          (markdown + frontmatter)               │
│       npcs/cassian.statblock.json   (Foundry pf2e-shaped)             │
│       locations/...                                                    │
│       sessions/...                                                     │
│       .pf2e-tool/                                                      │
│         index.db        ◄── SQLite + FTS5 + sqlite-vec rebuild       │
│         plugins/<id>/manifest.json                                     │
│         capabilities.json                                              │
│         license-provenance.json                                        │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
        ▲                                                  ▲
        │ file watch / two-way sync                        │
        │                                                  │ (v2)
┌───────┴──────────────────┐               ┌───────────────┴───────────┐
│   Tauri 2 (Rust core)    │               │   Automerge sync layer    │
│                          │               │   (doc-per-entity CRDT)   │
│   ├─ vault watcher       │               └───────────────────────────┘
│   ├─ schema validator    │
│   ├─ SQLite + sqlite-vec │
│   ├─ capability gate     │
│   └─ LLM client          │
│         ├─ Ollama (local)│
│         └─ Anthropic /   │
│            OpenAI / etc. │
└──────────┬───────────────┘
           │ IPC (capability-gated)
┌──────────┴────────────┐
│   Webview UI          │
│   (SvelteKit / React) │
│   + plugin host       │
└───────────────────────┘
```

## How the paths connect (cross-path findings)

These are the connections the per-path agents wouldn't have found on their own:

1. **Foundry pf2e is the gravitational center across three paths.** Path 1 ([[pf2e-licensing-posture]]) finds it's the only realistic data-ingestion target (Apache 2.0 schema, comprehensive packs). Path 2 ([[worldbuilding-tool-landscape-2026]]) finds Foundry's pf2e module is the gold standard for PF2e mechanics but cramped for worldbuilding. Path 5 ([[world-data-model-recommendation]]) finds Foundry's DataModel-per-subtype is the right schema pattern. **Conclusion: don't compete with Foundry on mechanics; ingest its schema, export back to JournalEntry/Actor packs, occupy the worldbuilding-wiki seat next to it.**

2. **NovelCrafter's BYO-key model + Ollama's local runtime + Anthropic's prompt caching converge on a single LLM commercial pattern.** Path 2 finds NovelCrafter is the lone proof of BYO-key + local-Ollama working commercially. Path 4 finds Ollama is the lowest-friction local runtime and Anthropic's 1h cache makes always-on world-bible feasible. **Conclusion: ship BYO-key by default, support cloud and local providers identically via Pydantic schemas, charge no inference margin.**

3. **sqlite-vec is the load-bearing component across desktop + LLM paths.** Path 3 picks it for the desktop stack. Path 4 picks it for RAG. Path 5 picks it for the SQLite mirror. **Conclusion: one `.db` file inside the vault folder holds relational + FTS + vector. Single engine, three workloads.**

4. **KuzuDB's archival forces a graph-DB rethink across paths 3 and 5.** Both paths landed on Kuzu independently as the natural pick; both flagged the 2025-10-10 archival as disqualifying. **Conclusion: avoid KuzuDB; treat embedded graph DB as optional, not required; SurrealDB embedded or CozoDB if needed; SQLite-on-recursive-CTE handles 1-2 hop queries fine.**

5. **Obsidian is the reference architecture from three angles.** Path 3 takes the vault-as-folder layout. Path 5 takes the markdown + YAML + wikilinks pattern. Path 2 finds GMs already use Obsidian + javalent stack despite the 5e bias. **Conclusion: the product should be "Obsidian for PF2e GMs" in shape — copy the vault model, fix Obsidian's plugin-permission gap with Tauri capabilities, fix Obsidian's untyped-backlinks gap with a typed-relation YAML convention.**

6. **The PF2e "rules-as-tools" gap is real and unsolved.** Path 2 finds nobody offers wiki + statblocks + encounter math + LLM in one place for PF2e. Path 4 finds existing AI-DM products fail at PF2e because action economy and trait math need symbolic computation. **Conclusion: structured PF2e rules exposed as agent tools (`xp_budget`, `validate_statblock`, `level_curve_check`) is the wedge — the LLM is the orchestrator/narrator, the rules engine is local code.**

## Implementation phasing

**Phase 0 (week 1–2)** — scaffold:
- Tauri 2 project, SvelteKit/React frontend, vault model.
- SQLite + FTS5 + sqlite-vec wired up.
- Foundry pf2e JSON ingestion (read-only).
- ORC license-provenance metadata on every record.

**Phase 1 (week 3–6)** — core wiki:
- Entity types (Character/NPC/Location/Faction/Quest/Event/Calendar/Note).
- Markdown + YAML frontmatter editor.
- Typed relations.
- Search (FTS5).

**Phase 2 (week 7–10)** — LLM integration:
- Ollama client with Qwen3 default.
- Anthropic provider with 1h prompt caching for world bible.
- Pydantic schema → JSON Schema → tool-use / GBNF.
- RAG via sqlite-vec; chunker by semantic boundary.
- Agent loop with PF2e tool set (`lookup_rule`, `xp_budget`, `validate_statblock`).

**Phase 3 (week 11–14)** — PF2e-native features:
- Statblock renderer (PF2e math, not 5e-cribbed).
- Encounter budget calculator.
- AoN linking.
- Foundry pf2e JournalEntry/Actor pack export.
- Eval harness for canon-faithfulness + statblock validity.

**Phase 4 (post-launch)** — polish:
- Plugin system with Tauri capability gates.
- Automerge sync (live multi-device).
- Mobile co-target via Tauri 2 mobile.
- Optional SurrealDB graph view for power-user queries.

## See also

- [[pf2e-licensing-posture]]
- [[worldbuilding-tool-landscape-2026]]
- [[desktop-app-stack-recommendation]]
- [[llm-integration-architecture]]
- [[world-data-model-recommendation]]
- [[rust-multi-platform]] (HUB topic — UI framework decision, cross-compile, signing)
