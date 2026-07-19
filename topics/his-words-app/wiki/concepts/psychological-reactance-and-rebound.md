---
title: Psychological reactance and rebound
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, psychology, ux, autonomy]
sources:
  - raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge.md
  - raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024.md
  - raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas.md
---

# Psychological reactance and rebound

**Reactance** (Brehm 1966) is the motivational state that arises when a perceived freedom is threatened. The user's response is to reassert the threatened freedom — by circumventing, dismissing, uninstalling, or doubling down on the prohibited behavior. Reactance is the single most-cited reason digital self-control tools fail, per [[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|Lukoff 2022]].

For His Words, reactance is the failure mode to design against. A Christian-themed wrapper does not exempt the app from this dynamic; if anything, religious framing intensifies reactance for users who feel coerced toward a spiritual posture they did not choose in this moment.

## What the research says

[[../raw/papers/2026-06-23-psych-locknType-vs-lukoff-blocking-vs-nudge|Three convergent CHI papers]]:

- **Kim 2019 (LocknType)**: longer typing-task lockouts reduce app launches 30-50% short-term but autonomy plummets and uninstalls follow.
- **Lukoff 2022 (Designing for Autonomy)**: reactance correlates r = 0.4-0.6 with abandonment intent. Autonomy-supportive prompts (offering an out, framing as the user's own goal, non-judgmental copy) sustain engagement; controlling prompts trigger reactance.
- **Lyngs 2019 (DSCT review of 367 tools)**: block-access tools have **highest install counts but highest 30-day uninstall rates**. Self-tracking and gentle nudges install slower but retain at 90 days.

[[../raw/papers/2026-06-23-psych-haliburton-design-frictions-chi2024|Haliburton 2024]] adds a moderator: when users describe the friction as **"an ally"** they sustain; when they describe it as **"a barrier"** they circumvent. The framing — copy, iconography, naming — is half the work.

[[../raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas|One Sec PNAS]] sustained ~57% abandonment over 6+ weeks specifically because the prompt is dismissable. The user is given the choice; they often choose the prompted alternative; when they don't, no autonomy is destroyed.

## Reactance triggers in faith-app context

Specific design choices that *will* trigger reactance:

- **Hard blocking (no dismiss)** — proven failure mode at scale.
- **Escalating friction** (longer pauses if you dismiss repeatedly) — this is the strongest reactance trigger Lukoff identified.
- **Guilt-laden copy** ("you've wasted X minutes today") — self-judgment language activates defensiveness.
- **Mood/spiritual labeling** ("you seem distracted today") — diagnoses the user, who experiences it as judgment.
- **Bible Focus's coin economy** ([[../raw/articles/2026-06-23-competitors-bible-focus-rewired|profile]]) — frames worship as transactional duty, theologically and psychologically reactance-prone.
- **Streak-loss notifications** — see [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]] for the cliff effect.

Reactance suppressors that *do* work:

- **Always allow dismissal.** Non-negotiable. The mandatory-reflection window ([[wiki/concepts/mandatory-reflection-window|here]]) holds for ~6s; after that, the user can leave.
- **Autonomy-supportive copy.** "Take a moment with this verse" beats "Stop scrolling."
- **Tie the prompt to the user's own stated goal**, established at onboarding.
- **Mid-session over pre-launch hard blocks** — the same Lukoff finding.
- **Personalization** — let users pick which apps trigger interrupts, which topics rotate, which translation. Each choice converts the app from imposed-on-me to chosen-by-me.

## The autonomy paradox of religious content

A unique design tension: Scripture is, for the believing user, *meant* to be authoritative. They want to be re-aligned to it. But "I want to be re-aligned to Scripture" is the user's autonomous choice; the app's job is to *serve* that choice, not impose it. The moment the app's tone becomes "you should engage with this verse," it inverts the relationship and triggers reactance even in users who hold the same theological commitment.

The right voice is **brother-in-the-faith reminder**, not **pastor-with-pulpit-authority**. "Here is a verse for this moment. May it bless you." not "Reflect on this passage now."

## Rebound risk

A rare but documented dynamic: blocking-style interventions can produce a *rebound effect* — the user, frustrated, abandons not just the intervention but the goal it served. Users who tried One Sec, hated being interrupted, and then *increased* their TikTok use post-uninstall as a kind of catch-up reaction. The size of this effect is debated, but it is real for a subpopulation.

For a faith app, rebound is theologically costly: a user who quits His Words in frustration may also retreat from the spiritual practice the app was meant to support. The damage extends beyond a churned user.

This is why **the dismissable, mid-session, autonomy-supportive design is not just a UX choice** — it is the only design that makes the app safe for the population it is trying to serve.

## Cross-references

- [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]] — where the autonomy line is drawn in time.
- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — the cadence that must respect autonomy.
- [[wiki/topics/contrarian-objections-and-responses|contrarian objections]] — where this concept addresses the One Sec retention objection.
