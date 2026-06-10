---
title: "Reference: CLINK specs, repos, related projects"
type: reference
created: 2026-06-09
updated: 2026-06-09
---

# Reference: CLINK specs, repos, related projects

## Canonical CLINK

| Resource | URL |
|----------|-----|
| Spec repo | https://github.com/shocknet/CLINK |
| Project portal | https://clinkme.dev |
| Specs page (JS-rendered) | https://clinkme.dev/specs.html |
| Apps directory | https://clinkme.dev/apps.html |
| Contact / npub | https://clinkme.dev/contact.html |
| Discussions | https://github.com/shocknet/CLINK/discussions |
| JS SDK (npm) | https://www.npmjs.com/package/@shocknet/clink-sdk |
| JS SDK (repo) | https://github.com/shocknet/ClinkSDK |
| Open issue (Namecoin discovery) | https://github.com/shocknet/CLINK/issues/6 |

### Individual specs (raw URLs)

- Offers: `https://raw.githubusercontent.com/shocknet/clink/main/specs/clink-offers.md`
- Debits: `https://raw.githubusercontent.com/shocknet/clink/main/specs/clink-debits.md`
- Manage: `https://raw.githubusercontent.com/shocknet/clink/main/specs/clink-manage.md`

## ShockNet first-party implementations

| Repo | Role | Language | License |
|------|------|----------|---------|
| [Lightning.Pub](https://github.com/shocknet/Lightning.Pub) | Reference server (LND-backed) | TypeScript | AGPL |
| [wallet2 / ShockWallet](https://github.com/shocknet/wallet2) | Reference wallet (PWA + Android + iOS TestFlight) | TypeScript | AGPL |
| [bridgelet](https://github.com/shocknet/bridgelet) | LNURL/NIP-05 → CLINK bridge | TypeScript / Bun | AGPL-3.0 |
| [clink-demo](https://github.com/shocknet/clink-demo) | Web demo | HTML/JS | — |
| [SanctumDK](https://github.com/shocknet/SanctumDK) | Embedded remote-signer component | — | — |
| [NymRank](https://github.com/shocknet/NymRank) | Web-of-Trust namespace (NIP-05 alt) | — | — |
| [BXRD.app](https://bxrd.app) | Nostr social client w/ debit-zaps | — | — |

## ShockNet org

- Org: https://github.com/shocknet
- Homepage: https://shock.network
- Org founded: 2018-03-08
- Telegram (community): https://t.me/ShockBTC
- Telegram (Justin): https://t.me/justin_shocknet
- X / Twitter (org): @ShockBTC
- X / Twitter (Justin): @shocknet_justin
- Project npub (= ShockNet npub = Justin's npub):
  `npub1xvtwx6tduaxnn9v3y7uasskl277achgu0tu2qncmc7hdsz6y2zyqce64sa`
- Investors: Wolf VC, Ride Wave Ventures, Fulgur Ventures
- Bitcoin grants: none confirmed (not in OpenSats / HRF / Spiral / Brink)

## Confirmed third-party adopters

| Project | Role | Repo / link |
|---------|------|-------------|
| Stacker News | Production CLINK send + recv (since Sept 2025) | https://github.com/stackernews/stacker.news |

## Listed in CLINK README ecosystem table (verification varies)

| Project | Claim | Status |
|---------|-------|--------|
| Zeus Wallet | Offers (ZEUS Pay default) | https://zeusln.app — verification gap (Zeus README has no CLINK terminology) |
| TakeMySats | Offers (merchant platform) | https://takemysats.com — not code-verified |
| BXRD.app | Offers + Debits | https://bxrd.app — live site has no CLINK reference |

## Adjacent specs / related protocols

| Spec | Where | Relation to CLINK |
|------|-------|-------------------|
| NIP-05 (DNS-based identifier) | https://github.com/nostr-protocol/nips/blob/master/05.md | CLINK's default human-readable discovery hop |
| NIP-19 (bech32 entities) | https://github.com/nostr-protocol/nips/blob/master/19.md | CLINK uses NIP-19 bech32 encoding for noffer/ndebit/nmanage |
| NIP-44 (encrypted payloads) | https://github.com/nostr-protocol/nips/blob/master/44.md | Mandatory for all CLINK content payloads |
| NIP-47 (Nostr Wallet Connect) | https://github.com/nostr-protocol/nips/blob/master/47.md | Closest functional competitor; CLINK Debits rejects NWC's pre-shared-secret model |
| NIP-57 (Lightning Zaps) | https://github.com/nostr-protocol/nips/blob/master/57.md | CLINK Offers integrates with the kind 9734 zap-request format |
| NIP-59 (Gift wrap) | https://github.com/nostr-protocol/nips/blob/master/59.md | Optional metadata-privacy enhancement for CLINK Offers |
| NIP-26 (delegated event signing) | https://github.com/nostr-protocol/nips/blob/master/26.md | NOT adopted by CLINK Manage (and not justified in spec) |
| LNURL LUDs | https://github.com/lnurl/luds | LUD-06 (pay), LUD-16 (Lightning Address), LUD-21 (verify) — what CLINK Offers replaces |
| BOLT 12 | https://github.com/lightning/bolts/blob/master/12-offer-encoding.md | In-protocol rival to CLINK Offers |

## Wiki cross-references

### Concepts
- [[../concepts/clink-overview.md]]
- [[../concepts/clink-offers.md]]
- [[../concepts/clink-debits.md]]
- [[../concepts/clink-manage.md]]
- [[../concepts/clink-wire-format.md]]
- [[../concepts/clink-discovery-and-nip05.md]]
- [[../concepts/clink-implementations.md]]
- [[../concepts/clink-origin-and-stewardship.md]]

### Topics
- [[../topics/clink-vs-alternatives.md]]
- [[../topics/clink-security-and-trust.md]]
- [[../topics/clink-roadmap-signals.md]]

## Adjacent topic wikis in this hub

- [[../../../cdk-ldk-lnurl/_index.md|cdk-ldk-lnurl]] — LNURL deployment via CDK + LDK; CLINK is the Nostr-native alternative
- [[../../../ldk-server/_index.md|ldk-server]] — Lightning node binary, candidate CLINK backend
- [[../../../fedimint/_index.md|fedimint]] — Federated ecash; Nostr-touching custody patterns
