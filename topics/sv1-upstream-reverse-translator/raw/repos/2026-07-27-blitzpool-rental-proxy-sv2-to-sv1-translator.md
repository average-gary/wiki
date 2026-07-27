---
title: "warioishere/blitzpool-rental-proxy — working bidirectional SV1↔SV2 translator (SV2 miner → SV1 pool implemented)"
source: https://github.com/warioishere/blitzpool-rental-proxy
url: https://github.com/warioishere/blitzpool-rental-proxy
type: repos
category: repo
crate_name: stratum-rental-proxy
crate_version: 0.3.1
language: Rust
license: AGPL-3.0-or-later
author: "Blitzpool Contributors <https://yourdevice.ch>"
repo_created: 2026-06-27
last_commit: 2026-07-05
commits_on_master: ~80
stars: 0
status_upstream: "Beta — deployed and running, but still maturing"
ingested: 2026-07-27
ingested_by: manual
volatility: warm
quality: 5
quality_score: 5
credibility: medium-high
confidence: high
tags: [sv2-to-sv1, sv1-to-sv2, reverse-translator, bidirectional-translator, prior-art, existence-proof, stratum-translation, hashrate-rental, hashrate-broker, upstream-switching, extranonce, set-extranonce-prefix, bdiff, failover, rust, agpl]
summary: "CONTRADICTS this wiki's 2026-05-28 'greenfield from a code perspective' conclusion. A deployed Rust proxy (v0.3.1, beta) that implements the SV2-miner→SV1-pool direction by hand in src/proto/translate.rs, precisely because stratum_translation only ships the SV1→SV2 direction. All four protocol combinations work. Also an existence proof for the hashrate-broker customer segment this wiki hypothesized, and a solved treatment of the upstream-switching problem (forced reconnect for operator-initiated changes vs in-place SetExtranoncePrefix/SetTarget re-pointing for failover)."
---

# warioishere/blitzpool-rental-proxy — a working reverse translator

**This is the prior art this wiki concluded did not exist.**

On 2026-05-28 this wiki's research concluded, in [[../../wiki/concepts/sv2-spec-issue-102-the-canonical-reference|the issue-102 concept article]]: "The work is **greenfield from a code perspective**." That was accurate as of the sources surveyed then (SV2 spec §10.4.5 blank, sv2-spec issue #102 open, PR #103 stale ~19 months, Sjors recruiting for reverse-translator development). It is **no longer true**. This repo — created 2026-06-27, a month after that research — is a deployed implementation.

Crate `stratum-rental-proxy` v0.3.1, AGPL-3.0-or-later, by Blitzpool Contributors (yourdevice.ch). ~80 commits on `master`, last push 2026-07-05. Self-described status: "**Beta. Deployed and running, but still maturing — expect rough edges.**" 0 stars, 0 forks — unnoticed, not unbuilt.

Note it is *not* a standalone reverse translator: the translation lives inside a hashrate-rental proxy. But the SV2→SV1 code path is separable and is the direction this wiki cares about.

## The translation claim, verbatim from `src/proto/translate.rs`

The module doc-comment states which direction came from upstream and which they had to author:

> - **SV1 miner ↔ SV2 pool**: SV2 `NewExtendedMiningJob`+`SetNewPrevHash` become a `mining.notify`, `SetTarget` becomes `mining.set_difficulty`, and a `mining.submit` becomes `SubmitSharesExtended`. **These conversions are provided by `stratum_translation`.**
> - **SV2 miner ↔ SV1 pool**: the inverse, **built here** — `mining.notify` becomes `NewExtendedMiningJob`(+`SetNewPrevHash`), `mining.set_difficulty` becomes `SetTarget`, and `SubmitSharesExtended` becomes a `mining.submit`.

This **independently confirms this wiki's Path-1 finding**: the SRI `stratum-translation` crate's helpers are usable for the SV1→SV2 leg, and the inverse leg must be hand-authored. This repo's `translate.rs` is 33 855 bytes — a real datapoint against the playbook's "~150 LOC" gap estimate from [[2026-05-28-path1-sri-stratum-translation-crate]], though that file also carries difficulty/target math and the probe logic, so it isn't a like-for-like comparison.

