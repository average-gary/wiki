---
title: "clinkme.dev/contact.html — official CLINK contact, Nostr npub, governance posture"
source: https://clinkme.dev/contact.html
type: article
ingested: 2026-06-09
path: origin
quality: 5
credibility: high
tags: [clink, shocknet, governance, contact, nostr-identity, npub]
---

# Source overview

The contact page of the CLINK project's canonical website (clinkme.dev). It
is the only place where the project explicitly publishes its governance
contact channels in one place: a Nostr npub, a Telegram group, an X handle,
and a pointer to GitHub Discussions. Despite being a short page, it is
load-bearing for several distinct claims about CLINK's organizational
posture, and it confirms a critical identity fact: the CLINK project Nostr
key is the same as the ShockNet/Justin key.

# Key findings

## Listed contact channels

- GitHub Discussions (https://github.com/shocknet/CLINK/discussions): the
  project's stated forum for protocol and integration inquiries.
- Telegram community: @ShockBTC (https://t.me/ShockBTC).
- Twitter / X: @ShockBTC.
- Nostr public key:
  npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa.

The page presents these channels with minimal framing: "For protocol
questions, integration help, or to join the community, reach out via [the
listed channels]."

## The CLINK npub IS the ShockNet npub

The same Nostr public key
(npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa) is
published as:

- the contact key on clinkme.dev/contact.html, AND
- the contact key on the shock.network home page.

Implications:

1. There is no separate "CLINK Foundation" or "CLINK working group" Nostr
   identity. CLINK's Nostr presence is operationally indistinguishable from
   ShockNet's. The protocol speaks with the company's voice.
2. This npub is most likely Justin's personal/operational key (since
   shock.network and clinkme.dev are both Justin-run properties and the
   site has no separate "team" page). On Nostr, "the CLINK project" is a
   single human's keypair.
3. For wallet implementers verifying CLINK announcements, NIP-05
   verifications, or signed spec updates: the trust anchor is one key. If
   that key is rotated or compromised, both ShockNet and CLINK would need
   to coordinate a key migration simultaneously. There is no documented
   key-rotation process.

## Governance posture (what is NOT on the page)

A contact page that lists no team, no working-group members, no charter,
no signing-keys roster, no contributors-policy link, and no roadmap
document is itself a strong governance signal. CLINK is, by its own
public framing on this page, **operated as a single-vendor open spec
with a community-input shape but maintainer-led decisions**. The
"Contributing" section in the GitHub README lists a five-step process
(Discussion to Acceptance), but the contact page shows no separate
governance body to enforce it.

Compare to other Lightning specs:

- Bolt12 (BLIPs): listed maintainers across multiple implementers
  (Lightning Labs, ACINQ, Blockstream).
- NIP-47 NWC: a NIP with a track of co-authors and an active discussion
  on nostr-protocol/nips.
- LNURL specs: split across multiple implementer GitHub orgs.
- CLINK: one Nostr key, one Telegram group, one X handle, one GitHub org.

This is not necessarily bad: many successful open specs started this way
(NIP-04 was effectively a Damus thing for a long time; LSAT was a
Lightning Labs thing). But it is a fact a wiki reader should weigh when
estimating future spec stability and governance robustness.

## What the page does NOT mention

- No founder names.
- No co-author list.
- No advisory board.
- No sponsorship/funding callout (no GitHub Sponsors link, no OpenSats
  badge, no "supported by [VCs]" line; the VC backing is only on
  shock.network, not on clinkme.dev).
- No conference appearance archive or "see us at" calendar.
- No press or media kit.
- No code of conduct or contributor license agreement (CLA) link.
- No roadmap link.
- No "subscribe to updates" / mailing list.

The minimalism is deliberate: this is a project portal that funnels
serious inquiries into a single Telegram group and a single Nostr DM
inbox.

# Direct quotes

> "For protocol questions, integration help, or to join the community,
> reach out via..."

clinkme.dev/contact.html: the only governance-flavored sentence on the
page.

> "@ShockBTC" (Telegram and X)

The project shares its X/Telegram handles with the parent company; no
project-specific handles exist.

> "npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa"

The single Nostr key for the project, identical to the ShockNet org key.

# Timeline events

- 2025-05-05: clinkme.dev domain pointed at the CLINK web demo (matches
  spec repo creation date).
- 2025-07-05: GitHub Discussions opened with the welcome announcement (the
  contact page links to Discussions, which became active here).
- 2026-06-09 (today): contact page is current; no version history visible
  (the site is a static demo without a public changelog).

# Open questions

- Is the Nostr key on this page an HD/derived key for project-only signing,
  or is it Justin's personal everyday key? If everyday, every Nostr DM and
  every signed event is conflated with personal Nostr activity. (The
  pre-launch Stacker.News tease about CLINK was posted by
  @justin_shocknet, suggesting the personal key.)
- Is there a key-rotation policy for the CLINK contact key? The page does
  not mention one.
- Will CLINK ever set up a separate "CLINK Working Group" identity (npub +
  X handle) to decouple project governance from ShockNet's commercial
  interests? Important if a wallet vendor wants to signal "we are
  committing to the spec, not to ShockNet's roadmap".
- Is there an out-of-band signed-tag policy on the GitHub repo, or are
  spec versions only authoritative as commit hashes? The page is silent.
- Where does someone file a security disclosure for CLINK? The contact
  page does not name a security contact, though a Telegram group and DM
  channel exist. Compare to Bolt12 / LDK which have explicit
  security@ addresses.

# Why this matters

This page is the canonical "front door" for anyone trying to coordinate
with CLINK as a project. Three reasons it matters for the wiki:

1. It nails down the **identity equivalence**: CLINK's Nostr presence =
   ShockNet's = Justin's. There is no separate trust anchor.
2. It confirms the **governance posture**: lightweight, maintainer-led,
   community-input shape but no formal multi-vendor working group. This
   shapes everything from "how do I propose a change?" to "what happens
   to CLINK if ShockNet's VC runway ends?".
3. It is the **canonical source of the project's contact npub** for any
   wallet doing NIP-65 relay-list verification, NIP-05 cross-reference,
   or future signed-event verification of the spec itself. Code that
   needs to "ask the CLINK project anything programmatically" should
   start with this npub.
