---
title: "Fedimint ServerModule / ClientModule trait surface (master @ c39f9c8)"
type: raw
source_type: repos
source_url: https://github.com/fedimint/fedimint
source: "fedimint/fedimint @ c39f9c83255fb88adb2381848ed3423c1e6d5c64"
local_path: /Users/garykrause/repos/fedimint
ingested: 2026-06-15
fetched: 2026-06-15
verified: 2026-06-15
revision: c39f9c83255fb88adb2381848ed3423c1e6d5c64
volatility: hot
quality: 5
confidence: high
tags: [fedimint, ServerModule, ClientModule, ModuleInit, three-crate-pattern, source-walkthrough]
summary: Code-level walkthrough of the Fedimint module trait surface — `ServerModule`, `ClientModule`, `ServerModuleInit`, `ClientModuleInit`, `CommonModuleInit` — with file:line citations against master @ c39f9c8. Also covers the three-crate (`-common`/`-client`/`-server`) pattern, the registry types (`ModuleDecoderRegistry`, `ServerModuleInitRegistry`), and database namespacing (`with_prefix_module_id`, `GlobalDBTxAccessToken`).
---

# Fedimint ServerModule / ClientModule trait surface (snapshot 2026-06-15)

Source-level walkthrough of the module-author trait surface in fedimint master at commit `c39f9c8` (workspace 0.12.0-alpha). All file paths are relative to `/Users/garykrause/repos/fedimint`.

## 1. `ServerModule` trait

**File:** `fedimint-server-core/src/lib.rs:33-196`

```rust
#[apply(async_trait_maybe_send!)]
pub trait ServerModule: Debug + Sized {
    type Common: ModuleCommon;
    type Init: ServerModuleInit;

    fn module_kind() -> ModuleKind { ... }
    fn decoder() -> Decoder { ... }

    async fn consensus_proposal<'a>(
        &'a self,
        dbtx: &mut DatabaseTransaction<'_>,
    ) -> Vec<<Self::Common as ModuleCommon>::ConsensusItem>;

    async fn process_consensus_item<'a, 'b>(
        &'a self,
        dbtx: &mut DatabaseTransaction<'b>,
        consensus_item: <Self::Common as ModuleCommon>::ConsensusItem,
        peer_id: PeerId,
    ) -> anyhow::Result<()>;

    fn verify_input(&self, _input: &<Self::Common as ModuleCommon>::Input)
        -> Result<(), <Self::Common as ModuleCommon>::InputError> { ... }

    async fn process_input<'a, 'b, 'c>(
        &'a self,
        dbtx: &mut DatabaseTransaction<'c>,
        input: &'b <Self::Common as ModuleCommon>::Input,
        in_point: InPoint,
    ) -> Result<InputMeta, <Self::Common as ModuleCommon>::InputError>;

    async fn process_output<'a, 'b>(
        &'a self,
        dbtx: &mut DatabaseTransaction<'b>,
        output: &'a <Self::Common as ModuleCommon>::Output,
        out_point: OutPoint,
    ) -> Result<TransactionItemAmounts, <Self::Common as ModuleCommon>::OutputError>;

    #[deprecated(note = "https://github.com/fedimint/fedimint/issues/6671")]
    async fn output_status(...) -> Option<...>;

    async fn verify_input_submission<'a, 'b, 'c>(...) { ... }   // mempool-policy hook
    async fn verify_output_submission<'a, 'b>(...) { ... }      // mempool-policy hook

    async fn audit(
        &self,
        dbtx: &mut DatabaseTransaction<'_>,
        audit: &mut Audit,
        module_instance_id: ModuleInstanceId,
    );

    fn api_endpoints(&self) -> Vec<ApiEndpoint<Self>>;
}
```

Key associated types via `Common: ModuleCommon`: `ConsensusItem`, `Input`, `Output`, `InputError`, `OutputError`, `OutputOutcome`. Result types: `InputMeta` wraps `TransactionItemAmounts`; `process_output` returns `TransactionItemAmounts` directly. (See [[2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnits/Amounts source walk]] for those types.)

## 2. `ClientModule` trait

**File:** `fedimint-client-module/src/module/mod.rs:778-943`

