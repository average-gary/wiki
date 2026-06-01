---
title: "Drop-In Q3: Rust Workspace Layout for datum-rs Drop-In Replacement"
source_url: https://github.com/OCEAN-xyz/datum_gateway/tree/master/src
source_type: derived-design
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: dropinq3
research_path: dropin-q3-non-stratum-concerns
quality_score: 8
tags: [datum, rust-port, workspace-layout, crate-decomposition, drop-in-replacement]
related_concepts: [phase2-drop-in-replacement, sri-integration]
---

# datum-rs workspace layout

A drop-in Rust replacement for `datum_gateway` decomposed into a Cargo
workspace. Each crate corresponds to a C module group with a clear
boundary and minimal cross-crate coupling. Optimized for: independent
testability, partial migration (the SV1 server can coexist with SV2),
and reuse outside DATUM where possible.

## Workspace layout

```
datum-rs/
├── Cargo.toml                  # [workspace] + shared dependency versions
├── rust-toolchain.toml         # pin stable channel
├── README.md
├── DESIGN.md                   # cross-crate architecture notes
│
├── crates/
│   ├── datum-rpc/              # bitcoind RPC client
│   │   ├── src/lib.rs
│   │   └── tests/              # against regtest bitcoind
│   │
│   ├── datum-blocktemplates/   # GBT pull, parse, ring-buffer cache
│   │   ├── src/lib.rs
│   │   ├── src/parser.rs       # GBT JSON → typed BlockTemplate
│   │   ├── src/cache.rs        # ring buffer of recent templates
│   │   ├── src/notifier.rs     # SIGUSR1 + /NOTIFY trigger surface
│   │   └── tests/
│   │
│   ├── datum-coinbaser/        # V2 blob parser + coinbase assembly
│   │   ├── src/lib.rs
│   │   ├── src/v2_blob.rs      # [datum_id][outval][slen][script]× parser
│   │   └── src/builder.rs      # assemble coinbase tx given outputs
│   │
│   ├── datum-submitblock/      # block-found escape hatch + multi-URL fanout
│   │   ├── src/lib.rs
│   │   └── tests/              # against regtest
│   │
│   ├── datum-protocol/         # upstream DATUM protocol leg
│   │   ├── src/lib.rs
│   │   ├── src/noise.rs        # Noise NX handshake
│   │   ├── src/messages.rs     # DATUM message types
│   │   ├── src/ring.rs         # 8-job ring buffer
│   │   └── src/client.rs       # connect, reconnect, ship
│   │
│   ├── datum-stratum-sv1/      # SV1 server (legacy / parity testing)
│   │   ├── src/lib.rs          # OPTIONAL — for mixed-mode and parity
│   │   ...
│   │
│   ├── datum-stratum-sv2/      # SV2 mining server
│   │   ├── src/lib.rs
│   │   ├── src/channel.rs      # standard + extended channel state
│   │   ├── src/job.rs          # job ring + NewExtendedMiningJob assembly
│   │   ├── src/share.rs        # share validation pipeline
│   │   └── src/server.rs       # connection accept + Noise handshake
│   │
│   ├── datum-dupes/            # composite-key share dedup filter
│   │   └── src/lib.rs          # ~150 LOC + tests
│   │
│   ├── datum-api/              # axum dashboard + /metrics
│   │   ├── src/lib.rs
│   │   ├── src/auth/digest.rs  # HTTP Digest extractor
│   │   ├── src/auth/csrf.rs    # CSRF middleware
│   │   ├── src/handlers/       # one file per endpoint
│   │   ├── src/templates/      # askama (or maud) templates
│   │   ├── www/                # HTML/CSS/SVG embedded via include_bytes!
│   │   └── src/metrics.rs      # Prometheus exposition (NEW)
│   │
│   ├── datum-config/           # serde + validators
│   │   ├── src/lib.rs
│   │   ├── src/schema.rs       # struct definitions matching JSON config
│   │   ├── src/validate.rs     # power-of-2, range clamps, derived values
│   │   └── tests/              # every clamp + every derivation
│   │
│   └── datum-bin/              # main entry point
│       ├── src/main.rs         # wires everything; signals; lifecycle
│       └── src/lifecycle.rs    # shutdown ordering, graceful drain
│
├── tests/
│   └── integration/            # workspace-level integration tests
│
└── deploy/
    ├── Dockerfile
    ├── systemd/
    └── examples/
```

