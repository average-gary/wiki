---
title: Android libraries — quick reference card
type: tool
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, android, libraries, tools]
sources:
  - raw/articles/2026-06-23-android-usage-stats-manager.md
  - raw/articles/2026-06-23-android-foreground-service-doze-5min.md
  - raw/articles/2026-06-23-android-system-alert-window-overlay.md
---

# Android libraries (tool card)

One-line descriptions of the Android system services and Jetpack libraries His Words uses. For deeper API surface see [[wiki/reference/android-api-surface|Android API surface reference]].

## System services

- **`UsageStatsManager`** — Foreground-app detection via `queryEvents`. Pull-only; ~500ms-2s latency. Permission: `PACKAGE_USAGE_STATS` (special access).
- **`WindowManager`** — Overlay rendering. `addView` with `TYPE_APPLICATION_OVERLAY` (API 26+). Permission: `SYSTEM_ALERT_WINDOW`.
- **`PowerManager`** — Battery optimization status. `isIgnoringBatteryOptimizations` + intent to request exemption.
- **`NotificationManager`** — Persistent FGS notification + per-channel importance.
- **`AppOpsManager`** — Verify special-access permissions (`OPSTR_GET_USAGE_STATS`).

## Jetpack / AndroidX

- **`androidx.lifecycle`** — Lifecycle-aware components for foreground service.
- **`androidx.compose.ui`** — UI for main app and overlay rendering. SwiftUI-equivalent.
- **`androidx.work` (WorkManager)** — Periodic background work. **Useless for 5-min interrupts** (15-min minimum). Useful only for daily-reminder Scripture push.
- **`androidx.datastore`** — Preferences storage. Replaces SharedPreferences.
- **`androidx.room`** — Local DB for redeemed-time log, verse cache, saved verses.

## Foreground service (Android 14+)

- **`ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE`** — manifest type required by Android 14+.
- **`PROPERTY_SPECIAL_USE_FGS_SUBTYPE`** — manifest property with justification text. Reviewed in Play Console.

## NOT using in v1

- **`AccessibilityService`** — high Play policy risk per [[wiki/reference/android-api-surface|API surface]]. v2 only if real product need.
- **`AlarmManager.setExactAndAllowWhileIdle`** — 9-minute throttle, useless for 5-min rhythm.
- **`AlarmManager.setAlarmClock`** — bypasses throttle but shows system "next alarm" indicator. Weird UX for a Bible app.

## Per-OEM battery whitelist intents (deep links)

His Words onboarding should detect OEM and offer Settings deep-links per [[wiki/reference/android-api-surface|API surface]]. dontkillmyapp.com is the canonical reference.

| OEM | Intent / Path |
|---|---|
| Xiaomi MIUI | Battery & performance > App battery saver > [App] > No restrictions |
| OPPO ColorOS | Battery > Background battery usage > Allow |
| Samsung One UI | Apps > [App] > Battery > Unrestricted |
| Huawei EMUI | Battery > App launch > [App] > Manual > all toggles ON |
| Vivo Funtouch | Battery > High background power consumption > [App] |

## Cross-references

- [[wiki/reference/android-api-surface|Android API surface]] — full reference card.
- [[wiki/concepts/android-foreground-service-poll-architecture|Android FGS architecture]] — high-level pattern.
- [[wiki/topics/platform-strategy|platform strategy]] — why Android is v2.
