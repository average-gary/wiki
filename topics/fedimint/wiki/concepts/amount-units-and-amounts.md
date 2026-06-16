---
title: "AmountUnit and Amounts (multi-unit core types)"
type: concept
created: 2026-05-28
updated: 2026-06-15
verified: 2026-06-15
volatility: hot
confidence: high
tags: [fedimint-core, amounts, amount-units, multi-currency, consensus]
---

# AmountUnit and Amounts (multi-unit core types)

Two types added to `fedimint-core` in [[../../raw/repos/2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] (merged 2025-10-19) that together replace the prior single-`Amount` (msat) accounting at the protocol layer.

## What they are

- **`AmountUnit(u64)`** — an opaque `u64` newtype identifying a unit of account. `AmountUnit::BITCOIN = AmountUnit(0)` is reserved (mainnet sats / signet sats / etc.). All other ids are operator-defined; **there is no registry or canonical mapping from id → human-readable currency**. Source: `fedimint-core/src/module/mod.rs:61-96`.
- **`Amounts(BTreeMap<AmountUnit, Amount>)`** — multi-unit money bag. Constructors filter zero amounts out (preserving the no-zero-entry invariant). Read-only deref to `BTreeMap`; no `DerefMut` to prevent accidental invariant breakage. Source: `fedimint-core/src/module/mod.rs:104-211`.

> Note: the source uses **singular `AmountUnit`**. Earlier wiki notes that referenced `AmountUnits` were inaccurate; the correct identifier is `AmountUnit`.

## Constructors

```rust
Amounts::ZERO
Amounts::new_bitcoin(amount)           // {BITCOIN: amount}, empty if amount == 0
Amounts::new_bitcoin_msats(msats)
Amounts::new_custom(unit, amount)      // {unit: amount}, empty if amount == 0
```

## Arithmetic

```rust
Amounts::checked_add(self, &other) -> Option<Self>      // None on overflow per-unit
Amounts::checked_add_mut(&mut self, &other) -> Option<&mut Self>
```

PR #8686 (2026-06-12) tightened overflow handling — modules summing per-unit `Amount`s must propagate `None` rather than panic.

## Helpers

```rust
get_bitcoin() -> Amount                       // shorthand for self.get(&BITCOIN).unwrap_or_default()
expect_only_bitcoin() -> Amount               // back-compat asserts single-unit BITCOIN
iter_units() / units()
```

`expect_only_bitcoin()` is the temporary back-compat helper for code paths that haven't been generalized. **No deprecation timeline** is set.

## What they replace

Before #7734, modules surfaced inputs/outputs/fees as a scalar `Amount` typed in millisatoshis. The consensus code added/subtracted those scalars to verify a transaction balanced. After #7734:

- Modules return `Amounts` (wrapped in `TransactionItemAmounts`) instead of `Amount` for inputs, outputs, and fees.
- Consensus iterates per-unit and verifies each unit balances independently — see [[transaction-item-amounts|`TransactionItemAmounts` and the per-unit balance check]].

This is **the single mechanical change** that lifts the single-currency assumption from the protocol layer.

## What they do NOT change

- The legacy `Amount` (msats) type still exists and is used as the value inside `Amounts`'s map. The `Amount`-typed value remains denominated in msats regardless of `AmountUnit` — a `mintv2(usd)` instance issuing a 2^20-msat note hands back `Amounts({usd: 1_048_576 msats})`. The semantics of those msats (e.g. "represents $X.YZ") are caller-defined.
- They do not introduce any non-BTC unit per se. They make non-BTC units *expressible* — actually issuing one is the job of [[mintv2-amount-unit-config|mintv2's `amount_unit` config]] and a federation operator who chooses to spin up a non-BTC mint instance.
- They do not introduce a peg, oracle, or backing mechanism.

## Comparison to Cashu NUT-01/02

Cashu's multi-unit primitive is a string (`"btc"`, `"sat"`, `"msat"`, ISO 4217 `"usd"`/`"eur"`, stablecoin tickers) bound into the keyset-ID derivation, with NUT-04 carrying per-`(method, unit)` min/max amount caps and the V4 token format including a mandatory `"u": str` field. Fedimint's `AmountUnit(u64)` is **lower-level** — opaque id, configured per module instance, no registry. A Fedimint module author building a fiat mint should look at NUT-01/02 for the human-readable / minor-unit-decimals semantics they will need to layer themselves.

## Relation to legacy Tiered<T>

`fedimint-core/src/tiered.rs` defines `Tiered<T>(BTreeMap<Amount, T>)` — the denomination-tier structure for the v1 mint module. It's hardcoded to msats: `gen_denominations` produces exponential msat tiers, the generic `T` parameter only abstracts per-tier *value* (key material), not *currency*. The v1 mint module remains BTC-only by construction. Multi-currency in the mint plane lives in v2 via `amount_unit`, not via `Tiered`.

## See also

- [[transaction-item-amounts|`TransactionItemAmounts` and the per-unit balance check]]
- [[mintv2-amount-unit-config|mintv2 `amount_unit` config]] — concrete consumer
- [[fedimint-modules-and-instances|Fedimint modules and instances]] — `ModuleInstanceId` decoupling that makes "one module-kind, multiple unit-instances" possible
- [[../../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source|Source walk]]
- [[../topics/fedimint-multi-currency-status|Multi-currency status]] — what these primitives unlock and what's still missing
