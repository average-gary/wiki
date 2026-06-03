# Log — datum

## [2026-06-02] all-phases code-complete | average-gary/datum-rs commits 76d11ca, 47ac473, 94aa66b — implementation pass landed for all 11 crates: datum-config, datum-rpc, datum-blocktemplates, datum-coinbaser, datum-dupes, datum-submitblock, datum-protocol, datum-stratum-sv1, datum-stratum-sv2, datum-logger, datum-api, datum-bin. 88 tests across 11 crates, all green. Real bugs caught: (1) submitblock null-result rejected as Malformed because Option<Value>::None hides null vs absent — fixed; (2) header obfuscator chain advanced using plaintext, breaking decryption — fixed to advance using ciphertext; (3) ProtoCmd 5-bit collisions: Coinbaser/JobValidation (0x10), ClientConfig/BlockNotify (0x19) — documented, frame flags must disambiguate. MSRV bumped 1.83→1.86→1.89 (dryoc 0.8 floor). Open work for v0.1.0 release: full SV1 direct-serve runtime, SRI integration in datum-stratum-sv2, DATUM handshake/messages/share-submit, live OCEAN handshake probe, header bitfield capture-and-pin, custom tracing formatter wired to subscriber, embedded HTML + Digest auth, cross-protocol golden-vector tests, ASIC fleet validation.

## [2026-06-02] phase-2 step-1 | handshake module + probe binary | average-gary/datum-rs commit d66fc64 — datum-protocol/src/handshake.rs (11-field hello payload assembly + Ed25519 detached signature + sealed-box wrap + framed with XOR'd header), datum-protocol/src/bin/handshake_probe.rs (one-shot CLI binary), tests/handshake_local.rs (full hermetic mock-pool round-trip). Two real obfuscation.rs bug fixes: INITIAL_SENDING_HEADER_KEY=0xDC871829 (was 0xb10cfeed); datum_header_xor_feedback rewritten as full Murmur single-block mix (was finalizer only). 89 tests green. Live OCEAN outcome: TCP connect succeeds, pool processes hello, drops connection silently across all version fall-backs (v0.4.1-beta, v0.3.3, v0.2.6, v0.4.1, v0.4.0-beta). Unblocks debugging path: capture-and-pin via inventory candidate `datum-header-bitfield-byte-ordering`.

## [2026-06-02] phase-1 step-4 | datum-rpc crate | average-gary/datum-rs commit 3d29417 — hand-rolled reqwest+serde_json client for bitcoind. 4 RPC methods (getbestblockhash, getblocktemplate, submitblock, preciousblock). Cookie-reload-on-401 retry (matches datum_jsonrpc.c::bitcoind_json_rpc_call). 12 tests (8 unit + 4 hyper integration). Bug caught: submitblock null-result was rejected as Malformed because Option<Value>::None hides null vs absent — fixed by inspecting raw JSON Object key presence. Bitcoin Core returns null for submitblock/preciousblock on success; a strict-Option port would silently break block submission. MSRV bump 1.83 → 1.86 (idna_adapter 1.2.2 + icu_* family need edition2024 / 1.86; SRI master is still 1.75 so we're well over the binding floor).

## [2026-06-02] phase-1 step-3 | datum-config crate | average-gary/datum-rs commit 9333403 — 8-section / 47-key JSON schema ported from datum_conf.c @ a3da9e69; 16 unit tests; --validate-config + --example-conf wired into datum-bin; C upstream's own doc/example_datum_gateway_config.json validates clean against the Rust port (first cross-check). Wiki claim of "~70 keys" corrected to 47. Wiki claim of "share_stale_seconds clamp" corrected to fatal-error-not-clamp.

## [2026-06-02] phase-0 | bootstrap complete | github.com/average-gary/datum-rs commit 2ddc417 — 11-crate Cargo workspace, MIT, rust-version=1.83, datum_gateway --version works, CI green on ubuntu-latest + macos-latest (run 26823181920), tracking issue #1 open cross-referencing OCEAN-xyz/datum_gateway#146

