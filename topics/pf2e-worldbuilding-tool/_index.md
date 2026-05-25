---
title: "Pathfinder 2e Worldbuilding Tool"
type: topic
created: 2026-05-24
updated: 2026-05-25
status: active
---

# Pathfinder 2e Worldbuilding Tool

## Driving Case

Design and build a worldbuilding tool for the Pathfinder 2e (PF2e) tabletop RPG that ships as both a **desktop app** (offline-capable, file-system-friendly) and an **LLM-integrated app** (chat-with-your-world, generative content, smart entity linking).

The tool should let a Game Master (GM) or worldbuilder:
- Capture a homebrew or canon setting (regions, factions, cities, NPCs, deities, religions, calendars, languages, timelines, plot threads, encounters)
- Stay rules-aware for PF2e (statblocks, traits, level math, encounter budget, treasure-by-level)
- Use an LLM as a creative collaborator that respects the world's canon and the system's rules
- Run locally first (privacy + offline at the table), with optional cloud LLMs

## Sub-questions (research paths)

`--plan --deep` round on 2026-05-24, 5 paths × 8 agents:

1. **pf2e-srd-data** — ORC license, Archives of Nethys, Foundry pf2e data, Paizo Community Use Policy, Remaster
2. **wb-tool-landscape** — Kanka, World Anvil, LegendKeeper, Foundry VTT, NovelCrafter, Obsidian + javalent, Campfire/Plottr/Inkarnate
3. **desktop-app-stack** — Tauri 2 vs Electron 42, embedded SQLite + sqlite-vec, Obsidian plugin model, packaging/signing 2026
4. **llm-integration-patterns** — Ollama (Qwen3), Anthropic prompt caching, sqlite-vec RAG, llama.cpp grammars, agent loops
5. **world-data-modeling** — Kanka entity types, Foundry DataModel, markdown-as-canonical, SurrealDB/CozoDB/Kuzu (archived), Automerge, Local-First

## Theses

(none yet — topic-mode survey first; see Topic Articles for the synthesized recommendation)

## Topic Articles (synthesis)

- [recommended-stack](wiki/topics/recommended-stack.md) — single-page synthesis across all 5 paths

## Concept Articles

- [pf2e-licensing-posture](wiki/concepts/pf2e-licensing-posture.md) — ORC vs OGL vs Community Use vs Pathfinder Infinite; the "free or Infinite" fork
- [worldbuilding-tool-landscape-2026](wiki/concepts/worldbuilding-tool-landscape-2026.md) — Kanka, World Anvil, LegendKeeper, Foundry, NovelCrafter, Obsidian
- [desktop-app-stack-recommendation](wiki/concepts/desktop-app-stack-recommendation.md) — Tauri 2 + SQLite + sqlite-vec; capability-gated plugin model
- [llm-integration-architecture](wiki/concepts/llm-integration-architecture.md) — Ollama + Anthropic, RAG, structured output, agent loops
- [world-data-model-recommendation](wiki/concepts/world-data-model-recommendation.md) — markdown-canonical + SQLite mirror; two-tier schema

## Reference Articles

- [pf2e-remaster-name-mapping](wiki/reference/pf2e-remaster-name-mapping.md) — ~330 legacy ↔ Remaster rename pairs + taxonomy shifts (alignment, schools removed, mechanical reworks)

## Sources

- [raw/_index.md](raw/_index.md) — 48 sources (38 from Round 1, 10 from gap-closing round)

## Output

- [output/_index.md](output/_index.md) — (no playbook artifact this round; topic-mode survey produced concept articles + synthesis)

## Stats

- Articles: 7 (1 topic synthesis + 5 concept + 1 reference)
- Sources ingested: 48 (39 articles, 8 repos, 1 guide)
- Research dates:
  - 2026-05-24 — Round 1 (--plan --deep, 5 paths × 8 agents): 38 sources, 6 articles
  - 2026-05-24 — Gap-closing round (4 parallel paths): 10 new sources, 1 new reference article, 2 concept articles materially updated

## Cross-references to other HUB topics

- [[rust-multi-platform]] — UI framework decision, desktop cross-compile, packaging/signing economics. Reusable as-is for the desktop stack; PF2e-specific concerns layered on top in [[desktop-app-stack-recommendation]].

## Logs

- [log.md](log.md)
