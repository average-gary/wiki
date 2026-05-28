---
title: "The Bitcoin Manual — What Is Fedimint Stability Pool?"
type: raw
source_type: articles
source_url: https://thebitcoinmanual.com/articles/what-fedimint-stability-pool/
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 4
confidence: medium
tags: [fedimint, stability-pool, fedi, synthetic-stablecoin, custom-module]
summary: Plain-language explainer of Fedimint's Stability Pool — a BTC-collateralized synthetic-USD module that matches Stability Seekers (1x short BTC) with Stability Providers (long, earn fees) at epoch boundaries. **Experimental; not yet on production federations.**
---

# The Bitcoin Manual — What Is Fedimint Stability Pool?

Independent Bitcoin-focused explainer site. Published article on Fedimint's Stability Pool mechanism.

## Mechanism

Two-sided market within a Fedimint federation, settled at epoch boundaries:

- **Stability Seekers**: lock USD value of BTC-denominated eCash. Effectively go 1x short BTC for the duration. Pay a fee.
- **Stability Providers**: post BTC collateral, earn the fees, and absorb BTC volatility (effectively long).
- **Epoch settlement**: positions settle at fixed intervals based on BTC/USD oracle price.
- **Configurable collateralization ratio**: e.g. 1:1 covers ~50% drawdown before forced unwind.
- **Global max pool feerate**: caps the fee Stability Seekers pay so the system can't be priced out.

## Code

The `stability_core` Rust crate uses pure functions + property tests; the article cites <2 msat payout discrepancy in tests. (External-module reference implementation lives at `github.com/nope78787/stabilitypool`; Fedi's production version is in `github.com/fedixyz/fedi` — see [[2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]].)

## Critical caveats

- **Synthetic, not pegged**: there is no real USD anywhere in the system. The "stable" value is a BTC-collateralized derivative. If BTC drops more than the collateralization ratio supports, Stability Seekers can lose value below their declared USD target.
- **Oracle-dependent**: requires a BTC/USD price oracle inside the federation. The federation guardians effectively *are* the oracle, since they collectively decide settlement prices.
- **Not yet on production federations** — the article (and dpc's [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218 reply]]) describe it as experimental.

## Relationship to multi-currency

This is the **closest live example** of "Fedimint can hold non-BTC value" — but it's worth being precise:

- The mint module still issues only BTC-denominated eCash notes.
- The Stability Pool is a *separate* custom module that holds locked BTC collateral and a USD-value position.
- Settlement happens in BTC. There are no USD notes in circulation. There is no USD anywhere in the system.
- A user can hold "$X of stable balance" in the Fedi UI, but redeeming that balance gives them BTC worth $X at settlement — assuming the oracle and counterparty solvency hold.

This is the architectural choice Fedimint has made: **synthesize stable value via collateralized derivatives rather than issue tokens claiming to be backed by external assets.**

## See also

- [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] — dpc confirming "synthetic stable balances"
- [[2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] — Fedi's external module brittleness
- [[2026-05-28-spark-fedimint-research-overview|Spark research]] — independent review of Fedimint trust model
- [[2026-05-28-chapsmart-fedi-mini-app|ChapSmart]] — alternative non-BTC pattern: payments-bridge, not synthetic asset
