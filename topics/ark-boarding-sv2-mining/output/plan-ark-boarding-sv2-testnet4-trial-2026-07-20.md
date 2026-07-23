---
title: "Plan: Minimal covenantless Ark-boarding SV2 extension — testnet4 real-hashrate trial"
type: plan
format: roadmap
sources:
  - topics/ark-boarding-sv2-mining/theses/ark-boarding-sv2-mining.md
  - topics/ark-boarding-sv2-mining/wiki/topics/thesis-analysis-viability.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/post-block-found-signing.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/covenantless-batch-output-mechanics.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/coinbase-maturity-and-reorg.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/sv2-extension-surface.md
  - topics/ark-boarding-sv2-mining/wiki/concepts/pure-receiver-and-liveness.md
  - topics/covenantless-ark/wiki/topics/clark-round-transaction-mechanics.md
  - topics/covenantless-ark/wiki/concepts/tree-presigning-musig2.md
  - topics/covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md
  - topics/musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md
generated: 2026-07-20
scope: small-signer-set (n=2-5), proxy/JDC-held keys, post-block-found trigger
verdict_basis: "Partially Supported / Medium — viable at small-signer-set/proxy-delegated scale"
---

# Plan: Minimal covenantless Ark-boarding SV2 extension — testnet4 real-hashrate trial

> Generated from the [ark-boarding-sv2-mining](../_index.md) wiki (7 topic articles),
> grounded in [covenantless-ark](../../covenantless-ark/_index.md) and
> [musig2-signing-ceremonies](../../musig2-signing-ceremonies/_index.md), plus a
> direct read of the `demand-share-accounting-ext` source and the local
> `stratum` / `bark` / `sv2-tp` checkouts.

## Executive Summary

Build and trial on **testnet4 with real hashrate** the *narrow, defensible* slice
of the thesis: an SRI-based SV2 pool running `demand-share-accounting-ext` that,
when it finds a testnet4 block (or on a faucet-funded fallback), runs a **small
n-of-n (2–5 party) MuSig2 cosigning ceremony over the mining connection** to board
miners into VTXOs inside a **Taproot n-of-n batch output** — using only Taproot +
MuSig2 + CSV/CLTV, **no CTV/CSFS/APO**. The ceremony is triggered by the existing
`NewBlockFound (0x03)` message and carried by **new extension messages `0x11–0x18`**
slotted alongside the current `0x00–0x10`.

Three design commitments (from the wiki verdict and your decisions) keep the trial
inside the regime that is actually viable rather than the pool-scale claim the
verdict rejects:

1. **Signer set = Pool(S) + 1–4 JDC/proxy cosigners; keys live on the proxy, never
   the ASIC.** The continuously-online party in SV2 is the lightweight proxy/JDC,
   which is where the ~seconds MuSig2 ceremony runs.
2. **Two measured funding variants.** *Primary:* board a **matured proxy UTXO**
   (≥100 blocks deep) to dodge the maturity/reorg wall. *Failure-mode demo:* fund
   the batch from the **fresh coinbase** to deliberately exercise the 100-block
   non-includability + reorg-voids-batch behavior (Phase 5 / Phase 6).
3. **Dropout = atomic abort + identify (`PartialSigVerify`) + ban-by-pool-identity
   + retry with fresh nonces.** MuSig2 is non-robust; this is the prescribed policy
   and demonstrates the thesis's strongest original argument (miner stake/identity
   blunts the pure-receiver DoS).

The deliverable is this plan; execution is a separate step. Effort estimates assume
one engineer already fluent in the SRI stack.

**Load-bearing correction discovered during planning:** MuSig2 in Rust is available
in the **mainline `secp256k1` crate `0.32.0-beta.2`** `musig` module (as used by the
local `bark` checkout) — *not* only the `secp256k1-zkp` binding the wiki cited. Build
the ceremony against `secp256k1::musig`.

## Architecture Decisions

### Decision 1: Trigger the ceremony *after* block-found, sign over a known outpoint

**Context**: [post-block-found-signing](../wiki/concepts/post-block-found-signing.md)
establishes the load-bearing insight — BIP-341's sighash commits to the input
outpoint, and a coinbase txid is unknown pre-block but *frozen the instant a valid
block exists*. So an ordinary MuSig2 signature over a tx spending the coinbase is
fully constructible post-block-found, with no rebindable-signature primitive.

**Options considered**:
- **Presign before the block** (per [coinbase-outpoint-presigning] wall) — requires
  APO/CTV; violates the covenantless constraint. Rejected.
- **Post-block-found signing** — "just wait" until the outpoint exists, then sign.

**Decision**: Post-block-found. The `NewBlockFound (0x03)` message this repo already
ships is the natural trigger ([sv2-extension-surface](../wiki/concepts/sv2-extension-surface.md)).

**Consequences**: The whole extension hangs off the `0x03` event. On testnet4 the
outpoint is known within one block; the ceremony must complete before the funds
must be usable (see Decision 3 for why maturity is handled separately).

### Decision 2: n-of-n batch output = `pk(S+A+…) OR (pk(S) AND after(T))`, presign + delete

**Context**: [covenantless-batch-output-mechanics](../wiki/concepts/covenantless-batch-output-mechanics.md)
and [tree-presigning-musig2](../../covenantless-ark/wiki/concepts/tree-presigning-musig2.md)
give the exact CTV substitute: a Taproot output whose cooperative **key-path** is an
n-of-n MuSig2 aggregate, plus a **script-path** timeout (`pk(S) AND after(T)`). The
tree is presigned and each cosigner deletes an **ephemeral per-round key**; security
= **1-of-n honest deletion**.

