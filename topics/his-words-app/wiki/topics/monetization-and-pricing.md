---
title: Monetization and pricing — subscription with church-partnership distribution
type: topic
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: medium
tags: [his-words-app, monetization, pricing, distribution, business]
sources:
  - raw/articles/2026-06-23-market-hallow-funding-and-growth.md
  - raw/articles/2026-06-23-market-youversion-bible-app.md
  - raw/articles/2026-06-23-market-pray-com-funding-trajectory.md
  - raw/articles/2026-06-23-market-glorify-app-uk.md
  - raw/articles/2026-06-23-market-bible-gateway-olive-tree-publishing.md
  - raw/articles/2026-06-23-market-sizing-and-monetization-patterns.md
  - raw/articles/2026-06-23-bible-api-bible-pricing-tiers.md
---

# Monetization and pricing

**Recommendation: subscription with optional lifetime, $59-69/yr ARPU, distributed via church partnerships and Christian podcast ad-buys, not VC-funded performance marketing.** This is a deliberate departure from the Hallow playbook and reflects a thesis about capital efficiency that the [[../raw/articles/2026-06-23-market-sizing-and-monetization-patterns|sizing analysis]] supports.

## The Hallow benchmark — and why not to copy it

Per [[../raw/articles/2026-06-23-market-hallow-funding-and-growth|Hallow funding and growth]]:

- $52M raised across two disclosed rounds (Series A 2021, Series B 2021).
- $69.99/yr ARPU.
- ~730K paying subscribers (per UnHerd estimate Dec 2024) → ~$51M ARR.
- Hit #1 App Store overall in Feb 2024 — the watershed moment for a Christian app.
- Heavy celebrity-endorsement marketing: Wahlberg, Roumie, Neeson, Brand. Three of four cited celebs caused PR issues.
- Super Bowl LVIII ads (~$7M+ for the slot alone, plus production).

Hallow has won. They are the gold-standard comparable. **The relevant question is not "match Hallow" — it is "what does a smaller, more capital-efficient version look like?"**

The capital-efficiency case:

- Hallow's $52M roughly maps to ~$40M of marketing burn against ~$10M of product/payroll. The marketing layer is the dominant cost.
- His Words can hit $10M ARR (~143k paid subs at $70 ARPU) on **$5-10M of capital** if it skips celebrity endorsements and Super Bowl ad-buys.
- The substitution: church-partnership distribution + Christian podcaster ad-buys + organic Christian-influencer micronetwork.

## ARPU benchmarks

Per [[../raw/articles/2026-06-23-market-sizing-and-monetization-patterns|market sizing]]:

| App | ARPU |
|---|---|
| Hallow | ~$70/yr |
| Calm / Headspace (secular comp) | ~$70/yr |
| Pray.com | ~$50-70/yr (inferred) |

The "Christian premium" is flat at ~$70/yr — same as secular wellness, not a discount. **His Words should price at $59-69/yr** with monthly fallback ($7.99/mo) and an optional lifetime tier ($129-199 one-time).

Lifetime pricing rationale:

- Lifetime tiers convert a sub-population of users who deeply distrust subscriptions.
- They lock in early-adopter LTV at install time.
- They create a one-time cash boost early in the app's life when it most needs runway.
- Covenant Eyes ([[../raw/articles/2026-06-23-accountability-covenant-eyes|here]]) sells lifetime at $950 — proving the model works in the Christian-app market at higher price points than secular-wellness norms.

Recommend $129 lifetime at launch, raised to $199 once user base ≥10k.

## TAM math

Per [[../raw/articles/2026-06-23-market-sizing-and-monetization-patterns|sizing]]:

