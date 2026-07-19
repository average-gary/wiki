---
title: UsageStatsManager — granularity, latency, permission UX, and detecting foreground app changes
source: https://developer.android.com/reference/android/app/usage/UsageStatsManager
type: article
created: 2026-06-23
tags: [his-words-app, android, usage-stats, package-usage-stats, foreground-detection]
quality: 4
confidence: high
summary: UsageStatsManager can detect when Instagram/TikTok come to foreground via UsageEvents.MOVE_TO_FOREGROUND, but with ~1–2s polling latency and a friction-heavy "Special Access" permission grant flow.
---

# UsageStatsManager: Can His Words detect when the user opens Instagram?

**Verdict for "interrupt every 5 minutes":** Constrained-yes for *detecting* a target app launch with ~1–2 second latency, but useless on its own for *interrupting* — overlay still requires SYSTEM_ALERT_WINDOW + foreground service (see other sources).

## API surface

`android.app.usage.UsageStatsManager` (API 21+, expanded API 28+) is the public, Play-policy-clean way to learn which app is in foreground.

The two relevant methods:

- **`queryUsageStats(intervalType, beginTime, endTime)`** — aggregated per-day/per-week/per-month bucket data. Useless for real-time interruption; designed for "screen time report" UIs.
- **`queryEvents(beginTime, endTime)`** — a stream of `UsageEvents.Event` objects. The event types relevant to His Words:
  - `ACTIVITY_RESUMED` (formerly `MOVE_TO_FOREGROUND`, value 1) — fires when an activity comes to foreground.
  - `ACTIVITY_PAUSED` (formerly `MOVE_TO_BACKGROUND`, value 2)
  - `ACTIVITY_STOPPED` (value 23, API 29+)

The standard polling pattern app blockers use:

```kotlin
val end = System.currentTimeMillis()
val begin = end - 10_000  // last 10 seconds
val events = usm.queryEvents(begin, end)
val event = UsageEvents.Event()
var lastForeground: String? = null
while (events.hasNextEvent()) {
    events.getNextEvent(event)
    if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
        lastForeground = event.packageName
    }
}
```

This loop is typically run every 1000–2000 ms from a foreground service (StayFree, ActionDash, Digital Detox all do this).

## Granularity & latency

- **Latency:** Empirically ~500ms to ~2s between actual app open and event being queryable. The system batches events to a flush buffer; there is no broadcast/callback API. You must poll.
- **Polling cost:** ~1Hz polling from a foreground service is the de-facto industry pattern. Battery cost is small but non-zero (CPU wake every second). Many devs poll at 2s to be conservative.
- **No push API:** Unlike iOS DeviceActivityMonitor (`eventDidReachThreshold`) or AccessibilityService (push events), UsageStatsManager is pull-only. This is the single biggest UX limitation — you cannot get sub-100ms reaction time without AccessibilityService.

## PACKAGE_USAGE_STATS permission UX

This is **not a runtime permission**. It is an `appop` permission that requires the user to:

1. Open Settings.
2. Navigate to **Settings > Apps > Special access > Usage access**. (Path varies by OEM: Samsung One UI hides it under "Permission manager" or "Other permissions"; Xiaomi MIUI hides it deeper.)
3. Find the app in the list.
4. Toggle "Permit usage access" ON.

The standard developer flow opens the system Settings deep link:

```kotlin
startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
```

But this drops the user at the *list of all apps* with usage access — they still have to find your app and toggle it. Drop-off rate in onboarding flows is reported anecdotally at 30–50% by indie blocker devs (StayFree, ActionDash forum threads).

Verifying permission post-grant:

```kotlin
val mode = appOps.unsafeCheckOpNoThrow(
    AppOpsManager.OPSTR_GET_USAGE_STATS,
    Process.myUid(),
    packageName
)
val granted = mode == AppOpsManager.MODE_ALLOWED
```

## Battery impact

- Polling at 1Hz from a foreground service: ~1–3% additional battery per day on modern devices.
- Without a foreground service, polling will be killed by Doze and App Standby — see Android 14 FGS source.
- OEM aggressive killers (Xiaomi, OPPO, Vivo, Huawei) will still kill the foreground service unless the user manually whitelists it via "Battery optimization > Don't optimize" or OEM-specific autostart settings. dontkillmyapp.com tracks this.

## Why this matters for His Words

- **Detecting Instagram/TikTok open:** Yes, ~1–2s latency. Sufficient for a "you've opened a target app — here is Scripture" overlay.
- **Periodic 5-min interrupt across all apps:** Polling is fine, but you need the foreground service running. The 9-minute Doze throttle on AlarmManager (see android-doze-foreground-service source) is the real constraint, not UsageStatsManager itself.
- **Play policy:** `PACKAGE_USAGE_STATS` is a "signature|privileged|appop" permission. Apps requesting it via `Settings.ACTION_USAGE_ACCESS_SETTINGS` are policy-clean — Google Play does not restrict this the way it restricts AccessibilityService. This is the **safe path** for His Words.

## Notes

- API 29+ (Android 10) introduced `queryEventsForSelf` which only returns events for the calling app — not useful here since His Words needs to see Instagram/TikTok events.
- The `UsageStatsManager.queryAndAggregateUsageStats(...)` signature aggregates per-package stats; useful for daily reports but not interruption.
- `UsageEvents.Event.NOTIFICATION_INTERRUPTION` (API 27+) does NOT mean an app launched — it means the system showed a heads-up notification. Don't conflate.
