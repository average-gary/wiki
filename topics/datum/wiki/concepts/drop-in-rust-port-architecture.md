---
title: "Rust port architecture — workspace, modules, and LOC budget"
category: concept
sources:
  - raw/articles/2026-06-01-dropinq3-non-stratum-modules.md
  - raw/articles/2026-06-01-dropinq3-block-found-flow.md
  - raw/articles/2026-06-01-dropinq3-api-endpoint-inventory.md
  - raw/articles/2026-06-01-dropinq3-rust-workspace-layout.md
  - raw/articles/2026-06-01-dropinq6-corepc-recommended-successor.md
  - raw/articles/2026-06-01-dropinq6-async-alternatives-survey.md
  - raw/articles/2026-06-01-dropinq6-c-source-baseline.md
  - raw/articles/2026-06-01-dropinq6-longpoll-async-pattern.md
created: 2026-06-01
updated: 2026-06-01
tags: [rust, workspace, architecture, modules, loc-budget]
confidence: high
---

# Rust port architecture

The Cargo workspace, module-to-crate mapping, and LOC budget for replacing every C module of `datum_gateway` with Rust. From [[../../raw/articles/2026-06-01-dropinq3-non-stratum-modules|Q3 module port plan]], [[../../raw/articles/2026-06-01-dropinq3-rust-workspace-layout|Q3 workspace layout]], [[../../raw/articles/2026-06-01-dropinq6-corepc-recommended-successor|Q6 RPC crate]], [[../../raw/articles/2026-06-01-dropinq6-longpoll-async-pattern|Q6 long-poll pattern]].

## Workspace layout (11 crates)

```
datum-rs/
├── Cargo.toml          # workspace root
├── crates/
│   ├── datum-rpc/              # bitcoind JSON-RPC client (replaces datum_jsonrpc.c)
│   ├── datum-blocktemplates/   # GBT puller + long-poll loop (replaces datum_blocktemplates.c)
│   ├── datum-coinbaser/        # V2 coinbaser blob parser/builder (replaces datum_coinbaser.c)
│   ├── datum-submitblock/      # block-found escape hatch (replaces datum_submitblock.c)
│   ├── datum-protocol/         # encrypted DATUM upstream (replaces datum_protocol.c)
│   ├── datum-stratum-sv1/      # SV1 server side (preserves SV1 ASIC compat)
│   ├── datum-stratum-sv2/      # SV2 server side (the new capability)
│   ├── datum-dupes/            # bounded dedup cache (replaces datum_stratum_dupes.c)
│   ├── datum-api/              # axum HTTP dashboard (replaces datum_api.c)
│   ├── datum-config/           # serde JSON config (replaces datum_conf.c)
│   └── datum-bin/              # main binary; produces target/release/datum_gateway
└── docs/
    ├── MIGRATING.md
    └── COMPAT.md
```

`Cargo.toml` `[[bin]] name = "datum_gateway"` so `cargo install --path crates/datum-bin --root /usr/local` produces `/usr/local/bin/datum_gateway` (matches C binary path; coordinates with [[drop-in-distribution]]).

## Per-module port plan

| C module | C LOC | Rust LOC | Crates leveraged | Difficulty | Hazard |
|---|---|---|---|---|---|
| `datum_jsonrpc.c` | ~230 | 100-150 | `reqwest` + `corepc-types` (hand-rolled — `bitcoincore-rpc` archived 2025-11-25) | Trivial | Cookie-reload on 401, 5s timeout |
| `datum_blocktemplates.c` | ~500 | 300-400 | `corepc-types`, `bitcoin` | Moderate | C hardcodes `["segwit"]` GBT rules; will break when bitcoind expects `taproot`. Free upgrade. |
| `datum_coinbaser.c` | ~550 | 200-300 | `bitcoin`, `nom` | Moderate | V2 blob `[datum_id 1B][outval LE 8B][slen 1B][script]`×≤512; **6 fingerprint variants collapse to 1 under SV2** |
| `datum_submitblock.c` | ~140 | 80-120 | `corepc-types`, `tokio` | Trivial | 8.5 MB pre-alloc actually lives in `datum_stratum.c::assembleBlockAndSubmit`, not this module |
| `datum_protocol.c` | ~2000 | 800-1200 | `dryoc`, `tokio`, `bytes` | Moderate-Hard | See [[datum-protocol-rust-implementation]] |
| `datum_logger.c` | ~450 | 50-80 | `tracing`, `tracing-appender` | Trivial | Custom formatter for 44-char function name + 5-char level prefix |
| `datum_api.c` | ~2100 | **800-1200** | `axum`, `askama` | **Hard** | 14 endpoints; HTTP Digest SHA-256+MD5; CSRF = `SHA256("DATUM Anti-CSRF Token" + port + admin_password)`; embedded HTML/CSS/SVG. **40% of the residual port budget.** |
| `datum_conf.c` | ~800 | 300-400 | `serde`, `serde_json` | Moderate | **47 keys** across 8 sections (corrected 2026-06-02 from "~70" by reading source @ a3da9e69); `vardiff_min` rounded down to power of 2; `work_update_seconds` clamped [5,120]; `share_stale_seconds` **fatal if outside [60,150]** (not clamp); `coinbase_tag_*` combined ≤88B; **no SIGHUP-reload** today |
| `datum_queue.c` | ~200 | 30-50 | `tokio::sync::mpsc` | Trivial | Dual-buffer rwlock + 10M-iter race retry → `mpsc::channel(N)` |
| `datum_stratum_dupes.c` | ~250 | 150-200 | `lru`, `hashbrown`, `smallvec` | Moderate | **SV1 sizing formula breaks under SV2** (channels-per-connection asymmetry); switch to bounded `lru::LruCache` |
| `datum_stratum.c` (SV1 side) | ~1200 | 600-900 | `tokio`, `serde_json` | Moderate | Full rewrite; SRI's `stratum_translation` crate v0.3.0 is the SV1↔SV2 adapter |
| **NEW: SV2 side** | n/a | 500-800 | `channels_sv2`, `handlers_sv2` (SRI) | Moderate | See [[sv2-downstream-architecture]] |
| Block-discovery glue | ~50 | 30-50 | `tokio::signal`, `axum` | Trivial | SIGUSR1 + `/NOTIFY` HTTP do same thing; 2.5s race-dedup |
| **Total** | **~8500** | **~4000-5500** | | | |

