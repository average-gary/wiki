---
title: "Plan: Bootstrap datum-rs (Phase 1 dual-protocol drop-in)"
type: plan
format: roadmap
sources:
  - output/playbook-drop-in-rust-datum-gateway-2026-06-01.md
  - wiki/topics/drop-in-rust-datum-gateway.md
  - wiki/concepts/drop-in-rust-port-architecture.md
  - wiki/concepts/dual-protocol-downstream.md
  - wiki/concepts/drop-in-surface-inventory.md
  - wiki/concepts/datum-protocol-rust-implementation.md
  - wiki/concepts/sv2-downstream-architecture.md
  - wiki/concepts/gateway-internals-c-architecture.md
  - wiki/concepts/drop-in-distribution.md
  - wiki/concepts/switch-day-runbook.md
generated: 2026-06-01
session: 2026-06-01-plan-bootstrap-datum-rs
project: datum-rs
---

# Plan: Bootstrap datum-rs — Phase 1 dual-protocol drop-in

> Generated from the [datum](../_index.md) wiki (8 articles consulted, plus the upstream playbook).

## Executive Summary

`datum-rs` is a greenfield Rust workspace at `~/repos/datum-rs/` that drops in for `OCEAN-xyz/datum_gateway`, preserves SV1-to-ASIC compatibility for OCEAN's existing miner base, adds SV2-to-ASIC as an opt-in protocol on a new port, and reuses the same encrypted DATUM upstream. **Phase 1 ships full dual-protocol downstream (SV1 + SV2) with shared DATUM upstream and a single source-of-truth coinbase output array.** It does not ship distribution polish (StartOS, `.deb`, Docker push) or observability extras (Prometheus, structured logs, `--migrate-config`) — those are explicitly deferred to Phases 2 and 3.

The de-risking work is already done in the wiki: no on-disk state to migrate, cipher correction confirmed (XSalsa20Poly1305 via `dryoc`), CLI surface is minimal, `bitcoincore-rpc` archived → hand-rolled `reqwest + corepc-types` is the rust-bitcoin org's recommendation. Per interview answers, Phase 1 also (a) builds SV1 and SV2 in parallel after the foundation crates land, (b) runs a live OCEAN handshake against production DATUM Prime as soon as the protocol crate compiles, (c) ships build+test-only CI, (d) opens the repo as public-MIT day one with a tracking issue cross-referencing `OCEAN-xyz/datum_gateway#146`.

## Architecture Decisions

### Decision 1: Greenfield Cargo workspace, NOT a fork

**Context**: [drop-in-rust-port-architecture](../wiki/concepts/drop-in-rust-port-architecture.md) and the playbook's Phase 0 step 1 specify a greenfield repo at `~/repos/datum-rs/`. The C codebase is treated as a reference, not a base.

