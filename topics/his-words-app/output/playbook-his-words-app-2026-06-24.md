---
title: His Words — Build Playbook (2026-06-24)
type: output-playbook
created: 2026-06-24
updated: 2026-06-24
status: draft-v1
confidence: medium
tags: [his-words-app, playbook, mvp, roadmap]
sources:
  - wiki/topics/positioning-and-differentiation.md
  - wiki/topics/mvp-feature-set.md
  - wiki/topics/platform-strategy.md
  - wiki/topics/monetization-and-pricing.md
  - wiki/topics/accountability-strategy.md
  - wiki/topics/bible-content-licensing.md
  - wiki/topics/contrarian-objections-and-responses.md
  - wiki/decisions/2026-06-24-platform-priority-ios-first.md
  - wiki/decisions/2026-06-24-no-ai-generated-content.md
  - wiki/decisions/2026-06-24-duration-streaks-not-day-streaks.md
---

# His Words — Build Playbook

A condensed, actionable plan distilled from 42 raw sources and 36 wiki articles compiled in the [[../wiki/_index|wiki layer]]. Cite this file when communicating the concept to a co-founder, designer, or first investor.

## TL;DR

**Build an iOS-first Christian digital-wellness app that interrupts social media every 5 minutes with a 6-second mandatory + optional 60-second Scripture pause. Ship public-domain translations only at launch. Monetize at $69.99/yr after a 14-day trial. Skip AI-generated content. Skip accountability v1. Plan a 12-week build to TestFlight, with a 12-week post-launch retention checkpoint as the go/no-go for v2.**

## The thesis in one sentence

Every existing competitor (Psalmo, Prayer Lock, Bible Mode, BibleScroll, Bible Focus, the entire FaithLock category) uses **one-time-per-day verse-gates** that unlock all monitored apps after a single read; **none re-interrupt during a long Instagram session**. Recurring N-minute Scripture interruption is a genuinely unoccupied position — and it has [[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas|empirical backing]] (One Sec PNAS 2023: ~57% abandonment-at-pause, ~50% time reduction, sustained past 6 weeks).

## Three differentiators that no competitor combines

1. **Recurring N-minute interrupt** instead of daily-reset gates. Universally absent from incumbent verse-gate apps. See [[../wiki/reference/competitors|competitor comparison]].
2. **Scripture-only — no AI-generated content.** Prayer Lock, Bible Mode, FaithLocked, Creed, Bible Chat all ship LLM-generated prayers; Reformed/confessional users distrust them. Credibility moat. See [[../wiki/decisions/2026-06-24-no-ai-generated-content|decision]].
3. **Family-covenant mode (v2)** — group-aggregate redeemed time, distinct from Covenant Eyes' purity-monitoring; symmetric, monotonic, no-cliff. See [[../wiki/concepts/family-covenant-mode|family covenant mode]].

## Hard decisions

| Decision | Choice | Rationale | Source |
|---|---|---|---|
| Platform | iOS first | Holy Focus precedent + single FamilyControls entitlement vs. Android's 4-5 grants + Google Play AccessibilityService policy risk | [[../wiki/decisions/2026-06-24-platform-priority-ios-first|ADR]] |
| AI content | None | Reformed/confessional users distrust LLM prayers; competitors all ship them | [[../wiki/decisions/2026-06-24-no-ai-generated-content|ADR]] |
| Streaks | Duration-based ("minutes redeemed"), rolling 7-day | Williams 2021: count-streaks have a 31% one-miss-quit cliff; duration-streaks recover gracefully and align with grace, not law | [[../wiki/decisions/2026-06-24-duration-streaks-not-day-streaks|ADR]] |
| Pause length | ~6s mandatory + optional 60s | One Sec PNAS empirical sweet spot; longer = reactance per Lukoff 2022 | [[../wiki/concepts/mandatory-reflection-window|concept]] |
| Bibles at launch | KJV + WEB (public domain) | Zero licensing risk; offline; no monetization conflict with API.Bible "no freemium" clause | [[../wiki/topics/bible-content-licensing|topic]] |
| Accountability | Skip v1 | Don't compete with Covenant Eyes' 25-year church distribution; family-covenant mode is v2 | [[../wiki/topics/accountability-strategy|topic]] |
| Monetization | $69.99/yr after 14-day trial | Hallow benchmark; matches Calm/Headspace ARPU; Christians demonstrably pay it | [[../wiki/topics/monetization-and-pricing|topic]] |

