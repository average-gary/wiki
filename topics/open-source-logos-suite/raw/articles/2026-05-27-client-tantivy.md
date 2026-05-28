---
title: "Tantivy — Rust-Native Full-Text Search Library"
source_url: "https://github.com/quickwit-oss/tantivy"
type: repo
path: client
date_ingested: 2026-05-27
date_published: 2025-01-01
tags: [client, architecture, search, rust, morphology]
quality: 4
confidence: high
summary: "Tantivy is a Lucene-class Rust search library: BM25, configurable tokenizers, positional indexing, ~2x Lucene speed, sub-10ms startup. Lemma/morphology requires custom tokenizers via tantivy-tokenizer-api; no built-in Hebrew/Greek analyzer."
---

# Tantivy — Rust-Native Full-Text Search Library

## Key findings

- **Lucene-architecture Rust library** (not a server like Quickwit/Elasticsearch). BM25 scoring "the same as Lucene" per docs; AND/OR boolean operators; phrase queries (`"michael jackson"`); positional indexing via term-frequency-and-position config.
- **Performance**: "approximately 2x faster than Lucene" per project benchmarks; sub-10ms startup time; multithreaded indexing of English Wikipedia in under 3 minutes.
- **Tokenization**: configurable tokenizer pipeline with stemming for **17 Latin languages** built in. Third-party crates extend to CJK: `tantivy-jieba`, `cang-jie` (Chinese), `lindera`, `Vaporetto` (Japanese/Korean).
- **No built-in Hebrew/Greek/Aramaic analyzers** — must implement via `tantivy-tokenizer-api`. For biblical use cases this means the suite ships its own tokenizer crate that knows lemma + morphology codes (e.g., consumes STEPBible TAGNT/TAHOT tab-separated data).
- **Index model**: schema-defined fields, term frequency + position storage, custom analysis chains pre-index. Suits a Bible app where each verse is a document with parallel fields per language/version.
- **Library, not service**: lives in your binary. For a Tauri/Rust desktop app, no separate process. For mobile via UniFFI, embeddable but binary-size cost is real (Tantivy is heavier than SQLite FTS5).

## Notable quotes / specifics

- "Closer to Apache Lucene than Elasticsearch" — distinguishes it from Meilisearch (which is a hosted server).
- Quickwit (Tantivy's parent) is the search-server productization; for a desktop+mobile suite, Tantivy-the-library is the relevant piece.

## Source notes

For a Rust-core Logos clone, Tantivy is the upgrade path from SQLite FTS5 when the suite needs:
1. Rich custom analyzer pipelines (morphology + clause structure)
2. Faster mass-corpus indexing (entire Greek/Hebrew lexicon + commentaries + cross-references)
3. Better positional/proximity scoring than FTS5's NEAR

Cross-references the existing [[rust-multi-platform/ui-framework-decision]] research: Tauri 2 + Rust core + Tantivy is a coherent stack. UniFFI exposes the Tantivy index to native iOS/Android views per [[rust-multi-platform/mobile-ffi-decision-tree]]. Trade-off: Tantivy is Rust-only — if the suite ever needs a JS/Python/Swift companion app to read the index directly, FTS5 wins on portability.
