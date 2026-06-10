---
title: "ShockNet ecosystem repo history — bridgelet, clink-demo, ClinkSDK origin trail"
source: https://github.com/shocknet
type: repo
ingested: 2026-06-09
path: origin
quality: 5
credibility: high
tags: [clink, shocknet, history, bridgelet, clink-sdk, lightning-pub, predecessors, roadmap, ecosystem]
---

# Source overview

Aggregated GitHub-API view of all 27 repositories owned by the ShockNet
org, with a focus on (a) the repos that pre-date the formal CLINK spec but
already implement the pattern (bridgelet, clink-demo), (b) the SDK and
reference-server repos that ship CLINK in production (ClinkSDK,
Lightning.Pub, wallet2), and (c) newer repos (PlebCafe, NymRank, spot)
that hint at where ShockNet, and therefore CLINK, is heading next. The
entire view is reconstructed from `gh api orgs/shocknet/repos` plus
per-repo first-commit logs collected on 2026-06-09.

# Key findings

## Three eras of ShockNet

Reading the org's repo timestamps as a single timeline reveals three
distinct eras:

### Era 1 (2018-2022): Lightning-only

- 2018-03-08: `shocknet.github.io` (org founded).
- 2019-01: singles-api (Lightning Singles Directory).
- 2019-07: Wizard (cross-platform installer for "a Lightning Page equipped
  node").
- 2019-10: bitcoin-lightning-logo (the now-iconic Bitcoin+LN combined
  logo, 29 stars, Justin's contribution to the public-domain Lightning
  brand).
- 2019-10: Lightning.Pub (the Nostr-Native Lightning node, today still the
  org's flagship at 93 stars, but **note**: the "Nostr-Native" tagline was
  added later; in 2019 it was a node-account product).
- 2019-10: wallet (the original ShockWallet).
- 2019-11: chargedMail (Lightning paywall for Gmail Inbox).
- 2020-06: seed (WebTorrent + Livestreaming seed service over Lightning).
- 2020-08: web-client (lightweight social view).
- 2021-02: PWA (decentralized social feed and business pages over
  Lightning).

This era is **pre-Nostr** for ShockNet's product framing. Most of these
projects are now archived or superseded.

### Era 2 (2022-2024): Lightning + Nostr fusion

- 2022-11-17: wallet2 (the current ShockWallet) — first ShockNet repo
  that explicitly mentions Nostr in its description: "Connect to multiple
  Lightning Nodes via LNURL and NOSTR".
- 2022-11-27: SMART (Slightly More Advanced Relay Technology for NOSTR) —
  ShockNet's first own-Nostr-relay project.
- 2024-05-29: docs (org documentation site, signaling the project surface
  has grown enough to need formal docs).
- 2024-09-06: **clink-demo** (HTML, by hatim boufnichel / boufni95).
- 2024-09-08: **bridgelet** ("LNURL and NIP-05 service powered by Nostr
  Offers", first commit by Justin).
- 2024-09-10: nostr-tools fork (preparing for SDK work).
- 2024-11-16: SanctumDK (embedded Sanctum Remote Signer component).

The September 2024 cluster is **the most important origin signal in the
entire org**: bridgelet's first-commit description "LNURL and NIP-05
service powered by Nostr Offers" predates the formal CLINK spec by
**8 months**, and uses the term "Nostr Offers" — which is what the May
2025 spec would name `noffer1...` static payment codes. The CLINK pattern
existed inside ShockNet as production code before it was named, written
down, or made into a public spec.

### Era 3 (2025-2026): CLINK as a public protocol

- 2025-05-05: **CLINK** repo (the formal spec, 22 stars).
- 2025-05-26: **ClinkSDK** (TypeScript client SDK by boufni95).
- 2025-07-16: test-umbrel-store (Umbrel app-store testing for
  one-click ShockNet deploys).
- 2025-10-18: **NymRank** ("Namespace for nostr based on social
  consensus") — this is the same problem space as issue #6 on CLINK
  (replacing HTTPS for NIP-05 discovery), but solved via Nostr WoT
  rather than via Namecoin. Strongly suggests ShockNet has its own
  preferred answer to the NIP-05 dependency problem and that issue #6
  is unlikely to be merged as-is.
- 2025-12-10: PlebCafe (no description; a new product line).
- 2026-01-12: spot ("Mirror Bitcoin spot price from Coinbase" —
  utility, but reveals ongoing infrastructure work).

## What ShockNet's roadmap looks like (read indirectly)

The org has no public ROADMAP.md anywhere, but the repo creation pattern
and cross-references reveal direction:

1. **Discovery without HTTPS** is a real and active product priority.
   NymRank (2025-10) is ShockNet's own answer to the NIP-05 / DNS
   problem (the same problem issue #6 raises). Expect a "CLINK over
   NymRank" pattern more than "CLINK over Namecoin".
2. **Self-hosted node UX** is the long-term target. The Wizard (2019)
   to Umbrel (2021) to test-umbrel-store (2025) progression shows
   ShockNet is committed to making `Lightning.Pub` a one-click home-server
   install. CLINK's spec design (NIP-05 entry point, Lightning.Pub
   webhook integration) is built around this end-state.
3. **Remote signing / delegation** matters: SanctumDK (2024-11) is the
   embedded component for Sanctum Remote Signer, which dovetails with
   `clink-manage.md` (delegated management) — kind 21003.
   Speculative roadmap item: "CLINK delegated signing" to combine
   Sanctum and clink-manage.
4. **Nostr-native social** is the consumer wedge. BXRD.app (Nostr
   social client with debit-integrated zaps) is how ShockNet plans to
   put CLINK in front of regular users — zaps as the demo use-case.
5. **Streaming / video** has been a recurring ShockNet theme since
   2020 (`seed` repo) and surfaces today as Lightning.Video. CLINK
   debits (recurring authorized pulls) are the obvious primitive for
   streaming/subscription monetization. Speculative roadmap item:
   "CLINK debits for streaming sats/sec".

## What is NOT in the public roadmap signal

- **Hold invoices** are not visible in any repo description. The CLINK
  Offers spec uses standard BOLT11 invoices end-to-end; nothing in the
  org public surface suggests hold-invoice or escrow features are next.
- **Splices over CLINK** are not visible. clink-manage.md is about
  delegated offer/debit management, not channel-management.
- **Multi-vendor RFC process**: no separate "clink-rfcs" repo, no
  invitation to other vendors to co-maintain.
- **Bolt12 bridge**: no shocknet/bolt12-bridge or similar.

If a wiki reader wants to know "what is genuinely on the table for CLINK
v2?" the org-wide repo signal points firmly at **discovery hardening
(NymRank), wallet UX (BXRD, ShockWallet), and node-side delegated
management (Sanctum + clink-manage)**. Hold-invoices and splices are not
indicated.

# Timeline events (consolidated)

- 2018-03-08: ShockNet org created.
- 2019-10-17: Lightning.Pub repo seeded.
- 2022-11-17: wallet2 seeded; first explicit Nostr in product framing.
- 2022-11-27: SMART relay seeded.
- 2024-09-06: clink-demo first commit (boufni95).
- 2024-09-08: bridgelet first commit ("LNURL and NIP-05 service powered
  by Nostr Offers").
- 2025-05-05: CLINK spec repo created.
- 2025-05-26: ClinkSDK first commit (boufni95).
- 2025-07-31: clink-manage spec merged (kind 21003).
- 2025-10-18: NymRank seeded (alternative NIP-05 discovery).
- 2025-12-10 / 2026-01-12: PlebCafe / spot seeded.

# Direct quotes (from repo descriptions, verbatim)

> "LNURL and NIP-05 service powered by Nostr Offers"

bridgelet description; the term "Nostr Offers" predates the CLINK spec by
8 months and is the strongest evidence that CLINK is a formalization of an
already-shipping pattern.

> "The Nostr Native Lightning node, share your node with nostr accounts and
> connect easily to webapps."

Lightning.Pub description (2019 repo, current text). The "Nostr-Native"
framing was retrofitted; CLINK's reference server inherits this position.

> "Namespace for nostr based on social consensus"

NymRank description (2025-10). ShockNet's preferred answer to "how do we
do NIP-05 / discovery without HTTPS or DNS or CAs?".

> "Connect to multiple Lightning Nodes via LNURL and NOSTR"

wallet2 / ShockWallet description; the consumer endpoint of CLINK.

# Open questions

- Is NymRank intended as a replacement for the NIP-05/HTTPS discovery hop
  in CLINK, or as an additive option? The two repos are not cross-linked.
- Is there a public ShockNet quarterly roadmap update anywhere (newsletter,
  Substack, Nostr long-form)? Not surfaced in any repo or website.
- Is the Sanctum Remote Signer being designed to deliberately back
  clink-manage delegations, or is the convergence accidental? No public
  design doc connects them.
- What is PlebCafe? The repo is empty / undescribed. Could be a community
  product or could be a CLINK-flavored consumer app.
- Why is ClinkSDK 100% TypeScript with no Rust counterpart? A Rust SDK
  (for LDK / CDK / Iroh integration) is conspicuously absent and would
  unlock a whole class of node-side integrations. Is this a deliberate
  scope decision or a resourcing gap?
- Is there a CLINK paid offering or commercial license behind the scenes
  (e.g., enterprise Lightning.Pub support contracts) that funds the open
  spec work? VC funding alone usually requires a revenue thesis; the
  public surface does not show one yet.

# Why this matters

This org-wide view is essential because the CLINK repo alone tells less
than half the origin story. Three takeaways for the wiki:

1. **CLINK is a formalization, not an invention.** The pattern shipped
   inside ShockNet's products in September 2024 (bridgelet's "Nostr
   Offers"). The May 2025 spec is the rationalization step. This makes
   the spec less risky as a thing to build on: the implementation
   experience is older than the spec.
2. **ShockNet's own product roadmap is the de facto CLINK roadmap.**
   With no public ROADMAP.md and a single-vendor governance model, the
   answer to "what is next in CLINK?" is best read off ShockNet's other
   repos: NymRank (discovery), BXRD (social UX), Sanctum (delegated
   signing), Lightning.Pub (node).
3. **Hold-invoices, splices, and multi-vendor RFC processes are not on
   the indicated path.** A wiki reader expecting CLINK to evolve into a
   full Lightning-control protocol that competes with NWC's full RPC
   surface should adjust expectations downward: CLINK is intended to
   stay a tight, identity-and-payment-flow protocol, not a node-RPC
   replacement. NWC and CLINK are likely to coexist as
   complementary-not-competing specs from the org's perspective.
