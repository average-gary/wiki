---
title: "SRI mining-device — the reference downstream SV2 client (sv2-apps)"
source_url: https://github.com/stratum-mining/sv2-apps/blob/main/integration-tests/lib/mining_device/mod.rs
source_url_2: https://github.com/stratum-mining/sv2-apps/blob/main/integration-tests/bin/mining_device.rs
type: repo
retrieved: 2026-07-21
credibility: high
corroboration: "rust-stack agent (primary source, ~1085 lines)"
tags: [stratum-v2, SRI, sv2-apps, mining-device, reference-client, noise, SetupConnection, OpenStandardMiningChannel, tokio]
summary: "The SRI reference CPU-mining client: the minimal working connect → Noise handshake → SetupConnection → open-channel → receive-job → hash → submit loop. Uses a STANDARD channel (so it never sees the coinbase) — the skeleton to adapt for an extended-channel coinbase-check daemon."
---

# SRI mining-device — reference downstream SV2 client

**Repo split note (2025):** low-level protocol crates live in
`stratum-mining/stratum` (aggregated by `stratum-core`); runnable role/app code moved
to **`stratum-mining/sv2-apps`**. The `mining-device` role that used to be at
`roles/test-utils/mining-device/` (still visible at tag `v1.0.0`) is now an embedded
module + binary inside the `integration-tests` crate in sv2-apps
(`[[bin]] name = "mining_device"`).

## The connect + mine loop (names every SRI type)

- **Type aliases** defining the framing stack: `Message = MiningDeviceMessages<'static>`;
  `StdFrame = StandardSv2Frame<Message>`; `EitherFrame = StandardEitherFrame<Message>`
  (from `codec_sv2`).
- **connect()**: `TcpStream::connect` → `noise_sv2::Initiator::new(pub_key)` →
  `network_helpers::noise_connection::Connection::new(socket,
  HandshakeRole::Initiator(initiator))` → returns `(Receiver<EitherFrame>,
  Sender<EitherFrame>)` async channels.
- **SetupConnection** (`SetupConnectionHandler`): builds
  `SetupConnection{ protocol: Protocol::MiningProtocol, min_version:2, max_version:2,
  flags, endpoint_host/port, vendor, ... }`, sends, awaits `SetupConnectionSuccess`.
- **open_channel()**: measures CPU hashrate, sends `OpenStandardMiningChannel{
  request_id, user_identity, nominal_hash_rate, max_target }`. **Note: STANDARD
  channel** → the pool sends a precomputed `merkle_root` in `NewMiningJob`, so this
  file does NOT reconstruct the coinbase.
- **Job/share loop**: `Device::handle_message_mining` matches `Mining::{NewMiningJob,
  SetNewPrevHash, SetTarget, OpenStandardMiningChannelSuccess, SubmitSharesSuccess/
  Error, ...}`. `Miner::new_header` builds a `bitcoin::block::Header` from `prev_hash`
  + `merkle_root`; `next_share()` hashes vs target (LE u256 word compare); winning
  nonce → `SubmitSharesStandard{ channel_id, sequence_number, job_id, nonce, ntime,
  version }`.

## Why it matters for this daemon

It's the smallest working client skeleton. To do a coinbase check, **swap the standard
channel** (`OpenStandardMiningChannel` / `SubmitSharesStandard` / hand-rolled `Miner`)
for the extended-channel path: `OpenExtendedMiningChannel` +
`channels_sv2::client::extended::ExtendedChannel` + `SubmitSharesExtended`. The
connect + handshake + frame-loop scaffolding carries over unchanged.
