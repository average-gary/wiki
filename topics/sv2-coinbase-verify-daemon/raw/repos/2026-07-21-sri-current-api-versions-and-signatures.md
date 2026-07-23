---
title: "SRI current API — crate versions + exact struct/fn signatures (July 2026)"
source_url: https://github.com/stratum-mining/stratum/blob/main/stratum-core/Cargo.toml
source_url_2: https://github.com/stratum-mining/sv2-apps/blob/main/integration-tests/Cargo.toml
source_url_3: https://docs.rs/mining_sv2/latest/mining_sv2/
type: repo
retrieved: 2026-07-21
credibility: high
corroboration: "gap-1 agent (source-verified against main + docs.rs)"
tags: [stratum-v2, SRI, rust, cargo, mining_sv2, channels_sv2, codec_sv2, api-signatures, ExtendedChannel, merkle_root_from_path]
summary: "Source-verified current SRI crate versions (all on crates.io) and the exact struct field types + function signatures a real daemon needs: SetupConnection, OpenExtendedMiningChannel(.Success), NewExtendedMiningJob, SubmitSharesExtended, ExtendedChannel::new / validate_share, merkle_root_from_path. Plus the frame build/parse idioms and an honest UNVERIFIED list."
---

# SRI current API — versions + signatures (July 2026)

## Crate versions (all published on crates.io, from stratum-core/Cargo.toml)

`buffer_sv2 ^3.0.0` · `binary_sv2 ^6.0.0` · `codec_sv2 ^6.0.0` (feature `noise_sv2`) ·
`extensions_sv2 ^0.2.0` · `framing_sv2 ^7.0.0` · `noise_sv2 ^1.0.0` · `parsers_sv2 ^0.5.0`
· `handlers_sv2 ^0.5.0` · `channels_sv2 ^7.0.0` · `common_messages_sv2 ^8.0.0` ·
`mining_sv2 ^11.0.0` · `template_distribution_sv2 ^6.0.0` · `job_declaration_sv2 ^9.0.0` ·
`bitcoin 0.32.5`. `stratum-core` itself = **0.5.0** (2026-07-08).

**Dependency posture caveat:** `stratum-apps 0.7.0` (the ADK holding `network_helpers` +
`key_utils`) currently **git-pins `stratum-core` to branch=main** and is not cleanly
crates.io-consumable ("MUST be changed before stratum-apps is published"). Buildable
options: (a) mirror SRI — git-pin `stratum-apps`; or (b) skip it, use standalone
`network_helpers_sv2` / `key_utils` (compat with channels_sv2 v7 UNVERIFIED), or drive
`codec_sv2` + tokio TCP directly.

## Exact struct definitions (docs.rs, verbatim)

```rust
// common_messages_sv2 8.0.0
pub struct SetupConnection<'d> {
    pub protocol: Protocol, pub min_version: u16, pub max_version: u16, pub flags: u32,
    pub endpoint_host: Str0255<'d>, pub endpoint_port: u16,
    pub vendor: Str0255<'d>, pub hardware_version: Str0255<'d>,
    pub firmware: Str0255<'d>, pub device_id: Str0255<'d>,
}
// mining_sv2 11.0.0 — nominal_hash_rate is PLAIN f32 (not an F32 wrapper); max_target is U256
pub struct OpenExtendedMiningChannel<'d> {
    pub request_id: u32, pub user_identity: Str0255<'d>,
    pub nominal_hash_rate: f32, pub max_target: U256<'d>, pub min_extranonce_size: u16,
}
pub struct OpenExtendedMiningChannelSuccess<'d> {
    pub request_id: u32, pub channel_id: u32, pub target: U256<'d>,
    pub extranonce_size: u16, pub extranonce_prefix: B032<'d>, pub group_channel_id: u32,
}
pub struct NewExtendedMiningJob<'d> {
    pub channel_id: u32, pub job_id: u32, pub min_ntime: Sv2Option<'d,u32>, pub version: u32,
    pub version_rolling_allowed: bool, pub merkle_path: Seq0255<'d,U256<'d>>,
    pub coinbase_tx_prefix: B064K<'d>, pub coinbase_tx_suffix: B064K<'d>,
}
pub struct SubmitSharesExtended<'d> {
    pub channel_id: u32, pub sequence_number: u32, pub job_id: u32,
    pub nonce: u32, pub ntime: u32, pub version: u32, pub extranonce: B032<'d>,
}
```

