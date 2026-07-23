---
title: "SRI client crate stack"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, SRI, rust, stratum-core, parsers_sv2, handlers_sv2, channels_sv2, codec_sv2, mining_sv2, network_helpers, cargo]
---

# SRI client crate stack

The minimal Rust dependency set for a daemon that connects, receives jobs, and
reconstructs/checks the coinbase — plus the naming traps to avoid.

## Two repos (2025 split)

- **`stratum-mining/stratum`** — low-level protocol crates, aggregated by the
  **`stratum-core`** re-export hub.
- **`stratum-mining/sv2-apps`** — runnable roles/apps. The **`mining-device`**
  reference client is now a module + binary in the `integration-tests` crate (was
  `roles/test-utils/mining-device/` at tag `v1.0.0`). `network_helpers` also lives here
  now (`stratum-apps/src/network_helpers/`), not as a standalone crate.
  — [[raw/repos/2026-07-21-sri-mining-device-reference-client]],
  [[raw/repos/2026-07-21-sri-stratum-core-crate-deps-and-handlers]]

## The roles_logic_sv2 split (naming trap)

The old `roles_logic_sv2` crate is now split into:
- **`parsers_sv2`** — message enums (`Mining`, `CommonMessages`, `MiningDeviceMessages`,
  `AnyMessage`) + `(msg_type, payload).try_into()` decode.
- **`handlers_sv2`** — the `HandleMiningMessagesFromServer{Sync,Async}` dispatch trait.
- **`channels_sv2`** — channel + coinbase/merkle logic (the reuse win).

`roles_logic_sv2 1.0.0` still exists for older tooling; new code uses the split crates.

## Minimal crate set + current majors (July 2026, source-verified on crates.io)

`codec_sv2 ^6` (feature `noise_sv2`) · `noise_sv2 ^1` · `binary_sv2 ^6` ·
`common_messages_sv2 ^8` · `mining_sv2 ^11` · `parsers_sv2 ^0.5` · `channels_sv2 ^7` ·
`handlers_sv2 ^0.5` (optional) · `framing_sv2 ^7` · `buffer_sv2 ^3` · `bitcoin 0.32.5` ·
`stratum-core 0.5.0`. Plus `network_helpers` (sv2-apps) for `Connection`, and
`tokio` / `async-channel` / `tracing` / `clap`. Simplest path: depend on `stratum-core`
+ `stratum-apps` and pull everything from one namespace.
— [[raw/repos/2026-07-21-sri-stratum-core-crate-deps-and-handlers]],
[[raw/repos/2026-07-21-sri-current-api-versions-and-signatures]]

**Dependency-posture caveat:** `stratum-apps 0.7.0` (the ADK with `network_helpers` +
`key_utils`) currently git-pins `stratum-core` to branch=main and is not cleanly
crates.io-consumable ("MUST be changed before stratum-apps is published"). Mirror SRI and
git-pin `stratum-apps`, or drive `codec_sv2` + tokio TCP directly. Exact struct/fn
signatures (SetupConnection, OpenExtendedMiningChannel, ExtendedChannel::new /
validate_share, merkle_root_from_path) and the frame build/parse idioms are captured in
[[wiki/topics/reference-implementation-skeleton]].

## Sniffer vs. own-client (architecture note)

`stratum-sniffer` is **not** a passive tap — it's an active MITM that terminates two
Noise sessions with its own hardcoded keypair (the miner must trust its pubkey). Because
SV2 is Noise_NX + AEAD, you cannot read a third party's session without keys/MITM. The
daemon should **be its own SV2 client** (holds session keys by construction), reusing the
same SRI crates the sniffer does. — [[raw/repos/2026-07-21-stratum-sniffer-mitm-architecture]]

## The reuse win: channels_sv2

- `channels_sv2::client::extended::ExtendedChannel` — `on_new_extended_mining_job`,
  `on_set_new_prev_hash`, and **`validate_share`** (reconstruct coinbase → merkle root →
  build `bitcoin::block::Header` → hash → compare vs share/network target). `no_std`-capable.
- `channels_sv2::merkle_root::merkle_root_from_path(prefix, suffix, extranonce, path)` —
  standalone free function; depends only on `bitcoin` + `alloc`.
- `channels_sv2::server::jobs::factory::JobFactory` — build the *expected* coinbase
  (`new_coinbase_tx_prefix_and_suffix`, `op_pushbytes_pool_miner_tag`).
- Support: `target.rs` (`Target`, `u256_to_block_hash`, `from_compact`, `is_met_by`),
  `bip141.rs`, `chain_tip.rs`, `extranonce_manager/`.
  — [[raw/repos/2026-07-21-sri-channels-sv2-client-extended-validate-share]]

## Alternatives

`demand-easy-sv2` (ergonomic wrapper over SRI); Braiins `ii-stratum` (separate
production Rust stack). No notable Go/Python SV2 *mining-client* library — Rust/SRI is
the reference.

## See also

- [[wiki/concepts/sv2-mining-client-message-flow]]
- [[wiki/concepts/coinbase-reconstruction-and-merkle-fold]]
- [[wiki/topics/daemon-build-playbook]]
- [[../stratum-sri/_index|stratum-sri]]
