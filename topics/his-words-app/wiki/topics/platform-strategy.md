---
title: Platform strategy — iOS first, Android deferred
type: topic
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, platform, strategy, ios, android]
sources:
  - raw/articles/2026-06-23-ios-screen-time-api-capabilities.md
  - raw/articles/2026-06-23-ios-app-store-approval-precedent.md
  - raw/articles/2026-06-23-ios-implementation-patterns.md
  - raw/articles/2026-06-23-ios-research-verdict.md
  - raw/articles/2026-06-23-android-usage-stats-manager.md
  - raw/articles/2026-06-23-android-accessibility-service-play-policy.md
  - raw/articles/2026-06-23-android-system-alert-window-overlay.md
  - raw/articles/2026-06-23-android-foreground-service-doze-5min.md
  - raw/articles/2026-06-23-android-implementation-verdict.md
---

# Platform strategy

**Decision: iOS first.** Android deferred until iOS validates the [[wiki/concepts/interruption-rhythm|interruption-rhythm]] thesis at ≥50k MAU + ≥40% Day-30 retention. The decision and reversibility analysis is captured in [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS-first]].

This article is the long-form rationale.

## The asymmetry: 1 permission vs. 4 permissions

The single most strategically significant fact about the platform comparison is the **permission grant count**:

| Concern | iOS | Android |
|---|---|---|
| Permission grants required | **1** (FamilyControls) | **4** (Notifications, Usage Access, Display over apps, Battery exemption) |
| Onboarding completion (industry benchmark) | ~75-90% | **~35-50%** |
| App Store / Play review surface | Family Controls entitlement gate | FGS specialUse review |
| Interruption rendering | System-managed shield (modal) | Self-built overlay (WindowManager) |
| Background reliability | Apple-managed | OEM-killer roulette (Xiaomi, OPPO, Samsung battery) |
| Latency | Push (variable, system-batched) | Poll 1-2s (UsageStatsManager) |

Per [[../raw/articles/2026-06-23-android-implementation-verdict|Android verdict]]: iOS has **roughly one-fourth the onboarding friction**. For an app whose entire value proposition depends on the user *enabling and keeping enabled* a continuous monitoring loop, this is the dominant variable.

## iOS: the verdict

Per [[../raw/articles/2026-06-23-ios-research-verdict|iOS research verdict]]:

- **Technical feasibility: yes.** [[wiki/concepts/ios-shield-mechanism|DeviceActivity + ShieldActionExtension + BGTaskScheduler]] is precedent-proven (One Sec, Opal, Jomo, Holy Focus all ship variants).
- **Approval probability: 70-80%.** Holy Focus is the direct precedent — Bible-content + DeviceActivity entitlement, approved. Per [[../raw/articles/2026-06-23-ios-app-store-approval-precedent|approval precedent]], the approval rate hinges entirely on **positioning as personal wellness, not surveillance**.
- **Constraint: 5-min background interval is impossible.** Apple imposes a 15-30 min floor on BGTaskScheduler. Acceptable: real-time 5-min works when app is foregrounded; background degrades to 15-30 min. Most users will see real-time intervals during high-friction moments (when they are actively scrolling) because that is when the OS keeps state warm.
- **Timeline: 3-6 weeks** from entitlement request through App Store approval.

The iOS path is well-trodden. The execution risk is in *positioning copy*, not technology.

## Android: the verdict

Per [[../raw/articles/2026-06-23-android-implementation-verdict|Android verdict]]:

- **Technical feasibility: yes.** [[wiki/concepts/android-foreground-service-poll-architecture|FGS + UsageStatsManager + SAW]] is precedent-proven (StayFree, Forest, ScreenZen, AppBlock).
- **Approval probability: medium.** `FOREGROUND_SERVICE_SPECIAL_USE` requires Play Console review with manifest justification. Honest digital-wellness justification typically clears, but it is a real review step.
- **AccessibilityService is high policy risk and avoidable.** Per [[../raw/articles/2026-06-23-android-accessibility-service-play-policy|Play accessibility policy]], Google explicitly disqualifies "monitoring apps" from accessibility-tool declaration. Use UsageStatsManager polling instead. Skip AccessibilityService for v1.
- **Engineering: 3-4× iOS effort.** Custom overlay UI, OEM-killer onboarding (per dontkillmyapp.com), per-OEM testing (Pixel, Samsung, Xiaomi, OPPO, Vivo).