Construction idioms: `Vec<u8>.try_into()` → `U256`/`B032`; `&str.try_into()` → `Str0255`.
`max_target: vec![0xFF_u8; 32].try_into().unwrap()`.

## channels_sv2 7.0.0 — the reuse win (source-verified signatures)

```rust
ExtendedChannel::new(
    channel_id: u32, user_identity: String /* std String, NOT Str0255 */,
    extranonce_prefix: ExtranoncePrefix, target: bitcoin::Target,
    nominal_hashrate: f32, version_rolling: bool, rollable_extranonce_size: u16,
) -> Self
fn validate_share(&mut self, share: SubmitSharesExtended)
    -> Result<ShareValidationResult, ShareValidationError>   // requires set_chain_tip first, else NoChainTip
fn on_new_extended_mining_job(&mut self, job: NewExtendedMiningJob<'a>) -> Result<(),ExtendedChannelError>
fn on_set_new_prev_hash(&mut self, p: SetNewPrevHashMp<'a>) -> Result<(),ExtendedChannelError>
fn set_chain_tip(&mut self, chain_tip: ChainTip)

// standalone free fn
merkle_root_from_path<T: AsRef<[u8]>>(cb_prefix: &[u8], cb_suffix: &[u8],
    extranonce: &[u8], path: &[T]) -> Option<Vec<u8>>

ExtranoncePrefix::from_wire(prefix: Vec<u8>) -> Result<Self, ExtranoncePrefixError>

enum ShareValidationResult { Valid(sha256d::Hash), BlockFound(sha256d::Hash) }
enum ShareValidationError { Invalid, Stale, InvalidJobId, DoesNotMeetTarget,
    VersionRollingNotAllowed, BadExtranonceSize, NoChainTip, DuplicateShare }
```

`validate_share` **internally** calls `merkle_root_from_path` over the coinbase halves +
extranonce + merkle_path, rebuilds the `bitcoin::block::Header`, and compares
`Target::from_compact(nbits)` (network) + job target. So it does the full
coinbase→merkle→target check for you.

## Frame build/parse idioms (verbatim from mining_device)

```rust
type Message = MiningDeviceMessages<'static>;
type StdFrame = StandardSv2Frame<Message>;
type EitherFrame = StandardEitherFrame<Message>;

// connect + Noise
let initiator = Initiator::new(pub_key.map(|e| e.0)); // Option<Secp256k1PublicKey>; None = don't verify cert
let (receiver, sender) = Connection::new(socket, HandshakeRole::Initiator(initiator)).await.unwrap();

// build + send
let f: StdFrame = MiningDeviceMessages::Common(setup.into()).try_into().unwrap();
sender.send(f.into()).await.unwrap();
let f: StdFrame = MiningDeviceMessages::Mining(Mining::OpenExtendedMiningChannel(open)).try_into().unwrap();

// receive + parse — the (message_type, payload).try_into() idiom
let mut inc: StdFrame = receiver.recv().await.unwrap().try_into().unwrap();
let mt = inc.get_header().unwrap().msg_type();        // u8
let payload = inc.payload();                          // &mut [u8]
let m: Mining = (mt, payload).try_into()?;            // Err = parsers_sv2::ParserError::UnexpectedMessage(u8)
```

## UNVERIFIED (do not treat as final)

1. U256(LE wire)→`bitcoin::Target` exact helper name (source uses `Target::from_le_bytes`
   internally; `channels_sv2::target` has conversion helpers).
2. `.into_static()` vs `.as_static()` to lift a borrowed message to `'static` for
   `on_new_extended_mining_job` / `on_set_new_prev_hash`.
3. `SetNewPrevHash` vs `SetNewPrevHashMp` importable name (docs render the param as `...Mp`).
4. `ChainTip` constructor (from prev_hash+nbits+ntime); `on_set_new_prev_hash` may set it
   internally.
5. Extended-channel `SetupConnection.flags` bit (SRI's `0b...0001` = REQUIRES_STANDARD_JOBS,
   which is the *wrong* one for extended — check `mining_sv2` flag consts).
6. Standalone `network_helpers_sv2 4.0.1` / `key_utils` crate compat with channels_sv2 v7.

## Takeaway

All prior-round version pins CONFIRMED and on crates.io. The reference `mining_device`
uses a STANDARD channel + no client-side validation; for this task, open an EXTENDED
channel and use `ExtendedChannel::validate_share` (or raw `merkle_root_from_path`).
