---
title: "Sourcing the expected value"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [bitcoin, subsidy, fees, coinbase_tx_value_remaining, payout-address, pplns, fpps, solo, datum, expected-value]
---

# Sourcing the expected value

The daemon checks the observed coinbase against an *expected* value — but "expected
value" decomposes into **three independent questions**, each with a different source and
trust profile.

## (1) Subsidy — computable from height alone (zero trust)

The daemon learns the height from the [[wiki/concepts/coinbase-transaction-anatomy|BIP34 coinbase scriptSig]]
(first push) or `SetNewPrevHash`. Then, in integer satoshis (never floats):

```
halvings = height / 210000                       # integer division
subsidy  = (halvings >= 64) ? 0 : (5_000_000_000 >> halvings)
```

- At height ~900,000 (mid-2026): halvings = 4 → `5,000,000,000 >> 4 = 312,500,000 sat =
  3.125 BTC`. Next halving 1.5625 BTC at 1,050,000 (~2028).
- **Consensus ceiling** (`bad-cb-amount`): `coinbase value ≤ subsidy + fees`, never more.
  — [[raw/papers/2026-07-21-block-subsidy-and-consensus-value-ceiling]]

## (2) Fees / total value — needs a template

A pure downstream miner on a mining channel does **not** know the block's fee total. To
get an independent ground-truth total: run your own **bitcoind + SV2 Template Provider**
(or `getblocktemplate`) and read `NewTemplate.coinbase_tx_value_remaining` (= subsidy +
fees minus TP-fixed outputs). Without a template you can only bound value by the subsidy
floor + trust the pool's own claimed outputs.
— [[raw/articles/2026-07-21-sv2-spec-template-distribution-protocol]]

## (3) Payout target (scriptPubKey) — depends on the payout scheme

Optech's rule: pools pay the coinbase to **EITHER the pool operator OR the miners
directly.** — [[raw/articles/2026-07-21-optech-pooled-mining-trust-model]]

| Scheme | Coinbase pays | Expected value = | Configure |
|--------|---------------|------------------|-----------|
| **FPPS / PPS+ / PPLNS** (custodial: Foundry, AntPool, F2Pool) | pool operator's address; miners paid off-chain | the pool's known payout scriptPubKey(s) | address book of pool SPKs + expected tag |
| **PPLNS-JD / SLICE** (SV2 Job Declaration) | pool payout = **FIRST coinbase output** (funded from 0 by the JDC) | output[0].scriptPubKey = pool SPK; value fully allocated | verify first-output SPK + allocation |
| **SOLO** | the miner directly, full reward | single miner scriptPubKey; value = subsidy+fees | the miner's own address |
| **DATUM / OCEAN TIDES** (non-custodial) | miners directly, one output per eligible miner, pro-rata | set of miner SPKs | the miner's own address(es) |

— [[raw/articles/2026-07-21-sv2-spec-job-declaration-protocol]],
[[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]],
[[../datum/_index|datum]]

**How the target is published:** pools are identified by (a) coinbase scriptSig **tags**
(regex-matched: `/Foundry USA Pool/`) and (b) known **payout addresses** (first output).
The `bitcoin-data` / `mempool` mining-pools datasets are the practical seed for the
daemon's expected-address book. Note tags/addresses legitimately drift.
— [[raw/data/2026-07-21-mining-pools-attribution-dataset]]

## Bottom line

Subsidy: compute from height (no deps). Fees/total: need a template (bitcoind + SV2 TP).
Payout target: configure an expected SPK — **pool address** for custodial FPPS/PPLNS,
**miner address** for SOLO/DATUM/JD. All three checks require an extended channel or a
local template.

## See also

- [[wiki/concepts/expected-value-checks-taxonomy]]
- [[wiki/concepts/coinbase-transaction-anatomy]]
- [[wiki/concepts/deviation-detection]]
