---
title: "MACULA Greek lowfat sample — 3 John 1:1-2"
url: https://raw.githubusercontent.com/Clear-Bible/macula-greek/main/Nestle1904/lowfat/25-3john.xml
retrieved: 2026-06-02
type: spec
---

# Lowfat sample (3 John)

A direct fetch of the smallest book in the corpus (`25-3john.xml`, 144 KB) confirms the schema described in the README. Each verse appears as a `<sentence>` containing a `<p>` paragraph and one or more `<wg>` clause nodes. Example wg: `<wg class="cl" articular="true" rule="S-IO">`, with children `<wg class="np" articular="true" rule="DetAdj" role="s">` and `<wg class="np" type="apposition" rule="NP-CL" role="io">`. Each `<w>` carries `ref` (e.g. `3JN 1:1!1` — book/chapter/verse/word index), `xml:id` (e.g. `n64001001001` — global token id), `after` (whitespace/punctuation), `class`, `lemma`, `normalized`, `strong`, `gender`/`number`/`case`, `gloss`, Louw-Nida `domain` and `ln`, `morph` (e.g. `T-NSM`), and `unicode`. Verbs additionally carry `frame="A0:nodeid A1:nodeid"` (PropBank-style semantic arguments) and `subjref` pointing back to the subject's xml:id. This is exactly the shape needed to flatten into a relational `tokens` table while preserving tree shape via `parent_id` plus a materialized path or interval encoding.
