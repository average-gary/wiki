---
title: "SQLite FTS5 — Full-Text Search Engine for Cross-Platform Apps"
source_url: "https://www.sqlite.org/fts5.html"
type: article
path: client
date_ingested: 2026-05-27
date_published: 2025-01-01
tags: [client, architecture, search, cross-platform, hebrew, greek, morphology]
quality: 5
confidence: high
summary: "Official SQLite FTS5 docs: BM25 ranking, Unicode61 tokenizer for Hebrew/Greek, NEAR/phrase/prefix queries, and patterns for morphological lemma search via custom tokenizers and external content tables."
---

# SQLite FTS5 — Full-Text Search Engine for Cross-Platform Apps

## Key findings

- **BM25 ranking is built-in** (`ORDER BY rank` or explicit `bm25(table, col1_weight, col2_weight)`). Same family of scoring as Lucene/Tantivy. Lower scores = better matches (negated).
- **Four tokenizers ship**: `unicode61` (default, Unicode 6.1 categories — works for Hebrew/Greek out of the box), `ascii` (Latin only), `porter` (English stemming wrapper around another tokenizer), `trigram` (3-char substring matching, enables non-tokenized substring search).
- **`unicode61` handles Hebrew/Greek**: General categories `L*` (all letters) + `N*` (numbers) treat Hebrew (Lo "other letter") and Greek scripts as token characters. `remove_diacritics 2` (v3.31.0+) properly handles Greek polytonic accents and Hebrew points/cantillation.
- **Phrase, NEAR, prefix, boolean queries supported**: `MATCH '"hesed olam"'`, `MATCH 'NEAR("logos theos", 5)'`, `MATCH 'agap*'`, `MATCH 'one OR two NOT three'`. NEAR with explicit window is critical for biblical clause-level search.
- **Column filtering**: `MATCH 'hebrew_text : ahab*'` lets one FTS5 table host multiple parallel columns (Hebrew, Greek, English, Latin) and query each independently.
- **Morphological lemma search has 3 patterns**:
  1. **Custom tokenizer with `tokendata=1`** — emits `lemma\0original_form`, indexes lemma but preserves surface form for highlighting.
  2. **External content table with separate `lemma_text` column** — store source text in main table, index lemmas via `content=docs, content_rowid=id`, JOIN back for display. Cleanest for biblical apps where you need both surface text AND lemma.
  3. **Auxiliary functions** — `xCreateFunction` callbacks for runtime lemma lookup.
- **Detail levels** — `detail='full'` (default, supports NEAR/phrase), `detail='column'` (no NEAR), `detail='none'` (rowid only). Biblical search needs `full` for original-language proximity queries.
- **Contentless tables** (`content=''`) reduce disk for index-only scenarios.

## Notable quotes / specifics

- Custom tokenizer registration via C API: `fts5_tokenizer_v2` struct with `iVersion=2`, `xCreate`, `xDelete`, `xTokenize` — registered through `pApi->xCreateTokenizer_v2()`.
- Highlight + snippet auxiliary functions ship: `highlight(ft, 0, '<b>', '</b>')`, `snippet(ft, 0, '<b>', '</b>', '...', 20)`.
- Initial-token query `MATCH '^one'` — useful for verse-start matching.

## Source notes

This is the canonical reference. Decision-grade for the suite: SQLite ships everywhere (iOS, Android, Linux, macOS, Windows, WASM via sql.js/SQLite-WASM), is embedded (no separate server process), and the FTS5 schema can absorb Hebrew/Greek lemma indexing via custom tokenizer or external-content patterns. Compared to Tantivy (Rust-only, library-not-server) and Meilisearch (separate server, hosted-mode), FTS5 is the cross-language, cross-platform default. For a Logos-style suite, FTS5 is the embedded baseline; Tantivy is the upgrade if the host language is Rust and lexicon-aware tokenization needs to live in the same binary.
