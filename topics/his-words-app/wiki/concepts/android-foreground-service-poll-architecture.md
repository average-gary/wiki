---
title: Android FGS poll architecture — UsageStatsManager + SAW + specialUse FGS
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, android, technical, architecture]
sources:
  - raw/articles/2026-06-23-android-usage-stats-manager.md
  - raw/articles/2026-06-23-android-system-alert-window-overlay.md
  - raw/articles/2026-06-23-android-foreground-service-doze-5min.md
  - raw/articles/2026-06-23-android-implementation-verdict.md
  - raw/articles/2026-06-23-android-accessibility-service-play-policy.md
---

# Android FGS poll architecture

His Words on Android cannot use a first-party screen-time framework — there is no Android equivalent to iOS Family Controls. The architecture every shipping app blocker (StayFree, ScreenZen, AppBlock, Forest, Mindful) converged on:

```
┌────────────────────────────────────────────────────────────┐
│ Foreground Service (specialUse type, persistent notif)     │
│  • Stays alive across Doze / App Standby                   │
│  • Polls every 1.5s                                        │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────┐
│ UsageStatsManager.queryEvents (last 10s window)            │
│  • Find last ACTIVITY_RESUMED event                        │
│  • If pkg in target_set AND >= 5 min since last interrupt  │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────┐
│ SYSTEM_ALERT_WINDOW overlay (TYPE_APPLICATION_OVERLAY)     │
│  • Renders verse view via WindowManager.addView            │
│  • Tap-blocking, full-screen, dismiss button               │
└────────────────────────────────────────────────────────────┘
```

This architecture is solved territory — multiple ~10M+ install apps run variants of it. See [[../raw/articles/2026-06-23-android-implementation-verdict|verdict]] for the full assessment.

## Why each layer is necessary

### 1. Foreground service — the only viable timer

Per [[../raw/articles/2026-06-23-android-foreground-service-doze-5min|FGS / Doze paper]], the three Android "wake periodically" primitives:

| Mechanism | Min interval | Verdict |
|---|---|---|
| WorkManager | 15 min | Useless for 5-min interrupts |
| AlarmManager.setExactAndAllowWhileIdle | 9-min throttle | Useless |
| **Foreground Service (continuously running)** | **1s+** | **The only path** |

A continuously-running FGS is exempt from Doze CPU restrictions for in-process work. Battery cost is ~1-2% per day for 1.5s polling.

Android 14 (API 34) requires every FGS to declare a `foregroundServiceType`. None of the 13 valid types cleanly fit a digital-wellness app — `dataSync` is a stretch, `shortService` has a 3-min timeout. The Play-policy-correct path is **`specialUse`** with a manifest property justification:

```xml
<service
    android:name=".HisWordsService"
    android:foregroundServiceType="specialUse"
    android:exported="false">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="Digital wellness Scripture reminder: foreground service polls
                       UsageStatsManager to detect when user opens user-configured
                       target apps and presents a brief overlay encouraging a pause.
                       Service is started only when user enables the feature, and
                       can be stopped from the persistent notification."/>
</service>
```

Play Console reviews this case-by-case. Honest justification + comparable approved app (Forest is the cleanest reference) typically clears review.

### 2. UsageStatsManager polling

Per [[../raw/articles/2026-06-23-android-usage-stats-manager|UsageStatsManager paper]]: `queryEvents(beginTime, endTime)` returns `UsageEvents.Event` objects of type `ACTIVITY_RESUMED` (formerly `MOVE_TO_FOREGROUND`). Polling at 1-2s gives ~500ms-2s latency between actual app open and detection. No push API exists; AccessibilityService is the only push alternative and is high policy risk (see below).

Permission: `PACKAGE_USAGE_STATS` (appop, not runtime). User must navigate Settings > Apps > Special access > Usage access > [App] and toggle on. Drop-off rate during this grant: **30-50%** per indie blocker dev reports.

### 3. SYSTEM_ALERT_WINDOW overlay

Per [[../raw/articles/2026-06-23-android-system-alert-window-overlay|SAW paper]]: `TYPE_APPLICATION_OVERLAY` (API 26+) lets His Words draw a Window above all other apps including the foreground app. Permission grant flow:

```kotlin
if (!Settings.canDrawOverlays(this)) {
    startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
        Uri.parse("package:$packageName")))
}
```

User sees a single-toggle screen with a scary system warning ("Allowing this could let the app interfere with the appearance or activity of other apps"). Drop-off here: **25-40%**.

Android 12+ requires the overlay-drawing process to be a foreground service (closes a backdoor). Already covered by the FGS layer above.

## The "AccessibilityService temptation" — and why to skip it

[[../raw/articles/2026-06-23-android-accessibility-service-play-policy|AccessibilityService]] is *technically superior* to UsageStatsManager: push events, sub-100ms latency, no polling cost. Every serious blocker (StayFree, ScreenZen, AppBlock, Mindful) ships it.

But Google Play's 2021+ policy explicitly disqualifies "monitoring apps" and "automation tools" from declaring as accessibility tools. Apps using it must:

1. Complete the Permission Declaration Form in Play Console.
2. Display a prominent in-app disclosure with affirmative consent.
3. Pass case-by-case review at Google's discretion.

Drop-off during AccessibilityService grant alone: **30-40%**. Adding it to His Words v1 would push onboarding completion below ~30% — unviable.

**Recommendation**: Skip AccessibilityService for v1. Polling at 1-2s is acceptable for a Scripture pause. Add accessibility as v2 only if a real product need emerges (sub-100ms blocking, content filtering of "Reels" specifically). See [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS-first]] — the policy risk on Android is one of the major reasons iOS leads.

## The Android tax

Permission stack the user must grant during onboarding:

1. `POST_NOTIFICATIONS` — runtime (Android 13+). Single dialog.
2. `PACKAGE_USAGE_STATS` — Settings > Special access. ~30-50% drop-off.
3. `SYSTEM_ALERT_WINDOW` — Settings > Display over other apps. ~25-40% drop-off.
4. Battery optimization exemption — system dialog or OEM-specific deeper Settings.
5. *(Optional v2)* `BIND_ACCESSIBILITY_SERVICE` — ~30-40% drop-off alone.

**Total: 4 mandatory grants for v1.** iOS has 1 (FamilyControls). Roughly 4× the onboarding friction.

Industry benchmark from StayFree: **35-50% onboarding completion rate** for similar architectures. His Words should expect the same.

## OEM aggressive killers

Even with FGS + battery exemption, OEMs (Xiaomi, OPPO, Vivo, Huawei, Samsung) will kill background services aggressively. Per dontkillmyapp.com:

- Xiaomi MIUI: Settings > Battery & performance > App battery saver > [App] > No restrictions.
- OPPO ColorOS: Settings > Battery > Background battery usage > Allow.
- Samsung One UI: Settings > Apps > [App] > Battery > Unrestricted.
- Huawei EMUI: Settings > Battery > App launch > [App] > Manual > all toggles ON.

His Words onboarding should detect OEM and link to the appropriate settings page. StayFree, Forest, and Sleep As Android all do this.

## Cross-references

- [[wiki/concepts/ios-shield-mechanism|ios shield mechanism]] — the comparable iOS architecture.
- [[wiki/reference/android-api-surface|android API surface]] — full reference card.
- [[wiki/topics/platform-strategy|platform strategy]] — why iOS is v1, Android v2.
- [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS-first]].
