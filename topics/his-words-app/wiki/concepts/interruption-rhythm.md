---
title: Interruption Rhythm — the core His Words mechanic
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, mechanic, core-concept, differentiation]
sources:
  - raw/articles/2026-06-23-competitors-psalmo.md
  - raw/articles/2026-06-23-competitors-prayer-lock.md
  - raw/articles/2026-06-23-competitors-bible-mode.md
  - raw/articles/2026-06-23-competitors-biblescroll.md
  - raw/articles/2026-06-23-competitors-bible-focus-rewired.md
  - raw/articles/2026-06-23-competitors-faithlock-variants.md
  - raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md
  - raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md
---

# Interruption rhythm

The core His Words mechanic is **time-based interruption during ongoing use**, not a one-time gate at app open. Every N minutes that the user is inside Instagram / TikTok / X / YouTube, a Scripture screen interrupts the session. The cue is *duration of use*, not *moment of launch*.

This makes His Words categorically different from every Christian app blocker shipping today. See [[wiki/concepts/verse-gate-pattern|verse-gate pattern]] for the dominant pattern in the market.

## What competitors actually do

Every reviewed competitor uses an **open-app gate** — friction at launch only:

- [[../raw/articles/2026-06-23-competitors-psalmo|Psalmo]]: verse overlay on app launch, "**unlocks for the remainder of the day, resetting at midnight**." A single 5-second tap at 9am buys unlimited Instagram for 15 hours.
- [[../raw/articles/2026-06-23-competitors-prayer-lock|Prayer Lock]]: pray-to-unlock with mood input — repeatable per session but only on launch transition.
- [[../raw/articles/2026-06-23-competitors-bible-mode|Bible Mode]]: scripture-blocker on launch + scheduled "Quiet Time Mode" windows. Strict Mode (2026-06) prevents rushing the devotional but is still session-bookended, not session-recurring.
- [[../raw/articles/2026-06-23-competitors-biblescroll|BibleScroll]]: daily reset — apps unlock once after a YouVersion read.
- [[../raw/articles/2026-06-23-competitors-bible-focus-rewired|Bible Focus]]: coin-economy — pray/study mints minutes of unlocked screen time. Once spent, unlocked.
- [[../raw/articles/2026-06-23-competitors-faithlock-variants|FaithLock variants]]: explicit synthesis quote — *"None offer recurring N-minute interrupts. Every app reviewed uses daily reset or per-session prayer gates."*

The verse-gate model assumes the **launch itself** is the disordered behavior. His Words assumes the **prolonged session** is the disordered behavior — which matches how doomscrolling actually works.

## Why time-based interruption is more honest about doomscrolling

A heavy social-media user opens the app once and stays for 45-90 minutes. The verse-gate fires once; the doomscroll runs uninterrupted. Time-based interruption fires at minute 5, 10, 15, 20 — each fire is an opportunity for the user to choose. This is the design implication of taking duration-of-use seriously.

## Empirical scaffolding

Two peer-reviewed sources validate the mid-session pause-prompt mechanic:

- **One Sec PNAS 2023** ([[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md|one-sec-self-nudge-pnas]]): a 6-second pause-then-deep-breath at app launch produced **~57% abandonment-at-prompt** and 37-50% reduction in time-on-app. Effect *persisted* past 6 weeks. The mechanism is not friction-cost — it is re-activation of System-2 deliberation against System-1 automaticity.
- **Haliburton CHI 2024** ([[../raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md|haliburton-chi2024]]): longitudinal field study confirms efficacy holds at 6-8 weeks; framing the friction as *ally* (not barrier) is the strongest moderator of long-term adherence. **Mid-session prompts** were shown to outperform pre-launch hard blocks for adherence.

His Words extends this work in one direction the existing literature has not tested in the wild: **mid-session, recurring, content-rich (Scripture)** rather than the one-shot pre-launch breathing animation One Sec ships.

## What the rhythm parameter should be

Best-evidence default: **every 5 minutes** of continuous use, with user override. Justification:

1. Below ~3 min the prompt feels punitive — see [[wiki/concepts/psychological-reactance-and-rebound|reactance]].
2. Above ~10 min the prompt fires too rarely to interrupt a doomscroll-shaped session that has already locked in.
3. 5 min matches the round-number anchoring users will accept ("5-minute rhythm") and aligns with the iOS BGTaskScheduler floor (15-30 min in background, real-time only when app is foregrounded — see [[wiki/concepts/ios-shield-mechanism|ios-shield-mechanism]]).

Per [[../raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement|the Skinner-schedule literature]], **vary the content, not the timing**. Fixed 5-min rhythm with rotating verses beats variable-interval timing with the same verse.

## Implications for the rest of the design

- The mechanic is duration-aware, so the app must run a continuous polling loop on Android ([[wiki/concepts/android-foreground-service-poll-architecture|FGS architecture]]) and a layered DeviceActivity + BGTaskScheduler stack on iOS ([[wiki/concepts/ios-shield-mechanism|ios-shield-mechanism]]).
- The headline metric is [[wiki/concepts/redeemed-time-accounting|redeemed minutes]], not "verses unlocked" — because every interrupt is a unit of time exchanged, not a single gate cleared.
- The interruption must remain dismissable to avoid [[wiki/concepts/psychological-reactance-and-rebound|reactance rebound]]; see also [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]] for the duration-of-pause design tension.
