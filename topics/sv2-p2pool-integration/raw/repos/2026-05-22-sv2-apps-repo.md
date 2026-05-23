---
title: "stratum-mining/sv2-apps"
source_url: https://github.com/stratum-mining/sv2-apps
type: repo
ingested: 2026-05-22
quality: 5
confidence: high
tags: [sv2-apps, sri, pool, jdc, jds, translator, repo]
---

# stratum-mining/sv2-apps

The SV2 reference application stack. The integration target on the SV2 side that p2poolv2 plugs into.

## Layout
- `bitcoin-core-sv2/` — translates Bitcoin Core IPC into SV2 Template Distribution Protocol
- `pool-apps/`
  - `pool/` — `PoolSv2`, channel manager, downstream server
  - `jd-server/` — Job Declarator Server with the **`JobValidationEngine`** plug-trait
- `miner-apps/`
  - `jd-client/` — Job Declarator Client
  - `translator/` — SV1↔SV2 bridge
- `stratum-apps/` — shared utilities (config, network, key management, monitoring, `tp_type::TemplateProviderType`)
- `integration-tests/`

## Key pluggable interfaces

### `JobValidationEngine` (sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/mod.rs)
```rust
#[async_trait::async_trait]
pub trait JobValidationEngine: Send + Sync {
    async fn handle_declare_mining_job(
        &self,
        declare_mining_job: DeclareMiningJob<'_>,
        provide_missing_transactions_success: Option<ProvideMissingTransactionsSuccess<'_>>,
    ) -> DeclareMiningJobResult;

    async fn handle_push_solution(&self, push_solution: PushSolution<'_>);

    async fn handle_set_custom_mining_job(
        &self,
        set_custom_mining_job: SetCustomMiningJob<'_>,
        allocated_token: JdToken,
    ) -> SetCustomMiningJobResult;

    fn shutdown(&self) {}
}
```
Today there is one implementation: `BitcoinCoreIPCEngine`. **A `P2poolV2Engine` would be a second implementation — the cleanest, lowest-friction integration path.**

### `TemplateProviderType` (sv2-apps/stratum-apps/src/tp_type.rs)
```rust
enum TemplateProviderType {
    BitcoinCoreIpc { network, data_dir, fee_threshold, min_interval },
    Sv2Tp { address, public_key },
}
```
A third variant `P2poolV2Backend { ... }` is conceivable but redundant if p2poolv2 already speaks SV2-TP via embedding.

### `PoolSv2` orchestration (sv2-apps/pool-apps/pool/src/lib/mod.rs)
- Builds optional embedded JDS if `[jds]` config present (today only with `BitcoinCoreIpc` TP).
- Channel manager mediates between TP and downstream miners.
- Adds monitoring HTTP server (Prometheus-style metrics).

## Recent work pattern (relevant context)
Recent commits emphasize share accounting and observability:
- `stratum-apps: pre-seed spec-defined rejection codes in shares_rejected_total`
- Updates to `stratum-core` dependency

Suggests share-accounting semantics is being formalized — relevant when mapping p2poolv2's chain-with-uncles share counts onto SV2 metrics.
