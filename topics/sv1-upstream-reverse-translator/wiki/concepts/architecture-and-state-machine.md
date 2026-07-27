---
title: "Reverse-translator architecture and state machine"
category: concept
status: active
created: 2026-05-28
updated: 2026-07-27
verified: 2026-07-27
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-28-path4-workspace-layout-and-integration-tests.md
  - raw/repos/2026-05-28-path4-channels-sv2-reuse.md
  - raw/repos/2026-05-28-path4-handlers-sv2-bidirectional.md
  - raw/repos/2026-05-28-path4-sv1-api-isclient-trait.md
  - raw/repos/2026-05-28-path4-extranonce-allocator-translator-pattern.md
  - raw/repos/2026-05-28-path4-stratum-translation-crate.md
  - raw/repos/2026-05-28-path2-sri-translator-role.md
  - raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md
tags: [architecture, state-machine, sri, channels-sv2, handlers-sv2, sv1-api, upstream-switching, failover]
summary: "Where the new role lives in the SRI workspace, which crates it reuses, what it must write from scratch, and how the runtime task graph is shaped. Built from Path 4's code-level reading of /Users/garykrause/repos/stratum."
---

# Reverse-translator architecture and state machine

Where the new role lives in the SRI workspace, which crates it reuses, what it must write from scratch, and how the runtime task graph is shaped. Built from Path 4's code-level reading of `/Users/garykrause/repos/stratum`.

## Workspace placement

- **Role binary** (tokio, networking): new crate in `stratum-mining/sv2-apps`, parallel to existing translator-proxy: `sv2-apps/roles/reverse-translator/`. **NOT** in `stratum-mining/stratum` — that repo is pure libraries (zero tokio deps; the README says "low-level crates only").
- **Translation helpers** (no networking, no async): extend the existing `stratum-core/stratum-translation/` crate in the low-level repo with three new pure functions plus a job-builder helper.

The split mirrors how the forward translator-proxy is organized today.

**See**: [[../../raw/repos/2026-05-28-path2-sri-translator-role|SRI translator-proxy]], [[../../raw/repos/2026-05-28-path4-workspace-layout-and-integration-tests|workspace layout]].

## Runtime task graph

```
[SV2 server task per downstream conn]  ←─── Arc<Mutex<State>> ───→  [SV1 client task to upstream pool]
        │                                                                    │
   handlers_sv2::HandleMiningMessages                                  sv1_api::IsClient
   FromClientAsync                                                     (port of sv1/examples
                                                                        /client_and_server.rs Client)
        │                                                                    │
   per-channel:                                                  per-connection:
     channels_sv2::server::ExtendedChannel<J>                      extranonce1, extranonce2_size,
     channels_sv2::vardiff::VardiffState                           last_notify, last_set_difficulty
                                                                   ClientStatus state machine
        \____________________________________________________/
                  Shared:
                  - channels_sv2::ExtranonceAllocator::from_upstream_prefix(extranonce1, ...)
                  - HashMap<sv2_channel_id, sv1_user_name>
                  - HashMap<sv2_job_id_u32, sv1_job_id_string>
                  - ChainTip
                  - current Target (from SV1 set_difficulty)
```

## Initialization order

1. Bind SV2 listener (Noise NX over TCP).
2. TCP-connect upstream SV1 pool (or TLS-tunneled).
3. Drive 3 SV1 RPCs: `mining.configure` (negotiate `version-rolling`, `subscribe-extranonce`, `info`) → `mining.subscribe` (capture extranonce1, extranonce2_size) → `mining.authorize`.
4. Build `ExtranonceAllocator::from_upstream_prefix(extranonce1, local_prefix_bytes, total_extranonce_len = len(extranonce1) + extranonce2_size, max_channels)`.
5. Process incoming SV2 `OpenExtendedMiningChannel` → allocate prefix, create `ExtendedChannel`, send synthesized `OpenExtendedMiningChannel.Success` + `NewExtendedMiningJob` (from cached SV1 notify) + `SetNewPrevHash` + `SetTarget`.
6. Process SV1 `mining.notify` → assign sv2_job_id, broadcast `NewExtendedMiningJob` (or `NewExtendedMiningJob` + `SetNewPrevHash` if `clean_jobs=true`) to all open channels.
7. Process SV2 `SubmitSharesExtended` → look up SV1 job_id, build `mining.submit`, queue upstream; on response, batch into SV2 `SubmitShares.Success` or map error string to typed `SubmitShares.Error`.

## Reusable primitives (no code change required)

