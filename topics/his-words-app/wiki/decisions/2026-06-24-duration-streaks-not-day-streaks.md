---
title: "Decision: duration streaks, not consecutive-day streaks"
type: decision
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, decision, metrics, gamification, theology]
sources:
  - raw/papers/2026-06-23-psych-streaks-gamification-duolingo-snapchat.md
  - raw/articles/2026-06-23-competitors-prayer-lock.md
  - raw/articles/2026-06-23-competitors-bible-focus-rewired.md
---

# Decision: duration streaks, not consecutive-day streaks

**Decision**: The headline metric is **lifetime minutes redeemed** (cumulative, monotonic, never resets). Secondary metric is **rolling-7-day attended-interrupt count**. Optional consecutive-day streak is **off by default** and includes silent auto-grace freezes (Sundays + first miss elsewhere).

This rejects the dominant Christian-app gamification pattern in favor of the empirical-and-theological case for a grace-aligned accumulator.

## Context

Per [[../raw/papers/2026-06-23-psych-streaks-gamification-duolingo-snapchat|streaks paper]]:

- Streaks improve 14-day retention by ~+19-40% (Duolingo public data).
- Streak-quitter cliff: users who break a 30+ day streak without a freeze available **disproportionately abandon within 7 days**.
- Snapchat snapstreaks documented as anxiogenic.
- Duolingo's "Streak Freeze" feature reduced post-break churn by an estimated 50%+.

Competitor patterns:

- [[../raw/articles/2026-06-23-competitors-prayer-lock|Prayer Lock]] ships sheep-faith-growth gamification + prayer streak tracking.
- [[../raw/articles/2026-06-23-competitors-bible-focus-rewired|Bible Focus]] ships an explicit coin economy where prayer mints unlock-time.

Both lean into the count-streak / earn-currency pattern that produces the cliff effect *and* invokes a theologically problematic "worship as transaction" framing.

## Rationale

### 1. Empirical: count streaks have a cliff

The streak-quitter asymmetry is well-documented: gain feels modestly motivating, loss feels disproportionately demotivating (loss aversion + sunk-cost-fallacy interaction). For a population already inclined toward shame and self-judgment in spiritual contexts, this is doubly costly. A user who breaks a 60-day Bible-engagement streak does not just lose engagement; they often retreat from the spiritual practice itself.

Duration streaks (cumulative, monotonic) have no cliff. Missing a day does not subtract; tomorrow's session adds.

### 2. Theological: grace, not law

A consecutive-day streak is law-shaped: it tracks compliance against an external standard, and breaking it incurs a cost. A duration accumulator is grace-shaped: it tracks the gift the user has received (time given back) and never punishes.

Romans 6:14 — "you are not under law but under grace." The metric layer should reflect the gospel framing the app's content layer claims. A streak that punishes the user for a missed day says one thing in copy and another in measurement.

### 3. Avoiding the Snapchat trap

Snapchat snapstreaks created compulsive maintenance behavior — empty content sent solely to preserve streaks. The mechanism turns the practice into obligation rather than communion. A scripture-pause app that produces this dynamic has become exactly what it was meant to remedy.

### 4. Avoiding the Bible Focus trap

The coin-economy pattern ([[../raw/articles/2026-06-23-competitors-bible-focus-rewired|Bible Focus]]) turns Scripture engagement into the *price* paid for Instagram time. This inverts the relationship — worship becomes transaction. Even if effective at behavior change, it corrupts the underlying spiritual posture.

His Words' redeemed-minutes accumulator does the opposite: it counts what God has given back (time recovered for reflection), not what the user has earned. Same numerical mechanic, opposite theological frame.

## Implementation

### Lead metric

**Lifetime minutes redeemed** — the headline number on the home screen. Format: "247 minutes redeemed" with a graceful animation when it grows.

Counts: every interrupt the user attends to (≥6s engaged, the [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]] floor). Dismissal-without-engagement does not subtract; it just doesn't add.

### Secondary metric

**Rolling-7-day attended-interrupt count.** Smooths weekly noise; shows recent engagement trend. Never resets; gracefully degrades as activity drops.

### Optional consecutive-day streak

Off by default. User can enable in settings. Mechanics:

- Auto-grace freeze on Sundays (Sabbath framing — theologically appropriate, behaviorally protective).
- Auto-grace freeze on first miss in any rolling 7-day window.
- Never display "streak lost" notification with negative valence. Frame breaks as transitions: "Welcome back — your minutes are still here."
- Streak count does not appear on home screen; it lives on a sub-page for users who want it.

### What is forbidden

- Cross-user leaderboards.
- Friend-streaks (Snapchat pattern).
- Coin economy of any kind.
- "X days remaining to keep your streak" notifications.
- Push notifications when a streak is "at risk."
- Public sharing of individual streak length.

## Risk: low gamification = lower engagement?

Possible. Streaks do drive 19-40% retention boost per Duolingo. By foregoing the count-streak as primary, His Words may sacrifice some of that boost.

Mitigations:

- The duration-streak alone has its own positive-reinforcement curve (number-goes-up satisfaction).
- The [[wiki/concepts/family-covenant-mode|family-covenant aggregate]] in v2 provides social-positive reinforcement at the household level without individual cliff risk.
- Optional consecutive-day streak is available for users who want it.

If Day-30 retention falls below 30% post-launch, gamification can be added — but as an *enhancement* layer over the duration-meter, not a replacement.

## Cross-references

- [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]] — long-form rationale.
- [[wiki/concepts/family-covenant-mode|family-covenant mode]] — group aggregate.
- [[wiki/concepts/psychological-reactance-and-rebound|reactance]] — why escalating-pressure mechanics fail.
- [[wiki/topics/mvp-feature-set|MVP]] — what ships in v1.
