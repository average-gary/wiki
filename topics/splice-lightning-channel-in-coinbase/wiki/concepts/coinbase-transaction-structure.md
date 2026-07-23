---
title: "Coinbase transaction structure"
type: concept
created: 2026-07-23
updated: 2026-07-23
confidence: high
tags: [coinbase, consensus, null-prevout, coinbase-maturity, reorg, bip34, bip141]
---

# Coinbase transaction structure

The block's **generation transaction** — position 0 in every block. Its defining
consensus properties are what the thesis collides with.

## The single null-prevout input

Bitcoin Core defines it in one line (`primitives/transaction.h`):

```cpp
bool IsCoinBase() const { return (vin.size() == 1 && vin[0].prevout.IsNull()); }
```

A transaction **is** a coinbase iff it has **exactly one input** whose prevout is
**null** — `{hash: 32 zero bytes, n: 0xffffffff}` (`NULL_INDEX = uint32_t::max`).
It references **no prior output**; it spends nothing.

`consensus/tx_check.cpp` makes this exclusive: a non-coinbase tx with any null input
is rejected `bad-txns-prevout-null`. So **"is a coinbase" and "spends a real UTXO"
are mutually exclusive at the type level.** *(high — Bitcoin Core consensus code;
canonical dev reference; corroborated across 3 agents)*

## The coinbase (scriptSig) field

In place of a signature script, the single input carries the **coinbase field**:
2–100 bytes of miner-chosen data. [[../reference/specs-and-prior-art|BIP-34]]
mandates the **block height** as its first item (minimally-encoded CScript); the
remainder is extranonce + miner tags. It is *not* a signature satisfying any output's script.

## Outputs

Payout outputs (subsidy + fees) to miner scriptPubKeys — which **can be arbitrary
scripts**, including a 2-of-2 P2WSH/P2TR (relevant to
[[three-readings|Reading B]]) — **plus** the mandatory BIP-141 witness-commitment
output: `OP_RETURN 6a24aa21a9ed <32-byte commitment>`.

## Two constraints the thesis lives or dies on

- **Maturity** (`COINBASE_MATURITY = 100`): coinbase outputs "cannot be spent … for
  at least 100 blocks" (~16.7 h). Spending one earlier is consensus-invalid
  (`bad-txns-premature-spend-of-coinbase` / `TX_PREMATURE_SPEND`). See
  [[coinbase-maturity-vs-ln-enforceability]].
- **Reorg fragility**: a coinbase — and every output it creates — ceases to exist if
  its block is orphaned. Maturity exists precisely to insure against this.

## The txid is unknowable pre-mining

The coinbase txid depends on BIP-34 height + extranonce + miner tags + the witness
merkle root — all fixed only at block assembly. So you cannot know
`coinbase_txid:0` before the block is found, which is the root of the
[[presigning-unknown-coinbase-outpoint|presigning wall]].

## A coinbase cannot exist outside a block

`validation.cpp` rejects a loose coinbase (`if (tx.IsCoinBase()) … "coinbase"`). It
can never be relayed as a standalone tx — so it can never be the negotiated,
broadcast funding/splice transaction of an interactive Lightning session.

## See also

- [[lightning-splice-mechanics]] — the other half of the collision.
- [[three-readings]] — how these properties map onto each reading.
- [[../reference/specs-and-prior-art]] — source pointers.
