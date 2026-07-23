---
title: "Plan: small daemon that reconstructs the coinbase tx and checks validity + pays-to-address"
type: plan
format: roadmap
sources:
  - wiki/concepts/sv2-mining-client-message-flow.md
  - wiki/concepts/standard-vs-extended-channels-coinbase-visibility.md
  - wiki/concepts/coinbase-reconstruction-and-merkle-fold.md
  - wiki/concepts/coinbase-transaction-anatomy.md
  - wiki/concepts/expected-value-checks-taxonomy.md
  - wiki/concepts/sri-client-crate-stack.md
  - wiki/topics/reference-implementation-skeleton.md
  - wiki/concepts/sourcing-the-expected-value.md
  - wiki/topics/what-the-daemon-can-and-cannot-prove.md
generated: 2026-07-21
---

# Plan: small daemon — reconstruct coinbase, check valid + pays-to-address

> Generated from [sv2-coinbase-verify-daemon](../_index.md) wiki (9 articles consulted)

## Executive Summary

Build `cbcheck` — a **small, single-purpose SV2 client daemon** that connects to a
Stratum V2 pool on an **extended channel**, receives one `NewExtendedMiningJob`,
reconstructs the coinbase transaction, verifies it is **structurally valid and
merkle-consistent** with the job, and asserts that **one of its outputs pays a configured
address**. It prints a verdict and exits `0` (match) / `1` (mismatch/invalid) — a
CI/cron-friendly one-shot, with a clean upgrade path to `--watch`.

**Key design decisions (all wiki-grounded):**
- **Extended channel, not standard** — only `NewExtendedMiningJob` carries the coinbase
  bytes; a standard channel exposes only an opaque merkle root, so there would be nothing
  to check.
- **Be its own SV2 client, not a sniffer** — SV2 is Noise-encrypted end-to-end; a direct
  client holds the session keys by construction.
- **Reuse SRI `channels_sv2`** — `merkle_root_from_path` and the `bitcoin` crate do the
  coinbase/merkle/address math; the daemon is mostly glue.
- **"Valid" = standalone structural + merkle** — no bitcoind, no fee oracle. The daemon
  proves *this job's* coinbase is well-formed, folds to the header merkle root, and pays
  the expected address. It does **not** claim consensus-value validity or that this job
  is what gets mined (explicitly out of scope).

## Scope

**In scope:** connect + Noise handshake; `SetupConnection`; `OpenExtendedMiningChannel`;
receive `NewExtendedMiningJob` + `SetNewPrevHash`; reconstruct coinbase; structural parse;
merkle-fold integrity check; address→scriptPubKey match; verdict + exit code.

**Out of scope (deliberately):** share submission / actual mining; value-vs-subsidy+fees
consensus check; witness-commitment validation; on-chain correlation; job-swap/withholding
detection; multi-pool. (These are the broader-watchdog features documented in the wiki and
listed as upgrade paths.)

## Architecture Decisions

### Decision 1: Extended channel (not standard)
**Context**: [standard-vs-extended-channels-coinbase-visibility](../wiki/concepts/standard-vs-extended-channels-coinbase-visibility.md)
documents that `NewMiningJob` (standard channel) carries only an opaque `merkle_root`
(U256), while `NewExtendedMiningJob` carries `coinbase_tx_prefix` / `coinbase_tx_suffix` /
`merkle_path`.
**Options considered**:
- Standard channel — smaller, but **structurally cannot see the coinbase**; a coinbase
  check is impossible.
- Extended channel — receives the raw coinbase halves; the only path that works.
**Decision**: Extended channel. Send `OpenExtendedMiningChannel`; the check depends on
`coinbase_tx_prefix`/`suffix` being on the wire.
**Consequences**: Must handle `extranonce_prefix`/`extranonce_size` from
`OpenExtendedMiningChannelSuccess`; must set the extended-channel `SetupConnection.flags`
correctly (NOT `REQUIRES_STANDARD_JOBS` — see Open Questions).

