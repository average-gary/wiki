---
title: "PF2e licensing posture for a derivative tool"
type: concept
created: 2026-05-24
updated: 2026-05-24
verified: 2026-05-24
volatility: medium
confidence: high
sources:
  - "[[2026-05-24-pf2e-srd-data-orc-license-paizo]]"
  - "[[2026-05-24-pf2e-srd-data-paizo-community-use-policy]]"
  - "[[2026-05-24-pf2e-srd-data-paizo-licenses-overview]]"
  - "[[2026-05-24-pf2e-srd-data-foundryvtt-pf2e]]"
  - "[[2026-05-24-pf2e-srd-data-pf2e-remaster-overview]]"
  - "[[2026-05-24-orc-verbatim-text]]"
  - "[[2026-05-24-aon-licenses-page-commercial-license]]"
  - "[[2026-05-24-aon-elasticsearch-endpoint]]"
  - "[[2026-05-24-aon-official-srd-status]]"
tags: [pf2e, orc-license, ogl, community-use, pathfinder-infinite, licensing, archives-of-nethys]
---

# PF2e licensing posture for a derivative tool

Pathfinder 2e content lives under a five-tier license stack. A worldbuilding/LLM tool builder must pick a posture before touching data, because the choice forks the product (free vs paid, hosted vs storefront-locked, mechanics-only vs full Golarion).

## The five licenses

1. **ORC (Open RPG Creative License)** — Library of Congress registration **TX 9-307-067**, drafted by Azora Law, *published* (not owned) by Paizo. Worldwide, royalty-free, **irrevocable, perpetual, non-sublicensable** grant over Licensed Material (mechanics). Reserved Material (trademarks, art, settings, proper nouns) is carved out. Required notices: ORC notice + upstream attribution + Reserved Material disclosure + downstream re-grant.
   - Section structure uses **Roman numerals I–V with lettered subsections**, not 1.0/2.0/etc.: I (Definitions), II (Grant + acceptance + sui generis DB rights + Reserved carve-out), III (Notice obligations + template), IV, V.a (termination, **60-day cure window**), V.b (license is immutable; cannot be amended by parties).
   - Acceptance is offer-and-acceptance via Use — no signature required (II.b).
   - Anti-DRM clause defined in I.d (Effective Technological Measures).
2. **OGL 1.0a** — legacy. Pre-Remaster PF2e (2019–2023 Bestiaries, APG, etc.) was published under OGL. **OGL and ORC content cannot be mixed**; conversion is forbidden. Original CRB/Bestiary 1/2/3 will not be reprinted.
3. **Pathfinder Compatibility License** — logo/badging only; lets a product say "Compatible with Pathfinder."
4. **Pathfinder Infinite** — most permissive over Paizo IP (Golarion deities, regions, plots). **DriveThruRPG-locked storefront**; effectively incompatible with a hosted web/desktop SaaS that ships outside that channel.
5. **Community Use Policy** (last updated 2024-08-22) — covers what ORC doesn't (Golarion-flavored content). Hard rule: **the project must be free** (no paywalls; Patreon/sponsors/ads OK). Specifies verbatim attribution boilerplate.

## The PF2e Remaster cliff (2023–2024)

The Remaster (Player Core + GM Core 2023, Monster Core + Player Core 2 2024) is the legal demarcation. Pre-Remaster = OGL legacy; post-Remaster = ORC primary. A 2026-built tool should target **ORC as the default content surface** and treat OGL Bestiary 2/3/APG content as a separate, opt-in legacy compendium that must remain segregated.

## Realistic data sources