**Options considered**:
- **Full VTXO tree (radix 2/4, à la arkd/bark)** — general, but heavy for n≤5.
- **Flat / depth-1 tree** — for n≤5 the "tree" is one batch output splitting to n
  leaves; trivial to build and to exit.

**Decision**: **Depth-1 (flat) tree** for the trial. Each of the n boarding miners
gets one leaf VTXO directly under the batch root. This is faithful to the mechanics
while keeping the tree builder to a few dozen lines. Keep the code shaped so a
recursive tree could replace it later.

**Consequences**: Unilateral exit is a 2-tx chain (batch→leaf, then claim after
CSV) rather than O(log n) levels — simpler to demonstrate in Phase 4. Per-round
**ephemeral cosigner keys** must be generated fresh and provably deleted (Phase 3).

### Decision 3: Board a MATURED proxy UTXO (primary); demo fresh-coinbase as the failure mode

**Context**: [coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md)
— if the batch *is* the fresh coinbase, the tree is non-includable for 100 blocks
(~16.7 h) and a reorg voids the entire batch and every VTXO under it. The verdict's
workable design boards a **matured UTXO** so the ceremony runs over funds that
cannot be reorged away; `NewBlockFound` still *schedules* the payout.

**Decision** (your call): **run both as measured variants.** Primary path boards a
matured proxy UTXO (≥100 confirmations, sourced from an earlier testnet4 coinbase or
a faucet); the second run funds from the fresh coinbase to explicitly measure and
demonstrate the maturity + reorg failure mode.

**Consequences**: Two funding code paths and a "funding source" config knob. The
fresh-coinbase run needs a controllable reorg on testnet4 (invalidateblock) to show
batch voiding (Phase 5). Presigned txs are fixed-fee → need a **P2A anchor + CPFP**
for fee-bumping (all available today).

### Decision 4: Signer set = Pool(S) + 1–4 JDC/proxy cosigners; keys on the proxy

**Context**: [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md)
— the continuously-online SV2 party is the lightweight proxy/JDC, *not* the ASIC.
n-of-n does not scale (Braidpool caps ~50), so the trial deliberately fixes **n =
2–5**. The cosigning key lives on the proxy device.

**Decision** (your call): **Pool + JDC/proxy(s).** S = pool; the other 1–4 parties
are JDC/proxy processes each holding one cosigning key on the proxy, never on the
hashboard. For a first smoke test the proxies may be co-located processes; the wire
protocol is identical whether they are local or remote.

**Consequences**: Liveness rests on proxy infrastructure (a trust concession the
verdict names explicitly). Ceremony latency (Phase 6) is measured proxy-to-pool, not
ASIC-to-pool.

### Decision 5: Dropout policy = abort-all + identify + ban + retry (fresh nonces)

**Context**: [musig2-interactive-signing-ceremonies](../../musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md)
— MuSig2 is **non-robust**: one dropout aborts the ceremony. `PartialSigVerify`
gives **identifiable abort**; every retry **must use fresh nonces** (reusing an
aborted round's nonce is the nonce-reuse catastrophe → key leak).

**Decision** (your call): abort the round with no on-chain footprint, attribute the
culprit via partial-sig verification, **ban by pool identity**, retry with the
remaining set and freshly generated nonces.

**Consequences**: A ban list keyed by SV2 identity, a ceremony state machine with an
explicit `Aborted` state, and a hard rule that `SecNonce` is single-use and zeroized.
This is the concrete demonstration of the thesis's strongest original claim (stake +
identity + bans blunt the free-receiver-DoS asymmetry).

## Repositories in play

| Repo | Local path | Role in this trial |
|---|---|---|
| `demand-share-accounting-ext` | `~/repos/share-accounting-ext` (this repo) | New Ark-boarding extension messages, ceremony types, batch-output scripts |
| `demand-open-source/stratum` fork | `~/repos/stratum` (`average-gary`/`ethan` remotes) | Ceremony state machine, message handlers, key custody in pool + JDC/proxy roles |
| SV2 apps (pool/JDS/JDC) | `~/repos/sv2-apps` (+ many worktrees) | The running SRI roles that host the extension |
| Template Provider | `~/repos/sv2-tp` (Sjors C++) or `~/repos/rust-sv2-template-provider` (Rust drop-in) | testnet4 block templates over IPC to bitcoind |
| testnet4 bitcoind | `~/repos/bitcoind-testnet4-startos` (packaging ref) | The node; source of coinbase + reorg control |
| `bark` | `~/repos/bark` | **Reference** for `secp256k1::musig` API usage + tree/exit shapes (do not depend on; read) |
| `ark-settler` | `~/repos/ark-settler` | **Reference** for weighted allocation + dust filtering; note it uses a *delegated* external ASP, unlike this pool-runs-ceremony design |

## Implementation Phases

### Phase 1: testnet4 environment + real hashrate (estimated effort: 3–5 days)

**Goal**: A running SRI stack on testnet4 that (a) actually finds testnet4 blocks
with real hashrate, and (b) has a faucet-funded-UTXO fallback to exercise the
ceremony when block-finding is slow.

