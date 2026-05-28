---
title: "Parasite Pool coinbase distribution — on-chain analysis"
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [parasite-pool, on-chain-analysis, coinbase, dispute, mempool-space, primary]
---

# Parasite Pool Coinbase — On-Chain Analysis

Investigation of `Distortions81`'s December 2025 [`parasite.wtf scam`](https://github.com/mweinberg/stratum-speed-test/issues/4) claim against the operator-side mechanics. Verified against the two known mainnet Parasite blocks.

## On-chain evidence

**Block 938,713** — coinbase tx `bde457e06ce61995c35ada890badefd74757f7031ae2a39999ba282814042ee2`:
- Output 0: **1.00000000 BTC** → `bc1qsmdhm009ukwayz90dkyydaw9qyk9zvvmz8ttae` (block-finder)
- Output 1: **2.14229255 BTC** → `bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp` (disputed pool address; ~68%)
- Output 2: 0 BTC OP_RETURN

**Block 945,601** — coinbase tx `b8217d473d02624d5e809ed2c92551ce72b9a799f18a9c6f0f0b32c716a643d8`:
- Output 0: **1.00000000 BTC** → `bc1q2l474n3qqpnmkg0y82ydt9f9jkyhz6dhqv04lt` (different finder, as expected)
- Output 1: **2.12678873 BTC** → `bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp` (same pool address)
- Output 2: 0 BTC OP_RETURN

Both coinbase scriptSigs contain the `|parasite|` tag.

## What the disputed address actually does

`bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp`:
- Total received: **6.76908827 BTC**
- Across only **8 transactions** total
- Current balance: **~0.00000699 BTC** (essentially drained)
- Pattern: aggressive — funds in, funds out, minimal retention

This profile is **consistent with a Lightning channel funding hot-wallet** (small UTXO count, fast turnover, low retained balance). It is **not** a cold-storage hoard.

## Verdict

| Claim | Status |
|---|---|
| Coinbase output #1 goes to a single address rather than fanning out on-chain | **Confirmed** — verified across both blocks |
| The address is operator-controlled and the operator "keeps" 68% | **Refuted by behavior** — address drains nearly to zero; matches a hot-wallet |
| The drained funds actually reach miners via Lightning as advertised | **Open / unprovable on-chain** — by design, LN payouts don't show on-chain; no published proof-of-payouts |
| The exact figure 2.15235992 BTC | **Not reproduced** — got 2.142 and 2.127 across the two known blocks; OP likely inspected a third |

The dispute is **half-true**: the structural observation (single-address output, no on-chain fanout) is correct. The inference (operator embezzlement) is not supported by the address's spend pattern. Definitive resolution requires either operator-published LN payout proofs or a community member receiving and tracing one.

## Sources

1. GitHub issue: https://github.com/mweinberg/stratum-speed-test/issues/4
2. Coinbase tx 938,713: https://mempool.space/tx/bde457e06ce61995c35ada890badefd74757f7031ae2a39999ba282814042ee2
3. Coinbase tx 945,601: https://mempool.space/tx/b8217d473d02624d5e809ed2c92551ce72b9a799f18a9c6f0f0b32c716a643d8
4. Pool address activity: https://mempool.space/address/bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp

## See also

- [[../../wiki/concepts/parasite-pool]] — concept article (updated with these findings)
- [[2026-05-26-zkshark-parasite-pool-substack]] — promotional source (does not address the dispute)
