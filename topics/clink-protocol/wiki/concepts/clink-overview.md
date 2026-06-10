---
title: CLINK overview
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/repos/2026-06-09-spec-primitives-clink-repo-overview.md
  - raw/articles/2026-06-09-spec-primitives-clinkme-dev-portal.md
  - raw/repos/2026-06-09-implementations-shocknet-clink.md
  - raw/repos/2026-06-09-origin-shocknet-clink-repo.md
---

# CLINK overview

**CLINK** = "Common Lightning Interface for Nostr Keys" — a set of three Nostr-native specifications for Lightning Network interactions, maintained at [github.com/shocknet/CLINK](https://github.com/shocknet/CLINK) and documented at [clinkme.dev](https://clinkme.dev). All specifications are public domain.

## What CLINK is

A protocol bundle that lets Lightning wallets and services interact directly through Nostr — using Nostr key identities, NIP-44-encrypted ephemeral events, and standard relay infrastructure — instead of through HTTPS endpoints (LNURL) or in-protocol Lightning onion messages (BOLT12).

## The three primitives

| Primitive | Event kind | Bech32 HRP | Purpose | Closest analog |
|-----------|-----------|-----------|---------|----------------|
| [[clink-offers.md|Offers]]  | **21001** | `noffer1...`  | Static reusable payment codes; request/response invoice flow | LNURL-pay (LUD-06) / BOLT12 offers |
| [[clink-debits.md|Debits]]  | **21002** | `ndebit1...`  | Payment authorization pointers (one-shot, recurring budgets, or unrestricted) | LNURL-withdraw + NWC `pay_invoice` |
| [[clink-manage.md|Manage]]  | **21003** | `nmanage1...` | Delegated CRUD over wallet-server resources (currently only `offer`) | NIP-26 delegation (rejected by CLINK), OAuth-style scopes |

All three event kinds sit in Nostr's **ephemeral** range (20000-29999) — relays are not expected to retain them. All three carry a mandatory `["clink_version", "1"]` tag and use **NIP-44** encryption end-to-end.

## Wire shape (universal across primitives)

- Bech32 pointer encodes a TLV blob: `(service_pubkey, relay_url, opaque_pointer_id [, primitive-specific TLVs])`.
- Request: ephemeral Nostr event of the appropriate kind, content = NIP-44-encrypted JSON, tagged `["p", <recipient_pubkey>]` and `["clink_version", "1"]`.
- Response: same kind back, tagged additionally `["e", <request_event_id>]` to bind the response to its request.
- Replay protection: 30-second `created_at` delta (Debits and Manage; Offers does not specify a delta).

See [[clink-wire-format.md|wire format reference]] for full TLV tables and JSON schemas.

## Positioning

CLINK is explicitly framed as a **Nostr-native successor to LNURL-pay** and a critical alternative to BOLT12. From the Offers spec:

> "Current Lightning payment flows either require maintaining HTTP endpoints, leading to unnecessary complexity and centralization risks in self-hosted scenarios, or depend on slow and unreliable P2P transport mechanisms."

The README distinguishes CLINK from NWC (NIP-47):

> "Where NWC is deferential to LNURL and scoped for a specific task, CLINK is fundamentally committed to Nostr as the foundation for the next generation of decentralized Lightning applications."

For a structured comparison, see [[../topics/clink-vs-alternatives.md|CLINK vs LNURL / BOLT12 / NWC / Zaps]].

## Origin and stewardship

- **Founded**: 2025-05-05 (initial spec commit by `shocknet-justin`).
- **Pattern predates spec**: ShockNet's `bridgelet` repo (2024-09-08) shipped "LNURL and NIP-05 service powered by Nostr Offers" eight months before the CLINK spec was written. CLINK is a formalization of an already-shipping pattern.
- **Stewardship**: single-vendor open spec, maintainer-led. 38/40 commits to the spec repo are by `shocknet-justin` (Justin, ShockNet founder). Hatim Boufnichel (`boufni95`) is the second core contributor (primary author of ClinkSDK, clink-demo).
- **Funding**: VC-backed (Wolf VC, Ride Wave Ventures, Fulgur Ventures); GitHub Sponsors as the only on-repo channel. **Not** in any visible Bitcoin grant program (OpenSats, HRF, Spiral, Brink) as of 2026-06-09.
- **Governance**: stated five-step "Discussion → Implementation → PR → Review → Merge" process; operationally maintainer-led. The Nostr key on clinkme.dev/contact.html is the same npub as ShockNet's, i.e. CLINK speaks with the company's voice.

See [[../concepts/clink-origin-and-stewardship.md|origin and stewardship]] for the full timeline and governance signals.

## Adoption snapshot (2026-06-09)

- **Reference server**: [[clink-implementations.md|Lightning.Pub]] (ShockNet, AGPL).
- **Reference wallet**: ShockWallet / `wallet2` (ShockNet, AGPL; PWA + Android APK + iOS TestFlight). Only known implementation of all three primitives client-side.
- **JS SDK**: [`@shocknet/clink-sdk`](https://www.npmjs.com/package/@shocknet/clink-sdk) (no Rust/Python/Swift/Kotlin equivalents).
- **Confirmed third-party production adopter**: Stacker News — CLINK is one of 10 wallet protocols, with both send (`ndebit`) and recv (`noffer`) shipped Sept 2025.
- **Listed in ecosystem table** (verification gap): Zeus Wallet (Offers), TakeMySats (Offers), bxrd.app (Debit-zaps).
- **Not adopting** as of 2026-06-09: Alby, Mutiny, Primal, Damus, Amethyst, Coracle. CLINK has effectively zero adoption among major Nostr clients beyond the ShockNet stack and Stacker News.

See [[clink-implementations.md|implementations]] for details.

## Where the spec is silent

CLINK consciously narrows scope. **Not** in the spec:
- Hold invoices (BOLT11 add_index / `holdinvoice`)
- Channel/peer/routing management (no analog to NWC's `get_info` or LNDg-style RPCs)
- Splices over CLINK
- Multi-vendor RFC process
- Key rotation / recovery primitives
- Revocation primitives for Manage delegations
- Proof-of-payment beyond what BOLT11 preimage already provides

ShockNet's adjacent repos (`NymRank`, `SanctumDK`, `BXRD.app`) suggest the *de facto* CLINK roadmap is: discovery hardening (NymRank replaces HTTPS for NIP-05 lookup), wallet UX (BXRD), and delegated-signing convergence (Sanctum + Manage). See [[../topics/clink-roadmap-signals.md|roadmap signals]].

## See also

- [[clink-offers.md]] — Offers primitive deep dive
- [[clink-debits.md]] — Debits primitive deep dive
- [[clink-manage.md]] — Manage primitive deep dive
- [[clink-wire-format.md]] — wire format reference
- [[clink-origin-and-stewardship.md]] — who runs CLINK and how
- [[../topics/clink-vs-alternatives.md]] — comparison with LNURL / BOLT12 / NWC / Zaps
- [[../topics/clink-security-and-trust.md]] — threat model
- [[../topics/clink-roadmap-signals.md]] — where CLINK is heading
- [[clink-implementations.md]] — adoption surface
- [[../reference/specs-and-repos.md]] — link index
