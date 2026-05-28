---
title: "LNURL LUDs index (lnurl/luds)"
type: paper
source: https://github.com/lnurl/luds
fetched: 2026-05-28
confidence: high
tags: [lnurl, spec, lud]
summary: Canonical LNURL spec home. 21 LUDs, all optional and additive. Lists the LUD IDs and which wallets/services implement which.
---

# LNURL LUDs — index

Repository: `github.com/lnurl/luds`. All LUDs are optional and additive — different wallets/services implement different sets.

## Catalog (relevant subset for a Cashu mint)

| LUD | Title | Relevance |
|---|---|---|
| LUD-01 | Base LNURL encoding (bech32, error envelope, CORS) | Foundation — all flows |
| LUD-03 | `withdrawRequest` (LNURL-withdraw, "pull" payments) | Mint exposes for "redeem ecash to LN" |
| LUD-04 | `auth` (k1 + ECDSA signature with linking key) | Used for LNURL-auth and VSS auth |
| LUD-06 | `payRequest` (LNURL-pay) | **Core** — mint exposes for "deposit sats, receive ecash" |
| LUD-08 | Fast `withdrawRequest` (inlined fields, app-to-app only) | Optional speed-up for `lightning:` URI handoff |
| LUD-09 | `successAction` for LNURL-pay (message/url/aes) | UX for delivering ecash tokens after deposit |
| LUD-12 | Comments on LNURL-pay | Optional payer-supplied tag (e.g., correlation id) |
| LUD-16 | Lightning Address (`user@domain` → LNURL-pay) | UX surface — likely what users actually paste |
| LUD-17 | Protocol schemes (`lnurlp://`, `lnurlw://`, `lnurlc://`, `keyauth://`) | App-to-app, replaces bech32 outside QR contexts |
| LUD-18 | `payerData` (request name/pubkey/identifier/email/auth from payer) | Cryptographic binding of payer identity to invoice |
| LUD-21 | `verify` (poll endpoint for LNURL-pay settlement proof) | **Critical for ecash** — preimage proof of receipt |

## Cross-cutting envelope rules (from LUD-01)

- Bech32 with HRP `lnurl`. QR codes uppercase; otherwise all-lowercase. Never mixed case.
- Transport: HTTPS clearnet (no self-signed certs) or HTTP onion v2/v3.
- **CORS required**: endpoints must serve `Access-Control-Allow-Origin: *`.
- Clients **ignore HTTP status codes** and parse the JSON body. Status is signaled inside the payload (`{"status":"ERROR","reason":"..."}` vs presence of expected fields). Footgun for naive clients.

## See also

- [[2026-05-28-lnurl-lud-06-payrequest.md|LUD-06 payRequest]]
- [[2026-05-28-lnurl-lud-16-lightning-address.md|LUD-16 Lightning Address]]
- [[2026-05-28-lnurl-lud-21-verify.md|LUD-21 verify]]
- [[2026-05-28-lnurl-lud-03-withdraw.md|LUD-03 withdrawRequest]]
