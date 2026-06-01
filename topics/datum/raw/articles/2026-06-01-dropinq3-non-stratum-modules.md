---
title: "Drop-In Q3: Non-Stratum Modules — Per-Module Port Plan for Rust DATUM Gateway"
source_url: https://github.com/OCEAN-xyz/datum_gateway/tree/master/src
source_type: source-survey
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: dropinq3
research_path: dropin-q3-non-stratum-concerns
quality_score: 9
tags: [datum, datum-gateway, rust-port, drop-in-replacement, non-stratum, module-survey, sv2]
related_concepts: [phase2-drop-in-replacement, sv2-downstream, gateway-internals]
---

# Drop-in Q3 — Non-stratum modules a Rust replacement must own

In the Phase 1 sidecar plan, the existing C `datum_gateway` binary continues
to handle bitcoind RPC, GBT, coinbaser parsing, submitblock, the dashboard,
the upstream DATUM-protocol leg, logging, and config — the Rust SV2-downstream
proxy plugs in only at the queue seam. **Phase 2 (drop-in replacement) owns
all of it.** This article enumerates each non-stratum module, dimensions the
port work, and identifies where Rust crates collapse the C complexity.

## Per-module port plan

Approximate C LOC are derived from raw fetches of each file on `master`
(2026-06-01). Rust LOC estimates assume idiomatic ports leveraging the
crates listed; they are not committed targets, just sizing.

| Module | C LOC | Rust LOC est. | Crates leveraged | Difficulty | Compatibility hazards |
|---|---|---|---|---|---|
| `datum_blocktemplates.c` | ~500 | 300–400 | `bitcoincore-rpc`, `bitcoin`, `serde_json` | Moderate | Hardcoded `["segwit"]` rules array; sizelimit/weightlimit parsed but **never enforced** (must replicate to match behavior, or fix); 16,383-txn cap; 2.5s race-condition guardrail between SIGUSR1 and prior change |
| `datum_jsonrpc.c` | ~230 | 100–150 | `bitcoincore-rpc` (or `jsonrpsee` + custom auth) | Trivial-Moderate | Cookie reload on 401 (single retry, no backoff); 5s hardcoded timeout; **no batch RPC**; libcurl callbacks → `reqwest`/`hyper` |
| `datum_submitblock.c` | ~140 | 80–120 | `bitcoincore-rpc`, `tokio` | Trivial | The 8.5 MB pre-alloc lives in `datum_stratum.c` (`malloc(8500000)`), **not** this module — Rust port can drop the per-thread pre-alloc and use `BytesMut` on demand; multi-URL `extra_block_submissions` broadcast must remain |
| `datum_coinbaser.c` | ~550 | 200–300 | `bitcoin`, `nom` (or hand-rolled parser) | Moderate | V2 blob: `[datum_id 1B][outval LE 8B][slen 1B][script slen]`×N (≤512); 6 fingerprint variants (nicehash/antminer/whatsminer/huge/antminer2) **collapse under SV2** — keep only "huge" or use SRI's TDP coinbase model |
| `datum_logger.c` | ~450 | 50–80 | `tracing`, `tracing-subscriber`, `tracing-appender` | Trivial | 6 levels (ALL/DEBUG/INFO/WARN/ERROR/FATAL) → tracing levels; daily rotation → `tracing-appender::rolling::daily`; **operators have grep patterns over current format** — preserve column widths or version |
| `datum_api.c` | ~2,100 | 800–1,200 | `axum`, `askama` (or `maud`), `tower-http` | **Hard** | 14 endpoints; embedded HTML/CSS/SVG/favicon (`include_bytes!`); HTTP Digest auth (SHA-256 + MD5 fallback); CSRF token = SHA256("DATUM Anti-CSRF Token" + port + admin_password); umbrel-api JSON contract; `/NOTIFY` GET triggers GBT refresh (HTTP equivalent of SIGUSR1) |
| `datum_conf.c` | ~800 | 300–400 | `serde`, `serde_json`, `figment` or `config` | Moderate | ~70 keys; **vardiff_min rounded down to power of 2**; `work_update_seconds` clamped [5,120]; `share_stale_seconds` [60,150]; `protocol_global_timeout > work_update_seconds + 5`; `coinbase_tag_primary + secondary ≤ 88 bytes`; CSRF token computed at load time; **no SIGHUP hot-reload** |
| `datum_queue.c` | ~200 | 30–50 | `tokio::sync::mpsc` | Trivial | Dual-buffer rwlock + 10M-iter race retry → `mpsc::channel(N)`; `void*` + `item_size` → typed enum; bounded by `max_entries` |
| `datum_stratum_dupes.c` | ~250 | 150–200 | `hashbrown`, `lru`, `smallvec` | Moderate | Composite key (nonce, job_index, ntime, version_bits, extranonce_a/b); 65536-bucket sorted linked-list → `HashMap<u32, SmallVec<DupeEntry>>` or `lru::LruCache`; sizing formula `max_clients × target_shares × stale_minutes × 16` must be re-derived for SV2 (channels-per-connection asymmetry blows it up) |
| Block-discovery glue | ~50 (in main + api) | 30–50 | `tokio::signal`, `axum` | Trivial | SIGUSR1 → `datum_blocktemplates_notifynew_sighandler()`; HTTP `/NOTIFY` does the same thing; race handling = 2.5s dedup window in `datum_blocktemplates.c` (carry forward) |