**Key enabling fact (gap-filled 2026-07-20)**: BIP-94 **preserves testnet4's
20-minute minimum-difficulty rule** — if a block's timestamp is >20 min past the
previous block, it may be mined at *minimum* difficulty regardless of network
difficulty. So a Bitaxe (or even CPU) **can** find a testnet4 block after any 20-min
gap. BIP-94 also fixes timewarp (first block of each 2016-period must be ≥ prior
nTime − 600 s) and takes the retarget base difficulty from the *first* block of the
previous period, preventing the testnet3 block-storm exploit. Practical consequence:
real-hashrate block-finding is a realistic trial input, not a fantasy — but cadence
is bursty (min-difficulty blocks cluster), so the faucet fallback is still needed for
deterministic ceremony runs.

**Tasks**:
- [ ] Run `bitcoind -testnet4` with `-server -txindex`, IPC/`-ipcbind` enabled for
      the Template Provider. Reference packaging: `~/repos/bitcoind-testnet4-startos`.
- [ ] Stand up the Template Provider: start with Sjors C++ `~/repos/sv2-tp` (the
      known-good path); keep `~/repos/rust-sv2-template-provider` as a drop-in
      alternative to try.
- [ ] Bring up SRI **Pool + JDS + JDC** from `~/repos/sv2-apps` pointed at the TP and
      testnet4. Confirm `demand-share-accounting-ext` activates (`Activate` /
      `Activate.Success`) over the mining connection.
- [ ] Attach **real hashrate**: a Bitaxe (preferred) or `cpuminer`
      (`~/repos/cpuminer`) as an SV1→SV2 translated downstream, hashing testnet4
      templates. Verify shares flow and `ShareOk (0x02)` returns.
- [ ] Confirm end-to-end: pool emits `NewBlockFound (0x03)` when the stack mines a
      testnet4 block (real or via a locally forced min-difficulty block using the
      20-min gap).
- [ ] **Faucet fallback**: obtain a testnet4 UTXO from a faucet, age it ≥100 confs;
      wire a `--funding-source={coinbase|matured-utxo|faucet}` knob so the ceremony
      can be driven on demand without waiting for a block.

**Design decisions the research flagged**:
- *Fresh-coinbase vs matured-proxy-UTXO*: this phase provisions **both** (Decision 3).
  The faucet UTXO doubles as the matured-proxy-UTXO source.
- *Where the cosigning key lives*: the JDC/proxy processes, provisioned here with
  their own keypairs (Decision 4).

**Dependencies**: None (foundation).

**Validation**: `bitcoin-cli -testnet4 getblockchaininfo` synced; a share accepted
end-to-end; a `NewBlockFound` observed (forced min-difficulty block acceptable); a
≥100-conf UTXO controllable by the proxy set.

**Wiki grounding**: [sv2-extension-surface](../wiki/concepts/sv2-extension-surface.md)
(activation + `NewBlockFound` trigger); [coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md)
(why a matured UTXO is provisioned up front).

**Definition of done**: Real hashrate is hashing testnet4 templates through the SRI
stack; a `NewBlockFound (0x03)` fires on a found block; a ≥100-conf proxy-controlled
UTXO exists; the funding-source knob selects coinbase / matured-UTXO / faucet.

---

### Phase 2: New extension messages for nonce + partial-sig rounds (estimated effort: 4–6 days)

**Goal**: Wire the two MuSig2 rounds (plus session setup and abort) into the
extension as new messages `0x11–0x18`, fully parser/const-integrated alongside the
existing `0x00–0x10`, with round-trip encode/decode tests.

**Message-type & channel-bit allocation** (extends the table in `extension.md` §3;
`EXTENSION_TYPE` stays `32`; channel_bit `false` like every existing message — these
are connection-level, not per-channel):

| Type | Name | Dir | Payload (fields) |
|---|---|---|---|
| `0x11` | `BoardingRequest` | S→C | `request_id:U32`, `batch_id:U256`, `funding_outpoint:(U256 txid, U32 vout)`, `funding_value:U64`, `n_signers:U8`, `csv_delta:U32`, `expiry_abs:U32` |
| `0x12` | `BoardingCommit` | C→S | `request_id:U32`, `batch_id:U256`, `cosigner_pubkey:PubKey(B0255/32B)`, `vtxo_pubkey:PubKey`, `payout_value:U64` |
| `0x13` | `TreeNonces` | C→S | `batch_id:U256`, `signer_index:U8`, `pub_nonces:SEQ0_64K[B0255]` (one 66-B `PublicNonce` per tree tx) |
| `0x14` | `TreeNoncesAggregated` | S→C | `batch_id:U256`, `agg_nonces:SEQ0_64K[B0255]` (one `AggregatedNonce` per tree tx) |
| `0x15` | `TreePartialSigs` | C→S | `batch_id:U256`, `signer_index:U8`, `partial_sigs:SEQ0_64K[B0255]` (32-B `PartialSignature` per tree tx) |
| `0x16` | `TreeSignatures` | S→C | `batch_id:U256`, `final_sigs:SEQ0_64K[B0255]` (combined Schnorr sig per tree tx) → batch confirmed boardable |
| `0x17` | `BoardingComplete` | S→C | `batch_id:U256`, `batch_txid:U256`, `leaf_index:U8`, `exit_path:B0_16M` (client-side exit data to persist) |
| `0x18` | `CeremonyAbort` | S↔C | `batch_id:U256`, `reason:U8` (enum: timeout/bad-partial-sig/dropout/reorg), `culprit_index:U8` (0xff = none) |

