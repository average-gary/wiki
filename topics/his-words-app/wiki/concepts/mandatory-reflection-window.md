---
title: Mandatory reflection window — how long the pause should last
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, ux, design-tension, friction]
sources:
  - raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md
  - raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md
  - raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge.md
  - raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement.md
---

# Mandatory reflection window

The pause-duration choice is the sharpest design tension in His Words. Too short and the prompt fails to engage System-2 deliberation; too long and the friction becomes coercive and triggers reactance. The empirical sweet spot is narrow.

## What the research says

| Source | Pause duration tested | Outcome |
|---|---|---|
| [[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas\|One Sec PNAS 2023]] | ~6 seconds | ~57% abandonment, sustained over 6+ weeks |
| LocknType (Kim et al. 2019, in [[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge\|blocking-vs-nudge]]) | Long typing task | 30-50% reduction short-term, but autonomy cost; uninstalls |
| [[../raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement\|Twitter "Read it First?"]] | ~0.5s, dismissable | 33% read-through rate at scale, near-zero friction cost |
| [[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge\|Lukoff 2022]] | Mid-session prompts, dismissable | Outperform pre-launch hard blocks for long-term adherence |

Two independent thresholds emerge:

- **Lower bound ~6 seconds**: below this, the pause is too brief to recruit System-2 reflection. The user proceeds on autopilot.
- **Upper bound ~30-60 seconds**: above this, autonomy cost rises sharply (LocknType data) and reactance dominates.

## The His Words design

Two-stage pause:

1. **~6-second mandatory pause** (no skip button visible). The verse is rendered. A countdown progresses silently. This is the One Sec sweet spot.
2. **Optional 60-second deeper engagement** with action buttons: Read full chapter, Save verse, Continue to app. The user *chooses* to extend.

Stage 1 is non-dismissable because dismissable-from-zero collapses to a 0-second pause for habituated users — and the empirical floor for System-2 engagement is ~6s. Stage 2 is the autonomy-supporting layer per [[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|Lukoff 2022]]: the user retains agency over how long to stay.

## Why mandatory at all

The contrarian critique ([[../raw/articles/2026-06-23-contrarian-intervention-novelty-isnt-proven|intervention novelty]]) argues users will dismiss interrupts on autopilot, training avoidance. This risk is real — and is precisely why the *first ~6 seconds* are non-dismissable. Below that floor, no engagement happens; above that floor, dismissal returns autonomy.

But mandatory must mean *short and consistent*. **Never escalate friction.** Per Lukoff, escalation (longer pause if user dismisses repeatedly) is the strongest predictor of intervention abandonment. Hold the floor at 6s; let the user decide whether to stay longer.

## Why not 60 seconds mandatory?

The original His Words brief proposed a 60-second mandatory window. This is rejected on two grounds:

1. **No published research supports 60s as more effective than 6s** for behavior change in app-pause contexts. The PNAS and CHI evidence both center on the ~6s mark.
2. **Reactance scaling**: LocknType found longer typing tasks reduce app launches more *short term* but trigger uninstalls. A 60-second forced read is closer to LocknType's long-friction condition than to One Sec's. Sustainable behavior change requires the autonomy-supportive frame, which is incompatible with 60s of forced reading.

The 60-second number remains, but as the **optional stage 2** offered to the user as a deeper engagement opportunity — not as a forced wall.

## What goes inside the 6 seconds

The visible state during the pause must do real work. From the One Sec evidence:

- A salient visual (their breathing animation; for His Words, the verse rendered in beautiful typography against a calm gradient).
- The user's own usage data on the prompt ("you've been in Instagram for 7 minutes today" — a re-anchor to the user's stated goal).
- A consistent visual treatment so the cue→reflection link calcifies (per [[wiki/concepts/implementation-intentions|implementation intentions]]).

What does NOT go inside: long-form reading, quizzes, AI chat, or any branching decision. The pause is one verse, one reference, one ambient image.

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — when the pause fires.
- [[wiki/concepts/psychological-reactance-and-rebound|reactance and rebound]] — why dismissable matters.
- [[wiki/decisions/2026-06-24-duration-streaks-not-day-streaks|decisions/duration-streaks]] — pairs with the grace-aligned posture.
