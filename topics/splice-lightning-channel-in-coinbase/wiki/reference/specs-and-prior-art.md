---
title: "Specs, consensus rules & prior art"
type: reference
created: 2026-07-23
updated: 2026-07-23
tags: [reference, bolt, bip, consensus, optech, prior-art]
---

# Specs, consensus rules & prior art

## Lightning

- **BOLT #2 — Peer Protocol** (splicing merged from lightning/bolts PR #1160).
  Splice definition, `tx_add_input`/`shared_input_txid`, `channel_ready` **coinbase
  100-block rule**, `splice_init` ordering, quiescence. *(the load-bearing source)*
  → raw: [[../../raw/papers/2026-07-23-bolt2-splicing-and-coinbase-funding]]
- **Bitcoin Optech — Splicing** — cross-implementation definition + shipping timeline
  (Eclair, Core Lightning, LDK, Phoenix). → raw:
  [[../../raw/articles/2026-07-23-optech-splicing]]
- **Bitcoin Optech — Zero-conf channels** — why zero-conf can't rescue an *unspendable*
  coinbase funding. → raw: [[../../raw/articles/2026-07-23-optech-zero-conf-channels]]
- **Implementation splice-in docs** — ACINQ/Phoenix auto-splice, CLN `splicein`
  (splice any confirmed wallet UTXO). → raw:
  [[../../raw/articles/2026-07-23-implementation-splice-in-docs]]

## Bitcoin consensus / coinbase

- **Bitcoin Core consensus code** — `IsCoinBase()`, `COINBASE_MATURITY = 100`,
  `bad-txns-premature-spend-of-coinbase`, `bad-txns-prevout-null`, loose-coinbase
  rejection. *(the direct kill for Reading A)* → raw:
  [[../../raw/repos/2026-07-23-bitcoin-core-coinbase-consensus-rules]]
- **Bitcoin Developer Reference** — coinbase input structure + maturity (canonical
  docs). → raw: [[../../raw/articles/2026-07-23-bitcoin-dev-reference-coinbase]]
- **BIP-34** — block height in coinbase scriptSig. → raw:
  [[../../raw/papers/2026-07-23-bip34-block-height-in-coinbase]]
- **BIP-141** — coinbase witness commitment + structure. → raw:
  [[../../raw/papers/2026-07-23-bip141-coinbase-witness-commitment]]
- **BIP-118 (SIGHASH_ANYPREVOUT)** — the presigning-wall relaxation (Draft / not on
  mainnet). → raw: [[../../raw/papers/2026-07-23-bip118-sighash-anyprevout]]

## Mining ↔ Lightning prior art

- **jamesob — Scaling noncustodial mining payouts with CTV** (Delving #1753) — the
  presign-a-coinbase-spend + fanout pattern with explicit maturity handling. → raw:
  [[../../raw/articles/2026-07-23-jamesob-noncustodial-payouts-ctv]]
- **Mining-payout-to-Lightning designs** — OCEAN (BOLT12), NiceHash, Braidpool
  (one-way channels). All route around the naive claim. → raw:
  [[../../raw/articles/2026-07-23-mining-payout-to-lightning-designs]]
- **StackExchange #115588** — the exact question ("open a channel with a coinbase
  output?"), answered "possible but impractical." → raw:
  [[../../raw/articles/2026-07-23-stackexchange-coinbase-open-channel]]

## Adjacent hub topics (cross-wiki)

- [[../../../sighash-anyprevout-bip118/_index|sighash-anyprevout-bip118]] — the
  unknown-coinbase-outpoint presigning wall; APO on signet.
  See especially [[../../../sighash-anyprevout-bip118/wiki/topics/coinbase-outpoint-presigning|coinbase-outpoint-presigning]].
- [[../../../ark-boarding-sv2-mining/_index|ark-boarding-sv2-mining]] — sibling thesis
  that defers signing to **post-block-found** to route around the presigning wall.
  See [[../../../ark-boarding-sv2-mining/wiki/concepts/post-block-found-signing|post-block-found signing]]
  and [[../../../ark-boarding-sv2-mining/wiki/concepts/coinbase-maturity-and-reorg|coinbase maturity & reorg]].
- [[../../../ldk-server/_index|ldk-server]] / [[../../../cdk-ldk-lnurl/_index|cdk-ldk-lnurl]] — LN node context.
- [[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]],
  [[../../../datum/_index|datum]], [[../../../sv2-coinbase-identity/_index|sv2-coinbase-identity]]
  — coinbase-construction / mining-payout context.