### Decision 2: Be its own SV2 client (not a sniffer/MITM)
**Context**: [sri-client-crate-stack](../wiki/concepts/sri-client-crate-stack.md) and
[reference-implementation-skeleton](../wiki/topics/reference-implementation-skeleton.md)
establish that SV2 is Noise_NX + AEAD encrypted end-to-end; `stratum-sniffer` only works
as an active MITM with its own hardcoded keypair (the miner must trust it).
**Options considered**:
- Passive tap / sniffer — reads only ciphertext without keys; requires MITM position.
- Direct SV2 client — completes the handshake itself, holds session keys by construction.
**Decision**: Direct client. Dial the pool as a legitimate SV2 client; optionally pin the
pool's authority pubkey via `Initiator::new(Some(pk))`.
**Consequences**: No decryption problem; the daemon needs the pool URL + (optionally) the
pool authority pubkey; it appears to the pool as a (non-hashing) miner connection.

### Decision 3: Reuse SRI `channels_sv2` for the crypto
**Context**: [coinbase-reconstruction-and-merkle-fold](../wiki/concepts/coinbase-reconstruction-and-merkle-fold.md)
+ [sri-client-crate-stack](../wiki/concepts/sri-client-crate-stack.md): SRI ships
`channels_sv2::merkle_root::merkle_root_from_path(prefix, suffix, extranonce, path) ->
Option<Vec<u8>>` (depends only on `bitcoin` + `alloc`), and `ExtendedChannel` wraps job
storage.
**Options considered**:
- Reuse `channels_sv2` (via `stratum-core`) — least code, correct merkle math.
- Hand-roll `codec_sv2` + own merkle fold — fewer deps, avoids the `stratum-apps` git-pin,
  but re-implements double-SHA256 folding (bug surface).
