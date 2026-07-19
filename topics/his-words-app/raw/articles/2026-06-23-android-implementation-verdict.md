---
title: Android implementation verdict — can His Words ship a 5-minute Scripture interrupt?
source: synthesized from android-usage-stats-manager, android-accessibility-service-play-policy, android-system-alert-window-overlay, android-foreground-service-doze-5min
type: synthesis
created: 2026-06-23
tags: [his-words-app, android, verdict, implementation, architecture, google-play-policy]
quality: 5
confidence: high
summary: Yes, technically feasible. The architecture is solved by 8+ shipping app blockers. Main risks are onboarding friction (3–5 system permission grants) and Play Console review of FOREGROUND_SERVICE_SPECIAL_USE — not the platform itself.
---

# His Words on Android: technical verdict and policy assessment

## TL;DR

**Verdict: YES — feasible with constraints.** The architecture is well-trodden. StayFree, ScreenZen, AppBlock, Forest, Mindful all ship variations of it. The Android tax is *engineering complexity and onboarding friction*, not platform refusal.

**Policy risk: MEDIUM.** Play Console reviews `FOREGROUND_SERVICE_SPECIAL_USE` justification case-by-case for digital wellness apps. AccessibilityService is high-risk and avoidable for v1.

## The canonical His Words Android architecture

```
COMPONENT                          PURPOSE                                  POLICY RISK
─────────────────────────────────  ──────────────────────────────────────   ───────────
PACKAGE_USAGE_STATS permission     Detect Instagram/TikTok foreground       LOW (clean)
UsageStatsManager.queryEvents      Poll every 1–2s for ACTIVITY_RESUMED     LOW
Foreground Service (specialUse)    Stay alive across Doze, run poll loop    MEDIUM (Play review)
SYSTEM_ALERT_WINDOW                Draw verse overlay over Instagram        LOW
POST_NOTIFICATIONS (API 33+)       FGS persistent notification              LOW
REQUEST_IGNORE_BATTERY_OPT          Survive OEM aggressive killers           LOW (just friction)
[OPTIONAL] AccessibilityService    Sub-100ms reaction, content filtering    HIGH (avoid v1)
```

## Permission stack the user must grant

In order of friction:

1. **POST_NOTIFICATIONS** — runtime, single dialog. Easy.
2. **PACKAGE_USAGE_STATS** — Settings > Special access > Usage access > [App]. ~15s, but path-finding.
3. **SYSTEM_ALERT_WINDOW** — Settings > Display over other apps > [App]. Single toggle, scary warning text.
4. **Battery optimization exemption** — system dialog OR OEM-specific deeper Settings dive.
5. **(Optional) BIND_ACCESSIBILITY_SERVICE** — Settings > Accessibility > Installed services > [App]. The single highest-friction permission on Android. ~30–40% drop-off alone.

**Total: 4 mandatory grants for v1, 5 if Accessibility added.** iOS equivalent for Screen Time is *one* FamilyControls prompt. Android is roughly 4x the onboarding friction.

Mitigation: build the onboarding as a stepped checklist with green checkmarks per granted permission. Make the value proposition clear at each step. Ship a "Why we need this" link per permission. StayFree, ActionDash, ScreenZen all converged on this pattern.

## "Every 5 minutes" feasibility

| Mechanism | Min interval | Reliable? | Verdict |
|-----------|-------------|-----------|---------|
| WorkManager | 15 min | Deferred in Doze | NO |
| AlarmManager.setExactAndAllowWhileIdle | 9 min throttle | Limited | NO |
| AlarmManager.setAlarmClock | 1s+ | Yes but UI-visible | NO (weird UX) |
| **Foreground Service polling** | **1s+** | **Yes** | **YES — this is the path** |

The **only viable architecture** is a continuously-running foreground service polling UsageStatsManager every 1–2 seconds, with a millisecond timer for the 5-minute boundary. This is what every shipping app blocker does.

## Google Play policy risk assessment

