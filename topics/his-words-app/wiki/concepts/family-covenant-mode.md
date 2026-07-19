---
title: Family covenant mode — group-aggregate redeemed time
type: concept
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: medium
tags: [his-words-app, accountability, family-mode, social, theology]
sources:
  - raw/articles/2026-06-23-accountability-covenant-eyes.md
  - raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple.md
  - raw/articles/2026-06-23-accountability-bark.md
  - raw/articles/2026-06-23-accountability-built-in-apple-google-family.md
  - raw/articles/2026-06-23-accountability-kid-phones-gabb-pinwheel-relay.md
  - raw/articles/2026-06-23-contrarian-reframe-what-differentiates.md
---

# Family covenant mode

Family covenant mode is His Words' answer to the accountability question — without entering the Christian-purity-accountability category. Instead of the [[../raw/articles/2026-06-23-accountability-covenant-eyes|Covenant Eyes]] surveillance model (one party monitored, one party views screenshots), the family unit shares a **group redeemed-time aggregate** and the encouragement is upward-only: when any family member attends an interrupt, the family total grows. No one's individual non-engagement is reported.

This is a different *kind* of accountability than the existing market ships. See [[wiki/topics/accountability-strategy|accountability strategy]] for the full positioning rationale.

## The mechanic

A family (or small group, or two-person partner) opts into a shared covenant:

1. Each member's individual app continues working as it always does.
2. Each interrupt that any member attends adds to a **shared family redeemed-minute counter**.
3. The home screen shows the aggregate — "Our family has redeemed 1,247 minutes this month" — with no individual breakdown.
4. Optionally, members can post a "verse that struck me today" to a shared family feed (no obligation; user-initiated only).
5. No notifications to others when a member misses, dismisses, or removes the app.

The metric is *group accumulation*, not *individual compliance*. This is the asymmetry-collapsing design.

## Why this design

The Covenant Eyes 2022 controversy ([[../raw/articles/2026-06-23-accountability-covenant-eyes|here]]) exposed the abuse vector of asymmetric accountability: when the watcher has power over the watched (employer, elder board, parent), surveillance becomes coercion. Pastors were disciplined for searches that were not crimes. Google Play removed the apps for accessibility-API misuse.

The lesson is structural: any accountability product where one party reports on another inherits this risk. His Words' family covenant is **symmetric** — every member contributes to the same shared total. There is no view-the-other surface. The shared object is the *gift* (redeemed minutes), not the *failure* (lapses).

This also avoids the Snapchat snapstreak failure mode ([[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]]): no one is on the hook for sustaining a streak; the counter only grows.

## What family covenant mode is NOT

- **Not parental monitoring.** [[../raw/articles/2026-06-23-accountability-built-in-apple-google-family|Apple Family Sharing and Google Family Link]] already cover the parental-control surface for free. His Words should not rebuild what every parent already has. See [[wiki/topics/accountability-strategy|accountability strategy]].
- **Not screenshot-based monitoring.** No screenshots, no AI flagging. Avoids the Covenant Eyes failure mode.
- **Not a kid phone.** Gabb / Pinwheel / Bark Phone are the hardware play; family covenant mode is software-only and adult-targeted by default.
- **Not a Bark-style mental-health alerter.** No alerts to parents about user content. The user remains in privacy-grace.

## What it IS

- A way for a household / Bible study group / accountability partnership to **share a positive metric** while preserving each member's privacy.
- A small ally-framing layer over the existing per-user mechanic.
- An optional feature — most users will never enable it, and that is correct.

## Theological framing

The word *covenant* is intentional. It signals:

- **Mutual** rather than asymmetric (covenant is between equal parties under God).
- **Promise-shaped** rather than enforcement-shaped (a covenant is what we have committed to, not what we are coerced into).
- **Restorable** rather than terminal (Old Testament covenants persist through breach).

Avoid the word *accountability* in the UI. Accountability has been colonized in evangelical spaces by purity-monitoring products and carries that connotation. Family covenant is a clean, theologically rich, market-clear term.

## Implementation notes

Privacy-first technical design:

- Family member identifiers are pseudonymous within the group; users do not see each other's exact app or topical-area choices.
- Aggregate counter syncs via end-to-end-encrypted family group (CloudKit family on iOS; Firestore with E2EE on Android).
- Individual logs never leave the device.
- Joining a covenant requires affirmative invite + accept; leaving is one-tap and silent (no "X left the covenant" notification).

## Risk: low adoption

This feature may be used by very few users. That is acceptable. Families who want it will value it; families who don't will ignore it. It is *not* a primary acquisition driver.

The strategic value is positioning: it lets His Words say "we have a family mode" without competing in the accountability category. It satisfies the question "is there anything for families?" without inheriting the surveillance baggage.

## Cross-references

- [[wiki/concepts/redeemed-time-accounting|redeemed-time accounting]] — the metric being shared.
- [[wiki/topics/accountability-strategy|accountability strategy]] — the build-vs-partner decision.
- [[wiki/reference/accountability-app-landscape|accountability app landscape]] — what we are NOT.