**Decision**: Reuse `channels_sv2` via `stratum-core 0.5`; call `merkle_root_from_path`
directly for the integrity check and `bitcoin::consensus::deserialize::<Transaction>` for
the structural/address check. Accept the `stratum-apps` git-pin caveat for
`network_helpers`.
**Consequences**: Depends on `stratum-core 0.5` (crates.io) + git-pinned `stratum-apps`
(per the wiki's documented posture). If the git-pin is undesirable, Decision 3's runner-up
(hand-rolled `codec_sv2` + own `Connection`) is the fallback.

### Decision 4: "Valid" = standalone structural + merkle-consistent
**Context**: [expected-value-checks-taxonomy](../wiki/concepts/expected-value-checks-taxonomy.md)
(check (a) pays-expected-SPK, check (e) merkle integrity) and
[sourcing-the-expected-value](../wiki/concepts/sourcing-the-expected-value.md) (fees need a
Template Provider; subsidy computable from height).
**Options considered**:
- Structural + merkle only — no bitcoind; provable client-side.
- + value floor vs subsidy — cheap add, partial (no fees).
- Full consensus validity — needs own bitcoind + SV2 TP; contradicts "small daemon."
**Decision**: Structural + merkle only (per interview). "Valid" means: parses as a coinbase
(single input, null prevout `00..00`/`ffffffff`, BIP34 height as first scriptSig push,
≥1 well-formed output, sane locktime) AND `merkle_root_from_path(...)` equals the merkle
root of the header the job is asking the miner to hash.
**Consequences**: The daemon does NOT verify total value = subsidy+fees or the witness
commitment. State this in output. Value-floor and full-consensus are documented upgrade
paths.

### Decision 5: Single address, any type, via `bitcoin::Address`
**Context**: [coinbase-transaction-anatomy](../wiki/concepts/coinbase-transaction-anatomy.md)
(outputs = `value` + `scriptPubKey`); rust-bitcoin 0.32.5 `Address` type-state API.
**Decision**: Config takes one address string. Parse
`addr.parse::<Address<NetworkUnchecked>>()?.require_network(net)?.script_pubkey()` → the
expected `ScriptBuf`; match if **any** coinbase output's `script_pubkey` equals it. Handles
P2WPKH/P2TR (bech32/bech32m), P2PKH, P2SH uniformly.
**Consequences**: Need a `--network` flag (mainnet/testnet4/signet/regtest) for
`require_network`. Upgrade path: address allowlist (interview runner-up) is a `Vec<ScriptBuf>`
contains-check.

## Implementation Phases

### Phase 0: Project + config skeleton (effort: ~0.5 day)
**Goal**: A buildable crate with CLI config, no protocol yet.
**Tasks**:
- [ ] `cargo new cbcheck`; add deps: `stratum-core = "0.5"` (feature `with_buffer_pool`),
  `stratum-apps` (git-pinned, features `network`,`config`), `tokio` (full),
  `async-channel`, `clap` (derive), `tracing`+`tracing-subscriber`, `anyhow`, `hex`.
- [ ] `clap` args: `--pool <host:port>`, `--address <addr>`, `--network <mainnet|testnet4|signet|regtest>`,
  `--pool-pubkey <base58>` (optional), `--user-identity <str>` (default `cbcheck.1`),
  `--watch` (bool, default false), `-v`.
- [ ] Parse `--address` → `Address<NetworkUnchecked>` → `require_network` → `expected_spk: ScriptBuf`. Fail fast on bad address/network.
**Dependencies**: none.
**Validation**: `cbcheck --address bc1... --network mainnet --pool x:y` parses config and
prints the derived scriptPubKey hex; exits.
**Wiki grounding**: dep set + versions from [reference-implementation-skeleton](../wiki/topics/reference-implementation-skeleton.md)
and [sri-client-crate-stack](../wiki/concepts/sri-client-crate-stack.md).

### Phase 1: Connect + open extended channel (effort: ~1–1.5 days)
**Goal**: Complete the Noise handshake, `SetupConnection`, and open an extended channel.
**Tasks**:
- [ ] TCP connect; `Initiator::new(pool_pubkey.map(|k| k.0))`; `Connection::new(socket,
  HandshakeRole::Initiator(..))` → `(Receiver<EitherFrame>, Sender<EitherFrame>)`.
- [ ] Define frame aliases (`Message`/`StdFrame`/`EitherFrame`).
- [ ] Send `SetupConnection { protocol: MiningProtocol, min_version:2, max_version:2, flags, .. }`;
  await `SetupConnectionSuccess`.
- [ ] Send `OpenExtendedMiningChannel { request_id, user_identity, nominal_hash_rate: 0.0
  (or nominal), max_target: 0xFF..FF, min_extranonce_size }`; await
  `OpenExtendedMiningChannelSuccess` → capture `channel_id`, `extranonce_prefix`,
  `extranonce_size`.
- [ ] Build the receive loop using the `(message_type, payload).try_into() -> Mining` idiom.
**Dependencies**: Phase 0.
**Validation**: Against SRI `pool_sv2` (or a testnet4 pool) on regtest/testnet, the daemon
reaches `OpenExtendedMiningChannelSuccess` and logs the channel_id + extranonce params.
**Wiki grounding**: message order from [sv2-mining-client-message-flow](../wiki/concepts/sv2-mining-client-message-flow.md);
exact structs/idioms from [reference-implementation-skeleton](../wiki/topics/reference-implementation-skeleton.md).
**Risk flag**: resolve the extended-channel `flags` bit (Open Questions #1) here.

### Phase 2: Receive job + reconstruct coinbase (effort: ~1 day)
**Goal**: On `NewExtendedMiningJob` (+ `SetNewPrevHash`), assemble the coinbase bytes.
**Tasks**:
- [ ] Handle `NewExtendedMiningJob` → store `coinbase_tx_prefix`, `coinbase_tx_suffix`,
  `merkle_path`, `version`. Handle `SetNewPrevHash` → store `prev_hash`, `nbits`, `min_ntime`
  and mark the job active.
- [ ] Choose an extranonce (zeros of length `extranonce_size` is fine — we're not searching).
- [ ] `full_extranonce = extranonce_prefix ‖ extranonce`.
- [ ] `coinbase_bytes = coinbase_tx_prefix ‖ full_extranonce ‖ coinbase_tx_suffix`.
**Dependencies**: Phase 1.
**Validation**: Log the reconstructed coinbase hex length; `bitcoin::consensus::deserialize::<Transaction>`
succeeds on it (round-trips).
**Wiki grounding**: assembly rule + byte order from
[coinbase-reconstruction-and-merkle-fold](../wiki/concepts/coinbase-reconstruction-and-merkle-fold.md).

### Phase 3: The check — validity + pays-to-address (effort: ~1 day)
**Goal**: The core deliverable.
**Tasks**:
- [ ] **Structural validity**: deserialize to `bitcoin::Transaction`; assert single input,
  prevout = null (`OutPoint::null()`-like: txid all-zero, vout `0xFFFFFFFF`); first scriptSig
  push is a BIP34 height; ≥1 output; each output `value`/`script_pubkey` well-formed.
- [ ] **Merkle integrity**: `merkle_root_from_path(prefix, suffix, full_extranonce,
  &merkle_path)` → compare to the merkle root implied by the job/header. (Equivalently,
  call `ExtendedChannel::validate_share` with a dummy share and accept
  `DoesNotMeetTarget` as "coinbase/merkle OK, PoW just insufficient".)
- [ ] **Address match**: `tx.output.iter().any(|o| o.script_pubkey == expected_spk)`.
- [ ] Verdict struct: `{ valid_structure, merkle_ok, pays_expected_address, matched_vout,
  matched_value_sat, coinbase_txid }`.
**Dependencies**: Phase 2.
**Validation**: Unit tests with fixture jobs — a coinbase paying the address (PASS), one
paying a different address (FAIL address), a corrupted `merkle_path` (FAIL merkle), a
malformed coinbase (FAIL structure). Use real testnet4 coinbases as fixtures.
**Wiki grounding**: checks (a) + (e) from [expected-value-checks-taxonomy](../wiki/concepts/expected-value-checks-taxonomy.md);
coinbase field layout from [coinbase-transaction-anatomy](../wiki/concepts/coinbase-transaction-anatomy.md).

### Phase 4: Verdict output, exit codes, `--watch` (effort: ~0.5 day)
**Goal**: One-shot CI/cron ergonomics + upgrade hook.
**Tasks**:
- [ ] One-shot (default): on the first fully-active job, run the check, print a structured
  line (human + `--json`), exit `0` (pays expected + valid) / `1` (mismatch or invalid) /
  `2` (protocol/connection error).
- [ ] `--watch`: keep the loop; check every `NewExtendedMiningJob`; log OK/MISMATCH; keep a
  nonzero-on-any-mismatch flag; optional `--exit-on-mismatch`.
- [ ] `--timeout <secs>` so one-shot can't hang forever waiting for a job.
**Dependencies**: Phase 3.
**Validation**: Exit codes verified in a shell harness; `--json` parses; `--watch` survives
multiple jobs and a `SetNewPrevHash`.
**Wiki grounding**: honest verdict wording from
[what-the-daemon-can-and-cannot-prove](../wiki/topics/what-the-daemon-can-and-cannot-prove.md).

### Phase 5 (optional upgrades, not MVP)
- Value floor vs subsidy from height ([sourcing-the-expected-value](../wiki/concepts/sourcing-the-expected-value.md)).
- Address allowlist; deviation/job-diff + on-chain correlation
  ([deviation-detection](../wiki/concepts/deviation-detection.md)); metrics endpoint.

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| Pool only offers **standard** channels → no coinbase visible | [standard-vs-extended-channels-coinbase-visibility](../wiki/concepts/standard-vs-extended-channels-coinbase-visibility.md) | Detect if only `NewMiningJob` arrives; exit with a clear "pool gave standard jobs, coinbase not inspectable" error (exit 2). |
| `stratum-apps` git-pin makes a pure crates.io build awkward | [reference-implementation-skeleton](../wiki/topics/reference-implementation-skeleton.md) | Git-pin `stratum-apps` (mirror SRI), or take Decision 3's fallback (hand-rolled `codec_sv2` + own `Connection`) to stay crates.io-only. |
| UNVERIFIED API details (U256→Target, `.into_static()`/`.as_static()`, `SetNewPrevHashMp` name, `ChainTip` ctor, extended flag bit) | [reference-implementation-skeleton](../wiki/topics/reference-implementation-skeleton.md) | Resolve against docs.rs/source in Phase 1; prefer the raw `merkle_root_from_path` free fn over `ExtendedChannel::validate_share` to sidestep `ChainTip`/`Target` construction entirely. |
| **Over-claiming**: "valid + pays address" ≠ trustless proof | [what-the-daemon-can-and-cannot-prove](../wiki/topics/what-the-daemon-can-and-cannot-prove.md), [coinbase-verification-trust-model-limits](../wiki/concepts/coinbase-verification-trust-model-limits.md) | Verdict text states it proves only *this job's* coinbase as served to *this* client — not what's mined/broadcast, not other miners' jobs. |
| Address in the miner-rolled **extranonce** window mistaken for fixed | [expected-value-checks-taxonomy](../wiki/concepts/expected-value-checks-taxonomy.md) | Payout outputs live in `coinbase_tx_suffix`; match on parsed `tx.output`, never on raw prefix/extranonce bytes. |
| Wrong `--network` → `require_network` rejects a valid address, or SPK mismatch | rust-bitcoin 0.32.5 Address API | Fail fast at config parse; document that `--network` must match the pool's chain. |

## Open Questions

1. **Extended-channel `SetupConnection.flags` bit** — SRI's example sets bit0
   (`REQUIRES_STANDARD_JOBS`), which is wrong here. Confirm the correct flags value (likely
   0, or a work-selection bit) against `mining_sv2` flag constants in Phase 1. *(UNVERIFIED
   in wiki.)*
2. **Merkle-root comparison target** — `NewExtendedMiningJob` gives coinbase halves +
   `merkle_path` but not a precomputed merkle root; the integrity check compares
   `merkle_root_from_path(..)` against the root the daemon *would* place in the header.
   Decide whether to (a) just recompute and treat a successful fold as "consistent," or (b)
   compare against an independently known root. For a standalone daemon, (a) is sufficient.
3. **Does the pool accept a zero-hashrate / non-submitting connection** long enough to emit
   a job? If a pool drops idle channels, `--watch` may need periodic keep-alive; verify
   against the target pool.
4. **Testnet4 vs signet target** for validation — which pool/chain to point at for the
   Phase 3 fixtures. (Suggest testnet4 via a public SV2 pool, or a local SRI `pool_sv2` +
   `sv2-tp` on regtest.)

## Sources Consulted

- [sv2-mining-client-message-flow](../wiki/concepts/sv2-mining-client-message-flow.md) — connect/handshake/open-channel/job ordering.
- [standard-vs-extended-channels-coinbase-visibility](../wiki/concepts/standard-vs-extended-channels-coinbase-visibility.md) — why extended is mandatory.
- [coinbase-reconstruction-and-merkle-fold](../wiki/concepts/coinbase-reconstruction-and-merkle-fold.md) — reconstruction + merkle algorithm.
- [coinbase-transaction-anatomy](../wiki/concepts/coinbase-transaction-anatomy.md) — coinbase field layout for structural + address checks.
- [expected-value-checks-taxonomy](../wiki/concepts/expected-value-checks-taxonomy.md) — checks (a) address + (e) merkle integrity.
- [sri-client-crate-stack](../wiki/concepts/sri-client-crate-stack.md) — minimal crates, `merkle_root_from_path`, be-your-own-client.
- [reference-implementation-skeleton](../wiki/topics/reference-implementation-skeleton.md) — verified versions, struct signatures, UNVERIFIED list.
- [sourcing-the-expected-value](../wiki/concepts/sourcing-the-expected-value.md) — subsidy/fees (informs the value-floor upgrade).
- [what-the-daemon-can-and-cannot-prove](../wiki/topics/what-the-daemon-can-and-cannot-prove.md) — trust-model scoping for verdict wording.
- rust-bitcoin 0.32.5 `Address` docs (gap-fill) — `parse → require_network → script_pubkey`.