- **[[2026-05-24-pf2e-srd-data-foundryvtt-pf2e]]** — the de facto standard. Code is **Apache 2.0** (schema reusable freely); content inherits OGL/ORC per record. Authorized via a Paizo–Foundry partnership that **a third-party tool cannot inherit** — a derivative tool re-derives its content posture from ORC + Community Use directly. Naming is name-keyed (`@Compendium[pf2e.pack-name.Entity Name]`), per-pack license provenance is tracked.
- **Archives of Nethys** — community-run by Rose-Winds LLC (Blake Davis). Operates under a **private commercial license with Paizo** ([[2026-05-24-aon-licenses-page-commercial-license]]) — Paizo Product Identity is "used by Archives of Nethys under commercial license" per AoN's own Licenses page. paizo.com/pathfinder officially links to AoN as the recommended free online resource ([[2026-05-24-aon-official-srd-status]]). The 2021 Paizo blog post that originally announced the partnership 404s at every plausible URL today.
  - **No public Terms of Service or scraping policy.** Footer is just "Site Owner: Rose-Winds LLC."
  - **No ORC notice** on AoN's Licenses page despite Paizo having released ORC in 2023 — possibly stale; worth re-checking annually.
  - **Undocumented Elasticsearch endpoint** at `https://elasticsearch.aonprd.com/aon/_search` ([[2026-05-24-aon-elasticsearch-endpoint]]) — public, unauthenticated, returns full JSON records (description, traits, mechanics, source). 10k+ docs per class. No documented schema, no rate-limit policy. **Effectively a de-facto API but no SLA, no contract, and no inheritable license.**
  - **Critical for derivative tools**: AoN's commercial license is **NOT transferable**. A tool that scrapes AoN does not inherit AoN's relationship with Paizo — its redistribution posture must still come from ORC + Community Use directly. AoN should be a **secondary enrichment layer** at most; **Foundry pf2e remains the cleaner primary ingestion source.**

## Decision tree for a worldbuilding/LLM tool

| Posture | Mechanics | Golarion content | Distribution | Monetization |
|---------|-----------|------------------|--------------|--------------|
| **ORC-only, monetized** | yes (ORC) | strip proper nouns | any channel | paid OK |
| **ORC + Community Use, free** | yes (ORC) | yes (Community Use) | any channel | **must be free** (Patreon/ads OK) |
| **Pathfinder Infinite** | yes | yes | DriveThruRPG only | paid OK, royalty share |
| **OGL legacy only** | yes (OGL) | no | any channel | paid OK, but content is mechanics-only and pre-Remaster |

**Recommended for a desktop + LLM app**: dual-build. The shipped binary is **ORC-only with stripped Golarion proper nouns** (monetizable). A separate "Golarion content pack" downloaded at runtime under Community Use (free, properly attributed) lets users opt into the setting without bundling it into the paid product.

## Required attribution

Every record carries (a) the ORC license notice, (b) upstream attribution chain, (c) Reserved Material disclosure (which trademarks/proper nouns are NOT licensed), (d) downstream re-grant clause. Foundry pf2e tracks per-pack provenance and a derivative tool **must preserve that metadata** rather than flattening it.

## See also

- [[recommended-stack]] — how this licensing posture flows into product architecture
- [[worldbuilding-tool-landscape-2026]] — pricing decisions tied to the "free vs Infinite vs ORC-only" fork
- [[world-data-model-recommendation]] — provenance metadata on each record

## Open questions

- **Verbatim ORC subsection text** — section structure (I–V with letter subsections) is now confirmed but the literal numbered text is still not ingested locally. The canonical PDF `https://downloads.paizo.com/ORC_LicenseFINAL.pdf` was successfully fetched but WebFetch's summarization layer refused full reproduction. A verbatim markdown mirror exists at `https://github.com/jlaufersweiler/ORC_License_Markdown/blob/main/ORC_license_text.md` — pull this directly via raw.githubusercontent.com or `pdftotext -layout` on the cached PDF in a follow-up round.
- **Pathfinder Infinite** revenue share / specific terms (paizo.com/pathfinderinfinite returned 403 in the previous round).
- ~~Whether Archives of Nethys is the "official" PF2e SRD~~ — **resolved**: AoN operates under a private commercial license with Paizo ([[2026-05-24-aon-licenses-page-commercial-license]]) and is endorsed via paizo.com/pathfinder. The original 2021 Paizo blog announcement is no longer at its canonical URL.
- AoN's Licenses page lacks an ORC notice — possibly stale; worth re-checking annually.