- US Christian smartphone TAM: **~188M people** (235M Christians × 80% smartphone penetration).
- Protestant + non-denominational subset: ~150M (Hallow's Catholic-only sub-TAM is ~75M, and they hit #1).
- Reformed/confessional subset (the audience most distrustful of AI prayers, hence most receptive to His Words' [[wiki/decisions/2026-06-24-no-ai-generated-content|no-AI positioning]]): ~30-40M.

8-figure ARR is achievable from the Reformed/confessional subset alone:

- $10M ARR / $70 ARPU = **143k paid subs**.
- At 3% free→paid conversion = ~4.8M total installs (3% of 30-40M Reformed/confessional TAM = 0.5-1M paid potential — well above the 143k requirement).

The math is favorable.

## Subscription mechanics

- **7-day free trial.** Match BibleScroll's pattern ([[../raw/articles/2026-06-23-competitors-biblescroll|here]]). Most other competitors paywall at install (Prayer Lock, FaithLock); a 7-day trial is a competitive softener.
- **No "free with ads" tier.** Ads in a Scripture-pause app are theologically and aesthetically wrong. Also: API.Bible Starter forbids freemium per [[../raw/articles/2026-06-23-bible-api-bible-pricing-tiers|API.Bible terms]] — but at MVP, His Words ships public-domain only, so this is not directly binding. Forbidding ads is a positioning choice.
- **Annual with monthly fallback.** Annual at $59 (saves ~40% vs. monthly $7.99). Lifetime at $129. Three tiers, no à la carte.
- **No in-app purchases beyond the subscription.** No coin packs (per [[../raw/articles/2026-06-23-competitors-bible-focus-rewired|Bible Focus]] failure mode), no cosmetic themes (Psalmo offers themes — His Words skips), no per-translation upsells until v2 (when NIV / NLT might warrant a "translations bundle" tier).

## Distribution: skip the Hallow playbook

Hallow's playbook: Super Bowl + celebrity endorsements + paid-performance marketing. Estimated marketing-to-product cost ratio ~4:1.

Cheaper, more credible Christian-app distribution:

### 1. Church partnerships

- 20-50 churches commit to mentioning the app in sermon series on attention / discipleship / digital wellness.
- Each church gets a custom referral code and a 25%-off discount for congregants.
- Bonus: pastors get free lifetime access; their congregants see them using it.
- Covenant Eyes' Five Stones playbook ([[../raw/articles/2026-06-23-accountability-covenant-eyes|here]]) shows this works but is sales-heavy. His Words can run a lighter version: package, kit, sermon outlines, no required call.

### 2. Christian podcast ad-buys

- Dozens of Christian podcasts in the 50k-500k weekly download range cost ~$25-200/CPM — roughly 10-50× cheaper per impression than Super Bowl reach against a much higher-converting audience.
- Target: BibleProject, The Holy Post, Phil Vischer, John Mark Comer's content, Ask Pastor John, The White Horse Inn.
- Christian podcasters of theological seriousness will resonate with the [[wiki/decisions/2026-06-24-no-ai-generated-content|no-AI]] positioning.

### 3. Christian micro-influencer organic

- Twitter / X has a thriving Christian intellectual community — Ross Douthat, Tish Harrison Warren, Karen Swallow Prior tier — that is over-indexed for the His Words audience.
- Organic outreach + free lifetime accounts → genuine reviews. No paid posts; risk of reputational backlash if disclosed-as-paid.

### 4. App Store discoverability

- Per [[../raw/articles/2026-06-23-competitors-faithlock-variants|FaithLock saturation]]: keyword competition on "Bible verse" + "screen time" is brutal. His Words must own a distinctive name (the brief satisfies this) and lean on category-defining keywords.

## Faith-VC reality check

Per [[../raw/articles/2026-06-23-market-pray-com-funding-trajectory|Pray.com]]: CEO Steve Gatena publicly cites VC bias against faith-tech as a major obstacle. His Words should expect:

- 2-3× more outreach than secular wellness peers to fund a comparable round.
- Likely path of least resistance: faith-aligned funds (Sovereign's Capital, Crossway Ventures, Faith Driven Investor) before tier-1 secular VCs.
- Glorify ([[../raw/articles/2026-06-23-market-glorify-app-uk|here]]) is the precedent that a16z entered on Christian-app — but $40M Series A is uncommon.
- **Default plan: bootstrap / friends-and-family round of $250k-1M; pursue a Series A only after $1M+ ARR proven.**

## What does NOT work

- **Donation-only.** Bible Gateway's predecessor (Gospel Communications International) failed on donation funding; sold to Zondervan in 2008 ([[../raw/articles/2026-06-23-market-bible-gateway-olive-tree-publishing|here]]). Pure donation requires patron-class capital (David Green / Hobby Lobby) or YouVersion-scale already.
- **Per-resource purchases.** Olive Tree's model. Caps LTV; doesn't fit the recurring-rhythm product shape.
- **Pure freemium with ads.** Theologically unfit; also forbidden by API.Bible Starter (binding when His Words upgrades to copyrighted translations).

## Pricing summary card

| Tier | Price | Notes |
|---|---|---|
| **Free trial** | 7 days | Full features |
| **Monthly** | $7.99 | Fallback for hesitant subs |
| **Annual** | $59 | Lead, saves 40% vs monthly |
| **Lifetime (limited)** | $129 → $199 | Launch at $129, raise after 10k installs |

## Cross-references

- [[wiki/topics/positioning-and-differentiation|positioning]] — the value-prop being priced.
- [[wiki/topics/mvp-feature-set|MVP feature set]] — what's in the price.
- [[wiki/topics/bible-content-licensing|content licensing]] — costs flowing into the price.
- [[wiki/reference/christian-app-market-snapshot|Christian app market snapshot]] — comp pricing.
