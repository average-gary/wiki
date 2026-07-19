---
title: Bible content licensing — translations strategy from MVP through scale
type: topic
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, bible, licensing, content, strategy]
sources:
  - raw/articles/2026-06-23-bible-api-bible-pricing-tiers.md
  - raw/articles/2026-06-23-bible-esv-api-crossway-terms.md
  - raw/articles/2026-06-23-bible-commercial-translations-licensing.md
  - raw/articles/2026-06-23-market-bible-gateway-olive-tree-publishing.md
  - raw/articles/2026-06-23-market-youversion-bible-app.md
---

# Bible content licensing

The translation-licensing question is the **single biggest non-tech strategic decision** for any Bible-adjacent app. Translation rights are an enforceable monopoly held by 4-5 publishers; the wrong choice can foreclose the most popular US translation (NIV) or land the app in copyright dispute.

**Recommendation for v1: ship public-domain only (KJV + WEB). Add ESV in v2 once an organizational entity exists. Stack NIV via API.Bible Pro post-Series-A. Never ship NASB, MSG, or other restrictive translations until $5M+ ARR.**

## Translation × license matrix

| Translation | Owner | License model | His Words v1 ship? |
|---|---|---|---|
| **KJV** | Public domain | Free | **YES — primary v1** |
| **WEB** (World English Bible) | Public domain | Free | **YES — secondary v1** |
| **ASV** (American Standard) | Public domain | Free | Optional |
| **YLT** (Young's Literal) | Public domain | Free | Optional, niche audience |
| **BSB** (Berean Standard) | Permissive (CC-BY) | Free with attribution | Optional |
| **NET** Bible | Permissive (special license) | Free for app use | v1.1 candidate |
| **LEB** (Lexham English Bible) | Permissive | Free for app use | v1.1 candidate |
| **ESV** | Crossway | Free non-commercial; org license for commercial | **v2** |
| **NIV** | Zondervan/HarperCollins (Biblica) | Commercial license required | **v3** (post-Series-A) |
| **NLT** | Tyndale House | Commercial license required | v3 |
| **NKJV** | Thomas Nelson | Commercial license required | Defer |
| **CSB** | B&H / Lifeway | Commercial license required | Defer |
| **NASB** | Lockman Foundation | Strict; selective licensees | Skip until major scale |
| **MSG** | NavPress | Commercial; expensive | Skip |
| **AMP** | Lockman | Strict | Skip |

## Why public domain at MVP

Per [[../raw/articles/2026-06-23-bible-commercial-translations-licensing|commercial translations]]:

- Direct publisher licensing involves royalties + **annual minimums of $1k-$10k+**, license terms 4-12 weeks, and prefer organizations over indie devs.
- API.Bible Pro at $29/mo + ~$10/mo per copyrighted translation requires the Pro tier (no copyrighted translations on Starter).
- API.Bible Starter is **strictly non-commercial** ([[../raw/articles/2026-06-23-bible-api-bible-pricing-tiers|here]]): "no ads, fees, freemium models, or upsells allowed." Any monetization plan disqualifies Starter use of any copyrighted translation.

The cleanest path for an MVP that intends to monetize:

1. Ship public-domain translations (KJV, WEB, ASV) bundled offline. Zero licensing cost. ~31k+ verses each, complete canon.
2. Use API.Bible Starter only if non-monetized (probably not; His Words plans to subscription-monetize).
3. Add ESV when an organizational entity is registered.
4. Add NIV via API.Bible Pro post-launch.

## Why KJV + WEB specifically

KJV: every Christian audience knows it. The cadence is theologically resonant for older / Reformed audiences. Has known modern-English friction for younger readers.

WEB (World English Bible): a public-domain modernization of the ASV. Reads like a contemporary translation but costs zero. Ideal for users who find KJV's archaic English alienating. Per [[../raw/articles/2026-06-23-competitors-psalmo|Psalmo]]: KJV+WEB is the *de facto* indie-Bible-app default for exactly these reasons.

His Words ships both at v1; user picks default in onboarding; switching is one-tap.

## ESV path

Per [[../raw/articles/2026-06-23-bible-esv-api-crossway-terms|ESV API terms]]:

- **Free for non-commercial mobile apps.** 5,000 queries/day, 1,000/hr, 60/min, 500 verses per query.
- **Cache up to 500 verses locally.** Periodic invalidation required.
- **Commercial license is granted to organizations, not individuals.** This is the gating factor.

Strategy:

- v1 ships without ESV until His Words is incorporated as an organization (LLC or C-corp) with a registered name.
- Once incorporated, apply for the Crossway commercial license. Their organizational requirement is a paperwork friction, not a fundamental gate.
- ESV ships as v2 default for the Reformed/confessional audience that currently has to leave the app for canonical text.

## NIV path

Per [[../raw/articles/2026-06-23-market-bible-gateway-olive-tree-publishing|publishing-house licensing]]:

- NIV is the most popular modern English translation. Without it, "half of US Protestants will not consider the app."
- Zondervan/HarperCollins (via Biblica) typically charges per-installation, per-use, or revenue-share royalties. Specific terms not public; reportedly low- to mid-single-digit % of subscription revenue.
- For a $50M-revenue app at Hallow scale, NIV licensing alone could be $1-3M/yr.

Practical NIV strategy:

1. **Defer NIV until 50k+ MAU.** Below that, the per-installation royalties don't pencil and Zondervan won't engage seriously with a sub-scale indie.
2. **Path of least resistance: API.Bible Pro.** $29/mo Pro base + ~$10/mo per copyrighted translation. NIV via API.Bible saves the developer from individually negotiating with Biblica.
3. **Direct license at scale.** Once $5M+ ARR, direct Zondervan license becomes economically reasonable; cuts out API.Bible margin.

## What about YouVersion-style translation aggregation?

[[../raw/articles/2026-06-23-market-youversion-bible-app|YouVersion]] has 3,000+ Bible versions across 2,243 languages. They have built this over 18 years with Hobby Lobby family wealth subsidizing the licensing layer.

His Words **cannot replicate this**. Nor should it try. The strategy is: **ship enough translation depth to satisfy the app's core use case (one verse interrupt), then defer the long tail.**

For an MVP, KJV + WEB cover ~85% of US English-speaking Christian users acceptably. ESV covers the next ~10% (Reformed/evangelical premium). NIV covers the remaining ~5% who specifically prefer it.

## The "no freemium on free tier" trap

Per [[../raw/articles/2026-06-23-bible-api-bible-pricing-tiers|API.Bible Starter]]: the free tier explicitly forbids "no ads, fees, freemium models, or upsells." A subscription-monetized app cannot use API.Bible Starter — even if the API call only fetches public-domain translations.

The trap: a developer might assume "Starter is fine for KJV, I'll just upgrade for NIV." But Starter's **app-level monetization clause** binds even when fetching public-domain texts. The clean answer is: **bundle public-domain Bibles offline (no API call) and only use API.Bible Pro when you need copyrighted translations.**

For KJV/WEB bundled offline, His Words has zero API.Bible exposure and pays nothing.

## Recommended licensing roadmap

| Milestone | Translations | Licensing cost | Notes |
|---|---|---|---|
| **v1 launch** | KJV, WEB, ASV (bundled offline) | $0 | No API.Bible dependency |
| **v1.1 (3 months)** | + BSB, NET, LEB | ~$0 | Permissive licenses; attribution required |
| **v2 (6-9 months)** | + ESV (free non-commercial; org license once incorporated) | $0 (free tier) → license fee at scale | Caching ≤500 verses/device |
| **v2.5 (~50k MAU)** | + NIV via API.Bible Pro | $29 + $10/mo NIV = $39/mo | First copyrighted translation |
| **v3 (~100k MAU)** | + NLT, NKJV | +$20-30/mo | Stack via API.Bible |
| **Series A scale** | Direct NIV/NLT publisher licenses | Variable | Cuts API.Bible margin |
| **Eventual** | NASB, MSG, CSB | Skip until enterprise scale | Lockman terms restrictive |

## Open questions

- ESV API ToS on caching: 500 verses/device is fine for normal rotation but what about pre-fetching the topical pool? Verify with Crossway in writing before scaling.
- API.Bible "no freemium" clause: explicit verbal confirmation needed that public-domain bundled-offline KJV in a subscription app is policy-clean (it should be — Starter's clause binds Starter, not the app).
- NIV per-installation royalty rate: get a quote at the 50k MAU mark; the negotiation is more important than the published rate.

## Cross-references

- [[wiki/tools/bible-data-sources|bible data sources]] — actual repos for offline bundling.
- [[wiki/reference/bible-translation-licensing-matrix|licensing matrix reference card]].
- [[wiki/topics/monetization-and-pricing|monetization]] — translation cost flows to pricing.
