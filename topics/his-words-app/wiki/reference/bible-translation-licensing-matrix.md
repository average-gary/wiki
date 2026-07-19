---
title: Bible translation licensing matrix
type: reference
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, bible, licensing, reference]
sources:
  - raw/articles/2026-06-23-bible-api-bible-pricing-tiers.md
  - raw/articles/2026-06-23-bible-esv-api-crossway-terms.md
  - raw/articles/2026-06-23-bible-commercial-translations-licensing.md
  - raw/articles/2026-06-23-market-bible-gateway-olive-tree-publishing.md
---

# Bible translation × license × cost matrix

Reference card for translation licensing. Strategy synthesis: [[wiki/topics/bible-content-licensing|bible content licensing]]. Decision basis: [[wiki/decisions/2026-06-24-no-ai-generated-content|no-AI decision]] is independent; this matrix is the translation-tier roadmap.

## Public domain (free, unrestricted)

| Translation | Year | License | Notes |
|---|---|---|---|
| **KJV** (King James Version) | 1611 | Public domain | The definitive PD English Bible. Cadence resonates with older / Reformed audiences. Modern-English friction for younger readers. |
| **WEB** (World English Bible) | 2000s | Public domain | Modernized ASV. Ideal for users who find KJV archaic. **Default v1 modern-English option.** |
| **ASV** (American Standard) | 1901 | Public domain | Foundation for many modern translations. Useful as middle-ground. |
| **YLT** (Young's Literal Translation) | 1862 | Public domain | Literal scholarly value, niche audience. |
| **WMB** (World Messianic Bible) | derivative | Public domain | WEB variant for Hebrew-name preference. Niche. |

**v1 ship**: KJV + WEB bundled offline. Zero licensing cost. ~31k+ verses each, complete canon.

## Permissive licenses (free with attribution / minor terms)

| Translation | License | Notes |
|---|---|---|
| **BSB** (Berean Standard Bible) | CC-BY 4.0 | Free with attribution; permissive for derivative works. |
| **NET** (New English Translation) | Special permissive | Free for app use with attribution + caching limits. |
| **LEB** (Lexham English Bible) | Special permissive | Free for app use. Owned by Logos / Faithlife. |
| **CEB** (Common English Bible) | Special | Some restrictions; verify before bundling. |

**v1.1 ship**: add BSB, NET, LEB. Attribution surface. No cost.

## Crossway / API.Bible / direct-publisher tiers

| Translation | Owner | API.Bible Pro per-translation cost | Direct license cost | Notes |
|---|---|---|---|---|
| **ESV** (English Standard Version) | Crossway | n/a (direct API: free non-commercial; org license at scale) | Variable; org-only | **Free non-commercial mobile app**. 5,000 queries/day, 60/min, 500-verse cache. Commercial license requires *organizational* applicant — not solo dev. |
| **NIV** (New International Version) | Zondervan / HarperCollins (Biblica) | ~$10/mo via API.Bible Pro | Royalty-based; reportedly low- to mid-single-digit % rev share or fixed annual minimums $1k-$10k+ | **The single biggest BD lever**. Without NIV, half of US Protestants will not consider the app. |
| **NLT** (New Living Translation) | Tyndale House | ~$10/mo | Royalty + minimums | Most flexible / responsive direct publisher per [[../raw/articles/2026-06-23-bible-commercial-translations-licensing\|licensing notes]]. |
| **NKJV** (New King James) | Thomas Nelson / HarperCollins | ~$10/mo | Royalty + minimums | Conservative-evangelical adjacent to NIV. |
| **CSB** (Christian Standard) | B&H / Lifeway / Holman | ~$10/mo | Royalty + minimums | SBC-aligned audience. |
| **NASB / NASB 2020** | Lockman Foundation | ~$10/mo | **Strict; selective licensees** | Famously restrictive. Skip until enterprise scale. |
| **MSG** (The Message) | NavPress / Tyndale | ~$10/mo (premium) | Expensive | Paraphrase; expensive to license relative to devotional value. Skip. |
| **AMP** (Amplified) | Lockman Foundation | n/a | Strict | Same gating as NASB. Skip. |

## API.Bible tier breakdown

| Tier | Price | Calls/mo | Copyrighted Bibles | Commercial use? |
|---|---|---|---|---|
| **Starter** | $0 | 5,000 | Up to 3 of choice | **No — strictly non-commercial; "no ads, fees, freemium models, or upsells"** |
| **Pro** | $29+/mo base | 150,000 (overage $1/1k) | All copyrighted | Yes |
| Custom | Negotiated | n/a | n/a | For 100K+ MAU |

**The "no freemium" trap**: Starter forbids ANY monetization on the app, even for public-domain calls. Subscription-monetized apps must use Pro tier. (For apps that bundle public-domain offline with NO API.Bible calls, this clause does not bind.)

## Caching budgets

| Source | Cache limit | Notes |
|---|---|---|
| ESV API | 500 verses per device | Periodic invalidation required |
| API.Bible | Per ToS; verify with publisher | Bulk pre-cache typically not permitted |
| Public domain | Unlimited | Bundle the whole canon offline |

## His Words licensing roadmap

| Milestone | Translations | Licensing cost |
|---|---|---|
| **v1 launch** | KJV, WEB, ASV (offline bundle) | $0 |
| **v1.1 (~3 months)** | + BSB, NET, LEB (permissive) | ~$0 |
| **v2 (~6-9 months)** | + ESV (free tier; org license at scale) | $0 free tier |
| **v2.5 (~50k MAU)** | + NIV via API.Bible Pro | $29 + $10 = $39/mo |
| **v3 (~100k MAU)** | + NLT, NKJV via API.Bible | +$20-30/mo |
| **Series A scale** | Direct NIV/NLT publisher licenses | Variable |
| **Eventual / never** | NASB, MSG, CSB, AMP | Skip |

## Why public-domain-only for MVP

1. Zero licensing risk at launch.
2. KJV+WEB cover ~85% of US English-speaking Christian audience acceptably.
3. App.Bible Starter's "no freemium" clause does not bind if no API call is made.
4. ESV organizational license can be acquired later once entity exists.
5. NIV publisher minimums ($1k-$10k+/yr) don't pencil at sub-50k MAU.

## Why NEVER NASB or AMP

Lockman Foundation's terms are restrictive even for established Christian publishers. Their licensing model assumes traditional print-publication scenarios; mobile-app scaling typically draws unwanted scrutiny. The audience for NASB is small enough that the licensing burden exceeds the addressable user benefit. Skip indefinitely.

## Open questions worth verifying before scaling

- **ESV caching**: 500 verses/device is fine for normal rotation, but what about pre-fetching the full topical pool (~600 verses across ~30 topics)? Verify with Crossway.
- **API.Bible Starter language**: explicit verbal confirmation that public-domain bundled-offline KJV in a subscription app is policy-clean. (Should be — Starter's clause binds Starter, not the app.)
- **NIV per-installation rate**: get a quote at the 50k MAU mark; the negotiation matters more than the published rate.
- **NLT direct license**: Tyndale is reportedly the most flexible direct licensor; worth a conversation early in v2.5 planning.

## Cross-references

- [[wiki/topics/bible-content-licensing|bible content licensing]] — strategic synthesis.
- [[wiki/tools/bible-data-sources|bible data sources]] — actual repos for offline bundling.
- [[wiki/topics/monetization-and-pricing|monetization]] — translation costs flow into pricing.
