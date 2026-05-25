---
title: "A Brief History & Ethos of the Digital Garden — Maggie Appleton"
source: "https://maggieappleton.com/garden-history"
type: article
date_fetched: 2026-05-24
date_published: 2020-12-04
tags: [knowledge-graph, philosophy, notes, digital-garden]
quality: 4
credibility: high
path: world-data-modeling
summary: "Appleton's canonical writeup of the digital garden ethos: topography over timelines, continuous growth, learning in public, intercropped media, independent ownership. The mental model behind every modern markdown-knowledge-graph tool (Obsidian, Roam, LogSeq) and a lens for designing GM-facing worldbuilding UIs."
---

# Digital Gardens — Patterns and Ethos

## The streams-vs-gardens framing
Streams (Twitter, blog feeds) are time-ordered and ephemeral. Gardens are spatially organized, "richly linked landscape that grows slowly over time" — the right metaphor for a worldbuilding wiki.

## Six patterns
1. **Topography over timelines** — organize by topic, link densely; readers enter anywhere.
2. **Continuous growth** — notes are perpetually unfinished; status indicators (seedling/budding/evergreen) communicate maturity.
3. **Imperfection / learning in public** — epistemic status beats fake polish.
4. **Playful & personal** — bespoke design; HTML/CSS over template lock-in.
5. **Intercropped media** — text, diagrams, video, code mixed freely.
6. **Independent ownership** — runs on user-controlled infrastructure.

## Relevance to our tool
1. **Status indicators map directly to GM workflow**: lore at "seedling" vs "evergreen" tells the GM what's safe to drop on players. We should bake `status: seedling|budding|evergreen` into frontmatter or as a typed field.
2. **Topographic structure** validates the typed-entity-graph model over a timeline-of-edits model. The world is a place, not a feed.
3. **Continuous growth** justifies CRDT/append-friendly storage — entities are never "done."
4. **Independent ownership** echoes the local-first essay: GMs should be able to take the vault and walk away.
5. **Caveat**: gardens don't enforce schema; PF2e statblocks do need validation. The garden ethos applies to *lore*, not *rules data*. Two-tier design: schemaful PF2e mechanical layer + garden-style lore layer that links to it.