## [2026-06-01] inventory | added question ocean-production-protocol-version (p0)
## [2026-06-01] inventory | added question datum-header-bitfield-byte-ordering (p1)
## [2026-06-01] inventory | added watch sri-master-watch (p2)
## [2026-06-01] inventory | added watch datum-gateway-upstream-watch (p2)
## [2026-06-01] inventory | added task datum-rs-phase-2-distribution-polish (p2, blocked)
## [2026-06-01] inventory | added task datum-rs-phase-3-observability-extras (p3, blocked)

## [2026-06-01] plan | "Bootstrap ~/repos/datum-rs/. Phase 1 ships full dual-protocol drop-in: SV1 + SV2 downstream with shared DATUM upstream and a single source-of-truth coinbase output array." (project: datum-rs) → output/plan-bootstrap-datum-rs-2026-06-01.md (8 articles consulted, 9 decisions, 5 phases — bootstrap → foundations → DATUM upstream + live OCEAN gate → SV1+SV2 in parallel → observability + main binary; distribution polish + observability extras deferred to Phase 2/3 per brief)

## [2026-06-01] rename | topic 'datum-gateway' → 'datum'. Scope broadened from OCEAN gateway internals to include SV2-downstream proxy design. Filesystem moved $HOME/wiki/topics/datum-gateway → $HOME/wiki/topics/datum; wikis.json updated with renamed-from + renamed-on.

## [2026-06-01] research --plan --deep | datum · "DATUM-capable proxy: SV2 downstream + DATUM/OCEAN upstream" — 5 paths × 8 agents = ~40 parallel research workers. 32 new sources ingested (22 articles + 10 repo reads + 1 notes + 0 papers/data). 5 new articles compiled (4 concepts + 1 topic playbook), 1 existing article updated (`datum-protocol` confidence upgraded medium→high with full wire-format), 1 existing article corrected (`datum-gateway-overview` retracted bogus "in-tree Rust port" claim).

