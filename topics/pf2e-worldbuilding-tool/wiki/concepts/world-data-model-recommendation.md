---
title: "World data model recommendation"
type: concept
created: 2026-05-24
updated: 2026-05-24
verified: 2026-05-24
volatility: medium
confidence: high
sources:
  - "[[2026-05-24-world-data-modeling-kanka-entity-types]]"
  - "[[2026-05-24-world-data-modeling-foundry-vtt-data-model]]"
  - "[[2026-05-24-world-data-modeling-kuzudb-embedded-graph]]"
  - "[[2026-05-24-world-data-modeling-surrealdb-embedded]]"
  - "[[2026-05-24-world-data-modeling-automerge-crdt]]"
  - "[[2026-05-24-world-data-modeling-local-first-software]]"
  - "[[2026-05-24-world-data-modeling-obsidian-properties]]"
  - "[[2026-05-24-world-data-modeling-digital-gardens-appleton]]"
tags: [data-model, schema, markdown, sqlite, graph-db, surrealdb, automerge, local-first, obsidian, kanka, foundry]
---

# World data model recommendation

**Markdown + YAML frontmatter as canonical source-of-truth, SQLite mirror for query, derived graph view for relations, Automerge later for live multi-device.** Two-tier schema: schemaful for mechanics, schemaless for lore.

## Recommended entity ontology

Copy from Kanka ([[2026-05-24-world-data-modeling-kanka-entity-types]]), narrow with Foundry/PF2e ([[2026-05-24-world-data-modeling-foundry-vtt-data-model]]):

**Core types**: Character, NPC, Creature, Location (hierarchical), Faction/Organization, Family, Item, Quest, Event, Era/Timeline, Calendar, Session/Journal, Note, Tag, Ability/Spell, Map.

**Typed relations** (first-class edges, not free-text wikilinks): `member_of`, `parent_of`, `enemy_of`, `located_in`, `occurred_at`, `wields`, `knows`, `worships`, `descended_from`.

## Two-tier schema

This is the most important decision. **Mechanics and lore have different shapes.**

### Mechanical layer (schemaful, validated)

PF2e statblocks: level, ancestry, traits, actions, AC/HP/saves, abilities. **Foundry-style DataModel-per-subtype** — `character`, `npc`, `hazard`, `loot`, `vehicle`, `familiar`, `party`. Validated against JSON Schema at write time. This layer is what the LLM tool-use endpoints ([[llm-integration-architecture]]) read and write.

### Lore layer (schemaless, freeform)

