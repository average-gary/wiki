---
title: shocknet/CLINK — Common Lightning Interface for Nostr Keys (canonical spec repo)
source: https://github.com/shocknet/CLINK
type: repo
ingested: 2026-06-09
path: implementations
quality: 5
credibility: high
tags: [clink, implementation, spec, shocknet, noffer, ndebit, nmanage, ecosystem]
---

# Source overview

The canonical specification repository for CLINK (Common Lightning Interface for Nostr Keys), maintained by ShockNet at `github.com/shocknet/CLINK` (22 stars as of 2026-06-09; last update 2026-06-09T21:28:40Z; no tagged releases — spec lives on `main`). Repo contains the README, three spec markdown files under `specs/`, branding SVGs, and a diagram. The README enumerates the canonical "Ecosystem" table — the authoritative list of CLINK adopters this path needs.

# Key findings

- **Three specs are documented**, each tied to a Nostr event kind:
  - `21001` — CLINK Offers (`noffer1...`) → invoice request/response
  - `21002` — CLINK Debits (`ndebit1...`) → payment authorization
  - `21003` — CLINK Manage (`nmanage1...`) → delegated management
- **Canonical Ecosystem table** lists 9 named adopters + "Your project here" placeholder. Distribution by feature support:
  - **Offers + Debits (full)**: Lightning.Pub, ShockWallet, CLINK SDK, Stacker.News, clinkme.dev, bxrd.app
  - **Offers only**: Zeus Wallet, Bridgelet, TakeMySats
  - **No Manage adopters listed in the README ecosystem table** — Manage (`21003`) is specified but appears unshipped or unreported.
- The CLINK SDK is published on npm as `@shocknet/clink-sdk` (the apps page link `github.com/shocknet/CLINK/tree/main/ClinkSDK` 404s — SDK appears to live in a separate repo `shocknet/ClinkSDK` per the org listing, last updated 2026-06-01).
- Open issue #6 ("CLINK over Namecoin: NIP-05 discovery without HTTPS", opened 2026-05-18) suggests the spec is still being extended.
- Contribution gate: "New specifications should demonstrate working implementations" — implementation-led standardization, not committee-driven.

# Maturity assessment

**Beta / actively converging.** No git tags or numbered spec versions; spec changes ship to `main`. Three specs are written and have at least one shipping reference implementation each (Offers + Debits demonstrably; Manage is asserted but no listed adopter in the ecosystem table). Contribution policy explicitly requires "Implementation First" — meaning what's documented has shipping code somewhere. Activity is recent (commits within the last day at time of capture).

# Direct quotes from README

1. "CLINK defines Nostr-native standards for Lightning Network interactions, leveraging the protocol's built-in transport, identity, and encryption."
2. "Where NWC is deferential to LNURL and scoped for a specific task, **CLINK is fundamentally committed to Nostr as the foundation for the next generation of decentralized Lightning applications.**"
3. "[CLINK Offers]: Static payment codes (`noffer1...`) analogous to LNURL-Pay but entirely Nostr-native. Enables invoice generation via Nostr direct messages without a publicly accessible HTTPS endpoint."
4. "[CLINK Debits]: Static authorization pointers (`ndebit1...`) for direct, secure payment requests between parties via key-based identity and event-based authorization flows."
5. Contribution rule: "**Implementation First**: New specifications should demonstrate working implementations."

# Open questions

- Is anyone shipping `nmanage1...` / kind 21003 (Manage)? README ecosystem table shows zero adopters with "Manage" feature; only the spec doc exists.
- Why does the apps.html page link to `github.com/shocknet/CLINK/tree/main/ClinkSDK` when no such directory exists in the canonical repo? The SDK lives at `shocknet/ClinkSDK` (separate repo) and `npmjs.com/package/@shocknet/clink-sdk`.
- No version tags / spec versioning — how do implementations declare compatibility? Does Stacker News pinning `@shocknet/clink-sdk ^1.4.0` correspond to a specific spec snapshot?

# Why this source matters

This is the canonical, authoritative roster of who implements CLINK and which features. Every other implementation source must be triangulated against this README's "Ecosystem" table. It also defines the only public versioning surface for the spec (none — there are no spec version tags, just `main`).
