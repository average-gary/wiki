---
title: shocknet/wallet2 (ShockWallet) — CLINK reference wallet (client-side)
source: https://github.com/shocknet/wallet2
type: repo
ingested: 2026-06-09
path: implementations
quality: 5
credibility: high
tags: [clink, implementation, shockwallet, wallet, client, noffer, ndebit, manage, pwa, mobile]
---

# Source overview

`shocknet/wallet2`, branded **ShockWallet**, is ShockNet's reference *client* implementation of CLINK. TypeScript, 42 stars, 1,812 commits, 20 beta releases (latest `v0.0.28-beta`, 2026-06-06). Distributed as a single-codebase PWA + Android APK + iOS TestFlight. It is listed in the canonical CLINK README as *"Wallet — Offers, Debits — Pay offers and manage your offers and requests via Lightning.Pub."*

# Key findings

- Release notes provide the **clearest CLINK shipping timeline** of any source — they reveal that Manage (kind 21003) IS shipped on the wallet side even though the README ecosystem table only lists Offers + Debits:
  - `v0.0.19-beta` (2025-06-10) — "clink client" by boufni95 in #392
  - `v0.0.20-beta` (2025-08-11) — "clink manage auth and list" by boufni95 in #437 — **first evidence of Manage shipping**
  - `v0.0.21-beta` (2025-09-20) — "up clink", "bridge types"
  - `v0.0.22-beta` (2025-10-10) — "Blinded path offers" — BOLT12 interop alongside CLINK
  - `v0.0.28-beta` (2026-06-06) — "update clink / noffer" by shocknet-justin in #615
- Connection model: user pastes an `nprofile` from a Lightning.Pub instance into `my.shockwallet.app/sources` — entire onboarding is via Nostr identifiers, no LNURL or HTTP required.
- ShockWallet's `/lapps` page exposes the `ndebit` (for paying out) and `/offers` page shows the `noffer` (for receiving). Stacker News's CLINK testing doc (separate source) confirms this UI flow:
  > "Go to https://my.shockwallet.app/lapps; Copy ndebit and paste into SN [...] Go to https://my.shockwallet.app/offers; Copy offer and paste into SN"
- Multi-platform from one codebase: web/PWA at `my.shockwallet.app`, Android via GitHub releases APK, iOS via TestFlight beta.
- README features list emphasizes NIP-78 multi-device sync, recurring payments, pre-authorized external apps (this is the Manage / Debits authorization pattern user-facing), optional Bootstrap node for self-custodied channels.
- Self-described as *"a revolutionary Lightning Wallet for connecting to nodes over Nostr."* but also: *"there will be bugs and bad UX decisions"* — explicit beta posture.

# Maturity assessment

**Late-stage beta, near-shipped.** v0.0.28-beta after ~2 years of public development. Production-deployed PWA available now; iOS still TestFlight (not on App Store). CLINK Offers, Debits, AND Manage all have shipped commits. Active development through 2026-06 — most recent release literally one day before this ingest, titled "update clink / noffer."

# Direct quotes from README + release notes

1. README: *"a revolutionary Lightning Wallet for connecting to nodes over Nostr"*
2. README: *"We're also pushing the boundaries of Nostr and Lightning integration with CLINK that create more secure app connections with better UX than is currently available."*
3. v0.0.20 release: "clink manage auth and list" — first Manage support
4. v0.0.22 release: "Blinded path offers" — coexistence with BOLT12 blinded paths in the same wallet
5. v0.0.28 release (most recent, 2026-06-06): "update clink / noffer"

# Open questions

- ShockWallet supports `nmanage` per release notes, but neither the CLINK README ecosystem table nor any other listed wallet declares Manage support. Is there any *service* that issues nmanage codes for ShockWallet to consume, or is it client-side only / pending a peer service?
- iOS shipping path: is App Store submission planned, or is TestFlight the indefinite distribution channel? (Apple has historically rejected non-custodial Lightning wallets — possible adoption blocker.)
- ShockWallet uses CLINK as its primary wallet-attach mechanism *for Lightning.Pub*. Does it interop with any non-Lightning.Pub CLINK service? (Stacker News, yes — confirmed via cross-source.) Bridgelet? bxrd.app? Probably yes per README ecosystem, but not directly confirmed in shockwallet release notes.

# Why this source matters

ShockWallet is the canonical *client* counterpart to Lightning.Pub and the only wallet implementing all three CLINK specs (Offers, Debits, Manage). Its release notes are the most granular public timeline of CLINK feature rollout in any wallet. Together with Lightning.Pub it forms the complete first-party demo loop, and its proven interop with Stacker News makes it the integration target for any new third-party CLINK adopter.
