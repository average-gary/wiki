---
title: SV2 ↔ p2poolv2 share-accounting mapping spec
type: topic
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: hot
confidence: high
status: draft
sources:
  - "[[raw/papers/2026-05-22-sv2-spec-job-declaration-protocol|SV2 spec: 06 JDP]]"
  - "[[raw/repos/2026-05-22-p2poolv2-module-map|p2poolv2 module map]]"
  - "[[raw/papers/2026-05-22-p2poolv2-tla-sharechain-spec|p2poolv2 TLA+ ShareChain spec]]"
  - "[[raw/repos/2026-05-22-sv2-apps-repo|sv2-apps repo]]"
verified_against:
  - "/Users/garykrause/repos/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/mod.rs"
  - "/Users/garykrause/repos/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/bitcoin_core_ipc.rs"
  - "/Users/garykrause/repos/sv2-apps/stratum-apps/src/monitoring/snapshot_cache.rs"
---

# SV2 ↔ p2poolv2 share-accounting mapping spec

Detailed mapping between SV2's share-accounting messages and p2poolv2's chain-with-uncles share-chain. Suitable for an implementer writing a `JobValidationEngine` for p2poolv2.

The structure mirrors the existing `BitcoinCoreIPCEngine` reference at `pool-apps/jd-server/src/lib/job_declarator/job_validation/bitcoin_core_ipc.rs:1-867` — the only thing that changes is the *backend* of the validation predicates.

## SV2 message inventory (relevant subset)

### Mining Protocol (spec 05)

| Message | Role |
|---|---|
| `OpenStandardMiningChannel` / `OpenExtendedMiningChannel` | Open per-miner accounting channel; carries `user_identity`, `nominal_hash_rate`, `max_target` |
| `NewMiningJob` / `NewExtendedMiningJob` | Server-to-miner job |
| `SetTarget` | Update per-channel difficulty |
| `SetNewPrevHash` | Invalidate older jobs on Bitcoin tip change |
| `UpdateChannel` | Renegotiate hashrate/target |
| `SubmitSharesStandard` / `SubmitSharesExtended` | Share submission |
| `SubmitSharesSuccess` | `{channel_id, last_sequence_number, new_submits_accepted_count, new_shares_sum}` |
| `SubmitSharesError` | `{channel_id, sequence_number, error_code}` |

### Canonical SV2 share-rejection codes

Verified at `stratum-apps/src/monitoring/snapshot_cache.rs:45-74` (recently added):

```
ERROR_CODE_SUBMIT_SHARES_INVALID_CHANNEL_ID
ERROR_CODE_SUBMIT_SHARES_INVALID_SHARE
ERROR_CODE_SUBMIT_SHARES_STALE_SHARE
ERROR_CODE_SUBMIT_SHARES_INVALID_JOB_ID
ERROR_CODE_SUBMIT_SHARES_DIFFICULTY_TOO_LOW
ERROR_CODE_SUBMIT_SHARES_DUPLICATE_SHARE
ERROR_CODE_SUBMIT_SHARES_BAD_EXTRANONCE_SIZE
```

These are pre-seeded into the `sv2_*_shares_rejected_total` Prometheus GaugeVec — the monitoring contract a p2poolv2 backend must populate.

### JDP (spec 06) — coupling messages

- **`DeclareMiningJob`** — JDC declares a custom job. Fields: `request_id`, `mining_job_token`, `version`, `coinbase_tx_prefix`, `coinbase_tx_suffix`, `wtxid_list`. Verified at `bitcoin_core_ipc.rs:425-492`.
- **`DeclareMiningJobSuccess`** / **`Error`** — error codes from `job_declaration_sv2`: `INVALID_MINING_JOB_TOKEN`, `INVALID_COINBASE_TX`, `INVALID_COINBASE_TX_INPUT`, `STALE_CHAIN_TIP`, `INTERNAL_ERROR` (verified `bitcoin_core_ipc.rs:32-37`).
- **`ProvideMissingTransactions`** / **`Success`** — JDS asks for body bytes of unknown wtxids.
- **`PushSolution`** — JDC announces a found block. Verified `bitcoin_core_ipc.rs:639-653` — fire-and-forget propagation.

