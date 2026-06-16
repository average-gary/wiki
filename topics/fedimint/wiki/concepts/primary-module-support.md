---
title: "Primary module support — per-unit transaction funding routing"
type: concept
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: hot
confidence: high
tags: [fedimint, primary-module, PrimaryModuleSupport, multi-currency, ClientModule]
---

# Primary module support

Pre-#7734 the client kept a single manually-set `primary_module: ModuleInstanceId`. PR #7734 ("chore: multi-currency support") replaced that with **per-unit primary modules** declared by each `ClientModule` via `supports_being_primary() -> PrimaryModuleSupport`.

## The type

In `fedimint-client-module/src/module/mod.rs` (referenced by trait method on line 879):

```rust
pub enum PrimaryModuleSupport {
    Any { priority: PrimaryModulePriority },
    Selected {
        priority: PrimaryModulePriority,
        units:    BTreeSet<AmountUnit>,
    },
    None,                                 // default
}

pub struct PrimaryModulePriority(...);
impl PrimaryModulePriority {
    pub const HIGH: Self = ...;           // numeric: 100
    pub const LOW:  Self = ...;           // numeric: 10000  (lower number wins)
}
```

The orchestrator picks, per unit, the registered module with the **lowest priority number** that declares it can be primary for that unit.

## How modules declare it

**mintv2** (`modules/fedimint-mintv2-client/src/lib.rs`):

```rust
fn supports_being_primary(&self) -> PrimaryModuleSupport {
    PrimaryModuleSupport::Selected {
        priority: PrimaryModulePriority::HIGH,
        units:    [self.cfg.amount_unit].into_iter().collect(),
    }
}
```

— each mintv2 instance is primary for its single configured unit.

**A custom multi-unit module** that issues two units could declare:

```rust
PrimaryModuleSupport::Selected {
    priority: PrimaryModulePriority::HIGH,
    units:    [unit_a, unit_b].into(),
}
```

— and would be expected to handle both in `create_final_inputs_and_outputs`.

**A non-primary module** (e.g. lnv2 client) returns `PrimaryModuleSupport::None`.

## Implication for multi-instance

A federation can stand up `mintv2(btc)` and `mintv2(usd-synth)` as separate `ModuleInstanceId`s. Each declares `Selected { units: [its_unit] }`. The orchestrator routes BTC-funding work to the BTC instance and USD-synth-funding work to the USD-synth instance. **Whether two instances of the same module type with different units coexist correctly is not exercised by tests** ([[../../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions#6-open-questions-carry-forward-to-playbook|open question Q5]]).

## What primary modules must implement

If `supports_being_primary()` returns anything other than `None`, the module must implement:

- `create_final_inputs_and_outputs(dbtx, op_id, unit, in_amount, out_amount)` — produce the bundles that balance a transaction in `unit`. Reject if `unit` is not in your declared set.
- `await_primary_module_output(op_id, out_point)` — block until the output is finalized.
- `get_balance(dbtx, unit) -> Amount` — per-unit spendable balance.
- `get_balances(dbtx) -> Amounts` — all-unit spendable balances.
- `subscribe_balance_changes() -> BoxStream<()>` — change notifications.

A module that returns `PrimaryModuleSupport::None` can leave these as no-ops/defaults.

## See also

- [[client-module-trait|`ClientModule` trait]]
- [[transaction-item-amounts|`TransactionItemAmounts`]]
- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — concrete usage
- [[../../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit/Amounts source walk]]
- [[../../raw/repos/2026-06-15-fedimint-server-module-trait-surface|ServerModule/ClientModule trait surface]]