```rust
#[apply(async_trait_maybe_send!)]
pub trait ClientModule: Debug + MaybeSend + MaybeSync + 'static {
    type Init: ClientModuleInit;
    type Common: ModuleCommon;
    type Backup: ModuleBackup;
    type ModuleStateMachineContext: Context;
    type States: State<ModuleContext = Self::ModuleStateMachineContext>
        + IntoDynInstance<DynType = DynState>;

    fn decoder() -> Decoder { ... }
    fn kind() -> ModuleKind { ... }
    fn context(&self) -> Self::ModuleStateMachineContext;
    async fn start(&self) {}

    async fn handle_cli_command(&self, _args: &[ffi::OsString])
        -> anyhow::Result<serde_json::Value> { ... }
    async fn handle_rpc(&self, _method: String, _request: serde_json::Value)
        -> BoxStream<'_, anyhow::Result<serde_json::Value>> { ... }

    fn input_fee(&self, amount: &Amounts,
        input: &<Self::Common as ModuleCommon>::Input) -> Option<Amounts>;
    fn output_fee(&self, amount: &Amounts,
        output: &<Self::Common as ModuleCommon>::Output) -> Option<Amounts>;

    fn supports_backup(&self) -> bool { false }
    async fn backup(&self) -> anyhow::Result<Self::Backup> { ... }

    fn supports_being_primary(&self) -> PrimaryModuleSupport { ... }

    async fn create_final_inputs_and_outputs(
        &self,
        dbtx: &mut DatabaseTransaction<'_>,
        operation_id: OperationId,
        unit: AmountUnit,
        input_amount: Amount,
        output_amount: Amount,
    ) -> anyhow::Result<(
        ClientInputBundle<<Self::Common as ModuleCommon>::Input, Self::States>,
        ClientOutputBundle<<Self::Common as ModuleCommon>::Output, Self::States>,
    )>;

    async fn await_primary_module_output(&self, operation_id: OperationId,
        out_point: OutPoint) -> anyhow::Result<()>;

    async fn get_balance(&self, dbtx: &mut DatabaseTransaction<'_>,
        unit: AmountUnit) -> Amount;
    async fn get_balances(&self, dbtx: &mut DatabaseTransaction<'_>) -> Amounts;

    async fn subscribe_balance_changes(&self) -> BoxStream<'static, ()>;
    // ... leave_federation method ...
}
```

Note the **per-unit balance API**: `get_balance(dbtx, unit) -> Amount` plus `get_balances(dbtx) -> Amounts`. Primary-module support is per-unit (see `PrimaryModuleSupport` below).

## 3. Init traits

### `ModuleInit` (base) — `fedimint-core/src/module/mod.rs:655-669`

```rust
pub trait ModuleInit: Debug + Clone + Send + Sync + 'static {
    type Common: CommonModuleInit;
    fn dump_database(
        &self,
        dbtx: &mut DatabaseTransaction<'_>,
        prefix_names: Vec<String>,
    ) -> impl Future<...>;
}
```

### `CommonModuleInit` — `fedimint-core/src/module/mod.rs:718-725`

```rust
#[apply(async_trait_maybe_send!)]
pub trait CommonModuleInit: Debug + Sized {
    const CONSENSUS_VERSION: ModuleConsensusVersion;
    const KIND: ModuleKind;
    type ClientConfig: ClientConfig;
    fn decoder() -> Decoder;
}
```

### `ServerModuleInit` — `fedimint-server-core/src/init.rs:180-261`

```rust
#[apply(async_trait_maybe_send!)]
pub trait ServerModuleInit: ModuleInit + Sized {
    type Module: ServerModule + Send + Sync;

    fn versions(&self, core: CoreConsensusVersion) -> &[ModuleConsensusVersion];
    fn supported_api_versions(&self) -> SupportedModuleApiVersions;
    async fn init(&self, args: &ServerModuleInitArgs<Self>) -> anyhow::Result<Self::Module>;

    fn trusted_dealer_gen(
        &self,
        peers: &[PeerId],
        args: &ConfigGenModuleArgs,
    ) -> BTreeMap<PeerId, ServerModuleConfig>;

    async fn distributed_gen(
        &self,
        peers: &(dyn PeerHandleOps + Send + Sync),
        args: &ConfigGenModuleArgs,
    ) -> anyhow::Result<ServerModuleConfig>;

    fn validate_config(&self, identity: &PeerId, config: ServerModuleConfig)
        -> anyhow::Result<()>;
    fn get_client_config(&self, config: &ServerModuleConsensusConfig)
        -> anyhow::Result<ClientConfig>;
    fn get_database_migrations(&self)
        -> BTreeMap<DatabaseVersion, ServerModuleDbMigrationFn<Self::Module>> { ... }
    fn used_db_prefixes(&self) -> Option<BTreeSet<u8>> { None }
    fn is_enabled_by_default(&self) -> bool { true }
    fn get_documented_env_vars(&self) -> Vec<EnvVarDoc> { vec![] }
}
```

