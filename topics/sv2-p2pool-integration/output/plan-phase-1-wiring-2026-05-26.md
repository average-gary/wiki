---
title: "Plan: Phase 1 wiring — connect RecentSolutions, reorg_detector, and P2poolV2Engine into the pool binary"
type: plan
format: roadmap
sources:
  - "[[wiki/topics/share-accounting-mapping|SV2 ↔ p2poolv2 share-accounting mapping]]"
  - "[[wiki/topics/integration-paths|Integration paths]]"
  - "[[wiki/concepts/sv2-integration-surface|SV2 integration surface]]"
  - "[[wiki/concepts/p2poolv2|p2poolv2]]"
  - "[[output/plan-sv2-p2pool-repo-2026-05-22|sv2-p2pool repo spec]]"
  - "[[output/plan-swarm-issues-2026-05-25|Swarm completion roadmap]]"
  - "ADRs 0001 (uncle weighting), 0002 (jdtoken→payout-script), 0004 (coinbase-only mode), 0010 (capnp schema hosting) on main"
generated: 2026-05-26
status: proposed
---

# Plan: Phase 1 wiring — connect `RecentSolutions`, `reorg_detector`, and `P2poolV2Engine` into the pool binary

> Generated from the [sv2-p2pool-integration wiki](../_index.md) (8 articles + 4 ADRs + 2 prior plans + 9 closed GitHub issues consulted).

## Executive summary

The autonomous swarm shipped four Phase-1 pieces in isolation: `RecentSolutions` (PR #17), `reorg_detector` + `DeclaredJobCache` (PR #21), the engine skeleton (`P2poolV2Engine` with `{start,stop}_reorg_watcher`), and the upstream trait extension (`notify_share_chain_reorg`, on the sv2-apps fork). What's missing is the **pool binary** that hosts these, plus the **`JobValidationEngine` method bodies** translating SV2 messages into share-chain calls. This plan threads them all together into a runnable signet-class binary, validated against bitcoind regtest.

Three interlocking decisions drive the work:
1. **Full pool replacement** (not JDS-only): the binary assembles `JobDeclarator` + `ChannelManager` + downstream listener directly, bypassing `PoolSv2::start()`.
2. **Token-allocation interceptor**: a thin wrapper around `JobDeclarator` populates the `(JdToken → ScriptBuf)` map at allocation time. No upstream PR needed for Phase 1.
3. **Phase-1 integration branches on both forks**: stable submodule pointers during dev. Avoids per-PR submodule churn.

Validation: **regtest harness** with bitcoind + p2poolv2 node + sv2-p2pool binary + sv2-apps `jd-client`. End-to-end DeclareMiningJob → Success → SubmitSharesExtended → block-finder credit.

Execution: **iterative in-conversation**, not another swarm.

## Architecture decisions

### Decision 1: Full pool replacement, bypassing `PoolSv2::start()`

**Context**: `vendor/sv2-apps/pool-apps/pool/src/lib/mod.rs:91-110` hardcodes `BitcoinCoreIPCEngine` as the only engine. [[../concepts/sv2-integration-surface]] confirms `JobDeclarator::new(engine, ...)` is the public constructor we can call directly with our own engine.

**Options considered**:
- A. Patch `PoolSv2::start()` upstream to accept an engine via config (rejected: blocks Phase 1 on upstream review).
- B. JDS-only: just run `JobDeclarator`; rely on sv2-apps's `jd-client` for end-to-end (rejected: doesn't deliver miner-facing SV2 channels).
- C. **Full pool replacement: assemble `JobDeclarator` + `ChannelManager` + downstream listener directly** (chosen).

**Decision**: C. Per [[output/plan-sv2-p2pool-repo-2026-05-22|repo spec §2.3]] and the user's confirmation today.

**Consequences**:
- Our binary owns the lifecycle; `PoolSv2` is dead code in our deployment.
- `ChannelManager` is reused as a workspace dep — no fork.
- If sv2-apps changes `JobDeclarator::new` signature upstream, we follow.

