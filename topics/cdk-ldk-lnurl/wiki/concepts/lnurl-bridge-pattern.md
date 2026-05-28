---
title: "LNURL bridge pattern (LNURL in front of a Cashu mint)"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [lnurl, lightning-address, bridge, npubcash, deployment-pattern]
---

# LNURL bridge pattern

cdk-mintd ships no LNURL endpoints. Every production "user@my-mint.com" UX in the wild is delivered by a separate **bridge process** that translates LNURL flows into NUT-04 / NUT-05 calls on the mint.

## Topology

```
LN payer wallet                LNURL bridge                  cdk-mintd + cdk-ldk-node
        |                             |                                    |
        | GET /.well-known/lnurlp/<u> |                                    |
        |---------------------------->|                                    |
        |  LUD-06 step-1 response     |                                    |
        |<----------------------------|                                    |
        | GET callback?amount=...     | POST /v1/mint/quote/bolt11         |
        |---------------------------->|----------------------------------->|
        |                             |  { quote, request: bolt11, ... }   |
        |                             |<-----------------------------------|
        |  { pr: bolt11, verify, ...} |                                    |
        |<----------------------------|                                    |
        | pays bolt11                 |     ...payer pays via LN...        |
        |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>|
        |                             | POST /v1/mint/bolt11               |
        |                             |  (with blinded outputs)            |
        |                             |----------------------------------->|
        |                             | blind sigs                         |
        |                             |<-----------------------------------|
        | (later: claim tokens via NIP-98 auth)                            |
```

## Reference implementations

| Bridge | Stack | Notes |
|---|---|---|
| [[../../raw/repos/2026-05-28-cashubtc-npubcash-server.md|npubcash-server]] | TypeScript / Node.js, Docker | Powers npub.cash; cashubtc-org maintained; the canonical OSS implementation |
| ZEUS `zeuspay` | Closed/custom; ships with ZEUS wallet | Vendor-managed; demonstrates the same pattern bundled with a wallet |
| LNbits + Cashu extension | Python (LNbits) + LNURLp extension + Cashu mint extension | Different topology — LNURL and a small mint share a host inside LNbits |

## Address style choices

1. **One address per user** — `alice@mint.com`. Bridge maintains a user table mapping username → owner pubkey/email.
2. **One address for the mint, payer-supplied tag** — `mint+<npub>@mint.com`. Bridge strips `+<tag>` and uses it as the owner identity. This is the npub.cash idiom — no signup required.

Tag-suffix style (LUD-16 supports `+tag` suffix natively) is the lower-friction option for a public-facing mint.

## Spec dependencies

The bridge must implement:

- [[../../raw/papers/2026-05-28-lnurl-lud-06-payrequest.md|LUD-06]] — LNURL-pay step-1 + step-2
- [[../../raw/papers/2026-05-28-lnurl-lud-16-lightning-address.md|LUD-16]] — Lightning Address resolution (`.well-known/lnurlp/<u>`)
- [[../../raw/papers/2026-05-28-lnurl-lud-21-verify.md|LUD-21]] — strongly recommended; provides preimage proof of receipt for ecash flows
- LUD-12 (comments) — optional; useful for correlation IDs

For LNURL-withdraw (redeem ecash to LN):

- [[../../raw/papers/2026-05-28-lnurl-lud-03-withdraw.md|LUD-03]] — atomic k1 enforcement is critical
- LUD-04 LNURL-auth — recommended to gate withdraw before display

## The description_hash binding problem

LUD-06 mandates `sha256(metadata_string) == bolt11.description_hash`. cdk-mintd's NUT-04 quote endpoint accepts an optional `description` (sets BOLT11 description text) but **does not** let the caller supply `description_hash` directly. So a bridge has two options:

1. **Bridge-side LN node** — bridge runs its own LDK Node, generates the BOLT11 with the right `description_hash`, then funds the bridge's mint balance via LN→mint round-trips later. Heavier; bridge is now custodial.
2. **Mint-side BOLT11 generation, weak metadata binding** — bridge passes `description_hash` to the mint via a NUT extension or sets only `description` and skips strict LUD-06 verification. Some wallets will reject; some will accept.

The npub.cash pattern uses option 1: **the bridge holds the LN node**, the mint holds the tokens. This means in practice CDK + LDK + LNURL on a single host is **two LN nodes**: cdk-ldk-node (the mint's reserve) and the bridge's LN node (LNURL-facing).

A simpler design is option 1 with **only one LN node**: the bridge IS the LN node, and the mint backend is `cdk-fake-wallet` or `cdk-payment-processor` that talks to the bridge. But that's a different architecture from "deploying LNURL using CDK's LDK Node."

A third option, deferred for spec work: extend NUT-04 to accept `description_hash` directly. No upstream proposal as of 2026-05-28.

See [[lnurl-cdk-design-tensions.md|design tensions]] for the full discussion.

## See also

- [[cdk-architecture-and-backends.md|CDK architecture]]
- [[lnurl-cdk-design-tensions.md|Design tensions]]
- [[nwc-vs-lnurl.md|NWC as alternative]]
- [[../topics/deployment-playbook.md|Deployment playbook]]
