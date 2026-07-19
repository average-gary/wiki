---
title: Implementation intentions — Gollwitzer's if-then plans applied to His Words
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, psychology, habit-formation, onboarding]
sources:
  - raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer.md
  - raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md
---

# Implementation intentions

An *implementation intention* is a pre-committed if-then plan: **"If situation X occurs, then I will perform behavior Y."** Per [[../raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer|Gollwitzer 1999 + Gollwitzer & Sheeran 2006 meta-analysis]], implementation intentions produce a **d = 0.65 (medium-to-large) effect** on goal attainment — across 94 studies, ~8,000 participants, populations ranging from clinical to recreational, behaviors ranging from exercise to addiction recovery. This is one of the most robust findings in social psychology.

For His Words, the entire app architecture is — or should be — an implementation-intention machine.

## The architecture as if-then

Default user-installed configuration:

> **IF I'm in Instagram for 5 minutes, THEN a Scripture pause appears.**

The user pre-commits to this rule at onboarding. The OS APIs (DeviceActivity on iOS, UsageStatsManager + foreground service on Android — see [[wiki/concepts/ios-shield-mechanism|ios-shield-mechanism]] and [[wiki/concepts/android-foreground-service-poll-architecture|android FGS architecture]]) automate the trigger. The user does not need to remember to pause; the cue fires.

This is precisely the structure Gollwitzer's research validates: the user *delegates control of behavior* from conscious goal pursuit to **automatic environmental cue → response linkage**. The cue is "I have been in Instagram for 5 minutes." The response is "the verse appears." The user pre-committed to honor it.

## What makes implementation intentions actually work

Per the [[../raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer|raw source]] and Sheeran et al. 2005:

1. **The cue must actually fire.** If the user has to remember the cue, it's a goal intention, not an implementation intention. His Words automates the cue — this is the whole point.
2. **Goal commitment must be high.** Gollwitzer's "Interplay" paper: implementation intentions are *most effective when goal commitment is already high*. Users who don't care about reducing scroll-time or engaging Scripture do not benefit much.
3. **The if-then must be specific.** "I will read Scripture more" is goal-only. "If I'm in Instagram for 5 minutes, then I will read this verse" is an implementation intention.
4. **Repetition builds automaticity.** Per Wendy Wood's lab: ~43% of daily behavior is habitual; consistent context-cue → behavior pairing repeated until automaticity emerges (Lally et al. 2010 median ~66 days, very high variance).

## Habit substitution — easier than extinction

Wood's lab finding: **substitution is easier than extinction.** It is easier to replace a habit's *response* while keeping the *cue*, than to eliminate the cue-response chain entirely.

Existing habit:
- Cue: boredom, phone in hand
- Response: open Instagram → scroll → dopamine
- Outcome: time lost, mood unchanged or worse

His Words intervenes at the response stage:
- Cue: same (boredom + phone in hand → Instagram)
- Response: scroll for 5 min, then verse pause + reflection
- Outcome: partial substitution — the dopamine response is partly displaced by reflective response

The user does not need to extinguish the urge to open Instagram (extremely hard). They need to install a new partial response *during* the existing habit (much easier).

## Onboarding as implementation-intention ceremony

This has direct UX consequences. Onboarding is not feature-tutorial — it is **the explicit if-then commitment ritual**:

1. User picks 1-3 apps to monitor (specificity).
2. User picks the rhythm (5 min default, user-configurable to 3-15 min).
3. User picks topical area (anxiety, hope, marriage — see [[wiki/concepts/topical-verse-categorization|topical-verse-categorization]]).
4. User reads and confirms a stated commitment: **"When I am in [Instagram] for [5 minutes], I want to pause for Scripture on [hope]."**
5. The app fires the cue automatically thereafter.

Step 4 is non-trivial. Per Sheeran/Webb/Gollwitzer 2005: the *act of writing or affirming the implementation intention* is part of what produces the d = 0.65 effect. It is not optional UX — it is the intervention.

## What about commitment-level filtering?

Implementation intentions only work for high-commitment users. Gollwitzer's data is unambiguous: low-commitment users get smaller benefit.

His Words should *self-select* commitment by:
- Requiring the explicit if-then affirmation at onboarding (low-commitment users will bail).
- Avoiding aggressive marketing ("be a better Christian") that pulls in users who do not actually want to change.
- Asking — but never demanding — the user's reason for installing the app.

Some level of self-selection is healthy. The product should bless the people who actually want to be there.

## Pairing with [[wiki/concepts/family-covenant-mode|family covenant mode]]

The Haliburton finding ([[../raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024|here]]) — that framing the friction as "an ally" sustains adherence — pairs with the implementation-intention literature: a user-affirmed if-then is the maximally ally-framed friction. The user designed the rule; the app honors it.

A family covenant extends the if-then commitment to a group: **"When any of us has been in Instagram for 5 minutes, we pause for Scripture, and our family's redeemed-minute total grows."** This is implementation intention at communal scale, addressed in [[wiki/concepts/family-covenant-mode|family-covenant mode]].

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — the cue.
- [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]] — the outcome counter.
- [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]] — what happens when the if-then fires.
