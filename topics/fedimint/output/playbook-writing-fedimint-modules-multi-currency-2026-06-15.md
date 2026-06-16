---
title: "Writing Fedimint modules with multi-currency support — 2026-06-15 playbook"
type: output
output_kind: playbook
created: 2026-06-15
updated: 2026-06-15
verified: 2026-06-15
volatility: hot
confidence: high
target_repo_revision: c39f9c83255fb88adb2381848ed3423c1e6d5c64
target_workspace_version: 0.12.0-alpha
tags: [fedimint, module-authoring, multi-currency, AmountUnit, FMCM, playbook]
question: "How do you write a Fedimint module that supports multi-currency in 2026?"
---

# Writing Fedimint modules with multi-currency support — 2026 playbook

**Audience:** Rust engineers writing a new Fedimint module (in-tree or FMCM) that needs to handle non-BTC units. **Status of upstream as of 2026-06-15:** the protocol-layer multi-currency rails are merged and stable in master `c39f9c8` (workspace `0.12.0-alpha`); end-to-end deployment of a non-BTC unit is not. **No federation in production currently issues non-BTC ecash with real backing.**

This playbook is the deliverable of the 2026-06-15 research session. Inputs:
- Code: `/Users/garykrause/repos/fedimint` @ master c39f9c8
- Wiki snapshot: see [[../wiki/topics/fedimint-multi-currency-status|Multi-currency status]]
- Source walks: [[../raw/repos/2026-06-15-fedimint-server-module-trait-surface|trait surface]] · [[../raw/repos/2026-06-15-fedimint-amount-units-and-amounts-source|AmountUnit/Amounts]] · [[../raw/repos/2026-06-15-fedimint-mintv2-amount-unit-wiring|mintv2 wiring]]
- Recent activity: [[../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions|PRs & discussions]]
- FMCM reality: [[../raw/articles/2026-06-15-fedimint-custom-modules-example-and-fedi-stability-pool|FMCM survey]]

---

## TL;DR — the headline answers

