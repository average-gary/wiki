---
title: "shock.network — ShockNet org homepage, products, founding, investors"
source: https://shock.network
type: article
ingested: 2026-06-09
path: origin
quality: 5
credibility: high
tags: [clink, shocknet, history, funding, vc-backing, products, lightning-pub, shockwallet]
---

# Source overview

The official homepage of SHOCK.Network, the parent organization behind CLINK.
This page is the primary canonical statement of (a) when ShockNet was founded,
(b) what the full product portfolio looks like (CLINK is one of ~8 lines), and
(c) how the company is funded. It is the authoritative public source for the
"who is behind CLINK" question because it ties Justin's GitHub work to a
named, US-located organization with declared investors.

# Key findings

## Organization basics

- Name: SHOCK.Network (frequently styled SHOCKNET on GitHub, ShockBTC on
  social platforms).
- Mission: "Democratizing financial incentives on the internet by enabling
  direct micropayments between users and services, bypassing traditional
  intermediaries and their fee structures."
- Tagline: Builds a Lightning-Nostr stack enabling Bitcoin-native
  applications. Non-custodial, open-source.
- Founded: 2018 (the page cites "block #543210"; Bitcoin block 543210 was
  mined approximately mid-2018, matching the 2018-03-08 GitHub organization
  creation date independently visible via the GitHub API).
- Location: Not pinned on the site, but the GitHub org public profile reads
  "United States of America"; Justin's personal profile says "US".

## Founders / team

The shock.network home page does not name individual founders or list a
team. This is consistent with a small, founder-led startup that prefers to
let the GitHub commit log identify its principals (Justin / "Justin
shocknet" plus Hatim Boufnichel / boufni95 are the visible engineering
core). The site instead funnels readers toward calendly.com/shocknet/halfy
for booking, a single "halfy" 30-min slot, which strongly suggests one
person on the calendar (Justin).

## Investors / funding model

This is the most novel finding of the source: ShockNet is VC-backed, not
grant-funded. Listed backers on the homepage:

- Wolf Venture Capital
- Ride Wave Ventures
- Fulgur Ventures

Fulgur Ventures is the well-known Lightning-focused fund (Strike, Voltage,
Fedi, Zeus alumni). The presence of Fulgur is significant: it puts ShockNet
in the same investor cohort as Zeus Wallet, which now ships CLINK Offers as
a default for ZEUS Pay users. That alignment likely is not a coincidence;
the Fulgur portfolio is a plausible explanation for why Zeus was the first
external wallet to ship CLINK support (per the README ecosystem table:
"Zeus Wallet — Pay offers, ZEUS Pay users get an offer by default").

There is no mention on the homepage of:

- OpenSats grants
- HRF Bitcoin Development Fund
- Spiral / Block grants
- Brink fellowships
- Bitcoin Design grants

Cross-referenced against opensats.org/projects on 2026-06-09: no ShockNet,
CLINK, Lightning.Pub, or ShockWallet entries appear in the OpenSats project
showcase. CLINK is therefore not Bitcoin-grant-funded as of mid-2026.

## Product portfolio

ShockNet describes CLINK as one product among eight. The full stack:

1. Lightning.Pub: "node management protocol", described as the Nostr-Native
   Lightning node. Reference server for CLINK.
2. ShockWallet: cross-platform Lightning wallet, multi-node via LNURL/Nostr.
3. Lightning.Video: Bitcoin-native video platform. Justin's Stacker.News
   bio says he is "Relentlessly Lightning Maxxing @ Lightning.Video |
   ShockWallet.app".
4. CLINK: "payments standard for Nostr". Available as an SDK.
5. Sanctum Auth: access delegation / remote signing (Sanctum DK is the
   embedded component repo).
6. BXRD.app: Nostr social client (graph-based; per CLINK README, ships
   debit-integrated zaps).
7. NymRank: decentralized Web-of-Trust namespace, October 2025 repo.
8. Nodestr VMs: Lightning-paid virtual servers.

The pattern is clear: ShockNet is a vertically integrated Lightning + Nostr
stack vendor, and CLINK is the public-protocol layer they extracted from
their own product surface to invite outside wallets and services to
interoperate. Product to CLINK role mapping:

- Lightning.Pub = CLINK reference server (publishes offers, fields
  requests).
