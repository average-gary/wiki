---
title: Android API surface — UsageStatsManager, FGS, SAW
type: reference
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, android, technical, api-reference]
sources:
  - raw/articles/2026-06-23-android-usage-stats-manager.md
  - raw/articles/2026-06-23-android-accessibility-service-play-policy.md
  - raw/articles/2026-06-23-android-system-alert-window-overlay.md
  - raw/articles/2026-06-23-android-foreground-service-doze-5min.md
  - raw/articles/2026-06-23-android-implementation-verdict.md
---

# Android API surface

Reference card for the Android APIs used by the [[wiki/concepts/android-foreground-service-poll-architecture|FGS poll architecture]]. Pulled from the four Android raw sources.

## Permission stack (v1)

| Permission | Type | Grant flow | Drop-off |
|---|---|---|---|
| `POST_NOTIFICATIONS` | Runtime (Android 13+) | Single dialog | Low |
| `PACKAGE_USAGE_STATS` | Special access (appop) | Settings > Apps > Special access > Usage access | **30-50%** |
| `SYSTEM_ALERT_WINDOW` | Special access (appop) | Settings > Display over other apps | **25-40%** |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | System dialog → OEM-specific | Variable per OEM | High |
| `FOREGROUND_SERVICE` | Normal | Manifest only | None |
| `FOREGROUND_SERVICE_SPECIAL_USE` | Normal + Play review | Manifest + property | Play review gate |

**Total mandatory grants: 4.** Industry-benchmark onboarding completion: **35-50%**.

## NOT in v1

| Permission | Why skip |
|---|---|
| `BIND_ACCESSIBILITY_SERVICE` | High Play policy risk; explicit Google policy disqualifies "monitoring apps" from a11y declaration. Drop-off ~30-40% alone. Add only as v2 if real product need (sub-100ms blocking, content filtering of "Reels"). |

## UsageStatsManager (foreground detection)