## Crate dependency graph

```
                    ┌─────────────┐
                    │  datum-bin  │
                    └─────────────┘
                           │
        ┌──────────────────┼──────────────────────────┐
        │                  │                          │
        ▼                  ▼                          ▼
 datum-stratum-sv2   datum-protocol            datum-api
        │                  │                          │
        ├──────► datum-blocktemplates ◄──────────┐    │
        │                  │                     │    │
        ▼                  ▼                     │    │
   datum-dupes       datum-coinbaser             │    │
        │                  │                     │    │
        │                  ▼                     │    │
        │             datum-rpc ◄────────────────┘    │
        │                  ▲                          │
        │                  │                          │
        │            datum-submitblock                │
        │                                             │
        └────────────────────────────────────────────►│
                       (channel/connection state)

 All depend on: datum-config (passive, just structs)
```

## Per-crate dependency commentary

### `datum-rpc`

Wraps `bitcoincore-rpc` (or `jsonrpsee` if we need batch) with a thin
layer for cookie-file watching and exponential backoff. Public API:

```rust
pub struct BitcoindClient { /* ... */ }
impl BitcoindClient {
    pub async fn get_block_template(&self, rules: &[&str]) -> Result<BlockTemplate>;
    pub async fn get_best_block_hash(&self) -> Result<BlockHash>;
    pub async fn submit_block(&self, hex: &str) -> Result<()>;
    pub async fn precious_block(&self, hash: &BlockHash) -> Result<()>;
}
```

Dependencies: `bitcoincore-rpc`, `tokio`, `tracing`.

### `datum-blocktemplates`

Owns the template ring buffer and the SIGUSR1 / `/NOTIFY` notifier
surface. Exposes a `TemplateProvider` trait that the SV2 server
subscribes to:

```rust
pub trait TemplateProvider {
    fn subscribe(&self) -> tokio::sync::watch::Receiver<Arc<BlockTemplate>>;
    fn notify_new(&self);  // called by signal handler and /NOTIFY
}
```

Dependencies: `datum-rpc`, `bitcoin`, `tokio`, `serde_json`.

### `datum-coinbaser`

V2 blob parser + per-template output materialization. SV2-only port
drops the 6 fingerprint variants and keeps only "huge" (or generates
exactly what `NewExtendedMiningJob` needs).

Dependencies: `bitcoin`, `nom` (or hand-rolled), `tokio` (for the
periodic fetch task).

### `datum-submitblock`

Spawned independently from share validation. Receives block hex via a
channel. Fans out:
1. Local `submitblock` via `datum-rpc`
2. Each `extra_block_submissions.urls[]` via dedicated `BitcoindClient`s
3. `preciousblock` after step 1

Dependencies: `datum-rpc`, `datum-config`, `tokio`.

### `datum-protocol`

The upstream DATUM-protocol leg. Owns the Noise NX session and the
8-job ring buffer. Exposed as:

```rust
pub struct DatumUpstream { /* ... */ }
impl DatumUpstream {
    pub fn submit_share(&self, share: SharePayload) -> Result<(), TrySendError>;
    pub fn need_coinbaser(&self) -> watch::Receiver<bool>;
    // ...
}
```

Critically, `submit_share` is a `try_send` (or `send_timeout`) — it
must not block the caller, since the caller is the share-validation
hot path which has just (in parallel) fired off submitblock if this was
a real block.

Dependencies: `noiseexplorer-nx` or `snow`, `tokio`, `bytes`.

### `datum-stratum-sv2`

The SV2 mining server. Builds on SRI's roles-logic. Bridges:
- Subscribes to `datum-blocktemplates` for template updates
- Subscribes to `datum-coinbaser` for coinbase outputs
- Forwards valid shares to `datum-protocol` via `mpsc::Sender`
- Forwards block-found events to `datum-submitblock` via `mpsc::Sender`
- Reports per-channel state to `datum-api`

