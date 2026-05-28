---
title: "NUT-05: Melting tokens"
type: paper
source: https://github.com/cashubtc/nuts/blob/main/05.md
fetched: 2026-05-28
confidence: high
tags: [cashu, nut-05, melt-quote, bolt11, spec]
summary: Canonical Cashu withdrawal flow. Two-step melt quote → melt with proofs. Sync default; async via prefer_async. UNPAID → PENDING → PAID state machine.
---

# NUT-05 — Melting tokens

## Flow

```
POST /v1/melt/quote/{method}        →  { quote, amount, fee_reserve, state, expiry }
GET  /v1/melt/quote/{method}/{q_id} →  state polling
POST /v1/melt/{method}               (with proofs)  →  { state, payment_preimage }
```

## States

`UNPAID → PENDING → PAID`

## Sync vs async

- Default: sync — `POST /v1/melt/{method}` blocks until LN settles or fails
- `prefer_async: true` — returns immediately with `PENDING`; client polls

## Method extensions

- **NUT-23** — bolt11 (default)
- **NUT-25** — bolt12
- **NUT-30** — onchain

## Fee reserve

Quote response includes `amount` (LN amount) and `fee_reserve` (max overpayment to cover routing). Total proofs needed = `amount + fee_reserve`. Excess is returned as change.

## Relationship to LNURL-withdraw

LNURL-withdraw and NUT-05 mirror NUT-04/LNURL-pay symmetry:

- LNURL-withdraw: wallet supplies a BOLT11 it generated, service pays it
- NUT-05: wallet supplies a BOLT11 (from anyone — typically external destination), mint pays it via its LN backend

A LNURL-withdraw bridge for a Cashu mint is straightforward: the bridge accepts the wallet's `pr` (BOLT11) and proofs, calls NUT-05 melt-quote+melt on the mint with `pr`, and returns `{status:"OK"}` on settle.

## See also

- [[2026-05-28-cashu-nut-04-mint.md|NUT-04 mint]] — inbound mirror
- [[2026-05-28-lnurl-lud-03-withdraw.md|LUD-03 LNURL-withdraw]]