**Totals:** roughly **5,300 C LOC** of non-stratum concerns (excluding the
SV1 server itself, which is replaced by SRI mining-server) port to roughly
**2,000–3,000 Rust LOC** thanks to crate leverage. The biggest single
chunk is `datum_api.c` (~40% of the residual port).

## Module-by-module findings

### 1. `datum_blocktemplates.c` (~500 LOC)

**RPC calls:** `getblocktemplate`, `getbestblockhash`. No `getblockchaininfo`,
no `getmininginfo`, no `submitblock` (lives in `datum_submitblock.c`).

**Rules array (hardcoded):**
```c
"params":[{"rules":["segwit"]}]
```
Only `segwit`. No `taproot`, no `signet` rules. Rust replacement should
make this configurable (or at minimum add `taproot` for forward
compatibility — bitcoind requires explicit rule advertisement to receive
templates including transactions that depend on those soft forks).

**Polling vs blocknotify:** Hybrid.
- Primary: SIGUSR1 sets a flag (`new_notify` + `new_notify_threadsafe`)
- Fallback: `datum_gateway_fallback_notifier` thread polling
  `getbestblockhash` every 1 second (gated by `bitcoind.notify_fallback`)
- Configured GBT refresh: `bitcoind.work_update_seconds` (default 40,
  clamped 5–120)

**Cache:** Ring buffer of `MAX_TEMPLATES_IN_MEMORY` template slots
(circular, no per-slot timestamp eviction). 2.5-second race guardrail:
notifications arriving within 2.5s of prior change treated as duplicate.

**Sizelimit/weightlimit:** Parsed into `tdata->sizelimit` and
`tdata->weightlimit` from GBT response. **Tallied but not enforced.**
Hardcoded 16,383-transaction cap; truncation is silent. Rust port should
either fix this or replicate to avoid behavior drift.

**Reconnect:** Logs error, sleeps 1s, retries. No exponential backoff,
no circuit breaker.

### 2. `datum_jsonrpc.c` (~230 LOC)

Generic libcurl-backed JSON-RPC client. **No batch RPC.** Two auth
paths:
- Cookie file (preferred): read `.cookie`, format as `__cookie__:<hex>`
- User/pass: HTTP Basic via libcurl's `CURLOPT_USERPWD`

`bitcoind_json_rpc_call()` handles 401 by reloading the cookie file
**once** before retrying. No exponential backoff.

