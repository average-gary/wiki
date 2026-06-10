---
title: clink-protocol — config
type: topic-config
created: 2026-06-09
---

# clink-protocol — config

## Scope

**In scope**:
- CLINK protocol (Common Lightning Interface for Nostr Keys) — clinkme.dev, github.com/shocknet/clink
- Three primitives: **Offers** (static payment codes / Nostr-published BOLT11/12-like), **Debits** (direct payment requests over Nostr), **Manage** (delegated permissions)
- Nostr transport for Lightning interactions: NIP-05 identifiers, signed events, encrypted DMs (NIP-44/NIP-04), web-of-trust
- Comparisons: CLINK vs LNURL (LUD-06/LUD-16), BOLT12 offers, NWC (Nostr Wallet Connect / NIP-47), zaps (NIP-57), Lightning Address
- Implementations: ShockNet's reference apps (Lightning.Pub, Shockwallet, etc.), third-party wallets/clients adopting CLINK
- Security/trust model: blinded paths, web-of-trust, key compromise / rotation, custody implications
- Relationship to Lightning Service Provider (LSP) flows and self-custody nodes

**Out of scope**:
- General Nostr protocol theory beyond what touches CLINK transport and identity
- General LNURL / BOLT12 deep-dives (covered in `cdk-ldk-lnurl` topic — cross-link only)
- ShockNet business / governance unrelated to the CLINK spec
- Wallet UX comparisons that don't involve CLINK adoption

## Sensitivity

Public. Hub-publishable. CLINK is an open spec; ShockNet is a public OSS organization.

## Source preferences

- **Primary**: clinkme.dev site, github.com/shocknet/clink (specs, NIP drafts), github.com/shocknet/lightning.pub, NIP source documents
- **Secondary**: ShockNet blog/docs, Nostr NIP repo (nostr-protocol/nips), interoperating wallet repos (Alby NWC, mutiny, etc.)
- **Tertiary**: practitioner blog posts, podcast/conference talks, social-media commentary from named protocol authors

## Adjacent topic wikis

- `cdk-ldk-lnurl` — LNURL deployment via Cashu+LDK; CLINK is a Nostr-native alternative to LNURL
- `ldk-server` — Lightning node binary; potential CLINK backend
- `fedimint` — federated ecash; Nostr-touching custody models
- `open-source-logos-suite` — adjacent only via Nostr-native infra patterns
