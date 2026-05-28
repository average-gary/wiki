---
title: "Cashu-Address: Cashu Mints as Better Lightning-Address Custodians"
type: article
source: https://www.nobsbitcoin.com/introducing-cashu-address/
fetched: 2026-05-28
published: 2024-02
confidence: medium
tags: [cashu-address, lightning-address, npubcash, deployment-pattern]
summary: Origin write-up of the cashu-address protocol — a LNURL-pay endpoint that resolves to a Cashu mint, locking received tokens to the user's nostr pubkey. Direct precursor to npub.cash. Authored by lightning-digital-entertainment.
---

# Cashu-Address — pattern overview

Originated under the `lightning-digital-entertainment` org (Feb 2024), later moved/aliased under `cashubtc` as `npubcash-server` and integrated NIP-46.

## Architecture

```
LN payer  →  cashu-address server  →  external Cashu mint
   |              |                          |
   |              | LUD-06 step-1            |
   |              | step-2 → asks mint       |
   |              |   for NUT-04 quote       |
   |              | returns BOLT11 to payer  |
   |              ↓                          |
   |        payer pays BOLT11                |
   |              |                          |
   |              | claims tokens via        |
   |              | NUT-04 mint endpoint     |
   |              | stores them locked       |
   |              | to user's npub via NIP-98|
```

Any nostr `npub` becomes a valid Lightning Address: `npub1…@cashu-address.com` (later `npub1…@npub.cash`). No signup. Token claim gated by NIP-98 HTTP auth (user proves nsec ownership).

## Trust model shift

Standard Lightning Address custody:
- LNURL provider holds funds; user's only recourse is "withdraw to my own LN node"

Cashu-Address custody:
- LNURL provider holds **only the LNURL routing**; tokens are held by the **mint**
- User can rotate **either** custodian: switch which mint the bridge points at, or switch which bridge resolves their npub

Net: custody risk concentrates at the mint (where it would have been at the LNURL provider anyway), and the LNURL provider becomes a **stateless router**.

## Components

- **cashu-address server** — Node.js/TypeScript, the LNURL+claim API
- **app.cashu-address.com / app.npub.cash** — React/TypeScript SPA on Vite + Tailwind, hosted on Netlify (zero backend in browser; calls cashu-address API directly)
- **Mint** — any NUT-compliant; publicly run mints rotate

## Why this matters for the CDK + LDK + LNURL design

This is the **production-validated pattern** for serving Lightning Addresses on top of a Cashu mint. The CDK + LDK Node stack would slot in as the mint, and either npubcash-server (already cashubtc-org maintained) or a custom equivalent would slot in as the bridge.

The bridge architecture answers the open question "does CDK ship LNURL?" with: **no, and it doesn't need to**. Run npubcash-server (or fork it) pointed at your `cdk-mintd` + `cdk-ldk-node` deployment.

## See also

- [[../repos/2026-05-28-cashubtc-npubcash-server.md|npubcash-server]] — the implementation
- [[../repos/2026-05-28-cashubtc-cdk-wallet-lnurl.md|CDK wallet LNURL]] — wallet-side complement