**RPC methods used across the codebase** (greppable):
- `getblocktemplate` (datum_blocktemplates.c)
- `getbestblockhash` (datum_blocktemplates.c, fallback notifier)
- `submitblock` (datum_submitblock.c)
- `preciousblock` (datum_submitblock.c — for orphan-rate insurance via
  `extra_block_submissions`)

That's **four methods, total.** A Rust port using `bitcoincore-rpc` gets
all four trivially; the only custom code needed is cookie auth, which
that crate supports natively (`Auth::CookieFile`).

### 3. `datum_submitblock.c` (~140 LOC)

The 8.5 MB pre-allocated buffer (`malloc(8500000)`) is in
**`datum_stratum.c`'s `assembleBlockAndSubmit`**, not this module —
the wiki had this misattributed. With `max_threads=8` and one buffer per
share-validation slot, that's the 68 MB number. Rust port: `BytesMut`
from a pool, allocated only when a share actually meets the network
target. Most threads never touch it.

**Trigger condition** (in `datum_stratum.c`):
```c
if (compare_hashes(share_hash, job->block_target) <= 0) {
    // BLOCK
    was_block = true;
```

When `was_block`, the assembled block hex (coinbase + all template
transactions) is passed to `datum_submitblock_trigger(submitblock_req, block_hash_hex)`.
The trigger thread:
1. Calls `submitblock` RPC on local bitcoind (canonical broadcast)
2. Calls `submitblock` RPC on every URL in
   `extra_block_submissions.urls[]` (orphan-rate insurance — broadcast
   to multiple bitcoind nodes the operator runs)
3. Calls `preciousblock` on the local node

This runs **in parallel** with the share being shipped via
`datum_protocol.c` to OCEAN. **Non-negotiable** — the operator's block
discovery does not depend on OCEAN connectivity.

`save_submitblocks_dir` is **not** referenced in this module; that
behavior is in `datum_stratum.c` (write block hex + metadata to disk
before submitting, as a forensic record).

**Public API:** `datum_submitblock_init()`, `datum_submitblock_trigger()`,
`datum_submitblock_waitfree()`. Three functions.

### 4. `datum_coinbaser.c` (~550 LOC)

V2 blob format confirmed:
```
[datum_id 1B] [outval 8B LE] [slen 1B] [script slen B] ... × ≤512
```
Script length validated 2–64 bytes. Sigops counted: `0x76` prefix
(P2PKH) costs 4 sigops.

**6 fingerprint variants** are the bulk of the file's LOC:
| Variant | Coinbase size cap |
|---|---|
| empty | — |
| nicehash | 500B |
| antminer | 755B |
| whatsminer | 6500B |
| antminer2 | 2250B |
| huge | 16 KB |

The reason: SV1 ASIC firmwares vary in how big a coinbase they accept
(some old ASICs panic on >2 KB). The gateway fingerprints the miner
from its `mining.subscribe` user-agent string and serves the
appropriately-trimmed coinbase variant.

**SV2 collapses this.** SRI's `NewExtendedMiningJob` carries the
coinbase prefix/suffix unambiguously, and modern SV2 firmware doesn't
have the size pathology. A Rust SV2-downstream port keeps **only
"huge"** (or generates one variant at the largest tier). Saves
~300 LOC and removes the `fingerprint_miners` config knob.

**Polling:** 12ms loop. Watches `global_latest_stratum_job_index`.
When `s->need_coinbaser` is set, calls `datum_protocol_coinbaser_fetch()`
to pull a fresh blob from the upstream pool, then regenerates all 6
variants.

**Consumer of the parsed outputs:** When the SV1 server builds a
`mining.notify`, it picks one of the 6 pre-generated variants based on
the connected miner's fingerprint. For an SV2 port, the consumer is
`NewExtendedMiningJob` construction: the parsed outputs become
`coinbase_tx_outputs` directly.

### 5. `datum_logger.c` (~450 LOC)

