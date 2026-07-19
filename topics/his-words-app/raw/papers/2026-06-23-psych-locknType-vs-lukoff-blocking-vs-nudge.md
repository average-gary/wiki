---
title: "Kim et al. (2019) LocknType (CHI) + Lukoff et al. (2022) Designing for Autonomy (CHI). Combined source: hard blocking vs. autonomy-supporting interventions."
source: https://dl.acm.org/doi/10.1145/3290605.3300927
type: paper
created: 2026-06-23
tags: [his-words-app, behavioral-psychology, reactance, blocking, autonomy, CHI]
quality: 5
confidence: high
summary: Hard lockouts reduce app opens short-term but trigger reactance and circumvention; autonomy-supporting prompts produce smaller but more durable behavior change.
authors: "Kim, Park, Lee, Ko, Lee (2019); Lukoff, Lyngs, Zade et al. (2022); Lyngs et al. (DSCT review, 2020)"
year: "2019, 2022"
venue: ACM CHI Conference on Human Factors in Computing Systems
---

# Blocking vs. Soft-Interruption: LocknType (Kim 2019) and Designing for Autonomy (Lukoff 2022)

## Citations
- Kim, J., Park, J., Lee, H., Ko, M., & Lee, U. (2019). LocknType: Lockout Task Intervention for Discouraging Smartphone App Use. In *Proc. CHI '19*. https://doi.org/10.1145/3290605.3300927
- Lukoff, K., Lyngs, U., Zade, H., et al. (2022). Designing to Support Autonomy and Reduce Psychological Reactance in Digital Self-Control Tools. In *Proc. CHI '22*. https://doi.org/10.1145/3491102.3517729
- Lyngs, U., Lukoff, K., Slovák, P., Binns, R., Slack, A., Inzlicht, M., Van Kleek, M., & Shadbolt, N. (2019). Self-Control in Cyberspace: Applying Dual Systems Theory to a Review of Digital Self-Control Tools. In *Proc. CHI '19*.

## What each paper shows

### Kim et al. (2019) — LocknType
- **Design**: When a user opens a target app (e.g., Facebook), a lockout task forces them to type a sequence (random digits, or paragraph copy) before the app opens. Compares: no intervention, simple delay (timer), short typing task, long typing task.
- **N**: 40 in main study, 4-week deployment.
- **Findings**: Longer typing tasks reduced app launches **30-50%** vs. control. *But* user satisfaction and perceived autonomy dropped sharply with longer tasks. Many participants reported frustration; some uninstalled the intervention.
- **Implication**: Hard friction works *short-term* but extracts a high autonomy cost.

### Lukoff et al. (2022) — Designing for Autonomy
- **Design**: Conceptual + qualitative + survey study of how Digital Self-Control Tools (DSCTs) trigger psychological reactance (Brehm 1966). Tested timing variants (start-of-session vs. mid-session vs. end-of-session prompts) and framing variants (controlling vs. autonomy-supportive language).
- **N**: 13 in interview study, 360 in survey.
- **Findings**:
  - **Reactance is the dominant predictor of intervention abandonment.** Tools that *force* a behavior (block, hard-timer-no-skip) produce the highest abandonment rates.
  - **Autonomy-supporting prompts** — those offering an *out*, framing the intervention as the user's own goal, and using non-judgmental language — sustain engagement.
  - **Mid-session prompts** with optional dismissal outperform start-of-session hard blocks for long-term adherence.
  - **Personalization** (user-set goals, user-chosen apps) reduces reactance significantly.

### Lyngs et al. (2019) — DSCT Review
- Reviewed 367 DSCTs across iOS/Android/web. Categorized by mechanism: (a) block-access, (b) self-tracking, (c) goal-advancement, (d) reward/punishment.
- Block-access tools have **highest install counts but highest uninstall rates** within 30 days. Self-tracking and gentle nudges have lower install counts but **higher 90-day retention**.

## Effect sizes
- LocknType: ~30-50% reduction in launches (short term, 4 weeks).
- Lukoff (qualitative + survey): no single effect size; reactance correlated r = 0.4-0.6 with abandonment intent.

## Applicability to His Words' interruption-rhythm hypothesis
**Strong evidence FOR** the soft-interruption thesis and **AGAINST** hard blocking. Specifically:
- Hard blocks → reactance → circumvention (uninstall, disable, find a workaround). His Words' "verse pause that the user can dismiss" is the recommended pattern.
- The recommended *autonomy-supporting* pattern is exactly what His Words proposes: a brief, dismissible Scripture moment that re-aligns the user with their own stated values, rather than punishing or blocking.
- Mid-session interruption (the His Words model) outperforms pre-launch hard blocks in long-term adherence per Lukoff.

## Design recommendations transferable
1. **Always allow dismissal.** A "Continue anyway" option is non-negotiable for sustained use.
2. **Use autonomy-supporting language.** "Take a moment" beats "Stop scrolling."
3. **Tie the prompt to the user's own goals**, not to a system-defined limit. The verse should feel like *their* aspiration, not the app's rebuke.
4. **Mid-session pause every N minutes** is supported as more durable than pre-launch hard blocks.
5. **Avoid escalating friction** (e.g., longer timers if user dismisses) — escalation is the strongest reactance trigger.

## Evidence rating
**Strong** — three CHI papers, converging evidence, foundational citations in the digital-wellness HCI literature. The soft-interruption thesis is well-supported.
