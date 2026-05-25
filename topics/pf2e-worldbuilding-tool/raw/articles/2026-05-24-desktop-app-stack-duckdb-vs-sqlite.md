---
title: "DuckDB vs SQLite — analytical vs transactional embedded DBs"
source: "https://duckdb.org/why_duckdb"
type: article
date_fetched: 2026-05-24
date_published: "unknown"
tags: [embedded-db, duckdb, sqlite, olap, oltp]
quality: 4
credibility: high
path: desktop-app-stack
summary: "DuckDB targets analytical (OLAP) workloads; SQLite targets transactional (OLTP). DuckDB has bulk-optimized MVCC for ACID over analytical loads. v2.0 will move to C++17 (current stable not specified in source). DuckDB is suboptimal for high-frequency single-row writes — meaning for a typing-driven worldbuilding tool, SQLite is the chassis and DuckDB is at most an adjunct for analytics over campaign data."
---

# DuckDB vs SQLite for PF2e worldbuilding tool

## DuckDB positioning

- Adopted SQLite's "embedded, simple" philosophy but for **analytical** queries.
- "Custom, bulk-optimized MVCC" for ACID under analytical workloads.
- Native single-file format; also supports DuckLake / lakehouse formats scaling to petabytes.
- Optimal for: complex aggregations, large joins, bulk modifications, scanning many rows.
- **Suboptimal for**: high-frequency single-row transactional scenarios.
- DuckDB v2.0 will move to C++17 (per docs).

## What this means for a worldbuilding tool

The dominant write pattern in a worldbuilding app is: user types a paragraph → save row(s); user adds a single NPC → save row. This is OLTP and wants SQLite. There's no scenario in a single-user worldbuilding tool where DuckDB's analytical superpower (scanning millions of rows in parallel) materially helps.

**Possible adjunct use case**: import an entire AoN (Archives of Nethys) bestiary CSV/parquet dump, run analytics on stat distributions, encounter balancing math. Even there, SQLite is fine for the typical hundreds-to-thousands-of-rows scale.

## Decision

- **Primary embedded DB**: SQLite (+ FTS5 + sqlite-vec).
- **DuckDB**: only if a future feature genuinely needs columnar analytics over multi-million-row datasets (rare for a worldbuilding tool). At that point, embed it as a secondary store next to SQLite.
- **DO NOT** swap SQLite for DuckDB as the primary store.
