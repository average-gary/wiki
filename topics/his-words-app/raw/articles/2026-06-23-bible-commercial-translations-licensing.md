---
title: Commercial Bible Translations — NIV, NASB, NLT, CSB, MSG Licensing for Apps
source: https://api.bible/ + Biblica/Lockman/Tyndale/B&H/NavPress publisher policies (synthesized)
type: article
created: 2026-06-23
tags: [his-words-app, bible-api, licensing, niv, nasb, nlt, csb, msg, commercial]
quality: 4
confidence: medium
summary: NIV/NASB/NLT/CSB/MSG are all gated through publisher licensing. Easiest path is API.Bible Pro at ~$10/mo per copyrighted translation. Direct publisher licensing involves royalties + minimums and is inaccessible to indie devs at MVP stage.
---

# Commercial Bible Translation Licensing for App Developers

## Translation → Publisher Map

| Translation | Publisher | License Holder |
|---|---|---|
| NIV (New International Version) | Zondervan / HarperCollins Christian Publishing | Biblica (translation rights) |
| NASB / NASB 2020 | The Lockman Foundation | Lockman directly |
| CSB (Christian Standard Bible) | B&H Publishing / Lifeway | Holman Bible Publishers |
| NLT (New Living Translation) | Tyndale House Publishers | Tyndale |
| MSG (The Message) | NavPress | NavPress / Tyndale |
| NKJV (New King James) | Thomas Nelson / HarperCollins | Thomas Nelson |
| AMP / Amplified | Lockman Foundation | Lockman |

## Three Paths to Use a Copyrighted Translation in an App

### 1. Quote-and-credit fair-use threshold (NOT a license)
Most publishers permit limited quotation without a formal license, typically:
- Up to 500 verses (NIV, NLT, NKJV) or 1,000 verses (some)
- Not exceeding a complete book of the Bible
- Not exceeding 25% of the total work in which they appear
- With proper attribution

**This does NOT cover apps that display verses as their primary feature.** A "verse-of-the-day" or "pause overlay" app will exceed the 25% threshold within a small set of users seeing different verses, AND the verses ARE the product. Fair-use threshold is for books/sermons, not for verse-display apps.

### 2. Direct publisher licensing
- Apply directly to Biblica (NIV), Lockman (NASB), Tyndale (NLT/MSG), B&H (CSB).
- Process: submit app description, audience size, monetization model, sample screens.
- Cost structure: typically royalty-based (per-display or per-active-user fees), often with **annual minimums of $1,000-$10,000+**.
- Timeline: 4-12 weeks; many publishers prefer to license to organizations with track record, not pre-launch indie apps.
- NIV (Biblica) and NLT (Tyndale) are reportedly the most flexible / responsive; Lockman (NASB) is famously strict.

### 3. API.Bible Pro tier (recommended for MVP commercial use)
- $29/mo Pro base + ~$10/mo per copyrighted translation.
- API.Bible has aggregate licenses with the publishers and resells access.
- Per-translation fees stack: NIV+NLT+NASB+MSG = ~$40 add-on + $29 base = ~$69/mo.
- Saves the developer from individually negotiating with 4-5 publishers.
- Still requires Pro tier (no copyrighted Bibles on Starter), and Starter forbids ANY monetization.

## Implication for His Words App
- **Do not build MVP around copyrighted translations.** Risk of licensing rejection or surprise minimums.
- **Ship with public-domain + permissively-licensed translations first.** (See separate article.)
- **Add NIV/NLT via API.Bible Pro post-launch** once user base is shaped and budget exists for ~$50-100/mo + Pro fees.
- **Skip NASB and MSG entirely until Series A scale.** Lockman's terms are restrictive; MSG paraphrase is expensive to license relative to its devotional value vs. ESV/CSB.

## Hard "no freemium" caveat
API.Bible Starter's "no freemium, no upsells" language is an industry signal: copyrighted-translation publishers generally do not want their text used as a hook to convert users to a paid product without a direct license. Expect this clause to appear in any direct publisher contract.
