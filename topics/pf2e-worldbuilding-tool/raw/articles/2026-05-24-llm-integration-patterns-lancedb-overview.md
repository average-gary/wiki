---
title: "LanceDB - embedded multimodal vector database"
source: "https://lancedb.com/blog"
type: article
date_fetched: 2026-05-24
date_published: "2025-11-01"
tags: [rag, vector-db, embedded, hybrid-search, local-first]
quality: 4
credibility: high
path: llm-integration-patterns
summary: "LanceDB is the heavier-weight alternative to sqlite-vec for embedded vector search: columnar Lance format, IVF-PQ + HNSW + RaBitQ indexes, native hybrid search (vector + BM25), Python/Rust/JS/Java SDKs. Better choice when canon grows past ~100K chunks or hybrid search is required out-of-box."
---

# LanceDB for PF2e Worldbuilding RAG

## What It Is
AI-native multimodal lakehouse on the open-source Lance columnar format. Embedded mode (no server) is the relevant deployment for a desktop GM app.

## Storage
- Lance v2.2: 50%+ compression vs Parquet
- Up to 68x faster blob reads
- Columnar - good for filtering large fact tables (NPCs, locations, items) before vector search

## Indexing
- **IVF-PQ** (default for large): inverted file + product quantization
- **HNSW**: graph index, lower recall floor with high QPS
- **RaBitQ**: newer quantization for fast/compact search

## Hybrid Search
**Native** - vector + BM25 + SQL filter in one query. For PF2e:
```python
table.search("undead resistant to fire")
  .where("level <= 8 AND source = 'bestiary-1'")
  .rerank(reranker)
  .limit(10)
```
Demonstrated at 41M Wikipedia docs (FTS) and 10B-scale vector search.

## SDKs
- Python (most mature)
- Rust (embedded core)
- JS/TS (embedded for desktop apps - "developer privacy" emphasized)
- Java

## When to Pick LanceDB over sqlite-vec
| Need | Pick |
|------|------|
| Single-file portability, joinable with relational data | sqlite-vec |
| Out-of-box hybrid (BM25 + vector) | LanceDB |
| Multimodal (images of maps/tokens) | LanceDB |
| <50K chunks, simple semantic search | sqlite-vec |
| 100K+ chunks, complex filtering | LanceDB |
| Tauri/Electron with minimal deps | sqlite-vec |
| Full-text search at scale | LanceDB |

## Use Cases Cited
- Local-first AI agent memory layers
- Multimodal data curation
- Semantic code search

## Recommendation for PF2e Tool
Start with **sqlite-vec** (single-file campaign DB is a better UX for backups/sharing). Migrate to **LanceDB** only if hybrid search or multimodal (encounter maps, token art search) becomes a hard requirement.
