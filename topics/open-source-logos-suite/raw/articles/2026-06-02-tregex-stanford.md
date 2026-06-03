---
title: "Tregex / Tsurgeon / Semgrex (Stanford NLP)"
url: https://nlp.stanford.edu/software/tregex.shtml
retrieved: 2026-06-02
type: article
---

# Tregex (Stanford NLP)

Tregex is the canonical tree-pattern matching language for constituency trees, part of CoreNLP. Patterns are written with relational operators: `<` (immediately dominates), `<<` (dominates anywhere below), `>` (immediately dominated by), `>>` (dominated by anywhere above), `$` (sister-of) with `$+`/`$-` for left/right immediate sister, `..`/`.` for precedence, `,,`/`,` for follow, `<#`/`>#` for head relations, plus boolean `&`/`|`/`!`/`?`. Node labels are literal strings, regex in slashes, or `__` wildcard. Sister tools: Tsurgeon performs tree rewrites; Semgrex matches dependency-graph patterns. Released under GPL v2-or-later (commercial license available); the API is stable but development pace has slowed (4.2.0 in November 2020, no new release through 2026-06). For christ-is-lord the operator vocabulary is the de-facto standard a power-user expects, but the GPL makes embedding the Java engine itself infeasible — christ-is-lord should implement a Tregex-flavoured subset against its own SQLite-backed index rather than ship CoreNLP.
