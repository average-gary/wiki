---
title: "The n-of-n batch (pool) output"
type: concept
created: 2026-07-16
updated: 2026-07-16
confidence: high
tags: [ark, clark, batch-output, pool-output, taproot, sweep-path, unroll-path, expiry]
---

# The n-of-n batch (pool) output

The **batch output** (litepaper term; also **pool output** in older Ark writeups, **batch output** in Arkade) is the single on-chain output the [[clark-round-lifecycle.md|round transaction]] creates to hold the pooled funds of all participants. It is the root of the pre-signed [[vtxo-and-vtxo-tree.md|VTXO tree]].

## Script structure (litepaper Def 4.3)

The batch output is "locked by a taproot script `batchScript` with an unspendable key path and **exactly two script paths**" ([[../../raw/papers/2026-07-16-foundations-ark-litepaper.md|Ark litepaper]]):

1. **Sweep path** — "allows the Ark operator to claim the entire output after a time T_e, which we call the *batch expiry*." This is the timeout/refund backstop that lets the ASP reclaim funds nobody exited. See [[unilateral-exit-and-timeouts.md|timeouts]].
2. **Unroll path** — "specifies spending according to a VTXT [virtual transaction tree] with root spending the full batch, where each leaf of the VTXT has a VTXO as its only output." This is the cooperative path that subdivides the pool into individual VTXOs.

The Taproot **key path is unspendable** — there is no key that can move the whole output arbitrarily; spends must take one of the two script paths. In arkd, `BuildBatchOutput` generates this taproot script and amount; the sweep path is a `CSVMultisigClosure` requiring the operator's signature after the delay ([[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|arkd source]]).

## Why "n-of-n"

The unroll path's first tree transaction is spendable only by an **n-of-n MuSig2 aggregate** of the server plus all VTXO owners beneath it. Roose states the node policy as `pk(S+A+B+C+..) OR (pk(S) AND after(T))` — the everyone-cooperates branch, or server-alone-after-timeout ([[../../raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md|Roose, Delving #1528]]). Because the aggregate requires every owner's signature, the pre-signed tree cannot be re-signed differently once ephemeral keys are deleted — this *is* the [[tree-presigning-musig2.md|pseudo-covenant]].

## On-chain layout of the commitment tx

In arkd the commitment (round) transaction places outputs in a fixed order ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]):

- **Output 0**: VTXO tree root (the batch output, P2TR) — present when a batch exists
- **Output 1**: [[forfeit-and-connectors.md|connector]] tree root — "always at index 1 when present, and may be the second output even if no batch output exists"
- **Outputs 2+**: on-chain collaborative exit payments
- **Final output**: operator change (if above dust)

## Expiry and the two-clock model

The batch output carries an **absolute** expiry timelock `T_exp` (the sweep path). Individual VTXO exit leaves carry a **relative** exit-delay timelock `Δt`. See [[unilateral-exit-and-timeouts.md|unilateral exit and timeouts]] for how the two interact and the default values (arkd: ~7-day tree expiry, 24-hour exit delay).

## See also

- [[vtxo-and-vtxo-tree.md|VTXOs and the VTXO tree]]
- [[tree-presigning-musig2.md|Tree presigning (MuSig2)]]
- [[unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]]
- [[forfeit-and-connectors.md|Forfeits and connectors]]
