---
title: "Bitcoin Core consensus code: IsCoinBase, COINBASE_MATURITY, premature-spend"
source: "https://github.com/bitcoin/bitcoin/blob/master/src/primitives/transaction.h"
source_extra:
  - "https://github.com/bitcoin/bitcoin/blob/master/src/consensus/tx_check.cpp"
  - "https://github.com/bitcoin/bitcoin/blob/master/src/consensus/tx_verify.cpp"
  - "https://github.com/bitcoin/bitcoin/blob/master/src/consensus/consensus.h"
  - "https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp"
type: repo
subtype: consensus-code
retrieved: 2026-07-23
tags: [bitcoin-core, consensus, coinbase, iscoinbase, coinbase-maturity, premature-spend, reorg]
credibility: high
evidence_strength: consensus-rule
direction: "opposes Reading A (definitively); hard-constrains Reading B"
bears_on: [A, B]
summary: "The reference-implementation consensus rules that settle the thesis. IsCoinBase() requires exactly one input with a null prevout; tx_check.cpp makes coinbase and prevout-spending mutually exclusive; COINBASE_MATURITY=100; tx_verify.cpp rejects spends of coinbase outputs <100 deep; validation.cpp rejects a loose coinbase outside a block."
---

# Bitcoin Core — coinbase consensus rules

The source of truth. Reading A is not a policy question; it is a type-level
consensus contradiction.

## Coinbase definition (`primitives/transaction.h`)

```cpp
bool IsCoinBase() const { return (vin.size() == 1 && vin[0].prevout.IsNull()); }
```
- A tx **is** a coinbase iff it has **exactly one input** AND that input's prevout
  is **null**.
- `COutPoint::IsNull()` requires `hash.IsNull() && n == NULL_INDEX`, where
  `NULL_INDEX = std::numeric_limits<uint32_t>::max()` = **`0xffffffff`**. So the
  coinbase's single input is `{hash: 32 zero bytes, n: 0xffffffff}` — it references
  **no prior output**.

## Coinbase ⟺ null-prevout are mutually exclusive (`consensus/tx_check.cpp`)

```cpp
if (tx.IsCoinBase()) {
    // only checks scriptSig length 2–100 (bad-cb-length)
} else {
    for (const auto& txin : tx.vin)
        if (txin.prevout.IsNull())
            return state.Invalid(..., "bad-txns-prevout-null");
}
```
- A tx that spends a real funding UTXO is **by construction non-coinbase** and may
  not have any null input; a coinbase spends nothing. **The two are mutually
  exclusive.** This is the direct kill for Reading A.

## Coinbase maturity (`consensus/consensus.h`)

```cpp
/** Coinbase transaction outputs can only be spent after this
 *  number of new blocks (network rule) */
static const int COINBASE_MATURITY = 100;
```

## Premature-spend rejection is consensus (`consensus/tx_verify.cpp`)

```cpp
if (coin.IsCoinBase() && nSpendHeight - coin.nHeight < COINBASE_MATURITY)
    return state.Invalid(TxValidationResult::TX_PREMATURE_SPEND,
        "bad-txns-premature-spend-of-coinbase", ...);
```
- A commitment/force-close tx spending a coinbase-created funding output is
  **invalid for 100 blocks** — the channel cannot be enforced on-chain during that
  window (kills the LN "broadcast latest commitment at any time" safety property).
- Rejected at mempool (`bad-txns-premature-spend-of-coinbase`) and invalid under
  consensus if mined (`TX_PREMATURE_SPEND`).

## A coinbase cannot exist outside a block (`validation.cpp`)

```cpp
if (tx.IsCoinBase())
    return state.Invalid(..., "coinbase");
```
- A coinbase cannot be relayed as a loose transaction, so it can **never** be the
  negotiated/broadcast funding tx of an interactive splice.
- Reorg handling: on an orphaned block the coinbase and every output it created
  cease to exist; maturity is re-evaluated against the new chain.

## Bearing on the thesis

- **Reading A**: hard-coded contradiction. No mechanism resolves it.
- **Reading B**: a coinbase output *can* be a funding scriptPubKey, but the funding
  UTXO — and any commitment spending it — is invalid for 100 blocks and voided by
  reorg. Practical designs board a **matured proxy UTXO**, at which point the
  funding tx is no longer literally the coinbase.