## v1 ship list (8-12 weeks)

### Core mechanic
- iOS only, iOS 16+ (FamilyControls / DeviceActivity / ManagedSettings stable since 15.1, 16+ recommended for Shield API)
- Default rhythm: every 5 minutes of continuous use; user-configurable 3-15 min
- ~6s mandatory pause + optional engagement up to 60s
- Always dismissable after the 6s floor

### Monitored apps (default-suggested, user-customizable)
TikTok, Instagram, X (Twitter), YouTube, Facebook, Snapchat, Reddit. Onboarding nudges users to pick 2-3, not 7.

### Scripture
- KJV + WEB bundled offline (~50k+ verses each)
- ~20-30 topical categories from openbible.info (CC-BY)
- ESV is **v1.5+** once a legal entity holds the Crossway license

### Onboarding (implementation-intention ceremony)
1. "Transform scrolling into moments with God"
2. Pick monitored apps
3. Pick rhythm (5 min default)
4. Pick topical area or "rotating"
5. Confirm if-then: "When I'm in [Instagram] for [5 minutes], I want to pause for Scripture on [hope]."
6. FamilyControls authorization (single system prompt)

Target onboarding completion: ≥75%.

### Anti-features (do not ship at any version)
- AI-generated prayers, devotionals, or chat companions
- Coin / earn-to-unlock economies
- Streak-loss shame notifications
- Leaderboards or comparative ranking
- Screenshot-based monitoring (Covenant Eyes 2022 lessons)
- Hard blocking with no dismiss

## Platform reference

### iOS surface
- **FamilyControls** — `AuthorizationCenter.shared.requestAuthorization(for: .individual)`. Entitlement requires Apple approval; precedent (Holy Focus, One Sec, Opal, Jomo) shows ~70-80% approval likelihood.
- **DeviceActivity** — register schedule + `DeviceActivityEvent` (threshold by category/bundle ID).
- **ManagedSettings + ShieldConfiguration** — replace target app's first-launch view with a custom UI containing Bible verse + buttons.
- **ShieldActionExtension** — full SwiftUI control over the shield surface.
- **BGTaskScheduler** — background-task floor is 15-30 min (Apple-imposed). Foreground 5-min works; background falls back to 15-30 min minimum.