Dependencies: `roles-logic-sv2` (SRI), `binary-codec-sv2`,
`network-helpers-sv2`, `noise-sv2` (different Noise key from upstream),
`datum-blocktemplates`, `datum-coinbaser`, `datum-protocol`,
`datum-submitblock`, `datum-dupes`, `tokio`.

### `datum-stratum-sv1` (optional)

The C `datum_stratum.c` ported. Only build during the migration period
for byte-compatibility parity testing. Eventually deprecated.

Dependencies: same as SV2 except SRI crates → custom SV1 codec.

### `datum-dupes`

Composite-key share dedup. Pure data structure crate, no async.

```rust
pub struct DupeFilter { /* ... */ }
impl DupeFilter {
    pub fn check(&mut self, key: DupeKey) -> bool;  // true = dupe
    pub fn cleanup(&mut self, older_than: Duration);
}
```

Dependencies: `lru`, `smallvec`, `hashbrown`.

### `datum-api`

The dashboard. Heaviest crate by LOC. Owns the embedded assets and the
Digest auth.

Public API: a single `pub async fn run(state: ApiState, listen: SocketAddr) -> Result<()>`
function. `ApiState` holds Arc-clones of read-only views into the
other crates' state.

Dependencies: `axum`, `tower-http`, `askama` (or `maud`),
`sha2`, `md-5`, `subtle`, `prometheus`, `tracing`.

### `datum-config`

Just structs and validators. No async. Re-exported by `datum-bin` and
imported by every other crate that needs config values.

```rust
pub struct Config { /* ... */ }
impl Config {
    pub fn from_path(path: &Path) -> Result<Self>;
    pub fn validate(&self) -> Result<()>;
    pub fn csrf_token(&self) -> &str;
}
```

Dependencies: `serde`, `serde_json`, `sha2`.

### `datum-bin`

Main entry point. Parses CLI args, loads config, spawns all the long-
running tasks, wires up channels between them, handles signals, manages
graceful shutdown.

Dependencies: every other workspace crate, plus `clap`, `tokio`,
`tracing-subscriber`.

## Workspace `Cargo.toml`

```toml
[workspace]
resolver = "2"
members = ["crates/*"]

[workspace.package]
edition = "2021"
license = "MIT OR Apache-2.0"
rust-version = "1.75"

[workspace.dependencies]
tokio = { version = "1", features = ["full"] }
axum = "0.7"
tower-http = "0.5"
tracing = "0.1"
tracing-subscriber = "0.3"
tracing-appender = "0.2"
bitcoin = "0.32"
bitcoincore-rpc = "0.18"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
thiserror = "1"
anyhow = "1"
sha2 = "0.10"
md-5 = "0.10"
subtle = "2"
hashbrown = "0.14"
lru = "0.12"
smallvec = "1"
prometheus = "0.13"
askama = "0.12"
clap = { version = "4", features = ["derive"] }
# SRI:
roles-logic-sv2 = { git = "https://github.com/stratum-mining/stratum.git" }
binary-codec-sv2 = { git = "https://github.com/stratum-mining/stratum.git" }
network-helpers-sv2 = { git = "https://github.com/stratum-mining/stratum.git" }
noise-sv2 = { git = "https://github.com/stratum-mining/stratum.git" }
```

## Migration sequencing

A drop-in replacement isn't built crate-by-crate top-down. Suggested
sequence:

1. **`datum-config`** first — defines the schema, blocks downstream work
2. **`datum-rpc`** — needed by everything that talks to bitcoind
3. **`datum-blocktemplates`** + **`datum-coinbaser`** in parallel
4. **`datum-protocol`** — the upstream leg; isolatable, testable against
   OCEAN's beta endpoint
5. **`datum-dupes`** — pure logic, easy
6. **`datum-stratum-sv1`** (optional) — for parity testing
7. **`datum-submitblock`** — depends on `datum-rpc`, but trivial
8. **`datum-stratum-sv2`** — the new value; depends on SRI maturity
9. **`datum-api`** — last because depends on read views into all the others
10. **`datum-bin`** — wires everything

## Justification

A concrete crate decomposition that preserves the C module boundaries
where useful, collapses where Rust crates do the work for us, and
isolates the SV2 net-new work in `datum-stratum-sv2` and `datum-api`
(Prometheus). Forms the input to a Phase 2 implementation roadmap.