### `SetCustomMiningJob` (Mining Protocol, bound to JDP token)

Fields: `channel_id`, `request_id`, `token`, `version`, `prev_hash`, `min_ntime`, `nbits`, `coinbase_tx_version`, `coinbase_prefix`, `coinbase_tx_input_n_sequence`, `coinbase_tx_outputs`, `coinbase_tx_locktime`, `merkle_path`. Verified `bitcoin_core_ipc.rs:711-862`.

Error codes (`bitcoin_core_ipc.rs:39-50`): `INVALID_MINING_JOB_TOKEN`, `JOB_NOT_YET_VALIDATED`, `STALE_CHAIN_TIP`, `INVALID_NBITS`, `INVALID_VERSION`, `INVALID_COINBASE_TX`, `INVALID_COINBASE_PREFIX`, `INVALID_COINBASE_TX_VERSION`, `INVALID_COINBASE_TX_INPUT_N_SEQUENCE`, `INVALID_COINBASE_TX_OUTPUTS`, `INVALID_COINBASE_TX_LOCKTIME`, `INVALID_MERKLE_PATH`.

## p2poolv2 share-handling inventory

From [[../concepts/p2poolv2|p2poolv2 module map]]:

- `shares/handle_stratum_share.rs` — single entry point from V1 stratum into share-chain
- `shares/validation/` — share-chain rule validation
- `shares/share_block/` — full block-shaped share objects (GBT-style)
- `shares/share_commitment.rs` — commits a share to its parent share-chain tip
- `shares/witness_commitment.rs` — segwit commitment
- `shares/coinbaseaux_flags.rs` — auxiliary flags in coinbase
- `shares/chain/` — longest-share-chain rule with uncles
- `shares/extranonce.rs` — extranonce reservation
- `shares/transactions/`, `shares/compact_block.rs`
- `accounting/` — share accounting / payout selection

TLA+ spec covers: share generation, share validation, longest-share-chain rule, uncle organization. Payout, network protocol, and SV2 integration are NOT formally specified.

## Mapping table

| SV2 message | p2poolv2 action | `JobValidationEngine` method | Confidence |
|---|---|---|---|
| `OpenStandardMiningChannel` / `OpenExtendedMiningChannel` | Register `(channel_id → miner-payout-script)`; reserve extranonce range from `shares::extranonce` | **out of scope for trait** (sibling `Sv2MiningServer`) | High |
| `NewMiningJob` / `NewExtendedMiningJob` | Translate share-chain tip + uncle set + p2pool coinbase outputs into extended job | **out of scope for trait** | High |
| `SubmitSharesStandard` / `SubmitSharesExtended` | Reconstruct candidate `ShareBlock`; `shares::handle_stratum_share` → `shares::validation::validate(...)`; on Ok, gossip via `node` libp2p + credit `accounting` | **out of scope for trait** (`ChannelManager`) | High |
| `SubmitSharesSuccess` | After share admitted (incl. uncle); aggregate using uncle weighting | response | Med — uncle weighting is OPEN |
| `SubmitSharesError` | Validation failure path. See rejection-code mapping below | response | High |
| `SetCustomMiningJob` | Re-validate declared job against share-chain tip via `shares::validation::validate_block_template`; cache binding | **`handle_set_custom_mining_job`** | High |
| `DeclareMiningJob` (JDP) | Validate coinbase shape, segwit commitment, p2pool payout outputs match `accounting::payout_selection`, validate wtxid_list against share-chain's tx-selection policy; if any wtxid unknown emit `MissingTransactions(Vec<Wtxid>)` | **`handle_declare_mining_job`** | High |
| `ProvideMissingTransactions(Success)` | Same handler resumes validation with supplied `Vec<Transaction>` (mirrors `bitcoin_core_ipc.rs:494-512`) | **`handle_declare_mining_job`** | High |
| `PushSolution` (JDP) | Submit raw block via `bitcoindrpc`; mark corresponding share as block-finder; trigger payout-selection finalization | **`handle_push_solution`** | High |
| `SetTarget` | Update channel-difficulty in `pool_difficulty.rs` / `stratum::difficulty_adjuster`. (Channel-difficulty ≠ share-chain difficulty) | **out of scope for trait** | High |
| `SetNewPrevHash` (Mining) | Invalidate per-channel job cache; share-chain tip refresh | **out of scope for trait** (may need extension) | Med |

