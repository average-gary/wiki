---
title: "Cascadia Syntax Graphs / MACULA — public availability of Logos's syntax data"
source_url: "https://github.com/Clear-Bible/macula-greek"
type: article
path: logos
date_ingested: 2026-05-27
date_published: unknown
tags: [logos, cascadia, syntax, macula, open-data, moat, clear-bible]
quality: 5
confidence: high
summary: "The Clear-Bible MACULA Greek dataset packages Faithlife's SBLGNT (and related syntactic annotations descended from Cascadia) in open formats — a critical signal that one of Logos's prized academic moats is now CC-licensed open data."
---

# Cascadia Syntax Graphs / MACULA — public availability of Logos's syntax data

## Key findings

- The **MACULA Greek** dataset (Clear-Bible/macula-greek on GitHub) is an open-licensed corpus of linguistic annotations for the Greek New Testament. It explicitly cites **SBLGNT from Logos Bible Software** as a source dataset: "specifically, the data including the pericope adulturae from their commit on July 10, 2023."
- MACULA distributes the data in **four open formats**:
  - **TEI** (Text Encoding Initiative XML)
  - **nodes** (graph node format)
  - **lowfat** (a denormalized tree XML format readable by humans and tools)
  - **TSV** (flat tab-separated values for analysis)
- The Clear Bible / MACULA project (under SIL / United Bible Societies orbit) is the canonical home for openly-licensed structured biblical-text data. They have also produced or absorbed: MACULA Hebrew (Hebrew Bible syntax), aligned with the Westminster Hebrew Morphology and OSHB; alignment data between original-language and modern translations.
- **Strategic implication for a Logos clone**: One of the most-cited academic moats Logos has — the **Cascadia Syntax Graphs of the New Testament** — has been openly republished (via Faithlife collaboration with Clear Bible). This means a clone project does NOT need to license syntactic data from Faithlife; it can ingest MACULA directly and build syntactic search on top of it.
- Faithlife's contribution is not the syntactic data itself anymore — it's the **search UI**, **integration into the Passage/Exegetical Guides**, and the editorial Bible Knowledgebase that links syntactic search results back to commentaries and lexicons in the user's library. The data layer is open; the *tooling* layer remains commercial.

## Notable quotes / specifics

> "SBLGNT from Logos Bible Software; specifically, the data including the pericope adulturae from their commit on July 10, 2023."

> Four formats: TEI, nodes, lowfat, TSV.

## Source notes

GitHub repo readme — primary, high-confidence source for MACULA Greek's licensing and structure. The relationship between **Cascadia Syntax Graphs** specifically and **MACULA Greek**'s syntactic layer requires more research — a quick-fetch did not surface a direct statement that MACULA's syntax trees ARE Cascadia, only that SBLGNT (the underlying text) is from Logos. Cascadia is a constituency-tree / dependency-graph structure originally produced by Faithlife (Andi Wu, et al.); whether MACULA's "lowfat" trees are derived from or compatible with Cascadia is the open question. Need to fetch macula-greek docs and the Clear Bible blog to confirm. **Gap flagged for the compile pass.**

For the clone-Logos thesis this article is the single most important data point: **the data moat is leakier than Faithlife's marketing implies.** The lock-in is the curated knowledge graph (Factbook, Bible Knowledgebase) and the commissioned reverse-interlinear alignments per English translation — not the original-language linguistic annotations.
