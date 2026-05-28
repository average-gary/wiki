---
title: "LUD-03: withdrawRequest (LNURL-withdraw)"
type: paper
source: https://github.com/lnurl/luds/blob/luds/03.md
fetched: 2026-05-28
confidence: high
tags: [lnurl, lud-03, lnurl-withdraw, pull-payments, spec]
summary: "Pull" payments — service initiates LN payment after wallet supplies an invoice. k1 is a bearer token with no built-in replay protection. Implementer must enforce single-use.
---

# LUD-03 — withdrawRequest

## Step 1 response

```json
{
  "tag": "withdrawRequest",
  "callback": "https://service.com/lnurl-withdraw/callback/abc",
  "k1": "<32-byte-hex>",
  "defaultDescription": "Withdraw from MyMint",
  "minWithdrawable": 1000,
  "maxWithdrawable": 100000000
}
```

## Step 2 callback

```
GET <callback><?|&>k1=<k1>&pr=<bolt11>
```

`pr` is **wallet-generated** (the wallet acts as receiver and creates the invoice). LNURL-withdraw is a pull flow — the LN service pays the invoice asynchronously.

## Final response

```json
{"status":"OK"}
```
or
```json
{"status":"ERROR","reason":"..."}
```

## Security caveats (spec text)

> Service will withdraw funds to anyone who can provide a valid ephemeral k1.

The spec acknowledges:

- No mandatory authentication between QR display and withdrawal processing
- No spec-level replay protection beyond k1 — implementer must invalidate atomically
- No expiry timestamp on k1
- No double-spend prevention — implementer responsibility
- No rate-limiting requirement

Suggested mitigation in the spec is "MAY require LNURL-auth" (LUD-04). A naive cdk-mintd LNURL-withdraw layer that doesn't burn k1 atomically is a replay footgun.

## Use in CDK + LDK + LNURL deployment

If exposing LNURL-withdraw for "redeem ecash to LN":

1. Bridge generates `k1`, stores `(k1, max_withdraw, expiry, ecash_token_hash)` in a single transaction
2. Returns step-1 response with `callback` pointing at bridge
3. On callback: validate `k1` exists + not consumed + within window
4. Atomically: mark `k1` consumed, call cdk-mintd `POST /v1/melt/quote/bolt11` with `pr`, then `POST /v1/melt/bolt11` to settle, return `{status:"OK"}`
5. If atomic step fails or the melt errors, leave `k1` consumed but record refund-needed

For a small mint, this is **substantially simpler than LNURL-pay** because the wallet provides the invoice — no description_hash binding gymnastics.

## See also

- [[2026-05-28-lnurl-lud-06-payrequest.md|LUD-06 payRequest]] — the inverse (push) flow
- LUD-08 — fast variant inlining step-1 fields as query params (app-to-app only, not for QR)
