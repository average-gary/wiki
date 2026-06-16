---
title: "ClientModule trait — what a Fedimint module author implements (client side)"
type: concept
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: hot
confidence: high
tags: [fedimint, ClientModule, ClientModuleInit, module-authoring, state-machines, primary-module]
---

# ClientModule trait

The `ClientModule` trait is the client-side surface a Fedimint module implements. It lives in [`fedimint-client-module/src/module/mod.rs`](../../raw/repos/2026-06-15-fedimint-server-module-trait-surface) (master @ c39f9c8). Pair with [[server-module-trait|`ServerModule`]] for the consensus side.

## Required associated types

```rust
type Init:                  ClientModuleInit;
type Common:                ModuleCommon;
type Backup:                ModuleBackup;
type ModuleStateMachineContext: Context;
type States: State<ModuleContext = Self::ModuleStateMachineContext>
            + IntoDynInstance<DynType = DynState>;
```

`States` is the module's state-machine enum — every long-running client operation moves through transitions of these states; the orchestrator drives them, persists transitions, and surfaces them via the [event log](../../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions#3-open-issues-module-api--multi-currency-adjacent).

## Required methods

### Always required

| Method | Purpose |
|---|---|
| `decoder()` | decoder for module types + state-machines + backup |
| `kind()` | `ModuleKind` |
| `context()` | `ModuleStateMachineContext` for SM transitions |
| `start()` (default no-op) | spawn background tasks once `ClientContext` is ready |
| `input_fee(amount: &Amounts, input)` | per-input fee in `Option<Amounts>` |
| `output_fee(amount: &Amounts, output)` | per-output fee in `Option<Amounts>` |

### Optional (CLI / RPC / backup)

| Method | Purpose |
|---|---|
| `handle_cli_command(args)` | JSON CLI handler |
| `handle_rpc(method, request)` | JSON-RPC stream handler |
| `supports_backup()` / `backup()` | recovery support |

### Required ONLY if module is a primary module for some unit

| Method | Purpose |
|---|---|
| `supports_being_primary()` | declare per-unit primacy via [[primary-module-support|`PrimaryModuleSupport`]] |
| `create_final_inputs_and_outputs(dbtx, op_id, unit, in_amount, out_amount)` | produce the inputs/outputs that balance a transaction in unit `unit` |
| `await_primary_module_output(op_id, out_point)` | block until the output confirms or is rejected |
| `get_balance(dbtx, unit) -> Amount` | spendable balance in `unit` |
| `get_balances(dbtx) -> Amounts` | spendable balances in all units |
| `subscribe_balance_changes()` | balance-change notifications |
| `leave_federation()` | safety check before deleting all module state |

## Connection to multi-currency

The per-unit balance API is the load-bearing change. **Pre-#7734** a primary module was set manually and exposed `get_balance() -> Amount`. **Post-#7734** the orchestrator picks the primary module per unit using [[primary-module-support|`PrimaryModuleSupport`]] and the module exposes `get_balance(_, unit)` plus `get_balances(_)`. See [[../../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source#7-client-transaction-builder|client transaction builder source]].

A unit-aware module's `create_final_inputs_and_outputs` typically rejects work for any unit it doesn't handle:

```rust
if unit != self.cfg.amount_unit {
    anyhow::bail!("Module can only handle its configured amount unit");
}
```

— exactly what mintv2 does (`modules/fedimint-mintv2-client/src/lib.rs:406-419`). See [[mintv2-amount-unit-config|mintv2 wiring]].

## `ClientModuleInit`

Lives in `fedimint-client-module/src/module/init.rs`:

```rust
async fn init(&self, args: &ClientModuleInitArgs<Self>) -> anyhow::Result<Self::Module>;
async fn recover(&self, args, snapshot) -> anyhow::Result<()>;   // default: error
fn supported_api_versions(&self) -> MultiApiVersion;
fn get_database_migrations(&self) -> BTreeMap<DatabaseVersion, ClientModuleMigrationFn>;
fn used_db_prefixes(&self) -> Option<BTreeSet<u8>>;
```

`ClientModuleInitArgs` exposes `module_root_secret()`, `db()`, `notifier()`, `context()`, `cfg()`, `federation_id()` — what a module needs to bootstrap.

## State-machine pattern

Each long-running operation (e.g. "ecash issuance from this peg-in", "lightning payment") is driven by a state machine variant in `Self::States`. The client orchestrator:

1. Persists each transition.
2. Routes outputs back to the originating module's `await_primary_module_output`.
3. Surfaces transitions through the operation log and `subscribe_*` streams.

See [issue #8421](../../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions#3-open-issues-module-api--multi-currency-adjacent) for the canonical "every SM state should map to an event-log event" guidance.

## Recent walletv2 / mintv2 patterns to copy

PRs #8665, #8647, #8676 (2026-05/06) standardize:
- **Persist terminal SM states to the operation log** (so listing operations replays correctly).
- **Expose receive address / preimage / outpoint on `OperationMeta` + event log** — dual surfacing.
- **Caller-supplied `OperationMeta`** for client-driven receive.

A multi-currency module client should mirror these patterns from day one.

## See also

- [[server-module-trait|`ServerModule` trait]]
- [[primary-module-support|Primary module support]] — per-unit funding routing
- [[transaction-item-amounts|`TransactionItemAmounts`]]
- [[three-crate-pattern|Three-crate module pattern]]
- [[../../raw/repos/2026-06-15-fedimint-server-module-trait-surface|Full source walk]]