Rationale for the round mapping: `0x13/0x14` = MuSig2 Round 1 (nonce exchange);
`0x15/0x16` = Round 2 (partial-sig exchange). **No commitment pre-round** — canonical
MuSig2 does not need one. This mirrors arkd's `TreeNonces → TreeNoncesAggregated →
TreeTx/TreeSignature` event sequence, coordinator-pushed by the pool.

**Concrete files to change — `demand-share-accounting-ext`**:
- `src/const.rs`: add `MESSAGE_TYPE_BOARDING_REQUEST = 0x11` … `MESSAGE_TYPE_CEREMONY_ABORT = 0x18` and matching `CHANNEL_BIT_* = false` consts.
- `src/boarding_request.rs`, `src/boarding_commit.rs`, `src/tree_nonces.rs`, `src/tree_partial_sigs.rs`, `src/boarding_complete.rs`, `src/ceremony_abort.rs`: new message structs. Follow the exact pattern in `src/new_block_found.rs` (simple `#[repr(C)]` + `Serialize/Deserialize` + `with_serde` `GetSize`); for the SEQ-of-blob fields, follow `src/data_types/share.rs` (`Seq064K`, manual `Sv2DataType`/`GetSize`/`GetMarker`).
- `src/data_types/mod.rs` (+ a new `src/data_types/musig.rs`): typed newtypes for `PubNonce`(66B), `AggNonce`(66B), `PartialSig`(32B), `SchnorrSig`(64B), `CosignerKey`(32B) over `B0255`/fixed arrays, so the wire types are self-documenting.
- `src/lib.rs`: `mod` + `pub use` each new message (mirror lines 6–30).
- `src/parser.rs`: add all six new variants to `ShareAccountingMessages` **and** to each of the six match arms — `message_type()`, `channel_bit()`, `EncodableField` `From`, `GetSize`, `ShareAccountingMessagesTypes` enum + `TryFrom<u8>`, `TryFrom<(u8,&mut[u8])>`, and `into_static()`. (This is the "6-place wiring" the existing code already demonstrates — miss one arm and it won't compile.)
- `extension.md`: append the six messages to §2 and their rows to the §3 message-type table; add a short "§4 Ark Boarding Ceremony" narrative.

**Concrete files to change — `stratum` fork**: none in Phase 2 (message *types* live
in the extension crate; handlers come in Phase 3). Bump the extension dependency
pin once published.

**Design decisions the research flagged**:
- *Coordinator-vs-peer topology*: **coordinator (pool-pushed)**, matching arkd and
  keeping the ASIC/miner passive — consistent with Decision 4.
- *Nonce discipline*: the `SecNonce` is **never** a wire type — it stays on the
  cosigner. Only `PublicNonce` crosses the wire. Enforce single-use at the type level.

**Open risks**:
- Fixed-size vs `B0255` for 32/64/66-byte crypto blobs — pick fixed arrays if
  `binary_sv2` supports them cleanly (check `B032`/custom); else length-prefixed
  `B0255` with runtime length asserts.
- `SEQ0_64K[blob]` encoding has a manual-impl footgun (see `share.rs`
  `to_slice_unchecked` off-by-one on `ntime`); write round-trip tests first.

**Dependencies**: Phase 1 (a stack to exchange them on) — but this phase is pure
crate work and can proceed in parallel.

**Validation**: `cargo build` + `cargo test` with a new `tests/roundtrip.rs` that
encodes→frames→decodes every new message and asserts equality; a wire-capture of a
mocked ceremony shows `0x11..0x18` on `extension_type=32`.

**Wiki grounding**: [musig2-interactive-signing-ceremonies](../../musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md)
(two rounds, no commitment pre-round, session framing); [covenantless-batch-output-mechanics](../wiki/concepts/covenantless-batch-output-mechanics.md)
(the arkd 4-event sequence the messages mirror).

**Definition of done**: All six messages encode/decode round-trip under both
`with_serde` and default features; `parser.rs` compiles with every match arm
handled; `extension.md` documents `0x11–0x18`; the crate version is bumped.

---

### Phase 3: Batch-output script + presigned tree + ephemeral-key deletion (estimated effort: 5–8 days)

**Goal**: Given a known funding outpoint (matured UTXO or fresh coinbase) and n
cosigners, build the Taproot n-of-n batch output, run the MuSig2 ceremony over the
Phase-2 messages to presign the depth-1 VTXO tree, and provably delete ephemeral
keys — producing a broadcastable, confirmed batch output with n leaf VTXOs.

**The output script** (from [covenantless-batch-output-mechanics](../wiki/concepts/covenantless-batch-output-mechanics.md)):
Taproot output with
- **key-path** = n-of-n MuSig2 aggregate of `{S, A, B, …}` (pool + each proxy's
  per-round ephemeral cosigner key), Taproot-tweaked;
- **script-path** = `pk(S) AND after(T)` (`OP_CLTV`/`CSV` sweep) — the operator
  backstop reclaiming un-exited funds after absolute expiry `T`.
Each **leaf VTXO** additionally carries a unilateral-exit tapleaf `pk(owner) AND
after(Δt)` with **CSV `<144>` (~1 day)** — the value bark uses (Phase 4 consumes it).

**MuSig2 wiring (the corrected API)** — build against **`secp256k1` `0.32.0-beta.2`
`musig` module** (confirmed in `~/repos/bark/lib`):
- `musig::KeyAggCache::new(&keys)` → aggregate + Taproot tweak (`tweaked_key_agg` /
  `pubkey_to`).
- Round 1: each cosigner `musig::new_nonce_pair(...)` → `(SecretNonce, PublicNonce)`;
  send `PublicNonce` via `0x13`; pool `musig::nonce_agg(&pubnonces)` →
  `AggregatedNonce`, broadcast via `0x14`.
- Round 2: each cosigner `musig::Session::new(...).partial_sign(SecretNonce, …)` →
  `PartialSignature`; send via `0x15`; pool verifies each with the session's
  partial-verify, then `combine_partial_signatures` → final Schnorr sig, broadcast
  via `0x16`.
- **Ephemeral-key deletion**: cosigner keys are per-round; after `0x16` each proxy
  zeroizes its ephemeral private key and `SecretNonce`. Security = 1-of-n honest
  deletion. Log the deletion event for the Phase-6 demonstration.

**Concrete files to change — `stratum` fork** (`~/repos/stratum`):
- New module `protocols/v2/subprotocols/ark-boarding/` (or under roles-logic): the
  **ceremony state machine** (`Idle → AwaitCommits → Round1Nonces → Round2Sigs →
  Confirmed | Aborted`), a `CeremonyCoordinator` (pool side) and `CeremonyCosigner`
  (proxy side).
- `roles-logic-sv2` message handlers: dispatch `0x11–0x18` to the state machine
  (mirror how existing extension messages are routed).
- A `batch_tx` builder module using `rust-bitcoin` (`bark` shows the Taproot/tapleaf
  construction): assemble batch output, depth-1 tree txs, leaf VTXOs, P2A anchor,
  and per-leaf exit tapleaf.
- Key custody: pool holds S; each JDC/proxy role holds one ephemeral cosigner key
  (generated per batch, never persisted).

**Concrete files to change — `sv2-apps`** (`~/repos/sv2-apps`):
- Pool role: on `NewBlockFound (0x03)` (or faucet trigger), instantiate a
  `CeremonyCoordinator` for the selected funding outpoint and drive `0x11`→`0x16`.
- JDC/proxy role: implement `CeremonyCosigner` responding to `0x11/0x14` with
  `0x12/0x13/0x15`.

**Concrete files to change — `demand-share-accounting-ext`**: none new beyond
Phase 2 (this phase *consumes* the message types).

**Design decisions the research flagged**:
- *Ephemeral vs wallet keys*: use **ephemeral per-round cosigner keys** (clArk's
  default; 1-of-n deletion is the pseudo-covenant). The Ark Labs "sign with wallet
  keys" optimization is out of scope for the trial.
- *Fee-bumping a fixed presigned tree*: **P2A anchor + CPFP** (Decision 3); no
  dynamic fee consumption is possible on a presigned tx.
- *Broadcast ordering*: for a depth-1 tree the pool broadcasts the batch (root) tx
  only after holding all final leaf signatures — the "sign first, broadcast last"
  safety property from [clark-round-transaction-mechanics](../../covenantless-ark/wiki/topics/clark-round-transaction-mechanics.md).

**Open risks**:
- **Coinbase-funded variant**: signatures are valid immediately but the batch tx is
  **non-includable for 100 blocks** — do not broadcast until maturity (feeds Phase 5).
- **Ephemeral-key deletion is unverifiable to others** — it is an assumption, not a
  proof; the trial can only demonstrate *our* deletion, not enforce peers'.
- `binary_sv2` ↔ `rust-bitcoin` type conversions (U256 endianness for txids, PubKey
  encodings) are a classic bug source; unit-test the outpoint round-trip.

**Dependencies**: Phase 1 (funding outpoints) + Phase 2 (messages).

**Validation**: On testnet4, drive a full ceremony over a matured UTXO with n=3;
the batch tx confirms; `getrawtransaction` shows a single-key-path Taproot spend
(the aggregate sig); n leaf VTXOs exist with correct values (use `ark-settler`'s
allocation logic to split by share weight); ephemeral-deletion events logged.

**Wiki grounding**: [tree-presigning-musig2](../../covenantless-ark/wiki/concepts/tree-presigning-musig2.md)
(the MuSig2 session + ephemeral keys); [covenantless-batch-output-mechanics](../wiki/concepts/covenantless-batch-output-mechanics.md)
(the script); [post-block-found-signing](../wiki/concepts/post-block-found-signing.md)
(why signing the coinbase spend is valid).

**Definition of done**: A full n=3 ceremony over a matured testnet4 UTXO produces a
confirmed n-of-n Taproot batch output with n leaf VTXOs; the on-chain footprint is a
single Schnorr key-path spend; ephemeral keys are zeroized and logged; the
per-leaf exit data is emitted to clients via `0x17`.

---

### Phase 4: Demonstrated unilateral exit after the CSV delay (estimated effort: 3–5 days)

**Goal**: A boarded miner exits its VTXO **without pool cooperation**, using only
the presigned exit data + the CSV timeout path, proving self-custody.

**Mechanism** (from [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md)):
For a depth-1 leaf, exit is a short chain — broadcast the batch→leaf branch (TRUC/v3,
P2A-anchor CPFP for fees), wait the leaf's **CSV `<144>` (~1 day, ~144 testnet4
blocks)**, then spend the exit tapleaf `pk(owner) AND after(Δt)` to a sole-control
address. Exit is **cancellable** until the final leaf-spend confirms (a reconnected
miner can offboard cooperatively instead).

