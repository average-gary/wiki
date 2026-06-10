---
title: ClinkSDK and Bridgelet — JS SDK + LNURL-bridge reference implementations
source: https://github.com/shocknet/ClinkSDK
type: repo
ingested: 2026-06-09
path: implementations
quality: 4
credibility: high
tags: [clink, implementation, sdk, bridgelet, npm, typescript, lnurl-bridge]
---

# ClinkSDK and Bridgelet

## Source overview

Two adjacent ShockNet repos that together form CLINK's JavaScript surface area:

- **ClinkSDK** (`github.com/shocknet/ClinkSDK`, npm `@shocknet/clink-sdk`) — the canonical JS implementation library used by ShockWallet, Stacker News, and any third-party JS client integrating CLINK.
- **Bridgelet** (`github.com/shocknet/bridgelet`) — a minimalist LNURL-pay / Lightning-Address bridge that translates legacy LNURL flows into CLINK Offers, intended as a fork-to-customize starter rather than a deployment binary.

Path-3 research could not reach `registry.npmjs.org` directly from the sandboxed environment, so SDK surface details were triangulated via Stacker News's `package.json` pin (`^1.4.0`) and import statements in SN's wallet code.

## Key findings

- **Public SDK surface (extracted from Stacker News's CLINK send/recv code paths)**:
  - `decodeBech32` — TLV unpacker for `noffer1...` / `ndebit1...` / `nmanage1...`
  - `generateSecretKey` — payer-side key generation; supports the spec's "ephemeral payer key" recommendation
  - `newNdebitPaymentRequest` — builds an encrypted kind-21002 event
  - `SendNdebitRequest`, `SendNofferRequest` — wire-level send helpers
  - `SimplePool` — relay-pool wrapper (likely re-export from `nostr-tools`)
  - `OfferPriceType` — enum mirroring spec TLV-3 pricing types (0 fixed / 1 variable / 2 spontaneous)
- **SDK feature gap — Manage NOT advertised**: the CLINK README ecosystem-table entry for ClinkSDK lists only Offers + Debits. No `SendNmanageRequest` or equivalent Manage helper has been observed in third-party imports. This is consistent with path-3's broader finding that Manage is the least-shipped of the three primitives.
- **Documentation drift**: clinkme.dev/apps.html links to `github.com/shocknet/CLINK/tree/main/ClinkSDK` (404). The real path is `github.com/shocknet/ClinkSDK`. Suggests the SDK was extracted from a monorepo subdirectory after the apps page was last updated.
- **SDK packaging quality issue**: Stacker News commit `a2f653c` (2026-05-27) opened an upstream PR fixing a `rimraf` packaging issue, suggesting the SDK has rough edges below the public-API layer.
- **Bridgelet**: TypeScript/Bun, AGPL-3.0, 29 commits, 3 stars, no releases. Frames itself as fork-to-customize. Implements LNURL-pay + Lightning Address by terminating LNURL on one side and emitting CLINK Offers (kind 21001) on the other.
- **Bridgelet zap path**: `src/handlers/clinkProcessor.ts` handles NIP-57 zaps with graceful degradation when the receiving Offer doesn't advertise zap support.
- **Language ceiling**: ClinkSDK is JS/TS-only. No Rust, Python, Go, Swift, or Kotlin SDKs exist. Combined with the spec's heavy reliance on `nostr-tools`-style relay pools and bech32-TLV decoding, this is a real adoption ceiling — wallets in non-JS stacks would need to roll their own primitives.

## Cited identifiers / keys

- npm package: `@shocknet/clink-sdk`
- Stacker News pin: `^1.4.0`
- ClinkSDK repo: `github.com/shocknet/ClinkSDK`
- Bridgelet repo: `github.com/shocknet/bridgelet`
- Bridgelet license: AGPL-3.0
- Stacker News upstream PR commit: `a2f653c` (2026-05-27)
- Documented (broken) link in apps.html: `github.com/shocknet/CLINK/tree/main/ClinkSDK`

## Direct quotes

(Quotes were unavailable to path-3 due to npm registry access being blocked; the bullet content above is reconstructed from Stacker News import statements and the CLINK README ecosystem table. Future research should fetch the ClinkSDK README directly via gh CLI to populate verbatim quotes.)

## Open questions

- Full public API surface of `@shocknet/clink-sdk` 1.x — is Manage supported or absent?
- Are there other in-flight non-JS SDK efforts? (None visible on github.com/shocknet as of 2026-06-09.)
- Does Bridgelet support LNURL-withdraw, or only LNURL-pay + Lightning Address?
- What is the Bridgelet operational deployment story — is anyone running it in production?

## Why this source matters

ClinkSDK is the load-bearing dependency for *every* known JS-based CLINK adopter (ShockWallet, Stacker News send + recv). Its public API defines what's practically callable from CLINK clients today, and its language-monoculture is the most obvious adoption ceiling. Bridgelet is the canonical worked example of how CLINK Offers can replace LNURL endpoints, and it's relevant to both the comparison-landscape path (CLINK vs LNURL) and the implementations path.

This file was rescued from path-3's report after the in-agent Write tool returned permission-denied mid-run on the 5th file.
