---
title: Behavioral psychology citations — what each paper shows for His Words
type: reference
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, psychology, citations, reference]
sources:
  - raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md
  - raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md
  - raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge.md
  - raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer.md
  - raw/papers/2026-06-23-psych-streaks-gamification-duolingo-snapchat.md
  - raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement.md
  - raw/articles/2026-06-23-psych-haidt-newport-phone-overuse-context.md
---

# Behavioral psychology citations

Each cited source plus a one-line synthesis of what it shows for His Words. Primary sources for the psychological scaffolding of [[wiki/concepts/interruption-rhythm|interruption-rhythm]], [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]], [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]], [[wiki/concepts/implementation-intentions|implementation intentions]], and [[wiki/concepts/psychological-reactance-and-rebound|reactance]].

## Direct evidence: pause prompts work, sustainably

### Grüning, Riedel & Lorenz-Spreen (2023). PNAS, e2213114120.
[[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas|raw source]]
- ~6-second pause-then-breath at app launch.
- ~36,000 user telemetry, ~280-N controlled studies.
- **~57% abandonment at the prompt**; ~37-50% reduction in cumulative time-on-app.
- **Sustained over 6+ weeks** — minimal habituation decay.
- **What it shows for His Words**: pause-prompts work, the empirically-tested duration is ~6s, and the effect lasts. This is the closest published analog to the His Words intervention.

### Haliburton, Grüning, Riedel & Schmidt (2024). CHI '24.
[[../raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024|raw source]]
- Longitudinal in-the-wild deployment, 8+ weeks.
- **Frictions framed as "ally" sustain; framed as "barrier" get circumvented.**
- Personalization (user picks apps, framing) slows habituation.
- Mid-session prompts > pre-launch hard blocks for adherence.
- **What it shows for His Words**: language and framing matter as much as mechanism. Onboard for "ally" framing. Vary content to slow habituation.

## Reactance: hard blocks fail; autonomy-supportive sustains

### Kim, Park, Lee, Ko, Lee (2019). LocknType. CHI '19.
[[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|raw source]]
- Lockout typing-task before app open. 4-week study.
- Longer typing tasks → 30-50% reduction short-term, but autonomy cost; uninstalls.
- **What it shows for His Words**: hard friction works in the short term but extracts a long-term autonomy cost. Avoid escalation.

### Lukoff, Lyngs, Zade et al. (2022). Designing for Autonomy. CHI '22.
[[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|raw source]]
- 13 interview, 360 survey.
- **Reactance correlates r = 0.4-0.6 with abandonment intent.**
- Autonomy-supportive prompts (offering an out, framing as user's own goal) sustain.
- Mid-session > pre-launch hard blocks.
- **What it shows for His Words**: the dismissable, mid-session, autonomy-supportive design is the only design that survives reactance.

### Lyngs, Lukoff, Slovák et al. (2019). DSCT review. CHI '19.
[[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|raw source]]
- Reviewed 367 digital self-control tools.
- **Block-access tools: highest installs, highest 30-day uninstalls.**
- Self-tracking + gentle nudges: lower installs, higher 90-day retention.
- **What it shows for His Words**: there is a category-level finding here. Aggressive blockers do not sustain. The persistent products are the gentle ones.

## Implementation intentions: how habits actually shift

### Gollwitzer (1999). American Psychologist, 54(7).
### Gollwitzer & Sheeran (2006) meta-analysis.
[[../raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer|raw source]]
- 94 studies pooled, ~8,000 participants.
- **d = 0.65 (medium-to-large) effect** on goal attainment when implementation intentions are added to mere goal intentions.
- Effect holds across populations and behavior types.
- **What it shows for His Words**: the "if I'm in Instagram for 5 min, then I read a verse" structure is the most robust behavior-change scaffolding in social psychology. Onboarding must explicitly construct this if-then.

### Wood, Wendy (2019). *Good Habits, Bad Habits*.
[[../raw/papers/2026-06-23-psych-implementation-intentions-gollwitzer|raw source]]
- ~43% of daily behavior is habitual (cue-driven, automatic).
- **Substitution > extinction**: easier to replace a habit's response while keeping the cue, than to eliminate the cue-response chain.
- Lally et al. 2010 median ~66 days for habit formation, very high variance.
- **What it shows for His Words**: don't try to extinguish "open Instagram." Substitute the response *during* the existing habit (verse interrupt at minute 5). This is the easier psychological lift.

## Streaks and gamification: cliff vs. accumulator

### Duolingo Research, Hofman, Williams, Cunha-Peréz et al. (2018-2024).
[[../raw/papers/2026-06-23-psych-streaks-gamification-duolingo-snapchat|raw source]]
- Streaks improve 14-day retention by ~+19-40% (Duolingo public data).
- "Streak Quitter" cliff: users who break a 30+ day streak without a freeze available **disproportionately abandon within 7 days**.
- Snapchat snapstreaks documented as anxiogenic.
- **What it shows for His Words**: count streaks have a cliff. Use a hybrid (duration + optional consecutive-day with auto-grace freezes). Avoid social streaks entirely. See [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]].

## Single-tap reflection nudges work at scale

### Twitter (2020). "Sharing an article can spark conversation..." Engineering blog.
[[../raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement|raw source]]
- "Want to read this before retweeting?" prompt.
- 40% more articles opened after the prompt; **33% read-through rate** vs. baseline near 0%.
- **What it shows for His Words**: a single-tap, dismissable, well-framed prompt produces real behavior change at industry scale. Validates the brief-friction-is-enough thesis.

### Hiniker, Hong, Kohno & Kientz (2016). MyTime. CHI '16.
[[../raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement|raw source]]
- 23 users, 2-week deployment.
- ~21% reduction in time-on-target-apps.
- **What it shows for His Words**: gentle, self-set reminders are *acceptable* (users described them as supportive, not punitive) — small effect but feasibility-establishing.

### Skinner (1953) + Eyal (2014).
[[../raw/papers/2026-06-23-psych-take-a-break-twitter-prompts-variable-reinforcement|raw source]]
- Variable-ratio reinforcement is what makes slot machines / TikTok addictive.
- For *aversive* prompts, fixed timing with **content variation** is the better lever.
- **What it shows for His Words**: vary the *verse*, not the *interval*. Fixed 5-min rhythm with rotating verses beats variable-interval timing.

## Macro-context: the audience-level case

### Haidt (2024). *The Anxious Generation*. Penguin Press.
### Newport (2019). *Digital Minimalism*. Portfolio.
### Twenge & Haidt (2020-2024). Various peer-reviewed papers.
[[../raw/articles/2026-06-23-psych-haidt-newport-phone-overuse-context|raw source]]
- Population-level smartphone overuse problem; non-clinical.
- ~95% US teens have smartphones; 40-60% of waking hours phone-mediated.
- Substitution model is preferable to addition; minimal-intervention products fit better than feature-bloated wellness apps.
- **What it shows for His Words**: there is a real, large, audience-committed population. Position as substitution, not addition. Adult-target by default. See [[wiki/topics/contrarian-objections-and-responses|contrarian objections]] for the limits of this audience claim for teens.

## Cross-references

- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — uses One Sec + Haliburton.
- [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]] — uses One Sec + LocknType.
- [[wiki/concepts/psychological-reactance-and-rebound|reactance]] — uses Lukoff + Lyngs.
- [[wiki/concepts/implementation-intentions|implementation intentions]] — uses Gollwitzer + Wood.
- [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]] — uses Duolingo + Williams.
