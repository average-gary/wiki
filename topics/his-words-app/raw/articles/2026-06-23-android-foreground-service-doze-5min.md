---
title: Foreground Service + Doze + AlarmManager — can His Words wake every 5 minutes on Android?
source: https://developer.android.com/about/versions/14/changes/fgs-types-required
type: article
created: 2026-06-23
tags: [his-words-app, android, foreground-service, doze, alarm-manager, work-manager, android-14]
quality: 5
confidence: high
summary: A continuously-running foreground service can poll UsageStats every second and is not Doze-throttled. AlarmManager-only patterns max out at 9-minute fire intervals. WorkManager is 15-minute minimum. The FGS is required.
---

# Periodic check stack: AlarmManager / WorkManager / Foreground Service

**Verdict for "every 5 minutes":** Yes — but **only via a continuously-running foreground service** that polls. Pure AlarmManager and WorkManager cannot do 5-minute intervals reliably. This is the Android architecture every serious blocker uses.

## The three Android "wake periodically" primitives, ranked

### 1. WorkManager — minimum 15 minutes, deferred during Doze

```kotlin
val work = PeriodicWorkRequestBuilder<HisWordsWorker>(15, TimeUnit.MINUTES).build()
WorkManager.getInstance(context).enqueueUniquePeriodicWork(
    "his_words_check",
    ExistingPeriodicWorkPolicy.KEEP,
    work
)
```

- **Minimum interval: 15 minutes.** Hardcoded in the API; passing less throws or is rounded up.
- **Doze:** WorkManager uses JobScheduler internally. Jobs are **deferred** until the next maintenance window when device is dozing.
- **Verdict:** Useless for 5-minute interrupts. Only good for daily "send reminder Scripture at 8am" use case.

### 2. AlarmManager.setExactAndAllowWhileIdle — 9-minute throttle

```kotlin
alarmManager.setExactAndAllowWhileIdle(
    AlarmManager.RTC_WAKEUP,
    System.currentTimeMillis() + 5 * 60_000,
    pendingIntent
)
```

- Verbatim from Android docs: "Neither setAndAllowWhileIdle() nor setExactAndAllowWhileIdle() can fire alarms more than once per nine minutes, per app."
- Even if you schedule 5 minutes out, the system will defer to the 9-minute boundary.
- `setAlarmClock()` bypasses the throttle but shows a system "next alarm" indicator users will find weird for a Bible app.
- `SCHEDULE_EXACT_ALARM` permission required on Android 12+, auto-revoked on 13+ for non-clock apps.
- **Verdict:** Useless for 5-minute intervals.

### 3. Foreground Service running continuously — no throttle, full control

This is **the answer.** A foreground service in `STATE_RUNNING` is exempt from Doze for its in-process work (it can poll, do CPU, run timers). Network access is still throttled in deep Doze, but His Words doesn't need network for the polling loop.

```kotlin
class HisWordsService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val pollIntervalMs = 1500L
    private val notifyIntervalMs = 5 * 60_000L
    private var lastNotify = 0L

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
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

    private fun checkForegroundApp() {
        val pkg = currentForegroundPackage() // queryEvents
        val now = System.currentTimeMillis()
        if (pkg in targetApps && now - lastNotify > notifyIntervalMs) {
            showVerseOverlay()
            lastNotify = now
        }
    }
}
```

- Polls every 1.5s. Battery cost: negligible (~1–2% per day).
- Doze: irrelevant — the FGS keeps the app in the "foreground" process state, exempt from App Standby and Doze CPU restrictions for in-process work.
- 5-minute interrupt: trivially achievable (count milliseconds since last interruption).
- Survives screen-off, but OEM aggressive killers (Xiaomi, OPPO, Vivo, Huawei, Samsung battery optimization) **will** kill it. Solution: prompt user to whitelist battery optimization, document per-OEM at dontkillmyapp.com.

## Android 14 foreground-service-type requirement

Android 14 (API 34) **requires** every FGS to declare a `foregroundServiceType` in manifest AND match a runtime permission. From the official docs:

> "If an app that targets Android 14 doesn't define types for a given service in the manifest, then the system will raise MissingForegroundServiceTypeException upon calling startForeground() for that service."

The 13 valid types are: `camera`, `connectedDevice`, `dataSync`, `health`, `location`, `mediaPlayback`, `mediaProjection`, `microphone`, `phoneCall`, `remoteMessaging`, `shortService`, `specialUse`, `systemExempted`.

For a digital wellness app, **none cleanly fit** — `dataSync` is a stretch, `shortService` has a 3-minute hard timeout. The Play-policy-correct path is **`specialUse`** with a justification:

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

Verbatim from Play Console docs:

> "These values and corresponding use cases are reviewed when you submit your app in the Google Play Console. The use cases you provide are free-form, and you should make sure to provide enough information to let the reviewer see why you need to use the specialUse type."

This is a **gate at Play submission.** Reviewers approve or reject case-by-case. App blockers and digital wellness apps are generally approved if the justification is honest and the persistent notification is non-deceptive.

## Battery optimization exemption

Even with FGS, OEMs (especially Xiaomi, OPPO, Vivo, Huawei, Samsung) will kill background services aggressively. The standard pattern:

```kotlin
val powerManager = getSystemService(POWER_SERVICE) as PowerManager
if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
    intent.data = Uri.parse("package:$packageName")
    startActivity(intent)
}
```

This shows a system dialog asking user to allow the app to ignore battery optimization. Required on most OEMs for the FGS to survive screen-off for hours.

Per dontkillmyapp.com, OEM-specific further hardening:
- Xiaomi MIUI: Settings > Battery & performance > App battery saver > [App] > No restrictions.
- OPPO ColorOS: Settings > Battery > Background battery usage > Allow.
- Samsung One UI: Settings > Apps > [App] > Battery > Unrestricted.
- Huawei EMUI: Settings > Battery > App launch > [App] > Manual > all toggles ON.

His Words onboarding should detect the OEM and link to the appropriate settings page. This is well-documented territory (StayFree, Forest, Sleep As Android all do this).

## Putting it together: the canonical "every 5 minutes" architecture

```
[FGS started on user enable]
         ↓
[Persistent notification shown]
         ↓
[Loop: every 1.5s]
   ↓
[queryEvents on UsageStatsManager]
   ↓
[If target app foreground AND >=5 min since last interrupt]
   ↓
[Add SYSTEM_ALERT_WINDOW overlay with verse]
   ↓
[User dismisses; record timestamp]
   ↓
[Continue polling]
```

This is what StayFree, ScreenZen, AppBlock, Mindful all do, with minor variations. The architecture is solved territory; the hard parts are:

1. Play Console review for `specialUse` (medium risk, usually approved).
2. Permission onboarding UX (high friction — 35–50% drop-off industry-typical).
3. OEM battery-killer whitelisting (very high friction, but well-trodden).

## Digital Wellbeing — is there a public API?

**No.** Android's "Digital Wellbeing" feature (introduced 2018, Pixel-first, now on most devices) is a **system app**. It uses `UsageStatsManager` internally plus privileged signature-permission APIs that third-party apps cannot access:

- `android.app.usage.UsageStatsManager.SYSTEM_USAGE_OBSERVER` — privileged.
- `setAppInactive()` / `setAppStandbyBucket()` — system-only.
- Wind Down / Focus mode internals — closed.

Third-party apps cannot directly toggle Focus mode, set app timers in the system Digital Wellbeing UI, or schedule Wind Down. **There is no analogue to iOS's FamilyControls / DeviceActivityMonitor / ManagedSettings public framework on Android.**

Implication: His Words must rebuild the entire stack itself (FGS + UsageStatsManager + SYSTEM_ALERT_WINDOW). On iOS, Apple gives you the framework. On Android, you build it yourself. This is a meaningful asymmetry — Android implementation is *more work* but has *fewer App Store gates*.