Six levels (ALL=0 / DEBUG=1 / INFO=2 / WARN=3 / ERROR=4 / FATAL=5),
each with a fixed-width display label (`"  ALL"`, `" INFO"`,
`"FATAL"`). Format:
```
YYYY-MM-DD HH:MM:SS.mmm [44-char function name] LEVEL: message
```

Daily rotation: rename `logfile` → `logfile.YYYY-MM-DD` at midnight.
SIGHUP triggers re-open (handled here, **not** in main).

Internal: double-buffered, with `pthread_rwlock_t` and a 10M-iteration
spin retry on buffer-version race. The Rust replacement collapses all
of this to `tracing` with a `tracing-appender::rolling::daily` non-
blocking writer — ~50 LOC including the format-layer customization to
match the existing column widths.

**Hazard:** operators may have `grep` / `awk` pipelines keyed on the
44-char-function-name column or the level labels with leading spaces.
Either preserve byte-for-byte or version the format and document the
break.

### 6. `datum_api.c` (~2,100 LOC) — **the scope risk**

14 endpoints (full table in module port plan above). Notable details:

- **Embedded assets:** `www_home_html`, `www_clients_top_html`,
  `www_threads_top_html`, `www_coinbaser_top_html`, `www_config_html`,
  `www_config_errors_html`, `www_foot_html`, `www_assets_style_css`,
  `www_assets_icons_datum_logo_svg`, `www_assets_icons_favicon_ico`,
  `www_assets_post_js`. Compiled into the binary. Rust port:
  `include_bytes!` + `tower-http::ServeDir` (or hand-route).

- **HTTP Digest auth:** SHA-256 (with optional MD5 fallback for Safari,
  gated by `api.allow_insecure_auth`). The CSRF token is computed at
  config-load time as `SHA256("DATUM Anti-CSRF Token" + port + admin_password)`.
  Rust port: `axum-auth` plus a custom Digest extractor (no off-the-
  shelf crate matches the SHA-256 + MD5-fallback dual-mode), or
  reimplement in ~150 LOC.

- **`/NOTIFY` endpoint:** GET request triggers GBT refresh (HTTP-side
  equivalent of SIGUSR1). Returns "OK" plaintext. Used by operators
  who can't easily wire `bitcoin.conf`'s `blocknotify=` to send a
  signal — they use a curl invocation instead. **Must preserve.**

- **`/cmd` endpoint:** POST JSON. Admin actions (kick client, empty
  thread). Auth: password OR HTTP Digest, plus CSRF. Inline JS posts
  to it without page reload.

- **`/umbrel-api`:** JSON contract for the Umbrel Bitcoin Mining
  widget. `{"connections": N, "hashrate": "<value>", "refresh": "30s"}`.
  External integration; do not break.

- **`/config`:** GET serves an HTML form rendering current config.
  POST updates the config file. Gated by `api.modify_conf` (default
  `false`). **Restart required** for some changes (pool/bitcoind),
  acknowledged in the response page. Rust port via `axum` + `askama`
  is straightforward; the config-edit logic is the work.

- **No Prometheus today.** This is the single biggest improvement
  opportunity for a Rust rewrite — `axum-prometheus` middleware adds
  `/metrics` for free, then per-channel and per-connection counters
  plug into the existing dashboard data sources.

This module is **~40% of the non-stratum port budget by LOC.** If the
Rust port targets parity, plan accordingly. If parity is partial
(e.g., skip `/cmd`, skip `/config` POST), call it out explicitly in
the migration guide.

### 7. `datum_conf.c` (~800 LOC)

Jansson-based JSON parser. ~70 keys across 8 sections (full table in
`raw/articles/2026-06-01-path2-datum-config-surface.md`).

