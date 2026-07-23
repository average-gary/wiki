---
title: "Playbook — Build an SV2 coinbase-verification mining daemon"
type: output
created: 2026-07-21
updated: 2026-07-21
tags: [stratum-v2, coinbase, daemon, rust, SRI, playbook, deliverable]
summary: "Actionable end-to-end playbook: build a simple daemon that connects as a miner to a Stratum V2 pool, receives extended jobs, reconstructs the coinbase, and checks it against an expected value — with the SRI crate stack, a source-verified code skeleton, the expected-value sourcing rules, deviation-detection design, and an honest trust-model boundary."
---

# Playbook — SV2 coinbase-verification mining daemon

**Goal:** a simple daemon that connects to mine to a Stratum V2 pool and does a coinbase
transaction check to determine whether the coinbase matches an expected value.

This playbook is the practical distillation of the
[[../_index|sv2-coinbase-verify-daemon]] wiki. Read the linked concept articles for the
evidence behind each step.

## TL;DR

1. **Open an EXTENDED channel** — it's the *only* SV2 channel type that exposes the
   coinbase (`coinbase_tx_prefix`/`suffix`/`merkle_path`). A standard channel gives an
   opaque merkle root; a coinbase check there is impossible.
2. **Be your own SV2 client** — don't sniff. SV2 is Noise-encrypted; connect directly,
   complete the handshake, read jobs in plaintext-to-you.
3. **Reuse SRI's `channels_sv2`** — `ExtendedChannel::validate_share` /
   `merkle_root_from_path` already do reconstruct→fold→hash→target. Don't reimplement.
4. **Compute the expected value** by part: subsidy from height, fees from a template,
   payout target from config (pool address for custodial pools, miner address for
   SOLO/DATUM/JD).
5. **Scope it honestly** — this is a watchdog, not a trustless guarantee.

## Step 1 — Connect as an extended-channel SV2 client

Message flow ([[../wiki/concepts/sv2-mining-client-message-flow]]):

```
Noise_NX handshake  →  SetupConnection(.Success)  →
OpenExtendedMiningChannel(.Success)  →  NewExtendedMiningJob (+ SetNewPrevHash)  →  [check]  →  SubmitSharesExtended
```

- **Extended, not standard.** Only `NewExtendedMiningJob` carries the coinbase bytes.
  ([[../wiki/concepts/standard-vs-extended-channels-coinbase-visibility]])
- **Client, not sniffer.** `stratum-sniffer` is an active MITM needing its own keypair;
  a direct client holds the session keys by construction.
  ([[../wiki/topics/reference-implementation-skeleton]])

## Step 2 — Crate stack (verified, July 2026)

`stratum-core 0.5.0` (re-exports `binary_sv2 6`, `codec_sv2 6`, `mining_sv2 11`,
`channels_sv2 7`, `common_messages_sv2 8`, `parsers_sv2 0.5`, `noise_sv2 1`,
`bitcoin 0.32.5`) + `stratum-apps` (git-pinned; `network_helpers` + `key_utils`) +
`tokio`/`async-channel`/`clap`. Full Cargo.toml + `main.rs`:
[[../wiki/topics/reference-implementation-skeleton]]. Crate roles + naming traps
(`roles_logic_sv2` → `parsers`/`handlers`/`channels`): [[../wiki/concepts/sri-client-crate-stack]].

## Step 3 — Reconstruct the coinbase & fold the merkle root

```
coinbase_tx = coinbase_tx_prefix ‖ extranonce_prefix ‖ extranonce ‖ coinbase_tx_suffix
coinbase_txid = SHA256d(coinbase_tx)
root = fold(coinbase_txid, merkle_path)     # h = SHA256d(h ‖ e), coinbase = left leaf
```

Reuse `channels_sv2::merkle_root::merkle_root_from_path(prefix, suffix, extranonce, path)`
(or `ExtendedChannel::validate_share`, which also builds the header + checks target).
Byte-level detail: [[../wiki/concepts/coinbase-reconstruction-and-merkle-fold]] and
[[../wiki/concepts/coinbase-transaction-anatomy]].