**Options considered**:
- Fork `OCEAN-xyz/datum_gateway` → vendor C code → port file-by-file in-place. Rejected: keeps git history tied to a build system (CMake) the Rust port doesn't use, and the C/Rust ratio shifts the working copy noisily.
- Greenfield workspace with `[[bin]] name = "datum_gateway"` in `crates/datum-bin` (per [drop-in-distribution](../wiki/concepts/drop-in-distribution.md#cargo-binary-name)).

**Decision**: Greenfield 11-crate workspace. The on-disk binary name `datum_gateway` (underscore) is preserved via `[[bin]] name = "datum_gateway"` so `bitcoin.conf` `blocknotify=killall -USR1 datum_gateway` recipes keep working ([drop-in-surface-inventory § four hard surfaces](../wiki/concepts/drop-in-surface-inventory.md#the-four-hard-surfaces)).

**Consequences**: All code is new; the C source lives under `~/repos/datum_gateway/` as a read-only reference for golden-vector tests. CI is fast (one cargo build, no CMake bootstrap).

### Decision 2: Dual-port dual-protocol — both SV1 and SV2 ship in Phase 1

**Context**: OCEAN's miner base is ~75-90% SV1-only ([dual-protocol-downstream](../wiki/concepts/dual-protocol-downstream.md#ocean-miner-base-composition-low-medium-confidence)). An SV1-only drop-in fails the project's "drop-in" promise; an SV2-only drop-in bricks the OCEAN fleet. Single-port protocol sniffing is technically trivial (SV1 first byte `0x7b` vs SV2's 64-byte ElligatorSwift random) but complicates debugging and load-balancer configs.

**Options considered**:
- Single-port sniffing default — rejected (operator-invisible debugging hazard).
- SV1-only Phase 1, SV2 deferred — rejected by the user brief ("Phase 1 ships full dual-protocol drop-in").
- Dual-port, SV1 default-on (port 23334), SV2 opt-in (port 23335).

**Decision**: Dual-port, SV1 default-on at 23334, SV2 opt-in at 23335. Single-port sniff lands behind `stratum.protocol_sniff = true` config flag in Phase 2.

**Consequences**: Two server tasks bind two TCP listeners under one binary. SV1 path runs direct-serve (per [dual-protocol-downstream § SV1 implementation](../wiki/concepts/dual-protocol-downstream.md#sv1-implementation--sris-stratum_translation-crate)) — no internal SV1↔SV2 translation. Each downstream connection builds its own job from the shared template; they never see each other's state.

### Decision 3: Single source-of-truth coinbase output array

**Context**: [dual-protocol-downstream § per-channel isolation](../wiki/concepts/dual-protocol-downstream.md#per-channel-isolation) flags coinbase divergence between SV1 `coinb1/coinb2` and SV2 `NewExtendedMiningJob.coinbase_tx_outputs` as **catastrophic** — operator could pay self instead of OCEAN.

**Options considered**:
- Each protocol path independently parses OCEAN's V2 coinbaser blob → two parse paths → silent divergence on edge cases.
- Single `Vec<TxOut>` constructed once in `datum-coinbaser` per template refresh, consumed by both `datum-stratum-sv1` (via `coinb1/coinb2` synthesis) and `datum-stratum-sv2` (via `JobFactory::new_extended_job`'s `additional_coinbase_outputs`).

**Decision**: Single `Vec<TxOut>` source-of-truth in `datum-coinbaser`, distributed via `tokio::sync::watch`. Golden-vector tests assert byte-exact equivalence of resulting coinbase txs against the C gateway's output for both protocols.

**Consequences**: `datum-coinbaser` is the sole owner of OCEAN-blob-to-`Vec<TxOut>` parsing. SV1 and SV2 server crates consume read-only handles; neither reparses. The 6-fingerprint coinbase variants in C `datum_stratum.c` collapse to 1 under SV2 ([drop-in-rust-port-architecture per-module table, datum_coinbaser.c row](../wiki/concepts/drop-in-rust-port-architecture.md#per-module-port-plan)) — Phase 1 retains all 6 for SV1 parity and feeds the post-collapse single variant to SV2.

### Decision 4: SV1 + SV2 built in parallel after foundation crates

**Context**: User chose "parallel (after foundations)" in the interview. Foundations = `datum-config` → `datum-rpc` → `datum-blocktemplates` + `datum-coinbaser` → `datum-protocol`.

**Options considered**:
- SV1 first (parity-then-extend) — lowest delta against existing fleet but defers SRI integration risk.
- SV2 first (capability-led) — frontloads SRI risk but leaves SV1 parity as final gate.
- Parallel after foundations — both server crates depend on the same coinbase + template + protocol upstream interfaces; once those interfaces stabilize, the server work is independent.

**Decision**: Parallel after foundations. The protocol crate, blocktemplates, coinbaser, RPC, and config are all upstream of both server paths and are sequenced strictly. SV1 and SV2 server crates fork off in parallel branches once those interfaces compile and pass mock-pool integration.

**Consequences**: Two reviewable PR streams once foundations land. The `JobStore` trait + shared `Vec<TxOut>` watch channel are the cross-protocol contract — defined once at the foundation/server-crate boundary.

### Decision 5: Live OCEAN handshake as soon as `datum-protocol` compiles

**Context**: User chose "live OCEAN as soon as protocol crate compiles" in the interview. This validates the playbook's follow-up thesis: *"DATUM Prime accepts a Rust client speaking master-version `v0.4.1-beta` against the production endpoint."*

**Options considered**:
- Mock-pool-only Phase 1 — defers the highest-risk unknown (DATUM Prime drift) to v0.1.0 release gate.
- Mid-Phase 1 capture-and-pin — captures real C-emitted PING for header-bitfield byte ordering pinning.
- Live OCEAN as soon as protocol crate compiles — exposes drift earliest; cheapest pivot if rejected.

**Decision**: Live OCEAN handshake is a milestone gate inside Phase 3 (protocol crate work). A hello-world Rust client connects to `datum-beta1.mine.ocean.xyz:28915` with master version `"v0.4.1-beta"`, completes the libsodium-box handshake, and exits. Any rejection produces a fall-back version string (Path 1's 2025-12-17 triple-bump suggests `v0.3.3` or `v0.2.6` are live) before the rest of the protocol crate is wired up.

**Consequences**: `datum-protocol` ships a `mock_pool.rs` for hermetic CI tests AND a `bin/datum-protocol-handshake-probe` integration probe for the live test. Capture the C-emitted PING frame on first probe to pin header bitfield ordering — see [datum-protocol-rust-implementation § known unknowns](../wiki/concepts/datum-protocol-rust-implementation.md#known-unknowns-gating).

### Decision 6: Build + test only CI for Phase 1

**Context**: User brief defers distribution polish to Phase 2/3. User chose "build + test only (minimal)" CI scope.

**Options considered**:
- Build + test + static-musl artifacts — adds a downloadable binary at minimal cost.
- Build + test + full release matrix — close to playbook step 11; out of Phase 1 scope.
- Build + test only — `cargo build`, `cargo test`, `cargo clippy --all -- -D warnings`, `cargo fmt --check`.

**Decision**: GitHub Actions workflow with one job per (target, profile): `cargo build --workspace --locked`, `cargo test --workspace --locked`, `cargo clippy --workspace --all-targets -- -D warnings`, `cargo fmt --all -- --check`. No release artifacts. Phase 2 adds the static-musl + cargo-deb + Docker matrix.

**Consequences**: Lowest-friction CI; no release-engineering distractions during the high-risk protocol port. `Cargo.lock` is committed from day one for reproducibility hooks even though release reproducibility is not Phase 1.

### Decision 7: `dryoc 0.8` for libsodium-compatible crypto

**Context**: [datum-protocol-rust-implementation § crate recommendation](../wiki/concepts/datum-protocol-rust-implementation.md#crate-recommendation-dryoc-08): `dryoc 0.8` is the only pure-Rust crate covering all four needed primitives (sealed box, precomputed crypto_box, Ed25519 detached, randombytes_buf). `sodiumoxide` is archived; `crypto_box` (RustCrypto) is missing 2 of 4 primitives.

**Decision**: `dryoc 0.8` behind a `DatumCrypto` trait (so we can swap to `libsodium-sys-stable` for byte-exact cross-validation tests). Cipher is **XSalsa20Poly1305** (libsodium default), **not** ChaCha20Poly1305 — this correction is asserted via test in `datum-protocol`.

**Consequences**: Phase 1 binary is musl-static-clean even though static-musl artifacts are deferred to Phase 2. The `_easy` vs `_detached` MAC layout difference (libsodium prepends 16-byte MAC; dryoc returns separately — must concatenate `mac || ct`) is wrapped once in `crypto.rs`.

### Decision 8: Hand-rolled `reqwest + corepc-types` for bitcoind RPC

**Context**: [drop-in-rust-port-architecture § bitcoind RPC](../wiki/concepts/drop-in-rust-port-architecture.md#bitcoind-rpc--hand-rolled-reqwest--corepc-types): `bitcoincore-rpc` archived 2025-11-25; `corepc-client` flagged "do not use in production"; `bitcoind-async-client` is wallet-focused with zero mining methods; `jsonrpsee` is overweight.

**Decision**: Hand-rolled `reqwest + corepc-types` JSON-RPC client (~100-150 LOC). 4 RPC methods total: `getblocktemplate`, `getbestblockhash`, `submitblock`, `preciousblock`. Cookie auth + UserPass.

**Consequences**: Free upgrade — Phase 1 implements GBT native long-polling (75s timeout, longer than bitcoind's ~60s GBT deadline) replacing C's signal+1Hz fallback. SIGUSR1 handler stays for blocknotify-script compatibility but becomes a redundancy.

### Decision 9: SRI `channels_sv2` + `handlers_sv2` for SV2 server side

**Context**: [sv2-downstream-architecture § reusable-vs-write-from-scratch](../wiki/concepts/sv2-downstream-architecture.md#reusable-vs-write-from-scratch-breakdown): ~9600 LOC reused from SRI vs ~1500 LOC written for the SV2 server side, 6:1 reuse ratio. `ExtendedChannel::new_for_pool` + `JobFactory::new_extended_job` is the supported code path for "plain SV2 pool front, no JDS, no JDC".

**Decision**: Phase 1 SV2 server uses SRI's `channels_sv2::server::extended::ExtendedChannel` with `DefaultJobStore<ExtendedJob>`. Custom `JobStore` consumes the GBT template + OCEAN coinbase outputs. Plain SV2 pool front, no Job Declaration. Extranonce 32-byte hierarchical → 12-byte flat bridge in `extranonce_bridge.rs` with `total_extranonce_len = 12`.

**Consequences**: Pinned SRI version in `Cargo.toml`; track SRI master via Cargo.lock for predictable upgrades. Vendor a stratum-translation v0.3.0 dep for any internal-translate fallback path Phase 2 might want; Phase 1 doesn't use it (direct-serve SV1).

## Implementation Phases

### Phase 0 — bootstrap (estimated effort: 2-4 hours)

**Goal**: Empty workspace at `~/repos/datum-rs/` becomes a buildable 11-crate Cargo workspace with a `datum_gateway` binary that prints `--version` and exits.

**Tasks**:
- [ ] Create greenfield repo at `~/repos/datum-rs/` (already exists as empty `.git`); MIT license file.
- [ ] Workspace `Cargo.toml` per playbook `## What concrete code looks like in week one` block (resolver = "2", 11 crate members, edition 2021, rust-version 1.83).
- [ ] Per-crate `Cargo.toml` stubs with workspace dep inheritance.
- [ ] `crates/datum-bin/src/main.rs`: prints version + git hash on `--version`, exits.
- [ ] `[[bin]] name = "datum_gateway"` in `datum-bin` Cargo.toml (underscore preserved).
- [ ] `.gitignore` (Rust + macOS), `rustfmt.toml`, `clippy.toml`, `rust-toolchain.toml` pinning 1.83.
- [ ] Initial commit, public push to `github.com/<author>/datum-rs` with MIT license, README pointing at the wiki playbook.
- [ ] Open issue #1 (this repo) cross-referencing `OCEAN-xyz/datum_gateway#146`.
- [ ] GitHub Actions workflow `.github/workflows/ci.yml`: `cargo build`, `cargo test`, `cargo clippy --all -- -D warnings`, `cargo fmt --check` on `ubuntu-latest` + `macos-latest`. No release artifacts.

**Dependencies**: None.

**Validation**: `cargo build --workspace --locked` green. `cargo test --workspace` green (zero tests yet). `target/release/datum_gateway --version` prints. CI green on first push.

**Wiki grounding**: Playbook Phase 0 steps 1-2; [drop-in-distribution § cargo binary name](../wiki/concepts/drop-in-distribution.md#cargo-binary-name); [drop-in-rust-port-architecture § workspace layout](../wiki/concepts/drop-in-rust-port-architecture.md#workspace-layout-11-crates).

---

### Phase 1 — foundation crates (estimated effort: 1-2 weeks)

**Goal**: Config parsing, bitcoind RPC client, GBT puller, coinbaser blob parser all compile, unit-test, and run end-to-end against a regtest bitcoind.

**Tasks**:
- [ ] `datum-config` (~300-400 LOC) — `serde` + `serde_json` JSON config schema. 8 sections, ~70 keys per [drop-in-surface-inventory](../wiki/concepts/drop-in-surface-inventory.md#inventory-by-surface). Validation: `vardiff_min` rounded down to power of 2; `work_update_seconds` clamped [5,120]; `coinbase_tag_*` combined ≤88B. Add `--validate-config` subcommand. **Defer `--migrate-config --dry-run` to Phase 2/3.** Add new `stratum_v2` section (default disabled) for the SV2 opt-in.
- [ ] `datum-rpc` (~100-150 LOC) — hand-rolled `reqwest + corepc-types` JSON-RPC client. Cookie auth + UserPass. 4 methods: `getblocktemplate`, `getbestblockhash`, `submitblock`, `preciousblock`. Cookie-reload on 401. 5s timeout.
- [ ] `datum-blocktemplates` (~300-400 LOC) — GBT puller with native long-poll loop (75s timeout). Rules `["segwit", "taproot"]` (free upgrade vs C's hardcoded `["segwit"]`). Templates broadcast via `tokio::sync::watch::channel<Arc<Template>>`.
- [ ] `datum-coinbaser` (~200-300 LOC) — V2 coinbaser blob parser/builder: `[datum_id 1B][outval LE 8B][slen 1B][script]` × ≤512. Single source-of-truth `Vec<TxOut>`, also broadcast via `tokio::sync::watch`. Phase 1 keeps all 6 fingerprint variants for SV1 parity.
- [ ] Integration test: spin up `bitcoind -regtest`, drive `datum-rpc` + `datum-blocktemplates` + `datum-coinbaser` end-to-end; assert template + coinbase outputs round-trip cleanly.

**Dependencies**: Phase 0.

**Validation**: All four crates `cargo test`-green. Integration test against regtest bitcoind passes locally and in CI (CI uses a `bitcoind` action or Dockerized regtest). `datum_gateway --validate-config <path>` exits 0 on a known-good config and exits 1 on a malformed config.

**Wiki grounding**: Playbook Phase 1 steps 3-4 + Phase 2 steps 5-6; [drop-in-rust-port-architecture per-module table](../wiki/concepts/drop-in-rust-port-architecture.md#per-module-port-plan); [drop-in-surface-inventory config schema row](../wiki/concepts/drop-in-surface-inventory.md#inventory-by-surface).

---

### Phase 2 — encrypted DATUM upstream + live OCEAN gate (estimated effort: 4-6 weeks; the gating engineering work)

**Goal**: `datum-protocol` crate fully functional against an in-tree mock pool harness AND completes a hello-world handshake against production OCEAN DATUM Prime.

**Tasks**:
- [ ] `datum-protocol/src/frame.rs` — 32-bit packed header pack/unpack. `cmd_len (22 bits)`, `reserved (2)`, `is_signed (1)`, `is_encrypted_pubkey (1)`, `is_encrypted_channel (1)`, `proto_cmd (5)`. Capture a real C-emitted PING frame from the C gateway running locally; pin via test before coding pack/unpack.
- [ ] `datum-protocol/src/obfuscation.rs` — MurmurHash3-32 finalizer (~15 LOC inline) with init constant `0xb10cfeed`. XOR-feedback chain seeded by client-chosen `nk`.
- [ ] `datum-protocol/src/crypto.rs` — `DatumCrypto` trait + `dryoc 0.8` impl. Cipher = **XSalsa20Poly1305**. `_easy` vs `_detached` MAC concatenation wrapper. Test asserts cipher choice via fixed-input fixed-key fixed-nonce vector matched against C output.
- [ ] `datum-protocol/src/handshake.rs` — state machine (states 0..3). `crypto_box_seal` to OCEAN long-term pubkey; hello carries long-term + session Ed25519 + X25519 pubkeys, signed with long-term Ed25519. OCEAN pool pubkey hardcoded as default in `datum-config` (parsed by `datum_pubkey_to_struct`-equivalent).
- [ ] `datum-protocol/src/opcodes.rs` — `ProtoCmd` + `MiningSub` enums; 3-level dispatch under `0x50`.
- [ ] `datum-protocol/src/messages/{coinbaser,share,job_validation,client_config,block_notify}.rs` — opcodes 0x10/0x11, 0x27 + 0x8F response, 0x50, 0x99, 0xF9.
- [ ] `datum-protocol/src/client.rs` — Tokio async I/O top level. 8-job ring; `mpsc<ShareToSubmit>` ingress.
- [ ] `datum-protocol/src/mock_pool.rs` — server-side reference for hermetic tests.
- [ ] **Live OCEAN handshake probe** (gate): `crates/datum-protocol/src/bin/handshake_probe.rs` connects to `datum-beta1.mine.ocean.xyz:28915` with version `"v0.4.1-beta"`, completes handshake, prints server version, exits. Run manually; document any version-string fallback in `MIGRATING.md` draft.
- [ ] `datum-dupes` (~150-200 LOC) — bounded `lru::LruCache`, key on `(channel_id, sequence_number, ntime, version, extranonce, nonce)`. Switch from C's SV1-sizing formula.
- [ ] `datum-submitblock` (~80-120 LOC) — direct submission to bitcoind on block discovery. Replaces ~140 C LOC. `extra_block_submissions.urls[]` pass-through.

**Dependencies**: Phase 1.

**Validation**: 
- All `datum-protocol` unit tests green against `mock_pool`.
- The hello-world handshake probe completes successfully against production OCEAN. **If rejected**, immediately fall back to `v0.3.3` or `v0.2.6` and document in `MIGRATING.md`. **If still rejected, this is a Phase 2 blocker** — escalate to OCEAN engineering or revisit project assumptions.
- `datum-dupes` handles 100k-share fuzz without exceeding bounded capacity.
- `datum-submitblock` triggers `submitblock` RPC + `preciousblock` on a regtest hand-mined block.

**Wiki grounding**: Playbook Phase 3 step 7; [datum-protocol-rust-implementation](../wiki/concepts/datum-protocol-rust-implementation.md) (full); [drop-in-rust-port-architecture per-module table § datum_protocol.c, datum_stratum_dupes.c, datum_submitblock.c rows](../wiki/concepts/drop-in-rust-port-architecture.md#per-module-port-plan); the "live OCEAN as soon as protocol crate compiles" interview decision.

---

### Phase 3 — SV1 + SV2 downstream in parallel (estimated effort: 6-10 weeks)

**Goal**: Both SV1 and SV2 server paths fully functional. ASICs can mine against both ports. Shared coinbase output array proven byte-exact via golden vectors.

**Parallel branch A — SV1 (`feature/sv1-server`)**:
- [ ] `datum-stratum-sv1` (~600-900 LOC) — direct-serve, bit-exact with C `datum_stratum.c`. SV1 mining methods: `mining.subscribe`, `mining.authorize`, `mining.notify`, `mining.submit`, `mining.set_difficulty`, `mining.suggest_difficulty`. Vardiff (port the C clamp logic).
- [ ] Extranonce layout: `extranonce1 = (thread_id << 22) | (client_id ^ 0xB10CF00D)` for protocol parity. (Per [gateway-internals-c-architecture § extranonce layout](../wiki/concepts/gateway-internals-c-architecture.md#extranonce-layout-current-c-gateway).)
- [ ] Six local share validation checks (PoW, target, stale, ntime, dedup, ring-aged) per the C reference.
- [ ] Golden-vector test: drive C gateway and Rust SV1 with identical template + coinbase + miner subscription; assert byte-equivalent `mining.notify` and `mining.submit` ack JSON.

**Parallel branch B — SV2 (`feature/sv2-server`)**:
- [ ] `datum-stratum-sv2` (~500-800 LOC) — SRI `channels_sv2::server::ExtendedChannel<DefaultJobStore<ExtendedJob>>`. Custom `JobStore` impl that consumes GBT template watch + coinbase outputs watch.
- [ ] `extranonce_bridge.rs` — `ExtranonceAllocator` with `total_extranonce_len = 12`, partition `[local_prefix=0, local_index=2, rollable=10]`. Concatenate prefix+rolling for upstream submit.
- [ ] `HandleMiningMessagesFromClientAsync` impl — 7 leaf handlers per [sv2-downstream-architecture § code organization](../wiki/concepts/sv2-downstream-architecture.md#code-organization-phase-1) (adapted for in-process drop-in, not sidecar).
- [ ] Channel registry: `HashMap<channel_id, ExtendedChannel>` behind `tokio::Mutex`.
- [ ] Plain SV2 pool front — no JDS, no JDC. `JobFactory::new_extended_job` consumes shared `Vec<TxOut>`.
- [ ] Golden-vector test: assert SV2 coinbase tx outputs byte-equivalent to SV1 path's outputs given the same template + OCEAN blob.

**Shared (both branches must satisfy)**:
- [ ] Single `tokio::sync::watch::Receiver<Arc<Vec<TxOut>>>` in both server crates; neither reparses the OCEAN blob.
- [ ] Cross-protocol golden vector: same template + same blob → byte-identical sum-of-coinbase-outputs across SV1 `coinb1/coinb2` synthesis and SV2 `JobFactory::new_extended_job` output.
- [ ] Failover behavior: prolonged DATUM upstream outage → SV1 TCP close + SV2 explicit `CloseChannel` + TCP close ([dual-protocol-downstream § failover behavior](../wiki/concepts/dual-protocol-downstream.md#failover-behavior)).
- [ ] Disconnect-all-on-outage replicated for both protocols.

**Dependencies**: Phase 2.

**Validation**: 
- SV1 path: physical Antminer S19 / S21 with stock firmware mines through `datum-rs` to OCEAN testnet/beta endpoint. Share rate within 10% of C gateway baseline.
- SV2 path: BraiinsOS+ Antminer mines through `datum-rs:23335` to OCEAN testnet/beta endpoint.
- Cross-protocol golden-vector test: zero divergence between coinbase output sums under identical inputs.
- Failover: kill DATUM upstream; both SV1 and SV2 clients receive close + TCP close within 30s.

**Wiki grounding**: Playbook Phase 4 steps 8-9; [dual-protocol-downstream](../wiki/concepts/dual-protocol-downstream.md) (full); [sv2-downstream-architecture](../wiki/concepts/sv2-downstream-architecture.md) (full, adapted from sidecar to in-process); [gateway-internals-c-architecture § local share validation](../wiki/concepts/gateway-internals-c-architecture.md#local-share-validation-six-checks).

---

### Phase 4 — observability surface + main binary (estimated effort: 3-5 weeks)

**Goal**: `datum_gateway` binary runs end-to-end. Operator-facing 14-endpoint HTTP API matches the C gateway URL paths and JSON shapes. Custom `tracing` formatter matches C's log line shape byte-for-byte. Phase 1 ends here.

**Tasks**:
- [ ] `datum-logger` (~50-80 LOC) — custom `tracing-subscriber` formatter producing `TS.ms [func_name_padded_44] LEVEL: msg` with right-padded 5-char level prefix (`"  ALL"`, `"DEBUG"`, `" INFO"`, `" WARN"`, `"ERROR"`, `"FATAL"`). Daily rotation via `tracing-appender Rotation::DAILY`. Side-by-side log-string fixture file vs C output (committed).
- [ ] `datum-api` (~800-1200 LOC) — **the largest single crate** (40% of residual port). `axum` rewrite of the 14-endpoint dashboard:
  - `/`, `/clients`, `/threads`, `/coinbaser`, `/config`, `/cmd`
  - `/assets/*` (embedded HTML/CSS/SVG)
  - `/NOTIFY` (HTTP equivalent of SIGUSR1)
  - `/testnet_fastforward`, `/umbrel-api`
  - HTTP Digest auth: SHA-256 + MD5 fallback.
  - CSRF token: `SHA256("DATUM Anti-CSRF Token" + port + admin_password)`.
  - URL paths and JSON shapes match C exactly; HTML can be cleaner.
  - **Defer `/metrics` (Prometheus) to Phase 2/3** per user brief.
- [ ] `datum-bin` (~300 LOC) — main loop: parse CLI (`-?/--help`, `-c/--config FILE`, `--example-conf`, `--test`, `--version`); spawn config + RPC + blocktemplates + coinbaser + protocol + sv1-server + sv2-server (gated) + dupes + submitblock + api + logger as Tokio tasks. SIGUSR1 → force GBT refresh. SIGPIPE → ignore. SIGTERM/SIGINT → clean shutdown (additive vs C).
- [ ] Block-discovery glue (~30-50 LOC) — SIGUSR1 + `/NOTIFY` HTTP do the same thing; 2.5s race-dedup.
- [ ] Contract test against the 14-endpoint list: GET each path with valid auth, assert HTTP 200 + JSON schema match.

**Dependencies**: Phase 3.

**Validation**:
- Full Phase 1 verification: bring up `datum-rs` against regtest bitcoind + mock OCEAN; SV1 + SV2 ASICs mine; HTTP API serves `/clients`, `/threads`, `/coinbaser` correctly.
- Log-format fixture diff: zero byte difference vs C gateway log output for matched events.
- Switch-day runbook 5-check verification ([switch-day-runbook § phase 3](../wiki/concepts/switch-day-runbook.md#phase-3--verify-5-checks-any-failure--rollback)) passes:
  1. `datum_gateway --version` prints version + commit hash.
  2. Dashboard pool state: `http://gateway:7152/` shows OCEAN connection authenticated.
  3. First share accepted within 1-2 min.
  4. Share-rate floor matches pre-swap rate within 10%.
  5. Log line health: existing grep alerts still fire.
- v0.1.0 release tag, GitHub Release with hand-uploaded binary (no CI artifact yet — Phase 2 adds that).

**Wiki grounding**: Playbook Phase 5 step 10; [drop-in-rust-port-architecture per-module table § datum_api.c, datum_logger.c rows](../wiki/concepts/drop-in-rust-port-architecture.md#per-module-port-plan); [drop-in-surface-inventory § four hard surfaces](../wiki/concepts/drop-in-surface-inventory.md#the-four-hard-surfaces); [switch-day-runbook § phase 3](../wiki/concepts/switch-day-runbook.md#phase-3--verify-5-checks-any-failure--rollback).

---

## What is explicitly NOT in Phase 1 (deferred to Phase 2/3)

Per the user brief, these are out of scope for Phase 1:

**Distribution polish (Phase 2)**:
- StartOS `.s9pk` package fork of `OCEAN-xyz/datum-gateway-startos`.
- `cargo-deb` `.deb` artifacts with `Replaces:`/`Conflicts:`.
- Multi-arch `docker buildx` push to `ghcr.io/<author>/datum-gateway`.
- Static-musl release artifacts attached to GitHub Releases.
- Reproducible builds (`SOURCE_DATE_EPOCH`, `--remap-path-prefix`).

**Observability extras (Phase 3)**:
- Prometheus `/metrics` endpoint.
- Structured JSON log option (gated, default off).
- `--migrate-config --dry-run` subcommand.
- `Type=notify` systemd integration.
- PID file (`--pid-file PATH`).

**Documentation polish (Phase 2/3)**:
- Full `MIGRATING.md` (a stub draft created during Phase 2 live-OCEAN gate is fine).
- `CHANGELOG.md`, `COMPAT.md`.

These are tracked in [Open Questions / Phase 2/3 backlog](#open-questions) below.

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| DATUM Prime wire-protocol drift mid-development | [drop-in-rust-datum-gateway § risks](../wiki/topics/drop-in-rust-datum-gateway.md#risks--open-questions) | Phase 2 live-OCEAN handshake probe gates further work; in-tree mock pool keeps CI hermetic |
| OCEAN production server runs older protocol than master | [datum-protocol-rust-implementation § production version drift](../wiki/concepts/datum-protocol-rust-implementation.md#production-version-drift) | Configurable version string; default `"v0.4.1-beta"`; documented fall-back to `v0.3.3` / `v0.2.6` |
| Coinbase output divergence SV1↔SV2 (operator pays self instead of OCEAN) | [dual-protocol-downstream § per-channel isolation](../wiki/concepts/dual-protocol-downstream.md#per-channel-isolation) | **Catastrophic if missed.** Single source-of-truth `Vec<TxOut>` + cross-protocol golden vector test (Phase 3 shared validation) |
| Log format drift breaks operator alerts | [drop-in-surface-inventory § four hard surfaces](../wiki/concepts/drop-in-surface-inventory.md#the-four-hard-surfaces) | Custom `tracing` formatter + fixture-diff test in Phase 4 |
| Disconnect-all-on-outage cascade misimplemented for SV2 (needs explicit `CloseChannel`) | [dual-protocol-downstream § failover behavior](../wiki/concepts/dual-protocol-downstream.md#failover-behavior) | Failover validation gate in Phase 3 (kill DATUM upstream, observe both protocols close cleanly) |
| `datum-api` rewrite underestimated (40% of residual port) | [drop-in-rust-port-architecture per-module table](../wiki/concepts/drop-in-rust-port-architecture.md#per-module-port-plan) | Phase 4 sequenced last; iterate against the 14-endpoint contract; HTML rewrite is freer than JSON contract |
| Header bitfield byte ordering differs between Rust and C (implementation-defined in C) | [datum-protocol-rust-implementation § known unknowns](../wiki/concepts/datum-protocol-rust-implementation.md#known-unknowns-gating) | Capture-and-pin a real C-emitted PING frame in Phase 2 before coding pack/unpack |
| SRI master breakage during Phase 3 | [sv2-downstream-architecture](../wiki/concepts/sv2-downstream-architecture.md) | Pin SRI version in `Cargo.toml`; track upstream via Cargo.lock |
| Dupe-table sizing breaks under SV2's many-channels-per-connection | [drop-in-rust-port-architecture per-module table § datum_stratum_dupes.c row](../wiki/concepts/drop-in-rust-port-architecture.md#per-module-port-plan) | `lru::LruCache` with bounded capacity, key on `(channel_id, seq, ntime, version, xn, nonce)` |
| OCEAN production endpoint unavailable for live handshake probe | Phase 2 gate dependency | Fall back to `datum-beta1.mine.ocean.xyz:28915` testnet endpoint; document availability windows |

## Open Questions

These are unresolved after wiki + interview; they map to follow-up research or runtime observation, not Phase 1 blockers (unless flagged):

1. **OCEAN production server protocol version** vs master `v0.4.1-beta`. **BLOCKER for Phase 2 if probe fails.** Empirical answer ships at the end of Phase 2.
2. **Header bitfield byte ordering.** Resolved by capture-and-pin in Phase 2.
3. **Per-miner unique-identifier delivery semantics.** 16-bit ID — one per gateway? per miner? Affects SV2 channel mapping. Runtime observation in Phase 3.
4. **Coinbaser refresh trigger** — block-notify? timer? per-share? Re-read `datum_coinbaser.c` during Phase 1 work; document in `datum-coinbaser` README.
5. **OCEAN keypair format on first share submit.** Validated by golden-vector test in Phase 3 (per-share Bitcoin payout address parsing).
6. **Phase 2/3 backlog**: distribution polish (StartOS, `.deb`, Docker push), observability extras (Prometheus, structured logs, `--migrate-config`), documentation polish (`MIGRATING.md` full, `CHANGELOG.md`, `COMPAT.md`). Suggested: open issues against the new repo for each, link them in the master tracking issue.

## Suggested Inventory Records

This plan creates a durable Phase 1 work queue. Once the user confirms, suggested inventory entries:

- **Open question**: "OCEAN production server runs `v0.4.1-beta` (verified via live handshake probe)" — close-out condition, blocks Phase 3 if False.
- **Open question**: "Header bitfield byte ordering is little-endian on the wire" — close-out condition, captured PING frame committed as test fixture.
- **Watch item**: SRI master (`stratum-mining/stratum`) — track for breaking changes during Phase 3 SV2 work.
- **Watch item**: `OCEAN-xyz/datum_gateway` master — track for protocol-version bumps that could shift the master string Rust port targets.
- **Backlog (Phase 2)**: Distribution polish — StartOS, `.deb`, Docker push, static-musl artifacts.
- **Backlog (Phase 3)**: Observability extras — Prometheus, structured logs, `--migrate-config`, PID file, systemd notify.

I have not created these inventory records yet — let me know if you want them added to the wiki's inventory layer.

## Sources Consulted

- [Playbook: Drop-in Rust DATUM gateway](playbook-drop-in-rust-datum-gateway-2026-06-01.md) — sequenced 10-step action plan; the source-of-truth per the user brief.
- [Drop-in Rust DATUM gateway — synthesis](../wiki/topics/drop-in-rust-datum-gateway.md) — TL;DR + architecture + risks; framing.
- [Rust port architecture](../wiki/concepts/drop-in-rust-port-architecture.md) — 11-crate workspace, per-module port plan, LOC budget, GBT long-poll pattern, dupe-table redesign.
- [Dual-protocol downstream](../wiki/concepts/dual-protocol-downstream.md) — SV1+SV2 dual-port design, per-channel isolation, single source-of-truth coinbase invariant, failover, risk matrix.
- [Drop-in surface inventory](../wiki/concepts/drop-in-surface-inventory.md) — 35-row operator-facing surface, 4 hard surfaces, de-risking finding (no on-disk state).
- [DATUM Protocol Rust implementation](../wiki/concepts/datum-protocol-rust-implementation.md) — `dryoc 0.8`, XSalsa20Poly1305 cipher correction, module layout, capture-and-pin test strategy, OCEAN pubkey location.
- [SV2-downstream architecture](../wiki/concepts/sv2-downstream-architecture.md) — SRI reuse mapping, `ExtendedChannel` + `JobFactory` + `DefaultJobStore`, extranonce 32→12 byte bridge.
- [Gateway internals — C architecture](../wiki/concepts/gateway-internals-c-architecture.md) — module map, queue seam, threading model, SV1 extranonce layout, six local share validation checks.
- [Drop-in distribution](../wiki/concepts/drop-in-distribution.md) — distribution channels (referenced for what's deferred to Phase 2/3).
- [Switch-day runbook](../wiki/concepts/switch-day-runbook.md) — 5-check verification gate (Phase 4), F1-F8 failure catalog (input to risk table).

## See Also

- [Wiki master index](../_index.md)
- [DATUM Gateway overview (anchor article)](../wiki/topics/datum-gateway-overview.md) — the C gateway being replaced
- [DATUM SV2-downstream proxy — sidecar playbook](../wiki/topics/datum-sv2-proxy-playbook.md) — the *sidecar* alternative; not this plan