Relationships, history, prose. **Obsidian-style frontmatter + freeform body.** Backlinks, but **typed** (since Obsidian's `[[wikilinks]]` are untyped by default — a real weakness for worldbuilding). Use a YAML convention:

```yaml
---
title: Lord Cassian
type: npc
status: budding   # seedling | budding | evergreen (Appleton's garden ethos)
relations:
  - member_of: [[house-velerian]]
  - enemy_of: [[the-pale-circle]]
  - wields: [[sword-of-meridian]]
mechanical: characters/cassian.statblock.json
---
```

Lore links to mechanical entities by ID (the `mechanical:` field above). The mechanical record stays schemaful; the lore wraps it.

## Storage stack

```
Markdown vault (canonical, git-friendly, human-readable)
        │
        ├─→ JSON Schema validator (schemaful subset only)
        │
        ├─→ SQLite mirror (rebuilt on write)
        │     ├─ entities (id, type, frontmatter, body)
        │     ├─ relations (from_id, edge_type, to_id, properties)
        │     ├─ FTS5 index over body
        │     └─ sqlite-vec index over chunked embeddings ([[llm-integration-architecture]])
        │
        └─→ Optional graph view (SurrealDB embedded OR Cozo for power-user queries)
```

**Why markdown as canonical, not SQLite**:
- Git/Dropbox sync gets you 5 of Ink & Switch's 7 local-first ideals ([[2026-05-24-world-data-modeling-local-first-software]]) for free.
- Lock-in resistance: if the company dies, the user's wiki is plain text.
- Pairs with Obsidian's vault model out of the box ([[desktop-app-stack-recommendation]]).
- Round-trips with LLM agents naturally — the agent reads MD, edits, the validator checks the schemaful subset, the SQLite mirror rebuilds.

**Why SQLite mirror, not just markdown grep**:
- FTS5 + relational joins + sqlite-vec in one query.
- Tool-use endpoints for the LLM (`get_entity`, `list_entities`, `find_relations`, `search`) need fast indexed reads, not file-grep.
- Rebuild is cheap (incremental on file-watch).

**Why optionally a graph DB, not graph-on-SQLite**:
- For Cypher/SurrealQL queries by power users.
- **AVOID KuzuDB** — archived 2025-10-10 ([[2026-05-24-world-data-modeling-kuzudb-embedded-graph]]). Was the natural pick; now isn't.
- **SurrealDB embedded** ([[2026-05-24-world-data-modeling-surrealdb-embedded]]) is the only multi-model embedded option after Kuzu's archival — graph + doc + KV + FTS + vector + live queries, all Rust-native.
- **CozoDB** is a strong active alternative (Datalog, RocksDB, Rust-native) — needs follow-up research.
- Most worldbuilding queries are 1-2 hop and SQLite handles them fine. Graph DB is optional.

## Sync story

Phase 1 (v1): **git or Dropbox sync of the markdown vault.** Gets ideals 1, 2, 3, 5, 7 from [[2026-05-24-world-data-modeling-local-first-software]] cheaply, no real-time collab.

Phase 2: **Automerge layer for live co-editing** ([[2026-05-24-world-data-modeling-automerge-crdt]]). JSON-shape CRDT, Rust core + JS/WASM/C/Swift bindings, rich-text CRDT included. Automerge 3 cut memory ~10×. **Doc-per-entity Automerge maps cleanly to file-per-entity markdown** — they coexist; Automerge is the live layer, markdown is the export/portability format.

## What to copy, what to invent

**Copy from Kanka**:
- Polymorphic entity wrapper (one `entities` table, type discriminator).
- Sub-resources pattern: relations, posts, attributes/EAV, mentions, inventory, tags, permissions all attach to any entity.
- Typed relations with free-text "the relationship" annotation + visibility + two-way flag.
- Posts (multiple body sections per entity — better than Foundry's single body).

**Copy from Foundry**:
- DataModel-per-subtype on the mechanical layer.
- Embedded vs linked discipline: embed when child can't outlive parent (Token, JournalEntryPage); link by ID otherwise.
- JournalEntryPage as the "long-form prose inside a typed entity" pattern.
- Folders as orthogonal organizational tree (separate from type hierarchy).

**Copy from Obsidian** ([[2026-05-24-world-data-modeling-obsidian-properties]]):
- File = entity, YAML = fields, body = prose.
- Wikilinks as the user-facing relation primitive (but **type them**, see above).

**Invent**:
- Typed-relation YAML convention (Obsidian backlinks are untyped — biggest weakness).
- `status: seedling | budding | evergreen` field for lore-readiness ([[2026-05-24-world-data-modeling-digital-gardens-appleton]]).
- LLM-tool-API spec wrapping the SQLite mirror (`get_entity`, `list_entities`, `find_relations`, `search`, `update_entity` with patch + validate).
- License-provenance field on every record (per [[pf2e-licensing-posture]] — ORC vs OGL vs Community Use vs homebrew).

## LLM-friendliness

Expose this tool API to the agent ([[llm-integration-architecture]]):

| Tool | Purpose |
|------|---------|
| `get_entity(id)` | by-id read |
| `list_entities(type, filters)` | typed list with predicate |
| `find_relations(entity_id, edge_type?)` | graph step |
| `search(query)` | FTS5 + sqlite-vec hybrid |
| `update_entity(id, patch)` | round-trip via markdown file → validator → SQLite rebuild |

Round-trip discipline: agent reads markdown → edits → validator checks schemaful subset → SQLite mirror rebuilds. Cypher/SurrealQL exposure is optional power-user surface, not the agent default.

## See also

- [[pf2e-licensing-posture]] — license provenance metadata on each record
- [[desktop-app-stack-recommendation]] — SQLite + sqlite-vec in a single .db inside the vault
- [[llm-integration-architecture]] — the tool API the agent calls
- [[worldbuilding-tool-landscape-2026]] — Kanka and Foundry as the schema references
- [[recommended-stack]] — full integrated stack

## Open questions

- **CozoDB** deep-dive (Datalog/RocksDB, Rust-native, active) — strongest active alternative to KuzuDB.
- **Yjs vs Automerge** comparative ingest — Yjs has better existing editor integrations.
- World Anvil templates blocked by 403/404 this round.
- Andy Matuschak's evergreen-notes essay returned thin content — re-ingest from `notes.andymatuschak.org` directly.
- TTRPG-on-Obsidian community plugins (RPG Manager, Fantasy Statblocks, Initiative Tracker) — survey their schema conventions.
