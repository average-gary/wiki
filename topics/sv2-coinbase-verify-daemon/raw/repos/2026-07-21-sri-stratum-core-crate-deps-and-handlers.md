---
title: "SRI stratum-core crate graph + handlers_sv2 + network_helpers (minimal dependency set)"
source_url: https://github.com/stratum-mining/stratum/blob/main/stratum-core/Cargo.toml
source_url_2: https://github.com/stratum-mining/stratum/blob/main/sv2/handlers-sv2/src/mining.rs
source_url_3: https://docs.rs/mining_sv2/latest/mining_sv2/
type: repo
retrieved: 2026-07-21
credibility: high
corroboration: "rust-stack + client-flow agents (mining_sv2 struct signatures cross-confirm the spec)"
tags: [stratum-v2, SRI, stratum-core, parsers_sv2, handlers_sv2, channels_sv2, codec_sv2, mining_sv2, roles_logic_sv2, network_helpers, Cargo]
summary: "The crate manifest that names the minimal SV2-client dependency set + current major versions, resolves the roles_logic_sv2 → parsers/handlers/channels split, gives the HandleMiningMessagesFromServer trait, and pins where network_helpers now lives (sv2-apps stratum-apps)."
---

# SRI stratum-core deps + handlers + network_helpers

## stratum-core (the dependency hub)

`stratum-core` re-exports all low-level protocol crates under one namespace
(the mining-device imports `stratum_apps::stratum_core::{codec_sv2,
common_messages_sv2, mining_sv2, noise_sv2, parsers_sv2, ...}`).

Current versions (July 2026 main): `binary_sv2 ^6`, `codec_sv2 ^6` (feature
`noise_sv2`), `framing_sv2 ^7`, `noise_sv2 ^1`, `buffer_sv2 ^3`, `parsers_sv2 ^0.5`,
`handlers_sv2 ^0.5`, `channels_sv2 ^7`, `common_messages_sv2 ^8`, `mining_sv2 ^11`,
`template_distribution_sv2 ^6`, `job_declaration_sv2 ^9`.

## The roles_logic_sv2 split (naming-confusion trap)

The crate historically called **`roles_logic_sv2`** was split into:
- **`parsers_sv2`** — message enums (`Mining`, `CommonMessages`, `MiningDeviceMessages`,
  `AnyMessage`) + the `(msg_type, payload).try_into()` parsing.
- **`handlers_sv2`** — the handler traits.
- **`channels_sv2`** — channel + coinbase/merkle logic.

`roles_logic_sv2 1.0.0` still exists on crates.io (used by older tooling:
message-generator, demand benchmarking-tool), but new code uses the split crates.

Subprotocol message structs live at `sv2/subprotocols/{common-messages, mining,
template-distribution, job-declaration}`. `mining_sv2` (`sv2/subprotocols/mining/src`)
defines `new_mining_job.rs`, `open_channel.rs`, `submit_shares.rs`,
`set_new_prev_hash.rs`, `set_target.rs`, etc.

## mining_sv2 struct signatures (docs.rs — cross-confirms the spec)

- `pub struct NewMiningJob { channel_id: u32, job_id: u32, min_ntime: Sv2Option<u32>,
  version: u32, merkle_root: U256 }` — **no coinbase / merkle_path fields**.
- `pub struct NewExtendedMiningJob { channel_id: u32, job_id: u32, min_ntime:
  Sv2Option<u32>, version: u32, version_rolling_allowed: bool, merkle_path:
  Seq0255<U256>, coinbase_tx_prefix: B064K, coinbase_tx_suffix: B064K }`.
- `min_ntime` is an `Sv2Option` (the future-job signal).

## handlers_sv2::mining (the client dispatch trait)

`trait HandleMiningMessagesFromServerSync` (and `...Async`): entry
`handle_mining_message_from_server(server_id, channel_type, message, tlv_fields)`
dispatches by variant to hooks you implement:
`handle_open_standard_mining_channel_success`,
`handle_open_extended_mining_channel_success`, `handle_new_mining_job`,
**`handle_new_extended_mining_job`**, `handle_set_new_prev_hash`, `handle_set_target`,
`handle_set_extranonce_prefix`, `handle_submit_shares_success/error`, etc.
`channel_type` lets one impl serve standard vs extended. Downstream-outbound messages
return `unexpected_message` — the trait is specifically *client-receiving-from-server*.

## network_helpers (moved to sv2-apps)

Now in **sv2-apps `stratum-apps/src/network_helpers/`** (module `noise_connection` with
`Connection`, plus `accept_noise_connection`, `noise_stream.rs`, plain TCP). Formerly a
standalone `network_helpers_sv2` crate. `Connection::new(stream, HandshakeRole)` returns
`(Receiver, Sender)` of `EitherFrame`s. `stratum-apps` also bundles
`key_utils::Secp256k1PublicKey` (pool cert pubkey parsing), `custom_mutex::Mutex`
(`safe_lock`), `coinbase_output_constraints.rs`, `config_helpers`, `payout.rs`.

## Minimal à-la-carte crate set

`codec_sv2`(+noise) · `noise_sv2` · `binary_sv2` · `common_messages_sv2` · `mining_sv2`
· `parsers_sv2` · `channels_sv2` · `network_helpers`(sv2-apps) · `bitcoin` · optionally
`handlers_sv2`. Plus `tokio`, `async-channel`, `tracing`, `clap`.

## Other client implementations (breadth)

- **DEMAND `demand-easy-sv2`** — ergonomic wrapper over SRI (`use
  demand_easy_sv2::roles_logic_sv2::parsers::{Mining, PoolMessages, TemplateDistribution}`).
- **Braiins** ships a separate Rust SV2 stack (`ii-stratum`), production-grade, not in
  the stratum-mining org.
- No official Go/Python SV2 *mining-client* library of note; Rust/SRI is the reference.