Android is feasible — it is just substantially more work for substantially worse onboarding. For a small team validating a thesis, this is the wrong place to start.

## Why iOS-first is also the correct *demographic* call

US Christian app demographics skew slightly Android (Apple iPhone share 55-60% in the US, but evangelical/conservative households over-index Android slightly per the imperfect data we have). However:

- **Hallow's $52M raise + #1 App Store ranking** ([[../raw/articles/2026-06-23-market-hallow-funding-and-growth|here]]) was iOS-first. The category leader proved out the audience on iPhone.
- **Premium subscription apps over-index iPhone.** Christian app users who pay for subscriptions skew iOS more than the underlying population.
- **Hallow / YouVersion / Pray.com / Glorify all built iOS-first.** This is the established pattern.

Building Android first would mean fighting the entire market's distribution gravity *and* eating 4× onboarding friction. Wrong shape.

## The "Holy Focus precedent" is doing real work

Per [[../raw/articles/2026-06-23-ios-app-store-approval-precedent|approval precedent]]: Holy Focus is the closest-existing-approved-app to His Words. Same tech (FamilyControls + DeviceActivity), same content vector (scripture interrupts), same audience. **Holy Focus is approved.** This is the single most useful piece of evidence for the entitlement application.

Concrete approval moves:

1. App Store description: "Transform scrolling into moments with God." (Pro-social, wellness-framed.)
2. Privacy policy: explicit no-data-collection, no-cross-tracking, no-server-sync.
3. Use-case document for entitlement request: cite Holy Focus directly, frame as personal wellness, attach screenshots.
4. Avoid trigger phrases: "block addictive apps", "monitor family member's TikTok use", "addiction recovery."

## Reversibility

The platform-priority decision is **highly reversible**. iOS-first does not foreclose Android. The Android stack is solved territory; six months of iOS validation buys all the signal needed to justify the Android build. If the iOS data shows the thesis is real, Android becomes a 4-6 week port plus 4-6 weeks of permission-UX polishing.

If iOS proves the thesis is *not* real, neither platform should ship — and we have not wasted the 3-4× effort of an Android v1 in parallel.

## When to start Android

Triggers that justify starting Android development:

- iOS hits ≥50k MAU.
- iOS Day-30 retention ≥40%.
- Subscriber base ≥1,000 paying users.
- ≥20% of organic install attempts come from Android (signaling unmet demand).

Until then, Android is a TestFlight-equivalent open prototype at most — code reference, not a shipped product.

## What if the entitlement is rejected?

Risk mitigation per [[../raw/articles/2026-06-23-ios-app-store-approval-precedent|approval precedent]]:

1. **First rejection is usable signal.** Apple typically rejects with a specific reason. Common: privacy policy ambiguity, surveillance language. Fix and resubmit; ~6 weeks total cycle.
2. **Fallback: Shortcuts-only architecture.** No FamilyControls entitlement; users install a Shortcuts personal automation. Worse UX but Apple-approval-clean. One Sec used this pre-FamilyControls.
3. **Fallback 2: notification-only.** No DeviceActivity monitoring; user manually starts a "scrolling session" timer. Honor system, much weaker product, but always-approvable.

Plan A is the entitlement; Plan B is Shortcuts; Plan C is notification-only. The first one wins for ~75% of submissions.

## Cross-references

- [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS-first]].
- [[wiki/concepts/ios-shield-mechanism|iOS shield mechanism]].
- [[wiki/concepts/android-foreground-service-poll-architecture|Android FGS architecture]].
- [[wiki/reference/ios-api-surface|iOS API surface]].
- [[wiki/reference/android-api-surface|Android API surface]].