**Computed/derived values that must be replicated:**
| Field | Derivation |
|---|---|
| `bitcoind_rpcuserpass` | `rpcuser ":" rpcpassword` |
| `extra_block_submissions_count` | `len(extra_block_submissions.urls)` |
| `api_admin_password_len` | `strlen(admin_password)` |
| `api_csrf_token` | `SHA256("DATUM Anti-CSRF Token" + port + admin_password)` |
| `datum_protocol_global_timeout_ms` | `protocol_global_timeout × 1000` |
| `override_mining_coinbase_tag_primary` | copy of `mining_coinbase_tag_primary` |

**Range clamps:**
- `work_update_seconds` clamped to [5, 120]
- `vardiff_min` rounded **down to nearest power of 2**
- `share_stale_seconds` clamped [60, 150]
- `vardiff_target_shares_min` ≥ 1
- `vardiff_quickdiff_count` ≥ 4
- `vardiff_quickdiff_delta` ≥ 3
- `coinbase_tag_primary + secondary` combined length ≤ 88 bytes (Bitcoin
  consensus: total scriptSig ≤ 100 bytes, minus BIP34 height + extranonce)
- `max_clients` ≤ `max_clients_per_thread × max_threads`
- `protocol_global_timeout > work_update_seconds + 5`
- RPC auth: must have either (rpcuser + rpcpassword) **or** rpccookiefile

**No SIGHUP hot-reload.** `/config` POST writes the file, but the
process must restart for some sections. Rust port can either match (one
shot at startup) or improve (live reload via `notify` + `arc-swap`),
but the change must be deliberate.

**Rust port:** `serde` + `serde_json` for the parse, then a dedicated
validator stage that enforces the clamps. ~300 LOC for parse +
validate, plus tests for every clamp/derivation.

### 8. `datum_queue.c` (~200 LOC)

Generic `void*` queue with caller-supplied `item_size` and a handler
function pointer. Dual-buffer design: producers write into the active
buffer; the consumer atomically swaps to the offline buffer and
processes everything in it, allowing producers to continue writing
without blocking. 10M-iteration retry on version race.

**Rust collapse:** `tokio::sync::mpsc::channel(max_entries)` with a
typed enum payload (`enum QueueItem { Share(SharePayload), ... }`).
~30 LOC for the wrapper. The dual-buffer optimization is unnecessary
in Tokio because `mpsc` is already lock-free for SPSC and lightly
contended for MPSC, and the consumer drains in batches via
`recv_many()`.

### 9. `datum_stratum_dupes.c` (~250 LOC)

Bucketed linked-list hash table:
- 65536 buckets, indexed on upper 16 bits of nonce
- Each bucket sorted by lower 16 bits
- Backing storage: contiguous `T_DATUM_STRATUM_DUPE_ITEM[]` array
- Initial capacity: `max_clients × vardiff_target_shares × stale_window_minutes × 16`
  (defaults: 1024 × 8 × 2 × 16 = 262,144 slots)
- Grows by 25% on full
- Cleanup on full: evict entries older than `share_stale_seconds`
- Re-grows if cleanup freed <5%

**Caller holds the lock** — module is not internally synchronized.

**SV2 rekey:** Replace `connection_id` with `channel_id`, replace
`extranonce1+2` with the SV2 extranonce field. SV2 share submissions
also carry a `sequence_number` per channel which can replace
`job_index` if jobs are tracked by sequence.

**Sizing concern for SV2:** A single SV2 connection can host many
extended channels, so "max channels" can be much larger than the SV1
"max clients" was. The 1024 × 8 × 2 × 16 default formula could blow
out memory. Rust port should either:
- Use `lru::LruCache` with an absolute capacity cap
- Make the cap configurable per-channel rather than per-connection

Rust data structure: `HashMap<u32, SmallVec<[DupeEntry; 4]>>` keyed
on upper-16-of-nonce, or `dashmap::DashMap` if cross-task contention
matters. ~150 LOC.

### 10. Block-discovery glue (SIGUSR1, `/NOTIFY`)