### Android (deferred to v3+)
- UsageStatsManager (1-2s polling) + SYSTEM_ALERT_WINDOW + foreground-service `specialUse` is the canonical stack.
- AccessibilityService is the trap — Google Play's Nov-2021 policy disqualifies "monitoring apps." Skip it.
- 4-5 permission grants → onboarding completion 35-50% (vs. iOS's single-prompt 75%+).

## Monetization

| Tier | Price | Includes |
|---|---|---|
| Free trial (14 days) | $0 | Full feature set |
| Annual subscription | $69.99/yr | Standard tier |
| Lifetime (year 1 only, then retire) | $179 | Marketing tool; sunset after launch cohort |

**Distribution motion:** church-partnership outreach + Christian-podcast ad-buys + organic founder-led content. **Avoid the Hallow burn:** their $52M raise ≈ $20+M of Wahlberg/Super Bowl marketing per inference. Capital-efficient path to $10M ARR ≈ 143K paying subs ≈ 4.8M installs at 3% conversion. Pursue Sovereign's Capital / Crossway Ventures / Faith Driven Investor before secular tier-1 VCs.

## 12-week build plan

### Weeks 1-2: setup
- Apple Developer Program; FamilyControls entitlement request submitted day 1
- Legal: form LLC, draft privacy manifest, draft App Store metadata
- Brand identity: 4-5 logo iterations, color palette, typography
- KJV + WEB Bible JSON pipeline (scrollmapper or wldeh + offline indexing)

### Weeks 3-4: core SwiftUI app
- Onboarding flow (6 screens)
- Settings (apps, rhythm, topical area)
- Home screen (lifetime redeemed minutes + today's count + saved-verses cards)
- Local persistence (Core Data or SQLite)

### Weeks 5-6: shield extension
- DeviceActivityMonitor extension
- ShieldActionExtension with custom Scripture UI
- Pause-counter logic (6s mandatory + 60s optional)
- ManagedSettingsStore configuration

### Weeks 7-8: integration
- Wire DeviceActivityCenter scheduling to user's selected apps + rhythm
- Test on real device with 3-5 apps simultaneously
- Verse rotation logic (rolling, no-repeat-within-7-days)
- Topical-area filtering

### Weeks 9-10: polish + RevenueCat
- Subscription paywall (post-trial, gentle)
- Empty states, loading states, error states
- Accessibility audit (Dynamic Type, VoiceOver)
- Privacy manifest finalization

### Weeks 11-12: TestFlight + App Store
- Beta with 30-50 trusted users
- Capture qualitative feedback + retention data
- App Store screenshots + listing copy
- Submit for review (allow 1-2 weeks)

## 12-week post-launch retention checkpoint

| Metric | Target | If miss |
|---|---|---|
| Installs | ≥10,000 | Re-evaluate marketing motion |
| Day-30 retention | ≥40% | The intervention-novelty objection has won; structural revision needed |
| Redeemed time per user per week | ≥30 min | Pacing or topical content not landing |
| Trial→paid conversion (14d) | ≥20% | Pricing or paywall placement issue |
| NPS | ≥40 | Concept not resonating |

If Day-30 retention is below 30%, take the [[../raw/articles/2026-06-23-contrarian-intervention-novelty-isnt-proven|intervention-novelty objection]] seriously and consider a structural pivot to family-covenant + scheduled phone-free time.

## Risks taken seriously

1. **The phone-is-the-problem objection (Crouch, Newport, Reinke).** The strongest theological critique. Answer: ship the *least* phone-app of any Christian app — open it briefly, return to life. Measure outcome as *less total phone time*, not *more app sessions*.
2. **YouVersion already won the friction battle.** YouVersion has ~1B installs and is free. The motivation gap is real. Answer: His Words doesn't compete on Bible reading; it competes for the moments YouVersion *isn't* used (i.e., during distraction-app sessions). Different surface area, different user state.
3. **Interruption fatigue.** One Sec retention plateaus around 30% at 30 days. Answer: Day-30 retention target of 40% is *better than One Sec*. If the product can't beat the reference, the thesis is wrong.
4. **AccessibilityService is unavailable** for Android v3 expansion. Answer: UsageStatsManager-only architecture is what StayFree, Forest, and ScreenZen ship — it works. Just much higher onboarding friction.
5. **Bible licensing economics** at scale. NIV / NASB / CSB / NLT add real cost (licensing fees, per-translation API.Bible Pro tiers). Plan: gate translations to paid tier so each translation is paid for by a subset of subscribers.

## Open questions for next research round

1. Family-covenant-mode UX details — how does shared-aggregate counter work without leaking individual app-usage? Hashed contributions per device + sum? CloudKit shared zone?
2. Church-partnership distribution playbook — what's the ask, what's the offer, what's the price, and what does the pastor actually do?
3. RevenueCat vs. native StoreKit 2 — RC overhead vs. simplicity tradeoff for a single-product subscription.
4. ESV organizational license — whom to email at Crossway, what does the agreement look like, what's the typical lead time?
5. Apple's response to the FamilyControls entitlement application — what's the exact rationale to write?

These can be researched in a follow-up `--plan` round if desired.

## Cross-references

- [[../_index|topic _index]]
- [[../wiki/_index|wiki article layer]]
- [[../raw/_index|raw sources]]
