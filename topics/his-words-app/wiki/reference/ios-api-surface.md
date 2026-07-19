---
title: iOS API surface — FamilyControls, DeviceActivity, ManagedSettings, Shield
type: reference
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, ios, technical, api-reference]
sources:
  - raw/articles/2026-06-23-ios-screen-time-api-capabilities.md
  - raw/articles/2026-06-23-ios-implementation-patterns.md
  - raw/articles/2026-06-23-ios-research-verdict.md
  - raw/articles/2026-06-23-ios-app-store-approval-precedent.md
---

# iOS API surface

Reference card for the Apple frameworks His Words uses on iOS. Pulled from [[../raw/articles/2026-06-23-ios-screen-time-api-capabilities|Screen Time API capabilities]], [[../raw/articles/2026-06-23-ios-implementation-patterns|implementation patterns]], and [[../raw/articles/2026-06-23-ios-research-verdict|verdict]].

## Required entitlement

```
com.apple.developer.family-controls
```

Apple-approval-gated. Request via App Store Connect with use-case document, privacy policy, and screenshots. Approval timeline: **1-4 weeks for entitlement, 1-2 weeks for app review** (in parallel where possible). Total typical: 3-6 weeks.

## Required frameworks

| Framework | Min iOS | Purpose |
|---|---|---|
| `FamilyControls` | 15 | User authorization, app-token picker |
| `DeviceActivity` | 15 | Schedule monitoring, callback events |
| `ManagedSettings` | 15 | Apply restrictions / shields |
| `ManagedSettingsUI` | 15 | Display shields with default UI |
| `BackgroundTasks` (`BGTaskScheduler`) | 13 | Background interval management |
| `UserNotifications` | 10 | Optional secondary interruptions |
| **`ShieldActionExtension`** | **16** | **Custom Scripture UI in shield** |

ShieldActionExtension at iOS 16+ is the critical capability. iOS 15 ships only the default Apple shield UI; for His Words' custom Scripture rendering, **iOS 16+ is the practical floor**.

## Core classes

| Class | Purpose | Notes |
|---|---|---|
| `DeviceActivity` | Define what apps/times to monitor | Initialized with `DeviceActivitySchedule` |
| `DeviceActivityName` | String identifier for a monitoring schedule | Used to look up later |
| `DeviceActivitySchedule` | Time window for monitoring | Day-based or recurring; **NOT sub-minute** |
| `DeviceActivityEvent` | Threshold trigger (e.g., "2 hours of TikTok") | Fires `eventDidReachThreshold` |
| `DeviceActivityMonitor` | Subclass override receives callbacks | Runs in extension process |
| `ManagedSettings` | Apply restrictions to a managed settings store | One per app group |
| `ShieldConfiguration` | Define which apps to shield + visual style | Per-application or per-category |
| `ShieldActionExtension` | iOS 16+ custom shield UI | SwiftUI view in extension |
| `BGAppRefreshTaskRequest` | Background refresh task | iOS schedules at its own pace |

## Key callbacks (DeviceActivityMonitor)

| Callback | When fires | Context |
|---|---|---|
| `intervalDidStart(for:)` | Schedule period begins | Background extension |
| `intervalWillEnd(for:)` | Warning before period ends | Background |
| `intervalDidEnd(for:)` | Schedule period ends (e.g., end of day) | Background |
| `eventDidReachThreshold(_:for:)` | Usage threshold met (e.g., 2hr cumulative) | Background |

Callbacks fire **in a system extension process**, separate from the main app. They run while the user is in the monitored app (TikTok). Latency: variable, OS-batched, typically <1 second but **not guaranteed**.

## Schedule types — what they CAN do

```swift
let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 0, minute: 0),
    intervalEnd: DateComponents(hour: 23, minute: 59),
    repeats: true,
    warningTime: nil
)
```

- Day-based: run on specific weekdays.
- Time-window: 9am-5pm.
- Recurring intervals: daily, weekly, monthly.
- Continuous: 0:00-23:59 with `repeats: true`.

## What schedules CANNOT do

- **Sub-minute intervals**: there is no "fire every 5 minutes" schedule type. The schedule tells DeviceActivity *when to be active*, not *how often to fire*.
- **Exact timing**: even if you set a threshold at 5 minutes, the event may fire 30s+ late due to OS batching.
- **Cross-device**: one device's monitor doesn't know if user moved to iPad.

## Achieving "every 5 minutes" — the layered workaround

```
Layer 1: DeviceActivity threshold event at 5 minutes of TikTok use today
  ↓ Fires → triggers ShieldActionExtension
  
Layer 2: ShieldActionExtension shows custom verse UI
  ↓ User dismisses (after 6s mandatory + optional 60s)
  ↓ App reset threshold to fire again at next 5-min mark
  
Layer 3: BGTaskScheduler keeps app warm
  ↓ Re-registers monitoring on schedule
```

The threshold-reset pattern is what enables recurring rhythm: each fire triggers the shield, and the dismiss action re-arms the threshold for the next 5-minute window.

## BGTaskScheduler floor: 15-30 minutes

```swift
let request = BGAppRefreshTaskRequest(identifier: "com.his-words.check")
request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)  // earliest

try BGTaskScheduler.shared.submit(request)
```

`earliestBeginDate` is a *suggestion*. iOS will not run the task before that time, but may run it much later. **Empirical floor: ~15-30 minutes** when app is fully backgrounded.

For real-time 5-minute rhythm, the user must keep His Words foregrounded (Split View, widget on home screen) — the task can then run on a tighter local timer.

## ShieldConfiguration UI

The shield replaces the monitored app's UI. SwiftUI ShieldActionExtension example:

```swift
struct ShieldActionView: View {
    @State private var verse: BibleVerse = fetchVerseFromCache()
    
    var body: some View {
        ZStack {
            LinearGradient(/* calm gradient */).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Take a Spiritual Pause")
                Text(verse.text).font(.body).foregroundColor(.white)
                Text(verse.reference).italic()
                Button("Read Full Chapter") { openBibleApp() }
                Button("Save Verse") { saveVerse(verse) }
                Button("Return to App") { dismiss() }
            }.padding(24)
        }
    }
}
```

Critical: the extension runs in a **separate process**. Verses must be pre-cached locally. Network calls in the extension are unreliable.

## Privacy manifest

`PrivacyInfo.xcprivacy`:

```xml
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyCollectedDataTypes</key>
<array>
  <dict>
    <key>NSPrivacyCollectedDataType</key>
    <string>NSPrivacyCollectedDataTypeOtherAppActivity</string>
    <key>NSPrivacyCollectedDataTypeLinked</key>
    <false/>
    <key>NSPrivacyCollectedDataTypeTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypePurposes</key>
    <array>
      <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
    </array>
  </dict>
</array>
```

## Approved-app precedents (from [[../raw/articles/2026-06-23-ios-app-store-approval-precedent|approval precedent]])

- **One Sec** — DeviceActivity + ShieldActionExtension pause modal.
- **Opal** — DeviceActivity + ShieldActionExtension scheduled blocking.
- **Jomo** — DeviceActivity + ShieldActionExtension motivational screens.
- **ScreenZen** — DeviceActivity + custom UI breaks.
- **Holy Focus** — **Direct precedent for His Words**. Bible content + DeviceActivity. Approved.
- **BibleFocus** — also approved with similar stack.

## Cross-references

- [[wiki/concepts/ios-shield-mechanism|iOS shield mechanism]] — high-level architecture.
- [[wiki/topics/platform-strategy|platform strategy]] — why iOS first.
- [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS-first]].
- [[wiki/tools/ios-frameworks|iOS frameworks tools card]].
