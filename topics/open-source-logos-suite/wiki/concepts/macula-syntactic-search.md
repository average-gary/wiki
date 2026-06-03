---
title: "MACULA syntactic search: query DSL + indexing"
type: concept
created: 2026-06-02
updated: 2026-06-02
verified: 2026-06-02
volatility: warm
confidence: high
sources:
  - raw/articles/2026-06-02-macula-greek-readme.md
  - raw/articles/2026-06-02-macula-hebrew-readme.md
  - raw/articles/2026-06-02-macula-greek-license.md
  - raw/articles/2026-06-02-lowfat-xml-schema.md
  - raw/articles/2026-06-02-lowfat-3john-sample.md
  - raw/articles/2026-06-02-tregex-stanford.md
  - raw/articles/2026-06-02-tigersearch-defunct.md
  - raw/articles/2026-06-02-fts5-tree-limits.md
  - raw/articles/2026-06-02-andersen-forbes-hebrew.md
  - raw/articles/2026-06-02-treebank-wikipedia.md
---

# MACULA syntactic search: query DSL + indexing

## TL;DR

Clear-Bible's MACULA Greek and MACULA Hebrew now ship full syntax trees in a "lowfat" XML format ([[../../raw/articles/2026-06-02-lowfat-xml-schema.md|lowfat schema]], [[../../raw/articles/2026-06-02-lowfat-3john-sample.md|3 John sample]]) under CC BY 4.0 with no ShareAlike clause ([[../../raw/articles/2026-06-02-macula-greek-license.md|MACULA Greek license]]). christ-is-lord can flatten lowfat into a small set of SQLite tables — `tokens` (with parent_id, depth, materialized path, lemma, morph, Strong's, semantic frame), `wordgroups` (class, role, rule), `verses` (FTS5 join key) — and compile a textual Cascadia-flavoured DSL down to SQL self-joins. Tree-pattern visual builders should ship later; the v0.5 deliverable is a textual query and a handful of canned templates that meet the "every verbless clause where the subject is a divine name in <2 s" bar.

## Evidence

### MACULA data shape and licensing

MACULA Greek combines Nestle1904 / SBLGNT text with Clear Bible's hand-corrected syntax trees, MARBLE (Louw-Nida) word-sense data, Berean Study Bible glosses (now public domain), and PropBank-style semantic-role tagging ([[../../raw/articles/2026-06-02-macula-greek-readme.md|MACULA Greek README]]). MACULA Hebrew mirrors that shape using Westminster Leningrad Codex + Open Scriptures Hebrew Bible morphology + the Groves Center's Westminster Hebrew Syntax, now openly licensed ([[../../raw/articles/2026-06-02-macula-hebrew-readme.md|MACULA Hebrew README]]). Both ship four formats: TEI, Nodes, Lowfat, TSV. Lowfat is the right ingest target — `<wg>` carries clause-level `class` (np, cl, pp, vp, adjp, advp, nump, adv, conj), `role` (s, v, vc, o, p, io, o2, adv), boolean `articular`/`det`/`head`, and a `rule` attribute identifying the construction; `<w>` carries `lemma`, `strong`, full morphology, Louw-Nida `domain`/`ln`, `frame` (e.g. `A0:nodeid A1:nodeid`), and `subjref` for subject coreference. A direct fetch of `25-3john.xml` confirms this shape ([[../../raw/articles/2026-06-02-lowfat-3john-sample.md|lowfat 3 John sample]]).

License is CC BY 4.0 on the combined MACULA Greek dataset (© 2022-2024 Biblica, Inc) with attribution string `MACULA Greek Linguistic Datasets, available at https://github.com/Clear-Bible/macula-greek/`. There is **no ShareAlike clause**. Per-source notes: SBLGNT under Logos's free-for-non-commercial license, MARBLE used with permission, Berean glosses public domain, Cherith glosses CC BY 4.0. The older `biblicalhumanities/greek-new-testament` lowfat repo (Robie/Palmer 2014-2017) is **CC BY-SA 3.0** and would impose ShareAlike; christ-is-lord must ingest from `Clear-Bible/macula-greek` to keep its derivative SQLite indexes redistributable under the project's own MIT/Apache scheme ([[../../raw/articles/2026-06-02-macula-greek-license.md|MACULA license analysis]]).

