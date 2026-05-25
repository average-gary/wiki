---
title: "sqlite-vec: vector search SQLite extension"
source: "https://github.com/asg017/sqlite-vec"
type: repo
date_fetched: 2026-05-24
date_published: "2026-03-31"
tags: [rag, vector-db, sqlite, embedded, local-first]
quality: 5
credibility: high
path: llm-integration-patterns
summary: "Pure-C SQLite extension for vector search - the leading embedded vector store for local-first desktop apps. v0.1.9 (Mar 2026), runs everywhere (Linux/macOS/Windows/WASM/Pi). Successor to sqlite-vss, no dependencies."
---

# sqlite-vec - Embedded Vector DB for PF2e Tool

## Status (May 2026)
- Latest: **v0.1.9** (March 31, 2026)
- Still pre-1.0; breaking changes possible
- Pure C, no dependencies
- Cross-platform: Linux, macOS, Windows, WebAssembly, Raspberry Pi

## Vector Types
- `float` (32-bit)
- `int8` (quantized, smaller)
- `binary` (1-bit, smallest, fast Hamming distance)

For a worldbuilding app with ~10K-50K chunks, `float` works fine; `int8` cuts storage 4x.

## Index Types
- Flat (brute force) - default for `vec0` virtual tables
- IVF (inverted file) - in `sqlite-vec-ivf.c`
- DiskANN - in `sqlite-vec-diskann.c`

## SQL Surface
```sql
CREATE VIRTUAL TABLE vec_examples USING vec0(
  sample_embedding float[768]
);

SELECT rowid, distance
FROM vec_examples
WHERE sample_embedding MATCH '[0.1, 0.2, ...]'
ORDER BY distance
LIMIT 10;
```

Metadata stays in regular SQLite columns alongside vectors - lets you filter by world/region/canon-status before/after vector search.

## Language Bindings
- Python: `pip install sqlite-vec`
- Node.js: `npm install sqlite-vec`
- Ruby: `gem install sqlite-vec`
- Rust, Go: standard package managers
- Datasette, rqlite plugins available

## Why This Beats Alternatives for PF2e Desktop App
1. **Single-file portability**: campaign DB = one .sqlite file, easy to back up/sync/share
2. **No daemon**: Chroma/Qdrant/Weaviate require a running server; sqlite-vec is in-process
3. **Joins**: vector hits join with relational tables (chunks <-> documents <-> campaigns)
4. **Tauri/Electron compatible**: ships with the app

## Limitations
- Pre-1.0: schema evolution may require rebuilds
- No native hybrid (BM25 + vector) - layer SQLite FTS5 separately and merge in app code
- Max dims not specified in docs; community reports comfortable to ~1536 dims
