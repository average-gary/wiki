---
title: "clArk round transaction mechanics — end to end"
type: topic
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/papers/2026-07-16-foundations-ark-litepaper.md
  - raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md
  - raw/repos/2026-07-16-implementations-arkd-go-source.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md
  - raw/articles/2026-07-17-second-docs-learn-rounds.md
  - raw/articles/2026-07-17-second-docs-learn-vtxo.md
  - raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md
tags: [ark, clark, round, batch-output, presigning, forfeit, dropout, unilateral-exit, timeout, synthesis, hark]
aliases: [round transaction mechanics, round mechanics, batch swap mechanics]
summary: "The load-bearing end-to-end synthesis: how a covenantless Ark round works as a transaction system — n-of-n batch output, MuSig2 tree presigning, dropout/freeze, forfeit atomicity, and the timeout refund/exit path — now noting the two tree radices (arkd 2 / bark 4) and the live-hArk shift from connector to hash-lock round forfeits."
---

# clArk round transaction mechanics — end to end

This is the load-bearing synthesis for the research question: how a **covenantless Ark round** works as a transaction system — the **n-of-n batch output**, **tree presigning**, **dropout/freeze**, and the **timeout refund/exit path**. It stitches together the atomic concepts; follow the links for detail and sources.

## The object being built

A round produces **one on-chain transaction** — the **round transaction** (Second) / **commitment transaction** (Ark Labs/litepaper) — with two key outputs:

- **Output 0 — the [[../concepts/n-of-n-batch-output.md|n-of-n batch (pool) output]]**: a Taproot output, unspendable key path, two script paths — an **unroll path** (spend via the pre-signed [[../concepts/vtxo-and-vtxo-tree.md|VTXO tree]]) and a **sweep path** (operator claims after absolute expiry `T_exp`).
- **Output 1 — the [[../concepts/forfeit-and-connectors.md|connector]] tree root**: dust anchor outputs that bind each user's forfeit to this transaction's confirmation.

The batch output roots a **VTXO tree** — **binary (radix 2) in arkd**, but a **quad tree (radix 4) in bark** — whose leaves are the individual VTXOs handed to users. The tree transactions are "virtual" — pre-signed but optimistically never broadcast. bark uses Taproot + MuSig so the whole tree "appears on-chain as a simple single-signature transaction."

## Why it's "covenantless"

There is no `OP_CTV`. The tree's structure is enforced by an **n-of-n MuSig2 [[../concepts/tree-presigning-musig2.md|pre-signature]]** of the server plus every VTXO owner below each node — policy `(A + B + ... + S) or (S + T_exp)` — combined with **ephemeral-key deletion**. Once at least one honest participant deletes their per-round cosigner key, the tree can never be re-signed differently. This 1-of-n honesty assumption is the price of avoiding a soft fork.

## The round, step by step

1. **Intent** — users come online, submit the VTXOs to refresh, desired new-VTXO parameters, and ephemeral cosigner keys (BIP322-signed intents in Arkade). Window ≈ 30 s (arkd) to ~1 h cadence (bark). See [[../concepts/clark-round-lifecycle.md|round lifecycle]].
2. **Assembly** — operator builds the *unsigned* commitment tx (batch + connector outputs), VTXO tree, and connector tree.
3. **Tree signing (MuSig2)** — clients generate a nonce per branch tx → `AggregateNonces` → partial `Sign` (sorted keys + sweep tweak) → `CombineSigs`. Each user signs only their branch (~log₂(n) txs after the Ark Labs optimization).
4. **Forfeit** — each user signs a **forfeit tx** (two inputs: old VTXO + connector; version-3/TRUC with a P2A anchor in arkd) handing back their old VTXO. Atomicity: the forfeit is valid **only if the commitment tx confirms** (connector in arkd; hash-lock preimage in bark rounds). Under bark's **live January-2026 hArk**, the round forfeit commits only to a **preimage/hash** rather than the whole funding tx — the mechanism that enables non-interactive refresh but breaks in-round offboards (see [[../concepts/forfeit-and-connectors.md|forfeits and connectors]]).
5. **Broadcast** — *only after holding every forfeit* does the operator sign and broadcast the commitment tx. New VTXOs activate on confirmation; old ones are invalidated.

**Ordering is the safety property**: users sign the tree + forfeits FIRST, operator broadcasts LAST.

## Dropout / freeze

