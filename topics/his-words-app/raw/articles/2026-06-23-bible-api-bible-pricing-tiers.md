---
title: API.Bible (American Bible Society) — Pricing, Tiers, and Freemium Restrictions
source: https://api.bible/
type: article
created: 2026-06-23
tags: [his-words-app, bible-api, licensing, api-bible, freemium-restriction]
quality: 5
confidence: high
summary: API.Bible Starter tier ($0) is strictly non-commercial — no ads, no fees, NO FREEMIUM, no upsells. Pro at $29+/mo unlocks commercial copyrighted Bibles at ~$10/mo per translation.
---

# API.Bible (American Bible Society) Developer Terms

API.Bible is operated by American Bible Society and aggregates "hundreds of open access Bibles" plus licensed copyrighted translations through a single REST API. Texts are normalized to the USX standard.

## Pricing Tiers

### Starter — $0/month
- 5,000 API calls per month (caps roughly at ~166/day)
- Choose up to **3 copyrighted Bibles** of choice
- Full access to Creative Commons + Public Domain Bibles
- **Strictly non-commercial use. No ads, fees, freemium models, or upsells allowed.**

### Pro — $29+/month
- 150,000 API calls per month (overage billed ~$1 per 1,000 calls)
- Access to all copyrighted Bibles in catalog
- Commercial use permitted
- Copyrighted translations require additional licensing **starting at $10/month per translation** (separate from Pro base fee)

### Custom / Enterprise — "Coming Soon"
- For apps scaling beyond 100K monthly active users
- Negotiated allowances and per-translation licensing

## Rate Limits
Documented as monthly call allowances. Per-second / per-day burst limits not publicly published — must be discovered via API responses (HTTP 429). Documentation footer states "From 5K/day on Starter to 150K/month on Pro" — note the unit mismatch in their own marketing; assume monthly.

## Available Translations
Catalog includes (per public marketing):
- NIV, NKJV, NASB, CSB, NLT, MSG (Message), Amplified, GNT (commercial — require add-on per-translation fee)
- Plus many international + public-domain translations bundled

## Key Restrictions for His Words App
1. **The Starter free tier is unusable for any monetized app.** "No freemium models or upsells allowed" explicitly forbids the most common indie iOS app pattern (free tier + premium IAP).
2. **Pro tier is required even before counting copyrighted-Bible add-ons** if there is ANY monetization — including a one-time purchase, in-app subscription, or ad-supported model.
3. **Per-translation licensing on Pro** stacks: 6 copyrighted translations = $60/mo on top of $29 base = ~$89/mo minimum.
4. **Caching terms**: not explicitly published on the public pricing page. Assume API.Bible expects calls per display rather than full bulk caching of copyrighted texts; need to verify in actual ToS before shipping.

## Implication
- Public-domain translations only on Starter is the only zero-cost path, but if monetization is planned even later, Starter is contractually unusable.
- For a paid-app ship, budget ~$30-100/mo on Pro depending on translation mix.