### Decision 2: Token-allocation interceptor in our binary

**Context**: [[ADR 0002]] chose in-memory `Arc<DashMap<JdToken, ScriptBuf>>`. The map needs to be populated at `AllocateMiningJobToken` time. The current `JobValidationEngine` trait does NOT handle that message — it lives upstream of the engine in JDS.

**Options considered**:
- A. **Wrap `JobDeclarator` with our own token-allocation interceptor** (chosen).
- B. Land an upstream trait extension (ADR 0002 Option 4) — blocks Phase 1.
- C. Pool-wide single script — defeats decentralized payouts.

**Decision**: A. The wrapper handles `AllocateMiningJobToken` before delegating to JobDeclarator's normal path. It writes to the shared DashMap. The engine reads from it inside `handle_push_solution`. Per ADR 0002 §"Decision (Phase 1)".

**Consequences**:
- One small wrapper struct in our pool crate.
- We DO need to peek into the JDP message stream — touches `vendor/sv2-apps/pool-apps/jd-server/src/lib/job_declarator/job_declaration_message_handler.rs`. May require a small upstream-friendly hook (callback, not trait change) or we can re-implement JDP message dispatch in our binary. Decide during Phase 1.1.

### Decision 3: Phase-1 integration branches on both forks

**Context**: Three feature branches live on user-owned forks:
- `average-gary/p2pool-v2:feat/bitcoind-trait` (closed #6)
- `average-gary/p2pool-v2:feat/capnp-ipc` (closed #7) — currently rebased on top of `feat/bitcoind-trait`
- `average-gary/sv2-apps:feat/jve-reorg-notify` (closed #3)

Phase 1 needs `feat/bitcoind-trait` + `feat/jve-reorg-notify`. capnp-ipc is Phase 2.

**Options considered**:
- A. **Phase-1 integration branches on both forks** (chosen).
- B. Keep individual feat branches; switch as needed (per-PR submodule churn).
- C. Wait for canonical upstream merges (adds weeks).

**Decision**: A. Create:
- `average-gary/p2pool-v2:phase-1` = current `feat/capnp-ipc` HEAD (already includes `feat/bitcoind-trait`).
- `average-gary/sv2-apps:phase-1` = `feat/jve-reorg-notify` HEAD on top of upstream main.

Submodule pointers in `sv2-p2pool` main bump to these once. Stable for the duration of Phase 1.

**Consequences**:
- We carry capnp-ipc's stub server in the Phase-1 build. Harmless (it's a no-op unless `[ipc]` config is set).
- When Phase 2 starts, we move on; when canonical upstream merges land, we collapse the integration branch.

### Decision 4: Regtest validation, not signet

**Context**: User chose regtest over signet for E2E. Regtest gives us deterministic block generation (`bitcoin-cli generatetoaddress`) and second-scale iteration vs signet's 10-minute waits.

**Decision**: Build a `regtest/` directory with docker-compose that boots bitcoind in regtest mode, a p2poolv2 node configured for regtest, and our pool binary. Block generation is driven by the test runner.

**Consequences**:
- p2poolv2 must accept regtest as a network. (Verify in Phase 0.)
- Some real-network behaviors (mempool churn, network propagation) won't be exercised. Add a signet-tier later if desired.

### Decision 5: Iterative in-conversation execution

**Context**: User chose direct iterative work over another swarm. Phase 1 is integration-heavy with tightly-coupled pieces (engine ↔ JobDeclarator ↔ ChannelManager ↔ downstream listener); fast feedback beats parallelism.

**Consequences**:
- I drive the work directly in the conversation; you review at logical checkpoints.
- No reviewer panel for every commit; you're the panel.
- Plan still saved durably here so we can hand off if needed.

---

## Implementation phases

### Phase 1.0 — Submodule integration branches (effort: 30 min)

**Goal**: Stable submodule pointers for the rest of Phase 1.

**Tasks**:
- [ ] Create `average-gary/p2pool-v2:phase-1` from current `feat/capnp-ipc` HEAD.
- [ ] Create `average-gary/sv2-apps:phase-1` from `feat/jve-reorg-notify` rebased onto upstream main.
- [ ] Bump `sv2-p2pool` submodule pointers in a small PR. CI must remain green.

**Validation**: `cargo check --workspace --locked` passes; `cargo test --workspace` passes.

**Wiki grounding**: [[output/plan-swarm-issues-2026-05-25|swarm plan §"Decisions deferred"]] flagged this exact concern; we resolve it now.

### Phase 1.1 — `P2poolV2Engine` skeleton fields + constructor (effort: half-day)

**Goal**: The engine struct holds every piece it needs. Constructor takes shared handles.

**Tasks**:
- [ ] Define `P2poolV2Engine` fields:
  ```rust
  pub struct P2poolV2Engine {
      chain: ChainStoreHandle,                       // p2poolv2 share-chain
      validator: Arc<dyn ShareValidator>,            // p2poolv2 validation
      accounting: Arc<Accounting>,                   // p2poolv2 payout selection
      bitcoind: Arc<dyn BitcoindLike>,               // BitcoindLike trait (PR #18)
      declared_jobs: Arc<DashMap<JdToken, DeclaredJobSnapshot>>,
      token_payout: Arc<DashMap<JdToken, ScriptBuf>>,  // ADR 0002
      recent_solutions: Arc<RecentSolutions>,        // PR #17
      reorg_tx: broadcast::Sender<BlockHash>,        // detector fanout
  }
  ```
- [ ] Add `pub fn new(...)` constructor accepting all of the above.
- [ ] Define `DeclaredJobSnapshot` (mirror of `BitcoinCoreIPCEngine`'s — coinbase prefix/suffix, wtxid_list, validated bool).
- [ ] Wire `start_reorg_watcher` to use `chain` (already plumbed in PR #21; just confirm).
- [ ] Unit test: construct engine with mock handles; verify default state is empty.

**Validation**: `cargo check`; one unit test passing.

**Wiki grounding**: [[topics/share-accounting-mapping#recommended-jobvalidationengine-skeleton]] specifies these exact fields.

### Phase 1.2 — `handle_declare_mining_job` impl (effort: 1-2 days)

**Goal**: JDP `DeclareMiningJob` messages translate into p2poolv2 share-chain template validation.

**Tasks**:
- [ ] Decode JDP token from message; look up in `declared_jobs` cache.
- [ ] Reconstruct coinbase tx; verify exactly one input.
- [ ] Validate p2pool-specific coinbase outputs against `accounting::payout_selection` for current tip.
  - Witness commitment present
  - p2pool top-N payout outputs match accounting's selection
  - Share-commitment output present
- [ ] Resolve missing wtxids; emit `MissingTransactions(Vec<Wtxid>)` if any unknown.
- [ ] Run `validator.validate_block_template(coinbase, wtxids, missing_txs, tip)`:
  - `Ok` → cache snapshot as validated; return `Success`.
  - `StaleTip` → `Error(STALE_CHAIN_TIP)`.
  - `Invalid(_)` → `Error(INVALID_COINBASE_TX)` (per ADR 0004).
- [ ] **Coinbase-only mode**: per [[ADR 0004]], reject with `INVALID_COINBASE_TX`.
- [ ] Per-message tests with canned `DeclareMiningJob` byte fixtures.

**Validation**: tests covering happy path + each error code path.

**Wiki grounding**: [[topics/share-accounting-mapping#mapping-table]] row "DeclareMiningJob (JDP)" + ADR 0004.

### Phase 1.3 — `handle_set_custom_mining_job` impl (effort: 1 day)

**Goal**: Mining-protocol `SetCustomMiningJob` validated against the previously-declared job.

**Tasks**:
- [ ] Mirror `bitcoin_core_ipc.rs:711-862` line-for-line.
- [ ] Lookup declared job by token; remove from cache (one-shot consumption).
- [ ] Require `validated == true`.
- [ ] Compare every field: prev_hash, nbits, version, coinbase_*, merkle_path.
- [ ] Each mismatch maps to its precise `SET_CUSTOM_MINING_JOB_*` error code (12 codes).
- [ ] **p2poolv2 extension**: also compare merkle_path against share-chain-derived txid_list.
- [ ] Tests: each mismatch path exercised once.

**Validation**: tests.

**Wiki grounding**: [[topics/share-accounting-mapping#mapping-table]] row "SetCustomMiningJob" + section §"Recommended JobValidationEngine skeleton".

### Phase 1.4 — `handle_push_solution` impl + `RecentSolutions` integration (effort: half-day)

**Goal**: Block-finder credit lands without losing the race against `SubmitSharesExtended`.

**Tasks**:
- [ ] Reconstruct full Bitcoin block from solution + last-validated job.
- [ ] Submit raw block via `bitcoind.submit_block(...)` — fire-and-forget per reference impl.
- [ ] Compute share_hash; record into `RecentSolutions` (PR #17) with TTL 30s.
- [ ] When the corresponding `SubmitSharesExtended` arrives in `ChannelManager`'s share-handler path, `recent_solutions.take(&share_hash)` returns the block hash → tag the share as block-finder in `accounting::on_block_found(share_hash)`.
- [ ] Unit test: PushSolution arrives before SharesExtended; confirm finder credit lands.
- [ ] Unit test: PushSolution arrives after SharesExtended; finder credit still lands (alternate path).

**Validation**: 2 unit tests + 1 proptest expanding on PR #17's existing harness.

**Wiki grounding**: [[topics/share-accounting-mapping#mapping-table]] row "PushSolution (JDP)" + Open Q 7.

### Phase 1.5 — Token-allocation interceptor + `JobDeclarator` wrapper (effort: 1 day)

**Goal**: `(JdToken → ScriptBuf)` map gets populated at allocation time. ADR 0002 chose this design.

**Tasks**:
- [ ] Define `OurJobDeclarator` wrapper struct holding `JobDeclarator` + `Arc<DashMap<JdToken, ScriptBuf>>`.
- [ ] Override the message-dispatch path so we observe `AllocateMiningJobToken` before forwarding.
  - Option a: re-implement JDP message dispatch in our binary (bigger; touches sv2-apps API surface).
  - Option b: ask sv2-apps for a small `on_token_allocated` callback hook (smaller; one upstream PR).
  - **Decide during this phase based on what `JobDeclarator`'s public API actually exposes.** If a method like `start_downstream_server` accepts a callback, use it. If not, prefer (b).
- [ ] On `AllocateMiningJobToken`, parse the JDP message; extract miner's coinbase script (the JDC sends it). Insert `(token → script)` into the DashMap.
- [ ] Tests: simulated allocation populates the map; eviction on token expiry matches `token_management/mod.rs` janitor.

**Validation**: tests.

**Wiki grounding**: [[ADR 0002]] §Decision §3.

### Phase 1.6 — `ChannelManager` wiring + share-submission path (effort: 2-3 days)

**Goal**: SV2 mining-protocol channels terminate in our binary and route shares into p2poolv2 share-chain.

**Tasks**:
- [ ] Reuse `vendor/sv2-apps/pool-apps/pool/src/lib/channel_manager/` directly. Constructor takes TP/downstream channels + coinbase outputs.
- [ ] Wire `OpenStandardMiningChannel` / `OpenExtendedMiningChannel`: register `(channel_id → miner_payout_script)` binding; reserve extranonce range from `shares::extranonce`.
- [ ] Wire `SubmitSharesStandard` / `SubmitSharesExtended`:
  - Reconstruct candidate `ShareBlock`.
  - Call `shares::handle_stratum_share(emission, chain_store_handle)`.
  - On Ok: gossip via libp2p; credit `accounting`; check `recent_solutions.take(&share_hash)` for block-finder bonus.
  - On Err: emit `SubmitSharesError` with the canonical code (per [[topics/share-accounting-mapping#mapping-of-sv2-share-rejection-codes-onto-p2poolv2-validation-predicates]]).
- [ ] **Uncle handling per [[ADR 0001]]**: a share that fails longest-chain but admits as uncle gets `SubmitSharesSuccess` with `new_shares_sum += 1` (α=1), NOT `stale-share`.
- [ ] Wire `SetTarget` to our `pool_difficulty.rs`.
- [ ] Wire `SetNewPrevHash` to invalidate per-channel job cache + trigger `start_reorg_watcher`'s notification.
- [ ] Per-message tests with canned SV2 frame fixtures.

**Validation**: tests + manual smoke with `jd-client` connecting.

**Wiki grounding**: [[topics/share-accounting-mapping]] full mapping table + ADR 0001.

### Phase 1.7 — Pool binary entry-point (effort: half-day)

**Goal**: `crates/sv2-p2pool-pool/src/main.rs` ties everything together.

**Tasks**:
- [ ] Replace the Phase-0 stub with the real binary per [[output/plan-sv2-p2pool-repo-2026-05-22|repo spec §2.3]]:
  ```rust
  #[tokio::main]
  async fn main() -> anyhow::Result<()> {
      let cfg = Config::load()?;
      let cancellation = CancellationToken::new();
      let task_manager = Arc::new(TaskManager::new());

      // 1. Start p2poolv2 in-process; owns libp2p swarm + ChainStoreHandle.
      let p2pool = p2poolv2_lib::node::Node::new(cfg.p2pool_config()).await?;

      // 2. Build engine sharing handles with the live node.
      let engine = Arc::new(P2poolV2Engine::new(p2pool.handles())?);
      engine.start_reorg_watcher(cfg.reorg_poll_period());

      // 3. Build OurJobDeclarator wrapper around JobDeclarator::new.
      let jd = OurJobDeclarator::new(
          engine.clone() as Arc<dyn JobValidationEngine>,
          engine.token_payout(),
          cancellation.clone(),
          task_manager.clone(),
          cfg.coinbase_reward_script(),  // fallback for legacy miners
      ).await?;
      jd.start_downstream_server(/* ... */).await?;

      // 4. ChannelManager from sv2-apps for SV2 mining-protocol channels.
      let cm = ChannelManager::new(/* ... */, Some(jd.inner())).await?;
      cm.start(cancellation.clone(), task_manager.clone(), cfg.coinbase_outputs()).await?;
      cm.start_downstream_server(/* ... */).await?;

      // 5. Wait + graceful shutdown.
      tokio::select! {
          _ = tokio::signal::ctrl_c() => cancellation.cancel(),
          _ = cancellation.cancelled() => {}
      }
      task_manager.join_all().await;
      Ok(())
  }
  ```
- [ ] `Config::load()` reads `config/pool.example.toml` schema (already exists; extend as needed).
- [ ] `cargo build --release -p sv2-p2pool-pool` — must produce a binary.

**Validation**: binary boots without panic; logs show it listening on configured ports.

**Wiki grounding**: [[output/plan-sv2-p2pool-repo-2026-05-22|repo spec §2.3]].

### Phase 1.8 — Regtest harness + E2E test (effort: 1-2 days)

**Goal**: `docker compose -f regtest/compose.yaml up && cargo test --test e2e_regtest` exits 0.

**Tasks**:
- [ ] `regtest/compose.yaml`: bitcoind (regtest), p2poolv2 node (regtest config), sv2-p2pool-pool, sv2-apps `jd-client` (configured pointing at our JDS).
- [ ] `integration-tests/tests/e2e_regtest.rs` (Rust integration test or shell harness):
  1. Start docker-compose stack.
  2. `bitcoin-cli generatetoaddress 101 <addr>` to mature coinbase.
  3. Wait for p2poolv2 chain to initialize.
  4. Configure jd-client with a test `coinbase_reward_script`.
  5. Wait for `DeclareMiningJob` → `Success` exchange in logs.
  6. Generate enough hash/blocks to get an actual share submission.
  7. Verify share appears in p2poolv2 accounting.
  8. Force a regtest reorg (`bitcoin-cli invalidateblock`); confirm `declared_jobs` cache invalidates.
- [ ] Document in `docs/regtest.md`.

**Validation**: regtest E2E test exits 0. Optional follow-up: wire it into CI as a separate slow-job (cargo flag `cfg(regtest)`).

**Wiki grounding**: [[output/plan-sv2-p2pool-repo-2026-05-22|repo spec §6 Testing strategy]] called for "smoke test on signet"; user upgraded to regtest for faster iteration.

### Phase 1.9 — Documentation + monitoring (effort: half-day)

**Goal**: `docs/architecture.md` reflects the real binary; Prometheus metrics expose key counters.

**Tasks**:
- [ ] Update `docs/architecture.md` with the actual component graph (replace the Phase-0 stub).
- [ ] Add Prometheus exposure on the configured `monitoring.listen_address`. Reuse `vendor/sv2-apps/stratum-apps/src/monitoring/`. Surface:
  - `sv2_*_shares_accepted_total` (mirrored from sv2-apps)
  - `sv2_*_shares_rejected_total{code=...}` (canonical 7 codes)
  - `p2pool_uncle_shares_total{kind=main|uncle}` (from ADR 0001's Option D follow-up — mark as observability-only)
  - `p2pool_reorg_events_total`
- [ ] Add a brief `RUNNING.md` that walks an operator through the regtest setup → real bitcoind → eventually mainnet readiness.

**Validation**: scrape `:9090/metrics`, confirm 4 series visible.

---

## Risks & mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| `JobDeclarator`'s public API doesn't expose a token-allocation hook | ADR 0002 §Phase-1 caveat | Phase 1.5 has option (a) "re-implement JDP dispatch" as fallback. Worst case adds 1-2 days. |
| p2poolv2 doesn't accept regtest as a network | Decision 4 unverified assumption | Spike in Phase 1.0; if not, fall back to a private signet or a mocked share-chain. |
| Race between `PushSolution` and `SubmitSharesExtended` | Open Q 7 | RecentSolutions buffer (PR #17) handles it; Phase 1.4 verifies via 2 ordering tests. |
| Uncle vs stale-share confusion | ADR 0001 | Phase 1.6's share-submission path tests both branches explicitly. |
| Submodule rebases churn during dev | Decision 3 | Phase-1 integration branches keep pointers stable. |
| Lockfile drift on submodule bump | Operational learning from PRs #18/#19 | CI's `--locked` catches it; we re-update on each bump. |
| sv2-apps `JobValidationEngine` trait shape changes upstream during dev | Active upstream | Pin sv2-apps to phase-1 integration branch; bump deliberately. |
| ChannelManager's API needs hooks we don't have | Phase 1.6 unknown | Read `pool-apps/pool/src/lib/channel_manager/` first; if blocked, propose minimal upstream hook PR. |
| Variance economics make Phase 1 demo unconvincing | [[topics/why-decentralized-pools-struggle]] | Out of scope; Phase 1's job is a working integration, not market traction. |

## Open questions

These are known unknowns that surface during execution, not blockers:

1. **`JobDeclarator` token-allocation hook**: Phase 1.5 settles. If forced to re-implement JDP dispatch, scope expands by ~1-2 days.
2. **Regtest support in p2poolv2**: Phase 1.0 verifies. Fallback options exist.
3. **`ChannelManager` reuse vs rebuild**: Phase 1.6 verifies whether sv2-apps's ChannelManager has the hooks we need.
4. **What does `Accounting::on_block_found` actually look like?** Read `vendor/p2poolv2/p2poolv2_lib/src/accounting/` early.
5. **Do we want the Prometheus `p2pool_uncle_shares_total` counter as Phase 1 or Phase 1.5?** ADR 0001 marks it follow-up; user can decide during Phase 1.9.

## Sources consulted

- [[topics/share-accounting-mapping]] — message-by-message implementation contract; cited throughout
- [[topics/integration-paths]] — confirms Path-B (full pool replacement)
- [[concepts/sv2-integration-surface]] — `JobDeclarator::new`, `ChannelManager`, trait shape
- [[concepts/p2poolv2]] — `Node` lifecycle, `ChainStoreHandle` semantics
- [[output/plan-sv2-p2pool-repo-2026-05-22|repo spec]] — §2.3 binary entry-point, §6 testing strategy
- [[output/plan-swarm-issues-2026-05-25|swarm plan]] — what the swarm shipped + deferred follow-ups
- ADRs 0001, 0002, 0004, 0010 on `main`
- Direct code (verified earlier): `bitcoin_core_ipc.rs:404-867`, `mod.rs:29` (trait), `mod.rs:91-110` (PoolSv2 hardcoded selection), `snapshot_cache.rs:45-74` (rejection codes)
- New code from this swarm:
  - `crates/sv2-p2pool-engine/src/recent_solutions.rs` (PR #17)
  - `crates/sv2-p2pool-engine/src/reorg_detector.rs` (PR #21)
  - `crates/sv2-p2pool-engine/src/lib.rs` (`P2poolV2Engine` skeleton)
  - `vendor/p2poolv2:feat/bitcoind-trait` (`BitcoindLike` trait)
  - `vendor/sv2-apps:feat/jve-reorg-notify` (trait extension)

## Inventory follow-ups

- **Watch**: sv2-apps `JobValidationEngine` trait stability — pin sv2-apps phase-1 branch until upstream merges land.
- **Watch**: p2poolv2 release cadence — Phase-1 integration branch tracks `feat/capnp-ipc` HEAD; bump when canonical branches land.
- **Open question**: token-allocation hook strategy (Phase 1.5 §a vs §b).
- **Open question**: regtest support in p2poolv2 (verify in Phase 1.0).
- **Open question**: should the Phase 1.9 Prometheus surface be the canonical observability story, or do we want OpenTelemetry instead? Defer until 1.9.

## Phasing summary

| Phase | Effort | Output | Blocks |
|-------|-------:|--------|--------|
| 1.0 Submodule integration branches | 30m | stable submodule pointers | 1.1+ |
| 1.1 Engine skeleton fields | half-day | `P2poolV2Engine` constructor | 1.2+ |
| 1.2 `handle_declare_mining_job` | 1-2d | JDP `DeclareMiningJob` works | 1.3, 1.6 |
| 1.3 `handle_set_custom_mining_job` | 1d | `SetCustomMiningJob` works | 1.6 |
| 1.4 `handle_push_solution` + RecentSolutions | half-day | block-finder credit lands | 1.6, 1.8 |
| 1.5 Token-allocation interceptor | 1d | per-miner payout binding | 1.7 |
| 1.6 ChannelManager wiring | 2-3d | SV2 mining-protocol works | 1.7, 1.8 |
| 1.7 Pool binary entry-point | half-day | runnable binary | 1.8 |
| 1.8 Regtest E2E | 1-2d | passing acceptance test | 1.9 |
| 1.9 Docs + monitoring | half-day | operator-ready | — |

**Total**: ~9-12 working days. Iterative-in-conversation execution; checkpoint at end of each numbered phase.
