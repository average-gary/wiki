---
title: "Stability Pool (synthetic-USD via BTC collateral)"
type: concept
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: warm
confidence: medium
tags: [fedimint, stability-pool, fedi, synthetic-stablecoin, custom-module, oracle]
---

# Stability Pool

Fedi's external custom module that provides "synthetic-USD" balances inside a Fedimint federation by matching BTC-collateralized derivative positions. **Synthetic, not pegged.** Maintained out-of-tree at `github.com/fedixyz/fedi`; experimental/non-production reference at `github.com/nope78787/stabilitypool`.

## Mechanism

Two-sided market settled at epoch boundaries inside the federation:

- **Stability Seekers** — lock USD value of BTC-denominated eCash. Effectively go 1x short BTC for the duration. Pay a fee.
- **Stability Providers** — post BTC collateral, earn the fees, absorb BTC volatility (effectively long).
- **Epoch settlement** — positions settle at fixed intervals based on a BTC/USD oracle price.
- **Configurable collateralization ratio** — e.g. 1:1 covers ~50% drawdown before forced unwind.
- **Global max pool feerate** — caps the fee Stability Seekers pay.

The `stability_core` Rust crate uses pure functions + property tests; the Bitcoin Manual writeup cites <2 msat payout discrepancy in test runs.

## Critical caveats

- **Synthetic, not pegged.** No real USD anywhere in the system. Stability Seekers can lose value below their declared USD target if BTC drops more than the collateralization ratio supports.
- **Federation is the oracle.** The BTC/USD price used at epoch settlement is decided by the guardians collectively. There is no external trust-minimized oracle. Confidence: medium — the Bitcoin Manual writeup is the most public technical description, but the Fedi production source is not openly published.
- **Not yet on production federations.** dpc's [[../../raw/articles/2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218 reply]] confirms it is the "custom extension module that implements synthetic stable balances" used by Fedi app — but the Bitcoin Manual writeup (and the absence from any v0.7 release notes) put it outside the production-stable surface.

## Relation to multi-currency

Stability Pool is the **closest live example** of "Fedimint can hold non-BTC value" but is not what someone usually means by "multi-currency support":

- The BTC mint module still issues only BTC-denominated eCash notes.
- Stability Pool is a *separate* module that holds locked BTC collateral and a USD-value position.
- Settlement is in BTC. There are no USD notes. There is no USD anywhere.
- A user holds "$X of stable balance" in the Fedi UI; redeeming gives them BTC worth $X *at settlement* — assuming the oracle and counterparty solvency hold.

This is the architectural choice Fedimint has made *until native multi-currency arrives*: **synthesize stable value via collateralized derivatives rather than issue tokens claiming to be backed by external assets.**

## See also

- [[../../raw/articles/2026-05-28-bitcoin-manual-fedimint-stability-pool|Bitcoin Manual writeup]] — the source-of-record for the mechanism
- [[../../raw/articles/2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] — dpc on synthetic vs native multi-currency
- [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] — porting Fedi's stability pool across upstream versions
- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — the alternative (in-tree) path Fedimint is now building
- [[off-mint-payments-bridge-pattern|Off-mint payments-bridge pattern]] — the third path (BitSacco, ChapSmart)
