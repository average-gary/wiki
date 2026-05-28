---
title: "LUD-16: Lightning Address"
type: paper
source: https://github.com/lnurl/luds/blob/luds/16.md
fetched: 2026-05-28
confidence: high
tags: [lnurl, lud-16, lightning-address, spec]
summary: user@domain syntax that resolves to a LUD-06 LNURL-pay endpoint via .well-known/lnurlp/<username>. Authored by akumaigorodski, andreneves (ZBD), fiatjaf.
---

# LUD-16 — Lightning Address

## Format

`<username>@<domain>` where:

- `username` — `a-z0-9-_.` (lowercase only) plus `+` for tag suffixes
- `domain` — standard DNS

## Resolution

```
GET https://<domain>/.well-known/lnurlp/<username>
```

(HTTP for `.onion` domains.) Response **mirrors LUD-06 step-1 exactly** — Lightning Address is sugar over LNURL-pay.

## Metadata requirements

LUD-16 metadata MUST include `text/identifier` (and `text/email` if it's an actual email).

## Tag suffix idiom

`<user>+<tag>@<domain>` — server strips the tag, may include a `text/tag` metadata entry with the tag value. Useful for per-user deposit accounts under one address (a mint could issue `npub1abc+kid_birthday@mint.com` to scope a payment).

## Authors

Co-authored by:
- **akumaigorodski** (lnurl-rfc co-creator)
- **andreneves** (ZBD founder; original Lightning Address proposal)
- **fiatjaf** (LNURL creator)

## Security model

The trust anchor is **the TLS certificate of `<domain>`**. A DNS hijack of `mint.example.com` lets an attacker substitute their own LNURL-pay endpoint and divert deposits — see [[2026-05-28-lnurl-lud-06-payrequest.md|LUD-06]] § Security limitations. Mitigations:

- Pin the linking key via LUD-18 `payerData.auth` for repeat depositors
- Offer BOLT12 offers as an alternative (signer pubkey is part of the offer)
- Out-of-band fingerprint distribution

## Why widely adopted vs BOLT12

Lightning Address pre-dates working BOLT12 wallet support by years. Adoption: Wallet of Satoshi, Alby, Phoenix, Strike, Coinos, Mutiny, ZEUS, Bitkit. CDK's wallet supports sending to Lightning Addresses via `WalletTrait::melt_lightning_address_quote`.

## Usage for CDK mints

The dominant deployment pattern: the operator brings an LNURL bridge (npubcash-server / custom Axum) that serves `/.well-known/lnurlp/<u>` and translates to NUT-04 mint-quote calls on cdk-mintd.

Two address-style choices for a Cashu mint:

1. **One address per user** (`alice@mint.com`) — bridge maintains user→token mapping
2. **One address for the mint, payer-supplied tags** (`mint+<npub>@mint.com`) — npub.cash style; user identity is in the suffix

ZEUS's `zeuspay` and `npub.cash` use variants of the second pattern.