1. **The multi-currency rails are real but incomplete.** PR #7734 (2025-10-19, dpc) replaced single-`Amount` accounting with [[../wiki/concepts/transaction-item-amounts|`Amounts`]]. PR #8460 (2026-04-08, joschisan) wired `amount_unit` into `mintv2` config. Consensus balances per-unit. Tests pass. **But:** `MintGenParams` does not expose `amount_unit` to operators, so today every mintv2 instance is hardcoded to `BITCOIN` in genesis.
2. **There is no upstream backing-asset module.** No peg, no oracle, no collateral primitive ships in-tree. `AmountUnit` is a label; whether your `mintv2(usd)` notes redeem for any USD is the responsibility of code you write yourself.
3. **The official scaffold is 2 years stale.** `fedimint-custom-modules-example` last updated 2024-07-13, pinned to fedimint v0.3.0 — pre-`Amounts`. **Use in-tree `fedimint-empty-*` / `fedimint-dummy-*` instead.** See [[../wiki/concepts/three-crate-pattern|three-crate pattern]].
4. **The only public real-world FMCM** (Fedi's stability pool in `github.com/fedixyz/fedi`) **forks fedimint** rather than tracking upstream — `git tag = "v0.11.0-fedi1"` on `github.com/fedibtc/fedimint`. Plan accordingly. See [[../wiki/concepts/fmcm-upgrade-tax|FMCM upgrade tax]].
5. **The gateway is BTC-only.** Discussion #8395 (2026-03-19) proposes a `GatewayPaymentHandler` extension API for non-BTC LN; unimplemented as of 2026-06-15. A non-BTC ecash module today **cannot receive Lightning payments through `gatewayd`** — implement deposits/withdrawals out-of-band.

---

## Decision tree

**You're an operator wanting to serve a non-BTC user base today.**
→ Use the off-mint payments-bridge pattern (BitSacco / ChapSmart). The mint stays BTC-only; fiat runs on existing regulated mobile-money rails. See [[../wiki/concepts/off-mint-payments-bridge-pattern|off-mint bridge]]. **Do not attempt path A.**

**You're a builder wanting a "stable" UX.**
→ Use Fedi's Stability Pool as a reference (synthetic-USD via BTC collateral, external custom module). Note the FMCM brittleness: per [[../wiki/concepts/fmcm-upgrade-tax|upgrade tax]], plan for fork-and-track or week-scale ports per minor fedimint release.

**You actually want a real multi-currency federation (Path A).**
→ This playbook. You will be doing partly-novel work: wiring `amount_unit` into module genesis, building or adopting a backing/peg/oracle mechanism, and writing the gateway integration if you need non-BTC LN. Continue below.

---

## Part 1: The mechanical playbook (in-tree mintv2-style module)

This part covers writing a module that issues notes in a unit other than `BITCOIN`. It assumes you'll fork the fedimint repo and add your module under `modules/fedimint-<your>-{common,client,server,tests}` — the in-tree path. The FMCM (out-of-tree) path is in Part 3.

### Step 1 — Scaffold from `fedimint-empty-*`

Copy `modules/fedimint-empty-*` to `modules/fedimint-<your>-*`. Total: ~480 LOC across three crates for a no-op module. See [[../wiki/concepts/three-crate-pattern|three-crate pattern]] for what lives where.

In `<your>-common/src/lib.rs`:

```rust
pub const KIND: ModuleKind = ModuleKind::from_static_str("yourmod");
pub const MODULE_CONSENSUS_VERSION: ModuleConsensusVersion = ModuleConsensusVersion::new(0, 0);

#[derive(Debug, Clone, ...Encodable, Decodable)]
pub struct YourInput  { /* your fields */ pub amount: Amount }
#[derive(Debug, Clone, ...Encodable, Decodable)]
pub struct YourOutput { /* your fields */ pub amount: Amount }
```

If your module is multi-asset, embed `unit: AmountUnit` directly on the input/output (the dummy module pattern):

```rust
pub struct YourInput  { pub amount: Amount, pub unit: AmountUnit, ... }
pub struct YourOutput { pub amount: Amount, pub unit: AmountUnit, ... }
```

If your module is single-unit but configurable per-instance (the mintv2 pattern), put `amount_unit: AmountUnit` in `YourConfigConsensus` instead.

### Step 2 — Add `amount_unit` to your module's config

Following the mintv2 pattern ([[../wiki/concepts/mintv2-amount-unit-config|wiring detail]]):

```rust
// <your>-common/src/config.rs
#[derive(Clone, Debug, Serialize, Deserialize, Encodable, Decodable)]
pub struct YourConfigConsensus {
    /* your existing fields */
    pub fee_consensus: FeeConsensus,
    pub amount_unit:   AmountUnit,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize, Encodable, Decodable, Hash)]
pub struct YourClientConfig {
    /* your existing fields */
    pub fee_consensus: FeeConsensus,
    pub amount_unit:   AmountUnit,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YourGenParams {
    pub fee_consensus: FeeConsensus,
    pub amount_unit:   AmountUnit,    // <-- DO this even though mintv2 doesn't yet
}
```

**Important deviation from mintv2:** mintv2 hardcodes `AmountUnit::BITCOIN` in `trusted_dealer_gen` / `distributed_gen` because `MintGenParams` does not yet expose `amount_unit`. If you want a real configurable instance, add the field to your `GenParams` and propagate it. **You will be ahead of mintv2 in this regard** — and ahead of `ConfigGenModuleArgs`'s API too. Talk to elsirion / dpc before assuming your design will be merged upstream; the per-module-`GenParams` story is acknowledged as needing reintroduction (Issue #8217) but no PR has landed.

### Step 3 — Implement `ServerModule` and `ServerModuleInit`

In `<your>-server/src/lib.rs`:

```rust
#[apply(async_trait_maybe_send!)]
impl ServerModule for YourModule {
    type Common = YourModuleTypes;
    type Init   = YourInit;

    async fn process_input<'a, 'b, 'c>(
        &'a self,
        dbtx: &mut DatabaseTransaction<'c>,
        input: &'b YourInput,
        _in_point: InPoint,
    ) -> Result<InputMeta, YourInputError> {
        // ... your spend / verify / db logic ...
        let unit   = self.cfg.consensus.amount_unit;
        let amount = input.amount;
        Ok(InputMeta {
            amount: TransactionItemAmounts {
                amounts: Amounts::new_custom(unit, amount),
                fees:    Amounts::new_custom(unit, self.cfg.consensus.fee_consensus.fee(amount)),
            },
            pub_key: input.pub_key,
        })
    }

    async fn process_output<'a, 'b>(
        &'a self,
        dbtx: &mut DatabaseTransaction<'b>,
        output: &'a YourOutput,
        out_point: OutPoint,
    ) -> Result<TransactionItemAmounts, YourOutputError> {
        // ... your issue logic ...
        let unit   = self.cfg.consensus.amount_unit;
        let amount = output.amount;
        Ok(TransactionItemAmounts {
            amounts: Amounts::new_custom(unit, amount),
            fees:    Amounts::new_custom(unit, self.cfg.consensus.fee_consensus.fee(amount)),
        })
    }

    async fn audit(&self, dbtx: ..., audit: &mut Audit, module_instance_id: ModuleInstanceId) {
        audit.add_items(dbtx, module_instance_id, &YourInputAuditPrefix, |_, v| v.msats as i64).await;
        audit.add_items(dbtx, module_instance_id, &YourOutputAuditPrefix, |_, v| -(v.msats as i64)).await;
    }

    // consensus_proposal, process_consensus_item, api_endpoints, ... as needed
}
```

In `ServerModuleInit::distributed_gen`, propagate `args.<your_gen_params>.amount_unit` into the consensus config:

```rust
async fn distributed_gen(
    &self,
    peers: &(dyn PeerHandleOps + Send + Sync),
    args: &ConfigGenModuleArgs,
) -> anyhow::Result<ServerModuleConfig> {
    // ... DKG / setup ...
    let cfg = YourConfig {
        consensus: YourConfigConsensus {
            /* fields */
            fee_consensus,
            amount_unit: args.<your-extracted-amount-unit>,   // <-- propagate from operator
        },
        private: ...,
    };
    Ok(cfg.to_erased())
}
```

The exact mechanism for getting `amount_unit` out of `ConfigGenModuleArgs` is the **single biggest gap** today. Options:
- **Env var** in your `init` / `distributed_gen` (the elsirion-suggested workaround in Issue #8217). Ugly but works.
- **Custom `ServerModuleInit::init` plumbing** if you control the binary.
- **Contribute the `GenParams` reintroduction upstream** (would unblock other FMCMs too).

### Step 4 — Implement `ClientModule` and `ClientModuleInit`

In `<your>-client/src/lib.rs`:

```rust
#[apply(async_trait_maybe_send!)]
impl ClientModule for YourClientModule {
    type Init   = YourClientInit;
    type Common = YourModuleTypes;
    type Backup = YourBackup;
    type ModuleStateMachineContext = YourContext;
    type States = YourStateMachines;

    fn input_fee(&self, amounts: &Amounts, _input: &YourInput) -> Option<Amounts> {
        let unit   = self.cfg.amount_unit;
        let amount = amounts.get(&unit).copied().unwrap_or_default();
        Some(Amounts::new_custom(unit, self.cfg.fee_consensus.fee(amount)))
    }
    fn output_fee(&self, amounts: &Amounts, _output: &YourOutput) -> Option<Amounts> {
        let unit   = self.cfg.amount_unit;
        let amount = amounts.get(&unit).copied().unwrap_or_default();
        Some(Amounts::new_custom(unit, self.cfg.fee_consensus.fee(amount)))
    }

    fn supports_being_primary(&self) -> PrimaryModuleSupport {
        PrimaryModuleSupport::Selected {
            priority: PrimaryModulePriority::HIGH,
            units:    [self.cfg.amount_unit].into_iter().collect(),
        }
    }

    async fn create_final_inputs_and_outputs(
        &self,
        dbtx: &mut DatabaseTransaction<'_>,
        operation_id: OperationId,
        unit: AmountUnit,
        input_amount: Amount,
        output_amount: Amount,
    ) -> anyhow::Result<(ClientInputBundle<YourInput, YourStateMachines>,
                        ClientOutputBundle<YourOutput, YourStateMachines>)>
    {
        if unit != self.cfg.amount_unit {
            anyhow::bail!("Module can only handle its configured amount unit");
        }
        // ... select funding, build bundles, wrap each item in Amounts::new_custom(unit, _) ...
    }

    async fn get_balance(&self, dbtx: ..., unit: AmountUnit) -> Amount {
        if unit != self.cfg.amount_unit { return Amount::ZERO; }
        // ... read your db ...
    }
    async fn get_balances(&self, dbtx: ...) -> Amounts {
        Amounts::new_custom(self.cfg.amount_unit, self.get_balance(dbtx, self.cfg.amount_unit).await)
    }

    async fn subscribe_balance_changes(&self) -> BoxStream<'static, ()> {
        Box::pin(WatchStream::new(self.balance_update_sender.subscribe()).map(|_| ()))
    }
    // handle_cli_command, handle_rpc, await_primary_module_output, leave_federation as needed
}
```

### Step 5 — State machines + event log

Per recent walletv2 / mintv2 patterns ([[../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions#1-recently-merged-prs-newest-first|see PRs #8665, #8647, #8676]]):

- **Persist terminal SM states to the operation log.** Don't just emit events; the operation log is what `client.list_operations()` replays.
- **Expose receive address / preimage / outpoint on `OperationMeta` AND on the event log** (dual surfacing).
- **Accept caller-supplied `OperationMeta`** for client-driven operations (the `add custom meta to wallet v2 send` pattern).

These three patterns aren't enforced by the trait surface but are how 2026 in-tree modules are written. Mirror them.

### Step 6 — Tests with devimint

`fedimint-<your>-tests/tests/tests.rs`. Use the existing `fedimint-mintv2-tests/tests/tests.rs:109-186` shape: build a regtest federation with `fixtures().new_fed_not_degraded()`, join clients, exercise send/receive.

**Watch out:** there is **no in-tree test that exercises a non-BITCOIN unit end-to-end.** All `fedimint-mintv2-tests` runs use `client.get_balance_for_btc()`. You'll be writing the first such test. Recommended: parametrize your fixture by `AmountUnit` and run the same flow under `BITCOIN`, `AmountUnit::new_custom(1)`, and `AmountUnit::new_custom(42)` — you'll surface concurrency / ordering issues that single-unit tests miss.

### Step 7 — Run `just final-check` against your fork

Per [the project CLAUDE.md](/Users/garykrause/repos/fedimint/CLAUDE.md): linting + formatting + full test suite + doc tests + WASM check. **Run this before opening any PR upstream.** WASM compatibility is the single most common breakage point for client modules — see `fedimint-wasm-tests`.

### Step 8 — Wire the gateway (if you need non-BTC LN)

**Today: you can't, cleanly.** Discussion #8395 proposes the extension API and is unimplemented. Workarounds:
- Skip the gateway: implement deposits / withdrawals via your own bridge service (the off-mint pattern but for your specific unit).
- Patch `gatewayd` directly (becomes part of your fork — adds upgrade tax).
- Wait for / contribute to #8395.

---

## Part 2: Where to deviate from mintv2

mintv2 is the closest thing to a multi-currency reference, but it has **two real limitations** you should not inherit blindly:

1. **Operator surface gap.** `MintGenParams` doesn't expose `amount_unit`; mintv2 hardcodes `AmountUnit::BITCOIN` in genesis. Add it to your `<Your>GenParams` and propagate from day one — see Step 2 above.

2. **Denomination scheme is unit-agnostic.** mintv2 issues 42 power-of-two msat denominations (`2^0 .. 2^41 msats`) regardless of unit. A `mintv2(usd)` instance still issues 1-msat-tier notes — fine for BTC, ridiculous for fiat. If you're issuing in a unit where 1-msat-equivalent is meaningless (e.g., fiat cents-as-msats), customize your denomination tiers in `<your>-common`. Don't blindly copy mintv2's `consensus_denominations()`.

If your module is more like "ledger position tracker" than "blinded-note issuer" (e.g., a Stability-Pool-shape module), mintv2 is not a great template. Look at Fedi's stability-pool source (`https://raw.githubusercontent.com/fedixyz/fedi/main/crates/modules/stability-pool/server/src/lib.rs`, ~2,500 lines) for a real-world ledger-style module structure — note that it uses `Amounts::new_custom` and `TransactionItemAmounts` despite tracking synthetic positions rather than minting.

---

## Part 3: If you're building out-of-tree (FMCM)

If you can't or won't merge upstream, you're an FMCM author. The mechanical Steps 1-7 above still apply, but:

### Pin to a fork, not to crates.io

There is no published `fedimint-core` that matches the in-tree multi-currency surface. Either:
- Fork `fedimint/fedimint`, tag your fork (`v0.11.0-yourname1`-style — Fedi's pattern), and depend via `git = "..." tag = "..."`.
- Use Cargo `[patch.crates-io]` to redirect to a fork.

### Plan for the upgrade tax

[[../wiki/concepts/fmcm-upgrade-tax|FMCM upgrade tax]] catalogs the recurring breakages. Concretely:
- Re-pin every `fedimint-*` git dep on each fedimint minor release.
- Resolve workspace renames (PR #6578-class).
- Re-add any `GenParams`-equivalent runtime config when the previous mechanism is deleted.
- Update trait signatures touched by the release.
- Update DB migrations.
- Decide v1 vs v2 vs both for any module you integrate against.

Realistic budget: a few days to multi-week port per minor fedimint release.

### Integration testing

Devimint can drive an external module if `fedimintd` is built with your module registered. The `fedimint-custom-modules-example` repo demonstrates this layout for the Dummy module — just don't trust its trait shape (pre-`Amounts`).

### Consider contributing your peg/oracle/backing module upstream

The reason there is no in-tree backing-asset module is partly that no one has contributed one, not just that the maintainers haven't asked. If your module has clean abstractions (per-unit `BackingMechanism` trait, oracle-pluggable, audit-friendly), there is plausibly upstream appetite — see Discussion #8129 (Primitives Module).

---

## Part 4: Open questions to track

These are unresolved as of 2026-06-15 and worth revisiting before any production deployment:

| # | Question | Source |
|---|---|---|
| Q1 | Will fedimint adopt a string/enum convention for `AmountUnit` to avoid id collisions across federations? | [[../raw/repos/2026-06-15-fedimint-recent-prs-and-discussions#6-open-questions-carry-forward-to-playbook|recent activity]] |
| Q2 | Will `MintGenParams` (and `ConfigGenModuleArgs`) regain per-module `GenParams` to unblock multi-asset operator surface? | Issue #8217, elsirion comments |
| Q3 | Will `gatewayd` ship the `GatewayPaymentHandler` extension API for non-BTC LN? | Discussion #8395 |
| Q4 | Will mintv2 deprecate mintv1? Strong technical case but no roadmap PR. | Discussion #8680 |
| Q5 | Do two `mintv2` instances with different `amount_unit`s actually coexist correctly under load? Not exercised by tests today. | Test gap |
| Q6 | What is the proof-of-reserves story for a federation issuing multiple units? Risk multiplier per [[../wiki/concepts/federation-trust-model|trust model]]. | Open |

---

## Part 5: Suggested follow-up theses

For the next research session (`/wiki:research --mode thesis`):

1. **"`mintv2(usd-synth)` plus an external oracle module is a viable production path before the gateway extension lands."** — testable with a regtest federation + mock oracle. Verdict will hinge on UX without LN.
2. **"The off-mint payments-bridge pattern outperforms native multi-currency on every metric except settlement-finality for the emerging-markets use case."** — testable against BitSacco's deployed metrics + a hypothetical `mintv2(KES)` cost model.
3. **"Fedi's fork-and-track pattern is the only economically rational FMCM strategy through fedimint v0.13."** — testable against a hypothetical "track upstream master" baseline.

---

## Sources

**Primary code (master @ c39f9c8):**
- `fedimint-core/src/module/mod.rs:61-211` — `AmountUnit`, `Amounts`
- `fedimint-server-core/src/lib.rs:33-232` — `ServerModule`, `InputMeta`, `TransactionItemAmounts`
- `fedimint-client-module/src/module/mod.rs:778-943` — `ClientModule`
- `fedimint-server/src/consensus/transaction.rs:121-197` — `FundingVerifier::verify_funding`
- `modules/fedimint-mintv2-{common,server,client}/src/` — concrete consumer
- `modules/fedimint-empty-*` / `fedimint-dummy-*` — recommended scaffolds

**Discussions / issues:**
- PR #7734 (multi-currency core), PR #8460 (mintv2 amount_unit), PR #8067 (broke FMCM), PR #8686 (overflow fix)
- Issue #8217 (FMCM `GenParams` removal)
- Discussion #8218 (dpc on multi-currency status), #8395 (gateway extensibility), #8680 (v2-module status), #8129 (primitives module)

**Comparable spec:**
- Cashu NUT-00/01/02/04 — string-based ISO-aware multi-unit, for reference

**Wiki cross-links:**
- [[../wiki/topics/fedimint-multi-currency-status|Multi-currency status (synthesis)]]
- [[../wiki/concepts/server-module-trait|`ServerModule` trait]]
- [[../wiki/concepts/client-module-trait|`ClientModule` trait]]
- [[../wiki/concepts/transaction-item-amounts|`TransactionItemAmounts`]]
- [[../wiki/concepts/primary-module-support|Primary module support]]
- [[../wiki/concepts/three-crate-pattern|Three-crate pattern]]
- [[../wiki/concepts/fmcm-upgrade-tax|FMCM upgrade tax]]