### Mapping of SV2 share-rejection codes onto p2poolv2 validation predicates

| SV2 `error_code` | p2poolv2 cause | Likely source |
|---|---|---|
| `invalid-channel-id` | Unknown `Sv2ChannelRegistry` entry | `Sv2MiningServer` |
| `invalid-share` | Consensus-rule failure not covered below (bad commitment, witness commitment, malformed coinbase) | `shares/validation/` |
| `stale-share` | `prev_hash` (Bitcoin) or share-chain parent no longer on longest share-chain | `shares::chain::is_on_longest_chain()` |
| `invalid-job-id` | `job_id` not in per-channel job cache | `Sv2MiningServer` |
| `difficulty-too-low` | PoW does not meet share-target | `shares::validation::check_pow` |
| `duplicate-share` | `(channel_id, sequence_number)` or share-hash already seen | per-channel dedup + `shares::chain` membership |
| `bad-extranonce-size` | Extranonce length disagrees with channel's reserved range | `shares::extranonce` |

### Critical note: uncles

p2poolv2's chain-with-uncles means a share that fails the *longest-chain* test may still be admissible as an **uncle**. SV2 has no "accepted-as-uncle" code.

**Recommendation**: Count uncle admissions toward `new_shares_sum` (uncle-weighted) and **do NOT** emit `stale-share` for shares that are admitted as uncles. This is an isomorphism gap between the two share-accounting models.

## Recommended `JobValidationEngine` skeleton

