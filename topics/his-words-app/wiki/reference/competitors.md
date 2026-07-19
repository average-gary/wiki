---
title: Competitor reference — comparative table
type: reference
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, competitors, reference]
sources:
  - raw/articles/2026-06-23-competitors-psalmo.md
  - raw/articles/2026-06-23-competitors-prayer-lock.md
  - raw/articles/2026-06-23-competitors-bible-mode.md
  - raw/articles/2026-06-23-competitors-biblescroll.md
  - raw/articles/2026-06-23-competitors-bible-focus-rewired.md
  - raw/articles/2026-06-23-competitors-faithlock-variants.md
  - raw/articles/2026-06-23-competitors-hallow-and-adjacents.md
---

# Competitors — comparative table

All seven faith-blocker competitor profiles in one comparison view, plus adjacent-but-non-blocker apps for context.

## Faith-blocker direct competitors

| App | Mechanism | Platform | Reset | Verse source | AI content? | Ratings | Stars | Last update | Distinguishing feature |
|---|---|---|---|---|---|---|---|---|---|
| [[../raw/articles/2026-06-23-competitors-psalmo\|Psalmo]] | Verse on launch | iOS+Android | Daily (midnight) | KJV, WEB (PD) | Yes (premium AI prayers) | 2 | 5.0 | 2026-06-03 | 50+ topical categories, 31k offline verses |
| [[../raw/articles/2026-06-23-competitors-prayer-lock\|Prayer Lock]] | Pray-to-unlock with mood | iOS | Per-session | AI-generated, scripture-rooted | **Yes (core feature)** | **30,208** | **4.88** | 2026-06-16 | Sheep faith gamification, community feature, weekly cadence |
| [[../raw/articles/2026-06-23-competitors-bible-mode\|Bible Mode]] | Scripture-blocker + Strict Mode | iOS | Per-session | KJV+ESV (licensed) | Yes (Bible Chat AI) | 10,486 | 4.93 | active | ESV license = real moat; Strict Mode anti-skip |
| [[../raw/articles/2026-06-23-competitors-biblescroll\|BibleScroll]] | Daily YouVersion read gate | iOS | Daily | YouVersion handoff (3,500 versions) | No | 952 | 4.80 | 2026-06-20 | Sub-after-7-day-trial; YouVersion-defer architecture |
| [[../raw/articles/2026-06-23-competitors-bible-focus-rewired\|Bible Focus]] | Coin economy (earn-to-unlock) | iOS | Coin-spent | Editorial; PD likely | No (quizzes) | 1,034 | 4.82 | 2026-05-13 | Church check-in (geofence); scripture scanning OCR |
| [[../raw/articles/2026-06-23-competitors-faithlock-variants\|FaithLock × 6]] | Pray-to-unlock variants | iOS | Per-session | Various | Mostly yes | 0-282 each | 3.6-5.0 | 2026 | Name-collision saturation; **gold-rush** |

**Cross-cutting observation**: every faith-blocker uses a **launch-time gate**. None ship a [[wiki/concepts/interruption-rhythm|recurring N-minute interrupt during ongoing use]]. The category gap is real.

## Adjacent faith apps (not blockers)

| App | Category | Ratings | Stars | Funding | Notes |
|---|---|---|---|---|---|
| Hallow | Audio prayer/meditation | 367,794 | 4.89 | $52M raised | Catholic-leaning. **Could ship a blocker tomorrow.** |
| YouVersion (Bible.com) | Bible reader | 13.4M | — | Donor (Hobby Lobby) | ~1B installs. Could ship a blocker tomorrow. |
| Bible Chat (Book Vitals) | AI Bible companion | 343,754 | 4.92 | Unknown | AI-first, not friction-first |
| Creed (Lemon Tree Labs) | AI Bible chat companion | 30,321 | 4.88 | Unknown | Therapy-adjacent positioning |
| Dwell Audio Bible | Audio Bible | 83,215 | 4.89 | Unknown | 14 translations, professional narration |

## Secular pause-prompt apps (technical and behavioral precedents)

| App | Mechanism | Platform | Pricing | Ratings | Notes |
|---|---|---|---|---|---|
| One Sec | 6s pause-then-breath on app launch | iOS+Android | $2.99/mo freemium | High (~$50M+ ARR rumored) | **PNAS 2023 validated**: ~57% abandonment at 6 weeks |
| Opal | App limiter + scheduled blocking | iOS+Android | $4.99/mo | Large | "Wellness coach" framing |
| Jomo | Wellness + blocking | iOS | $9.99/mo | Mid | Motivational screen messaging |
| ScreenZen | Gentle app breaks | iOS+Android | Freemium | ~500K+ | Custom break UX |
| Holy Focus | Bible app + DeviceActivity blocks | iOS | Freemium | Smaller | **Direct precedent for His Words approval path** |

## What none of them combine

Going column-by-column:

- **Mid-session recurring interrupt**: only the secular pause-prompt apps approach this, and even they fire only on app launch (not at minute N of a continuous session).
- **Faith content + autonomy-supportive design + no AI**: Hallow has faith but no blocking; Holy Focus has both but no recurring rhythm; Prayer Lock / FaithLock have faith and blocking but ship AI content.
- **Scripture-only positioning**: Bible Mode is closest (KJV+ESV) but ships a Bible Chat AI as kitchen-sink expansion.
- **Recurring rhythm + scripture content + grace-aligned metric**: nobody.

His Words' positioning sits in this combinatorial gap. See [[wiki/topics/positioning-and-differentiation|positioning]].

## Quality flags worth tracking

- **Prayer Lock's update cadence**: weekly. Genuine product investment. Treat as the category leader to beat.
- **Bible Mode's ESV license**: only competitor with a paid translation license. Suggests Friday Labs has product-market-fit signal worth investigating.
- **FaithLock's name collision**: 6 distinct apps in 6 months with the same brand stem. Category in gold-rush phase; commoditization within ~6 months.
- **Hallow's silence on screen-time**: the most strategically important data point. If the category leader thought blocking was a winner, they would ship it. They have not. Watch for this to change.
- **YouVersion's reading-plan churn**: Day-30 ~8% per [[../raw/articles/2026-06-23-contrarian-youversion-already-won|the contrarian article]]. Bible engagement is hard. Don't underestimate retention difficulty.

## Cross-references

- [[wiki/topics/positioning-and-differentiation|positioning]] — synthesis use of this comparison.
- [[wiki/concepts/verse-gate-pattern|verse-gate pattern]] — what every competitor does.
- [[wiki/concepts/interruption-rhythm|interruption rhythm]] — what His Words does instead.
