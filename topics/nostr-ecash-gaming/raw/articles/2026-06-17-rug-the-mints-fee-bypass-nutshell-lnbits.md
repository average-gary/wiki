---
title: "Rug the Mints — Nutshell LNbitsWallet silently bypasses fee_limit_msat"
source: https://uncensoredtech.substack.com/p/rug-the-mints
type: article
tags: [cashu, security, vulnerability, mint-insolvency, lightning, nutshell, melt-fee, gaming-implications]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: direct
direction: opposes
summary: |
  Disclosure of a fee-limit bypass in Nutshell's Lightning backend. `LNbitsWallet.pay_invoice()`
  ignores the user-quoted `fee_limit_msat`, so a routing-fee attacker with a high-fee channel
  can drain the mint's hot wallet while marking proofs as spent. Returns success-on-overage,
  hiding the loss until insolvency. Existential for any "mint-as-referee = mint-as-escrow"
  gaming architecture.
---

# Rug the Mints (Uncensored Tech / floppy)

## Source

- URL: https://uncensoredtech.substack.com/p/rug-the-mints
- Quality: 5 (substantive technical disclosure with shipped-code citations)

## Findings

- **Mint backends silently bypass the user-quoted fee limit.** Specifically:
  > "Nutshell's `LNbitsWallet.pay_invoice()` ignores the `fee_limit_msat` argument and sends
  > the bolt11 to the LNbits HTTP API with no cap field."
- The wallet ↔ mint contract assumes proofs of `amount + fee_reserve` bound the loss — but the
  driver doesn't enforce that bound at the backend.
- **Self-routing attack**: an attacker controlling a high-fee routing channel can cycle
  `AMOUNT` of ecash back to themselves AND extract `AMOUNT × 0.01` from the mint's hot wallet
  via routing fees.
- **Silent failure**: on fee overage, the code logs an error and **returns success anyway**,
  marking proofs as spent — so the loss is invisible to users.

## Why this matters for nostr-ecash gaming

Every wager held as ecash is implicitly underwritten by the mint's hot-wallet solvency. If the
mint runs dry from an unrelated melt-fee attack, all in-flight bets become uncollectible. The
"mint-as-referee" pattern in kirk and the prize pool in manastr both assume the mint can
honor reward redemptions — this assumption is broken if the mint is insolvent at payout time.

## Quotes

> "Nutshell's `LNbitsWallet.pay_invoice()` ignores the `fee_limit_msat` argument and sends the
> bolt11 to the LNbits HTTP API with no cap field."
>
> "Cycle AMOUNT of ecash back to themselves AND extract AMOUNT × 0.01 from the mint's hot
> wallet via the routing fee."
