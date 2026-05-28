---
title: "NWC vs LNURL as the wallet interface"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: medium
tags: [nwc, lnurl, nip-47, alternative-protocols]
---

# NWC vs LNURL — choosing the wallet-facing protocol

When designing the front door to a CDK mint, LNURL isn't the only option. Nostr Wallet Connect (NIP-47, NWC) is a competing protocol with different trade-offs.

## Feature matrix

| Feature | LNURL | NWC |
|---|---|---|
| Pay an invoice | ✓ (LNURL-pay) | ✓ (`pay_invoice`) |
| Receive ("withdraw") | ✓ (LNURL-withdraw) | ✓ (`make_invoice`) |
| Read balance | ✗ | ✓ (`get_balance`) |
| List transactions | ✗ | ✓ (`list_transactions`) |
| Hold invoices | ✗ (out of scope) | ✓ |
| QR-friendly | ✓ (bech32) | ✓ (URI scheme) |
| Censorship-resistant transport | only via .onion | ✓ (multi-relay Nostr) |
| Pubkey identity | optional via LUD-18 | mandatory |
| Spec-level identity binding | LUD-18 metadata-hash | per-event encryption with revocable secret |

## When LNURL wins

- Universal wallet support (40+ pay, 35+ withdraw clients)
- Lightning Address syntax (`user@domain`) is recognized by everyone
- Stateless servers — no relay infrastructure
- BIP-353 fallback path (lightning address via DNS)

## When NWC wins

- Two-way ongoing connection with capability advertisement
- Wallet can read mint's balance and history (impossible in LNURL)
- Hold invoices supported (when LN backend supports them)
- Censorship-resistant transport via multi-relay
- Power users; wallet-to-mint long-lived sessions

## Why a CDK mint should consider both

LNURL is the **public-facing identity surface** — the address you put on your business card. It's how external payers fund the mint.

NWC is the **wallet-control surface** — how an authenticated user manages their relationship with the mint, claims accumulated tokens, monitors balance, etc.

A complete CDK + LDK + LNURL deployment naturally evolves into CDK + LDK + LNURL + NWC, where:

- Lightning Address brings deposits in (anonymous payers)
- NWC connects authenticated users' wallets to the mint for token claim, balance reads, list-transactions UX

[[../../raw/papers/2026-05-28-nip-47-nostr-wallet-connect.md|NIP-47 raw]] has the full method catalog and event-kind table.

## Reference: NUTbits

[DoktorShift/NUTbits](https://github.com/DoktorShift/NUTbits) is the closest existing implementation: NWC-in-front-of-Cashu-mint. It does for NWC what npubcash-server does for LNURL. Mapping:

| NWC method | Cashu equivalent |
|---|---|
| `pay_invoice` | NUT-05 melt |
| `make_invoice` | NUT-04 mint quote |
| `get_balance` | proof inventory sum |
| `lookup_invoice` | NUT-07 / NUT-23 quote-state polling |
| `list_transactions` | NWC-side history; mint stateless about user history |

## Bottom line

If LNURL is the only goal: stop here. If you want power-user UX, plan for NWC alongside.

## See also

- [[lnurl-bridge-pattern.md|LNURL bridge pattern]]
- [[lnurl-spec-cheatsheet.md|LNURL spec cheatsheet]]