`trusted_dealer_gen` produces per-peer configs in tests; `distributed_gen` runs DKG over the supplied `PeerHandleOps` in production. Both consume `ConfigGenModuleArgs` — the surface that **lost the per-module `GenParams` field in PR #8067** (see [[../articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]]; reintroduction expected per elsirion when multi-asset support firms up). The current `ConfigGenModuleArgs` carries only `disable_base_fees: bool` plus the standard module-id glue.

### `ClientModuleInit` — `fedimint-client-module/src/module/init.rs:371-422`

```rust
#[apply(async_trait_maybe_send!)]
pub trait ClientModuleInit: ModuleInit + Sized {
    type Module: ClientModule;

    fn supported_api_versions(&self) -> MultiApiVersion;
    fn kind() -> ModuleKind { ... }

    async fn recover(&self, _args: &ClientModuleRecoverArgs<Self>,
        _snapshot: Option<&<Self::Module as ClientModule>::Backup>)
        -> anyhow::Result<()> { ... }

    async fn init(&self, args: &ClientModuleInitArgs<Self>) -> anyhow::Result<Self::Module>;

    fn get_database_migrations(&self) -> BTreeMap<DatabaseVersion, ClientModuleMigrationFn> { ... }
    fn used_db_prefixes(&self) -> Option<BTreeSet<u8>> { None }
}
```

## 4. Three-crate pattern (dummy / empty exemplars)

The convention in `modules/`:

```
fedimint-<module>-common/   # shared types: Input, Output, ConsensusItem, KIND, MODULE_CONSENSUS_VERSION, ClientConfig, CommonModuleInit
fedimint-<module>-server/   # ServerModule + ServerModuleInit, DB schema, consensus
fedimint-<module>-client/   # ClientModule + ClientModuleInit, state machines, CLI/RPC
fedimint-<module>-tests/    # devimint-driven integration tests
```

**Dummy module sizes (`modules/fedimint-dummy-*/src/lib.rs`):**

| Crate | lib.rs lines | Notable Cargo deps |
|---|---|---|
| `-common` | 120 | `fedimint-core`, `serde`, `thiserror` |
| `-server` | 279 | `fedimint-core`, `fedimint-server-core`, `fedimint-dummy-common`, `async-trait`, `erased-serde`, `strum` |
| `-client` | 432 | `fedimint-api-client`, `fedimint-client-module`, `fedimint-core`, `fedimint-dummy-common`, `tokio`, `tokio-stream`, `tracing` |

**Empty module sizes (`modules/fedimint-empty-*/src/lib.rs`):**

| Crate | lib.rs lines |
|---|---|
| `-common` | 112 |
| `-server` | 241 |
| `-client` | 131 |

The empty module is the explicitly-recommended bare scaffold; dummy adds primary-module / balance / state-machine logic. Total empty-module surface ≈ 480 LOC for a no-op module.

**Dummy `-common` is already multi-currency-aware** (`modules/fedimint-dummy-common/src/lib.rs:36-46`):

```rust
pub struct DummyInput {
    pub amount: Amount,
    pub unit: AmountUnit,
    pub pub_key: PublicKey,
}
pub struct DummyOutput {
    pub amount: Amount,
    pub unit: AmountUnit,
}
```

Dummy server `process_input` (lines 207-238) returns:

```rust
Ok(InputMeta {
    amount: TransactionItemAmounts {
        amounts: Amounts::new_bitcoin(input.amount),
        fees: Amounts::ZERO,
    },
    pub_key: input.pub_key,
})
```