All four combinations are claimed working: **SV1→SV1** and **SV2→SV2** passthrough, plus **SV1 miner→SV2 pool** and **SV2 miner→SV1 pool** translation.

### Correctness details worth stealing

- **Byte order:** follows the SV2 spec — targets are 32-byte **little-endian**; the SV1 `mining.notify` prev-hash **per-word swap** is handled by the SV1 `PrevHash` newtype, so the SV2 `prev_hash` stays in its natural internal order.
- **Difficulty convention:** uses Bitcoin **"bdiff"** (difficulty 1 = the `0x00000000FFFF0000…0000` target), matching `rust-bitcoin`'s `Target::difficulty_float`. Stated rationale: "a miner reads back exactly the difficulty the pool set (no off-by-one), and the threshold the miner sees agrees with the work the proxy credits." Directly relevant to this wiki's pdiff/bdiff Path-1 source.
- **Version rolling:** `VERSION_ROLLING_MASK: u32 = 0x1fff_e000` — the default BIP320 mask advertised to miners and used to extract version-rolling bits from a submitted SV2 version field.
- Imports `stratum_core::channels_sv2::merkle_root::merkle_root_from_path` — i.e. it **reuses `channels-sv2`** for merkle reconstruction rather than reimplementing, matching this wiki's [[2026-05-28-path4-channels-sv2-reuse]] recommendation.
- Uses `stratum_core::stratum_translation::sv2_to_sv1` plus `stratum_core::sv1_api` types (`Extranonce`, `HexU32Be`, `MerkleNode`, `PrevHash`, `client_to_server`/`server_to_client` methods).

### Upstream protocol detection

`UPSTREAM_PROBE_TIMEOUT = 3s`. Detection is **folded into the connect**: the native protocol is attempted first and its socket **reused on success**; only on failure/timeout is the other protocol tried and translation engaged. There is no standalone upstream prober.

Downstream detection is separate and cheaper — `src/proto/detect.rs` classifies each connection on a shared port by **peeking (not consuming) the first byte**: `{`, space, `\n`, `\r` → SV1 (JSON-RPC, with leniency for miners that lead with whitespace); everything else → SV2 (Noise handshake ephemeral-key bytes), on the reasoning that "the SV2 adapter's handshake rejects genuine garbage and closes." A TLS `0x16` ClientHello is explicitly called out as landing in the SV2 bucket.

## The upstream-switching problem (a solved treatment)

The README calls this "the one hard problem": a new upstream hands out a different extranonce + difficulty. Two distinct strategies, chosen by cause:

| Cause | Strategy | Mechanism | Rationale given |
|---|---|---|---|
| **Operator-initiated** (idle-pool edit, rent start, rent end) | **Force miner reconnect** | miner re-handshakes cleanly against the new upstream, correct extranonce/difficulty from the first job | "A live re-point a miner might silently ignore would waste every share, so the reconnect is the safe default here." |
| **Automatic failover** (upstream dies mid-session) | **Re-point in place** | SV1: `mining.set_extranonce` + `mining.set_difficulty` + `mining.notify(clean)`, or `client.reconnect` if the miner can't take a live extranonce. SV2: `SetExtranoncePrefix` + `SetTarget`. | "In-place keeps a flapping pool from storming the miner with reconnects." |

That split — safety-first reconnect for intentional changes, continuity-first in-place for unintentional ones — is a design answer this wiki's [[../../wiki/concepts/architecture-and-state-machine|architecture-and-state-machine]] article should absorb.

## Architecture

```
seller miners ──▶  [ this proxy ]  ──▶  upstream pool
                    per-session:        (default pool when idle,
                     downstream conn     buyer target when rented)
                     + SWAPPABLE upstream
                     + share window (hashrate)
                    control API  ◀── web UI (orders, pool switch, config)
```

**Protocol-agnostic core** (session, routing, control, accounting) with SV1/SV2/translate as **pluggable transport-codec adapters** under `src/proto/`. This is the same layering this wiki's playbook proposed.

