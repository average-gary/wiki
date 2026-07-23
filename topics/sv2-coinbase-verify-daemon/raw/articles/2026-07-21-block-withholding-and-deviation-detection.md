---
title: "Block withholding + coinbase deviation detection (Optech, APoW arXiv, mempool API)"
source_url: https://bitcoinops.org/en/topics/block-withholding/
source_url_2: https://arxiv.org/html/2601.02496
source_url_3: https://mempool.space/docs/api/rest
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "gap-4 agent"
tags: [block-withholding, deviation-detection, job-diff, on-chain-correlation, mempool-api, esplora, APoW, sybil, undetectable]
summary: "Detection design for the 'signed != broadcast' gap: intra-channel job-diff heuristic (anchor coinbase changes to SetNewPrevHash), on-chain correlation loop (own bitcoind or mempool.space/Esplora), sybil auditing feasibility — and the hard limits (block withholding is provably undetectable from share stats without a consensus change; off-chain payout correctness is orthogonal)."
---

# Block withholding + coinbase deviation detection

## Block withholding (Optech + APoW arXiv 2601.02496, 2026)

- Definition (Optech): a miner "submits and receives payment for shares that are not
  eligible to become full blocks but doesn't submit shares that are eligible to become
  full blocks." Asymmetry: attacker loses ~0.1% income, victim loses 100% of a block
  reward. Optech: **"We are unaware of any deployed method that fully addresses this
  problem."**
- APoW (arXiv 2601.02496, 2026): PoW is asymmetric — solutions are publicly verifiable
  but "unsuccessful search effort leaves no auditable trace." Pools "cannot distinguish
  deliberate suppression from statistical fluctuation using only share statistics";
  detection needs long windows + gives "weak confidence." A fix (verification-mining)
  needs a **consensus-level change + new ASICs**. Payment taxonomy: PPLNS
  (block-conditioned) → strong resistance; PPS/FPPS (share-conditioned) → BWA strictly
  profitable.

## Intra-channel job-diff heuristic

Payout outputs live in `coinbase_tx_suffix`; the height push/tags in
`coinbase_tx_prefix`; extranonce is the middle. Compare each new `NewExtendedMiningJob`
to the last on the same channel and **anchor every coinbase change to a `SetNewPrevHash`**:

| Observation | Verdict |
|---|---|
| Only extranonce region differs | benign (normal rolling) |
| Coinbase changed *with* a fresh `SetNewPrevHash` | benign-expected (new height → new coinbase) |
| Suffix value/fee changed, first-output address+tag unchanged, no new prevhash | low/watch (fee refresh; pools rebuild ~30s per 0xB10C) |
| **First-output payout scriptPubKey (or tag) changed with NO `SetNewPrevHash`** | **HIGH** — no consensus reason to change payout mid-prevhash |
| `merkle_path` inconsistent with served coinbase vs header being hashed | **HIGH** — served coinbase not committed to the work |

## On-chain correlation loop

On a new block at working height H (own bitcoind ZMQ `hashblock`, or poll
mempool.space/Esplora `/api/blocks/tip/height`): fetch `getblockhash(H)` →
`getblock hash 2` tx[0], or `GET /api/block-height/H` → `/api/block/:hash/txid/0`.
Coinbase JSON: `vin[0].is_coinbase`, `scriptsig_asm` (tag); `vout[].scriptpubkey_address`
+ `value` (sats). Compare on stable fields (payout address, tag, ~value) to what the pool
served for H; alert on mismatch. **Own bitcoind is strictly stronger** (no 429 rate
limits, no third-party trust, immediate ZMQ notification).

## Sybil auditing

Running multiple daemon identities (separate connections/tokens) against one pool and
diffing served coinbases *can* detect "pool serves different payouts to different
workers" (SV2 JD allows per-worker coinbase variation — "not prohibited, not prevented").
Caveats: pools can fingerprint/correlate sybils and serve them identically; legitimate
per-worker addresses exist; detects served-differently, not mined-differently. Advanced/
optional, false-positive prone.

## Fundamentally UNDETECTABLE by an external coinbase checker

- **Block withholding** — you see shares/jobs, never the pool's relay of full solutions.
- **Per-miner discrimination against workers you don't run** — only diffable across your
  own identities.
- **Off-chain / internal accounting payouts** — PPS/FPPS/PPLNS pay off-chain from pool
  balances; the on-chain coinbase pays the *pool*. Coinbase inspection ≠ ledger audit.
- **The pool's true internal template** — you compare against a reference (your node /
  served jobs), never the pool's actual state; ~30s refresh + mempool divergence give
  irreducible false-positive risk.
