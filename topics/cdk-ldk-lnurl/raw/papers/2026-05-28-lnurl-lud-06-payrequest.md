---
title: "LUD-06: payRequest base spec (LNURL-pay)"
type: paper
source: https://github.com/lnurl/luds/blob/luds/06.md
fetched: 2026-05-28
confidence: high
tags: [lnurl, lud-06, lnurl-pay, spec]
summary: Two-step LNURL-pay flow. Step 1 returns metadata + callback. Step 2 returns BOLT11 with description_hash binding. Wallets MUST verify sha256(metadata) == invoice.h.
---

# LUD-06 — payRequest

## Step 1 (response from initial LNURL GET)

```json
{
  "callback": "https://service.com/lnurl-pay/callback/abc",
  "maxSendable": 100000000,
  "minSendable": 1000,
  "metadata": "[[\"text/plain\",\"Pay to mint@example.com\"],[\"text/identifier\",\"mint@example.com\"]]",
  "tag": "payRequest"
}
```

- `metadata` — JSON array **serialized as a string**. First entry mandatory: `["text/plain", description]`. Optional: `text/long-desc`, `image/png;base64`, `image/jpeg;base64` (≤136,536 chars / 100KB base64). Lightning Address (LUD-16) adds `text/identifier` (and `text/email` if applicable).
- `minSendable`, `maxSendable` — millisatoshis; `minSendable >= 1000`.

## Step 2 (wallet calls callback)

```
GET <callback><?|&>amount=<milliSatoshi>
```

Response:

```json
{ "pr": "lnbc...", "routes": [] }
```

`routes` is deprecated; always `[]`.

## Verification rules (CRITICAL)

Wallets MUST:

1. Compute `sha256(utf8ByteArray(metadata_string))` and compare to the BOLT11 invoice's `h` (description_hash) tag — this binds the invoice to the advertised metadata.
2. Verify invoice amount equals user-specified amount.

If either fails, abort. No additional confirmation step — wallet pays directly after verification.

## Security limitations

- Metadata is **not signed**. The hash binds metadata-as-returned to invoice-as-returned; an attacker controlling the LNURL endpoint (e.g., DNS hijack of a `mint@example.com` Lightning Address) can return matching attacker-supplied metadata + attacker invoice and the verification still passes.
- The only trust anchor is TLS+DNS at the LNURL endpoint.
- Mitigation: out-of-band cert pinning, payer-side LNURL-auth (LUD-18 `auth`), or BOLT12 offers (which carry signer pubkey).

## Use in CDK + LDK + LNURL deployment

A mint operator exposing a Lightning Address `mint@example.com` for ecash deposits would:

1. Receive `GET /.well-known/lnurlp/mint`
2. Return LUD-06 step-1 with `callback` pointing at the operator's LNURL bridge (e.g., npubcash-server)
3. On step-2 callback, the bridge calls `POST /v1/mint/quote/bolt11` on cdk-mintd, gets a BOLT11 (with `description_hash` = sha256(metadata)), returns `{ pr, routes: [] }`
4. After payer settles, the bridge claims tokens with `POST /v1/mint/bolt11` and stores them for the user

**Important**: The mint must be willing to issue an invoice with `description_hash` set to a value the bridge supplies (rather than using its own quote description). NUT-04 / NUT-23 must allow this — current cdk-mintd accepts an optional description on the quote request, which sets the BOLT11 description but not its hash. Adapting requires either a NUT extension or invoice generation in the bridge layer (with the bridge holding the LN node) — which is why the dominant pattern is to give the **bridge** the LN node and treat the mint as a token-issuer over the bridge's own LN.
