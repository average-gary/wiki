---
title: MVP feature set — what ships in v1, what defers to v2
type: topic
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, mvp, scope, product]
sources:
  - raw/articles/2026-06-23-ios-research-verdict.md
  - raw/articles/2026-06-23-ios-implementation-patterns.md
  - raw/articles/2026-06-23-android-implementation-verdict.md
  - raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md
  - raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge.md
  - raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer.md
  - raw/articles/2026-06-23-bible-esv-api-crossway-terms.md
  - raw/articles/2026-06-23-bible-api-bible-pricing-tiers.md
---

# MVP feature set

This is the v1 ship list and the explicit defer list. Every choice is grounded in the research layer above; the goal is a tight, defensible MVP that proves the [[wiki/concepts/interruption-rhythm|interruption-rhythm]] thesis at small scale before any expansion.

## v1 (8-12 weeks of build)

### Core mechanic

- **Platform: iOS only.** Per [[wiki/decisions/2026-06-24-platform-priority-ios-first|platform-priority decision]] and [[wiki/topics/platform-strategy|platform strategy]].
- **Default rhythm: every 5 minutes** of continuous use in monitored app, user-configurable 3-15 min.
- **Mandatory pause: ~6 seconds** (per [[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas|One Sec PNAS]]).
- **Optional engagement: up to 60 seconds** with action buttons (Read more, Save verse, Continue) — see [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]].
- **Always dismissable after the 6s floor.** Non-negotiable per [[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|Lukoff 2022]].

### Monitored apps

Ship with a curated default list of 5-7 high-leverage attention apps:

- TikTok
- Instagram
- X (Twitter)
- YouTube
- Facebook
- Snapchat
- Reddit

User can add or remove from the full FamilyControls picker. Default is the most-cited high-leverage set. Per [[../raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024|Haliburton]]: onboarding should help users select 2-3 apps, not 10+.

### Scripture content

- **Translations: KJV + WEB** (public domain, ~50k+ offline verses each, no licensing risk).
- **ESV: optional add-on at v1** if Crossway organizational license is feasible — per [[../raw/articles/2026-06-23-bible-esv-api-crossway-terms|ESV API terms]], free tier is permitted for non-commercial mobile apps with caching ≤500 verses/device. Ship public-domain only at hard launch; add ESV when an organizational entity exists to hold the license.
- **No AI-generated content of any kind.** No mood-matched LLM prayers, no AI chat companion, no auto-generated commentary. See [[wiki/decisions/2026-06-24-no-ai-generated-content|decision]].
- **Topical taxonomy: ~20-30 categories** drawn from openbible.info CC-BY tags, manually curated — see [[wiki/concepts/topical-verse-categorization|topical verse categorization]].

### Onboarding as implementation-intention ceremony

Per [[wiki/concepts/implementation-intentions|implementation intentions]] and [[../raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer|Gollwitzer]]:

1. Welcome (1 screen — "Transform scrolling into moments with God").
2. Pick monitored apps (default-suggested, user-customizable).
3. Pick rhythm (5 min default; explain that it's adjustable).
4. Pick topical area or "rotating" default.
5. Confirm if-then: "When I'm in [Instagram] for [5 minutes], I want to pause for Scripture on [hope]."
6. FamilyControls authorization (single Apple system prompt).

Onboarding completion target: ≥75% (vs. ~35-50% Android benchmark; iOS is much higher because of the single-prompt FamilyControls flow).

### Metrics

- **Lead metric: minutes redeemed (lifetime, monotonic).**
- Secondary: rolling-7-day attended-interrupt count.
- Optional consecutive-day streak with auto-grace freezes — *off* by default. See [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]].

### UI

Single tab home screen:
- Lifetime redeemed minutes (large).
- Today's count (small).
- Recently saved verses (3-5 cards, swipeable).
- Settings hatch (gear icon top-right).

Avoid: leaderboards, social feed, in-app community, AI chat, news feed.

### Privacy

- **Local-only data.** No cloud sync of usage logs (CloudKit family sync is v2 territory; v1 is single-device).
- **No analytics SDK** beyond Apple's anonymous App Analytics opt-in.
- Privacy manifest declaring no tracking, no data collection types other than `OtherAppActivity` for app functionality only.

## v2 (3-6 months post-launch, conditional on traction)

In rough priority order:

1. **NIV via API.Bible Pro** — once organization formed and budget supports ~$50-70/mo. Per [[../raw/articles/2026-06-23-bible-commercial-translations-licensing|commercial translations]].
2. **CloudKit sync** for redeemed-time + saved verses across user's devices.
3. **Family Covenant Mode** ([[wiki/concepts/family-covenant-mode|here]]) — opt-in shared-aggregate counter for households / Bible study groups.
4. **Topical-time-of-day rotation** — Mon=peace, Tue=patience, etc.
5. **Apple Watch glance** — current redeemed-minutes count on wrist.
6. **Verse import from Bible reading plans** — let users sync their YouVersion plan as the active topical pool.

## v3+ (defer until traction signals)

- Android. Per [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision]] and [[wiki/topics/platform-strategy|platform strategy]] — no Android until iOS hits 50k MAU + 40% retention.
- ESV (Crossway organizational license) once revenue exists.
- Further translations (NLT / NASB / CSB) — per [[../raw/articles/2026-06-23-bible-commercial-translations-licensing|licensing]], stack via API.Bible Pro.
- "Phone-free schedule" (hard lock during sleep / family meal times). Adds value but blurs the focused [[wiki/concepts/interruption-rhythm|rhythm]] thesis.
- Church partnership distribution (the [[wiki/topics/monetization-and-pricing|monetization plan]] explores this in detail; it is mostly a v2+ marketing motion, not a feature).

## Explicit non-features

These do not ship in any version. They are *anti-features* relative to the [[wiki/topics/positioning-and-differentiation|positioning]]:

- AI-generated prayers, devotionals, or chat companions ([[wiki/decisions/2026-06-24-no-ai-generated-content|decision]]).
- Coin economies or earn-to-unlock mechanics (per [[../raw/articles/2026-06-23-competitors-bible-focus-rewired|Bible Focus profile]] — theologically and reactance-prone).
- Streak-loss notifications or shame-style nudges.
- Cross-user leaderboards or comparative ranking.
- Screenshot-based monitoring (per [[../raw/articles/2026-06-23-accountability-covenant-eyes|Covenant Eyes 2022 lessons]]).
- Hard blocking with no dismiss (reactance per [[wiki/concepts/psychological-reactance-and-rebound|reactance]]).

## What "MVP success" means

12-week post-launch checkpoint:

- ≥10,000 installs.
- ≥40% Day-30 retention (vs. ~30% One Sec / ~8% generic Bible app).
- ≥30 minutes/user/week of redeemed time.
- ≥20% of installs convert to paid trial within 14 days.
- Net Promoter Score ≥40.

If retention is below 30%, the [[../raw/articles/2026-06-23-contrarian-intervention-novelty-isnt-proven|intervention-novelty]] objection has won and the product needs structural revision.

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — what v1 ships.
- [[wiki/topics/platform-strategy|platform strategy]] — why iOS only.
- [[wiki/topics/monetization-and-pricing|monetization]] — pricing for v1.
- [[wiki/topics/bible-content-licensing|content licensing]] — what translations ship.
- [[wiki/decisions/_index|decisions index]] — every defer is anchored to a decision file.
