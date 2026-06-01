---
title: "DATUM Gateway Config Surface — Operator Knobs the SV2 Variant Inherits"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_conf.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 9
tags: [datum, datum-gateway, configuration, operator-surface, vardiff-config, defaults]
related_concepts: [sv2-downstream-replacement, vardiff, config-compatibility]
---

# DATUM Gateway config surface — what the operator sees today

Extracted from `src/datum_conf.c` — every key the parser recognizes, with
defaults. This is the **operator-facing contract** an SV2-downstream variant
must either preserve or explicitly version-break.

## `bitcoind` (Bitcoin node)

| Key | Type | Default | Note |
|---|---|---|---|
| `rpccookiefile` | string | "" | path to `.cookie` |
| `rpcuser` | string | "" | RPC user |
| `rpcpassword` | string | "" | RPC password |
| `rpcurl` | string | **required** | e.g. `http://localhost:8332` |
| `work_update_seconds` | int | 40 | range 5–120 |
| `notify_fallback` | bool | true | fallback notifications |

## `stratum` (the SV1 server — fully replaced under SV2)

| Key | Type | Default | Note |
|---|---|---|---|
| `listen_addr` | string | "" | bind addr |
| `listen_port` | int | **23334** | OCEAN-canonical port |
| `max_clients_per_thread` | int | 128 | |
| `max_threads` | int | 8 | |
| `max_clients` | int | 1024 | global ceiling |
| `trust_proxy` | int | -1 | PROXY protocol depth, -1 disabled |
| `vardiff_min` | int | 16384 | minimum diff; **must be power of 2** |
| `vardiff_target_shares_min` | int | 8 | target shares/min |
| `vardiff_quickdiff_count` | int | 8 | shares before fast bump |
| `vardiff_quickdiff_delta` | int | 8 | speed multiplier threshold |
| `share_stale_seconds` | int | 120 | range 60–150 |
| `fingerprint_miners` | bool | true | infer miner type for coinbase variant |
| `idle_timeout_no_subscribe` | int | 15 s | 0=disabled |
| `idle_timeout_no_shares` | int | 7200 s | 0=disabled |
| `idle_timeout_max_last_work` | int | 0 | 0=disabled |
| `username_modifiers` | object | — | per-share revenue routing (see usernames.md) |

## `mining` (block construction)

| Key | Type | Default | Note |
|---|---|---|---|
| `pool_address` | string | **required** | reward recipient |
| `coinbase_tag_primary` | string | "DATUM Gateway" | |
| `coinbase_tag_secondary` | string | "DATUM User" | |
| `coinbase_unique_id` | int | 4242 | range 1–65535 |
| `save_submitblocks_dir` | string | "" | block log dir |

## `api` (operator dashboard)

| Key | Type | Default | Note |
|---|---|---|---|
| `admin_password` | string | "" | blank = disabled |
| `allow_insecure_auth` | bool | false | Safari MD5 fallback |
| `listen_addr` | string | "" | |
| `listen_port` | int | 0 | 0=disabled |
| `modify_conf` | bool | false | runtime config edit toggle |

## `extra_block_submissions`

| Key | Type | Default | Note |
|---|---|---|---|
| `urls` | string[] | [] | alternate bitcoind RPC endpoints for block broadcast |

Block-broadcast multi-endpoint (orphan-rate insurance) — easy to keep in SV2 variant.

## `logger`

| Key | Type | Default |
|---|---|---|
| `log_to_console` | bool | true |
| `log_to_stderr` | bool | false |
| `log_to_file` | bool | false |
| `log_file` | string | "" |
| `log_rotate_daily` | bool | true |
| `log_calling_function` | bool | true |
| `log_level_console` | int | 2 (Info) — range 0–5 |
| `log_level_file` | int | 1 (Debug) |

## `datum` (upstream pool)

| Key | Type | Default |
|---|---|---|
| `pool_host` | string | `datum-beta1.mine.ocean.xyz` |
| `pool_port` | int | 28915 |
| `pool_pubkey` | string | (64-char hex, OCEAN's pubkey) |
| `pool_pass_workers` | bool | true |
| `pool_pass_full_users` | bool | true |
| `always_pay_self` | bool | true |
| `pooled_mining_only` | bool | true |
| `protocol_global_timeout` | int | 60 |

## SV2-downstream config impact analysis

### Section-by-section

- **`bitcoind`** — preserve as-is. SV2 doesn't change GBT path.
- **`stratum`** — **rename and overhaul**. New section, e.g.
  `mining_server_sv2`, with: `listen_addr`, `listen_port`,
  `noise_keypair`, `auth_keys[]`, `max_channels` (replaces
  `max_clients`), `extranonce_prefix_size`, `min_target` (replaces
  `vardiff_min`).
- **`mining`** — preserve.
- **`api`** — preserve. Endpoints likely stay similar.
- **`extra_block_submissions`** — preserve.
- **`logger`** — preserve.
- **`datum`** — preserve (upstream DATUM protocol leg unchanged in scope).

### Specifically gone

- `vardiff_min` (16384, must be power of 2) — SV2 uses 256-bit targets
  natively, no diff-must-be-power-of-2 constraint.
- `fingerprint_miners` — SV2 has no notion of miner-UA-based coinbase
  selection at the channel layer; this either disappears or moves to
  template builder.
- `max_clients_per_thread` / `max_threads` — Tokio-task model has no
  worker-thread cap with the same semantics; replaced by Tokio runtime
  worker_threads count which is a **runtime** rather than per-protocol knob.
- `idle_timeout_no_subscribe` — SV2 has explicit `OpenMiningChannel` /
  `SetupConnection` lifecycle; no equivalent half-open state.

### Specifically new

- Noise static keypair (Ed25519 / X25519) for SV2 transport encryption.
- Authority pubkey bundle (for downstream miner cert verification, if used).
- Channel-type policy: `allow_standard`, `allow_extended`, default
  extranonce sizes.
- Optionally: SV2 sub-protocol selectors (Job Declaration / Template
  Distribution if the gateway exposes those — though for a downstream-
  facing variant, only Mining Protocol matters).

## Justification

Authoritative list of every operator knob, with defaults. Necessary
input for spec'ing the SV2-downstream variant's config compatibility
story (preserve vs version-bump vs deprecate).