Dummy client (`fedimint-dummy-client/src/lib.rs:300-304`):

```rust
async fn get_balance(&self, dbtx: &mut DatabaseTransaction<'_>, unit: AmountUnit) -> Amount;
async fn get_balances(&self, dbtx: &mut DatabaseTransaction<'_>) -> Amounts;
```

## 5. Registries

**`ModuleInitRegistry<M>` — `fedimint-core/src/config.rs:473-619`**

```rust
pub struct ModuleInitRegistry<M>(BTreeMap<ModuleKind, M>);
pub type CommonModuleInitRegistry = ModuleInitRegistry<DynCommonModuleInit>;
// ServerModuleInitRegistry / ClientModuleInitRegistry are aliases living in their respective `init.rs` files.
```

`attach<T: Into<M>>(&mut self, gen: T)` — how `fedimintd` and the client builder register modules.

**`ModuleDecoderRegistry` — `fedimint-core/src/module/registry.rs:173-191`**

```rust
pub type ModuleDecoderRegistry = ModuleRegistry<Decoder, DecodingMode>;

pub enum DecodingMode {
    #[default] Reject,    // unknown module instance ids → error
    Fallback,             // unknown → DynUnknown placeholder
}
```

Built from server modules in `fedimint-server-core/src/lib.rs:511-523`:

```rust
impl ServerModuleRegistryExt for ServerModuleRegistry {
    fn decoder_registry(&self) -> ModuleDecoderRegistry {
        self.iter_modules()
            .map(|(id, kind, module)| (id, kind.clone(), module.decoder()))
            .collect::<ModuleDecoderRegistry>()
    }
}
```

## 6. Database namespacing

**File:** `fedimint-core/src/db/mod.rs:453-472`

```rust
pub fn with_prefix_module_id(
    &self,
    module_instance_id: ModuleInstanceId,
) -> (Self, GlobalDBTxAccessToken) {
    let prefix = module_instance_id_to_byte_prefix(module_instance_id);
    let global_dbtx_access_token = GlobalDBTxAccessToken::from_prefix(&prefix);
    (Self {
        inner: Arc::new(PrefixDatabase {
            inner: self.inner.clone(),
            global_dbtx_access_token: Some(global_dbtx_access_token),
            prefix,
        }),
        module_decoders: self.module_decoders.clone(),
    }, global_dbtx_access_token)
}
```

Plus `ensure_global()` / `ensure_isolated()` runtime checks. Each module receives an isolated `dbtx`; cross-module access requires the `GlobalDBTxAccessToken` capability returned at prefix creation. This is the mechanism behind "module-specific KV namespacing" mentioned in the docs.

## 7. Lifecycle order summary

**Server module (one consensus round, one transaction):**

1. `decoder()` — startup, builds `ModuleDecoderRegistry`
2. `consensus_proposal(dbtx)` — every few seconds; module proposes non-tx items
3. `process_consensus_item(dbtx, item, peer_id)` — once per item; return `Err` if redundant
4. `verify_input(input)` — stateless, parallelizable
5. `process_input(dbtx, input, in_point) -> InputMeta` — stateful spend
6. `process_output(dbtx, output, out_point) -> TransactionItemAmounts` — stateful issue
7. `audit(dbtx, audit, module_instance_id)` — assets vs liabilities reconciliation

**Client module:** `decoder()` → `kind()` → `start()` (background tasks) → per-tx: `input_fee()`/`output_fee()` → primary modules: `create_final_inputs_and_outputs(dbtx, op_id, unit, in, out)` → `await_primary_module_output(...)` → balance: `get_balance(dbtx, unit)` / `get_balances(dbtx)`.

## See also

- [[2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnits/Amounts source walk]] — the multi-unit types this trait surface returns/consumes
- [[2026-06-15-fedimint-mintv2-amount-unit-wiring|mintv2 amount_unit wiring]] — concrete example of trait-impl using `cfg.consensus.amount_unit`
- [[2026-06-15-fedimint-recent-prs-and-discussions|Recent PRs & discussions]] — PR #8395 (gateway extensibility for non-BTC LN), #8680 (v2-module status from elsirion)
- [[../articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] — `GenParams` removal that affects `ConfigGenModuleArgs`