`datum-api` (40% of the residual port) is the largest single sub-project after the protocol implementation.

## Bitcoind RPC — hand-rolled `reqwest` + `corepc-types`

`bitcoincore-rpc` was archived 2025-11-25 ([[../../raw/articles/2026-06-01-dropinq6-bitcoincore-rpc-archived|Q6]]). The rust-bitcoin org's official guidance is to use `corepc-types` for response/request types and write your own client. Crate verdict:

| Crate | Verdict |
|---|---|
| `bitcoincore-rpc` | **archived 2025-11-25** — non-starter |
| `corepc-client` | maintainers say "do not use in production" |
| `bitcoind-async-client` | wallet/PSBT focused; zero mining methods |
| `jsonrpsee` | overweight for ~5 RPC methods |
| **Hand-rolled `reqwest` + `corepc-types`** | **PICK** — ~200 LOC, less than C's ~235 LOC; full async; supports Knots/Core 25-29 transparently |

Only 4 RPC methods are actually called: `getblocktemplate`, `getbestblockhash`, `submitblock`, `preciousblock`.

## GBT long-polling — a free upgrade

The C gateway uses a signal-handler + 1Hz `getbestblockhash` polling because libcurl long-polling is awkward. Rust port should **use bitcoind's native long-poll**:

1. First call: `getblocktemplate {"rules":["segwit"]}` with short timeout (~10s).
2. Extract `longpollid`; immediately re-issue with `{"rules":["segwit"], "longpollid":"<id>"}` and **75s timeout** (longer than bitcoind's ~60s GBT deadline).
3. bitcoind returns when tip changes / mempool drifts / timeout — refresh `longpollid`, broadcast new template via `tokio::sync::watch`.
4. On error, drop `longpollid` (bitcoind restart invalidates it) and back off 2s.

**Effects**: lower bitcoind RPC load, lower latency, no signal-handler brittleness, zero operator-side blocknotify configuration. The SIGUSR1 handler stays for blocknotify-script compatibility but becomes a redundancy, not the primary path.

## Block-found data flow

```
SV2 miner submits share → datum-stratum-sv2 validates → if hash <= block_target:
                                                              │
                                          ┌───────────────────┴───────────────────┐
                                          │ (parallel, independent)                │
                                          ▼                                        ▼
                                  datum-submitblock                          datum-queue (mpsc)
                                          │                                        │
                                          ▼                                        ▼
                                  bitcoind submitblock RPC                  datum-protocol task
                                  + extra_block_submissions.urls[]                  │
                                  + preciousblock                                   ▼
                                                                              Noise-encrypted
                                                                              upstream to OCEAN
```

**Non-negotiable invariant**: path 1 must NOT be gated on path 2 (and vice versa). The C gateway enforces this via independent threads; the Rust port via independent `tokio::spawn` tasks. 4 hazards for the Rust port:

1. Shared RPC client locks
2. Upstream backpressure starving the local submit
3. Panic cascade between the two tasks
4. RPC timeout shorter than block-validation latency

## Dupe-table — SV1 sizing breaks under SV2

C `datum_stratum_dupes.c` formula: `max_clients × target_shares × stale_min × 16`. SV1 connection ↔ one share-stream. SV2 connection ↔ many channels, each a separate share-stream. Direct port over-allocates by `max_channels_per_connection`x. Switch to `lru::LruCache` with bounded capacity, key on `(channel_id, sequence_number, ntime, version, extranonce, nonce)`. ~150-200 LOC.

## Migration sequence (build order)

`config` → `rpc` → `blocktemplates + coinbaser` (parallel) → `protocol` (mock pool first, live pool second) → `dupes` → `submitblock` → `stratum-sv2` → `stratum-sv1` (or skip if SV2-only at first) → `api` → `bin`. Each crate ships with its own unit tests; `bin` ships with integration tests against a regtest bitcoind.

## See also

- [[datum-protocol-rust-implementation]] — the protocol crate's internal design
- [[drop-in-surface-inventory]] — what compatibility the binary must hit
- [[gateway-internals-c-architecture]] — the C source being replaced
- [[sv2-downstream-architecture]] — the SV2 server-side design (Phase 1 pattern, refactored for in-process)
