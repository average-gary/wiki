---
title: "Playbook: Drop-in Rust DATUM gateway"
type: playbook
created: 2026-06-01
session: 2026-06-01-question-mode-deep
question: "How can we use SV2 for a DATUM gateway? Miners SV2 downstream, DATUM upstream, drop-in replacement for `datum_gateway`."
---

# Playbook — Drop-in Rust DATUM gateway

A practical playbook for building `datum-rs`: a Rust binary that drops in for `OCEAN-xyz/datum_gateway`, preserves SV1-to-ASIC compatibility for the existing OCEAN miner base, adds SV2-to-ASIC as an opt-in protocol on a new port, and reuses the same encrypted DATUM upstream to OCEAN.

The wiki articles linked from this playbook contain the full source material; this file is the executive summary + sequenced action list.

## The original question

> How can we use SV2 for a DATUM gateway? Miners SV2 downstream, DATUM upstream, **drop-in replacement for `datum_gateway`**.

## Decomposition (4 sub-questions + 3 adjacent — all answered)

| # | Sub-question | Answer | Article |
|---|---|---|---|
| Q1 | What does "drop-in" actually mean? | 35-row inventory; 4 hard surfaces (log format, binary name, HTTP API, default ports); no on-disk state to migrate | [[../wiki/concepts/drop-in-surface-inventory]] |
| Q2 | How to reimplement encrypted DATUM in Rust? | `dryoc 0.8` (pure-Rust libsodium-compatible); cipher correction (XSalsa20Poly1305, not ChaCha20); OCEAN pool pubkey hardcoded in `datum_conf.c` | [[../wiki/concepts/datum-protocol-rust-implementation]] |
| Q3 | Where does the port absorb non-stratum gateway concerns? | 11-crate Cargo workspace; ~5,300 C LOC → ~2,000-3,000 Rust LOC; `datum-api` is 40% of the residual port | [[../wiki/concepts/drop-in-rust-port-architecture]] |
| Q4 | What are the operational risks of dual-protocol drop-in? | OCEAN miner base ~75-90% SV1; dual-port (23334 SV1 + 23335 SV2 opt-in); SRI's `stratum_translation` crate is the SV1↔SV2 adapter | [[../wiki/concepts/dual-protocol-downstream]] |
| Q5 | How does the binary actually become a drop-in (packaging)? | 4 channels: source / Ubuntu PPA / StartOS / Docker (no upstream image — free win); `cargo-deb` with `Replaces:` + `Conflicts:`; static-musl via `dryoc` | [[../wiki/concepts/drop-in-distribution]] |
| Q6 | Which Rust crate handles bitcoind RPC? | `bitcoincore-rpc` is **archived 2025-11-25**; hand-rolled `reqwest + corepc-types` (~200 LOC); free upgrade to native GBT long-poll | [[../wiki/concepts/drop-in-rust-port-architecture#bitcoind-rpc--hand-rolled-reqwest--corepc-types]] |
| Q7 | What does an operator do on switch day? | 5-phase runbook; F1-F8 failure catalog; MIGRATING.md skeleton; gateway today ships zero migration docs | [[../wiki/concepts/switch-day-runbook]] |

## The four de-risking findings

1. **No on-disk state to migrate.** Gateway regenerates keypair on every startup; TIDES attributes by Bitcoin payout address. Switch is a binary swap with zero statefile compat tooling.
2. **Cipher correction**: XSalsa20Poly1305 (libsodium default), **not** ChaCha20-Poly1305. `dryoc` matches.
3. **CLI surface is minimal**: 4 flags, 1 signal, 0 env vars. Replication is hours.
4. **`bitcoincore-rpc` archived 2025-11-25**: hand-rolled `reqwest + corepc-types` is the rust-bitcoin org's official guidance. Replaces ~235 C LOC with ~200 Rust LOC, gains native GBT long-poll for free.

## Project sizing

- **Total Rust LOC**: ~4,000-5,500 (replacing ~8,500 C LOC).
- **Critical-path crate count**: 11.
- **Largest single crate**: `datum-api` (~800-1,200 LOC; 40% of residual port budget).
- **Solo-dev timeline estimate**: 4-6 months (assumes some prior SRI / async Rust experience).
- **External dependencies**: `tokio`, `reqwest`, `dryoc`, `axum`, `tracing`, `serde`, `corepc-types`, SRI's `channels_sv2` + `handlers_sv2`.

## Action plan (10 steps, ordered by dependency)

### Phase 0 — bootstrap

1. **Create greenfield repo** at `~/repos/datum-rs/` (NOT a fork of `OCEAN-xyz/datum_gateway`). MIT license. `Cargo.toml` workspace with the 11 crates from [[../wiki/concepts/drop-in-rust-port-architecture#workspace-layout-11-crates|Q3]].
2. **Open a tracking issue** referencing `OCEAN-xyz/datum_gateway#146` (the canonical SV2-DATUM bridge proposal) — sets community context.

### Phase 1 — foundation crates

3. **`datum-config`** (300-400 LOC) — port `datum_conf.c` JSON schema. ~70 keys, 8 sections. Add `--validate-config` and `--migrate-config --dry-run` subcommands.
4. **`datum-rpc`** (100-150 LOC) — hand-rolled `reqwest + corepc-types` JSON-RPC client. Cookie auth + UserPass. 4 methods: `getblocktemplate`, `getbestblockhash`, `submitblock`, `preciousblock`.

### Phase 2 — template + coinbase pipeline

5. **`datum-blocktemplates`** (300-400 LOC) — GBT puller with native long-poll loop (75s timeout). `["segwit"]` rules + new `["taproot"]` rule (free upgrade vs C).
6. **`datum-coinbaser`** (200-300 LOC) — V2 coinbaser blob parser/builder. Single source-of-truth `Vec<TxOut>` consumed by both SV1 and SV2 paths.

### Phase 3 — upstream protocol

7. **`datum-protocol`** (800-1,200 LOC) — the gating crate. Build the mock pool harness in-tree first; integration-test against live OCEAN second.
   - Module layout: `frame.rs`, `obfuscation.rs`, `crypto.rs` (`DatumCrypto` trait + `dryoc` impl), `handshake.rs`, `opcodes.rs`, `messages/{coinbaser,share,job_validation,client_config,block_notify}.rs`, `client.rs`, `mock_pool.rs`.
   - Capture a real C-emitted PING frame; pin via test before coding pack/unpack.

### Phase 4 — downstream protocols

8. **`datum-stratum-sv2`** (500-800 LOC) — SRI `channels_sv2::server::ExtendedChannel<DefaultJobStore>` + custom `JobStore` that consumes the GBT template + OCEAN coinbase outputs. Plain SV2 pool front, no JDS/JDC ([[sv2-downstream-architecture#recommended-model-plain-sv2-pool-front-no-jds-no-jdc]]).
9. **`datum-stratum-sv1`** (600-900 LOC) — direct serve; bit-exact with C `datum_stratum.c`. Test golden vectors against C output for `mining.notify` and `mining.submit` ack.

### Phase 5 — observability & supporting

10. **`datum-api`** (800-1,200 LOC) — `axum` rewrite of the 14-endpoint dashboard. URL paths and JSON shapes match C; HTML can be cleaner. Add `/metrics` (Prometheus). HTTP Digest SHA-256 + MD5 fallback. CSRF token format must match.

(Plus: `datum-dupes` 150-200 LOC, `datum-submitblock` 80-120 LOC, `datum-bin` glue + main loop ~300 LOC, `datum-logger` formatter ~50-80 LOC.)

### Phase 6 — distribution

11. **CI/CD**: GitHub Actions matrix for `{amd64,aarch64}-unknown-linux-{gnu,musl}` static-musl release artifacts; `cargo-deb` for `.deb`s; `docker buildx` multi-arch push to `ghcr.io/<author>/datum-gateway`; reproducible builds with `cargo build --locked` + `SOURCE_DATE_EPOCH`.
12. **StartOS package**: fork `OCEAN-xyz/datum-gateway-startos`, swap submodule pin, replace `cmake . && make` with `cargo build --release --locked`, drop the runtime libs.
13. **Docs**: ship `MIGRATING.md`, `CHANGELOG.md`, `COMPAT.md`. The C gateway has none of these — additive credibility.

## What concrete code looks like in week one

```toml
# Cargo.toml workspace root
[workspace]
resolver = "2"
members  = [
  "crates/datum-config",
  "crates/datum-rpc",
  "crates/datum-blocktemplates",
  "crates/datum-coinbaser",
  "crates/datum-submitblock",
  "crates/datum-protocol",
  "crates/datum-stratum-sv1",
  "crates/datum-stratum-sv2",
  "crates/datum-dupes",
  "crates/datum-api",
  "crates/datum-bin",
]

[workspace.package]
version = "0.1.0"
edition = "2021"
license = "MIT"
rust-version = "1.83"

[workspace.dependencies]
tokio       = { version = "1", features = ["full"] }
reqwest     = { version = "0.12", default-features = false, features = ["json", "rustls-tls"] }
dryoc       = "0.8"
axum        = "0.7"
serde       = { version = "1", features = ["derive"] }
serde_json  = "1"
corepc-types = "0.14"
tracing     = "0.1"
tracing-subscriber = "0.3"
tracing-appender   = "0.2"
thiserror   = "2"
bytes       = "1"
hex         = "0.4"
```

```toml
# crates/datum-bin/Cargo.toml
[[bin]]
name = "datum_gateway"  # underscore — matches C binary name
path = "src/main.rs"

[package.metadata.deb]
name = "datum-gateway-rust"
provides = "datum-gateway"
replaces = "datum-gateway"
conflicts = "datum-gateway"
```

## Key risks (from the synthesis)

1. **DATUM Prime wire-protocol drift** mid-development. Mitigation: mock pool first; pin to a known OCEAN version; coordinate with OCEAN engineering.
2. **Coinbase divergence SV1 vs SV2** — single source-of-truth array + golden-vector tests against C gateway output. Catastrophic if missed (operator could pay self instead of OCEAN).
3. **OCEAN production server protocol version** unknown. Configurable version string; literal `"v0.4.1-beta"` default; fall-back if rejected.
4. **Log format drift** silently breaks operator alerts. Custom `tracing` formatter; side-by-side log-string table in `MIGRATING.md`.

## Suggested follow-up theses

- *"DATUM Prime accepts a Rust client speaking master-version `v0.4.1-beta` against the production endpoint."* (Test this empirically with a hello-world Rust client before committing to the full port.)
- *"`OCEAN-xyz/datum-gateway-startos` will accept a maintainer PR that swaps the submodule to `datum-rs`, conditional on feature parity at v1.0."* (Test by opening a draft PR after v1.0 ships.)
- *"OCEAN's miner base is >50% SV2-capable by Q4 2026."* (Refute the Q4 inference if true; would change the dual-protocol design priority.)

## See also

- [[../wiki/topics/drop-in-rust-datum-gateway]] — synthesis topic article
- [[../wiki/topics/datum-sv2-proxy-playbook]] — the **sidecar proxy** alternative (Phase 1, no daemon replacement)
- [[../wiki/topics/datum-gateway-overview]] — anchor article for the C gateway
- All concept articles linked from the decomposition table above
