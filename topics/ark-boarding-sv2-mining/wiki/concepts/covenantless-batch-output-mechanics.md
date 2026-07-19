---
title: "Covenantless n-of-n batch output mechanics (the CTV substitute)"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
tags: [n-of-n, batch-output, musig2, ephemeral-keys, pseudo-covenant, vtxo-tree, unilateral-exit, csv]
sources:
  - raw/articles/2026-07-17-ark-protocol-clark.md
  - raw/articles/2026-07-17-roose-ark-case-for-ctv.md
  - raw/repos/2026-07-17-flock-research-ark.md
  - raw/repos/2026-07-17-arkd-batch-event-handler.md
  - raw/papers/2026-07-17-bip-327-musig2.md
summary: "How the batch output works without a covenant: a Taproot output with an n-of-n MuSig2 cooperative key-path and a server+timeout script-path; all parties pre-sign the VTXO tree then delete ephemeral keys (secure if >=1 honest deletion). Unilateral exit via a CSV/CLTV branch. This is the CTV substitute the thesis reuses, applied to a coinbase-funded batch."
---

# Covenantless n-of-n batch output mechanics (the CTV substitute)

The thesis reuses clArk's covenant substitute wholesale; nothing here needs a soft
fork. See the parent topic [[../../../covenantless-ark/wiki/concepts/n-of-n-batch-output|n-of-n batch output]]
for the general Ark treatment; this article frames it for the mining-payout case.

## The output script

The batch output is a Taproot output with the node policy
`pk(S+A+B+C+…) OR (pk(S) AND after(T))`
([[../../raw/articles/2026-07-17-roose-ark-case-for-ctv.md|Roose #1528]]):

- **Cooperative key-path** — an n-of-n [[../../raw/papers/2026-07-17-bip-327-musig2.md|MuSig2]]
  aggregate of the server plus all VTXO owners beneath the node. A single aggregate
  Schnorr signature spends it; on-chain it looks like any single-key Taproot spend.
- **Sweep/timeout script-path** — `pk(S) AND after(T)`: the operator reclaims the
  output after an absolute timeout if nobody exited. The backstop.

## The pseudo-covenant = presign + delete

Instead of a CTV commitment constraining the spend, "all parties … create a
multisig address and then pre-sign the desired transactions using an all-of-all
signature scheme," then each participant **deletes their ephemeral signing key**
([[../../raw/articles/2026-07-17-ark-protocol-clark.md|ark-protocol.org]]). Once
the keys are gone, no alternative spend of the tree can ever be signed — a
covenant-like constraint emerges. Security = **1-of-n honest deletion**: it holds
"as long as at least one user in the entire group commits to deleting their key"
([[../../raw/repos/2026-07-17-flock-research-ark.md|flock research-ark]]). A real
CTV would remove even that assumption.

## The ceremony (what the SV2 extension would carry)

From arkd's batch-event protocol, the MuSig2 tree signing is a coordinator-pushed
event sequence ([[../../raw/repos/2026-07-17-arkd-batch-event-handler.md|arkd]]):

1. `TreeNoncesEvent` — each cosigner submits nonces (one per branch tx).
2. `TreeNoncesAggregatedEvent` — coordinator aggregates.
3. `TreeTxEvent` / `TreeSignatureEvent` — partial signatures, then combined.
4. Forfeit signing.

This maps directly onto BIP-327's two rounds (nonce exchange → partial-sig
exchange) and is the closest existing analog to what an
[[sv2-extension-surface.md|SV2 cosigning extension]] would encode.

## Unilateral exit

Each VTXO leaf carries an exit path — a relative-timelock (CSV) branch letting the
owner exit without operator cooperation. Exit = "broadcast every tree transaction
from root to your leaf … then a claim transaction after the CSV delay"
([[../../raw/repos/2026-07-17-flock-research-ark.md|flock]]). For the mining case,
this exit cannot execute until the coinbase matures — see
[[coinbase-maturity-and-reorg.md|coinbase maturity & reorg]].

## See Also

- [[post-block-found-signing.md|Post-block-found signing]] — why signing over the coinbase works at all
- [[pure-receiver-and-liveness.md|Pure-receiver / liveness problem]] — the cost of the "all pre-sign" requirement
- [[../../../covenantless-ark/wiki/concepts/tree-presigning-musig2|tree presigning (covenantless-ark)]]
