---
title: "SurrealDB embedded mode — multi-model in-process DB"
source: "https://surrealdb.com/docs/surrealdb/embedding"
type: guide
date_fetched: 2026-05-24
date_published: "unknown"
tags: [embedded-db, surrealdb, graph-database, document-store, multi-model]
quality: 4
credibility: high
path: desktop-app-stack
summary: "SurrealDB ships embedded mode with no network overhead — full query engine in-process. Official bindings: Rust, Go, JavaScript, Python, .NET. Browser support via IndexedDB (serializes data into Uint8Array binary KV). Strong fit for local-first apps that want graph+document+KV in one DB; replaces archived KuzuDB as the plausible 'single multi-model' choice but with its own maturity questions."
---

# SurrealDB embedded for PF2e tool

## Capabilities

- "Run SurrealDB directly inside your application process. Embedded mode gives you the full query engine with no network overhead."
- Bindings: Rust, Go, JavaScript, Python, .NET.
- Browser: IndexedDB serializing to Uint8Array.
- Multi-model: graph + document + key-value in one engine, plus full-text search and vector search (in recent releases).
- Storage backends include RocksDB, SurrealKV, in-memory.
- Query language: SurrealQL (SQL-like with graph traversal extensions).

## For a worldbuilding tool — pros

- One DB for: NPC docs, faction graph edges, vault metadata, vector embeddings, full-text. No 3-tier sqlite+vec+edge-table dance.
- Embedded Rust binding pairs naturally with Tauri backend.
- Live queries (subscriptions) — useful for collaborative or LLM-streaming UIs.

## Cons / risk

- Younger than SQLite (decade of trust gap).
- Schema evolution patterns less documented than SQLite migrations.
- Performance characteristics for single-user-on-laptop workloads less battle-tested than SQLite.
- Primary distribution emphasis is server mode; embedded is well-supported but a smaller share of the user base.

## Decision lens

- **Default pick**: SQLite + FTS5 + sqlite-vec (boring tech, file-as-canon, runs on iOS/WASM).
- **Pick SurrealDB if**: graph relationships dominate the data model AND you want live queries AND you're comfortable absorbing the maturity risk.
- **Avoid mixing both** as primary stores — pick one chassis.
