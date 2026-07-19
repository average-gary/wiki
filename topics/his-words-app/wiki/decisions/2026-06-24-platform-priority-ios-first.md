---
title: "Decision: iOS-first platform priority"
type: decision
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, decision, platform]
sources:
  - raw/articles/2026-06-23-ios-research-verdict.md
  - raw/articles/2026-06-23-ios-app-store-approval-precedent.md
  - raw/articles/2026-06-23-android-implementation-verdict.md
  - raw/articles/2026-06-23-android-accessibility-service-play-policy.md
---

# Decision: iOS-first platform priority

**Decision**: Ship His Words v1 on iOS only. Defer Android to v2+, conditional on iOS validating the [[wiki/concepts/interruption-rhythm|interruption-rhythm]] thesis.

## Context

Both platforms are technically feasible. Both have shipping precedents. The question is sequence under capital and time constraints, not feasibility.

## Rationale

### 1. Onboarding-friction asymmetry (4× difference)

Per [[../raw/articles/2026-06-23-android-implementation-verdict|Android verdict]] and [[../raw/articles/2026-06-23-ios-research-verdict|iOS verdict]]:

| | iOS | Android |
|---|---|---|
| Mandatory permission grants | **1** (FamilyControls) | **4** (Notifications, Usage Access, Display over apps, Battery) |
| Industry-benchmark onboarding completion | ~75-90% | ~35-50% |

For a product whose value proposition depends on continuous monitoring being enabled, this difference is the dominant variable. Android v1 would lose ~half the install funnel to onboarding friction.

### 2. Holy Focus precedent + faith-wellness positioning

[[../raw/articles/2026-06-23-ios-app-store-approval-precedent|Holy Focus]] is approved on iOS with the exact tech stack (FamilyControls + DeviceActivity + Bible content). Approval probability for His Words: **70-80%** with faith-wellness positioning. The precedent is concrete — not aspirational — and carries the entitlement application.

### 3. Google Play Accessibility-Service policy risk

Per [[../raw/articles/2026-06-23-android-accessibility-service-play-policy|Play accessibility policy]]: the technically-superior Android architecture (sub-100ms detection) requires AccessibilityService, which Google's policy explicitly disqualifies for "monitoring apps." Avoiding this means accepting 1-2s polling latency — fine for the [[wiki/concepts/interruption-rhythm|rhythm]] use case but a real product downgrade.

### 4. Demographic skew toward iOS for Christian premium-subscription

Hallow ($52M raised, $51M ARR), Pray.com, Glorify, YouVersion all built iOS-first. Premium-subscription Christian apps over-index iPhone users. Building Android first means fighting market gravity *and* eating 4× onboarding friction. Wrong shape.

### 5. Engineering capacity

Android requires 3-4× iOS effort: custom overlay UI (Apple's shield is system-rendered), per-OEM testing (Pixel, Samsung, Xiaomi, OPPO, Vivo), OEM-killer onboarding (dontkillmyapp.com per-vendor settings deep-links), Play Console specialUse review. For a small founding team, this is the wrong place to spend the v1 build.

## Reversibility

**High.** This is sequencing, not exclusion. The Android stack is solved territory (StayFree, Forest, ScreenZen, AppBlock all ship variants). Six months of iOS validation buys the signal needed to justify Android. If iOS data shows the thesis is real, Android becomes a 4-6 week port plus 4-6 weeks of permission-UX polishing.

If iOS shows the thesis is *not* real, neither platform should ship — and we have not wasted the 3-4× effort of an Android v1 in parallel.

## Triggers to start Android development

- iOS hits ≥50k MAU.
- iOS Day-30 retention ≥40%.
- Subscriber base ≥1,000 paying users.
- ≥20% of organic install attempts come from Android (signaling unmet demand).

Until any of these, Android remains a TestFlight-equivalent prototype at most.

## Risks accepted

- **Demographic exclusion**: a portion of the target audience (evangelical / conservative households over-index Android slightly per imperfect data) is shut out at v1. Acceptable given the funnel asymmetry.
- **Hallow / YouVersion shipping a competitor first**: if either incumbent ships a blocker feature on Android during the iOS-only window, His Words misses Android first-mover. Risk is small (neither has shown intent) but real.
- **Apple FamilyControls policy change**: Apple could tighten entitlement criteria, reject the app, or deprecate the API. Mitigated via Holy Focus precedent + Plan B (Shortcuts-only architecture) + Plan C (notification-only).

## Risks rejected

- **"We need Android for total addressable market."** Hallow proved Catholic-only addresses 75M sub-TAM and reaches #1. Protestant + Reformed iOS-first addresses ≥150M people. Sufficient for $10M+ ARR ceiling.
- **"Android is faster to iterate."** False for this category. Android requires 4-5 permission-flow iterations, OEM-killer documentation, Play Console review of specialUse — *more* iterations to ship.

## Cross-references

- [[wiki/topics/platform-strategy|platform strategy]] — long-form rationale.
- [[wiki/concepts/ios-shield-mechanism|iOS shield mechanism]] — what we ship.
- [[wiki/concepts/android-foreground-service-poll-architecture|Android FGS architecture]] — what we defer.
- [[wiki/reference/ios-api-surface|iOS API reference]].
