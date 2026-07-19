---
title: His Words App
type: topic-index
created: 2026-06-23
updated: 2026-06-24
status: active
summary: A Christian digital wellness app concept — instead of blocking social media until a user reads Scripture, "His Words" gently interrupts ongoing social media use every N minutes with a 60-second Scripture pause. Topic wiki covers the competitive landscape (Psalmo, Prayer Lock, Bible Mode, BibleScroll, Bible Focus, FaithLock variants, Hallow & adjacents), iOS Screen Time / FamilyControls / DeviceActivity / ManagedSettings APIs, Android Accessibility / UsageStats / SAW / foreground-service stack, behavioral psychology of pause-prompts (One Sec PNAS 2023, Haliburton CHI 2024, Lukoff 2022, Gollwitzer 1999, Williams 2021), Christian app market sizing & monetization (Hallow, YouVersion, Pray.com, Glorify), family/accountability prior art (Covenant Eyes, Bark, A2Y, Ever Accountable, Gabb), Bible content licensing (API.Bible, ESV API, public-domain sources, NIV/NASB/CSB commercial), and contrarian objections (Crouch, Newport, Haidt).
sources_count: 42
---

# His Words App

Topic wiki investigating the design and viability of "His Words" — a faith-based digital wellness app that **interrupts** social-media usage with Scripture instead of **blocking** it.

## Core concept

The interruption-rhythm pattern (vs. the [[wiki/concepts/verse-gate-pattern|verse-gate]] pattern most existing apps use):

```
Use TikTok for 5 minutes
  ↓
His Words interrupts (overlay / shield)
  ↓
~6s mandatory + optional 60s deeper engagement
  ↓
Choose: read another / open Bible / save verse / return to TikTok
  ↓
5 minutes later, repeat
```

Positioning: **"Transform scrolling into moments with God."** Not "block social media."

## Top-level findings

1. **Competitive landscape** — Every existing competitor profiled (Psalmo, Prayer Lock, Bible Mode, BibleScroll, Bible Focus, FaithLock variants) uses *one-time-per-day* gating or *per-launch* prompts. **None re-interrupt during a long session.** This is genuinely unoccupied territory. See [[wiki/reference/competitors|competitor comparison]].
2. **iOS feasibility** — **Yes, with constraints.** DeviceActivity + ShieldActionExtension + ShieldConfiguration delivers a custom Bible-verse shield. Background interval floor is 15-30 min (Apple-imposed); foreground 5-min works. Holy Focus's existing approval is direct precedent. ~70-80% approval likelihood. See [[wiki/topics/platform-strategy|platform strategy]].
3. **Android feasibility** — **Feasible with high policy risk.** UsageStatsManager poll + SYSTEM_ALERT_WINDOW + foreground-service `specialUse` delivers the architecture. **AccessibilityService is the trap** — Google Play's Nov-2021 policy disqualifies "monitoring apps." Skip it for v1; rely on UsageStatsManager polling.
4. **Behavioral psychology — strongly supportive.** [[raw/papers/2026-06-23-psych-one-sec-self-nudge-pnas|One Sec PNAS 2023]] is the closest published analog: ~57% abandonment-at-pause, ~50% time reduction, sustained past 6 weeks. Implementation-intention literature (Gollwitzer d=0.65) provides theoretical scaffolding. **But: brief's 60-second mandatory window is too long.** Literature converges on ~6s mandatory + dismissable. See [[wiki/concepts/mandatory-reflection-window|mandatory reflection window]].
5. **Market** — **$70/yr is the de-facto Christian-premium ARPU**. Hallow ($52M raised, 2M+ users) and Glorify ($40M Series A from a16z) prove Christians will pay it. YouVersion (~1B installs) is a non-competitor (free, donor-funded). 8-figure path = 143K paying subs at $70 ARPU. See [[wiki/topics/monetization-and-pricing|monetization]].
6. **Accountability** — **Don't compete with Covenant Eyes.** Either skip family/accountability v1, or ship a *family-covenant-mode* (group redeemed-time aggregate) that's distinct from purity-monitoring. The 2022 surveillance controversy + Snapchat-streak anxiogenesis converge on the same lesson: avoid asymmetric monitoring and obligatory streaks. See [[wiki/topics/accountability-strategy|accountability strategy]].
7. **Bible licensing** — **v1 ships KJV + WEB + ESV** (public-domain via scrollmapper/wldeh; ESV via Crossway free tier 5k verses/day). API.Bible Starter has a "no freemium on free tier" trap — incompatible with subscription monetization. Defer NIV/NASB/CSB/NLT until 50k MAU. See [[wiki/topics/bible-content-licensing|Bible content licensing]].
8. **Contrarian objections — taken seriously.** Three steelmanned in [[wiki/topics/contrarian-objections-and-responses|objections-and-responses]]: (a) Crouch/Newport "phone is the problem"; (b) "YouVersion already won the friction battle — motivation is the problem"; (c) "interruption-fatigue from One Sec retention curves." The reframe that survives: family-covenant + OS-level enforcement + community Scripture, not just individual interrupt.

## Sections

- [[wiki/concepts/_index|Concepts]] — interruption rhythm, verse-gate pattern, redeemed time, mandatory reflection window, topical verses, reactance, implementation intentions, iOS shield, Android FGS poll, family covenant mode (10 articles)
- [[wiki/topics/_index|Topics]] — synthesis playbooks: positioning, MVP feature set, platform strategy, monetization, accountability strategy, Bible licensing, contrarian objections (7 articles)
- [[wiki/reference/_index|Reference]] — competitor comparison, iOS API surface, Android API surface, behavioral-psychology citations, Christian-app market snapshot, accountability landscape, Bible-translation licensing matrix (7 articles)
- [[wiki/decisions/_index|Decisions]] — iOS-first, no AI-generated content, duration-streaks not day-streaks (3 ADRs)
- [[wiki/tools/_index|Tools]] — Bible data sources, iOS frameworks, Android libraries, competitive precedents (4 articles)

## Three differentiators that no competitor combines

1. **Recurring N-minute interrupt** instead of daily-reset gates. Universally absent from Psalmo, Prayer Lock, Bible Mode, BibleScroll, Bible Focus, all FaithLock variants.
2. **Scripture-only, no AI-generated content.** Prayer Lock, Bible Mode, FaithLocked, Creed, Bible Chat all ship LLM-generated prayers. Reformed/confessional users distrust them. Credibility moat. See [[wiki/decisions/2026-06-24-no-ai-generated-content|ADR]].
3. **Family-covenant mode** — group-aggregate redeemed time, not individual streak shame. Distinct from Covenant Eyes' purity-monitoring; symmetric, monotonic, no-cliff. See [[wiki/concepts/family-covenant-mode|family covenant mode]].

## Sources

- 42 raw sources ingested 2026-06-23. See [[raw/_index|raw sources index]].
- 36 articles + 5 indexes in [[wiki/_index|wiki article layer]] (compiled 2026-06-24).
- Output artifacts in [[output/_index|output]] (forthcoming playbook).

## Related hub topics

- [[../open-source-logos-suite/_index|open-source-logos-suite]] — adjacent: OSS Bible software, public-domain biblical text licensing, multi-platform client architecture.
- [[../rust-multi-platform/_index|rust-multi-platform]] — if implementation goes cross-platform Rust route, mobile FFI / Tauri / Dioxus surface.
- [[../pf2e-biblical-reskin/_index|pf2e-biblical-reskin]] — adjacent Christian-tech project.

## Mission

Redeem screen time by replacing distraction with moments of truth. *"Your word is a lamp unto my feet, and a light unto my path." — Psalm 119:105*
