---
title: iOS frameworks — quick reference card
type: tool
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, ios, frameworks, tools]
sources:
  - raw/articles/2026-06-23-ios-implementation-patterns.md
  - raw/articles/2026-06-23-ios-screen-time-api-capabilities.md
---

# iOS frameworks (tool card)

One-line descriptions of the Apple frameworks His Words depends on. For deeper API surface see [[wiki/reference/ios-api-surface|iOS API surface reference]].

## Core

- **`FamilyControls`** — User authorization layer. Includes `AuthorizationCenter` (request user permission for monitoring) and `FamilyActivityPicker` (let user select which apps to monitor via system picker).
- **`DeviceActivity`** — Schedule definition and monitoring. `DeviceActivitySchedule`, `DeviceActivityMonitor` (extension subclass), `DeviceActivityName`, `DeviceActivityEvent`.
- **`ManagedSettings`** — Apply restrictions. The shielding layer: set `settings.shield.applications` to enforce blocks.
- **`ManagedSettingsUI`** — Default Apple UI for restricted apps. iOS 15 only renders Apple's stock shield; iOS 16+ allows custom via `ShieldActionExtension`.

## iOS 16+ — Critical

- **`ShieldActionExtension`** — Custom shield UI in a separate process. Subclass `ShieldActionDelegate` and provide a SwiftUI view. **This is where the Scripture screen is rendered.**

## Background

- **`BackgroundTasks` (`BGTaskScheduler`)** — iOS-managed background task scheduler. Submit `BGAppRefreshTaskRequest` with `earliestBeginDate`; iOS decides actual execution time. Floor: ~15-30 min.
- **`UserNotifications` (`UNUserNotificationCenter`)** — Local notifications for opt-in tighter intervals. Requires user authorization.

## Data persistence

- **`UserDefaults`** — Lightweight prefs (selected apps, monitor enabled flag, last-interrupt timestamp).
- **`CoreData` or `SwiftData`** — Verse cache, redeemed-time log, saved-verses list. Local-only; no CloudKit at v1.
- **`CloudKit` (CKContainer)** — v2+ for cross-device sync of saved verses and redeemed-minutes total.

## UI

- **`SwiftUI`** — Primary UI framework for both main app and ShieldActionExtension.
- **`UIKit` (`UIHostingController`)** — Shim if SwiftUI integration with extension scaffolding requires it.

## Privacy

- **PrivacyInfo.xcprivacy** — Privacy manifest. Required by Apple for App Store submission. Declare `NSPrivacyCollectedDataTypeOtherAppActivity` for FamilyControls usage (purpose: AppFunctionality only; not Tracking).

## Entitlements

- **`com.apple.developer.family-controls`** — required for DeviceActivity / ManagedSettings / ShieldActionExtension. Apple-approval-gated.

## What NOT to use

- **`NEContentFilterProvider`** — VPN-style content filtering. Designed for adult-content filters, not for scripture pauses. Different policy bucket.
- **`MDM` profiles** — Mobile Device Management. Enterprise-only; consumer apps cannot use.
- **`HealthKit`** — irrelevant.
- **`Siri Shortcuts` / `App Intents`** — One Sec used Shortcuts pre-FamilyControls as a workaround. Not needed once FamilyControls entitlement is granted.

## Cross-references

- [[wiki/reference/ios-api-surface|iOS API surface]] — full reference card.
- [[wiki/concepts/ios-shield-mechanism|iOS shield mechanism]] — high-level architecture.
- [[wiki/decisions/2026-06-24-platform-priority-ios-first|decision: iOS-first]].