### Prior art on tree-query languages

Tregex (Stanford, GPL v2+) is the live de-facto standard. Its operator vocabulary — `<` immediately dominates, `<<` dominates, `>` immediately dominated by, `$+`/`$-` immediate left/right sister, `..`/`.` precedence, `<#`/`>#` head — is what a power-user expects, and Semgrex provides the same idea on dependency graphs ([[../../raw/articles/2026-06-02-tregex-stanford.md|Tregex]]). The 4.2.0 release in November 2020 has not been superseded; pace is slow but stable. Embedding CoreNLP itself is impossible (GPL + Java + size), so christ-is-lord should reimplement a Tregex-flavoured subset against its own index. TGrep2 (Rohde) is unmaintained since the mid-2000s. TigerSearch (Stuttgart) is officially defunct, with successor ICARUS unused in practice ([[../../raw/articles/2026-06-02-tigersearch-defunct.md|TIGERSearch]]). The Andersen-Forbes Hebrew database remains paywalled inside Logos with no open release ([[../../raw/articles/2026-06-02-andersen-forbes-hebrew.md|Andersen-Forbes]]). The pragmatic conclusion ([[../../raw/articles/2026-06-02-treebank-wikipedia.md|treebank survey]]): the only viable plan for an offline-first, mobile-friendly Bible app is a custom DSL compiled to SQL self-joins over a flattened tree.

### Indexing strategies

FTS5 alone cannot answer tree-pattern queries: it has no parent-child concept and no way to enforce structural relationships ([[../../raw/articles/2026-06-02-fts5-tree-limits.md|FTS5 tree limits]]). The corpus is small enough (about 800k Hebrew + Greek tokens combined) that a relational tree encoding fits comfortably in SQLite. Three encodings are viable for the small corpus: (a) `parent_id` plus depth — simple, slow on transitive-dominance queries; (b) materialized path on each token — `/sent42/wg7/wg2/w3` — cheap LIKE-prefix queries for descendant matches; (c) nested-set / interval (`lft`, `rgt`) — best for "X dominates Y" via `lft < x AND rgt > x`. A combination — `parent_id` + materialized path + interval `(lft, rgt)` — gives all three operator classes in O(log n) per join and costs maybe 40 bytes/token (32 MB total). FTS5 stays as a verse-level pre-filter so a query like "verbless clause whose subject's lemma is אֱלֹהִים" first narrows to verses containing H430, then runs the structural join on a few hundred candidate sentences instead of all 23k.

### UI patterns

Logos's commercial syntactic search ships a visual tree-pattern builder (drag-drop nodes, fill in attributes) plus a textual fallback. BibleArc-style bracket-diagrams are a different beast — discourse-level rather than sub-clause syntax — and not directly relevant. Cascadia-style textual DSLs (used by Logos under the hood) are compact and copy-pasteable, which matters for sharing queries on forums. The right v0.5 product cut: textual DSL only, with a small library of canned queries ("verbless clauses with divine subject", "imperatives addressed to feminine plural", "predicative adjective constructions") exposed as one-click buttons. The visual builder is a v0.7+ project.

## Implications for christ-is-lord

- **Ingest path**: `logos_ingest` adds a `macula_lowfat` ingester that streams `Clear-Bible/macula-greek/Nestle1904/lowfat/*.xml` and `Clear-Bible/macula-hebrew/WLC/lowfat/*.xml` (about 200 MB combined raw XML, 27 + 39 books) and emits flat row batches. Use `quick-xml` in Rust for streaming SAX-style parse — DOM is too heavy for the 13 MB Matthew file. Compute interval `(lft, rgt)` and materialized path during the depth-first walk so no second pass is needed.

