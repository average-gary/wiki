---
title: "AmountUnits and Amounts (multi-unit core types)"
type: concept
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: warm
confidence: high
tags: [fedimint-core, amounts, amount-units, multi-currency, consensus]
---

# AmountUnits and Amounts (multi-unit core types)

Two types added to `fedimint-core` in [[../../raw/repos/2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] (merged 2025-10-19) that together replace the prior single-`Amount` (msat) accounting at the protocol layer.

## What they are

- **`AmountUnits`** — a unit identifier. Lets a transaction tag the kind of unit a value is denominated in.
- **`Amounts`** — a `unit -> amount` map. Lets one logical "amount" express arbitrary combinations of multi-unit values in a single object (e.g., `{btc: 1000, usd-synth: 50}` in one transaction).

## What they replace

Before #7734, modules surfaced inputs/outputs/fees as a scalar `Amount` typed in millisatoshis. The consensus code added/subtracted those scalars to verify a transaction balanced. After #7734:

- Modules return `Amounts` instead of `Amount` for inputs, outputs, and fees.
- Consensus iterates per-unit and verifies each unit balances independently.

This is **the single mechanical change** that lifts the single-currency assumption from the protocol layer.

## What they do NOT change

- The legacy `Amount` (msats) type still exists for the BTC mint module and other BTC-denominated paths.
- They do not introduce any non-BTC unit. They make non-BTC units *expressible* — actually issuing one is the job of [[mintv2-amount-unit-config|mintv2's `amount_unit` config]] and a federation operator who chooses to spin up a non-BTC mint instance.
- They do not introduce a peg, oracle, or backing mechanism.

## Relation to legacy Tiered<T>

`fedimint-core/src/tiered.rs` defines `Tiered<T>(BTreeMap<Amount, T>)` — the denomination-tier structure for the v1 mint module. It's hardcoded to msats: `gen_denominations` produces exponential msat tiers, the generic `T` parameter only abstracts per-tier *value* (key material), not *currency*. The v1 mint module remains BTC-only by construction. Multi-currency in the mint plane lives in v2 via `amount_unit`, not via `Tiered`.

## See also

- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — per-module piece that pairs with these core types
- [[fedimint-modules-and-instances|Fedimint modules and instances]] — `ModuleInstanceId` decoupling from `ModuleKind` is what makes "one module-kind, multiple unit-instances" possible
- [[../topics/fedimint-multi-currency-status|Multi-currency status]] — what these primitives unlock and what's still missing