```kotlin
val usm = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
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

| Constant | Value | API | Purpose |
|---|---|---|---|
| `ACTIVITY_RESUMED` | 1 (formerly `MOVE_TO_FOREGROUND`) | 21+ | App came to foreground |
| `ACTIVITY_PAUSED` | 2 (formerly `MOVE_TO_BACKGROUND`) | 21+ | App went to background |
| `ACTIVITY_STOPPED` | 23 | 29+ | App fully stopped |

**Latency**: ~500ms-2s between actual app open and event becoming queryable. **No push API**: must poll.

**Polling cadence**: 1Hz (1000ms) is industry de-facto. 1.5-2s acceptable for a Scripture-pause UX (not a hard block).

**Permission verification**:
```kotlin
val mode = appOps.unsafeCheckOpNoThrow(
    AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
)
val granted = mode == AppOpsManager.MODE_ALLOWED
```

## SYSTEM_ALERT_WINDOW (overlay rendering)

```kotlin
val wm = getSystemService(WINDOW_SERVICE) as WindowManager
val params = WindowManager.LayoutParams(
    WindowManager.LayoutParams.MATCH_PARENT,
    WindowManager.LayoutParams.MATCH_PARENT,
    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,  // API 26+
    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
    PixelFormat.TRANSLUCENT
)
wm.addView(verseOverlayView, params)
```

**Permission grant**:
```kotlin
if (!Settings.canDrawOverlays(this)) {
    startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
        Uri.parse("package:$packageName")))
}
```

User sees a single-toggle screen with a system warning ("Allowing this could let the app interfere with the appearance or activity of other apps") — drop-off 25-40%.

**Android 12+ restriction**: overlay must be drawn from a foreground service for reliability. Already covered by the FGS layer.

**HIDE_OVERLAY_WINDOWS** (Android 12+): banking/payment apps can hide your overlay. His Words' Scripture interrupt won't show during banking sessions. Acceptable.

## Foreground service (specialUse)

Manifest:
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />

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

Service implementation:
```kotlin
class HisWordsService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val pollIntervalMs = 1500L
    private val notifyIntervalMs = 5 * 60_000L
    private var lastNotify = 0L

    override fun onStartCommand(...): Int {
        startForeground(NOTIF_ID, buildPersistentNotification(),
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        scheduleNextPoll()
        return START_STICKY
    }

    private fun scheduleNextPoll() {
        handler.postDelayed({
            checkForegroundApp()
            scheduleNextPoll()
        }, pollIntervalMs)
    }
}
```

**Battery cost** at 1.5s polling: ~1-2% per day on modern devices.

**Doze**: irrelevant — FGS keeps the app in foreground process state, exempt from App Standby and Doze CPU restrictions for in-process work.

**Android 14 (API 34)** requires every FGS to declare a `foregroundServiceType`. The 13 valid types: `camera`, `connectedDevice`, `dataSync`, `health`, `location`, `mediaPlayback`, `mediaProjection`, `microphone`, `phoneCall`, `remoteMessaging`, `shortService`, `specialUse`, `systemExempted`. Only `specialUse` cleanly fits digital wellness; `dataSync` is a stretch; `shortService` has 3-min timeout.

**Play Console review** of `specialUse`: case-by-case. Honest manifest justification + comparable approved app reference (Forest is cleanest) typically clears.

## What WorkManager and AlarmManager CANNOT do

| Mechanism | Min interval | Reliable? | Verdict |
|---|---|---|---|
| WorkManager | 15 min | Deferred in Doze | Useless for 5-min interrupts |
| AlarmManager.setExactAndAllowWhileIdle | 9-min throttle | Limited | Useless |
| AlarmManager.setAlarmClock | 1s+ | Yes but UI-visible | Weird UX (system "next alarm" indicator) |
| **Foreground Service polling** | **1s+** | **Yes** | **The path** |

Verbatim from Android docs: "Neither setAndAllowWhileIdle() nor setExactAndAllowWhileIdle() can fire alarms more than once per nine minutes, per app."

## OEM aggressive killers

Even with FGS + battery exemption, OEMs kill background services. Per dontkillmyapp.com:

| OEM | Settings path |
|---|---|
| Xiaomi MIUI | Battery & performance > App battery saver > [App] > No restrictions |
| OPPO ColorOS | Battery > Background battery usage > Allow |
| Samsung One UI | Apps > [App] > Battery > Unrestricted |
| Huawei EMUI | Battery > App launch > [App] > Manual > all toggles ON |
| Vivo Funtouch | Battery > High background power consumption > [App] |

His Words onboarding should detect OEM and link to the appropriate settings page.

## Digital Wellbeing — no public API

Android's "Digital Wellbeing" feature is a system app using privileged signature-only APIs (`SYSTEM_USAGE_OBSERVER`, `setAppInactive()`, `setAppStandbyBucket()`). Third-party apps cannot toggle Focus mode or set system app timers programmatically.

**There is no Android equivalent to iOS FamilyControls.** His Words rebuilds the stack itself on Android. Asymmetric platform engineering cost.

## Real apps using this exact pattern

| App | Architecture | Installs |
|---|---|---|
| **Forest** | UsageStats only (no a11y) | 10M+ — **the most policy-clean reference** |
| **StayFree** | UsageStats + Accessibility + Overlay | 10M+ |
| **AppBlock** | Accessibility | 10M+ |
| **ScreenZen** | Accessibility | ~500K |
| **Mindful** (open source) | Accessibility | github.com — useful as code reference |
| **OffScreen** | Accessibility + Overlay | mid |
| **BlockSite** | Accessibility (web filtering) | large |

**Recommendation**: cite Forest in any Play Console review. "His Words is architecturally similar to Forest, with a Scripture overlay instead of a tree."

## Cross-references

- [[wiki/concepts/android-foreground-service-poll-architecture|Android FGS architecture]] — the high-level pattern.
- [[wiki/topics/platform-strategy|platform strategy]] — why Android is v2.
- [[wiki/tools/android-libraries|Android libraries tools card]].