- **Recommended query DSL shape**: textual-first, Cascadia-flavoured. Example: `clause:verbless [subject = lemma:H430|H3068]` → "any clause with class=cl, no `<w role='v'>` descendant, and a child wg with role='s' whose head w has lemma in the divine-name set". v0.5 ships the parser + interpreter + 6-10 canned templates. Tree-pattern visual UI deferred to v0.7.

- **SQLite schema sketch** (logos_core, new migration):

  - `macula_tokens(id TEXT PRIMARY KEY, ref TEXT, book INT, chapter INT, verse INT, position INT, surface TEXT, lemma TEXT, strong TEXT, morph TEXT, gloss TEXT, ln_domain TEXT, parent_id TEXT, sentence_id TEXT, lft INT, rgt INT, depth INT, path TEXT, role TEXT, frame TEXT, subjref TEXT)`. Roughly 1 row per Hebrew/Greek token, 800k rows.
  - `macula_wordgroups(id TEXT PRIMARY KEY, parent_id TEXT, sentence_id TEXT, class TEXT, role TEXT, rule TEXT, articular INT, head_token_id TEXT, lft INT, rgt INT, depth INT, path TEXT)`. About 250k rows.
  - `macula_sentences(id TEXT PRIMARY KEY, ref_start TEXT, ref_end TEXT, root_wg_id TEXT)`. About 23k rows.
  - `macula_frames(verb_token_id TEXT, arg_role TEXT, arg_node_id TEXT)` — explodes the `frame="A0:... A1:..."` attribute for fast PropBank-style joins.
  - Indexes: `(lemma)`, `(strong)`, `(role)`, `(class)`, `(parent_id)`, `(lft, rgt)`, `(path)`. The verses FTS5 table from [[search-and-indexing|search and indexing]] stays untouched and joins by `(book, chapter, verse)`.

- **Query compiler**: a small Rust crate inside `logos_core` parses the DSL and compiles to parameterised SQL. "Subject is a divine name" becomes a single SQL self-join on `macula_wordgroups w_cl` (class='cl', role='s' child) ⨝ `macula_tokens w_tok` (head_token_id) WHERE `lemma IN (...)`. Verbless = `NOT EXISTS (SELECT 1 FROM macula_tokens v WHERE v.parent_id = w_cl.id AND v.role='v')`. With FTS5 pre-filter, the canonical Hebrew "verbless clause / divine subject" query runs in well under 2 s on a 2024 mobile SoC; without pre-filter it is still ~3-4 s.

- **License posture**: CC BY 4.0 only — no ShareAlike — so the SQLite database file shipped with christ-is-lord can be redistributed under the project's chosen license as long as the MACULA attribution string is preserved in About / credits and in the dataset's manifest signed by the Iroh-blobs distribution layer ([[decentralized-text-distribution|decentralized text distribution]]). Do **not** ingest from `biblicalhumanities/greek-new-testament` lowfat — that repo is CC BY-SA and would force the indexes themselves under SA terms.

- **What to defer**: visual tree-pattern builder, Semgrex-style dependency-graph queries (lowfat is constituency-shaped), and the Andersen-Forbes phrase-marker scheme (paywalled, no open replacement). MARBLE Louw-Nida domain queries ("show every verse with a noun in domain 92 'discourse referents'") are nearly free once tokens carry `ln_domain` — wire those into the same DSL.

## See Also

- [[search-and-indexing|Search and indexing]] — primary FTS5 index that this work joins against
- [[biblical-data-licensing|Biblical data licensing]] — overall license map
- [[client-architecture|Client architecture]] — where logos_core/logos_ingest live
- [[study-tool-ux-gap|Study-tool UX gap]] — UX rationale for textual-first DSL
