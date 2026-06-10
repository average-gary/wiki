---
title: CLINK Protocol — Wiki
type: wiki-root
created: 2026-06-09
updated: 2026-06-10
scope: hub-topic
---

# CLINK Protocol — Wiki

Topic wiki for **CLINK** (Common Lightning Interface for Nostr Keys) — a ShockNet-led set of Nostr-native standards for Lightning Network interactions. Covers the three primitives (Offers, Debits, Manage), how CLINK uses Nostr identifiers + signed events + NIP-44 encryption to replace LNURL's HTTPS dependency, and how it relates to BOLT12, NWC, zaps, and Lightning Address.

## Layout

- `wiki/concepts/` — atomic concept articles (8)
- `wiki/topics/` — synthesizing topic articles (3)
- `wiki/reference/` — link index
- `raw/` — ingested source material with provenance (23 files)
- `output/` — generated artifacts (none yet)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: **23** (15 articles, 8 repos, 0 papers)
- Articles compiled: **12** wiki articles (8 concepts + 3 topics + 1 reference)
- Outputs: 0
- Theses: 5 candidate theses surfaced
- Last research session: 2026-06-09 `--deep --plan` (5 paths × 8 agents)

## TL;DR

- **CLINK = Common Lightning Interface for Nostr Keys**, a ShockNet open spec ([github.com/shocknet/CLINK](https://github.com/shocknet/CLINK), public-domain, founded 2025-05-05).
- **Three primitives, three event kinds, three bech32 HRPs**: Offers (kind **21001**, `noffer1...`), Debits (kind **21002**, `ndebit1...`), Manage (kind **21003**, `nmanage1...`).
- **All wire-content is NIP-44 encrypted** (Cure53-audited Dec 2023). NIP-04 is not used.
- **Replaces LNURL-pay** ("Nostr-native successor"), **rejects NWC's pre-shared-secret model**, **swipes at BOLT12's onion-message dependence** without naming it.
- **Pattern shipped in production 8 months before the spec** (ShockNet's `bridgelet` repo, Sept 2024, "LNURL and NIP-05 service powered by Nostr Offers"). The spec is a formalization, not an invention.
- **Reference stack**: Lightning.Pub (server) + ShockWallet (wallet) + ClinkSDK (JS only; no Rust/Python/Swift/Kotlin).
- **One confirmed third-party production adopter**: Stacker News (CLINK send + recv shipped Sept 2025; ~9 months runtime).
- **Manage is the least-shipped primitive** — only ShockWallet ships client-side support; no service-side adopter advertises Manage.
- **Single-vendor governance**: 38/40 spec commits by `shocknet-justin`; project npub = ShockNet npub = Justin's npub. VC-backed (Wolf VC, Ride Wave, Fulgur), not in any Bitcoin grant program.
- **Biggest open security gap**: Manage defines no protocol-level revocation, time-bound, or expiry. Doesn't use NIP-26 and doesn't justify the rejection.

## Start here

- [[wiki/concepts/clink-overview.md|CLINK overview]] — orient
- [[wiki/concepts/clink-offers.md|Offers]] / [[wiki/concepts/clink-debits.md|Debits]] / [[wiki/concepts/clink-manage.md|Manage]] — three primitives
- [[wiki/concepts/clink-wire-format.md|Wire format reference]] — implementer cheat sheet
- [[wiki/topics/clink-vs-alternatives.md|CLINK vs LNURL / BOLT12 / NWC / Zaps]] — load-bearing comparison
- [[wiki/topics/clink-security-and-trust.md|Security and trust model]] — threat model
- [[wiki/concepts/clink-discovery-and-nip05.md|Discovery — NIP-05, HTTPS, NymRank]] — bootstrap-trust caveat
- [[wiki/concepts/clink-implementations.md|Implementations]] — adoption surface
- [[wiki/concepts/clink-origin-and-stewardship.md|Origin and stewardship]] — who runs CLINK
- [[wiki/topics/clink-roadmap-signals.md|Roadmap signals]] — where it's heading
- [[wiki/reference/specs-and-repos.md|Reference: specs and repos]] — comprehensive link index

## Open questions

- Does NymRank become the standardized non-HTTPS discovery transport, or will Issue #6 (Namecoin) get accepted? See [[wiki/concepts/clink-discovery-and-nip05.md|discovery]] and [[wiki/topics/clink-roadmap-signals.md|roadmap]].
- What does CLINK Manage's revocation model look like once specified? See [[wiki/concepts/clink-manage.md|Manage]] and [[wiki/topics/clink-security-and-trust.md|security]].
- Does Zeus actually implement CLINK Offers (claimed in README) or is the entry aspirational? Zeus README has zero CLINK terminology.
- Why no adoption among major Nostr clients (Damus, Amethyst, Primal, Coracle)?
- Is anyone shipping `nmanage` server-side?
- Will hold-invoices ever land as kind 21004?
- Will a non-JS SDK (Rust especially) appear?

## Adjacent wikis

- [[../cdk-ldk-lnurl/_index.md|cdk-ldk-lnurl]] — LNURL deployment via Cashu Dev Kit + LDK; CLINK is the Nostr-native alternative to that stack
- [[../ldk-server/_index.md|ldk-server]] — LDK Server daemon (gRPC); a candidate CLINK backend
- [[../fedimint/_index.md|fedimint]] — federated ecash; Nostr-touching custody patterns