Headline findings:
- (a) DATUM Protocol wire format reconstructed from `src/datum_protocol.[ch]`: 32-bit packed header (22-bit length, 5-bit opcode, 3 encryption flags), libsodium ChaCha20-Poly1305 (NOT Noise, NOT TLS), header-obfuscation chain seeded by `0xb10cfeed` (PR #202 hardens), 8-job ring, 16-bit unique-identifier in scriptSig, 6 sub-opcodes under proto_cmd=5 (0x10/0x11/0x27/0x50/0x8F/0x99/0xF9).
- (b) Issue #146 (`OCEAN-xyz/datum_gateway#146`) by `electricalgrade` (2025-08-23) is the only public, named, sourced SV2-DATUM bridge proposal. Open 9 months with no Concept ACK; luke-jr soft-pushback toward pkg-config shared library.
- (c) OCEAN docs explicitly reject SV2; Luke Dashjr quote on bitcoin/bitcoin#31002: "GBT has worked for years and nothing additional is needed for DATUM." SRI repos have zero documented engagement with DATUM.
- (d) `electricalgrade/sv2` (the only adjacent code) is stalled since 2025-09-21 — Noise + SetupConnection only, no DATUM bridge.
- (e) Gateway has a clean producer/consumer **queue seam** (`datum_queue.c`, ~80 LOC rwlock dual-buffer) between SV1 server (`datum_stratum.c`) and DATUM client (`datum_protocol.c`) — the architectural finding that makes the SV2-downstream rewrite tractable.
- (f) Recommended architecture: separate Rust binary (Tokio), plain SV2 pool front (no JDS, no JDC), `ExtendedChannel::new_for_pool` + `DefaultJobStore`, `total_extranonce_len = 12` for the SV2-32B → DATUM-12B bridge. ~1500 LOC new + ~9600 LOC SRI reuse (6:1 ratio).
- (g) Phase 1: SV1 client upstream to local datum_gateway:23334; Phase 2: native DATUM-protocol speaker direct to OCEAN.
- (h) DATUM Prime (pool side) is closed-source — no offline test target; integration tests must hit live OCEAN.
- (i) Operator value is real but narrow: "OCEAN/TIDES connectivity for SV2 firmware fleets." Trust delta vs running plain DATUM Gateway alongside SV1 firmware: NEGATIVE on custody (proxy = tiny pool), NEUTRAL on censorship (DATUM already had it), POSITIVE on transport security + channel hygiene.
- (j) Retraction: previous wiki revision claimed an in-tree Rust port at `datum_gateway_rust/` anchored on commit a3da9e69. Path 2 verified this is FALSE: a3da9e69 is a CI-workflow-only merge containing zero `.rs` files; no Rust code exists upstream or in any of 56 forks.

## [2026-06-01] compile | 32 sources → 5 new articles, 2 updated. New: gateway-internals-c-architecture, sv2-downstream-architecture, ocean-sv2-stance-and-prior-art, operator-value-and-threat-model, datum-sv2-proxy-playbook (topic). Updated: datum-protocol (confidence high; full wire format), datum-gateway-overview (Rust-port retraction).

## [2026-06-01] research --wiki datum --deep | datum · "How can we use SV2 for a DATUM gateway? Miners SV2 downstream, DATUM upstream, drop-in replacement for `datum_gateway`" — question-mode, 7 parallel agents (4 sub-questions + 3 adjacent). 30 sources ingested across all paths. 6 new concept articles + 1 new topic article + 1 output playbook artifact compiled. 1 existing article updated (datum-protocol — cipher correction).

Agent breakdown:
- **Q1** (drop-in surface): 4 sources, 35-row inventory of operator-facing surfaces. **De-risking finding: no on-disk state to migrate** (gateway regenerates keypair every startup; TIDES attributes by Bitcoin payout address, not pubkey).
- **Q2** (Rust DATUM upstream): 4 sources. Crate pick: `dryoc 0.8` (pure Rust, libsodium-compatible, musl-static-clean). **Critical correction**: cipher is XSalsa20Poly1305, NOT ChaCha20-Poly1305. OCEAN pool pubkey hardcoded in `datum_conf.c`.
- **Q3** (non-stratum modules): 4 sources. 11-crate Cargo workspace, ~5,300 C LOC → ~4,000-5,500 Rust LOC, `datum-api` is 40% of port budget. Free upgrade: GBT native long-poll replaces signal+1Hz dance.
- **Q4** (dual-protocol risks): 5 sources. OCEAN miner base ~75-90% SV1 (low-med confidence). Recommended: dual-port (23334 SV1 default, 23335 SV2 opt-in). SRI's `stratum_translation` crate is the SV1↔SV2 adapter.
- **Q5** (build/distribution): 4 sources. 4 channels: source / Ubuntu PPA / StartOS / Docker (no upstream image — free win). `cargo-deb` with `Replaces:`/`Conflicts:`. StartOS submodule swap is high-leverage.
- **Q6** (bitcoind RPC): 5 sources. **`bitcoincore-rpc` archived 2025-11-25**. Hand-rolled `reqwest + corepc-types` (~200 LOC) is the rust-bitcoin official guidance.
- **Q7** (operator migration): 4 sources. 5-phase runbook + F1-F8 failure-mode catalog + MIGRATING.md skeleton. C gateway ships zero migration docs today.

Headline findings:
- (a) Drop-in is feasible: ~4,000-5,500 Rust LOC over 4-6 months for one developer, replacing ~8,500 C LOC.
- (b) **No on-disk state to migrate** — switch-day rollback is a binary swap with zero compat tooling.
- (c) **Cipher correction**: prior wiki said ChaCha20-Poly1305; libsodium `crypto_box_*_easy` defaults to XSalsa20Poly1305. Both `dryoc` and RustCrypto's `crypto_box` match. Safe.
- (d) **Dual-protocol downstream is mandatory** because OCEAN's miner base is ~75-90% SV1; SV2-only would brick the fleet.
- (e) **`bitcoincore-rpc` is archived** (2025-11-25); rust-bitcoin org guidance is hand-rolled `reqwest + corepc-types`. Free upgrade: native GBT long-poll vs the C gateway's signal+1Hz fallback.
- (f) Hard operator surfaces: log line shape (44-char function-name padding); binary name `datum_gateway` (`bitcoin.conf` blocknotify recipes); 14 HTTP API URL paths (Umbrel widgets); default ports 23334/7152/28915.
- (g) `datum-api` is 40% of the residual port (~800-1200 Rust LOC for HTTP Digest + CSRF + 14 endpoints + embedded HTML/CSS/SVG).
- (h) Highest engineering risk: DATUM Prime wire-protocol drift; the protocol is the C source, OCEAN pool side is closed-source.
- (i) Catastrophic-if-missed risk: coinbase output divergence between SV1 `coinb1/coinb2` and SV2 `NewExtendedMiningJob.coinbase_tx_outputs` — operator could pay self instead of OCEAN.
- (j) Static-musl Rust binary opens distribution channels the C upstream can't reach (`FROM scratch` Docker, GitHub Release artifacts that actually run).

## [2026-06-01] compile | 30 sources → 6 new concept articles + 1 new topic + 1 output playbook artifact, 1 updated. New concepts: drop-in-surface-inventory, datum-protocol-rust-implementation, drop-in-rust-port-architecture, dual-protocol-downstream, drop-in-distribution, switch-day-runbook. New topic: drop-in-rust-datum-gateway. New output: playbook-drop-in-rust-datum-gateway-2026-06-01. Updated: datum-protocol (cipher correction XSalsa20Poly1305; OCEAN pool pubkey hardcoded; ephemeral keypair).

# Pre-rename history (when topic was 'datum-gateway')

## [2026-05-28] init | topic wiki created (anchored on OCEAN-xyz/datum_gateway @ a3da9e69)

## [2026-05-28] ingest-collection | datum-gateway via git: 2 new, 0 skipped, 2 total candidates (HEAD a3da9e6975984fd0ae584f37d76fe4afe2c75bac)

## [2026-05-28] ingest | OCEAN Documentation Index (raw/articles/2026-05-28-ocean-docs-index.md)
## [2026-05-28] ingest | Alternate Templates (raw/articles/2026-05-28-ocean-alternate-templates.md)
## [2026-05-28] ingest | DATUM Setup Guide (raw/articles/2026-05-28-ocean-datum-setup-guide.md)
## [2026-05-28] ingest | Lightning Payouts (raw/articles/2026-05-28-ocean-lightning-payouts.md)
## [2026-05-28] ingest | Core Antispam Node Policy (raw/articles/2026-05-28-ocean-core-antispam-policy.md)
## [2026-05-28] ingest | Core Node Policy (raw/articles/2026-05-28-ocean-core-policy.md)
## [2026-05-28] ingest | Data-Free Node Policy (raw/articles/2026-05-28-ocean-data-free-policy.md)
## [2026-05-28] ingest | OCEAN Node Policy (raw/articles/2026-05-28-ocean-node-policy.md)
## [2026-05-28] ingest | TIDES Technical Documentation (raw/articles/2026-05-28-ocean-tides-technical-documentation.md)
## [2026-05-28] ingest | The Origins of DATUM (raw/articles/2026-05-28-ocean-origins-of-datum.md)
## [2026-05-28] ingest | Introduction to the Lightning Network (raw/articles/2026-05-28-ocean-intro-to-lightning.md)
## [2026-05-28] ingest-collection | ocean-docs via web: 11 new (1 index + 10 sub-pages), 0 skipped (canonical_url=https://ocean.xyz/docs)

## [2026-05-28] compile | 3 sources → 5 new articles, 0 updated (datum-gateway-overview, datum-protocol, gateway-data-flow, stratum-usernames-and-modifiers, deployment-and-node-config)

## [2026-05-28] compile | 11 sources → 4 new articles, 3 updated (new: datum-history-and-motivation, tides-payout, lightning-payouts, node-policy-variants; updated: datum-gateway-overview, gateway-data-flow, deployment-and-node-config)
