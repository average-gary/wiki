---
title: "Coinbase maturity & reorg constraints on a post-block-found batch"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: cold
verified: 2026-07-17
tags: [coinbase-maturity, reorg, 100-blocks, timelock, cpfp, proxy-utxo, capital-lockup]
sources:
  - raw/articles/2026-07-17-braidpool-covenants-delving.md
  - raw/papers/2026-07-17-bip-341-taproot.md
summary: "A separate, real constraint — not a signing blocker. If the n-of-n batch output IS the fresh coinbase output, the VTXO tree cannot be broadcast or exited for 100 blocks (~16.7h) and a reorg in that window voids the whole batch. The workable design boards a MATURED proxy UTXO into the batch, which softens the clean 'post-block-found' timing story into 'post-maturity boarding'."
---

# Coinbase maturity & reorg constraints on a post-block-found batch

Post-block-found timing solves the *signing* problem
([[post-block-found-signing.md|see here]]) but not the *inclusion* problem. See the
parent fact article [[../../../sighash-anyprevout-bip118/wiki/concepts/coinbase-maturity-and-unknown-txid|coinbase maturity & unknown txid]].

## The two constraints

1. **100-block maturity (~16.7 h).** A coinbase output cannot be spent until 100
   blocks deep — a consensus rule protecting against reorgs. A presigned spend is a
   *valid signature* the moment the coinbase exists, but the transaction is
   **non-includable** until maturity. So the VTXO tree/unilateral-exit cannot be
   broadcast for ~16.7 h after the ceremony.
2. **Reorg.** If the block that produced the coinbase is orphaned during that
   window, the coinbase — and therefore the entire batch output funded by it, and
   every VTXO beneath it — **ceases to exist**. Signatures over it become spends of
   a nonexistent outpoint.

Braidpool names both as hard requirements: coinbase maturity "needs extra timelock
layering," alongside a solo-mining fallback for pool failure
([[../../raw/articles/2026-07-17-braidpool-covenants-delving.md|Delving #1370]]).

## The design consequence: board a matured proxy UTXO

The clean thesis reading — "fund the fresh coinbase into an n-of-n batch and sign
post-block-found" — is broken by reorg risk: you would be issuing VTXOs against
funds that can vanish. The practical fix, consistent with how Braidpool handles it,
is to **board a matured UTXO** (one already ≥100 blocks deep, funded from an earlier
coinbase) into the batch — so the ceremony runs over funds that cannot be reorged
away. This turns "post-block-found ceremony" into "**post-maturity boarding**": the
per-block trigger (e.g. this repo's `NewBlockFound`) can still *schedule* payouts,
but the on-chain batch commits matured funds.

This is a **cost, not a blocker**: it adds capital lockup / a rolling maturity lag
and means the batch isn't literally the block's own coinbase. It does not require
any new opcode.

## Fee-bumping a fixed presigned tx

Because the presigned tree is fixed, it cannot dynamically consume value for fees;
an **anchor output for CPFP** (or `SIGHASH_ANYONECANPAY` fee crowdsourcing) is the
standard handling — all available today.

## See Also

- [[post-block-found-signing.md|Post-block-found signing]] — the signing side (solved)
- [[../topics/thesis-analysis-viability.md|Viability analysis (verdict)]]
- [[../../../sighash-anyprevout-bip118/wiki/concepts/coinbase-maturity-and-unknown-txid|coinbase maturity & unknown txid (parent)]]
