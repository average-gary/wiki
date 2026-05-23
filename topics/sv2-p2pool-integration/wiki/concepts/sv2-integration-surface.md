---
title: SV2 integration surface (sv2-apps)
type: concept
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: warm
confidence: high
sources:
  - "[[raw/repos/2026-05-22-sv2-apps-repo|sv2-apps repo]]"
  - "[[raw/papers/2026-05-22-sv2-spec-job-declaration-protocol|SV2 spec: JDP]]"
---

# SV2 integration surface (sv2-apps)

The sv2-apps stack at `github.com/stratum-mining/sv2-apps` exposes three pluggable interfaces relevant for [[p2poolv2]] integration. Direct evidence from sv2-apps source code at `/Users/garykrause/repos/sv2-apps`.

## 1. `JobValidationEngine` trait — the natural plug-point

Defined at `sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/mod.rs`:

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

There is currently **one implementation**: `BitcoinCoreIPCEngine`. The trait is explicitly designed for modularity:

> This allows for modularity with regards to:
> - different Bitcoin Node implementations.
> - different ways to connect to the Bitcoin Node.

A `P2poolV2Engine` would be a clean second implementation: incoming `DeclareMiningJob` → validate against [[p2poolv2]]'s share-chain rules (block-shape, coinbase commitments, share PoW threshold) instead of bitcoind IPC.

Match between trait shape and p2poolv2 internals:
- `handle_declare_mining_job` ⟶ p2poolv2's `shares::validation`
- `handle_push_solution` ⟶ p2poolv2's `node` (libp2p gossip + Bitcoin block submission)
- `handle_set_custom_mining_job` ⟶ p2poolv2's `shares::handle_stratum_share` analog for SV2 mining-protocol channels

## 2. `TemplateProviderType` (stratum-apps)

Defined at `sv2-apps/stratum-apps/src/tp_type.rs`:

```rust
enum TemplateProviderType {
    BitcoinCoreIpc { network, data_dir, fee_threshold, min_interval },
    Sv2Tp { address, public_key },
}
```

This is the *upstream* template source. p2poolv2 currently uses bitcoind RPC + ZMQ; adopting `TemplateProviderType` would let p2poolv2 consume `NewTemplate`/`SetNewPrevHash` from any SV2 TP. A third variant `P2poolV2Backend { ... }` is conceivable but redundant if p2poolv2 just uses `Sv2Tp` mode.

## 3. `PoolSv2` orchestration

`sv2-apps/pool-apps/pool/src/lib/mod.rs` shows the integration shape:

- Optional embedded JDS if `[jds]` config present (today only with `BitcoinCoreIpc` TP)
- Channel manager mediates between TP and downstream miners
- Adds monitoring HTTP server (Prometheus-style metrics)

The pattern: **JDS is composed into Pool**, sharing a `task_manager` and `cancellation_token`. Same pattern would apply if a `P2poolV2Engine` were the JDS backend.

## 4. SV2 spec: Job Declaration Protocol

Per [[raw/papers/2026-05-22-sv2-spec-job-declaration-protocol|SV2 spec doc 06]]:

> Pools that opt into this protocol are only responsible for accounting shares and distributing rewards.

This precisely scopes what p2poolv2 must replace: **share accounting + reward distribution** is the only remaining centralized function once SV2 JDP is in place. p2poolv2's whole reason for existing is exactly this — see [[p2poolv2#differentiation-from-sv2--datum|p2poolv2's positioning]].

## Recent share-accounting work in sv2-apps

Recent commits emphasize formalizing share accounting:
- `stratum-apps: pre-seed spec-defined rejection codes in shares_rejected_total`
- Updates to `stratum-core` dependency

Suggests share-accounting semantics are being firmed up — relevant when mapping p2poolv2's chain-with-uncles share counts onto SV2 metrics.

## See also

- [[../topics/integration-paths|Integration paths]] — concrete options
- [[p2poolv2|p2poolv2]] — what's plugging in
- [[../decisions/_index|Decisions]] (TBD)
