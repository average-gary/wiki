---
title: Accountability strategy — build vs. partner vs. skip
type: topic
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: medium
tags: [his-words-app, accountability, strategy, family-mode]
sources:
  - raw/articles/2026-06-23-accountability-covenant-eyes.md
  - raw/articles/2026-06-23-accountability-bark.md
  - raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple.md
  - raw/articles/2026-06-23-accountability-built-in-apple-google-family.md
  - raw/articles/2026-06-23-accountability-kid-phones-gabb-pinwheel-relay.md
---

# Accountability strategy

Three options, in increasing scope:

1. **Skip accountability for v1.** Focus on individual user; no family / partner / group features. (Recommended for v1.)
2. **Ship lightweight family covenant** — group-aggregate redeemed-time counter, no surveillance. ([[wiki/concepts/family-covenant-mode|family-covenant mode]] details). v2 candidate.
3. **Integrate with Covenant Eyes** as accountability partner. Avoid head-on competition. v2-v3 candidate.

**Do not** build a full Christian-purity-accountability product. Reasons follow.

## Why not compete with Covenant Eyes

Per [[../raw/articles/2026-06-23-accountability-covenant-eyes|Covenant Eyes profile]]:

- 25-year incumbent. ~1.7M users. 71k+ app reviews at 4.5 stars.
- Five Stones church-partnership distribution operates at scale that an indie cannot match.
- The 2022 Wired/Slate/Tech Policy Press surveillance controversy is a live wound. Pastors disciplined for legal-but-private searches forwarded to elder boards. Google Play removed the apps temporarily.
- The category inherits this shadow. Any app positioned as "accountability" carries Covenant Eyes' reputational baggage by association.

The budget tier ([[../raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple|Accountable2You / Ever Accountable / Truple]]) at $11-16/mo has already exhausted the differentiation surface (Linux support, ISO certs, screenshot frequency control). His Words entering as the 5th Christian-purity-accountability app would be commoditized at launch.

## Why not compete with Bark

Per [[../raw/articles/2026-06-23-accountability-bark|Bark]]:

- Free-to-schools distribution flywheel: 1,000+ districts in year one, 80/month adoption.
- Mental-health-framed (suicidal ideation, self-harm, depression) — durable framing.
- Bark Phone hardware play sidesteps Apple's API constraints.

His Words is not a kid-monitoring product and should not become one. Bark and His Words can coexist — Bark watches kids' content, His Words helps adults engage Scripture during their own time.

## Why not build a kid phone

Per [[../raw/articles/2026-06-23-accountability-kid-phones-gabb-pinwheel-relay|kid phones]]:

- Gabb / Pinwheel / Bark Phone require hardware logistics, carrier deals, brutal margins.
- Relay's pivot from kid-walkie-talkie to enterprise frontline-comms is the cautionary tale: even a beloved consumer product couldn't sustain B2C unit economics.
- Forever-parents are a small market; most parents capitulate to the iPhone eventually.

A His Words family mode that competes with Gabb on hardware loses; one that complements (preinstalled-on-Gabb-phone partnership) is realistic.

## Why not duplicate Apple Family Sharing / Google Family Link

Per [[../raw/articles/2026-06-23-accountability-built-in-apple-google-family|built-in family controls]]:

- Apple Screen Time + Google Family Link cover scheduling, app limits, content filters, age-rating gates **for free**.
- Every iPhone and Android parent already has these.
- Any third-party family product must answer "what does this do that the OS doesn't?"

Apple/Google deliberately do *not* ship content surveillance (read messages, screenshot apps, etc.). That gap is what Covenant Eyes / Bark / A2Y fill. His Words should *not* fill it; the surveillance category is reputationally costly.

The His Words family-mode opportunity sits *inside the app, not at the OS layer*: shared scripture engagement aggregate. Not "what apps did your spouse use today" but "how many minutes did our family redeem this week from doomscrolling into scripture."

## The recommended path

### v1: skip accountability

No family mode, no partner pairing, no group feed, no shared anything. Single-user iOS app. The [[wiki/concepts/interruption-rhythm|interruption-rhythm]] is the value-prop; accountability dilutes the focus.

This is also a positioning argument: His Words ships *narrow and excellent* against the [[../raw/articles/2026-06-23-competitors-bible-mode|kitchen-sink Bible Mode]] / [[../raw/articles/2026-06-23-competitors-prayer-lock|maximalist Prayer Lock]] competitors. One mechanism, executed perfectly.

### v2: family covenant mode

Per [[wiki/concepts/family-covenant-mode|family-covenant mode]]: opt-in shared-aggregate redeemed-time counter. No screenshots, no individual reporting, no surveillance. Positioned as *covenant*, not accountability.

This is launched only after v1 demonstrates traction (≥10k MAU, ≥40% Day-30 retention). Until then, family covenant is a feature without enough single-user product to attach to.

### v3 (conditional): Covenant Eyes integration

If a real product partnership becomes available, integrate at the API level: Covenant Eyes users can opt to have their His Words attended-interrupt count surface in their Covenant Eyes dashboard as a positive-engagement signal. This positions His Words as the *positive* counterpart to Covenant Eyes' *avoidance* product. Both serve the same audience, neither cannibalizes the other.

Risk: Covenant Eyes is a competitor on church distribution. Partnership requires trust and a clean MOU. Not v1 territory.

## A note on naming

Avoid the word "accountability" in the UI. The term has been colonized in evangelical spaces by purity-monitoring products and carries the Covenant Eyes shadow. Use:

- "covenant" for [[wiki/concepts/family-covenant-mode|the v2 family feature]].
- "shared minutes" or "our family's minutes redeemed" in metric copy.
- Never "monitor", "watch", "report", "alert."

## Pricing implications

If family covenant ships in v2, the pricing question is whether to charge extra. Per [[../raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple|budget tier]]:

- Family tiers in the accountability space charge ~50% premium over personal ($16/mo vs. $11/mo at Accountable2You).
- His Words family covenant is structurally lighter (no screenshots, no monitoring) — the engineering and ops cost is small.
- Recommend bundling family covenant in the standard subscription rather than charging a family-tier premium. This avoids the optics of "pay more to share with your family" which conflicts with the gospel-shaped framing.

## Cross-references

- [[wiki/concepts/family-covenant-mode|family-covenant mode]] — what v2 ships.
- [[wiki/reference/accountability-app-landscape|accountability app landscape]] — the comp set.
- [[wiki/topics/positioning-and-differentiation|positioning]] — focus argument.
