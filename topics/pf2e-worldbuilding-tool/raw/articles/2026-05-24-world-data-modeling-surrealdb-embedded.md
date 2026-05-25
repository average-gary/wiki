---
title: "SurrealDB — Embedded Multi-Model Database in Rust"
source: "https://surrealdb.com/docs/surrealdb/embedding/rust"
type: guide
date_fetched: 2026-05-24
date_published: unknown
tags: [data-model, multi-model, graph-db, document-db, embedded, rust]
quality: 4
credibility: high
path: world-data-modeling
summary: "SurrealDB embeds in a Rust process with RocksDB or SurrealKV file backends (or in-memory). It's multi-model: documents + graph edges + key-value + full-text + vectors in one engine, queried with SurrealQL. Strong fit for desktop apps that need typed entities AND cross-cutting graph queries without running a server."
---

# SurrealDB Embedded Mode

## Storage backends
- `Mem` — in-RAM, volatile (testing/cache).
- `RocksDB` — battle-tested LSM, good for write-heavy.
- `SurrealKV` — first-party LSM, optimized for SurrealDB's access patterns.
- File-based engines persist across restarts, single-file vault.

## Data model — multi-model in one engine
- **Documents** — schemaless or schemafull tables of records.
- **Graph edges** — first-class `RELATE` syntax: `RELATE character:gandalf->knows->character:frodo`.
- **Key-value** — direct record IDs `table:id`.
- **Full-text search** — built-in analyzers + indexes.
- **Vector search** — HNSW indexes for embeddings.
- **Time series** — partitioned tables.

## SurrealQL highlights
- Schemafull mode supports typed fields, `ASSERT` clauses, computed fields.
- Graph traversal: `SELECT ->knows->character.* FROM character:gandalf`.
- Permissions clauses on tables and fields (`PERMISSIONS FOR select WHERE …`).
- Live queries (subscriptions) for reactive UI.

## Rust embedding
```rust
let db = Surreal::new::<RocksDb>("vault.db").await?;
db.use_ns("world").use_db("campaign1").await?;
```
Same SurrealQL whether embedded or remote — easy to graduate to client-server.

## Relevance to our tool
1. **One-engine bet**: typed PF2e entities, freeform notes, graph relations, vector search over lore — all in one file. Avoids the orchestration tax of SQLite + Kuzu + a vector DB.
2. **Rust-native**, actively maintained, MIT/BSL licensed (check current).
3. **SurrealQL is more obscure than SQL or Cypher** — minor tax on LLM tool-use; mitigate with view definitions and a constrained tool API.
4. **Schemafull tables for canonical types** (Character, Location, Quest…) + **schemaless for user-created lore notes** is a clean compromise.
5. Live queries map well to a desktop UI that should refresh when an LLM agent edits the world.
