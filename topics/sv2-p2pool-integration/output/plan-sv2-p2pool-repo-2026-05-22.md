---
title: "Plan: sv2-p2pool — vendor p2poolv2 + sv2-apps into a new SV2 Pool implementation"
type: plan
format: spec
sources:
  - "[[wiki/topics/share-accounting-mapping|SV2 ↔ p2poolv2 share-accounting mapping]]"
  - "[[wiki/topics/integration-paths|Integration paths]]"
  - "[[wiki/concepts/sv2-integration-surface|SV2 integration surface]]"
  - "[[wiki/concepts/p2poolv2|p2poolv2]]"
  - "[[wiki/concepts/stratum-v2-overview|Stratum V2 overview]]"
  - "[[wiki/decisions/open-questions|Open questions]]"
generated: 2026-05-22
status: proposed
---

# Plan: `sv2-p2pool` — new SV2 Pool implementation vendoring p2poolv2 + sv2-apps

## Executive summary

Build a new repo, `sv2-p2pool`, that assembles a complete SV2 mining pool binary by vendoring [stratum-mining/sv2-apps](https://github.com/stratum-mining/sv2-apps) (MIT/Apache-2.0) and [p2poolv2/p2poolv2](https://github.com/p2poolv2/p2poolv2) (AGPL-3.0) as git submodules. The pool replaces sv2-apps's `BitcoinCoreIPCEngine` with a `P2poolV2Engine` so SV2 miners — via JDC, or directly via SV2 mining-protocol channels — submit work that gets accounted on p2poolv2's decentralized share-chain.

Two architectural decisions distinguish this from the prior planning round:

1. **Full pool replacement, not just the JDS.** Phase 1 assembles `JobDeclarator` + `ChannelManager` + downstream listener directly, bypassing `PoolSv2::start()`. We don't need that orchestrator's hard-coded engine selection.

2. **p2poolv2 over Cap'n Proto IPC, mirroring bitcoin-core-sv2.** Rather than embedding `p2poolv2_lib` in-process (which forces our binary to AGPL and shares a process with the libp2p swarm), we propose adding a Cap'n Proto IPC server to p2poolv2 over a Unix socket — exactly the pattern `bitcoin-core-sv2` uses to talk to bitcoind. Our pool binary then talks to p2poolv2 the same way it talks to a Template Provider. Process isolation, lifecycle independence, and an upstream-friendly contribution.

Phase 1 ships the pool binary running against an in-process p2poolv2 (so we don't block on the IPC PR). Phase 2 lands the IPC PR upstream and switches the pool to use it.

---

## 1. System architecture

### 1.1 Repo layout

```
sv2-p2pool/                              # NEW REPO; AGPL-3.0
├── README.md
├── LICENSE                              # AGPL-3.0-or-later
├── Cargo.toml                           # workspace root
├── rust-toolchain.toml                  # 1.88 (MSRV from p2poolv2; >= sv2-apps's 1.85)
├── .gitmodules
├── vendor/
│   ├── sv2-apps/                        # submodule pinned to upstream commit
│   └── p2poolv2/                        # submodule pinned to upstream commit
├── crates/
│   ├── sv2-p2pool-engine/               # JobValidationEngine impl over p2pool
│   ├── sv2-p2pool-ipc/                  # capnp client (Phase 2; capnp schema in p2poolv2 PR)
│   └── sv2-p2pool-pool/                 # the pool binary (full replacement of PoolSv2)
├── config/
│   └── pool.example.toml
├── docker/
│   └── compose.signet.yaml              # bitcoind + p2poolv2 + sv2-p2pool, all signet
├── integration-tests/
│   └── tests/
└── docs/
    ├── architecture.md                  # 1-pager linking to the wiki
    └── verification.md
```

### 1.2 Vendoring strategy — what's a submodule, what's not

Only fork-prone or path-only deps are submodules. Everything else is a normal cargo dep pinned by `Cargo.lock`.

| Dep | Source | Why this choice |
|---|---|---|
| `sv2-apps` (`jd_server_sv2`, `pool_sv2`, `stratum-apps`, `bitcoin-core-sv2`) | **git submodule** at `vendor/sv2-apps/` | sv2-apps is path-only inside its own workspace. Submodule lets us pin a commit and locally hack if needed. |
| `p2poolv2_lib` (and future `p2poolv2_ipc`) | **git submodule** at `vendor/p2poolv2/` | Not published to crates.io. Also: we're filing a PR against this repo (the capnp IPC server). Submodule lets us iterate on a branch in place. |
| `stratum-core` | inherited via sv2-apps's own `Cargo.toml` (sv2-apps git-pins it upstream) | Our submodule pin on sv2-apps transitively pins stratum-core. Don't double-pin. |
| `capnp`, `capnp-rpc`, `bitcoin-capnp-types` | **crates.io**, pinned `=0.25.x` for capnp/capnp-rpc | Stable, MIT, well-maintained. No reason to fork. `Cargo.lock` reproduces builds; `=0.25.x` insulates from major-version churn that could break generated bindings. |
| `tokio`, `tower`, `tracing`, `dashmap`, `async-trait`, `anyhow`, etc. | **crates.io** | Standard ecosystem deps. |

**Generated capnp bindings** (the `*_capnp.rs` files produced from our `.capnp` schema) **are committed to the repo as source**. That is not vendoring — that is the normal capnp Rust workflow.

**Build reproducibility offline** is an orthogonal concern. If CI ever needs to build without internet, run `cargo vendor` once to write all crates.io deps into `vendor-cargo/` and configure cargo to read from it. Adopt that mechanism only when the requirement materializes; do not pre-add it.

**Rule of thumb**: vendor only what (a) cargo can't reach by name, or (b) we plan to patch. Capnp is neither.

### 1.3 Process topology (Phase 1, in-process)

```
┌──────────────────────────────────────────────────────────────────────┐
│  sv2-p2pool-pool (one process, AGPL)                                 │
│                                                                      │
│   ┌──────────────────────────┐    ┌─────────────────────────────┐    │
│   │ sv2-apps stack (vendored)│    │ p2poolv2_lib (vendored)     │    │
│   │                          │    │                             │    │
│   │  JobDeclarator           │    │  Node (libp2p swarm)        │    │
│   │  ChannelManager          │◀───┤  ChainStoreHandle           │    │
│   │  Downstream listener     │    │  ShareValidator             │    │
│   │  TemplateProvider client │    │  Accounting                 │    │
│   └─────────┬────────────────┘    └─────────────────────────────┘    │
│             │                                                        │
│             │ Arc<dyn JobValidationEngine>                           │
│             ▼                                                        │
│   ┌────────────────────────────────────────────┐                     │
│   │ sv2-p2pool-engine::P2poolV2Engine          │                     │
│   │   handle_declare_mining_job                │                     │
│   │   handle_set_custom_mining_job             │                     │
│   │   handle_push_solution                     │                     │
│   └────────────────────────────────────────────┘                     │
└──────────────────────────────────────────────────────────────────────┘
                              │
                              │ Bitcoin Core IPC (capnp over Unix socket)
                              ▼
                       ┌──────────────┐         ┌───────────────────────┐
                       │   bitcoind   │◀────────│  SV2 miner (JDC + MP) │
                       └──────────────┘         └───────────────────────┘
```

### 1.4 Process topology (Phase 2, IPC)

```
┌──────────────────────┐  capnp+UDS   ┌──────────────────────────────┐  capnp+UDS  ┌──────────┐
│ sv2-p2pool-pool      │◀────────────▶│ p2poolv2 daemon              │◀────────────│ bitcoind │
│ (MIT/Apache OR AGPL) │              │ (AGPL — own process)         │             └──────────┘
│ - JobDeclarator      │              │ - libp2p swarm               │
│ - ChannelManager     │              │ - ChainStoreHandle           │
│ - P2poolV2Engine     │              │ - new: capnp IPC server      │
│   (capnp client)     │              │   for share validation /     │
│                      │              │   template construction      │
└──────────────────────┘              └──────────────────────────────┘
```

In Phase 2, with p2poolv2 across a process boundary, our pool binary no longer links AGPL code — it can stay MIT/Apache if you want a sharable-with-sv2-apps codebase. (You explicitly said AGPL is fine; this is a side benefit.)

### 1.5 Component descriptions

- **`sv2-p2pool-engine`** — implements `JobValidationEngine` (defined at `vendor/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/mod.rs:29`). Phase 1 holds in-process handles to `p2poolv2_lib::node::Node` and `BitcoindRpcClient`. Phase 2 holds a `sv2-p2pool-ipc::Client` instead.
- **`sv2-p2pool-ipc`** — capnp generated bindings + thin Rust client. Materializes only after the p2poolv2 IPC PR lands. Schema is in p2poolv2's repo (mirroring how `bitcoin-capnp-types` is published from Bitcoin Core).
- **`sv2-p2pool-pool`** — the binary. Owns lifecycle: starts the p2poolv2 node (Phase 1) or connects to it (Phase 2), constructs the engine, builds `JobDeclarator::new(engine, ...)` directly, starts `ChannelManager`, runs the downstream listener.

---

## 2. API design

### 2.1 The `JobValidationEngine` impl (Phase 1)

```rust
// crates/sv2-p2pool-engine/src/lib.rs
use std::sync::Arc;
use async_trait::async_trait;
use dashmap::DashMap;

use jd_server_sv2::job_declarator::job_validation::{
    JobValidationEngine, DeclareMiningJobResult, SetCustomMiningJobResult,
};
use stratum_apps::{
    stratum_core::{
        bitcoin::ScriptBuf,
        job_declaration_sv2::{DeclareMiningJob, ProvideMissingTransactionsSuccess, PushSolution},
        mining_sv2::SetCustomMiningJob,
    },
    utils::types::JdToken,
};
use p2poolv2_lib::{
    bitcoindrpc::BitcoindRpcClient,
    shares::{
        chain::ChainStoreHandle,
        validation::ShareValidator,
    },
    accounting::Accounting,
};

pub struct P2poolV2Engine {
    chain: ChainStoreHandle,
    validator: Arc<dyn ShareValidator>,
    accounting: Arc<Accounting>,
    bitcoind: Arc<BitcoindRpcClient>,
    declared_jobs: Arc<DashMap<JdToken, DeclaredJobSnapshot>>,
    token_payout: Arc<DashMap<JdToken, ScriptBuf>>,
}

#[async_trait]
impl JobValidationEngine for P2poolV2Engine {
    async fn handle_declare_mining_job(
        &self,
        m: DeclareMiningJob<'_>,
        pmts: Option<ProvideMissingTransactionsSuccess<'_>>,
    ) -> DeclareMiningJobResult { /* ... */ }

    async fn handle_set_custom_mining_job(
        &self,
        m: SetCustomMiningJob<'_>,
        token: JdToken,
    ) -> SetCustomMiningJobResult { /* ... */ }

    async fn handle_push_solution(&self, m: PushSolution<'_>) { /* ... */ }
}
```

**Method bodies follow the message-by-message mapping in [[wiki/topics/share-accounting-mapping#mapping-table]].** The implementation mirrors `vendor/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/bitcoin_core_ipc.rs:404-867` line-for-line, swapping the bitcoind IPC calls for `validator.validate_block_template(...)` and `chain_store.handle.is_current()`.

### 2.2 The Cap'n Proto IPC schema (Phase 2)

Modeled on `bitcoin-capnp-types` (the schema package Bitcoin Core publishes for `bitcoin-core-sv2`). Lives in the p2poolv2 repo as a new crate `p2poolv2-capnp-types`, published independently to crates.io. Our `sv2-p2pool-ipc` crate consumes it as a normal cargo dep.

Minimal schema (proposed for upstream PR):

```capnp
# p2poolv2.capnp — proposed for github.com/p2poolv2/p2poolv2

@0xc0ffee...;  # generate fresh

interface ShareChain {
    # Validate a candidate block template against the share-chain tip.
    # Used by handle_declare_mining_job.
    validateTemplate @0 (
        coinbasePrefix :Data,
        coinbaseSuffix :Data,
        wtxidList      :List(Data),
        missingTxs     :List(Data),
    ) -> (result :ValidationResult);

    # Submit a found Bitcoin block solution.
    # Used by handle_push_solution.
    submitSolution @1 (
        rawBlock :Data,
        shareHash :Data,  # block-finder share for accounting
    ) -> (accepted :Bool);

    # Subscribe to share-chain tip changes.
    # Used to fire the (proposed) notify_share_chain_reorg trait extension.
    subscribeChainTip @2 (callback :ChainTipCallback);
}

struct ValidationResult {
    union {
        ok                  @0 :Void;
        staleChainTip       @1 :Void;
        invalidCoinbase     @2 :Text;
        missingTransactions @3 :List(Data);  # wtxids
    }
}

interface ChainTipCallback {
    onNewTip @0 (newTipHash :Data) -> ();
}
```

This maps 1:1 onto the trait methods. The schema is intentionally narrow; it does NOT expose the libp2p swarm or any P2P-mesh internals.

### 2.3 Pool binary entry point

```rust
// crates/sv2-p2pool-pool/src/main.rs (sketch)
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let cfg = Config::load()?;
    let cancellation = CancellationToken::new();
    let task_manager = Arc::new(TaskManager::new());

    // 1. Phase 1: start p2poolv2 in-process; Phase 2: connect over IPC.
    let p2pool = match cfg.p2pool_mode {
        Mode::InProcess(p) => P2poolBackend::start_embedded(p).await?,
        Mode::Ipc(addr)    => P2poolBackend::connect_ipc(addr).await?,
    };

    // 2. Build the engine over whichever backend.
    let engine: Arc<dyn JobValidationEngine> = Arc::new(
        P2poolV2Engine::new(p2pool.handles())
    );

    // 3. Build the JDS via JobDeclarator::new — bypassing PoolSv2::start().
    let jd = JobDeclarator::new(
        engine,
        cancellation.clone(),
        cfg.coinbase_reward_script(),
        task_manager.clone(),
    ).await?;
    jd.clone().start(cancellation.clone(), task_manager.clone()).await?;
    jd.clone().start_downstream_server(
        cfg.jds.authority_pk, cfg.jds.authority_sk, cfg.jds.cert_validity_sec,
        cfg.jds.listen_address, task_manager.clone(), cancellation.clone(),
        cfg.jds.supported_extensions, cfg.jds.required_extensions,
    ).await?;

    // 4. Build the miner-facing ChannelManager using the same engine path.
    let channel_manager = ChannelManager::new(
        cfg.pool.clone(),
        /* tp channels */, /* downstream channel */,
        cfg.coinbase_outputs(),
        Some(jd.clone()),
    ).await?;
    channel_manager.start(cancellation.clone(), task_manager.clone(), cfg.coinbase_outputs()).await?;
    channel_manager.start_downstream_server(/* ... */).await?;

    // 5. Wait + graceful shutdown.
    tokio::select! {
        _ = tokio::signal::ctrl_c() => cancellation.cancel(),
        _ = cancellation.cancelled() => {}
    }
    task_manager.join_all().await;
    Ok(())
}
```

**Critical**: this never calls `PoolSv2::start()`. We assemble the parts ourselves, which is what "full pool replacement" buys us — we control engine selection without forking sv2-apps.

---

## 3. Data model

### 3.1 Token allocation

The `JobValidationEngine` trait does NOT handle `AllocateMiningJobToken` — that's upstream of the engine. The JDS itself manages the token table. We need to extend it with a `(token → payout-script)` binding so `handle_push_solution` knows which p2pool miner to credit.

**Proposal**: a parallel `Arc<DashMap<JdToken, ScriptBuf>>` populated at `AllocateMiningJobToken` time, owned by the binary, passed by reference into the engine. This map is the only state our engine introduces beyond what the reference impl uses.

### 3.2 Declared-job cache

Mirror the reference impl exactly: `Arc<DashMap<JdToken, DeclaredJobSnapshot>>` where `DeclaredJobSnapshot` carries the validated coinbase prefix/suffix, wtxid list, and a `validated: bool`. Used for cross-checking `SetCustomMiningJob` against the previously-declared job. (See `vendor/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_validation/bitcoin_core_ipc.rs:415-440`.)

### 3.3 Storage

p2poolv2's rocksdb stays inside p2poolv2. Our pool binary holds zero persistent state of its own in Phase 1. (Token tables are in-memory; tokens are short-lived per the JDP spec.)

### 3.4 Config

```toml
# config/pool.example.toml
[pool]
listen_address = "0.0.0.0:34254"
authority_secret_key = "..."
authority_public_key = "..."
cert_validity_sec = 3600
coinbase_reward_script = "..."  # only used as fallback; payouts are p2pool-driven

[jds]
listen_address = "0.0.0.0:34264"
supported_extensions = []
required_extensions = []

[p2pool]
mode = "embedded"  # or "ipc"
# embedded:
config_path = "./vendor-config/p2pool.toml"  # passed to p2poolv2_lib::config
# ipc (Phase 2):
# socket = "/var/run/p2poolv2.sock"

[bitcoind]
url = "http://localhost:38332"
user = "..."
password = "..."
zmq_block = "tcp://localhost:28332"

[monitoring]
listen_address = "127.0.0.1:9090"
cache_refresh_secs = 15
```

---

## 4. Implementation details

### 4.1 Submodule pinning

```
git submodule add https://github.com/stratum-mining/sv2-apps  vendor/sv2-apps
git submodule add https://github.com/p2poolv2/p2poolv2        vendor/p2poolv2
```

Pin specific commits. Document upgrade procedure in `docs/architecture.md`: bumps require running the integration tests in `integration-tests/`.

Workspace `Cargo.toml`:

```toml
[workspace]
members = [
    "crates/sv2-p2pool-engine",
    "crates/sv2-p2pool-ipc",
    "crates/sv2-p2pool-pool",
    "vendor/sv2-apps/pool-apps/pool",
    "vendor/sv2-apps/pool-apps/jd-server",
    "vendor/sv2-apps/miner-apps/jd-client",
    "vendor/sv2-apps/miner-apps/translator",
    "vendor/sv2-apps/stratum-apps",
    "vendor/sv2-apps/bitcoin-core-sv2",
    "vendor/p2poolv2/p2poolv2_lib",
    "vendor/p2poolv2/p2poolv2_node",
    # ... transitively per the vendored workspaces
]
resolver = "2"

[workspace.dependencies]
# Pin the small surface we directly reference; let vendored crates pull the rest.
capnp     = "=0.25"
capnp-rpc = "=0.25"
async-trait = "0.1"
dashmap   = "6"
tokio     = { version = "1.44", features = ["full"] }
tracing   = "0.1"
anyhow    = "1"
```

Notable: workspace inclusion means our top-level `cargo check` builds vendored code too — useful for catching dep conflicts early. Open question 8 below tracks the workspace-merge spike.

### 4.2 Mapping the trait — by reference

The complete message-level mapping is at [[wiki/topics/share-accounting-mapping#mapping-table|share-accounting-mapping]]. Key callouts:

- **`SubmitSharesError` codes** — the seven canonical SV2 codes (`stratum-apps/src/monitoring/snapshot_cache.rs:45-74`) map onto p2poolv2 validation predicates, with one critical asymmetry: a share that fails p2poolv2's longest-chain rule may still be admitted as an *uncle*. **Do not emit `stale-share` for uncle-admitted shares.**
- **`SubmitSharesSuccess.new_shares_sum`** — flat-weighted in SV2; uncle-weighted in p2poolv2. Engine-level reconciliation TBD; tracked as repo issue.
- **`PushSolution`** — fire-and-forget in the reference impl. We must (a) submit raw block to bitcoind, (b) tag the corresponding share as block-finder so accounting credits the bonus.

### 4.3 Race conditions to handle

From [[wiki/decisions/open-questions]]:

- **`PushSolution` arrives before `SubmitSharesExtended`** — possible because they travel separate paths. Solution: buffer recently-found-block share-hashes for ~30s; on share-submission match, retroactively tag.
- **Share-chain reorg under in-flight tokens** — propose a `notify_share_chain_reorg(new_tip)` trait extension to sv2-apps. Until then, we detect via periodic polling of `chain.is_current()` in the engine and invalidate cached `declared_jobs` whose ancestry is dead.

### 4.4 IPC PR to p2poolv2 (Phase 2)

Open as a new issue + draft PR:
- New crate `p2poolv2_ipc` with capnp schema + capnp-rpc server actor.
- Wires into existing `p2poolv2_node` lifecycle alongside the libp2p swarm.
- Unix-socket-only by default (no TCP exposure); opt-in TCP behind a feature flag.
- Schema lives at `p2poolv2_ipc/proto/p2poolv2.capnp`, generated bindings at `p2poolv2_ipc/src/generated/`.
- Companion crate `p2poolv2-capnp-types` published to crates.io so external implementers (us, others) can depend on the schema without vendoring p2poolv2.

This PR is the most significant upstream contribution; the sv2-p2pool repo is its motivating use case.

### 4.5 License notes

- `LICENSE` at root: `AGPL-3.0-or-later`.
- Each crate's `Cargo.toml`: `license = "AGPL-3.0-or-later"`.
- README declares: links to `p2poolv2_lib` (AGPL-3.0); the `vendor/sv2-apps/` submodule remains MIT/Apache-2.0 in isolation.
- Phase 2 (IPC): the pool binary no longer links AGPL code. It can be re-licensed MIT/Apache if you want sv2-apps reusability — track as a Phase-2 followup.
- AGPL §13 obligation: when running the pool publicly, source must be available to network users. Public Git host satisfies this.

---

## 5. Implementation phases

### Phase 0 — Repo bootstrap (1 day)
- `cargo new --workspace`, set up `crates/sv2-p2pool-engine`, `crates/sv2-p2pool-pool`.
- Add submodules; pin commits.
- LICENSE, README, rust-toolchain, .gitignore, codecov.
- **Spike open question 8**: confirm `[workspace] members = ["vendor/..."]` does not collide with the vendored workspaces' own `[workspace]` declarations.
- Verify: `cargo check --workspace` builds vendored crates from submodules.

### Phase 1 — In-process engine + full pool binary (2-3 weeks)
- Implement `P2poolV2Engine` mirroring `BitcoinCoreIPCEngine` 1:1.
- Build `sv2-p2pool-pool` binary that bypasses `PoolSv2::start()`.
- Per-message tests against the wiki's mapping spec (recorded SV2 frames as fixtures).
- Signet smoke test: bitcoind + sv2-p2pool-pool + sv2-apps's jd-client. Confirm a `DeclareMiningJob → DeclareMiningJobSuccess` round-trip and an end-to-end share submission.
- File the 7 design questions from `decisions/open-questions.md` as repo issues.

### Phase 2 — Cap'n Proto IPC (3-4 weeks, dependent on upstream)
- Open issue + draft PR on p2poolv2/p2poolv2 for capnp IPC server.
- Add `crates/sv2-p2pool-ipc` with capnp client.
- Wire the IPC variant in the binary (`p2pool.mode = "ipc"`).
- Run pool binary against a separate p2poolv2 daemon process. Verify same signet smoke test passes.
- Optional: re-license pool binary MIT/Apache if upstream lands.

### Phase 3 — Production hardening (open-ended)
- Address each repo issue from Phase 1.
- Performance: per-message latency, share-validation throughput.
- Observability: integrate sv2-apps's monitoring (`stratum-apps/src/monitoring`) with our own metrics.
- Multi-machine deployment recipes (docker-compose, k8s helm chart).

---

## 6. Testing strategy

| Layer | Tool | What it catches |
|---|---|---|
| Type / trait | `cargo check` | Engine satisfies `JobValidationEngine` |
| Unit | `cargo test -p sv2-p2pool-engine` | Each `handle_*` method against canned SV2 frame fixtures |
| Integration | `integration-tests/` borrowing patterns from `vendor/sv2-apps/integration-tests/` | Multi-actor flows: jd-client ↔ our JDS ↔ p2poolv2 ↔ bitcoind |
| Smoke | docker-compose signet | End-to-end on signet; one `DeclareMiningJob` + one share submission |
| Fuzz | `cargo-fuzz` over engine method inputs | Crash resistance to malformed SV2 frames |

End-to-end smoke procedure:

1. `git submodule update --init --recursive`
2. `docker compose -f docker/compose.signet.yaml up -d`
3. `cargo run --release -p sv2-p2pool-pool -- --config config/pool.example.toml`
4. From sv2-apps: `cargo run -p jd_client_sv2 -- --config /path/to/jdc.toml` (pointing at our JDS port)
5. Verify in logs: `DeclareMiningJobSuccess`, share-chain tip advanced, share accounted.
6. Force a share-chain reorg in p2poolv2 and confirm cached tokens are invalidated.

---

## 7. Risks & mitigations

| Risk | Source | Mitigation |
|---|---|---|
| Variance economics dominate ideology — pool gets no hashrate | [[wiki/topics/why-decentralized-pools-struggle]] | Out of scope for repo; flag in README |
| Bandwidth ceiling at share-chain scale | Delving Bitcoin (ajtowns) | Inherit p2poolv2's design constraints; not solved here |
| p2poolv2 evolves fast → vendored commit rots | wiki/concepts/p2poolv2 (release cadence) | Submodule pin + scheduled bump-and-test cycle |
| sv2-apps `JobValidationEngine` trait shape changes | sv2-apps active dev | Pin sv2-apps commit until trait stabilizes |
| `BitcoindRpcClient` is concrete in p2poolv2 → hard to test | Explore phase 2 | Open p2poolv2 PR to abstract it; repo issue tracks |
| IPC PR rejected by p2poolv2 maintainers | Phase 2 dependency | Phase 1 doesn't need the PR; can stay in-process indefinitely |
| Duplicating sv2-apps's `ChannelManager` semantics is fragile | full-pool-replacement choice | Vendor `ChannelManager` directly from sv2-apps workspace; don't fork |
| capnp 0.26 bumps break generated bindings | crates.io dep churn | `=0.25.x` pin in workspace deps; bump deliberately with a passing CI run |

---

## 8. Open questions

From [[wiki/decisions/open-questions]] — file as repo issues at creation:

1. Uncle-weighting in `SubmitSharesSuccess.new_shares_sum`.
2. `JdToken` ↔ payout-script binding location and persistence.
3. Token revocation on share-chain reorg (proposed trait extension to sv2-apps).
4. Coinbase-only declaration handling (p2poolv2 likely requires full wtxid list).
5. `PushSolution` ↔ `SubmitSharesExtended` race.
6. `BitcoindRpcClient` trait abstraction (proposed PR to p2poolv2).
7. Capnp IPC schema review with p2poolv2 maintainers.

Plus newly surfaced:

8. **Workspace inclusion of vendored crates** — does `[workspace] members = ["vendor/..."]` cause version-resolver headaches with the vendored workspaces' own `[workspace]` declarations? Spike in Phase 0.
9. **MSRV alignment** — sv2-apps is 1.85, p2poolv2 is 1.88. Pick 1.88 root-toolchain; verify sv2-apps still builds.
10. **Schema crate hosting** — should the capnp schema crate be hosted in p2poolv2 (their preferred), in sv2-p2pool, or independently published? Decide before opening the PR.

---

## 9. Sources consulted

- [[wiki/topics/share-accounting-mapping]] — primary spec for the engine impl
- [[wiki/topics/integration-paths]] — confirms full-pool-replacement is Path B (extended)
- [[wiki/concepts/sv2-integration-surface]] — `JobValidationEngine`, `JobDeclarator::new`, `PoolSv2`
- [[wiki/concepts/p2poolv2]] — p2poolv2_lib structure, AGPL, libp2p constraint
- [[wiki/concepts/stratum-v2-overview]] — JDP, JDC, JDS roles
- [[wiki/decisions/open-questions]] — issue backlog
- Direct code reads (this session): `bitcoin_core_ipc.rs:404-867`, `mod.rs:29` (JobValidationEngine trait), `mod.rs:91-110` (PoolSv2::start engine selection), `bitcoin-core-sv2/Cargo.toml` (capnp deps), p2poolv2 `p2poolv2_api/src/api/server.rs` (no submit endpoints)
- New research (this session): p2poolv2 has read-only HTTP+WS API only; no IPC submission endpoint exists; adding capnp IPC is small-to-moderate; bitcoin-core-sv2 uses `capnp = "0.25"` + `capnp-rpc = "0.25"` over Unix sockets.

---

## 10. Inventory follow-ups

Suggested durable items to add to the wiki's inventory:

- **Watch**: p2poolv2 release cadence (bump submodule when new releases land).
- **Watch**: sv2-apps `JobValidationEngine` trait changes (pin until stable).
- **Watch**: capnp 0.25 → 0.26 migration cost when it lands.
- **Candidate corpus**: p2poolv2 maintainer Matrix room — for early review of the IPC schema PR before opening it.
- **Open question**: should the capnp schema crate be hosted in p2poolv2 (their preferred), in sv2-p2pool, or independently published? Decide before opening the PR.
