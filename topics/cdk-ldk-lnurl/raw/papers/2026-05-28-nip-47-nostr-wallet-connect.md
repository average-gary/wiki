---
title: "NIP-47: Nostr Wallet Connect"
type: paper
source: https://github.com/nostr-protocol/nips/blob/master/47.md
fetched: 2026-05-28
confidence: high
tags: [nostr, nip-47, nwc, wallet-protocol, alternative-to-lnurl]
summary: Nostr-native wallet RPC over encrypted events. The closest competitor to LNURL for "send sats to my wallet" UX. Supports balance reads, transaction lists, hold invoices — none of which LNURL covers.
---

# NIP-47 — Nostr Wallet Connect (NWC)

## Wire model

Encrypted (NIP-44, legacy NIP-04) JSON-RPC-style requests/responses over Nostr events:

| Kind | Direction | Purpose |
|---|---|---|
| 13194 | service → world | Info / capabilities advertisement |
| 23194 | client → service | Request |
| 23195 | service → client | Response |
| 23197 | service → client | Notification (async settle, etc.) |

## Connection URI

```
nostr+walletconnect://<service_pubkey>?relay=<wss://...>&secret=<hex>
```

Secret is a one-off keypair used for the encrypted channel; revocable by the service.

## Methods

- `pay_invoice` — pays a BOLT11
- `pay_keysend` — keysend payment
- `make_invoice` — generates a BOLT11
- `lookup_invoice` — checks state by payment_hash
- `list_transactions` — paginated history
- `get_balance` — wallet balance in msats
- `get_info` — node alias, color, network, methods supported
- `make_hold_invoice` / `settle_hold_invoice` — hold-invoice primitives (relevant for LNURL-withdraw atomicity and JIT flows)

## Why NWC matters for the CDK + LNURL design

NWC is the **closest competitor to LNURL** for client UX, with strict advantages and disadvantages:

| Feature | LNURL | NWC |
|---|---|---|
| Pay an invoice | ✓ (LNURL-pay) | ✓ (`pay_invoice`) |
| Receive ("withdraw") | ✓ (LNURL-withdraw) | ✓ (`make_invoice`) |
| Read balance | ✗ | ✓ (`get_balance`) |
| List transactions | ✗ | ✓ (`list_transactions`) |
| Hold invoices | ✗ (out of scope) | ✓ |
| QR-friendly | ✓ (bech32 LUD-01) | ✓ (URI scheme) |
| Censorship-resistant transport | only via .onion | ✓ (multi-relay Nostr) |
| Pubkey identity | optional via LUD-18 auth | mandatory |
| BIP-353 / DNS resolution | LUD-16 + DNS | NIP-05 |

A CDK mint operator could expose **both**: LNURL for backward compat and Lightning Address pasting; NWC for power users / wallet-to-mint integrations.

## NUTbits as a working reference

[DoktorShift/NUTbits](https://github.com/DoktorShift/NUTbits) implements NWC-in-front-of-Cashu-mint:

- `pay_invoice` → NUT-05 melt
- `make_invoice` → NUT-04 mint quote
- `get_balance` → proof inventory sum
- `lookup_invoice` → NUT-07/NUT-23 quote-state polling
- `list_transactions` → NWC-side history; mint is stateless about user history

Pairs with **LNbits as a funding source**, which gives 60+ LNbits extensions ecash liquidity. NUTbits + LNbits is essentially the NWC analog of npubcash-server + cdk-mintd.

## See also

- [[2026-05-28-cashubtc-npubcash-server.md|npubcash-server]] — LNURL analog
