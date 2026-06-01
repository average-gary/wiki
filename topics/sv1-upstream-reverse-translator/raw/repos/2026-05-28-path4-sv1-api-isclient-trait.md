# path4 - sv1_api crate (IsClient trait + example)

**Source type**: repos
**Path**: `/Users/garykrause/repos/stratum/sv1/`
**GitHub**: https://github.com/stratum-mining/stratum/tree/main/sv1
**Crate name**: `sv1_api` v4.0.0 (lib name: `v1`)
**Date observed**: 2026-05-28

## Why this matters for the reverse translator

The reverse translator must act as an **SV1 client** to the upstream pool. The `sv1_api::IsClient` trait is exactly the interface needed — and there is a fully-worked TCP example showing how to drive the state machine from a real socket.

## API surface

`sv1/src/lib.rs` defines two top-level traits:

- `IsServer<'a>` — used by SV1 servers (the *forward* translator-proxy uses this for its downstream SV1 miner).
- `IsClient<'a>` — used by SV1 clients (the *reverse* translator uses this for its upstream SV1 pool).

`IsClient` provides handler methods for incoming server-to-client messages:
- `handle_notify(server_id, notify: Notify)` — new mining job
- `handle_set_difficulty(server_id, &mut SetDifficulty)` — new target
- `handle_set_extranonce(server_id, &mut SetExtranonce)` — extranonce1 rotation
- `handle_set_version_mask(server_id, &mut SetVersionMask)` — BIP320 mask change
- `handle_subscribe(server_id, &Subscribe)` — extranonce1 + extranonce2_size handout
- `handle_configure(server_id, &mut Configure)` — version-rolling negotiation
- `handle_response(...)`, `handle_error_message(...)`

And methods to *send* client-to-server messages:
- `configure(id) -> Message` — produces `mining.configure`
- `subscribe(id, extranonce1) -> Message` — produces `mining.subscribe`
- `authorize(id, name, password) -> Message`
- `submit(id, user_name, extra_nonce2, time, nonce, version_bits) -> Message`
  - **Crucially**: `submit()` reads `last_notify` to populate `job_id` automatically and checks `is_authorized`.

Internal state tracked via `ClientStatus` enum: `Init -> Configured -> Subscribed`. All transitions enforced by trait methods.

## Worked example

`sv1/examples/client_and_server.rs` (~750 LOC) shows a complete `IsClient` impl driving a real TCP connection — exactly the pattern the reverse translator needs for its upstream SV1 connection. Highlights:

- Two threads per side: one reading `BufReader::lines()` -> `mpsc::channel<String>`, one writing from `mpsc::Receiver<String>`.
- `Client` struct holds `extranonce1`, `extranonce2_size`, `version_rolling_mask`, `status`, `last_notify`, `sented_authorize_request: Vec<(u64, String)>`, `authorized: Vec<String>`.
- State pump loop: `Init -> send_configure -> Configured -> send_subscribe -> Subscribed -> send_authorize -> running`.
- Submit loop: pulls `last_notify`, builds Submit message via `IsClient::submit()`.

The example uses `std::thread + std::sync::mpsc` rather than tokio, but the structure ports directly to async (replace `BufReader::lines()` with `tokio::io::BufReader::lines()`, `mpsc::channel` with `tokio::sync::mpsc`).

## Key findings

- **Q1/Q2 (reuse for SV1 client side)**: `sv1_api` already has the complete client side; no need to write from scratch. The reverse translator binary impls `IsClient` for a struct that holds the connection-level state and translates incoming SV1 messages into outgoing SV2 messages on a `tokio::sync::mpsc` to the SV2 server task.

- **Q4 (state diagram)**: SV1 client must complete configure/subscribe/authorize *before* it can submit — the IsClient state machine enforces this. The reverse translator must therefore delay opening the SV2 listener (or accept SV2 connections but stall their `OpenExtendedMiningChannel` requests) until the upstream SV1 connection reaches Subscribed/Authorized state. Alternatively: open SV2 listener immediately, but mining.notify won't arrive until SV1 subscribed, so SV2 channels stay job-less until then.

- **Q5 (stateful translation - extranonce)**: `subscribe()` response carries `extranonce1` (Hex) and `extranonce2_size` (usize). These define the total extranonce size and exact upstream-prefix for `channels_sv2::ExtranonceAllocator::from_upstream_prefix`. The `set_extranonce` server-to-client message means the reverse translator must propagate a `SetExtranoncePrefix` SV2 message to ALL its open SV2 channels (and then re-allocate). This is the trickiest stateful flow.

- **Q5 (stateful translation - submit)**: SV1 `submit` requires `job_id` (string), `user_name` (string), `extra_nonce2` (bytes — must equal `extranonce2_size`), `time`, `nonce`, optional `version_bits`. The reverse translator's incoming SV2 `SubmitSharesExtended` carries `channel_id`, `job_id` (u32), `extranonce` (full extranonce minus channel's extranonce_prefix), `nonce`, `ntime`, `version`. Translation logic:
  - `sv1_job_id`: looked up from a `HashMap<sv2_job_id_u32, sv1_job_id_string>` populated when `mining.notify` arrives.
  - `user_name`: looked up from `HashMap<sv2_channel_id, sv1_authorized_user_name>` populated at SV2 channel-open time.
  - `extra_nonce2`: `[channel_extranonce_prefix - sv1_extranonce1, sv2_share.extranonce]` concatenated, then the leading SV1 extranonce1 must be stripped (it's already accounted for upstream). What's left must be exactly `extranonce2_size` bytes.

- **Q3 (does roles_logic_sv2 need new mode)**: `roles_logic_sv2` only exists in sv2-apps; here the equivalent low-level abstractions are `channels_sv2` + `handlers_sv2` + `sv1_api`. None needs a new mode — they are direction-agnostic. The orchestration glue (currently in sv2-apps's translator-proxy) is what needs a sibling impl with reversed wiring.

## Unresolved / worth flagging

- The `IsClient` trait does NOT expose a clean way to handle the upstream pool requesting an `mining.set_extranonce` mid-session if SV2 downstream channels are mid-share. The reverse translator likely needs to drain in-flight shares, send `SetExtranoncePrefix` to all SV2 channels, and only then resume.

- `IsClient::submit()` autopopulates `job_id` from `last_notify`, which assumes one job at a time. SV2 downstreams may be working multiple past_jobs simultaneously. The reverse translator likely cannot use `IsClient::submit()` directly — it must build `client_to_server::Submit { job_id: <translated from sv2.job_id>, ... }` directly.

## Ingest justification

`sv1_api::IsClient` is the canonical SV1 client-side trait and `examples/client_and_server.rs` provides a working implementation pattern; the reverse translator's upstream side is a tokio port of this example with translation hooks at `handle_notify`, `handle_set_difficulty`, and `handle_set_extranonce`.
