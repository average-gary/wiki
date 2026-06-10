---
title: shocknet/Lightning.Pub — CLINK reference server (node-side)
source: https://github.com/shocknet/Lightning.Pub
type: repo
ingested: 2026-06-09
path: implementations
quality: 5
credibility: high
tags: [clink, implementation, lightning-pub, shocknet, lnd, reference-server, noffer, ndebit]
---

# Source overview

`Lightning.Pub` is ShockNet's Nostr-native Lightning node wrapper — the canonical CLINK *server* (node-side) implementation listed first in the CLINK README ecosystem table as "Reference server for wallets." 93 GitHub stars (most-starred in the org), TypeScript, AGPL-licensed, ~3,481 commits, 9 releases (latest `StartOS v0.0.26`, 2026-02-06). It wraps LND, runs Neutrino so no separate Bitcoin node is required, manages channels via LSPs, and exposes Nostr-native interfaces including CLINK Offers and CLINK Debits.

# Key findings

- Listed in the canonical CLINK README ecosystem table as: *"Lightning.Pub — Server — Offers, Debits — Reference server for wallets."*
- Recent CLINK-tagged migration in code search: `src/services/storage/migrations/1765497600000-clink_requester.ts` adds columns `clink_requester_pub` and `clink_requester_event_id`. Timestamp `1765497600000` ≈ 2025-12-12 (Unix ms) — indicates ongoing CLINK-side schema work in late 2025.
- README positions CLINK Offers as part of solving the Lightning Address self-custody gap: *"Your Pub's CLINK offers enable ShockWallet to connect to CLINK-compatible services, like Stacker News"* — explicitly referencing Stacker News interop.
- Architecture: zero-network-config (no port-forwarding / DNS / firewalls), uses Nostr relays for transport, NIP-44 encryption. Multi-layer accounting for "applications and users" — supports the Uncle-Jim model where one node serves many ShockWallet users.
- StartOS releases (StartOS = Start9's sovereign-computing OS) — Lightning.Pub ships as an Umbrel/Start9 app, not just a developer artifact. Latest 9 releases are all `StartOS v0.0.x` from late 2024 / early 2025, indicating productionization for sovereign-node packaging.
- README hedge: *"While this software has been used in a high-profile production environment for several years, it should still be considered bleeding edge."*

# Maturity assessment

**Beta-shipped (production with caveats).** Multi-year prod history per maintainer claim, packaged for Start9/StartOS, actively committed to (CLINK migration ts 2025-12-12), and explicitly designated by the spec maintainers as the **reference server**. Versioning is `StartOS v0.0.x` — pre-1.0, so semver-wise still beta, but it is the de-facto canonical CLINK server.

# Direct quotes from README

1. *"The biggest hurdle to more adoption via Family and SMB Lightning nodes hasn't been with Bitcoin/Lightning node management itself...but rather the legacy baggage of traditional Client-Server web infrastructure."*
2. *"Nostr native CLINK 'offers'"* — listed as a feature.
3. *"Your Pub's CLINK offers enable ShockWallet to connect to CLINK-compatible services, like Stacker News"*
4. *"While this software has been used in a high-profile production environment for several years, it should still be considered bleeding edge."*
5. The implementation prioritizes *"Nostr's own encryption spec (NIP44)"* for trustless relay communication.

# Open questions

- Lightning.Pub release notes are sparse — page returns "Uh oh! There was an error while loading" via WebFetch, and gh CLI release listing for shocknet/Lightning.Pub shows StartOS-targeted releases without inline changelogs. Is there a CLINK-specific changelog anywhere? (Likely commits-only.)
- Does Lightning.Pub implement CLINK Manage (kind 21003)? README mentions Offers and Debits explicitly; Manage is absent. Spec-side migration `clink_requester` columns suggest a per-request authorization model — could be Manage scaffolding but not confirmed.
- Lightning.Pub depends on LND. Are there CLN, LDK, or Eclair forks/equivalents? (Not in the ShockNet org. No forks of the CLINK-server architecture for non-LND backends.)

# Why this source matters

Lightning.Pub is the *only* full-stack CLINK server implementation. Anyone building a CLINK-compatible service today must either run Lightning.Pub or write their own server-side spec implementation. This makes it both the de-facto reference and the single point of failure for ecosystem health on the server side.
