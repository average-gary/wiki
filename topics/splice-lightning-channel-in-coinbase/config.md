---
title: "splice-lightning-channel-in-coinbase — config"
type: topic-config
created: 2026-07-23
freshness_threshold: 70
---

# splice-lightning-channel-in-coinbase — config

Thesis wiki for a single claim:

> **"I can splice a lightning channel in a coinbase transaction."**

## Scope

**In scope**:
- **The thesis, both readings**:
  - *Reading A (literal splice)*: the on-chain splice tx **is** a coinbase — it
    spends the existing channel funding UTXO and creates a new funding UTXO while
    also serving as the block's generation (coinbase) transaction.
  - *Reading B (charitable)*: a Lightning channel **funding output** (fresh open,
    or splice-in destination) is **created as an output** of a coinbase tx.
- **Coinbase transaction structure & consensus rules**: the single null-prevout
  input (32-byte-zero hash, index `0xFFFFFFFF`), scriptSig = coinbase (BIP-34
  height + arbitrary), witness-commitment output (BIP-141), no ability to spend
  any existing UTXO, `COINBASE_MATURITY = 100`.
- **Lightning splicing semantics** (BOLT / dynamic commitments / splicing spec):
  a splice *spends the current funding output* and *creates a new one*; the
  channel is quiescent during the splice; the new funding must be enforceable.
- **Funding-output requirements**: commitment txs must be broadcastable at any
  time; a coinbase-borne funding output is unspendable for 100 blocks and voided
  by a reorg → what that does to channel enforceability and LN safety.
- **The presigning wall**: a coinbase outpoint is unknowable until the block is
  mined; how (or whether) LN funding/splice construction copes (cross-link
  `sighash-anyprevout-bip118`, `ark-boarding-sv2-mining`).
- **Adjacent constructions that get close**: pool-payout-to-channel, splice-in
  from a coinbase-descended UTXO, channel funding from mining rewards.

**Out of scope**:
- General LN channel opening from ordinary (non-coinbase) transactions.
- Ark boarding as such (cross-link `ark-boarding-sv2-mining`) — related timing
  trick, different mechanism.
- PPLNS / payout-fairness math (cross-link `bitcoin-mining-payout-schemas`).
- Generic Stratum V2 internals unrelated to coinbase output construction.
- Covenant soft-fork activation politics beyond "needed here or not."

## Sensitivity

Public. Hub-publishable. Bitcoin consensus rules, BOLT/LN specs, and the SV2
spec are all public; no employer-specific content.

## Source preferences

- **Primary**: Bitcoin consensus rules (Bitcoin Core `validation.cpp`,
  `consensus/tx_check`, BIP-34, BIP-141), the Lightning BOLTs (esp. BOLT 2/3 and
  the splicing spec / PR #1160), Optech's splicing coverage, LN implementation
  docs (LND, CLN, LDK, Eclair splicing).
- **Secondary**: delvingbitcoin / lightning-dev / bitcoin-dev threads, BIP-118
  (APO), the `ark-boarding-sv2-mining` and `sighash-anyprevout-bip118` hub topics.
- **Tertiary**: practitioner blog posts, conference talks, named-author commentary.

## Adjacent topic wikis

- `sighash-anyprevout-bip118` — the unknown-coinbase-outpoint presigning wall this
  thesis runs straight into.
- `ark-boarding-sv2-mining` — the sibling thesis that routes *around* the coinbase
  presigning wall by deferring signing to post-block-found; closest prior art.
- `ldk-server`, `cdk-ldk-lnurl` — Lightning node context.
- `bitcoin-mining-payout-schemas`, `sv2-coinbase-identity`, `datum` — the mining /
  coinbase-construction context.
