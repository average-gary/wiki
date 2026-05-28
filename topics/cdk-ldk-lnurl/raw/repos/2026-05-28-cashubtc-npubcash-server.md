---
title: "cashubtc/npubcash-server — canonical LNURL/Lightning-Address bridge for Cashu"
type: repo
source: https://github.com/cashubtc/npubcash-server
fetched: 2026-05-28
confidence: high
tags: [lnurl, lightning-address, cashu-address, deployment, sidecar]
summary: TypeScript/Node.js backend powering npub.cash. Receives LNURL-pay / Lightning-Address payments, asks an external Cashu mint for a BOLT11 via NUT-04, claims the resulting tokens, holds them locked to the user's nostr pubkey until claim. The reference implementation of the LNURL-in-front-of-mint pattern.
---

# npubcash-server — LNURL bridge for Cashu mints

Maintained by `@egge21m` under the `cashubtc` GitHub org. Live backend powering [npub.cash](https://npub.cash). Companion frontend SPA: [cashubtc/npubcash-website](https://github.com/cashubtc/npubcash-website).

## Pattern

```
LN payer wallet                npubcash-server                Cashu mint (cdk-mintd / nutshell)
        |                             |                                    |
        | GET /.well-known/lnurlp/<u> |                                    |
        |---------------------------->|                                    |
        |  LUD-06 step-1 response     |                                    |
        |<----------------------------|                                    |
        | GET callback?amount=...     |                                    |
        |---------------------------->| POST /v1/mint/quote/bolt11         |
        |                             |----------------------------------->|
        |                             |  { quote, request: bolt11, ... }   |
        |                             |<-----------------------------------|
        |  { pr: bolt11, ... }        |                                    |
        |<----------------------------|                                    |
        | pays bolt11                 |                                    |
        |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>|
        |                             |  POST /v1/mint/bolt11 (claim with  |
        |                             |  blinded outputs)                  |
        |                             |----------------------------------->|
        |                             |  blind sigs                        |
        |                             |<-----------------------------------|
        |                             | stores tokens locked to npub       |
```

## Stack

- TypeScript / Node.js
- Dockerfile + `compose.yaml`
- Vitest tests
- Env-file config
- Mint is **swappable / external** — speaks the standard NUT wire protocol; works with cdk-mintd or nutshell

## Trust model

- Users identified by nostr `npub` — no signup. Address: `npub1…@npub.cash`.
- Custody risk shifts from the LNURL provider (npub.cash) to the **mint**. Users can move custodian by pointing a different `npub.cash`-style server at a different mint.
- NIP-98 auth gates the token-claim API (user proves they hold the corresponding nsec).

## Roadmap signals (worth watching)

- README mentions removing the Blink API integration → confirms historical reliance on Blink as one funding/LN-side path
- Plans to integrate **NUT-10** (P2PK / HTLC) once adoption matures — would let the server issue tokens directly P2PK-locked to the user's npub, removing the "stored on server" custody window

## Why this is the canonical reference

This is the only widely deployed OSS implementation of a LNURL-Address-in-front-of-Cashu bridge under the `cashubtc` org. Any new operator wanting a `user@my-mint.com` UX in front of a `cdk-mintd` + `cdk-ldk-node` deployment will either:

1. Run npubcash-server pointed at their mint, or
2. Re-implement its pattern (a few hundred lines of HTTP routing + NUT-04 client calls)

See also the [Cashu-Address protocol announcement](https://www.nobsbitcoin.com/introducing-cashu-address/) describing this pattern.
