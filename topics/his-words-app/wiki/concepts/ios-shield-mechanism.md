---
title: iOS shield mechanism — DeviceActivity, ShieldActionExtension, BGTaskScheduler
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, ios, technical, architecture]
sources:
  - raw/articles/2026-06-23-ios-screen-time-api-capabilities.md
  - raw/articles/2026-06-23-ios-implementation-patterns.md
  - raw/articles/2026-06-23-ios-research-verdict.md
  - raw/articles/2026-06-23-ios-app-store-approval-precedent.md
---

# iOS shield mechanism

His Words on iOS uses Apple's **Family Controls / Screen Time API** to monitor target apps and present a custom Scripture screen as a *shield* over them. This is the only first-party API path for inserting a non-Apple modal between the user and a third-party app. Indie precedents (One Sec, Opal, Jomo, Holy Focus) prove the architecture; the entitlement is approvable for faith-wellness positioning. See [[../raw/articles/2026-06-23-ios-research-verdict|verdict]] for the executive summary.

## Three-layer architecture

```
┌────────────────────────────────────────────────────────────┐
│ DeviceActivity Monitor (system extension)                  │
│  • Detects when user opens TikTok / Instagram / X / etc.   │
│  • Fires intervalDidStart / eventDidReachThreshold callbacks│
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────┐
│ ManagedSettings + ShieldConfiguration                      │
│  • Applies a shield to targeted apps                       │
│  • Shield is MODAL, not overlay (fully blocks app behind)  │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────┐
│ ShieldActionExtension (iOS 16+)                            │
│  • Renders custom SwiftUI verse UI                         │
│  • Handles dismiss / read more / save buttons              │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ BGTaskScheduler (background recurrence)                    │
│  • Periodic re-check; iOS-imposed 15-30 min floor          │
│  • Cannot achieve true 5-min in pure background            │
└────────────────────────────────────────────────────────────┘
```

## Required entitlement and frameworks

Per [[../raw/articles/2026-06-23-ios-implementation-patterns|implementation patterns]]:

- Entitlement: `com.apple.developer.family-controls` (Apple-approval-gated; see [[../raw/articles/2026-06-23-ios-app-store-approval-precedent|approval precedent]]).
- Frameworks: `FamilyControls`, `DeviceActivity`, `ManagedSettings`, `ManagedSettingsUI`.
- Min iOS: 15 for base monitoring, 16 for `ShieldActionExtension` custom UI.

## What the API can and cannot do

| Capability | Native? | Workaround |
|---|---|---|
| Monitor TikTok/IG/YT usage | Yes (DeviceActivity) | n/a |
| Trigger shield on app open | Yes (instant) | n/a |
| Show custom Scripture UI | Yes (ShieldActionExtension, iOS 16+) | n/a |
| **Recur every 5 min while user in TikTok (foreground)** | Yes | Local timer in extension |
| **Recur every 5 min while app is backgrounded** | No | BGTaskScheduler floor 15-30 min |
| Make shield non-bypassable | Yes (modal, not overlay) | n/a |
| Make shield dismissable after N seconds | Yes | Custom timer in extension |

The **5-minute background problem** is the architecture's hardest constraint. iOS will not let arbitrary apps wake every 5 minutes — battery and fairness reasons. Practical resolutions:

1. Foreground-mode opt-in. User keeps His Words in Split View / on home screen — real-time 5-min works.
2. Accept 15-30 min floor when fully backgrounded. Not catastrophic for the spiritual-pause use case; the user still gets multiple interrupts per hour.
3. Use local notifications as a complementary channel — but these are user-visible and require explicit opt-in.

## Shield is modal, not overlay — and this is a feature

Apple's shield *replaces* the target app while active. The user cannot interact with TikTok behind the shield. This is *stronger* than a transparent overlay because:

- No way to "peek" or scroll behind the shield.
- Stronger guarantee of the [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]] holding for the configured ~6s.
- Cleaner UX (the shield owns the screen).

A trade-off His Words inherits without choosing it.

## The custom shield UI

ShieldActionExtension allows full SwiftUI rendering. The pseudo-code from [[../raw/articles/2026-06-23-ios-implementation-patterns|implementation patterns]]:

```swift
struct ShieldActionView: View {
    @State private var verse: BibleVerse = fetchDailyVerse()
    var body: some View {
        ZStack {
            LinearGradient(...)  // calm gradient
            VStack {
                Text(verse.text).font(.body).foregroundColor(.white)
                Text(verse.reference).italic()
                Button("Read Full Chapter") { openBibleApp() }
                Button("Save Verse") { saveVerse(verse) }
                Button("Return to App") { dismiss() }
            }
        }
    }
}
```

The extension runs in a separate process from the main app. Verses must be pre-cached locally (UserDefaults / file) — the extension cannot make network calls reliably.

## Approval positioning

Per [[../raw/articles/2026-06-23-ios-app-store-approval-precedent|approval precedent]]: Holy Focus is approved with this exact stack. Approval probability is ~70-80% if positioning is **faith-wellness** (not surveillance, not parental control, not addiction-language). See [[wiki/topics/platform-strategy|platform strategy]] for the full positioning argument.

Concrete approval moves:

- App Store description: "Transform scrolling into moments with God."
- Privacy policy: explicit no-data-collection, no-cross-tracking, no-cloud-sync of usage logs.
- Use-case document for entitlement request: link Holy Focus as comparable approved app, frame as personal wellness.
- Avoid: "block addictive apps", "monitor family", "addiction recovery."

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — the behavior this mechanism enables.
- [[wiki/reference/ios-api-surface|iOS API surface]] — the full reference card.
- [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS first]].
- [[wiki/topics/platform-strategy|platform strategy]] — iOS vs Android trade-offs.