| Primitive | Crate | Use in reverse translator |
|---|---|---|
| `IsClient` trait | `sv1_api` | SV1 upstream-pool client side |
| `IsServer` trait + worked example | `sv1_api` | Reference for fake-pool test harness |
| `HandleMiningMessagesFromClientAsync` | `handlers_sv2` | SV2 server-side dispatch (FromClient/FromServer split is already bidirectional) |
| `HandleCommonMessagesFromClientAsync` | `handlers_sv2` | SetupConnection handling |
| `server::extended::ExtendedChannel<J>` | `channels_sv2` | Per-SV2-channel state (with custom JobStore) |
| `ExtranonceAllocator::from_upstream_prefix` | `channels_sv2` | Docstring **literally calls out the Translator use case** — sub-allocate SV1 extranonce1 across SV2 channels |
| `vardiff::classic::VardiffState` | `channels_sv2` | Per-channel difficulty adaptation |
| `bip141::try_strip_bip141` | `channels_sv2` | Already used in forward translation; usable as a reference |
| `chain_tip::ChainTip` | `channels_sv2` | Track prev_hash/nbits/min_ntime, gates share validation |
| `merkle_root::merkle_root_from_path` | `channels_sv2` | Used inside `validate_share` |
| `target::hash_rate_to_target` | `channels_sv2` | Channel target sizing |
| Wire pipeline | `parsers_sv2`, `codec_sv2`, `framing_sv2`, `noise_sv2` | Unchanged |
| `build_sv2_open_extended_mining_channel` | `stratum_translation` | Verifies input shapes |

**See**: [[../../raw/repos/2026-05-28-path4-channels-sv2-reuse|channels_sv2 reuse]], [[../../raw/repos/2026-05-28-path4-handlers-sv2-bidirectional|handlers_sv2 bidirectional]], [[../../raw/repos/2026-05-28-path4-sv1-api-isclient-trait|sv1_api IsClient trait]], [[../../raw/repos/2026-05-28-path4-extranonce-allocator-translator-pattern|extranonce allocator pattern]].

## What needs to be written from scratch

### In `stratum_translation` (low-level repo, ~150 LOC signatures → budget 500–1000 LOC)

- `build_sv2_new_extended_mining_job_from_sv1_notify(notify, sv2_job_id, version_rolling_allowed) -> Result<NewExtendedMiningJob>`
- `build_sv2_set_target_from_sv1_set_difficulty(set_difficulty) -> Result<SetTarget>` (uses `Target::from_difficulty(f64)` from the bitcoin crate — note this is **bdiff**-based, which conflicts with the pdiff math prescribed in [[sv2-sv1-primitive-mapping]]; see [[prior-art-blitzpool-rental-proxy]] § The difficulty-convention conflict)
- `build_sv1_submit_from_sv2_submit_shares_extended(share, sv1_job_id_string, user_name, extranonce1_len) -> Result<client_to_server::Submit>`

**Revised 2026-07-27**: the ~150 LOC figure is the cost of *these three signatures*, not of the translation layer. Blitzpool's equivalent `src/proto/translate.rs` is **33 855 bytes** (~900–1100 lines) — not a like-for-like comparison, since it also carries difficulty/target math, version-rolling mask handling, and probe logic this article assigns to the role binary, but large enough that 150 should be read as a floor. Budget **500–1000 LOC** for everything on the pure-translation side.

**See**: [[../../raw/repos/2026-05-28-path4-stratum-translation-crate|stratum_translation crate]], [[../../raw/repos/2026-05-28-path1-sri-stratum-translation-crate|same crate from Path 1]], [[../../raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator|blitzpool translate.rs]].

### In the new sv2-apps role binary (~1500-2500 LOC)

