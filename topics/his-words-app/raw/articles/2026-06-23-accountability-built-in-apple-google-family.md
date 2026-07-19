---
title: Apple Family Sharing & Google Family Link — The Free Defaults Most Families Already Have
source: https://support.apple.com/en-us/HT201304 + https://families.google/familylink/
type: article
created: 2026-06-23
tags: [his-words-app, accountability, family-mode, apple-family-sharing, google-family-link, screen-time, baseline-controls]
quality: 4
confidence: high
summary: Apple Screen Time and Google Family Link cover the parental-control surface for free; any third-party family mode must answer "what does this do that the OS doesn't already?"
---

# The Free Default Layer — Apple Family Sharing + Google Family Link

## Why This Matters First

Every iPhone and Android parent already has these. They're free, OS-integrated, and cover most of what casual parents want. **Any third-party family/accountability product (including a hypothetical His Words family mode) has to answer one question: "What do you do that Screen Time / Family Link doesn't?"**

If the answer is "nothing," the product fails on competitive grounds. If the answer is "more invasive monitoring," the product fails on Apple/Google App Store policy grounds.

## Apple Family Sharing + Screen Time

**Free, built-in, requires no extra app.** Set up via Settings on iPhone/iPad/Mac.

**Capabilities (2026):**
- **Screen Time:** daily app limits, downtime windows, "always allowed" exceptions.
- **Communication Limits:** restrict who kids can message/call during downtime and screen time.
- **Content Restrictions:**
  - Explicit music, podcasts, and media filters.
  - Age-rating filters for movies, TV, books, apps.
  - Web content filtering: unrestricted / limit adult sites / approved sites only.
- **App permissions:** install/delete restrictions, in-app purchase blocking, App Clips controls.
- **Privacy controls:** location, contacts, calendar, photos, mic, Bluetooth.
- **Game Center:** multiplayer rules, friend-adding, screen recording, private messaging.
- **Apple Intelligence (new in iOS 18+):** restrict image generation, writing tools, web search; explicit-language and math-results filters.
- **Settings lock:** prevent kids changing passcodes, Face ID, cellular data, background app activity.
- **Ask to Buy:** parent approval for app installs and in-app purchases.
- **Screen Distance:** new health-oriented control reducing eye strain.

**What Apple Family Sharing does NOT do:**
- No content monitoring of messages, social media, or browser history.
- No screenshots, no AI flagging.
- No alerts on mental health / suicide / predator language.
- No transcripts shared with parents.
- "What apps were used and for how long" is the maximum signal — not "what was inside those apps."

This gap is exactly the gap Bark, Covenant Eyes, etc. fill.

## Google Family Link

**Free, built-in on Android, also works for managing kids' use of Google services on iOS.**

**Capabilities:**
- **Screen time:** daily limits, School Time, Downtime schedules, per-app limits.
- **Educational app exceptions:** unlimited time for chosen apps.
- **Location:** map of kids' devices, geofence-style arrival/departure notifications. Requires device on + connected.
- **Account management:** change/reset child's password, manage account data.
- **App approval:** required for new installs.
- **Content filters:** Chrome, Play Store, YouTube, Search — including SafeSearch.
- **Communication settings management.**

**Age limits:** Designed for children under 13 (or local equivalent). Older teens can use **supervised accounts** with reduced restrictions. At 13, kids can graduate themselves out unless parent retains supervision.

**What Family Link does NOT do:**
- Same gaps as Apple — no content of messages, social, browser pages.
- Cannot monitor third-party messaging apps' internal content.
- Cannot detect mental-health language or predator behavior.

## How They Differ

| | Apple Family Sharing | Google Family Link |
|---|---|---|
| Screen time | Yes | Yes |
| Geofencing | Limited | Strong |
| Content filtering | Strong (web, media, games) | Strong (Chrome, YouTube, Play, Search) |
| Cross-device | Apple ecosystem only | Android primary; some iOS support |
| Lock at 13/18 | Parent retains via Family Sharing | Kid can opt out at 13 unless supervised |
| App approval | Ask to Buy | Required by default for child accounts |
| Apple Intelligence / AI controls | Yes | (Gemini equivalents emerging) |
| Free | Yes | Yes |

## What This Means for the Accountability Category

The whole third-party accountability category exists because Apple and Google **deliberately do not provide content surveillance.** They provide *guardrails* (filters, time limits) but not *transparency* (read everything, share with a third party).

This is a values choice baked into the platforms:
- Apple: privacy as competitive advantage.
- Google: ad-driven, but legally constrained around minors.

Bark, Covenant Eyes, Accountable2You, Ever Accountable, Truple all sell the *transparency layer* the OSes refuse to ship. That's the moat the category has — and it's also why every one of those apps has had Apple/Google Play Store friction.

## Design Lessons for His Words

1. **Assume parents already have Family Sharing or Family Link.** Don't rebuild what they have. Time limits, app approvals, web filters — those are commodity.
2. **The differentiation surface is *inside* apps, not at the OS layer.** Screen Time can't tell a parent whether their kid actually engaged with their Bible plan today; only the app can. This is His Words' natural lane.
3. **The "set verses as homescreen widget / lockscreen" pattern is enabled by Apple/Google APIs and not blocked.** This is a low-friction family-mode hook that doesn't require monitoring.
4. **Don't ship monitoring features.** Anything resembling content surveillance risks Play Store / App Store rejection (per Google's 2022 sweep on Covenant Eyes / A2Y for accessibility-API misuse).
5. **Family Bible plans, shared prayer lists, parent-child devotional pairs** — these are family-mode features that don't compete with OS controls and don't trigger surveillance concerns.

## COPPA / GDPR-K Implications (Quick Reference)

- **COPPA (US):** apps "directed to" under-13s must obtain verifiable parental consent before collecting personal info. Recent (2024–2025) FTC amendments tightened requirements around third-party data sharing and increased enforcement.
- **GDPR-K (EU):** parental consent required for under-16 (or under-13 depending on member state) for personal data processing.
- **Practical implication:** any His Words "kids mode" or under-13 account requires parental-consent flow, data minimization, no third-party advertising on kid surfaces, and likely a separate privacy policy for child users.
- Apple's Kids Category and Google's Designed for Families have stricter SDK rules — would need audit if His Words goes there.

## Open Questions

- Does Apple's new Screen Time API allow third-party apps to read aggregate child usage in any way? (Per ios-screen-time-api-capabilities.md elsewhere in this wiki — yes, in limited form via Family Controls framework.)
- Is there a way to integrate with Family Sharing such that His Words family mode coexists rather than competes with Apple's controls?