The round is **atomic** — "if any participant fails to submit, the round is aborted," with no on-chain footprint; honest users retry next round. See [[../concepts/dropout-and-round-abort.md|dropout and round abort]].

The deep problem is the **receiver-DoS asymmetry**: a pure receiver has no VTXO at stake, "can't be penalized and [has] nothing to lose in performing a DoS attack on the round." So clArk cannot safely admit receivers — round participation is effectively **refresh-only (send-to-self)**, and real payments to others go through [[../concepts/out-of-round-payments.md|out-of-round (OOR)]] transfers. Roose's one-liner: "users have to do something synchronously and the bad actions of certain users will affect all other users." The interactivity/liveness burden and the griefing surface are the same property.

## Timeout refund / unilateral exit path

Two clocks govern the exit ([[../concepts/unilateral-exit-and-timeouts.md|unilateral exit and timeouts]]):

- **`T_exp`** (absolute, ~7 d arkd / 14 d ark-protocol.org / ~30 d bark): after expiry the operator's **sweep path** reclaims un-exited funds. This is the ASP-side refund/reclaim.
- **`Δt`** (relative CSV, ~24 h arkd): after a user's exit tx confirms, they wait `Δt` before the owner-only claim is valid. `Δt` guarantees a [[../concepts/forfeit-and-connectors.md|forfeit]] is broadcastable *before* the exit branch matures, enabling the fraud penalty.

**Unilateral exit** = broadcast the pre-signed branch from batch root down to your leaf (in chain order, TRUC/v3, P2A-anchor CPFP for fees), wait `Δt`, then spend to sole control. Cost is **O(log t)** in the batch size; deep chains can cost more than a small VTXO is worth. For preconfirmed OOR VTXOs the exit is **two-stage** via [[../concepts/checkpoint-transactions.md|checkpoint transactions]].

**Two critical covenantless properties of the refund path**:
- The user must **store the presigned exit data client-side** — lose it and exit is impossible (a covenant would remove this).
- There is an **exit-window race**: exits must complete before `T_exp`, or the server races and sweeps; a mass exit under congestion erodes the margin.

## The forfeit-vs-exit duality

The same connector/forfeit machinery is both the **refresh mechanism** and the **fraud penalty**: an honest exit uses the `CSVMultisigClosure` (owner after `Δt`); a *fraudulent* exit of an already-forfeited VTXO lets the operator claim the funds via the forfeit tx (`MultisigClosure`/`CLTVMultisigClosure` + connector). The relative timelock ordering is what makes the penalty enforceable.

## One-paragraph mental model

A clArk round is an atomic, synchronous ceremony in which the ASP and a set of users MuSig2-pre-sign a tree that will subdivide a single n-of-n-locked on-chain output into per-user VTXOs; users hand back old VTXOs via connector-bound (or hash-locked) forfeits before the ASP broadcasts the root; each VTXO carries a cooperative 2-of-2 spend path and a timeout-delayed unilateral-exit path, while the whole pool carries a longer absolute-expiry sweep path that lets the ASP reclaim anything left un-refreshed. The covenant is faked by pre-signing plus key-deletion, which is exactly why everyone must be online, why a griefer can abort a round, and why users must hoard their exit transactions.

## See also

- [[clark-vs-covenant-ark.md|clArk vs covenant-based Ark]]
- [[clark-limitations-and-trust.md|Limitations and trust model]]
- [[clark-evolution.md|Evolution: tree-signing, OOR, delegation, hArk/Erk]]
- [[../concepts/offboarding-and-onchain-payments.md|Offboarding and on-chain payments]]
- [[../concepts/vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[../reference/clark-glossary-and-timelocks.md|Glossary + timelock reference]]

## Sources

- [Ark litepaper](../../raw/papers/2026-07-16-foundations-ark-litepaper.md) — batch output, VTXT, forfeit/connector constructions
- [Roose, Delving #1602](../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md) — node policy, broadcast-last ordering, recursive signing
- [arkd Go source](../../raw/repos/2026-07-16-implementations-arkd-go-source.md) — concrete MuSig2 ordering, tx structure, radix 2
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — round atomicity, output order, two-stage exit
- [Roose, Delving #1528](../../raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md) — receiver-DoS asymmetry
- [Ark rounds (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-rounds.md) — bark five-phase lifecycle, Taproot/MuSig, hash-locked forfeits
- [Ark VTXOs (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-vtxo.md) — quad tree (radix 4)
- [On-chain payments (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md) — live-hArk immediate broadcast
