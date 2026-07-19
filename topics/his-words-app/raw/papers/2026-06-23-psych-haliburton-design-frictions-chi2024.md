---
title: "Haliburton, Grüning, Riedel & Schmidt (2024). A longitudinal in-the-wild investigation of design frictions to prevent smartphone overuse. CHI '24."
source: https://dl.acm.org/doi/10.1145/3613904.3642370
type: paper
created: 2026-06-23
tags: [his-words-app, behavioral-psychology, friction, longitudinal, habituation, CHI]
quality: 5
confidence: high
summary: Longitudinal field study of design frictions for smartphone use; finds frictions retain efficacy over weeks and that personalization + visible progress moderates habituation.
authors: Luke Haliburton, Dimitra J. Grüning, Frederic Riedel, Albrecht Schmidt
year: 2024
venue: ACM CHI Conference on Human Factors in Computing Systems
---

# A Longitudinal In-the-Wild Investigation of Design Frictions to Prevent Smartphone Overuse

## Citation
Haliburton, L., Grüning, D. J., Riedel, F., & Schmidt, A. (2024). A Longitudinal In-the-Wild Investigation of Design Frictions to Prevent Smartphone Overuse. In *Proceedings of the 2024 CHI Conference on Human Factors in Computing Systems* (CHI '24). ACM. https://doi.org/10.1145/3613904.3642370

## Study design
- **Type**: Longitudinal in-the-wild deployment + survey + interview.
- **Population**: Real users of the One Sec app, recruited through the app + supplementary panel.
- **Duration**: Multi-week (reported windows up to 8+ weeks).
- **Methods**: Quantitative usage telemetry (opens, abandons, session length) + qualitative interviews about subjective experience.

## Key findings
1. **Frictions work, even long-term.** The pre-launch pause continued to reduce app opens at 6-8 weeks of use. The expected "novelty wears off" decay was *attenuated* — not absent, but smaller than in prior literature on lockouts.
2. **Habituation does occur partially**, but personalization (e.g., the user choosing which apps to friction, and the framing of the pause) slows it.
3. **User mental models matter.** Participants who described the friction as "an ally" vs. "a barrier" had very different long-term outcomes. The framing-as-ally group sustained reductions; framing-as-barrier group circumvented or disabled it.
4. **Active choice + brief friction beats passive timeout.** Participants reported the active "Continue / Close" button gave them a sense of agency and reflection rather than coercion.
5. **Not all apps respond equally.** Short-form video (TikTok, Reels) and infinite-scroll feeds (Instagram, X) show the largest reductions. Utility apps (banking, maps) — irrelevant since not flagged.
6. **Identifies failure modes**: users sometimes added apps to the friction list aspirationally, then removed them when frustrated. Suggests onboarding should help users select a *small* set of high-leverage apps.

## Applicability to His Words' interruption-rhythm hypothesis
**Strong evidence** for two design choices:
- **Mid-session interruption can sustain efficacy** if framed as an ally rather than a guard. Scripture-verse framing ("a moment with God") is naturally ally-framed; "you've been on too long, stop" is barrier-framed and predicted to backfire.
- **User-selected scope matters.** Letting the user choose which apps trigger the verse pause (vs. system-imposed list) preserves autonomy and reduces reactance — see also Lukoff 2022.
- Some habituation is inevitable; counter it with **content variation** (different verses each pause), **periodic re-onboarding**, and **visible progress feedback** (e.g., "you've spent 23 fewer minutes in Instagram this week thanks to these pauses").

## Design recommendations transferable
1. **Frame the interruption as an ally, not a blocker** — naming, copy, iconography all matter.
2. **Vary the content of each interruption** to slow habituation. Different verse each time, not the same one.
3. **Show users their own progress** as part of the prompt or in a weekly digest.
4. **Onboard users to pick 2-3 apps** to friction, not 10+.

## Evidence rating
**Strong** — CHI 2024, longitudinal real-world data, same research group as the PNAS paper above, replicates and extends.
