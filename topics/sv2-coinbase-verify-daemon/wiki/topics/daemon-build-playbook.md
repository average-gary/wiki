---
title: "Build playbook — SV2 coinbase-verify daemon"
type: topic
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, daemon, build-guide, rust, SRI, extended-channel, coinbase-check, playbook]
---

# Build playbook — SV2 coinbase-verify daemon

End-to-end guide to building the simple daemon: connect to an SV2 pool as a miner,
receive jobs, reconstruct the coinbase, and check it against an expected value.
Synthesizes the concept articles into a build order.

## Design decision #0: open an EXTENDED channel

The whole task hinges on this. A **standard** channel gives you only a `merkle_root`
(opaque) and you can check *nothing* about the coinbase. Only an **extended** channel's
`NewExtendedMiningJob` carries `coinbase_tx_prefix` / `coinbase_tx_suffix` /
`merkle_path`. → Always `OpenExtendedMiningChannel`.
See [[wiki/concepts/standard-vs-extended-channels-coinbase-visibility]].

## Crate stack

Depend on `stratum-core` + `stratum-apps`, or à-la-carte: `codec_sv2`(+noise),
`noise_sv2`, `binary_sv2`, `common_messages_sv2`, `mining_sv2`, `parsers_sv2`,
`channels_sv2`, `network_helpers` (sv2-apps), `bitcoin`, `tokio`, `async-channel`,
`tracing`, `clap`. Reuse `channels_sv2` for merkle/coinbase/target math — don't
reimplement. See [[wiki/concepts/sri-client-crate-stack]].

## The daemon loop (naming SRI types)

```
1. CONNECT + NOISE
   let initiator = noise_sv2::Initiator::new(Some(pool_pubkey.0)); // Secp256k1PublicKey
   let (rx, tx) = network_helpers::noise_connection::Connection::new(
                      socket, HandshakeRole::Initiator(initiator)).await;

2. SETUP CONNECTION
   send  SetupConnection{ protocol: MiningProtocol, min_version:2, max_version:2, flags,.. }
   recv  SetupConnectionSuccess

3. OPEN EXTENDED CHANNEL
   send  OpenExtendedMiningChannel{ request_id, user_identity, nominal_hash_rate,
             max_target, min_extranonce_size }
   recv  OpenExtendedMiningChannelSuccess{ channel_id, target, extranonce_prefix,
             extranonce_size, group_channel_id }
   -> ExtendedChannel::new(channel_id, .., extranonce_prefix, .., extranonce_size, ..)

4. FRAME LOOP
   match parsers_sv2::Mining::try_from((msg_type, payload)) {
     NewExtendedMiningJob(j) => channel.on_new_extended_mining_job(j)?, // stores prefix/suffix/path
     SetNewPrevHash(p)       => channel.on_set_new_prev_hash(p)?,       // activates future job
     SetTarget(t)            => channel.set_target(..),
     SetExtranoncePrefix(e)  => channel.set_extranonce_prefix(..),
   }

5. RECONSTRUCT + CHECK  (the point of the tool)
   full_extranonce = extranonce_prefix ++ chosen_extranonce
   let coinbase = prefix ++ full_extranonce ++ suffix;
   let tx: bitcoin::Transaction = consensus::deserialize(&coinbase)?;
   // run the expected-value checks (see taxonomy):
   //   tx.output.iter().any(|o| o.script_pubkey == expected_spk)         // check (a)
   //   tx.output value vs expected                                        // check (b)
   //   scriptSig contains expected tag / BIP34 height / 0xfabe6d6d        // checks (c/c'/c")
   //   OP_RETURN 6a24 aa21a9ed <commitment>                               // check (d)
   // integrity (e): merkle_root_from_path(prefix,suffix,full_extranonce,path)
   //                must equal the root you'd hash in the header
   -> on mismatch: log/alert (misconfig or skimming signal)

6. (optional) MINE + SUBMIT
   reuse channel.validate_share(SubmitSharesExtended{..}) for PoW/block-found;
   send SubmitSharesExtended{ channel_id, sequence_number, job_id, nonce, ntime,
            version, extranonce }
```

See [[wiki/concepts/sv2-mining-client-message-flow]] and
[[wiki/concepts/coinbase-reconstruction-and-merkle-fold]].

## The expected-value checks

Pick from the [[wiki/concepts/expected-value-checks-taxonomy|taxonomy]]. Most common:
(a) payout scriptPubKey matches a configured address, (b) output value matches an
expected split, (c) pool tag present. For **where the expected value comes from** — the
subsidy (computable from height), the fees (need a template), and the payout target
(pool-address for custodial FPPS/PPLNS vs miner-address for SOLO/DATUM/JD) — see
[[wiki/concepts/sourcing-the-expected-value]]. Do **not** treat the miner-rolled
extranonce window as a fixed expected constant.

## Concrete code + turning it into a watchdog

- [[wiki/topics/reference-implementation-skeleton]] — the source-verified Cargo.toml +
  `main.rs` (exact SRI signatures, and an honest UNVERIFIED list).
- [[wiki/concepts/deviation-detection]] — extend the one-shot check into alerting: an
  intra-channel job-diff heuristic + an on-chain correlation loop against your own
  bitcoind or mempool.space/Esplora.

## Where to start from code

Fork the SRI `mining-device` skeleton for connect/handshake/frame-loop; swap its
standard channel for the extended-channel path + `ExtendedChannel`; add the
`consensus::deserialize::<Transaction>` + output/scriptSig checks. That reuses
essentially all the merkle/coinbase/target math.
See [[wiki/concepts/sri-client-crate-stack]].

## Honest scoping

This is a **watchdog**, not a trustless guarantee — read
[[wiki/topics/what-the-daemon-can-and-cannot-prove]] before overselling it.

## See also

- [[wiki/topics/what-the-daemon-can-and-cannot-prove]]
- [[wiki/concepts/prior-art-coinbase-verification]]
- [[../stratum-sri/_index|stratum-sri]]
- [[../datum/_index|datum]]
