---
title: Redeemed-time accounting — duration streaks over count streaks
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, metrics, gamification, theology]
sources:
  - raw/papers/2026-06-23-psych-streaks-gamification-duolingo-snapchat.md
  - raw/articles/2026-06-23-competitors-prayer-lock.md
  - raw/articles/2026-06-23-competitors-bible-focus-rewired.md
---

# Redeemed-time accounting

His Words' headline metric is **minutes redeemed** — cumulative time interrupted-and-reflected, accumulated across the user's lifetime in the app. It is monotonic; it cannot decrease. Every interrupt the user attends to adds to the total. Every interrupt the user dismisses without engaging does not subtract.

This stands against the dominant gamification pattern in faith-blocker apps — **consecutive-day count streaks** — which research suggests are *theologically and behaviorally* hostile to the user the app is trying to serve.

## What count streaks actually do

Per the [[../raw/papers/2026-06-23-psych-streaks-gamification-duolingo-snapchat|streaks paper]]:

- Streaks improve 14-day retention by ~+19-40% (Duolingo public data).
- But streak break = disproportionate abandonment risk. Users who break a 30+ day streak (without a Streak Freeze available) **disproportionately abandon the app entirely within 7 days**.
- Snapchat snapstreaks documented as anxiogenic; users send empty content to preserve streaks.
- Williams (and adjacent HCI gamification reviews) document the "streak-quitter" asymmetry: gain feels modestly motivating, loss feels disproportionately demotivating (loss aversion + sunk cost).

Prayer Lock ships sheep-faith-growth gamification ([[../raw/articles/2026-06-23-competitors-prayer-lock|prayer-lock profile]]) and Bible Focus ships an explicit coin economy ([[../raw/articles/2026-06-23-competitors-bible-focus-rewired|bible-focus profile]]). Both are theologically loaded — they invert worship into transaction or obligation.

## Why a duration meter solves the problem

A duration meter — "247 minutes redeemed from social media this week" — has different mathematical properties:

- **Monotonic**: the number can only grow. There is no cliff.
- **Grace-aligned**: a missed day does not punish the user. The total is unchanged; tomorrow's session adds to it.
- **Theologically clean**: the metric counts the *gift* (time given back), not the *adherence* (compliance with a rule). Cf. Romans 6:14 — "you are not under law but under grace." A streak is law-shaped; a redeemed-time accumulator is grace-shaped.
- **Honest about progress**: a user who attends 2 interrupts on Mon and 5 interrupts on Fri has 7 minutes redeemed regardless of the day-pattern. This matches what actually happened.

## The Duolingo lesson, applied

Duolingo's empirical answer is *neither pure count-streak nor pure duration*. It is a **hybrid with grace**: a count streak with **Streak Freeze** that auto-applies on missed days, plus a cumulative XP meter. Streak Freeze reduced post-break churn by an estimated 50%+ (Duolingo internal).

His Words can replicate this:

- **Lead metric: minutes redeemed** (cumulative, headline number on home screen).
- **Secondary metric: rolling-7-day attended-interrupt count** (a rolling window, not a streak — never resets, gracefully degrades when user drops).
- **Optional consecutive-day streak**, *off* by default, that auto-freezes on Sundays (Sabbath) without user action and gracefully on first miss elsewhere.
- **Never display "streak lost" notifications.** Frame breaks as transitions ("welcome back — your minutes are still here").

## Concrete numerical defaults

Behavior-shaping research suggests "rolling-7-day" is the right window: long enough to smooth weekly noise, short enough to feel responsive to current behavior. The **lifetime** redeemed-minute total is the dignified accumulator that says "look at all the time God has given back."

## What about social comparison?

Avoid Snapchat-style snapstreaks. Avoid leaderboards across users. The [[wiki/concepts/family-covenant-mode|family covenant mode]] reframes social presence at a different unit (the family aggregate) — that is the safe place for shared-progress display. Individual cross-user comparison invites pride or shame, both of which corrode the spiritual posture His Words is supposed to cultivate.

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — the act being measured.
- [[wiki/concepts/family-covenant-mode|family-covenant mode]] — group-aggregate redeemed minutes.
- [[wiki/decisions/2026-06-24-duration-streaks-not-day-streaks|decision: duration streaks, not day streaks]].
