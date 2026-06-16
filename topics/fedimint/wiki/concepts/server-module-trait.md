---
title: "ServerModule trait — what a Fedimint module author implements (consensus side)"
type: concept
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: hot
confidence: high
tags: [fedimint, ServerModule, ServerModuleInit, module-authoring, consensus]
---

# ServerModule trait

The `ServerModule` trait is the consensus-side surface a Fedimint module implements. It lives in [`fedimint-server-core/src/lib.rs`](../../raw/repos/2026-06-15-fedimint-server-module-trait-surface) (master @ c39f9c8). Pair it with [[client-module-trait|`ClientModule`]] for the client-side surface, and with [[../../raw/repos/2026-06-15-fedimint-server-module-trait-surface|the trait-surface source walk]] for full method bodies.

## Required associated types

```rust
type Common: ModuleCommon;   // shared types: Input, Output, ConsensusItem, errors
type Init:   ServerModuleInit;
```

`Common` is the module's `-common` crate's `ModuleCommon` impl — exposes `Input`, `Output`, `ConsensusItem`, `InputError`, `OutputError`, `OutputOutcome`. `Init` is the module's `ServerModuleInit` (config / DKG / migrations).

## Required methods (lifecycle order)

| Method | When called | What it returns |
|---|---|---|
| `module_kind()` (provided) | startup | `ModuleKind` (string id) |
| `decoder()` (provided) | startup | `Decoder` for the module's wire types |
| `consensus_proposal(dbtx)` | every consensus round | `Vec<ConsensusItem>` — non-tx items the module wants to add |
| `process_consensus_item(dbtx, item, peer_id)` | once per submitted item | `Ok(())` if state changed; `Err` if redundant (so consensus can prune) |
| `verify_input(input)` (default `Ok`) | before `process_input`, parallelizable | stateless cryptographic check |
| `process_input(dbtx, input, in_point)` | per tx input | `InputMeta { amount: TransactionItemAmounts, pub_key }` |
| `process_output(dbtx, output, out_point)` | per tx output | `TransactionItemAmounts` |
| `verify_input_submission` / `verify_output_submission` (default `Ok`) | mempool-style policy | non-consensus checks |
| `audit(dbtx, audit, module_instance_id)` | reconciliation | populates `Audit` with module assets/liabilities |
| `api_endpoints()` | startup | custom `ApiEndpoint`s exposed to clients |

[[../../raw/repos/2026-06-15-fedimint-server-module-trait-surface#1-servermodule-trait|Full trait body]] in source.

## Connection to multi-currency

`process_input` and `process_output` return `Amounts`-shaped results — see [[transaction-item-amounts|`TransactionItemAmounts`]]. This is **the** load-bearing change PR #7734 made on the server side: a module that issues e-cash in unit `U` returns `Amounts::new_custom(U, amount)`; a BTC-only module returns `Amounts::new_bitcoin(amount)`. Consensus iterates per-unit in [[transaction-item-amounts#funding-verifier|`FundingVerifier::verify_funding`]].

## `ServerModuleInit` — configuration / DKG / migrations

`ServerModuleInit` is paired with `ServerModule` and lives in [`fedimint-server-core/src/init.rs`](../../raw/repos/2026-06-15-fedimint-server-module-trait-surface):

| Method | Purpose |
|---|---|
| `versions(core)` | `&[ModuleConsensusVersion]` supported under each core version |
| `supported_api_versions()` | `SupportedModuleApiVersions` for client/server compat |
| `init(args)` | construct the `ServerModule` instance from config |
| `trusted_dealer_gen(peers, args)` | test-mode config generation |
| `distributed_gen(peers, args)` | DKG-driven config generation in production |
| `validate_config(identity, config)` | sanity-check config |
| `get_client_config(server_consensus_config)` | derive the client-visible config |
| `get_database_migrations()` | per-module DB migration registry |
| `used_db_prefixes()` (optional) | declared db key prefixes |
| `is_enabled_by_default()` (optional) | for `fedimintd` registration |
| `get_documented_env_vars()` (optional) | doc strings |

**Important gap:** `ConfigGenModuleArgs` does not currently expose a per-module `GenParams` field — that surface was removed by PR #8067, broke Fedi's stability-pool port (see [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]]), and elsirion has acknowledged it'll need to come back for proper multi-asset support. Today, operator-supplied config (e.g. "this mintv2 instance issues unit `U`") has no clean path; mintv2's `amount_unit` is hardcoded to `BITCOIN` in genesis ([[mintv2-amount-unit-config|see mintv2 wiring]]).

## Three-crate split

`ServerModule` impls live in `fedimint-<module>-server`. Shared types (`Input`, `Output`, `ConsensusItem`, `KIND`, `MODULE_CONSENSUS_VERSION`, `ClientConfig`) live in `fedimint-<module>-common`. The client surface lives in `fedimint-<module>-client`. See [[three-crate-pattern|three-crate pattern]].

## Module isolation

A `ServerModule` receives an isolated `DatabaseTransaction` (prefixed with its `ModuleInstanceId`) — `dbtx` operations stay in the module's KV namespace by default. Cross-module access requires the `GlobalDBTxAccessToken` capability returned at prefix creation. See [`fedimint-core/src/db/mod.rs:453-472`](../../raw/repos/2026-06-15-fedimint-server-module-trait-surface#6-database-namespacing).

## See also

- [[client-module-trait|`ClientModule` trait]] — the client-side counterpart
- [[transaction-item-amounts|`TransactionItemAmounts`]] — the multi-unit return type
- [[primary-module-support|Primary module support]] — per-unit funding routing
- [[three-crate-pattern|Three-crate module pattern]]
- [[fedimint-modules-and-instances|`ModuleKind` vs `ModuleInstanceId`]]
- [[../../raw/repos/2026-06-15-fedimint-server-module-trait-surface|Full source walk]]
