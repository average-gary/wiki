---
title: "PR #7734 — chore: multi-currency support (dpc, merged 2025-10-19)"
type: raw
source_type: repos
source_url: https://github.com/fedimint/fedimint/pull/7734
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 5
confidence: high
tags: [fedimint, multi-currency, multi-asset, mint-module, fedimint-core]
summary: First-step PR introducing AmountUnits and Amounts (a unit→amount map) into fedimint-core, plus consensus-layer enforcement that all involved units match per transaction. Marks the protocol-level transition from single-msat accounting toward arbitrary unit support.
---

# PR #7734 — chore: multi-currency support

- **Author**: dpc (Dawid Ciężarkiewicz, Fedimint core dev)
- **Merged**: 2025-10-19
- **State**: MERGED
- **URL**: https://github.com/fedimint/fedimint/pull/7734

## Author description (verbatim)

> This change is a first step towards modules that can deal with multiple units. The goal here is first-class support for additional unit of account. Examples could be synthetic stablecoins, bridges for stablecoins, fungible tokens, some contracting systems using some intermediate units (contracts, DLCs, etc.)
>
> At the fedimint-core level we now have `AmountUnits` and `Amounts` which is just a map of `unit -> amount` expressing arbitrary combination of multi-unit amounts.
>
> On the server-side the change is relatively simple. Modules now return `Amounts` instead of `Amount` for input&output values and fees. The consensus code verifies that all involved units match. Basically a loop over units in some places.
>
> On the client side the change is somewhat similar, but has some more consequences. Transaction balancing now needs to take care of balancing more than just single unit. For this to work we now have to have (potentially) multiple "primary modules" for different currencies. I've decided to remove the manual primary module setting, and just let modules define their priority for being a primary module for a given unit. In the future we can adapt this mechanism even further.
>
> Then in few last PRs the dummy module is converted to support any unit.

## Key takeaways

- **First protocol-layer step toward multi-currency.** The PR title is `chore:` (a refactor / preparation) — not `feat:` — explicitly framed as enabling future per-unit modules, not adding non-BTC support itself.
- **`AmountUnits` and `Amounts` types** added to `fedimint-core`. `Amounts` is a `unit -> amount` map. This replaces the prior single-`Amount` (msat) accounting in module input/output/fee surfaces.
- **Consensus enforces unit-balance.** Transaction validation iterates units and verifies every involved unit balances. This is the mechanical enabler — the server can now process a transaction touching multiple units without needing to know which units exist.
- **Client now supports multiple "primary modules"**, one per unit, with per-unit priority instead of a single manual primary-module setting. This is the wallet-side balancing change required to spend across units.
- **Dummy module made unit-agnostic** in follow-up PRs (per author note). The mint module proper (`mintv2`) is updated separately — see [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]].

## Implications for the multi-currency question

This is the load-bearing infrastructure change. After 2025-10-19, fedimint-core no longer assumes a single global currency at the consensus / transaction-balance layer. **Native multi-currency is no longer architecturally blocked at the core; the work moved up to per-module unit support.**

However, this PR does NOT:
- Add a stablecoin module
- Add a peg / oracle / collateral mechanism
- Implement any non-BTC unit
- Change the mint module's denomination tiers

It is the rails. The trains have not yet been built — see [[../../wiki/topics/fedimint-multi-currency-status|Multi-currency status]] for what's shipped vs. proposed.

## See also

- [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460 — mintv2 amount_unit config]] — downstream, applies the unit type to mintv2
- [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] — dpc's plain-language framing of the same roadmap
