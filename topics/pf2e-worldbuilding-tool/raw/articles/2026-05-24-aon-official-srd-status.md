---
title: "Archives of Nethys — 'official SRD' status (primary-source assessment)"
source: "https://2e.aonprd.com/Licenses.aspx + https://paizo.com/pathfinder"
type: article
date_fetched: 2026-05-24
date_published: unknown
tags: [pf2e, aon, archives-of-nethys, paizo, srd, official-status, primary-source]
quality: 4
credibility: high
path: pf2e-srd-data-gap
summary: "The widely-cited 2021 Paizo blog post designating AoN the official SRD could not be retrieved at the commonly-referenced paizo.com URLs (all 404 as of 2026-05-24). However, two primary-source artifacts confirm the special relationship: (1) AoN's own Licenses page states Paizo PI is 'used by Archives of Nethys under commercial license' — a direct commercial agreement, distinct from the public Community Use / Compatibility / ORC frameworks; (2) paizo.com/pathfinder links to AoN as its recommended free online resource. The 'official SRD' designation is real, but the primary artifact is AoN's commercial-license disclaimer, not a still-online Paizo blog post."
---

# AoN's "official SRD" status — what's verifiable in 2026

## The claim

PF2e community references frequently state: "Paizo announced in 2021 that Archives of Nethys is the official Pathfinder and Starfinder SRD." This claim shows up on PathfinderWiki, in subreddit resource lists, in podcasts, in Foundry VTT documentation, and informally everywhere.

## What can be verified directly (2026-05-24)

### Confirmed: a direct commercial license exists

AoN's `/Licenses.aspx` page states verbatim:

> "This website uses trademarks, copyrights, artwork, and other material identified as Product Identity owned by Paizo Inc. and used by Archives of Nethys under commercial license. The content on this website is not available for use under Paizo's [Community Use / Compatibility / ORC] licenses."

This is **primary-source confirmation** that AoN's relationship with Paizo is a private commercial agreement, not the public community frameworks. This is the legal artifact that distinguishes AoN from any other PF2e fan site.

### Confirmed: Paizo officially links to AoN

paizo.com/pathfinder includes:

> "Archives of Nethys offers a free online Pathfinder Player's Guide to help you learn and play!"

…with a direct link to `https://2e.aonprd.com/PlayersGuide.aspx`. This is Paizo officially endorsing AoN as the recommended free PF2e reference resource. The page does NOT use the literal phrase "official SRD," but the placement and endorsement are unambiguous.

### Could not be verified: the 2021 Paizo blog announcement

The widely-circulated paizo.com/community/blog URL referencing the announcement returns HTTP 404 (tested with several plausible slug variants on 2026-05-24). This may be due to:

- Paizo's blog migration / URL restructuring since 2021
- The post being archive-only on web.archive.org (which Claude Code cannot fetch in this environment)
- The original announcement being a forum thread or news post rather than a blog entry

The non-retrievability of this specific artifact is a **verification gap**, not evidence the announcement didn't happen. The two primary-source artifacts above (AoN's commercial-license disclaimer + Paizo's homepage endorsement) collectively confirm the relationship even without the blog post.

## What "official SRD" does and does NOT mean

### Does mean

- AoN has a **direct commercial license** from Paizo to use Product Identity (proper nouns, trademarks, art, Golarion setting).
- Paizo treats AoN as the canonical online reference for PF2e and SF rules text.
- Paizo's own marketing pages link out to AoN as the free online resource.
- AoN can host content (proper nouns, setting material) that Community Use Policy projects could not.

### Does NOT mean

- AoN inherits a public sublicensable grant. The commercial license is between Rose-Winds LLC and Paizo only. **Third-party scrapers do NOT inherit it.**
- AoN content is exempt from upstream Paizo licenses. The underlying mechanical content is still ORC (post-Remaster) or OGL 1.0a (pre-Remaster); AoN's commercial license adds the Product Identity layer on top.
- AoN provides redistribution rights to others. There is no statement on AoN's site granting any third-party redistribution license.
- AoN provides a sanctioned API or data export (none documented).

## Implication for a derivative tool

A worldbuilding tool that wants PF2e content **cannot ingest from AoN as a license posture**. AoN's commercial agreement is not transferable. The tool must:

1. Pick its license posture from Paizo's public stack (ORC, Community Use, Compatibility, Pathfinder Infinite, OGL legacy).
2. If it ingests data via AoN's Elasticsearch endpoint, it does so as a *technical* convenience while *legally* deriving from ORC + Community Use upstream.
3. Treat AoN-specific value-adds (categorization, flavor edits, organizational schema) as AoN's own creative work, which the tool **should not** copy without separate permission from Rose-Winds LLC.

## Caveats / open items

- The 2021 Paizo blog post URL needs another retrieval attempt via a tool that can reach web.archive.org, or via direct search of paizo.com's current blog index.
- AoN's Licenses page has no last-updated date visible; it's possible the OGL-only posture (no ORC notice) is stale and predates the 2023 ORC release.
- A direct contact with Rose-Winds LLC (`nethys@archivesofnethys.com`) could clarify scraping/API stance officially, but no public statement currently exists.

## Related

- [[2026-05-24-aon-licenses-page-commercial-license]]
- [[2026-05-24-aon-elasticsearch-endpoint]]
- [[2026-05-24-pf2e-srd-data-orc-license-paizo]]
- [[2026-05-24-pf2e-srd-data-paizo-community-use-policy]]
