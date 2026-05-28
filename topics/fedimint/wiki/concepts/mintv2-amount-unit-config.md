---
title: "mintv2 amount_unit config"
type: concept
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: warm
confidence: high
tags: [fedimint, mintv2, mint-module, amount-unit, multi-currency, joschisan]
---

# mintv2 amount_unit config

Per-module configuration field added to the v2 mint module by [[../../raw/repos/2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]] (joschisan, merged 2026-04-08, backported to `releases/v0.11` in PR #8466).

## What it does

When a federation operator sets up a `mintv2` module instance, they declare which unit it issues notes in via `amount_unit`. The federation can then run **multiple `mintv2` instances**, each with a different `amount_unit` — one BTC mint, one synthetic-USD mint, etc.

## Why this works architecturally

Two pre-existing properties make this clean:

1. **`ModuleKind` and `ModuleInstanceId` are decoupled** in `fedimint-core/src/core.rs`. The same module *kind* can be instantiated multiple times under different instance IDs ("rare, but possible," per the source comment).
2. **`fedimint-core` is now unit-aware** via [[amount-units-and-amounts|AmountUnits and Amounts]] (PR #7734, Oct 2025). Consensus can balance a transaction whose inputs/outputs touch multiple units.

The combination = a federation can stand up `mintv2(btc) + mintv2(usd-synth)` and the consensus layer handles the cross-instance bookkeeping.

## What it does NOT provide

- **No peg, no oracle, no collateral.** The unit is a label. Whether notes labeled `usd-synth` are *redeemable* for any USD value is entirely the responsibility of the module logic that backs them.
- **No production deployment.** As of 2026-05-28, no production federation has shipped a non-BTC `mintv2` instance with a real backing mechanism. The closest thing is Fedi's [[stability-pool|Stability Pool]], which is an *external* custom module, not a `mintv2` instance.

## See also

- [[amount-units-and-amounts|AmountUnits and Amounts]] — prerequisite core types
- [[fedimint-modules-and-instances|Fedimint modules and instances]] — module-kind / instance-id decoupling
- [[stability-pool|Stability Pool]] — the alternative architectural path (external custom module)
- [[../topics/fedimint-multi-currency-status|Multi-currency status]] — assembled story
