---
title: "Archives of Nethys — Licenses page (commercial license with Paizo)"
source: "https://2e.aonprd.com/Licenses.aspx"
type: article
date_fetched: 2026-05-24
date_published: unknown
tags: [pf2e, aon, archives-of-nethys, paizo, licensing, ogl, commercial-license, primary-source]
quality: 5
credibility: high
path: pf2e-srd-data-gap
summary: "AoN's own Licenses page states that Paizo Product Identity is 'used by Archives of Nethys under commercial license' — primary-source confirmation that AoN has a special commercial relationship with Paizo distinct from the public Community Use / Compatibility / ORC frameworks. The page also includes the full OGL 1.0a text. No ORC notice present at fetch time. No scraping/redistribution policy stated."
---

# Archives of Nethys — Licenses page

## URL & site context

- Site: 2e.aonprd.com (PF2e branch of Archives of Nethys)
- Operator: Rose-Winds LLC (Blake Davis)
- Page: `/Licenses.aspx`
- Linked from primary nav of every page on the site.

## Key disclaimer (verbatim, as extracted)

> "This website uses trademarks, copyrights, artwork, and other material identified as Product Identity owned by Paizo Inc. and used by Archives of Nethys under commercial license. The content on this website is not available for use under Paizo's [listed licenses]."

The "[listed licenses]" the page enumerates as **NOT** applicable to AoN's content:

- Paizo Community Use License
- Pathfinder Second Edition Compatibility License
- Starfinder Compatibility License
- Pathfinder Compatibility License (1st Ed)

## Licenses that ARE on the page

- **Open Game License v1.0a** — full text of the WotC 2000 license is reproduced on the page. This covers the OGL-licensed mechanical content AoN aggregates.
- The page does NOT include an **ORC License notice** (as of 2026-05-24 fetch). This is notable since Paizo's Remaster (Player Core 2023, Monster Core / Player Core 2 2024) shifted post-Remaster content to ORC.

## What the page says about scraping / redistribution / API

- Nothing. There is no scraping policy, no API terms, no rate-limit statement, no redistribution clause, no terms of service language.
- The site has no separate `/Terms.aspx` or `/TOS.aspx` page in navigation (header links: Licenses, Sources, Contact Us, Contributors, Support the Archives — no Terms).

## Implication: what "commercial license" means

The phrase **"used by Archives of Nethys under commercial license"** is the key claim. It means:

1. AoN's relationship to Paizo is **not** the public Community Use Policy (which is non-commercial-style, free-only).
2. AoN is **not** operating under the Compatibility License (badging only).
3. AoN is **not** operating under ORC alone (which wouldn't grant Product Identity / trademarks anyway).
4. There is a **direct commercial agreement between Rose-Winds LLC and Paizo Inc.** that grants AoN the right to use Paizo Product Identity (proper nouns, trademarks, art, setting material).

This is consistent with widely-cited 2021-era reporting that Paizo designated AoN the "official Pathfinder/Starfinder SRD," but the primary-source artifact for that designation is **AoN's own Licenses page disclaimer**, not a Paizo blog post (the commonly-cited paizo.com/community/blog URLs return 404 as of 2026-05-24).

## Caveats

- "Commercial license" between two private parties is **not** a public license. A third-party tool builder **cannot inherit** AoN's commercial license. This is the same posture as Foundry VTT pf2e (which has a separate Paizo partnership a third party also can't inherit).
- AoN's content posture is **specific to AoN**. A scraper of AoN does not gain AoN's commercial-license rights.
- The footer / Licenses page does not contain robots.txt-equivalent guidance, and the site has a publicly-reachable Elasticsearch backend, so technical access is unrestricted — but legal access for **redistribution** would still require deriving from upstream Paizo licenses (ORC, Community Use, OGL), not from AoN's commercial agreement.

## Footer (verbatim)

> "Site Owner: Rose-Winds LLC (Blake Davis)" — with `mailto:nethys@archivesofnethys.com` link and a Twitter icon.

No license badge in the footer itself. Licenses are reached via the header nav.

## Related sources

- [[2026-05-24-pf2e-srd-data-orc-license-paizo]] — ORC framework AoN does NOT cite
- [[2026-05-24-pf2e-srd-data-paizo-community-use-policy]] — Community Use, which AoN explicitly says does NOT apply
- [[2026-05-24-aon-elasticsearch-endpoint]] — the de-facto API derived from this site
