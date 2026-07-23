---
title: "Deviation detection — job-diff + on-chain correlation"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, deviation-detection, job-diff, on-chain-correlation, block-withholding, sybil, mempool-api, alerting]
---

# Deviation detection — job-diff + on-chain correlation

Turning the "signed ≠ broadcast" and "served-differently" gaps
([[wiki/topics/what-the-daemon-can-and-cannot-prove]]) into concrete alerting, plus the
hard limits.

## (1) Intra-channel job-diff heuristic

Payout outputs live in `coinbase_tx_suffix`; height/tags in `coinbase_tx_prefix`;
extranonce is the middle. Compare each new `NewExtendedMiningJob` to the last on the same
channel and **anchor every coinbase change to a `SetNewPrevHash` event**:

| Observation | Verdict |
|-------------|---------|
| Only the extranonce region differs | benign (normal rolling) |
| Coinbase changed *with* a fresh `SetNewPrevHash` | benign-expected (new height → new coinbase) |
| Suffix value/fee changed; first-output address + tag unchanged; no new prevhash | low / watch (fee refresh — pools rebuild ~30s) |
| **First-output payout scriptPubKey (or tag) changed with NO `SetNewPrevHash`** | **HIGH** — no consensus reason to change payout mid-prevhash |
| `merkle_path` inconsistent with served coinbase vs the header being hashed | **HIGH** — served coinbase not committed to the work |

Keep a rolling per-prevhash baseline of {first-output address, tag, value distribution};
alert on payout deltas within the same prevhash epoch.
— [[raw/articles/2026-07-21-block-withholding-and-deviation-detection]]

## (2) On-chain correlation loop

The strongest check: compare what the pool *served* against what actually got *mined*.

```
on new block at working height H (own bitcoind ZMQ hashblock, or poll mempool.space/Esplora):
    hash = getblockhash(H)                 # or GET /api/block-height/H
    cb   = coinbase = tx index 0           # getblock hash 2 → tx[0], or /api/block/:hash/txid/0
    extract: vout[0].scriptpubkey_address, total value (sats), vin[0].scriptsig_asm tag
    compare on stable fields to coinbase(s) served for H  →  mismatch ⇒ ALERT
```

**Own bitcoind is strictly stronger** than an explorer (no 429 rate limits, no
third-party trust, immediate ZMQ). Map coinbase→pool identity via the
[[raw/data/2026-07-21-mining-pools-attribution-dataset|mining-pools dataset]].
Limits: you only see blocks the pool actually **broadcast**; ~30s template refresh means
compare stable fields (address/tag/~value), not raw bytes; gate on N-confirmation depth
against reorgs.

## (3) Sybil auditing (advanced/optional)

Running multiple daemon identities against one pool and diffing served coinbases *can*
detect per-worker payout discrimination (SV2 JD allows per-worker coinbase variation —
"not prohibited, not prevented"). But pools can fingerprint/correlate sybils, legitimate
per-worker addresses exist, and it only detects *served*-differently, not
*mined*-differently. False-positive prone.

## Fundamentally undetectable

- **Block withholding** — you see shares/jobs, never the pool's relay of full solutions.
  Optech: "no deployed method fully addresses this." APoW (arXiv 2601.02496): undetectable
  from share statistics without a consensus change.
- **Discrimination against workers you don't run.**
- **Off-chain accounting payouts** — PPS/FPPS/PPLNS pay off-chain; coinbase pays the pool.
  Coinbase inspection ≠ ledger audit.
- **The pool's true internal template** — you only compare against a reference.

## See also

- [[wiki/topics/what-the-daemon-can-and-cannot-prove]]
- [[wiki/concepts/coinbase-verification-trust-model-limits]]
- [[wiki/concepts/prior-art-coinbase-verification]]
- [[wiki/concepts/sourcing-the-expected-value]]