- `impl sv1_api::IsClient` for upstream-pool task (port of `sv1/examples/client_and_server.rs`'s Client to tokio).
- `impl HandleMiningMessagesFromClientAsync` for the per-SV2-connection state.
- A new `JobStore<ExtendedJob>` impl that builds jobs from SV1 notify (the existing `JobFactory` expects template-distribution `NewTemplate`, which the reverse translator does not have).
- HashMap-based ID translation tables: `job_id u32 ↔ string`, `channel_id ↔ sv1_user_name`.
- Tokio task coordination (`Arc<Mutex<...>>` shared state, mpsc for cross-task message routing).
- TOML config: `upstream_url`, `listen_addr`, `max_channels`, vardiff params, error-string mapping per pool.

### In sv2-apps integration-tests (~500 LOC)

- Fake SV1 pool harness using `sv1_api::IsServer` + tokio TCP listener (port of the example's Server).

## Hard problems (unavoidable)

1. **BIP141 lossiness** — see [[sv2-sv1-primitive-mapping]] § Lossy conversions. Pass-through stripped coinbase; SV2 client must accept.
2. **Target precision** — float→U256 is fine in this direction.
3. **Job-ID translation** — SV1 string ↔ SV2 u32 + HashMap, GC'd on `clean_jobs=true`.
4. **Mid-session `mining.set_extranonce`** — forces `SetExtranoncePrefix` to all SV2 channels and a rebuild of the allocator; in-flight shares may fail upstream. **Has a known design answer** — see § Upstream switching below.
5. **Pool-specific error strings** — Foundry, Antpool, F2Pool wording differs; the error mapping table is per-pool config.

## Upstream switching — choose the strategy by cause, not by mechanism

Any reverse translator that can re-point at a different upstream inherits one hard problem: the new pool hands out a different `extranonce1` and a different difficulty, and every open SV2 channel is now mining against stale parameters. Blitzpool's shipped answer ([[prior-art-blitzpool-rental-proxy]]) is to split by *why* the switch is happening:

| Cause | Strategy | Mechanism | Rationale |
|---|---|---|---|
| **Operator-initiated** (config edit, deliberate pool change) | **Force miner reconnect** | Drop the downstream connection; the miner re-handshakes against the new upstream and gets correct extranonce/difficulty in its first job | "A live re-point a miner might silently ignore would waste every share, so the reconnect is the safe default here." A silently-ignored re-point burns 100% of shares until someone notices. |
| **Automatic failover** (upstream died mid-session) | **Re-point in place** | SV2: `SetExtranoncePrefix` + `SetTarget` to every open channel. SV1 downstream: `mining.set_extranonce` + `mining.set_difficulty` + `mining.notify(clean_jobs=true)`, falling back to `client.reconnect` for miners that can't take a live extranonce | "In-place keeps a flapping pool from storming the miner with reconnects." A pool that flaps every 30s would otherwise produce a reconnect storm. |

**Safety-first for intentional changes, continuity-first for unintentional ones.** The asymmetry is the point: an operator-initiated switch can afford one clean reconnect because it happens once and on a human timescale, while failover may recur on a machine timescale and must not amplify.

Implementation consequence for the task graph: the shared state needs an `ActiveUpstream` indirection (URL + credentials + optional authority pubkey) that the SV1 client task can swap behind the SV2 server tasks, plus a flag distinguishing operator-initiated from failover-initiated transitions so the broadcast path can pick a strategy. Blitzpool models the session's upstream selection as a two-variant enum (`Idle` vs `Rented { order_id }`) — a rental-specific shape, but the general lesson is that "which upstream am I on" belongs in an explicit enum rather than being implied by a mutable connection handle.

## Upstream protocol detection (if the upstream's protocol is not known statically)

Blitzpool folds detection **into the connect** rather than probing first: attempt the natively-configured protocol and **reuse that socket on success**; only on failure or timeout (`UPSTREAM_PROBE_TIMEOUT = 3s`) try the other protocol and engage translation. No standalone prober, no wasted round trip in the common case. Downstream detection on a shared port is cheaper still — **peek, don't consume, the first byte**: `{`, space, `\n`, `\r` → SV1 JSON-RPC; anything else → SV2 Noise handshake, letting the SV2 handshake reject genuine garbage.

A reverse translator with a statically-configured SV1 upstream needs neither, but both are relevant if it also serves as a drop-in for mixed fleets.

## Why this is "natural extension," not "rewrite"

- `stratum_translation` already exposes both `sv1_to_sv2` and `sv2_to_sv1` modules — bidirectionality was designed into the helper crate from the start.
- `handlers_sv2` already exposes both `FromClient` and `FromServer` async traits — the dispatch layer is direction-symmetric.
- The forward translator-proxy's task scaffolding is reusable as-shape; only inner message handlers and helper choices change.
- **Demonstrated 2026-07-27**: blitzpool-rental-proxy built exactly this shape on top of `stratum-core` + `stratum-apps` — protocol-agnostic core with SV1/SV2/translate as pluggable codec adapters — reusing `channels_sv2::merkle_root` and `stratum-apps::network_helpers` unchanged.

## Build-environment caveat

SRI's **crates.io releases do not compile together** at current majors (`mining_sv2`'s derives reference `super::binary_sv2`); the git workspaces are internally consistent. Pin `stratum-core` and `stratum-apps` to git revs and unify them on the same branch, and enable `stratum-core`'s `translation` feature to get `stratum_translation` + `sv1_api`. Details in [[prior-art-blitzpool-rental-proxy]] § Dependency posture.

## See also

- [[sv2-sv1-primitive-mapping]] — message-by-message translation
- [[sv2-features-lost-with-sv1-upstream]] — what value carries through this architecture
- [[prior-art-blitzpool-rental-proxy]] — a shipped instance of this architecture
- [[../topics/reverse-translator-playbook|the playbook]]
- [[sv2-spec-issue-102-the-canonical-reference.md|sv2-spec issue #102 — the canonical reference for V2-to-V1 down-to-up]]
- [[../reference/sv2-sv1-message-mapping-table.md|Reference — SV2 ↔ SV1 message mapping table]]