## Step 4 — Run the expected-value checks

Deserialize the reconstructed coinbase (`bitcoin::consensus::deserialize::<Transaction>`)
and check ([[../wiki/concepts/expected-value-checks-taxonomy]]):

| Check | How |
|-------|-----|
| (a) payout address | `tx.output.iter().any(|o| o.script_pubkey == expected_spk)` |
| (b) output value | compare `tx.output` values to expected split |
| (c) pool tag / BIP34 height / `0xfabe6d6d` | scan the scriptSig (visible prefix/suffix) |
| (d) OP_RETURN commitment | locate `6a 24 aa21a9ed <32-byte>` |
| (e) integrity | reconstructed root == the root you'd hash |

**Sourcing the expected value** ([[../wiki/concepts/sourcing-the-expected-value]]):
- **Subsidy:** `(5_000_000_000 >> (height/210000))` sats — 312,500,000 (3.125 BTC) at
  height ~900k. Integer sats only. Consensus ceiling: coinbase ≤ subsidy+fees.
- **Fees / total:** you need a template — run bitcoind + SV2 TP, read
  `NewTemplate.coinbase_tx_value_remaining`.
- **Payout target:** **pool address** for custodial FPPS/PPLNS (miners paid off-chain);
  **miner address** for SOLO/DATUM/JD (paid on-chain in the coinbase). Seed the expected
  address book from the `bitcoin-data`/`mempool` mining-pools datasets.

## Step 5 — Turn one-shot checks into a watchdog (optional)

[[../wiki/concepts/deviation-detection]]:
- **Job-diff:** anchor every coinbase change to a `SetNewPrevHash`. Payout-address/tag
  change *without* a new prevhash → HIGH-severity alert.
- **On-chain correlation:** when a block lands at your working height, fetch its coinbase
  (own bitcoind ZMQ, or mempool.space/Esplora `/api/block/:hash/txid/0`) and compare to
  what the pool served. Own bitcoind is strictly stronger (no rate limits, no trust).

## Step 6 — Know the limits (state them, don't paper over)

[[../wiki/topics/what-the-daemon-can-and-cannot-prove]]: a passive check proves only
*this job's* coinbase as served to *this miner*. It **cannot** prove what's actually
mined/broadcast, that other miners get the same coinbase, aggregate payout, or catch
block withholding (provably undetectable from share stats — APoW, Optech). Off-chain
PPS/FPPS/PPLNS payout correctness is a separate ledger concern. Real trust-minimization
is SV2 **Job Declaration** (the miner authors the coinbase).

## Suggested follow-up theses

1. *"An extended-channel coinbase-verify daemon can detect a pool silently redirecting
   its payout address in real time"* — testable via job-diff + on-chain correlation on
   testnet4.
2. *"For custodial FPPS/PPLNS pools, coinbase verification provides no assurance about
   individual miner payout"* — likely Supported (off-chain accounting).
3. *"Sybil-identity coinbase diffing can detect per-worker discrimination on a live SV2
   pool"* — feasibility-limited (pool fingerprinting).

## Source map

- Message flow / channels: [[../wiki/concepts/sv2-mining-client-message-flow]], [[../wiki/concepts/standard-vs-extended-channels-coinbase-visibility]]
- Coinbase mechanics: [[../wiki/concepts/coinbase-transaction-anatomy]], [[../wiki/concepts/coinbase-reconstruction-and-merkle-fold]]
- Checks + value: [[../wiki/concepts/expected-value-checks-taxonomy]], [[../wiki/concepts/sourcing-the-expected-value]]
- Code: [[../wiki/topics/reference-implementation-skeleton]], [[../wiki/concepts/sri-client-crate-stack]]
- Watchdog + limits: [[../wiki/concepts/deviation-detection]], [[../wiki/topics/what-the-daemon-can-and-cannot-prove]], [[../wiki/concepts/coinbase-verification-trust-model-limits]]
- Prior art: [[../wiki/concepts/prior-art-coinbase-verification]]
- Reference: [[../wiki/references/specs-repos-tools]]
