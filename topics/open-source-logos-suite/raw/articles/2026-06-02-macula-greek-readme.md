---
title: "MACULA Greek (Clear-Bible) repo overview"
url: https://github.com/Clear-Bible/macula-greek
retrieved: 2026-06-02
type: repo
---

# MACULA Greek

Clear-Bible's MACULA Greek repository combines linguistic data from Nestle1904, SBLGNT (with pericope adulterae), Clear Bible's hand-corrected syntax trees, Berean Study Bible glosses (now public domain), UBS MARBLE word senses (Louw-Nida domains), and "who-does-what-to-whom" semantic roles plus participant-referent tracking. It is distributed in four formats: TEI (readable), Nodes (nested `Node` elements for recursive NLP), Lowfat (graph-shaped XML optimized for query systems and display), and TSV (flat per-token). Latest release as of fetch date is 24.06.17 (June 2024); the project is active with 688+ commits. License is CC BY 4.0 with per-source notes in LICENSE.md (no ShareAlike). Lowfat is the recommended ingest target for tree-pattern search because each `<wg>` carries `class`/`role`/`rule` attributes and each `<w>` carries lemma, Strong's, morph, gloss, Louw-Nida domain, semantic frame (`A0:`/`A1:`), and `subjref` cross-references.