`src/` layout: `api.rs` (36 KB), `orders.rs` (25 KB), `store.rs` (12 KB), `main.rs`, `registry.rs`, `session.rs`, `hashrate.rs`, `control.rs`, `config.rs`, `db.rs`. `src/proto/`: `relay.rs` (**91.9 KB** — the bulk), `translate.rs` (33.9 KB), `sv2.rs`, `sv1.rs`, `adapter.rs`, `detect.rs`, `mod.rs`, plus `src/proto/sv2/` (`relay.rs` 86.7 KB, `keys.rs`, `wire.rs`, `relay/`).

### Session model (`src/session.rs`)

```rust
pub enum Routing {
    Idle,                          // mine on the seller's own default pool
    Rented { order_id: String },   // live buyer target on ActiveUpstream::target
}
```

`UpstreamTarget { url, user, password, authority_pubkey: Option<String> }` — the `authority_pubkey` is **SV2 only**: the pool's Noise authority public key in base58, verified during the upstream handshake. Explicitly documented: "when `None`, the link is encrypted but unauthenticated." Ignored by the SV1 adapter. That's a concrete note for this wiki's [[../../wiki/concepts/sv2-features-lost-with-sv1-upstream|features-lost]] article — with an SV1 upstream there is no authority key to verify at all.

### Hashrate measurement

`HashrateWindow`: rolling window of accepted-share difficulty, `hashrate = Σ(share_diff) × 2^32 / elapsed_seconds`, where elapsed is the real span covered by samples **capped at the window**, "so the estimate is right within about a minute of (re)connect instead of taking the whole window to warm up." Guarded by `MIN_RATE_SECS = 60.0` as a divisor floor to stop one early share from spiking the number post-reconnect. `DIFF1_HASHES = 4_294_967_296.0` (2^32).

## Why it exists: the hashrate-broker segment, realized

This is also an **existence proof for the customer segment** this wiki hypothesized in [[../../wiki/concepts/customer-segments-and-tam|customer-segments-and-tam]] ("hashrate brokers, multi-pool failover").

The inversion, in the README's words: "a pool *generates* its own block templates; this proxy *forwards* a miner's work to an upstream of someone else's choosing and measures the delivered hashrate for billing/payout." A seller registers a miner; while **idle** it mines the seller's own default pool; when a buyer **rents** it, hashrate is rerouted **server-side** for the duration, then reverts — "the seller never reconfigures the miner."

Economics: rented shares/blocks credit the **buyer's** upstream account. The seller earns a **rental fee**, not the mining reward. The proxy measures share rate × difficulty at the wire to determine seller payout and buyer billing; the operator takes a margin. Billing quantity is **TH·day** (`HASHES_PER_TH_DAY = 1e12 × 86_400.0` in `orders.rs`).

Orders (`src/orders.rs`, SQLite `orders` table): a buyer rents a worker until a deadline and/or prepaid budget; `until_ms = 0` means open-ended with no auto-revert. Statuses `Active` / `Ended` / `Cancelled`. Orders are **persisted so a rental resumes when the miner reconnects** (the relay checks for an active order on authorize), and delivered work accumulates durably as the billing basis. Each order can carry an optional **`fallback` UpstreamTarget** — used if the buyer target is unreachable at switch time or drops mid-rental — with the notable constraint that the fallback must be the **same protocol as the rented rig** ("the proxy doesn't translate" on that path).

Per-rig hashrate history (`src/hashrate.rs`): the live estimate is in-memory only, so it's sampled once per **10-minute** wall-clock slot (`SLOT_MS = 600_000`) into `rig_hashrate_samples`, one row per rig per slot, so one read per slot *is* that slot's 10-min average. **7-day retention** (`RETENTION_MS`), pruned each tick, upsert idempotent per `(worker, slot)` so a restart within the slot overwrites rather than erroring. Served at `/sellers/{worker}/history`.

## Dependency posture (SRI consumption)

Persistence is **embedded SQLite** via `sqlx` (WAL, one file, compile-time-checked queries, committed `.sqlx/` offline cache so builds run without a live DB) — 6 migrations, `0001_init.sql` through `0006_hashrate_samples_and_order_ended.sql`. Runtime tokio; HTTP axum 0.8.

