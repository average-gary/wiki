---
title: AccessibilityService for app detection — Google Play's "primarily for users with disabilities" policy
source: https://support.google.com/googleplay/android-developer/answer/10964491
type: article
created: 2026-06-23
tags: [his-words-app, android, accessibility-service, google-play-policy, app-blocker]
quality: 5
confidence: high
summary: AccessibilityService gives sub-100ms TYPE_WINDOW_STATE_CHANGED events but Google Play's 2021+ policy explicitly disqualifies "monitoring apps" — non-accessibility use is policy-risky and requires Permission Declaration Form review.
---

# AccessibilityService for His Words: technically perfect, policy-fraught

**Verdict for His Words:** Technically the best detection mechanism (zero polling, push events). Policy-wise, the **highest-risk path on Android**. Use UsageStatsManager instead unless you are willing to fight a Play review.

## What AccessibilityService gives you that UsageStatsManager doesn't

`AccessibilityService` is a system service designed for screen readers, switch access, and similar disability tools. It receives push callbacks from the WindowManager when:

- `TYPE_WINDOW_STATE_CHANGED` — the foreground window/activity changes. Fires within ~50ms of the user tapping an Instagram icon.
- `TYPE_WINDOW_CONTENT_CHANGED` — DOM-equivalent tree changes in the visible app.
- `TYPE_VIEW_CLICKED`, `TYPE_VIEW_TEXT_CHANGED`, etc.

For app blockers, the standard pattern is:

```kotlin
override fun onAccessibilityEvent(event: AccessibilityEvent) {
    if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
        val pkg = event.packageName?.toString() ?: return
        if (pkg in blockedPackages) {
            showOverlayOrKickToHome()
        }
    }
}
```

This is **strictly superior** to UsageStatsManager polling — push event, no polling cost, sub-100ms latency, no Doze throttle.

## Why most modern Android app blockers still use AccessibilityService

Despite the policy risk, **AccessibilityService is the standard architecture** for serious app blockers because:

1. UsageStatsManager polling has 1–2s latency, during which the user has already seen Instagram's feed.
2. Only AccessibilityService can read text content of the foreground app (e.g., "is the user in /reels?" for content-level blocking).
3. Only AccessibilityService can `performGlobalAction(GLOBAL_ACTION_BACK)` to forcibly back-out of an app.

Apps known to use AccessibilityService for blocking as of 2024–2026:
- **StayFree** — uses both UsageStatsManager (for stats) and AccessibilityService (for blocking).
- **AppBlock — Stay Focused** — AccessibilityService-based.
- **BlockSite** — AccessibilityService for browser content filtering.
- **ScreenZen** — AccessibilityService.
- **OffScreen** — AccessibilityService.
- **Forest** — Uses UsageStatsManager primarily; does NOT use AccessibilityService for the core focus mechanic, which is part of why it can ship on Play with less friction.
- **Mindful** (open source, Mihir-J/Mindful on GitHub) — AccessibilityService.

## Google Play's accessibility policy (effective Nov 3, 2021, enforced 2022+)

Verbatim from Play Console policy:

> "Only services that are designed to help people with disabilities access their device or otherwise overcome challenges stemming from their disabilities are eligible to declare that they are accessibility tools."

Explicitly **disqualified** categories listed in policy:

> "antivirus software, automation tools, assistants, monitoring apps, cleaners, password managers, and launchers."

App blockers fall under "monitoring apps" / "automation tools." This means:

1. You **cannot** declare `<service android:isAccessibilityTool="true">` — that's reserved for genuine a11y tools.
2. You **must** complete the Permission Declaration Form in Play Console explaining your use case.
3. You **must** display a prominent in-app disclosure before activating AccessibilityService, with affirmative user consent.
4. Approval is at Google's discretion and reviewers have rejected app blockers in waves (notably Q2 2022, Q1 2023).

## Real enforcement record (2022–2026)

- **2022:** First wave of removals/rejections; LastPass, Tasker, several password managers re-architected. Several app blockers were temporarily removed.
- **2023:** Enforcement loosened in practice; many blockers got re-approved with disclosure flows. Cerberus and other security tools migrated off AccessibilityService.
- **2024:** Android 13's "Restricted Settings" added a second layer — sideloaded apps cannot enable AccessibilityService at all without the user navigating Settings > Apps > [App] > Three-dot menu > "Allow restricted settings." Play-installed apps are exempt from Restricted Settings.
- **2025–2026:** Play continues to approve declared use cases case-by-case for productivity/wellness, but has explicitly stated apps must "minimize permissions" and prefer alternatives. Reviews have grown more rigorous, with some apps rejected for using AccessibilityService when UsageStatsManager would have sufficed.

## The standard "two-track" architecture

What StayFree, ScreenZen, and AppBlock actually ship:

1. **Primary detection:** AccessibilityService for sub-100ms push events.
2. **Fallback:** UsageStatsManager polling at 1Hz when AccessibilityService is disabled.
3. **Permission flow:** Onboarding shows two consent screens — first the disclosure (required by Play), then deep-link into Settings to enable the service. Drop-off here is severe — reportedly 40–60% of users abandon during AccessibilityService grant.
4. **Play submission:** Permission Declaration Form filled in detail explaining the focus/wellness use case.

## Recommendation for His Words

**Start with UsageStatsManager-only.** Reasons:

- Lower policy risk for a small/new developer with no Play review history.
- 1–2 second latency is *acceptable* for a "Scripture overlay" UX — it's not a hard block, it's a gentle interruption.
- If launches go well and you need sub-100ms reaction (e.g., for content-level filtering of "Reels" specifically), graduate to AccessibilityService later as v2.

Adding AccessibilityService later is *easier* than getting rejected at first review and re-architecting. Be the boring app that ships, not the cool app that gets removed.

## Key references for further verification

- Google Play Developer Program Policies, "Use of the Accessibility API" section.
- Android 13 Restricted Settings docs — `android.permission.BIND_ACCESSIBILITY_SERVICE`.
- 2022 Play Console announcement: "Use of Accessibility APIs in non-accessibility apps."