**SIGUSR1 path:**
- Bitcoin Core invokes a script via `blocknotify=<cmd>` in `bitcoin.conf`
- The conventional script: `kill -USR1 $(pidof datum_gateway)`
- Handler: `datum_blocktemplates_notifynew_sighandler()` sets a flag
  picked up by the template thread on its next 2.5ms-granularity sleep

**HTTP `/NOTIFY` path:**
- GET request to the API. Auth-free.
- Operators who can't (or won't) signal use:
  `blocknotify=curl -s http://127.0.0.1:7152/NOTIFY`
- Same flag set as the signal path

**Race handling:**
- The 2.5-second window in `datum_blocktemplates.c` deduplicates: a
  notification arriving within 2.5s of the prior `prevhash` change is
  treated as a no-op
- The fallback `datum_gateway_fallback_notifier` thread polls
  `getbestblockhash` every 1s as a safety net for missed signals
- Result: even with both signal and HTTP paths firing simultaneously,
  the worst case is one wasted GBT call

**Rust port:**
```rust
tokio::signal::unix::signal(SignalKind::user_defined1())
    // -> notifier.notify_one()
axum::Router::new().route("/NOTIFY", get(|state| async move {
    state.notifier.notify_one();
    "OK"
}))
```
~30 LOC including the dedup window.

## Rust workspace layout

Recommended crate decomposition (Cargo workspace):

```
datum-rs/
├── Cargo.toml                # workspace
├── crates/
│   ├── datum-rpc/            # bitcoind RPC client (wraps bitcoincore-rpc)
│   ├── datum-blocktemplates/ # GBT pull, parse, ring-buffer cache, blocknotify
│   ├── datum-coinbaser/      # V2 blob parser, coinbase output assembly
│   ├── datum-submitblock/    # block-found escape hatch + extra URLs
│   ├── datum-protocol/       # upstream DATUM protocol leg (Noise + 8-job ring)
│   ├── datum-stratum-sv1/    # SV1 server (legacy/optional, for parity testing)
│   ├── datum-stratum-sv2/    # SV2 mining server (uses SRI roles-logic)
│   ├── datum-dupes/          # composite-key share dedup filter
│   ├── datum-queue/          # mpsc wrapper + typed enum (might inline into bin)
│   ├── datum-api/            # axum dashboard, embedded assets, /NOTIFY, /metrics
│   ├── datum-config/         # serde + validator stage
│   └── datum-bin/            # main entry; wires everything; signals; lifecycle
└── ...
```

**Why this split:**
- `datum-rpc` and `datum-blocktemplates` are reusable outside DATUM;
  publishable independently, possibly upstreamable to `bitcoincore-rpc`
- `datum-stratum-sv1` lets us run mixed-mode binaries and
  byte-compatibility tests against the C gateway during migration
- `datum-stratum-sv2` is the new value; depends on SRI's `roles-logic-sv2`,
  `network-helpers`, `binary-codec`
- `datum-protocol` (the upstream leg) is unchanged in semantics; it's
  the same DATUM upstream protocol regardless of which downstream
  protocol the gateway speaks
- `datum-api` is its own crate because it's 40% of the LOC and changes
  on a different cadence than the protocol crates

**Heavy dependencies (workspace-level versioning):**
- `tokio` (full)
- `axum`, `tower`, `tower-http`
- `tracing`, `tracing-subscriber`, `tracing-appender`
- `bitcoin` (rust-bitcoin)
- `bitcoincore-rpc` (or replacement supporting cookie + retry)
- `serde`, `serde_json`
- `noiseexplorer-nx` or hand-rolled Noise (for upstream DATUM protocol)
- `roles-logic-sv2` (SRI), `binary-codec-sv2`, `network-helpers-sv2`

## Block-found data flow (Phase 2 drop-in, Rust)

