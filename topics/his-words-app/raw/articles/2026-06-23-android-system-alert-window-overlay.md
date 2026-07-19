---
title: SYSTEM_ALERT_WINDOW — overlay permission, Android 10/12/14/15 restrictions, foreground-service requirement
source: https://developer.android.com/reference/android/Manifest.permission#SYSTEM_ALERT_WINDOW
type: article
created: 2026-06-23
tags: [his-words-app, android, system-alert-window, overlay, foreground-service]
quality: 4
confidence: high
summary: Drawing a Scripture overlay over Instagram requires SYSTEM_ALERT_WINDOW (Settings > Display over other apps), and on Android 12+ the overlay-drawing process must be a foreground service. Permission is grantable but high-friction; usable but distrusted by users.
---

# SYSTEM_ALERT_WINDOW: drawing the Scripture overlay on top of Instagram

**Verdict for His Words:** Possible, but the **single biggest UX friction point** in the entire Android architecture. SYSTEM_ALERT_WINDOW is the permission users associate with malware/ads/scams, and its grant flow is intentionally hostile.

## What it does

`android.permission.SYSTEM_ALERT_WINDOW` ("Draw over other apps" / "Display over other apps") allows your app to add a `Window` of type `TYPE_APPLICATION_OVERLAY` (API 26+, replacing the deprecated `TYPE_PHONE` / `TYPE_SYSTEM_ALERT` types) that floats above all other apps including the foreground app.

Standard pattern for showing the His Words verse overlay:

```kotlin
val wm = getSystemService(WINDOW_SERVICE) as WindowManager
val params = WindowManager.LayoutParams(
    WindowManager.LayoutParams.MATCH_PARENT,
    WindowManager.LayoutParams.MATCH_PARENT,
    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
    PixelFormat.TRANSLUCENT
)
wm.addView(verseOverlayView, params)
```

The overlay can be tap-through (FLAG_NOT_TOUCHABLE), tap-blocking, full-screen, or a small floater. For His Words, full-screen tap-blocking that requires "Done" / "Continue" makes sense.

## Permission grant UX

`SYSTEM_ALERT_WINDOW` is an `appop`/special access permission, not a runtime permission. The grant flow:

1. App calls:
   ```kotlin
   if (!Settings.canDrawOverlays(this)) {
       startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
           Uri.parse("package:$packageName")))
   }
   ```
2. User sees **Settings > Display over other apps > [App name]** with a single toggle and a warning:
   > "Allowing this could let the app interfere with the appearance or activity of other apps. Allow display over other apps?"
3. User toggles ON, presses back twice to return to your app.

Drop-off here is non-trivial — the system warning text is genuinely scary. Common drop-off reported by indie dev blogs: 25–40%.

## Android 10+ (API 29) restrictions

- Apps can no longer **start activities from background** unless they hold SYSTEM_ALERT_WINDOW. This is actually advantageous — His Words can open its overlay activity even when the user is in Instagram.
- However, Google encourages using `Notification` + `setFullScreenIntent()` instead.

## Android 12 (API 31) restrictions

- **Overlay must be drawn from a foreground service** for reliability. If your overlay-creating process is killed, the overlay disappears.
- New `HIDE_OVERLAY_WINDOWS` permission lets banking/payment apps hide your overlay over their UI — meaning your Scripture interrupt may be invisible while user is in a banking app. Mostly fine for the His Words use case.
- `FLAG_LAYOUT_NO_LIMITS` interactions with insets changed; cutout/edge cases require testing on Pixel + Samsung.

## Android 13 (API 33)

- Restricted Settings introduced — but applies to AccessibilityService and Notification Listener, **not** to SYSTEM_ALERT_WINDOW directly. SYSTEM_ALERT_WINDOW grant still works for sideloaded apps the standard way.
- New runtime `POST_NOTIFICATIONS` is unrelated but worth grouping in the onboarding "permission stack."

## Android 14 (API 34) — full-screen intents and FGS

- `USE_FULL_SCREEN_INTENT` now auto-revoked unless app is in calls/alarm/clock category. Doesn't directly affect SYSTEM_ALERT_WINDOW but kills one common alternative pattern (using full-screen-intent notifications instead of overlays).
- Foreground service that draws the overlay needs a valid `foregroundServiceType`. For His Words, `specialUse` with manifest property + Play Console justification is the path. Alternative: `dataSync` is sometimes used but is a stretch.

```xml
<service
    android:name=".OverlayService"
    android:foregroundServiceType="specialUse"
    android:exported="false">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="Digital wellness Scripture interruption: foreground service runs while
                       user is using the device to detect target-app launches via UsageStatsManager
                       and present a brief Scripture overlay encouraging the user to take a break.
                       Service runs only while user has the feature enabled."/>
</service>
```

## Android 15 (API 35)

- No major SYSTEM_ALERT_WINDOW changes.
- Edge-to-edge becomes default — the overlay must respect insets.
- "Private space" feature can hide certain apps; not directly relevant.

## Foreground service requirement, in plain language

To reliably show overlays:

- The overlay-drawing process **must** be a foreground service with a persistent notification.
- The notification must be visible (no `IMPORTANCE_MIN` channel suppression). Users will see "His Words is running" persistently — make the icon nice and the text encouraging ("His Words is watching for moments to bless you").
- The FGS must declare `specialUse` and pass Play Console review (see android-android-14-fgs-doze source).

## Combined permission stack for His Words on Android

The total grant flow His Words must shepherd users through:

1. `PACKAGE_USAGE_STATS` (or BIND_ACCESSIBILITY_SERVICE) — to detect Instagram open.
2. `SYSTEM_ALERT_WINDOW` — to draw the verse overlay.
3. `POST_NOTIFICATIONS` (Android 13+, runtime) — for the FGS notification.
4. Battery optimization exemption (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) — to survive Doze/OEM killers.
5. Optionally: AccessibilityService — for sub-100ms reactions (high policy risk).

This is **3–5 separate Settings deep-links** the user must navigate during onboarding. Compare to iOS Screen Time API which is a single FamilyControls.AuthorizationCenter prompt. **This is the Android tax.**

Industry benchmark: StayFree's onboarding completion rate is reported in the 35–50% range; the rest abandon mid-onboarding. His Words should expect similar.

## Recommendation

- Use SYSTEM_ALERT_WINDOW. It's the only viable overlay path.
- Build onboarding as a checklist with progress dots so users see they're 3-of-5 done.
- Use `Settings.canDrawOverlays(this)` and similar checks on app resume to detect if the user toggled OFF — and re-prompt gracefully.
- Test on Pixel, Samsung One UI, Xiaomi MIUI, OPPO ColorOS — overlay behavior diverges across OEMs.
