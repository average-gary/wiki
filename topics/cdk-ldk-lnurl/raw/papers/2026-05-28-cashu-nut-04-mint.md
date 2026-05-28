---
title: "NUT-04: Mint tokens"
type: paper
source: https://github.com/cashubtc/nuts/blob/main/04.md
fetched: 2026-05-28
confidence: high
tags: [cashu, nut-04, mint-quote, bolt11, spec]
summary: Canonical Cashu deposit flow. Two-step quote → mint with blinded outputs. Method-agnostic; bolt11-specific behavior in NUT-23.
---

# NUT-04 — Mint tokens

## Flow

```
POST /v1/mint/quote/{method}     →  { quote, request, unit, ... }
(user pays `request`, e.g. BOLT11)
GET  /v1/mint/quote/{method}/{quote_id}  →  { quote, request, state, ... }
POST /v1/mint/{method}            (with blinded outputs B_)  →  { signatures C_ }
```

## Request shape

`POST /v1/mint/quote/bolt11` body:
```json
{ "amount": 21000, "unit": "sat", "description": "Optional" }
```

Response:
```json
{
  "quote": "<random_id>",
  "request": "lnbc210u1p...",
  "unit": "sat",
  "state": "UNPAID",
  "expiry": 1748400000
}
```

## Method-agnostic by design

NUT-04 doesn't dictate the payment method. Method-specific behavior:
- **NUT-23** — BOLT11 (the historical default)
- **NUT-25** — BOLT12 offers
- **NUT-30** — onchain

`{method}` in the path is the same identifier (`bolt11`, `bolt12`, `onchain`).

## Quote ID secrecy

`quote_id` MUST be unique/random and **kept secret** between user and mint to prevent front-running (an attacker who learns quote_id before the user's pay-and-redeem could race-claim with their own blinded outputs).

## State machine

`UNPAID → PENDING → PAID` (mint-side observation of the underlying LN/onchain payment).

## NUT-20 — pubkey-locked minting

A separate NUT lets the quote be locked to a payer pubkey, blocking any non-owner from claiming even if `quote_id` leaks. Very useful for LNURL bridges where the bridge holds quote IDs in its database.

## Relationship to LNURL-pay

LNURL-pay and NUT-04 are **sibling abstractions** over BOLT11, not competitors:

- LNURL-pay: `wallet → service → service-LN-node-issued-bolt11 → wallet pays`
- NUT-04: `wallet → mint → mint-LN-backend-issued-bolt11 → wallet pays → wallet redeems for tokens`

A LNURL-bridge-in-front-of-Cashu-mint glues them: the bridge's LNURL-pay callback internally creates a NUT-04 quote on the mint and returns its `request` BOLT11 to the LNURL payer. The bridge then redeems on the user's behalf when LN settles.

## See also

- [[2026-05-28-cashu-nut-05-melt.md|NUT-05 melt]] — outbound mirror
