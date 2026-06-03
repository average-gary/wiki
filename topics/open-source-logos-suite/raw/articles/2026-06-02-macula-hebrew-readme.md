---
title: "MACULA Hebrew (Clear-Bible) repo overview"
url: https://github.com/Clear-Bible/macula-hebrew
retrieved: 2026-06-02
type: repo
---

# MACULA Hebrew

Clear-Bible's MACULA Hebrew packages Westminster Leningrad Codex text, Open Scriptures Hebrew Bible morphology, Clear Bible syntax trees developed jointly with the Groves Center, UBS MARBLE word senses, Cherith glosses, semantic roles (Agent/Verb/Patient style), and participant referents. Distribution is `WLC/nodes` (recursive Node XML), `WLC/lowfat` (graph-shaped tree XML for queries), and `WLC/tsv` (flat per-token). The repo had 444 commits and 12 releases as of April 2026; coverage is the full Hebrew Bible. The Groves Center released "Westminster Hebrew Syntax without Morphology" under CC BY 4.0, and that release underwrites the Clear Bible syntax layer here. Per-source license notes are in LICENSE; no ShareAlike clause is asserted on the combined Clear Bible work. The lowfat format mirrors the Greek lowfat schema (sentence → wg → w with class/role/rule on word-groups and lemma/morph/sense on tokens), so a single ingest pipeline can target both testaments.
