---
title: ESV API (Crossway) — Rate Limits, Caching, and App Use Terms
source: https://api.esv.org/
type: article
created: 2026-06-23
tags: [his-words-app, bible-api, licensing, esv, crossway]
quality: 5
confidence: high
summary: ESV API is free for non-commercial mobile apps. 5,000 queries/day, 1,000/hour, 60/min, 500 verses max per query. Cache up to 500 verses locally. Commercial apps require formal Crossway licensing.
---

# ESV API (Crossway) Developer Terms

The ESV API is operated by Crossway Bibles and provides programmatic access to the English Standard Version translation. As of 2025/2026, the service remains active with updated tiered limits.

## Rate Limits
- **5,000 queries per day** maximum
- **1,000 requests per hour** maximum
- **60 requests per minute** maximum
- **500 verses per query** maximum (or half a book, whichever is less)
- Throttling on overage; no automatic upgrade path — apps over the threshold must license formally.

## Pricing
- **Free** for non-commercial use that meets all general conditions
- **Commercial license required** for: apps charging for access to ESV text specifically, apps "primarily designed to motivate visitors to buy something, to pay for a service, or to give a donation," or any use exceeding the rate limits.
- Commercial licenses obtained via Crossway's online application form. **License is granted to organizations, not individuals or solo developers.** This is a hard gate for indie devs.

## Attribution Requirements
1. Include "ESV" designation with each quotation displayed in the app.
2. Link to www.esv.org on every page/screen using the text.
3. Display one of three standard copyright notices on a dedicated copyright page: "Scripture quotations are from the ESV® Bible (The Holy Bible, English Standard Version®), © 2001 by Crossway, a publishing ministry of Good News Publishers. Used by permission. All rights reserved."

## Caching Terms
- May cache up to **500 verses locally** (per app instance / device)
- Must "periodically clear cache to ensure latest version" — version-bump invalidation required.
- Bulk download / pre-cache of full ESV is NOT permitted under the free tier.

## Mobile App Use
- Mobile app use is permitted on the free tier if all conditions met
- Apps with monetization (paid app, IAP, subscription) cross into "commercial" — require Crossway licensing

## Restrictions Specific to His Words App
- Indie solo developer status is a problem: Crossway licenses apply to **organizations**.
- 60 req/min cap is plenty for a "Scripture pause" overlay (one verse/minute), but bulk pre-fetch of a topical-tagged verse pool would burn budget fast — recommend store-and-rotate cached verse pool design.
- Daily 5,000 query cap could be hit at scale (~5,000 active users displaying once-per-day = full budget).
- No explicit "no freemium" language like API.Bible has, BUT charging in any form pushes you out of free tier.

## Implication
ESV is shippable on free tier for an MVP if:
- Distributed as free app with no monetization
- Caching budget (500 verses / device) is respected
- Daily 5K query budget covers active users
At paid-app stage, formal Crossway licensing is required, and indie/solo status may block approval — incorporate first.