**Tasks**:
- [ ] Client-side: persist the `0x17` exit data (`exit_path`) — without it, exit is
      impossible (the covenantless storage burden).
- [ ] Implement `unilateral_exit(vtxo)` in the proxy/wallet: build + fee-bump
      (CPFP on P2A) the branch txs, broadcast in chain order, each confirming before
      the next.
- [ ] Wait Δt; on testnet4, use `generatetoaddress` against a controlled wallet or
      the 20-min min-difficulty rule to advance ~144 blocks quickly.
- [ ] Broadcast the leaf-claim tx spending the CSV tapleaf; confirm sole-control UTXO.
- [ ] Demonstrate **cancellability**: start an exit, then cooperatively offboard
      before the leaf-claim, showing the exit was abandoned safely.

**Concrete files to change**:
- `stratum` fork / `sv2-apps` proxy role: the `unilateral_exit` routine + CPFP fee
  bumper (reuse the `batch_tx` builder from Phase 3).
- `demand-share-accounting-ext`: none (exit is on-chain, not an extension message) —
  unless you choose to add an optional cooperative-offboard message (out of scope).

**Design decisions the research flagged**:
- *Exit-data storage*: client-side, mandatory. Note this in the trial writeup as a
  covenantless cost a CTV design would remove.
- *Δt value*: **CSV `<144>`** (bark's value) — long enough for a forfeit/penalty to
  be broadcast first, short enough to demo in a day (or minutes with forced blocks).

**Open risks**:
- **Exit cost can exceed a small VTXO's value** (O(log t) fees + two txs). Size the
  trial VTXOs above the exit-cost floor.
- **Exit-window race**: exits must complete before absolute expiry `T`, or the pool
  sweeps. Keep `T` comfortably beyond Δt for the trial.

**Dependencies**: Phase 3 (a confirmed batch with leaf VTXOs + exit data).

**Validation**: A miner, given only its persisted exit data and with the pool
offline, lands a sole-control on-chain UTXO after Δt; a second run shows a started
exit cleanly cancelled by cooperative offboard.

**Wiki grounding**: [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md)
(the two-clock model, CSV `<144>`, TRUC/P2A, cancellability, storage burden).

**Definition of done**: Unilateral exit demonstrated end-to-end with the pool
offline; cancellability demonstrated; exit-tx vBytes and fee recorded for Phase 6.

---

### Phase 5: Failure handling — dropout, ban+retry, reorg-before-maturity (estimated effort: 4–6 days)

**Goal**: Exercise the three failure modes the verdict names, and show graceful
degradation (atomic abort, no fund loss) in each.

**5a — One dropout aborts all + ban + retry (fresh nonces)** (Decision 5;
[musig2-interactive-signing-ceremonies](../../musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md)):
- [ ] Kill/withhold one cosigner mid-`0x13` (nonce round) and mid-`0x15` (sig round).
- [ ] Pool detects the missing/invalid contribution: timeout on nonces; on sigs,
      `PartialSigVerify` **identifies** the culprit (`0x18` with `culprit_index`).
- [ ] Pool aborts with **no on-chain footprint**, adds the culprit's SV2 identity to
      a **ban list**, and retries with the remaining set and **freshly generated
      nonces** (never reuse — nonce-reuse = key leak).
- [ ] Show a banned identity is refused entry to the next round.

**5b — Reorg before coinbase maturity (fresh-coinbase variant)** ([coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md)):
- [ ] Run the ceremony against a **fresh coinbase** funding output; presign the tree
      post-block-found (signatures valid, tx non-includable).
- [ ] Force a reorg on testnet4: `bitcoin-cli -testnet4 invalidateblock <blockhash>`
      of the block carrying that coinbase, before 100-block maturity.
- [ ] Observe that the coinbase — and therefore the entire batch and every VTXO —
      **ceases to exist**; the presigned sigs now reference a nonexistent outpoint.
- [ ] Show the mitigation: the **matured-UTXO variant** run in parallel is
      unaffected (funds ≥100 confs cannot be reorged away).
- [ ] Confirm no miner funds were ever at risk in the matured path.

**5c — Ban+retry recovery timing**:
- [ ] Measure wall-clock from abort → re-round completion (feeds Phase 6).

**Concrete files to change**:
- `stratum` fork: ceremony state machine `Aborted` transition + culprit attribution;
  a `BanList` keyed by SV2 identity in the pool role; hard single-use `SecNonce`
  guard (type is non-`Copy`, zeroized on use).
- `sv2-apps` pool role: ban enforcement at ceremony admission; reorg watcher that
  invalidates a pending fresh-coinbase batch on prevhash change.
- `demand-share-accounting-ext`: `CeremonyAbort (0x18)` reason enum already defined
  in Phase 2; ensure `reorg` and `bad-partial-sig` reasons are covered.

**Design decisions the research flagged**:
- *Dropout policy*: **abort-all + ban + retry** (Decision 5) — the demonstrable form
  of the "stake + identity + bans blunt receiver-DoS" argument, which is the thesis's
  strongest original claim and is *unquantified in any source* (this trial is the
  first data point).
- *Fresh-coinbase vs matured-UTXO*: 5b is precisely why the primary path is matured
  (Decision 3); the reorg demo makes the cost visible.

**Open risks**:
- Attribution is only as good as `PartialSigVerify` — a cosigner that sends a
  *valid* partial sig then vanishes before completion is a timeout, not an
  identifiable fault; handle both branches.
- Ban-by-identity assumes stable SV2 identities; a Sybil proxy could re-enter under
  a new identity. Note as a scope limit (real bans need hashrate-cost binding).

**Dependencies**: Phase 3 (ceremony) + Phase 1 (reorg control on testnet4).

**Validation**: A withheld cosigner triggers a clean abort + ban + fresh-nonce
retry that completes; a pre-maturity reorg voids a fresh-coinbase batch while the
matured-UTXO batch survives; no miner funds lost in any case.

**Wiki grounding**: [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md)
(dropout/ban/stake); [musig2-interactive-signing-ceremonies](../../musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md)
(non-robust abort, identifiable abort, fresh-nonce rule); [coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md)
(reorg voids the batch).

**Definition of done**: All three failure modes reproduced on testnet4 with logged
evidence; abort leaves no on-chain footprint; matured-path funds provably safe
through a reorg that voids the fresh-coinbase path.

---

### Phase 6: Measurements (estimated effort: 2–3 days)

**Goal**: Quantify the four numbers the verdict says are *unmeasured in any source* —
turning "novel, untested" into "measured at n≤5 on testnet4."

**Measurements**:
- [ ] **Ceremony latency vs testnet4 block cadence.** Time `0x11`→`0x16`
      (setup→final sigs) for n=2,3,4,5, proxy-to-pool. Compare against testnet4 block
      cadence (bursty: min-difficulty clusters after 20-min gaps vs ~10-min target).
      The claim to test: the ceremony completes well inside a block interval.
- [ ] **Exit-tx cost.** vBytes + testnet4 fee for the branch txs + leaf-claim
      (baseline ~124 vB per exit tx per the wiki; measure the depth-1 total).
- [ ] **Abort recovery.** Wall-clock abort→completed-retry (from Phase 5a), across
      several trials.
- [ ] **Ceremony bandwidth/message sizes.** Bytes on the wire per round as n grows
      (nonces + partial sigs scale with n × tree-tx-count).

**Concrete files to change**:
- `stratum` fork / `sv2-apps`: instrument the ceremony state machine with timestamps
  and byte counters; emit a structured JSON metrics record per ceremony.
- A small `scripts/` analysis (in this repo or the trial harness) to tabulate runs.

**Design decisions the research flagged**: none new — this phase *validates* the
scope decisions. If latency stays flat and small for n≤5, it supports the
"small-signer-set viable" verdict; if it blows up by n=5, it corroborates the
"doesn't scale" objection at even modest n.

**Open risks**:
- testnet4 cadence is bursty (min-difficulty rule), so "vs block cadence" needs
  enough samples to be meaningful — report distribution, not a single number.
- Fee estimates on testnet4 are not representative of mainnet fee markets; report
  vBytes (size) as the portable metric, sats as illustrative.

**Dependencies**: Phases 3–5.

**Validation**: A results table (latency×n, exit vBytes, abort-recovery, bandwidth×n)
with ≥5 samples each; a one-paragraph read against the verdict.

**Wiki grounding**: the verdict's "**unquantified in any source** (open gap)" note in
[pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md) and the
"what would change this verdict → a working prototype at realistic counts" in the
[thesis](../theses/ark-boarding-sv2-mining.md).

**Definition of done**: All four metrics captured for n=2–5 with ≥5 samples;
results written up as a short report and fed back as an update to the thesis wiki
(candidate to move the verdict toward Supported for the small-n regime).

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| n-of-n doesn't scale; even n=5 latency may balloon | [thesis-analysis-viability](../wiki/topics/thesis-analysis-viability.md) (Braidpool ~50 cap) | Scope fixed to n≤5; Phase 6 measures the curve explicitly. Do **not** claim pool-scale. |
| Pure-receiver / one-dropout-aborts-all griefing | [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md) | Abort+ban+retry (Phase 5a); miner identity/stake as the ban lever (the thesis's own argument). |
| Coinbase 100-block maturity + reorg voids a fresh-coinbase batch | [coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md) | Primary path boards a **matured proxy UTXO**; fresh-coinbase run is a *deliberate* failure demo (Phase 5b). |
| Nonce reuse on retry → key leakage | [musig2-interactive-signing-ceremonies](../../musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md) | `SecNonce` single-use, non-`Copy`, zeroized; every retry is a fresh session with fresh nonces. |
| Ephemeral-key deletion is unverifiable to peers | [tree-presigning-musig2](../../covenantless-ark/wiki/concepts/tree-presigning-musig2.md) | 1-of-n honest-deletion assumption stated openly; trial demonstrates *our* deletion, not enforcement. |
| Proxy-held keys collapse trust toward pool-as-ASP (statechain-equivalent) | [thesis](../theses/ark-boarding-sv2-mining.md) follow-up #2 | Frame the trial honestly as "unilateral-exit custody," not self-custody; unilateral exit (Phase 4) is the trust floor. |
| Lost client-side exit data → no exit | [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md) | Persist `0x17` data durably; document as a covenantless cost. |
| Exit cost > small-VTXO value | [unilateral-exit-and-timeouts](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md) | Size trial VTXOs above the exit-cost floor; report vBytes. |
| Manual `Sv2DataType` impls for SEQ-of-blob are error-prone | this repo's `share.rs` (`ntime` off-by-one) | Round-trip tests **first** (Phase 2 validation). |
| `binary_sv2` ↔ `rust-bitcoin` type/endianness mismatch | direct code read | Unit-test outpoint/pubkey/sig round-trips at the boundary. |
| testnet4 block cadence too bursty/slow for real-hashrate demo | BIP-94 gap-fill | 20-min min-difficulty rule makes blocks findable; faucet-funded fallback drives ceremonies deterministically. |

## Open Questions

- **Does the SV2 identity ban actually deter a Sybil proxy?** Real deterrence needs
  binding to hashrate cost; the trial bans by identity only. (Thesis follow-up #1 —
  this trial is the first empirical touchpoint.)
- **Reuse an existing tree/exit implementation or hand-roll?** Plan hand-rolls a
  depth-1 tree for n≤5; if a recursive tree is wanted later, evaluate lifting
  `bark`'s tree builder vs. arkd's. Not needed for the trial.
- **Cooperative offboard message?** Left out of the extension (exit is on-chain). If
  the trial wants a fast cooperative path, that's a further message pair — scope
  creep for now.
- **Where does `demand-open-source/stratum` fork diverge from SRI master** in a way
  that affects handler wiring? Confirm the extension-message routing hook exists on
  the fork branch you build against (`~/repos/stratum` `main`, `average-gary` remote).
- **Fee-market realism**: testnet4 fees are not mainnet; a mainnet cost model for the
  batch + exits is follow-up research, not this trial.

## Sources Consulted

**Primary wiki — [ark-boarding-sv2-mining](../_index.md):**
- [thesis + verdict](../theses/ark-boarding-sv2-mining.md) — scope boundary, falsification criteria, "what would change the verdict" (drove the whole scoping).
- [thesis-analysis-viability](../wiki/topics/thesis-analysis-viability.md) — the sub-claim table separating confirmed core from contested scale.
- [post-block-found-signing](../wiki/concepts/post-block-found-signing.md) — why the `NewBlockFound` trigger + known outpoint makes MuSig2 sufficient (Decision 1).
- [covenantless-batch-output-mechanics](../wiki/concepts/covenantless-batch-output-mechanics.md) — the batch script + arkd 4-event ceremony → message mapping (Decisions 2, Phase 2/3).
- [coinbase-maturity-and-reorg](../wiki/concepts/coinbase-maturity-and-reorg.md) — matured-UTXO vs fresh-coinbase, P2A/CPFP (Decision 3, Phase 5b).
- [sv2-extension-surface](../wiki/concepts/sv2-extension-surface.md) — extension negotiation, `NewBlockFound`, verification≠custody.
- [pure-receiver-and-liveness](../wiki/concepts/pure-receiver-and-liveness.md) — proxy-not-ASIC, dropout/ban/stake (Decisions 4, 5, Phase 5a).

**Grounding wikis:**
- [covenantless-ark](../../covenantless-ark/_index.md): [round mechanics](../../covenantless-ark/wiki/topics/clark-round-transaction-mechanics.md) (sign-first/broadcast-last), [tree presigning](../../covenantless-ark/wiki/concepts/tree-presigning-musig2.md) (ephemeral keys, MuSig2 session), [unilateral exit](../../covenantless-ark/wiki/concepts/unilateral-exit-and-timeouts.md) (CSV `<144>`, TRUC/P2A, storage burden — Phase 4).
- [musig2-signing-ceremonies](../../musig2-signing-ceremonies/wiki/topics/musig2-interactive-signing-ceremonies.md): two rounds, no commitment pre-round, non-robust abort, identifiable abort, nonce-reuse catastrophe (Phase 2/3/5).

**Direct source & environment reads (2026-07-20):**
- `demand-share-accounting-ext` `src/const.rs`, `src/parser.rs`, `src/new_block_found.rs`, `src/data_types/share.rs`, `extension.md` — the exact wiring patterns Phase 2 extends.
- `~/repos/stratum` (demand fork, `average-gary`/`ethan` remotes), `~/repos/sv2-apps`, `~/repos/sv2-tp` (Sjors C++ TP), `~/repos/rust-sv2-template-provider`, `~/repos/bitcoind-testnet4-startos`, `~/repos/bark` (`secp256k1` `0.32.0-beta.2` `musig` API), `~/repos/ark-settler` (weighted allocation reference).

**Gap-fill research (2026-07-20):**
- BIP-94 (testnet4): 20-min min-difficulty rule preserved; timewarp fix (first-block-of-period nTime ≥ prior − 600 s); retarget base from first block of previous period → no block-storm. Real-hashrate block-finding feasible.
- MuSig2 Rust API correction: mainline `secp256k1` `musig` module (`KeyAggCache`, `new_nonce_pair`, `nonce_agg`, `Session`, `partial_sign`, `combine_partial_signatures`), per the local `bark` checkout — supersedes the wiki's `secp256k1-zkp` citation.

## Definition of Done (whole trial)

A testnet4 SRI pool, on finding a block (or faucet trigger), runs an n≤5 MuSig2
ceremony over new extension messages `0x11–0x18` that boards miners into leaf VTXOs
under a covenantless n-of-n Taproot batch output funded from a matured UTXO; a miner
unilaterally exits after the CSV delay with the pool offline; dropout→ban→retry,
banned-identity refusal, and a pre-maturity reorg (voiding only the fresh-coinbase
variant) are all demonstrated; and latency×n, exit vBytes, abort-recovery, and
bandwidth×n are measured and written back to the thesis wiki — with **no CTV/CSFS/APO
anywhere in any spending path.**




</content>
</invoke>
