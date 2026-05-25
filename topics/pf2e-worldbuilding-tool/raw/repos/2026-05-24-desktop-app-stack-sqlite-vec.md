---
title: "sqlite-vec — vector search SQLite extension"
source: "https://github.com/asg017/sqlite-vec"
type: repo
date_fetched: 2026-05-24
date_published: "2026-03-31"
tags: [embedded-db, sqlite, vector-search, rag, sqlite-vec]
quality: 5
credibility: high
path: desktop-app-stack
summary: "sqlite-vec v0.1.9 (Mar 2026) — pure-C, zero-dep SQLite extension; successor to sqlite-vss. Float/int8/binary vectors via `vec0` virtual tables; brute-force + IVF + DiskANN indexes in-tree. Pre-v1 with breaking-change warning. Sponsors: Mozilla Builders, Fly.io, Turso, SQLite Cloud, Shinkai. Runs on Linux/macOS/Windows/WASM/embedded. Bindings: Python, Node, Ruby, Go, Rust."
---

# sqlite-vec for PF2e worldbuilding tool RAG

## Status

- **v0.1.9**, March 31, 2026 (DELETE bug fix). 88 total releases. **Pre-v1 — breaking changes expected.**
- 7.6k GitHub stars, 318 forks, multi-sponsor support including Mozilla.
- Successor to sqlite-vss (which Alex deprecated in favor of sqlite-vec).

## Architecture

- Pure C, zero deps. Loadable as `.so/.dylib/.dll` or compiled into your app.
- `vec0` virtual table type. Stores vectors + scalar metadata + partition keys.
- Vector formats: float32, int8, binary (1-bit packed).
- Index strategies present in repo:
  - `sqlite-vec-ivf.c` — IVF inverted file
  - `sqlite-vec-ivf-kmeans.c` — IVF with k-means clustering
  - `sqlite-vec-diskann.c` — DiskANN
  - Plus default brute-force exact KNN
- Metadata filtering alongside vector search (i.e. `WHERE region = 'Absalom' ORDER BY distance LIMIT 10`).

## Why this fits PF2e tool

1. **Already have SQLite** — if the app uses SQLite + FTS5 for canon search, sqlite-vec is `LOAD EXTENSION` away. No second database process.
2. **Single-file persistence** — `.db` file ships in user's vault folder; aligns with file-system-canon design.
3. **Cross-platform**: Tauri can statically link the extension; works on iOS/Android/WASM too.
4. **Mozilla-sponsored** — better long-term odds than a startup-owned vector DB.

## Caveats vs alternatives

- **Pre-v1**: production-shipping it means pinning a version + tracking the changelog.
- vs **LanceDB**: Lance has a more sophisticated columnar format + built-in versioning ("Lance format") + better huge-corpus performance, but it's a separate dependency and a startup product.
- vs **Chroma**: Chroma is Python-first, server-shaped; awkward to embed in Rust/Tauri.
- vs **KuzuDB**: Kuzu was archived October 10, 2025 (see kuzu-archived note) — do NOT pick it.

## Recommendation

For PF2e tool RAG over canon + campaign notes: **SQLite + FTS5 + sqlite-vec** in one DB file, accessed from the Rust backend, exposed via capability-gated IPC commands.