SV2 support is **feature-gated** (`--features sv2`) "so the default SV1 build stays lean," pulling from **git, not crates.io**:

- `stratum-core` — `git = stratum-mining/stratum`, `branch = "main"`, `features = ["translation"]`
- `stratum-apps` — `git = stratum-mining/sv2-apps`, `rev = 27985c63f7c47310281289d4da17b90780bb11fd`, `features = ["network", "std"]`
- `secp256k1 0.28` matched to `noise_sv2`'s version, `rand 0.8`, `primitive-types 0.13` (256-bit division for the bdiff↔target conversion)

The stated reason for avoiding crates.io is a concrete SRI packaging defect worth recording: "**the crates.io releases at current majors don't compile together (`mining_sv2`'s derives reference `super::binary_sv2`), whereas the git workspaces are internally consistent.**" `stratum-core` and `stratum-apps`' transitive `stratum-core` are unified on `branch=main` with the exact rev pinned in `Cargo.lock`. The `translation` feature is what adds `stratum_translation` + `sv1_api`.

Network transport comes from `stratum-apps::network_helpers` (`connect_with_noise` / `accept_noise_connection` → `NoiseTcpStream`).

## Declared references (inspiration, not dependencies)

- `miningmeter/stratum-proxy` (Go) — "the per-worker-owns-an-upstream shape + per-worker hashrate window."
- `blitzpool-rust` `bp-stratum-v1` / SRI `sv2-apps` — "framing/correctness." (The sibling pool is ingested in `bitcoin-mining-payout-schemas` as `2026-07-27-blitzpool-server-rust-github`.)

## README milestone list (self-reported, partly stale)

1. Core pass-through (SV1) — *marked "(in progress)"*
2. Switch (SV1) — runtime upstream swap + extranonce + control API (`set_target`/`clear_target`)
3. Rental layer — buyer orders, allocation, auto-revert, accounting, web UI
4. SV2 adapter — second adapter under the same core

The list is **behind the code**: milestone 1 is marked in-progress while the committed tree already has the SV2 adapter, the translator, per-rig history, and a 0.3.1 release. Trust the code over the milestones.

## Source-criticism notes

- **Credibility medium-high, confidence high** on the *existence* claim specifically. Unlike a pure README ingest, the central claims here were **verified against committed source** via the GitHub contents API: `translate.rs`'s directional doc-comment, `session.rs`'s `Routing`/`HashrateWindow`, `orders.rs`'s TH·day math, `detect.rs`'s first-byte logic, `hashrate.rs`'s slot store, and `Cargo.toml`'s git pins. The translator's *correctness* is not verified — no test run, no interop check, and the author says "expect rough edges."
- **0 stars, 0 forks, ~1 month old, single author.** This is not a community-validated implementation, and its being unnoticed is likely why this wiki's May research missed it — the repo did not yet exist.
- SV2→SV1 here serves a **rental** use case, where the "SV2 stack" is a proxy, not a pool-front. This wiki's motivating cases (pool inertia, gradual migration) are adjacent but not identical; the translation primitives transfer, the surrounding role does not.
- Not audited: whether the SV2→SV1 path handles SegWit/BIP141 coinbase data, job-declaration interaction (there is none — rental is a Mining-protocol-only concern), or extranonce-size negotiation across the translated boundary.

## Follow-ups this creates for the wiki

1. **Revise the "greenfield" claim** in [[../../wiki/concepts/sv2-spec-issue-102-the-canonical-reference|issue-102]] — the spec-side gap (§10.4.5 still blank, #102 still open) stands, but the code-side gap does not.
2. **Reconcile the ~150 LOC estimate** in [[2026-05-28-path1-sri-stratum-translation-crate]] and the playbook against this 33.9 KB `translate.rs`.
3. **Absorb the reconnect-vs-in-place switching split** into [[../../wiki/concepts/architecture-and-state-machine|architecture-and-state-machine]].
4. **Add the SV1-upstream-loses-authority-key point** to [[../../wiki/concepts/sv2-features-lost-with-sv1-upstream|features-lost]].
5. Consider whether an upstream contribution (inverse helpers into `stratum-translation`, per the playbook's path of least friction) can now cite a working AGPL implementation as motivation.