### LOW risk
- `PACKAGE_USAGE_STATS` — well-accepted for digital wellness.
- `SYSTEM_ALERT_WINDOW` — accepted with disclosed use; flagged only for ad-injecting apps.
- `POST_NOTIFICATIONS`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` — unremarkable.

### MEDIUM risk
- `FOREGROUND_SERVICE_SPECIAL_USE` — Play Console review required. The justification text in the manifest `<property>` and in the App Content > Foreground Services declaration **must clearly explain** the digital wellness use case. Approval is typical for honest descriptions; rejection happens for vague "system optimization" language.

### HIGH risk (avoidable)
- `BIND_ACCESSIBILITY_SERVICE` for app blocking is explicitly listed by Play as a non-eligible use of accessibility APIs. Not banned outright but requires Permission Declaration Form, in-app disclosure, and case-by-case Play approval. Recommendation: **skip for v1.**

### Restricted Settings (Android 13+)
- Affects sideloaded APKs only — Play-installed His Words is exempt.
- Worth noting in case you ship beta builds via APK direct download.

## Engineering complexity vs iOS

| Concern | iOS | Android |
|---------|-----|---------|
| Detecting target app foreground | DeviceActivityMonitor schedule + threshold | UsageStatsManager + 1s polling loop |
| Drawing interruption | ManagedSettings ShieldConfiguration (system-rendered) | Build your own overlay UI in WindowManager |
| Background reliability | System-managed; fire-and-forget | FGS + battery whitelist + OEM-specific docs |
| Permission grants required | 1 (FamilyControls) | 4–5 |
| Customization of overlay | Limited (Apple's UI primitives) | Full — any view hierarchy |
| App Store review risk | Family Controls entitlement gate | FGS specialUse Play review |
| Across-app coverage | All apps (Apple's API) | All apps (your polling) |
| Latency | Push (variable, system-batched) | Poll (1–2s with UsageStats; <100ms with AccessibilityService) |

Net: **Android is more engineering work but more flexible.** iOS is less work but less customizable. His Words can ship richer overlays on Android (typography, animations, audio), worse UX during onboarding.

## Recommended v1 scope

1. Single foreground service, `specialUse`, with honest manifest justification.
2. UsageStatsManager polling at 1.5s; trigger overlay when (a) target app in foreground AND (b) 5+ minutes since last interrupt.
3. SYSTEM_ALERT_WINDOW overlay rendered as a modal-feeling Compose view with the verse, two buttons ("Continue", "Take 30s"), gentle fade animation.
4. Onboarding as 4-step checklist: Notifications → Usage Access → Display Over → Battery Optimization. Each step explains why and links to the right Settings page.
5. Per-OEM battery whitelist guidance for top 5 OEMs (Samsung, Xiaomi, OPPO, Vivo, Realme + dontkillmyapp.com link).
6. **Skip AccessibilityService.** Add as v2 if needed for content-level filtering or sub-100ms reaction.

## Real apps using this pattern (verified)

- **StayFree** (Sensor Tower / play.google.com/store/apps/details?id=com.burockgames.timeclocker) — UsageStats + Accessibility + Overlay. ~10M+ installs.
- **ScreenZen** — Accessibility-based, ~500K installs.
- **AppBlock — Stay Focused** (com.crossroad.android.appblock) — Accessibility, ~10M installs.
- **OffScreen** (com.offscreen) — Accessibility + Overlay.
- **Forest: Stay focused** — UsageStats only (no accessibility), ~10M+ installs. **The most policy-clean reference.**
- **Mindful** (open source on GitHub: github.com/Mindful-Android-App) — Accessibility-based, useful as a code reference.
- **BlockSite** — Accessibility, content-level web filtering.

Forest is the closest analogue for "policy-conservative wellness app" — His Words can credibly cite "Forest's architecture, with a Scripture overlay instead of a tree" in any policy discussion with reviewers.

## Failure modes to plan for

1. **OEM kills the FGS.** Mitigation: battery whitelist onboarding, dontkillmyapp.com guidance, in-app health check ("Last seen alive: 2 min ago").
2. **User toggles Usage Access OFF.** Mitigation: re-check on app foreground, gentle re-prompt.
3. **Play Console rejects specialUse.** Mitigation: have honest, detailed justification ready; reference Forest as comparable approved app.
4. **User uninstalls because persistent notification feels intrusive.** Mitigation: copy in notification ("His Words is watching for moments to bless you"), low-importance channel, dismiss-friendly UX, allow temporarily-disable from notification.
5. **Sub-100ms reaction needed (e.g., to block specific Reels).** Mitigation: ship v2 with optional AccessibilityService, with full disclosure.

## Final verdict

His Words on Android is **shippable, technically straightforward, and policy-survivable** — but **3–4× the engineering and onboarding effort of iOS**. Plan accordingly:

- iOS-first launch makes sense if engineering is constrained — fewer permission grants, system-rendered shield UI, App Store gate is one-time.
- Android-second with the architecture above; budget 4–6 weeks for permission UX polishing and per-OEM testing.
- Reserve AccessibilityService for v2 only if a real product need emerges (content filtering, instant block).