```
SV2 miner ──SubmitSharesExtended──▶ datum-stratum-sv2
                                          │
                                          ▼
                              channel-validation pipeline
                              (PoW, target, stale, ntime,
                              dedup via datum-dupes,
                              job-ring lookup)
                                          │
                              ┌───────────┴───────────┐
                              ▼                       ▼
                         was_block?                share is valid
                         (hash <= block_target)
                              │                       │
                              │                       ▼
                              │              datum-queue (mpsc)
                              │                       │
                              │                       ▼
                              │              datum-protocol
                              │              (upstream DATUM,
                              │              encrypted, 8-job ring,
                              │              ships to OCEAN)
                              │
                              ▼
                    datum-submitblock
                    │
                    ├─▶ bitcoind submitblock RPC (LOCAL)
                    │   via datum-rpc
                    │
                    ├─▶ extra_block_submissions[].submitblock
                    │   (parallel, fan-out to N URLs)
                    │
                    └─▶ bitcoind preciousblock RPC (LOCAL)
```

**Critical property:** the two outbound paths from a found block —
`submitblock` to the local bitcoind, and the share submission to OCEAN
via DATUM upstream — are **independent and parallel**. The Rust port
must preserve this. Even if OCEAN is unreachable, the operator's block
gets broadcast to the network. Even if the local node is sluggish, the
share gets to OCEAN to credit the operator.

## Scope risks

1. **`datum_api.c` is 40% of the residual port.** Operators built
   dashboards against this surface. Look at: `/clients` table layout,
   `/umbrel-api` JSON shape, `/NOTIFY` plaintext "OK" response, the
   CSRF token derivation (`SHA256("DATUM Anti-CSRF Token" + port +
   pwd)`). Each one is small individually; together they're ~1,200
   Rust LOC plus templates plus the embedded asset bundling.

2. **Logger format.** Operators have grep/awk pipelines over the
   timestamp + 44-char-function-name + 5-char-level format. The Rust
   replacement using `tracing` is technically free (50 LOC) but the
   tracing-subscriber default format does not match byte-for-byte.
   Plan: implement a custom `FormatEvent` that reproduces the layout,
   or version-bump and document.

3. **Coinbaser fingerprint variants.** The temptation is to drop all 5
   non-`huge` variants for SV2-downstream — correct decision, but the
   Rust gateway must verify against real ASIC firmware that the SV2
   path doesn't trigger the same coinbase-size pathologies SV1 had.
   Plan: integration test against an actual S19/M30S in SV2 mode
   before declaring parity.

4. **Dupe-table sizing under SV2.** The SV1 formula
   (`max_clients × target_shares × stale_min × 16`) silently scales
   with a multiplier that's wrong for SV2 (channels-per-connection).
   Without rethinking this, a single misbehaving downstream proxy
   could pin a couple of GB of RAM in dupe entries. Plan: switch to
   `lru::LruCache` with a hard cap, or per-channel sub-tables with
   a global LRU eviction policy.

5. **Hardcoded `["segwit"]` GBT rules.** Replicating this verbatim
   means the Rust gateway will stop working when bitcoind requires
   `taproot` to be advertised for templates containing taproot-
   dependent transactions (already happens for some non-standard
   policies). Plan: make the rules array configurable, default to
   `["segwit", "taproot"]`. Compatibility hazard if any operator
   has a bitcoind config that rejects unknown rule advertisement.

6. **Reconnect/backoff is ad-hoc.** The C gateway sleeps 1s and
   retries forever on RPC failure. The Rust port should add
   exponential backoff with jitter and a circuit breaker — both for
   bitcoind RPC and for the upstream DATUM connection. This is an
   improvement, but should be flagged so operators don't get
   surprised by different behavior under bitcoind restart.

## Justification

Concrete per-module port plan with LOC budget, crate selection, and
hazard list. Forms the input to a Phase 2 implementation roadmap.
The hazards section is the load-bearing output: a naive port that
ignores the API surface, dupe-table sizing, and logger format will
produce a gateway that "works" but breaks every operator's existing
ops infrastructure on day 1.
