---
title: Competitive precedents — secular pause-prompt and faith-blocker reference apps
type: tool
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, competitive, precedent, tools]
sources:
  - raw/articles/2026-06-23-ios-app-store-approval-precedent.md
  - raw/articles/2026-06-23-ios-implementation-patterns.md
  - raw/articles/2026-06-23-android-implementation-verdict.md
  - raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md
---

# Competitive precedents

Apps to study, cite, and reference when designing His Words. Some are direct competitors; others are technical/behavioral precedents with no audience overlap. The list below is operational — these are the apps that should be installed on a test device and dissected during product design.

## Secular pause-prompt apps to study

These validate the [[wiki/concepts/interruption-rhythm|interruption-rhythm]] mechanic without competing for the Christian audience.

### One Sec ([[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas|PNAS validation]])

- **Mechanism**: 6-second pause-then-breath at app launch.
- **Tech**: DeviceActivity + ShieldActionExtension + Shortcuts personal automations.
- **Pricing**: Freemium with $2.99/mo subscription.
- **What to study**: the breathing-animation visual treatment, the active-continue-tap pattern, the daily-open-count display on the prompt.
- **Approval precedent**: approved on first attempt after a privacy-policy revision.

### Opal

- **Mechanism**: scheduled blocking + goal reminders + alternative-suggestion nudges ("call a friend").
- **Tech**: DeviceActivity + ShieldActionExtension + Focus Modes integration.
- **Pricing**: Freemium with $4.99/mo.
- **What to study**: goal-personalization, alternative-suggestion UX, Shortcuts integration.

### Jomo

- **Mechanism**: app blocking + check-in reminders + motivational screens.
- **Tech**: DeviceActivity + custom shield UI.
- **Pricing**: Freemium with $9.99/mo.
- **What to study**: motivational-message rotation, check-in cadence.

### ScreenZen

- **Mechanism**: gentle app breaks + custom break UI.
- **Tech**: DeviceActivity + custom UI.
- **Pricing**: Freemium.
- **What to study**: break duration selection, dismissal handling.

## Faith reference (the approval precedent)

### Holy Focus

- **Mechanism**: Bible-reading + prayer reminders + app limits during prayer time.
- **Tech**: DeviceActivity + ShieldActionExtension + Bible content.
- **Pricing**: Freemium (Bible translation upgrades are paid).
- **Approval status**: ✅ APPROVED on iOS — **direct precedent for His Words.**
- **What to study**: how they framed the entitlement application, privacy policy language, App Store description copy.

The single most important precedent. Cite Holy Focus in any FamilyControls entitlement request.

## Direct faith-blocker competitors (the comp set)

For each, install on test device and document mechanism, copy, paywall, and content quality:

- [[../raw/articles/2026-06-23-competitors-prayer-lock|Prayer Lock (Covenant Studios)]] — category leader, 30k+ ratings.
- [[../raw/articles/2026-06-23-competitors-bible-mode|Bible Mode (Friday Labs)]] — ESV-licensed, kitchen-sink.
- [[../raw/articles/2026-06-23-competitors-psalmo|Psalmo (Artmvstd)]] — clean indie new entrant.
- [[../raw/articles/2026-06-23-competitors-biblescroll|BibleScroll (Screen Detox Inc)]] — YouVersion-defer architecture.
- [[../raw/articles/2026-06-23-competitors-bible-focus-rewired|Bible Focus (Rewired LLC)]] — coin economy, theologically aggressive.
- [[../raw/articles/2026-06-23-competitors-faithlock-variants|FaithLock variants × 6]] — saturated lower tier.

See [[wiki/reference/competitors|competitor reference]] for the comparative table.

## Android-side precedents (when His Words ships v2)

- **Forest** — UsageStatsManager-only architecture. **The most policy-clean reference for Play Console review.** "Forest with a Scripture overlay instead of a tree" is the cleanest pitch.
- **StayFree** — UsageStats + Accessibility + Overlay. 10M+ installs. Code reference for the dual-track architecture.
- **AppBlock — Stay Focused** — Accessibility-first. 10M+ installs.
- **Mindful** (open source on GitHub) — Accessibility-based, useful as a code reference.

## Adjacent (audio/AI/devotional but not blockers)

- **Hallow** — Catholic prayer/meditation. Watch for them shipping a blocker.
- **YouVersion** — the Bible reader. 1B installs. Watch for any blocking feature.
- **Bible Chat (Book Vitals)** — AI Bible companion at scale. The non-AI alternative is His Words.
- **Creed (Lemon Tree Labs)** — AI Bible chat companion. Same.
- **Dwell Audio Bible** — audio-first, no blocking.

## What to test on each (a checklist)

For every install:

- [ ] Does it interrupt during ongoing app use, or only at launch?
- [ ] What's the mandatory pause duration?
- [ ] Is dismissal allowed? After how long?
- [ ] What's the verse / content source?
- [ ] AI content yes/no?
- [ ] What's the metric / streak structure?
- [ ] Pricing tier and paywall placement?
- [ ] Onboarding step count?
- [ ] How does it handle the "user circumvents" case?

A spreadsheet from this checklist is the empirical foundation for [[wiki/topics/positioning-and-differentiation|positioning]].

## Cross-references

- [[wiki/reference/competitors|competitor reference table]].
- [[wiki/topics/positioning-and-differentiation|positioning]].
- [[wiki/decisions/2026-06-24-platform-priority-ios-first|iOS-first decision]].
