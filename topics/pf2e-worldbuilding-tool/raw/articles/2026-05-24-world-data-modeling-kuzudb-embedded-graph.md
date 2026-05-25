---
title: "KuzuDB — Embedded Property Graph Database"
source: "https://github.com/kuzudb/kuzu"
type: repo
date_fetched: 2026-05-24
date_published: 2025-10-10
tags: [data-model, graph-db, embedded, storage]
quality: 4
credibility: high
path: world-data-modeling
summary: "KuzuDB is an embeddable property-graph DB with Cypher, Python/JS/C++ bindings, columnar disk storage, ACID transactions, and built-in vector + full-text search. Caveat: archived by maintainers Oct 2025 — usable but no future development. Still the closest 'SQLite for graphs' that exists and a useful reference architecture even if we don't ship it."
---

# KuzuDB

## What it is
- Embedded **property-graph** database (one process, file-backed) — like SQLite but for graphs.
- Cypher query language (Neo4j-compatible subset).
- Columnar on-disk storage; CSR adjacency lists for fast traversal.
- Multi-core query parallelism, "novel and very fast" worst-case-optimal join algorithms.
- ACID, serializable transactions.
- MIT license.

## Bindings
- C++ (native, 70% of repo)
- Python (`kuzu` on PyPI)
- Node.js / JavaScript
- WASM (browser)
- **No official Rust binding** — community wrappers via the C API exist.

## Built-in capabilities
- Native vector index (good for embeddings + semantic search).
- Native full-text search.
- JSON extension.
- Graph algorithm extension (PageRank, BFS, etc.).
- Dynamic extension loader.

## Status (CRITICAL)
Project archived 10 Oct 2025. Releases remain installable; no new development. Forks are emerging but none are dominant yet.

## Relevance to our tool
1. **Right shape, wrong timing**: embedded property graph + Cypher is exactly what an LLM-friendly worldbuilding tool wants — but archival risk is real for a multi-year project.
2. **Cypher is LLM-friendly**: there's enormous training corpus. Tool-use over Cypher is a cleaner story than custom query DSLs.
3. **Vector index colocated with graph** is a unique value prop — semantic search ("find NPCs similar to this one") + graph traversal in one engine.
4. **Alternatives to evaluate**: SurrealDB (multi-model, active), CozoDB (Datalog over RocksDB, active, Rust-native), Neo4j embedded (deprecated), DuckDB-PGQ (newer, SQL/PGQ).
5. **Hybrid recommendation**: don't bet the canonical store on Kuzu. Use SQLite as canonical and project a graph view into Kuzu/Cozo on demand for analytical queries.
