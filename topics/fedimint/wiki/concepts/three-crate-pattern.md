---
title: "Three-crate module pattern (-common / -client / -server)"
type: concept
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: warm
confidence: high
tags: [fedimint, module-authoring, three-crate-pattern, dummy-module, empty-module]
---

# Three-crate module pattern

Every Fedimint module ships as three crates plus a tests crate. The pattern is enforced by convention, not by traits — but the canonical scaffolds (`fedimint-empty-*`, `fedimint-dummy-*`) and every in-tree module (`fedimint-mint-*`, `fedimint-mintv2-*`, `fedimint-ln-*`, `fedimint-lnv2-*`, `fedimint-wallet-*`, `fedimint-walletv2-*`, `fedimint-meta-*`) all follow it.

```
fedimint-<module>-common/    # shared types: Input, Output, ConsensusItem, KIND, ClientConfig
fedimint-<module>-client/    # ClientModule + ClientModuleInit, state machines, CLI/RPC
fedimint-<module>-server/    # ServerModule + ServerModuleInit, DB schema, consensus
fedimint-<module>-tests/     # devimint-driven integration tests (optional but recommended)
```

## What lives where

### `-common`

- `KIND: ModuleKind` (string id) and `MODULE_CONSENSUS_VERSION: ModuleConsensusVersion` constants.
- Wire-format types: `Input`, `Output`, `ConsensusItem`, `OutputOutcome`.
- Error types: `InputError`, `OutputError`.
- `ClientConfig` (the federation-distributed config the client sees).
- `CommonModuleInit` impl marker.
- `ModuleTypes` struct + `plugin_types_trait_impl_common!` macro call.

Cargo deps (from `fedimint-empty-common/Cargo.toml`): `anyhow`, `fedimint-core`, `serde`, `thiserror`. Total ~112 LOC for the empty module.

### `-server`

- `ServerModule` impl — consensus logic, `process_input`/`process_output`, `audit`.
- `ServerModuleInit` impl — `init`, `trusted_dealer_gen`, `distributed_gen`, `get_client_config`, `validate_config`, `get_database_migrations`.
- DB key/value schemas (typically `db.rs` submodule).

Cargo deps: `fedimint-core`, `fedimint-server-core`, `fedimint-<module>-common`, `async-trait`, `erased-serde`, `futures`, `serde`, `strum`. Total ~241 LOC for the empty module, ~279 LOC for dummy.

### `-client`

- `ClientModule` impl — `input_fee`/`output_fee`, primary-module API (if applicable), state machines.
- `ClientModuleInit` impl.
- `Context` struct (`ModuleStateMachineContext`) and `States` enum.
- CLI / RPC handlers.

Cargo deps: `fedimint-api-client`, `fedimint-client-module`, `fedimint-core`, `fedimint-<module>-common`, plus runtime crates (`tokio`, `tokio-stream`, `tracing`, `rand`). Total ~131 LOC for the empty module, ~432 LOC for dummy.

## Why the split

- A wallet / auditor / explorer can depend only on `-common` to decode transactions, without pulling in server consensus or client state-machine code.
- `-server` and `-client` can independently depend on test-only or platform-specific crates.
- WASM compatibility: `-client` can target `wasm32-unknown-unknown`; `-server` (which uses `fedimint-server-core` and DB drivers) cannot.

## Recommended starting point

`fedimint-empty-*` — minimal no-op module, total ~480 LOC across the three crates. Crate description literally says "good template for a new module".

`fedimint-dummy-*` — adds primary-module support, balance tracking, and state machines. Already multi-currency-aware:

```rust
// fedimint-dummy-common/src/lib.rs
pub struct DummyInput  { pub amount: Amount, pub unit: AmountUnit, pub pub_key: PublicKey }
pub struct DummyOutput { pub amount: Amount, pub unit: AmountUnit }
```

For multi-currency module work, **start from in-tree dummy/empty, not from the external `fedimint-custom-modules-example` repo** — that scaffold is pinned to fedimint v0.3.0 and pre-dates `Amounts` ([[../../raw/articles/2026-06-15-fedimint-custom-modules-example-and-fedi-stability-pool|see survey]]).

## Out-of-tree (FMCM) crate layout

External / Fedimint Custom Modules live in their own repos and pull `fedimint-*` as git deps. Fedi's stability pool (in `github.com/fedixyz/fedi`) follows the same three-crate split:

```
crates/modules/stability-pool/{common,client,server,tests}/
```

— but pins to a fedimint **fork** (`github.com/fedibtc/fedimint`, tag `v0.11.0-fedi1`) rather than upstream. See [[../../raw/articles/2026-06-15-fedimint-custom-modules-example-and-fedi-stability-pool#3-fedis-stability-pool--the-only-public-real-world-fmcm|stability-pool survey]].

## See also

- [[server-module-trait|`ServerModule` trait]]
- [[client-module-trait|`ClientModule` trait]]
- [[fedimint-modules-and-instances|Modules and instances]]
- [[fmcm-upgrade-tax|FMCM upgrade tax]] — what the three-crate split costs you when upstream churns
