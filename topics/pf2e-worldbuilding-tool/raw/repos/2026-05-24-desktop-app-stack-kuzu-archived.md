---
title: "KuzuDB — archived October 2025 (avoid for new projects)"
source: "https://github.com/kuzudb/kuzu"
type: repo
date_fetched: 2026-05-24
date_published: "2025-10-10"
tags: [embedded-db, graph-database, kuzu, archived, avoid]
quality: 5
credibility: high
path: desktop-app-stack
summary: "KuzuDB repository archived Oct 10, 2025 at v0.11.3 — read-only. Was an embedded property-graph DB with Cypher, FTS, vector indexing, columnar storage. 3.9k stars, MIT license. Existing releases remain usable but no future development. Material finding: do NOT pick KuzuDB for the PF2e worldbuilding tool's relationship/lineage graph."
---

# KuzuDB — archived (critical decision input)

## Status

- **Archived October 10, 2025**, repo read-only.
- Final version: **v0.11.3** (Oct 10, 2025), bundles "many (but not all) of the extensions."
- 3,900+ stars, 477 forks, 36 releases, 5,231 commits.
- License: MIT.

## What it was

- Embedded graph DB with Cypher query language.
- Property-graph model.
- Columnar disk storage + vectorized query processing.
- Built-in **full-text search + vector indexing** — was a strong contender for "single embedded DB for graph+text+vector" until archival.
- C++ 69.7%, Cypher 18.4%, with Python/JS/Java/Rust bindings.
- Targeted "complex analytical workloads on very large databases."

## Implication for PF2e tool

A worldbuilding tool benefits from graph queries (NPC ↔ faction ↔ location ↔ event lineage). Kuzu would have been ideal. With archival:

| Need | Replacement |
|------|-------------|
| Embedded graph + Cypher | **None production-grade in 2026.** SurrealDB embedded is the closest (but has its own maturity questions). |
| Graph relationships in SQLite | Recursive CTEs + edge tables; manual but reliable. |
| Graph + vector + FTS in one DB | **SQLite + FTS5 + sqlite-vec + edge tables** — pragmatic combo. |

## Recommendation

Replace any "use Kuzu for canon graph" plans with: SQLite recursive CTE edge tables. Re-evaluate SurrealDB only if graph queries become central; otherwise the SQLite stack is simpler and won't get archived.
