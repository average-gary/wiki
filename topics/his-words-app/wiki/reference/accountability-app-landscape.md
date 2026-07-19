---
title: Accountability app landscape — pricing and distribution
type: reference
created: 2026-06-24
updated: 2026-06-24
status: active
confidence: high
tags: [his-words-app, accountability, market, reference]
sources:
  - raw/articles/2026-06-23-accountability-covenant-eyes.md
  - raw/articles/2026-06-23-accountability-bark.md
  - raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple.md
  - raw/articles/2026-06-23-accountability-built-in-apple-google-family.md
  - raw/articles/2026-06-23-accountability-kid-phones-gabb-pinwheel-relay.md
---

# Accountability app landscape

Reference card for the accountability category His Words is *not* entering. See [[wiki/topics/accountability-strategy|accountability strategy]] for why and the [[wiki/concepts/family-covenant-mode|family-covenant mode]] for the limited adjacent feature His Words ships in v2.

## Christian-purity-accountability (the Covenant Eyes shadow)

| App | Personal Monthly | Annual | Family Tier | Lifetime | Distinguishing feature |
|---|---|---|---|---|---|
| **[[../raw/articles/2026-06-23-accountability-covenant-eyes\|Covenant Eyes]]** (anchor) | $18 | $198 | included (10 users) | **$950** | 25-year incumbent; Five Stones church program; 2022 surveillance controversy |
| [[../raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple\|Accountable2You]] | $11 | $121 | $16/mo or $176/yr | n/a | Linux support; family/personal tier split |
| [[../raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple\|Ever Accountable]] | $14.99 | $129 | unlimited devices on personal | n/a | **ISO certs (security + privacy)** — only one in category |
| [[../raw/articles/2026-06-23-accountability-budget-tier-a2y-ever-truple\|Truple]] | $16 | $160 | multi-device household | n/a | Random screenshot capture every 30s-5min |

**Pricing floor**: ~$11/mo personal, ~$16/mo family. Below this looks unserious; above competes with Covenant Eyes' brand.

**The 2022 controversy**: per [[../raw/articles/2026-06-23-accountability-covenant-eyes|Covenant Eyes profile]], multiple outlets reported Covenant Eyes and Accountable2You being used by churches and elder boards to surveil pastors and staff. Pastors were disciplined for non-criminal, non-doctrinally-prohibited searches. Google Play removed both apps temporarily. The category inherits this shadow.

## Mainstream parental monitoring

| Product | Cost |
|---|---|
| [[../raw/articles/2026-06-23-accountability-bark\|Bark App (iOS)]] | $20/mo or $148/yr |
| Bark App (Android) | $14/mo or $99/yr |
| Bark Phone | $29/mo subscription + $10/mo device (24mo) — ~$1,000/yr all-in |
| Bark Watch | $15/mo + $7/mo device |
| Bark Home (network filter) | $6/mo or $79 one-time |

**Bark for Schools (the killer distribution channel)**: free to schools. **1,000+ school districts in year one, 80/month adoption rate.** Mental-health-framed (suicidal ideation, self-harm, predator contact) — durable framing.

## Free defaults (the OS layer)

[[../raw/articles/2026-06-23-accountability-built-in-apple-google-family|Apple Family Sharing + Google Family Link]]: free, OS-integrated, cover the parental-control surface for *most* casual parents.

| | Apple Family Sharing | Google Family Link |
|---|---|---|
| Screen time | Yes | Yes |
| Geofencing | Limited | Strong |
| Content filtering | Strong | Strong |
| App approval | Ask to Buy | Required by default |
| Apple Intelligence / AI controls | Yes | (Gemini emerging) |
| Free | Yes | Yes |

What they do NOT do: content monitoring of messages/social/browser, screenshot capture, AI flagging, mental-health-language alerts. **This gap is the entire reason the Covenant Eyes / Bark / A2Y category exists.**

## Kid-safe phones (the hardware play)

| Product | Hardware | Monthly | Year 1 all-in |
|---|---|---|---|
| [[../raw/articles/2026-06-23-accountability-kid-phones-gabb-pinwheel-relay\|Gabb Phone]] | $149.99 | $24.99+ | ~$450 |
| Pinwheel | not public | not public | ~$300-500 (est.) |
| Bark Phone | $10/mo financed + wireless | $29 + wireless | ~$1,000 |
| iPhone SE on Family Sharing | $429 + plan | varies | ~$700+ |

**Relay's pivot from kid-walkie-talkie to enterprise frontline-comms is the cautionary tale.** The kid-phone consumer market is structurally hard. His Words should not enter it.

**Partnership opportunity**: a Gabb / Pinwheel preinstall partnership (His Words bundled on the device) is realistic; competing on hardware is not.

## The structural lesson

The whole third-party accountability category exists because Apple and Google **deliberately do not provide content surveillance**. They provide guardrails (filters, time limits) but not transparency (read everything, share with a third party).

This is a values choice baked into the platforms:
- Apple: privacy as competitive advantage.
- Google: ad-driven, but legally constrained around minors.

Bark, Covenant Eyes, Accountable2You, Ever Accountable, Truple all sell the *transparency layer* the OSes refuse to ship. That's the moat — and it's also why every one of those apps has had Apple/Google Play Store friction (Covenant Eyes + A2Y removed in 2022 sweep).

## Why His Words doesn't enter

1. **Don't compete with Covenant Eyes.** 25-year incumbent with church distribution at scale.
2. **Don't compete with Bark.** Free-to-schools flywheel is uncatchable.
3. **Don't ship a kid phone.** Hardware logistics are a different business; Relay is the warning.
4. **Don't duplicate Apple/Google.** Free OS-level controls cover the basic surface.
5. **Don't ship surveillance.** Inherits the 2022-controversy shadow.

The only lane that remains and is also strategically valuable: **shared positive-engagement metric inside His Words' own app** — the [[wiki/concepts/family-covenant-mode|family-covenant mode]] aggregate-counter. v2 only.

## COPPA / GDPR-K notes

If His Words ever shipped a kids tier (it should not in v1):

- **COPPA (US)**: apps directed to under-13s require verifiable parental consent. 2024-2025 FTC amendments tightened third-party data sharing requirements.
- **GDPR-K (EU)**: parental consent required for under-16 (or under-13 depending on member state).
- **Apple Kids Category and Google Designed for Families**: stricter SDK rules.

For a v1 adult-only product, none of this binds. But the boundaries should remain clear.

## Cross-references

- [[wiki/topics/accountability-strategy|accountability strategy]] — synthesis use of this map.
- [[wiki/concepts/family-covenant-mode|family-covenant mode]] — the v2 feature His Words actually ships.
