---
title: "LUD-21: verify endpoint for LNURL-pay"
type: paper
source: https://github.com/lnurl/luds/blob/luds/21.md
fetched: 2026-05-28
confidence: high
tags: [lnurl, lud-21, verify, preimage, ecash-critical]
summary: Optional verify URL added to LUD-06 step-2 response. Lets payer poll for cryptographic settlement proof (preimage). Mandatory reading for any Cashu mint integrating outbound LNURL-pay.
---

# LUD-21 — `verify` (LNURL-pay settlement proof)

## What it adds

LUD-06 step-2 response gains optional field `verify`:

```json
{
  "pr": "lnbc...",
  "routes": [],
  "verify": "https://service.com/lnurl-pay/verify/abc"
}
```

## Polling

```
GET <verify-url>
```

Returns one of:

**Pending**:
```json
{"status":"OK","settled":false,"preimage":null,"pr":"lnbc..."}
```

**Settled**:
```json
{"status":"OK","settled":true,"preimage":"<hex>","pr":"lnbc..."}
```

**Error**:
```json
{"status":"ERROR","reason":"Not found"}
```

## Why it matters for ecash

After paying an LNURL-pay invoice, a Cashu wallet (or a mint acting as an LNURL forwarder) needs **cryptographic proof of settlement** — the preimage — before issuing or accepting tokens. Without LUD-21:

- Payer can only ask their own LN node "did this invoice get paid?", which gives a local-trust answer
- LNURL service has no standard endpoint for "show me settlement proof"
- Async flows (wallet pays, then comes back later for the token) are awkward

With LUD-21:

- Wallet polls `verify` until `settled:true`
- Verifies `sha256(preimage_bytes) == payment_hash` (where `payment_hash` is parsed from `pr`)
- Treats this as proof and proceeds to claim tokens

## Footgun

A wallet that just checks `settled: true` **without** verifying `sha256(preimage) == payment_hash` against the original `pr` is trusting the server's word. The hash check is mandatory.

## Use in CDK + LDK + LNURL deployment

- A mint exposing Lightning Address for deposits **should** advertise `verify` so depositors can prove receipt before leaving their device
- A CDK wallet sending to an external Lightning Address (via `WalletTrait::melt_lightning_address_quote`) **should** use `verify` to confirm the LN-side payment landed before considering the melt complete
- The bridge server (npubcash-server style) needs to track `payment_hash → settlement_state` and expose this — straightforward since the bridge holds the LN node
