---
title: "Paizo Licenses Overview — ORC, OGL, Compatibility, Infinite, Community Use"
source: "https://paizo.com/licenses"
type: article
date_fetched: 2026-05-24
date_published: unknown
tags: [pf2e, licensing, orc, ogl, pathfinder-infinite, compatibility-license, primary-source]
quality: 5
credibility: high
path: pf2e-srd-data
summary: "Paizo offers a tiered set of third-party licenses: ORC (mechanics, post-remaster), OGL 1.0a (mechanics, legacy 2019-2023), Compatibility License (logo/trademark only), Pathfinder/Starfinder Infinite (commercial, platform-locked, near-full IP), and Community Use Policy (free fan content with setting access)."
---

# Paizo's Third-Party Licensing Ladder

## ORC — Open RPG Creative License

- For RPG products using Paizo mechanics published under ORC.
- **Excludes** Reserved Material: Paizo trademarks, copyrighted non-rules content, characters, locations, organizations, deities, events.
- **One-way**: Users must publish solely under ORC if utilizing ORC-specific content. **Cannot convert ORC content into OGL format.**
- Applies to all post-Remaster Paizo books: Player Core, GM Core, Monster Core, Player Core 2, and onward.

## OGL — Open Game License v1.0a

- Legacy license for pre-Remaster Pathfinder 2e (2019-2023 books).
- Same Reserved-Material-style exclusion ("Product Identity").
- Cannot mix ORC and OGL streams.

## Compatibility License

- Grants use of "special compatibility versions of Paizo's trademarks" (logos).
- Described by Paizo as **"the most restrictive"** free offering — logos/trademark only, not broader IP.

## Pathfinder Infinite / Starfinder Infinite

- **"Most permissive free license Paizo offers"**, but exclusive to the Infinite platforms (DriveThruRPG-hosted storefront).
- Allows commercial sale of RPG/published material using nearly all Paizo IP including setting (Golarion, deities, characters).
- Permits derivative works using other Infinite creators' content.
- Revenue share applies (specifics not extracted from this page).

## Community Use Policy

- Non-commercial, freely available content (no paywall) — wikis, streams, merch.
- Covers setting/IP references at the cost of monetization.

## Fan Content Policy

- Permits monetization of **non-RPG derivative works** (streaming, merch) within limits.

## Legal-Posture Decision Tree for a PF2e Tool

| Goal | Best License |
|---|---|
| Ship Remaster mechanics in a free or paid SaaS | **ORC** |
| Reference Golarion setting (deities, nations, NPCs) in a free tool | **Community Use** + ORC |
| Sell a paid product that includes Golarion setting | **Pathfinder Infinite** (DriveThruRPG-locked) |
| Use the "Compatible with Pathfinder 2e" logo on box art | **Compatibility License** + ORC/OGL |
| Pre-Remaster legacy mechanics only | **OGL 1.0a** (do not mix with ORC) |

## Implications for the Worldbuilding/LLM Tool

The cleanest posture for a generally distributed (web/desktop) tool is **ORC for mechanics + Community Use for Golarion references + free distribution**. Paid/SaaS models that want to ship Golarion must either separate setting content into a Pathfinder Infinite product or strip setting names and ship only ORC mechanics with user-supplied setting data.
