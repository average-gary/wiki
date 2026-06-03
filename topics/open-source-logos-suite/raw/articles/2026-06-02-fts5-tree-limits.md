---
title: "SQLite FTS5 tree-query limitations"
url: https://www.sqlite.org/fts5.html
retrieved: 2026-06-02
type: spec
---

# FTS5 tree limits

SQLite FTS5 is a flat-document inverted index. It supports column filters (`{col}: term`), exclusion (`-col: term`), `NEAR(a b, n)` with a configurable distance, phrase queries, and `^` start-of-column, but it has no concept of parent/child or tree shape. To answer "subject NP whose head is a divine name immediately dominated by a verbless clause" FTS5 alone is insufficient: it can locate verses that contain the right tokens, but it cannot enforce structural relationships. The recommended pattern is hybrid: keep FTS5 for surface/lemma/morph search across translations, and add a separate set of normal SQL tables for the tree (with parent_id, depth, and either materialized path or nested-set/Dewey/interval encoding). Tree-pattern queries compile to multi-self-join SQL against those tables. FTS5 then optionally pre-filters candidate verses to keep the join cardinality small. This is the same hybrid pattern PostgreSQL ltree users adopt — relational primitives are sufficient for tree-pattern search if you precompute the right encoding per token row.
