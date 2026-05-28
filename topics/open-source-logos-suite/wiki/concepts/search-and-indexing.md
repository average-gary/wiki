---
title: Search and Indexing
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [search, indexing, fts5, tantivy, sqlite, morphology, syntactic-search]
sources:
  - "[[raw/articles/2026-05-27-client-sqlite-fts5]]"
  - "[[raw/articles/2026-05-27-client-tantivy]]"
  - "[[raw/articles/2026-05-27-client-stepbible-data]]"
  - "[[raw/articles/2026-05-27-logos-cascadia-macula-data-availability]]"
---

# Search and Indexing

Bible-study search is fundamentally different from web search: corpora are small (a few hundred MB after lemma + morphology + syntax), but query types are rich (lemma, morphology, syntactic, NEAR, boolean). The right primitives are mature, embeddable, and free.

## Query types to support

| Query type | Example | Index requirement |
|-----------|---------|-------------------|
| Word search | "love" | Surface-form FTS |
| Lemma search | Strong's H157 (אָהַב) | Lemma index |
| Morphology search | "all imperfective verbs in Genesis" | Morphology index |
| Syntactic search | "subject + finite verb + object NP" | Syntax-tree index |
| Phrase / NEAR | "love within 5 words of neighbor" | Positional FTS |
| Boolean composition | (A AND B) NOT C | Set operations across indexes |
| Cross-translation | Find ESV verses where original Greek = ἀγάπη | Strong's-keyed cross-translation |

## Recommended primary index: SQLite FTS5

**Why FTS5**:
- Cross-platform (Rust, Swift, Kotlin, web via SQL.js)
- Embedded — single file, no server
- BM25 ranking
- NEAR queries enable clause-proximity
- `unicode61` tokenizer handles Hebrew + Greek natively
- Custom tokenizers (`tokendata=1`) emit `lemma\0surface_form` tuples for morphological lookup

**Schema sketch**:

```sql
CREATE VIRTUAL TABLE verses USING fts5(
  ref,             -- e.g. "Gen 1:1"
  translation,     -- e.g. "WEB", "WLC"
  text,            -- surface form
  lemma,           -- space-separated lemmas (Strong's numbers + words)
  morph,           -- morphology codes
  tokenize='unicode61 remove_diacritics 2'
);
```

Searches look like:

```sql
-- Surface word search
SELECT * FROM verses WHERE text MATCH 'love NEAR/5 neighbor';

-- Lemma search via Strong's
SELECT * FROM verses WHERE lemma MATCH 'H157';

-- Morphology in Genesis
SELECT * FROM verses
WHERE ref LIKE 'Gen %'
  AND morph MATCH 'V*Q*';  -- Qal verb form
```

## Upgrade for Rust-only desktop: Tantivy

**Why Tantivy** (when FTS5 isn't enough):
- Faster mass-corpus indexing throughput
- Richer Lucene-style analyzer pipelines
- Pure Rust, embeddable
- Supports per-field tokenization (different for Hebrew vs. Greek vs. English)
- Better facet/aggregation support

**When to use**:
- If full-corpus reindex is in the user-facing UX
- If you want per-field stemmers, custom analyzers
- If FTS5's tokenizer plugin API is too constraining

**When to stick with FTS5**:
- Cross-platform (mobile, web) is mandatory
- Index size and load time matter (FTS5 is more compact)
- The plugin author hasn't time for Tantivy's deeper API surface

For an OSS Logos suite: FTS5 first, Tantivy as an optional upgrade for the desktop power-user installation.

## The morphology angle

Strong's numbers are the universal join key (per [[biblical-data-licensing|Biblical data licensing]]). Index every word with its Strong's tag and you get:

- Cross-translation search ("show me every verse with Strong's G26 ἀγάπη in WEB")
- Word study ("count occurrences of H157 across the OT")
- Concordance generation
- Lemma-aware NEAR ("H157 within 5 words of H7453")

STEPBible TAHOT and TAGNT provide the disambiguated tagged corpus needed to build this.

## Syntactic search (the hard one)

Syntactic search is what Logos calls "Cascadia" and what the academic world calls treebank queries. Examples:

- "Find verbless clauses where the subject is a divine name"
- "Find predicative adjective constructions in NT epistles"
- "Find every imperative addressed to a feminine plural"

This requires a **syntactic tree index**, not just a token index. The data is now openly available:

- **MACULA Greek** (Clear Bible, CC BY 4.0) — full syntactic trees for SBLGNT NT
- **MACULA Hebrew** — coming, partial coverage in 2026

**How to index**: store the parsed tree (LowFAT XML or similar) in a dedicated table; expose a query language that walks the tree. Two approaches:

1. **Constraint-based query DSL**: users write structured queries. Powerful, learning curve.
2. **Visual tree-pattern editor**: users draw a partial tree, system finds matches. Logos-style. Better UX, more dev work.

Recommend starting with a textual DSL behind the scenes + a few canned queries exposed as buttons in v1. Tree-pattern editor in v2.

## Cross-platform considerations

| Platform | Choice |
|----------|--------|
| Desktop (Tauri 2 + Rust) | FTS5 default; Tantivy optional |
| iOS (native) | FTS5 (built-in to iOS SQLite) |
| Android (native) | FTS5 (built-in to Android SQLite) |
| Web (WASM) | FTS5 via SQL.js, OR upload-and-search via remote backend |

This is why FTS5 is the recommended primary: it's the only option that ships everywhere.

## Index size estimates

For the open default corpus (rough):

| Asset | Size |
|-------|------|
| WEB + KJV + ASV + BSB | ~20 MB text |
| WLC + STEPBible TAHOT | ~50 MB |
| Byzantine Greek + STEPBible TAGNT | ~30 MB |
| Strong's + BDB + TFLSJ | ~50 MB |
| OpenBible.info x-refs | ~10 MB |
| Matthew Henry + JFB commentaries | ~200 MB |
| MACULA Greek syntax | ~50 MB |
| **FTS5 index** of all above | ~150-300 MB |

So a complete default install with index is well under 1 GB. Mobile-friendly.

## What to NOT build

- **Don't roll a custom search engine.** FTS5 and Tantivy are mature; reinventing them is months of work for marginal gain.
- **Don't ship a server-side-only search.** Bible study is offline-friendly; embedded indexes belong on-device.
- **Don't index commentaries the same way as Bible text.** Different field types (commentaries are prose; Bible text is structured by book/chapter/verse). Separate FTS tables.

## See Also

- [[client-architecture|Client architecture]]
- [[biblical-data-licensing|Biblical data licensing]]
- [[study-tool-ux-gap|Study-tool UX gap]]
- [[../topics/engineering-playbook|Engineering playbook]]
