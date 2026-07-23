---
title: "Reference implementation skeleton (Rust / SRI)"
type: topic
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, rust, SRI, reference-implementation, cargo, main.rs, ExtendedChannel, coinbase-check]
---

# Reference implementation skeleton (Rust / SRI)

A concrete, source-verified starting point (July 2026 SRI). Signatures confirmed against
`stratum-mining/stratum` @ main + docs.rs; items that couldn't be confirmed are marked
**UNVERIFIED** — do not treat those as final.
Source: [[raw/repos/2026-07-21-sri-current-api-versions-and-signatures]].

## Architecture decision: be your own SV2 client (not a sniffer)

SV2 is Noise_NX + AEAD encrypted end-to-end, so a passive tap reads only ciphertext.
`stratum-sniffer` "works" only as an **active MITM** that terminates two Noise sessions
with its *own* hardcoded keypair — requiring the miner to be reconfigured to trust it.
The daemon should instead **connect directly as a legitimate SV2 client**: it completes
the handshake, holds the session keys by construction, and reads `NewExtendedMiningJob`
in plaintext-to-it. Pin the pool's authority pubkey via `Initiator::new(Some(pk))`.
— [[raw/repos/2026-07-21-stratum-sniffer-mitm-architecture]]

## Cargo.toml (verified versions, all on crates.io)

```toml
[dependencies]
# Simplest: the stratum-core re-export hub (binary_sv2 6, codec_sv2 6, mining_sv2 11,
# channels_sv2 7, common_messages_sv2 8, parsers_sv2 0.5, noise_sv2 1, bitcoin 0.32.5).
stratum-core = { version = "0.5.0", features = ["with_buffer_pool"] }

# ADK: network_helpers (Connection) + key_utils (Secp256k1PublicKey).
# NOTE: stratum-apps 0.7.0 currently git-pins stratum-core to branch=main and is not
# cleanly crates.io-consumable yet — mirror SRI and git-pin it, OR drop it and drive
# codec_sv2 + tokio TCP directly.
stratum-apps = { git = "https://github.com/stratum-mining/sv2-apps", branch = "main", features = ["network", "config"] }

async-channel = "1.8.0"
tokio = { version = "1.44.1", features = ["full"] }
tracing = "0.1.41"
clap = { version = "4.5.4", features = ["derive"] }
hex = "0.4.3"
```

## main.rs skeleton

```rust
type Message    = MiningDeviceMessages<'static>;
type StdFrame   = StandardSv2Frame<Message>;
type EitherFrame = StandardEitherFrame<Message>;

// 1. TCP + Noise (Initiator). None = don't verify the pool cert; Some(pk) = pin it.
let socket = TcpStream::connect(addr).await.unwrap();
let initiator = Initiator::new(pool_pubkey.map(|e| e.0));   // Option<Secp256k1PublicKey>
let (mut receiver, sender): (Receiver<EitherFrame>, Sender<EitherFrame>) =
    Connection::new(socket, HandshakeRole::Initiator(initiator)).await.unwrap();

// 2. SetupConnection (MiningProtocol). NB: flags bit0 = REQUIRES_STANDARD_JOBS in SRI's
//    example — for an EXTENDED channel do NOT set it; exact extended flag = UNVERIFIED.
let setup = SetupConnection {
    protocol: Protocol::MiningProtocol, min_version: 2, max_version: 2, flags: 0,
    endpoint_host: addr.ip().to_string().try_into().unwrap(), endpoint_port: addr.port(),
    vendor: "".try_into().unwrap(), hardware_version: "".try_into().unwrap(),
    firmware: "".try_into().unwrap(), device_id: "".try_into().unwrap(),
};
sender.send(TryInto::<StdFrame>::try_into(
    MiningDeviceMessages::Common(setup.into())).unwrap().into()).await.unwrap();
// await CommonMessages::SetupConnectionSuccess { used_version, flags }

// 3. OpenExtendedMiningChannel — extended, so we receive the coinbase halves.
let open = OpenExtendedMiningChannel {
    request_id: 1, user_identity: "worker.1".try_into().unwrap(),
    nominal_hash_rate: 1_000_000.0_f32,                       // plain f32
    max_target: vec![0xFF_u8; 32].try_into().unwrap(),        // U256 from Vec<u8>
    min_extranonce_size: 8,
};
sender.send(TryInto::<StdFrame>::try_into(
    MiningDeviceMessages::Mining(Mining::OpenExtendedMiningChannel(open))).unwrap().into()
).await.unwrap();

// 4. Frame loop: parse via (message_type, payload).try_into() → Mining
let mut inc: StdFrame = receiver.recv().await.unwrap().try_into().unwrap();
let mt = inc.get_header().unwrap().msg_type();
let payload = inc.payload();
match (mt, payload).try_into() {  // Err = parsers_sv2::ParserError
  Ok(Mining::OpenExtendedMiningChannelSuccess(s)) => {
      let xp = ExtranoncePrefix::from_wire(s.extranonce_prefix.to_vec()).unwrap();
      let target: bitcoin::Target = /* UNVERIFIED U256(LE)->Target helper */;
      channel = ExtendedChannel::new(s.channel_id, "worker.1".to_string(), xp,
                    target, 1_000_000.0, true, s.extranonce_size);
  }
  Ok(Mining::NewExtendedMiningJob(job)) => channel.on_new_extended_mining_job(job /*.into_static()? UNVERIFIED*/).unwrap(),
  Ok(Mining::SetNewPrevHash(p))         => channel.on_set_new_prev_hash(p).unwrap(), // sets chain tip
  _ => {}
}

// 5. THE COINBASE CHECK
//   (a) reconstruct + inspect outputs:
//       let cb = [prefix, extranonce_prefix, extranonce, suffix].concat();
//       let tx: bitcoin::Transaction = consensus::deserialize(&cb)?;
//       assert!(tx.output.iter().any(|o| o.script_pubkey == expected_spk));  // check (a)
//   (b) integrity via the reuse win:
//       let root = merkle_root_from_path(&prefix, &suffix, &full_extranonce, &path)?;
//   (c) full PoW/block-found: channel.validate_share(SubmitSharesExtended{..})
//       (requires chain_tip set, else Err(NoChainTip))
```

## Key UNVERIFIED items to resolve when building

1. U256(LE wire) → `bitcoin::Target` helper name (`channels_sv2::target` has one;
   `Target::from_le_bytes` used internally).
2. `.into_static()` vs `.as_static()` to lift borrowed messages to `'static`.
3. `SetNewPrevHash` vs `SetNewPrevHashMp` importable name.
4. `ChainTip` constructor (or whether `on_set_new_prev_hash` sets it internally).
5. The extended-channel `SetupConnection.flags` bit.

## See also

- [[wiki/topics/daemon-build-playbook]] — the higher-level build order.
- [[wiki/concepts/sri-client-crate-stack]] — crate roles + naming traps.
- [[wiki/concepts/coinbase-reconstruction-and-merkle-fold]] — the algorithm behind step 5.
- [[wiki/concepts/deviation-detection]] — turning the check into alerting.
