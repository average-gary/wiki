---
title: "Credible Exit and the Law of Conservation of Blockspace (Carvalho / BitcoinErrorLog, Delving Bitcoin)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/credible-exit-and-the-law-of-conservation-of-blockspace/2503
mirror: https://blockspace.science
author: John Carvalho (BitcoinErrorLog)
date: 2026-05-13
type: article
ingested: 2026-05-26
quality: 3
credibility: medium
confidence: medium
tags: [ark, lightning, scaling, exit-cost, blockspace, critique]
---

# Credible Exit and the Law of Conservation of Blockspace — Carvalho (May 2026)

Formal version of the unilateral-exit-cost critique that applies to **all layer-2 protocols** (Lightning, Ark, channel factories, statechains). Headline argument: **"Static block-weight accounting bound for unilateral L1 enforcement across 1-day, 14-day, and 28-day windows."**

## Core thesis

> "Layers cannot actually scale Bitcoin" in a trust-minimized way.

There is a hard cap on how many users a layer can support trust-minimized given finite L1 blockspace for forced exits. Specifically: a pool with N participants needs ≤ `blockspace_window / per-exit-weight` credible exits.

## Direct application to mining payouts

At ~1 MB per block × ~1000 blocks/week ≈ 1 GB/week, with thousands of small miners and per-exit weight ~hundreds of vBytes (Ark cooperative + tree-tail), only a fraction of miners can credibly exit in any reasonable window. **The unilateral-exit guarantee that Ark advertises does not survive contact with mining-pool-scale population sizes.**

## Caveat

Could not retrieve the full text of `blockspace.science` for the formal numerical bounds. The Delving thread is the announcement; the full paper at the science domain wasn't renderable via WebFetch in the research round. Wiki should cite this finding as **medium confidence** until the formal numbers are extracted.

## Why ingestion-worthy

The cleanest formalization of the exit-cost objection that the wiki uses against any L2-backed mining-payout proposal. Applies equally to Ark, Lightning, and CTV-fanout depending on the per-exit weight and the population.

## See also

- [[2026-05-26-ark-erik-de-smedt-ctv-csfs-delving]] — exit-asymmetry critique by roasbeef
- [[2026-05-26-ark-pickhardt-channel-factory-delving]] — capital-lockup critique
- [[2026-05-26-braidpool-covenants-delving]] — covenant-based alternative (UHPO)
