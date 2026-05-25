---
title: "p2poolv2 wiki: Trading Shares For Bitcoin (HTLC scripts)"
publication: github.com/p2poolv2/p2poolv2/wiki + docs/atomic-swap/
url: https://github.com/p2poolv2/p2poolv2/wiki/Trading-Shares-For-Bitcoin
url2: https://github.com/p2poolv2/p2poolv2/blob/main/docs/atomic-swap/htlc_scripts.md
url3: https://github.com/p2poolv2/p2poolv2/blob/main/docs/atomic-swap/p2pool-2-lightinig-example.md
type: article
ingested: 2026-05-24
quality: 4
credibility: high
confidence: medium
tags: [p2poolv2, atomic-swap, HTLC, P2WSH, P2TR, market-maker, Lightning]
---

# p2poolv2 — Trading Shares For Bitcoin

How small miners (whose shares fall outside the coinbase-output cap) get paid: **HTLC outputs on the share-chain**, redeemable atomically with Bitcoin or Lightning.

## Two-window constraint

Coinbases are tradable only after **~2880 share-chain blocks** (≈1 Bitcoin day at 30s share intervals) AND before they fall **inside the active PPLNS accounting window**. Shares inside the active PPLNS window cannot be traded — they're still earning future payouts.

So the trading window is: `share_age ≥ 2880 share-blocks AND share_age < window_expiry`.

## HTLC script forms

Both **P2WSH** and **P2TR** variants:

- **P2WSH**: 33-byte compressed pubkeys.
- **P2TR**: 32-byte x-only Schnorr keys; uses a NUMS key-path to force script-path spending of the three branches.

### Three spend paths (both forms)

1. **Success** — preimage + redeemer signature. `OP_SHA256 <secretHash> OP_EQUALVERIFY` style.
2. **Mutual instant refund** — 2-of-2 multisig. Cooperative cancel.
3. **Initiator refund** — `<waitTime> OP_CSV OP_DROP` then initiator sig. Relative timelock via `OP_CHECKSEQUENCEVERIFY`.

## Cross-chain atomicity (Lightning example)

From `docs/atomic-swap/p2pool-2-lightinig-example.md`:

1. Alice (small miner) generates a Lightning invoice with preimage R.
2. Reuses `payment_hash = sha256(R)` to lock 10,000 P2Pool shares in a P2Pool HTLC.
3. Bob (market maker) pays the Lightning invoice.
4. Alice reveals R to settle the invoice.
5. Bob uses R to redeem the share-chain HTLC.

Same `payment_hash` on both sides → cross-chain atomic.

## "Support transaction" = share-chain HTLC

The earlier wiki used the term "support transaction" for small-miner payouts. **The current docs don't use that term.** Functionally, the equivalent is the **P2Pool HTLC output** on the share chain plus its redeem transaction.

## What's NOT yet specified

- **Timelock specifics** are explicitly marked "yet to be specified" in the docs.
- **Market-maker incentives / fees** — not formalized. No published haircut rate; no published market-maker selection algorithm.
- **No minimum-takeup guarantee**: small miners must trade or lose value at window expiry; there's no obligation for market makers to buy specific addresses' shares.

## Critique surface

This is the most-attacked part of the design (per delvingbitcoin contrarians):

- **Market-maker monopsony**: small miners face forced-sale deadline; large miners face no buy obligation. Pricing power skews.
- **Censorship vector**: market makers can refuse to swap shares from sanctioned/disfavored addresses → reproduces OFAC-style filtering inside a "decentralized" pool.
- **No deterministic share-buying algorithm** specified.

## See also

- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting modules]]
- [[../articles/2026-05-24-p2poolv2-critiques|p2poolv2 critiques]]
