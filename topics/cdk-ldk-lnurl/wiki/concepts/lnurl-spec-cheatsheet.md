---
title: "LNURL spec cheatsheet (relevant LUDs for a Cashu mint)"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [lnurl, lud, spec, reference]
---

# LNURL spec cheatsheet

Subset of LUDs that matter for a CDK + LDK + LNURL deployment. See [[../../raw/papers/2026-05-28-lnurl-luds-index.md|the LUDs index raw]] for the full list.

## Foundation

| LUD | What |
|---|---|
| LUD-01 | Bech32 encoding (HRP `lnurl`); CORS `*` required; clients ignore HTTP status codes and parse JSON body for `{"status":"ERROR"}` |
| LUD-17 | Protocol schemes `lnurlp://`, `lnurlw://`, `lnurlc://`, `keyauth://` — replaces bech32 for app-to-app handoff |

## Pay flow (deposit to mint)

| LUD | What | Critical for ecash |
|---|---|---|
| [[../../raw/papers/2026-05-28-lnurl-lud-06-payrequest.md\|LUD-06]] | LNURL-pay base | **Yes** — `sha256(metadata) == invoice.description_hash` MUST be enforced |
| [[../../raw/papers/2026-05-28-lnurl-lud-16-lightning-address.md\|LUD-16]] | Lightning Address (`user@domain` → LUD-06) | **Yes** — UX surface |
| [[../../raw/papers/2026-05-28-lnurl-lud-21-verify.md\|LUD-21]] | Settlement-proof poll (`verify` URL → preimage) | **Yes** — proof of receipt for token issuance |
| LUD-09 | `successAction` (message / url / aes) — UX after pay | Useful — could deliver claim URL |
| LUD-12 | `comment` field on pay | Useful — payer-supplied correlation tag |
| LUD-18 | `payerData` (request name/pubkey/email/auth from payer); commits to `sha256(metadata + payerdata)` | Useful — bind depositor identity |

## Withdraw flow (redeem ecash to LN)

| LUD | What |
|---|---|
| [[../../raw/papers/2026-05-28-lnurl-lud-03-withdraw.md\|LUD-03]] | LNURL-withdraw base — k1 is a bearer token; **implementer must enforce single-use atomically** |
| LUD-04 | LNURL-auth (32-byte k1, ECDSA with linking key) — recommended to gate withdraw display |
| LUD-08 | Fast withdraw (inlined fields) — for `lightning:` URI handoff, not QR |

## Critical invariants

1. **CORS `*`** required on all LNURL endpoints (LUD-01)
2. **`sha256(metadata) == invoice.h`** must be verified by wallets — bridge must produce invoices that satisfy this (see [[lnurl-cdk-design-tensions.md|design tensions]])
3. **k1 single-use atomicity** — implementer responsibility; spec doesn't enforce
4. **`verify` preimage check** — wallet must verify `sha256(preimage) == payment_hash`, not just `settled: true`
5. **TLS+DNS is the trust anchor** — Lightning Address security boils down to this

## Wallet implementation hints (sender side)

CDK's wallet (`crates/cdk/src/lightning_address.rs`) implements LUD-06 + LUD-16 sending. CDK does not implement LUD-21 verify polling, LUD-18 payerData, or LUD-03 withdraw on the wallet side at time of writing. See [[../../raw/repos/2026-05-28-cashubtc-cdk-wallet-lnurl.md|CDK wallet LNURL raw]].

## See also

- [[lnurl-bridge-pattern.md|Bridge pattern]]
- [[lnurl-cdk-design-tensions.md|Design tensions]]
- [[nwc-vs-lnurl.md|NWC alternative]]