- ShockWallet = CLINK reference wallet (consumes offers, manages debits).
- Bridgelet = CLINK to legacy LNURL/NIP-05 bridge.
- BXRD = CLINK and Nostr social UX (zaps via debits).
- ClinkSDK = the client library every third-party integrator (Zeus,
  Stacker.News, TakeMySats) uses.

This is exactly the "founder uses their own dogfood to bootstrap an open
spec" pattern (compare: Damus to NIP-04, BlueWallet to submarine swaps,
Strike to USDT-on-Lightning).

## Contact channels

- Email: info@shock.network
- Calendly: calendly.com/shocknet/halfy
- Telegram (group): t.me/ShockBTC
- Telegram (Justin direct): t.me/justin_shocknet
- X / Twitter (org): @ShockBTC
- X / Twitter (Justin): @shocknet_justin
- Nostr (org/Justin shared key):
  npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa
  (this same npub is published on clinkme.dev/contact.html as the project
  contact key, confirming Justin and ShockNet route through one Nostr
  identity).

# Timeline events

- 2018 (block #543210): ShockNet founded; GitHub org created 2018-03-08.
- 2018-2019: Earliest products: shocknet.github.io site, singles-api
  (Lightning Singles Directory), Wizard installer, Lightning.Pub, wallet,
  chargedMail (Lightning paywall for Gmail).
- 2019-10-17: Lightning.Pub repo seeded (still the most-starred ShockNet
  repo at 93 stars).
- 2022-11-17: wallet2 (current ShockWallet) launched.
- 2024-05-29: docs repo created.
- 2024-09-06 to 10: bridgelet, clink-demo seeded as the first artifacts of
  the CLINK pattern (8 months before the formal spec).
- 2025-05-05: CLINK spec published.
- 2025-12-10: PlebCafe (a new ShockNet project) seeded.
- 2026-01-12: spot (Coinbase price mirror) seeded.

The org has a 6-year operating history before CLINK, which counts heavily
toward credibility: this is not a fly-by-night spec proposal.

# Direct quotes

> "Applications and Services for the Bitcoin Lightning Network"

SHOCKNET org GitHub description (verbatim).

> "Democratizing financial incentives on the internet by enabling direct
> micropayments between users and services, bypassing traditional
> intermediaries and their fee structures."

shock.network mission statement.

> "Established in 2018 (block #543210)"

shock.network founding date framing; block-height anchoring is a tell that
ShockNet self-identifies as Bitcoin-cypherpunk culture.

> "Relentlessly Lightning Maxxing @ Lightning.Video | ShockWallet.app"

Justin's Stacker.News bio (verbatim): the personal mission statement that
motivates CLINK from his side.

# Open questions

- Are the three VC funds (Wolf VC, Ride Wave, Fulgur) seed or series-A-stage
  backers? Round size and date are not disclosed on the page.
- Is anyone besides Justin and Hatim Boufnichel on the engineering team
  full-time? The site is silent; the GitHub org has 27 repos and only one
  public org member (Justin). Headcount is opaque.
- Does ShockNet plan to seek any Bitcoin-ecosystem grant (OpenSats, HRF)
  for CLINK specifically, or is the VC route the long-term path?
  Implication for governance: VC-funded protocols can pivot or
  proprietarize in ways grant-funded ones typically do not.
- Is there a written ShockNet "About / Team" page? The /about path returns
  404, the /team path returns 404: the homepage is the canonical org page.
- What is the relationship between Lightning.Video (the company Justin
  most identifies with on Stacker.News) and CLINK? Is Lightning.Video a
  CLINK consumer at scale yet, or is it still pre-launch?

# Why this matters

This source is critical for placing CLINK in a credibility/funding context.
Three takeaways for the wiki:

1. CLINK is a single-vendor open spec with VC money behind it. Different
   governance dynamics from grant-funded NIPs (NIP-47 NWC was shepherded by
   Alby with much broader implementer input from day one). The Fulgur
   Ventures connection plausibly explains the early Zeus Wallet integration.
2. CLINK is not in any visible Bitcoin grant pipeline as of 2026-06-09: if
   a wiki reader is evaluating it for grant-cycle stability or for the
   "open-source-and-bus-factor" risk, the funding posture is private VC,
   not public grants.
3. The 2018 founding date and 6-year product history establish ShockNet
   as a serious Lightning vendor, not a CLINK-specific shell: useful for
   reputational due-diligence framing.