```rust
// crate: p2poolv2_jds_engine
use stratum_apps::{
    stratum_core::{
        bitcoin::Wtxid,
        job_declaration_sv2::{
            DeclareMiningJob, ProvideMissingTransactionsSuccess, PushSolution,
            ERROR_CODE_DECLARE_MINING_JOB_INTERNAL_ERROR,
            ERROR_CODE_DECLARE_MINING_JOB_INVALID_COINBASE_TX,
            ERROR_CODE_DECLARE_MINING_JOB_INVALID_COINBASE_TX_INPUT,
            ERROR_CODE_DECLARE_MINING_JOB_INVALID_MINING_JOB_TOKEN,
            ERROR_CODE_DECLARE_MINING_JOB_STALE_CHAIN_TIP,
        },
        mining_sv2::SetCustomMiningJob,
    },
    utils::types::JdToken,
};
use p2poolv2_lib::{
    accounting::Accounting,
    bitcoindrpc::Client as BitcoinClient,
    shares::{
        chain::ShareChain,
        validation::{validate_block_template, ValidateOutcome},
    },
};

pub struct P2poolV2Engine {
    share_chain: Arc<ShareChain>,
    accounting: Arc<Accounting>,
    bitcoin: Arc<BitcoinClient>,
    /// (token -> declared job snapshot); mirrors BitcoinCoreIPCEngine::declared_custom_jobs
    declared_jobs: Arc<DashMap<JdToken, DeclaredJobSnapshot>>,
    /// (token -> payout script); populated by upstream AllocateMiningJobToken handler
    token_payout: Arc<DashMap<JdToken, ScriptBuf>>,
}

#[async_trait::async_trait]
impl JobValidationEngine for P2poolV2Engine {
    async fn handle_declare_mining_job(
        &self,
        m: DeclareMiningJob<'_>,
        pmts: Option<ProvideMissingTransactionsSuccess<'_>>,
    ) -> DeclareMiningJobResult {
        // 1. decode token (mirror bitcoin_core_ipc.rs:431-442)
        // 2. reconstruct + sanity-check declared coinbase tx (must have exactly one input)
        // 3. validate p2pool-specific coinbase-output constraints:
        //    - witness commitment present (shares::witness_commitment)
        //    - p2pool payout outputs match accounting::payout_selection for current tip
        //    - share-commitment output present (shares::share_commitment)
        // 4. resolve missing wtxids; emit MissingTransactions if any unknown
        // 5. validate_block_template against share-chain tip:
        //    - Ok           => store validated snapshot, return Success
        //    - StaleTip     => return Error(STALE_CHAIN_TIP)
        //    - Invalid(_)   => return Error(INVALID_COINBASE_TX) [code refinement OPEN]
    }

    async fn handle_set_custom_mining_job(
        &self,
        m: SetCustomMiningJob<'_>,
        token: JdToken,
    ) -> SetCustomMiningJobResult {
        // Mirror bitcoin_core_ipc.rs:664-865 line-for-line:
        // 1. lookup declared job by token; remove from cache (one-shot consumption)
        // 2. require validated == true
        // 3. compare prev_hash, nbits, version, coinbase_*, merkle_path
        // 4. each mismatch -> precise SET_CUSTOM_MINING_JOB_* error code
        // 5. p2poolv2 extension: also compare merkle_path against share-chain-derived txid_list
    }

    async fn handle_push_solution(&self, m: PushSolution<'_>) {
        // 1. reconstruct full Bitcoin block from solution + last-validated job
        // 2. self.bitcoin.submit_block(...) — fire-and-forget
        // 3. tag corresponding share as block-finder so accounting::on_block_found(share_hash) credits the bonus
        // 4. trigger payout-selection finalization for the share window
    }

    fn shutdown(&self) { /* flush in-memory token map; share-chain persists via store/ */ }
}
```

The skeleton matches the reference impl one-for-one in trait method bodies, replacing the Cap'n Proto IPC round-trip with synchronous calls into `p2poolv2_lib::shares`.

## Open questions

1. **OPEN — specs 05 and 07 not directly fetched.** Field-level details for `OpenExtendedMiningChannel`, `NewExtendedMiningJob`, `SubmitSharesExtended`, and TDP messages need verification against canonical spec text.
2. **OPEN — `ShareBlock` field list.** The exact data structure of p2poolv2's share, validation predicate signature, and uncle-tracking data structure should be read directly from the source.
3. **OPEN — uncle weighting in SV2 metrics.** SV2's `new_shares_sum` is a flat-weighted scalar; p2poolv2 distinguishes main-chain shares from uncles. How does `SubmitSharesSuccess.new_shares_sum` aggregate them? May need a richer return type from `JobValidationEngine`.
4. **OPEN — `JdToken` ↔ payout-script binding.** The current trait does NOT handle `AllocateMiningJobToken`; the (token → payout-script) map must live upstream in the JDS. Persistence semantics need design.
5. **OPEN — token revocation on share-chain reorg.** Trait has no callback. Likely needs an extension method `notify_share_chain_reorg(new_tip)`.
6. **OPEN — coinbase-only mode.** p2poolv2's GBT-style validation almost certainly requires the full wtxid list. Coinbase-only declarations may have to be rejected — needs a decision.
7. **OPEN — `PushSolution` ordering.** Race between `PushSolution` and the corresponding `SubmitSharesExtended` is not addressed in the reference impl (fire-and-forget). p2poolv2 must handle it (block-finder credit must not be lost).

## See also

- [[integration-paths|Integration paths]] — Path A is the trait-fit story above
- [[../concepts/sv2-integration-surface|SV2 integration surface]] — `JobValidationEngine` definition
- [[../concepts/p2poolv2|p2poolv2 internals]]
