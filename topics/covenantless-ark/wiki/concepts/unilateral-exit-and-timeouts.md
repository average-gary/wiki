---
title: "Unilateral exit, timeouts, and the refund path"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-evolution-roose-hark-erk.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/repos/2026-07-16-implementations-arkd-go-source.md
  - raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md
  - raw/articles/2026-07-16-implementations-arkade-os-docs.md
  - raw/articles/2026-07-17-second-docs-learn-exit.md
  - raw/articles/2026-07-17-second-docs-learn-vtxo.md
  - raw/articles/2026-07-17-second-docs-learn-lifetime.md
tags: [ark, clark, unilateral-exit, emergency-exit, timeout, refund, csv, cltv, expiry, sweep, exit-delta, truc, p2a, exit-window, cancellable]
aliases: [unilateral exit, emergency exit, timeout refund, sweep, exit window]
summary: "clArk's self-custody guarantee: broadcast your pre-signed tree branch and spend through a timeout (CSV) leaf without the operator. Two-clock model (absolute T_exp sweep vs relative exit-delta). bark: board/refresh VTXOs exit truly unilaterally, spend VTXOs are collusion-conditional; sequential root-to-leaf broadcast (CSV <144> ~1 day), cancellable until the leaf confirms; cost scales with tree depth. Client-side exit-data storage is the covenantless-specific burden."
---

# Unilateral exit, timeouts, and the refund path

The **unilateral exit** is clArk's self-custody guarantee: if the ASP disappears, censors, or refuses to cooperate, a user can force their [[vtxo-and-vtxo-tree.md|VTXO]] on-chain **without the operator**, by broadcasting the pre-signed tree branch and then spending through a **timeout (CSV) refund path**. This is the timeout-driven refund path at the heart of the covenantless design.

## The two-clock timelock model

clArk uses two kinds of timelock together ([[../../raw/articles/2026-07-16-evolution-roose-hark-erk.md|Roose hArk/Erk]]):

- **`T_exp` — absolute expiry** (batch/VTXO expiry height). After this, the [[n-of-n-batch-output.md|batch output]]'s sweep path lets the **operator** reclaim funds. It bounds liveness so later VTXO owners don't inherit indefinite online obligations.
- **`Δt` — relative exit delay** (a CSV on the VTXO's unilateral leaf). After a user's exit tx confirms, they must wait `Δt` before the owner-only claim input is valid.

The relative `Δt` guarantees **spend-clause precedence**: a [[forfeit-and-connectors.md|forfeit]] must be broadcastable *before* the exit branch matures, so the operator can always penalize a fraudulent exit of an already-forfeited VTXO.

## Default timelock values

Implementation- and deployment-configurable; representative defaults:

| Parameter | arkd default | ark-protocol.org | bark |
|---|---|---|---|
| VTXO tree / batch expiry (`T_exp`) | 604672 s (~7 d) | 14 d | ~30 d |
| Unilateral exit delay (`Δt`) | 86400 s (24 h) | 24 h | `vtxo_exit_delta` blocks (CSV) |
| Checkpoint exit delay | 86400 s (24 h) | — | — |
| Boarding exit delay | 7776000 s (~90 d) | — | — |

arkd timelocks are **second-based** and must be BIP-68 multiples of 512 ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]], [[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|arkd source]]).

## Unilaterality depends on the VTXO type (bark)

bark's emergency-exit docs draw a sharp line by [[vtxo-and-vtxo-tree.md|VTXO type]] ([[../../raw/articles/2026-07-17-second-docs-learn-exit.md|bark exit docs]]):

- **Board & refresh VTXOs**: **truly unilateral** — "users can always exit without any possibility of prevention by the server or other parties."
- **Spend VTXOs (arkoor)**: **conditional** — "the exit can be prevented if the sender and Ark server collude to double-spend. As long as either the sender or server acts honestly, the exit will succeed." This is the statechain-like caveat from [[out-of-round-payments.md|out-of-round payments]], surfacing at exit time.

## The exit procedure

For a **leaf VTXO** (direct batch recipient): broadcast the minimal tree branch from the commitment tx down to your leaf via the "exit closure tapscript path," then wait `Δt`, then spend to a sole-control on-chain output ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). bark describes the same as an ordered tree traversal: broadcast the first branch from the VTXO root, wait for it to confirm, broadcast the next in sequence, and repeat down to the final leaf exit tx — "each transaction in this sequence must confirm before the next can be broadcast." bark's per-user exit CSV is concretely **`<144> OP_CHECKSEQUENCEVERIFY` (~1 day)** ([[../../raw/articles/2026-07-17-second-docs-learn-vtxo.md|bark VTXO docs]]); the countdown starts when the exit tx confirms, "giving the Ark server and other users time to respond to any malicious exit attempts."

**Cancellability**: a partially-completed exit remains **cancellable until the final leaf exit transaction is broadcast and confirmed on-chain** — so a user who started exiting but then reconnected to a cooperative server need not finish the costly on-chain unroll ([[../../raw/articles/2026-07-17-second-docs-learn-exit.md|bark exit docs]]).

For a **preconfirmed (out-of-round) VTXO**, arkd uses a **two-stage** exit: Stage 1 broadcast the [[checkpoint-transactions.md|checkpoint tx(s)]] gated by `checkpointExitDelay` CSV; Stage 2 broadcast the ark tx spending the checkpoint output, gated by `unilateralExitDelay` CSV.

Physical on-chain sequence ([[../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md|instagibbs/boats]]):
- Presigned exit txs are published "in chain order (each spends an output of the previous)" under **TRUC/v3** "1-parent-1-child" topology; each level enters the mempool only after the previous confirms.
- Exit txs carry **no built-in fee** — each needs a **CPFP child spending the P2A anchor** to pay. A basic exit tx is **124 vB**; deep chains accumulate cost, and wallets "SHOULD expose the total cost estimate."
- Cost = **O(log t)** in the batch size — the depth of your branch (litepaper §2.3).
- Claim-side relative timelocks vary by clause: pubkey = `exit_delta`; HTLC-send recovery = `2 * exit_delta`; HTLC-recv = `htlc_expiry_delta + exit_delta`.

## The refund / operator-sweep backstop

The other side of the timeout is the **operator's expiry sweep** — the batch output's sweep path (`CSVMultisigClosure`, operator signature after `T_exp`). arkd's sweeper queries `GetSweepableRounds()`, computes `expiryTimestamp = blockTime + vtxoTreeExpiry`, and broadcasts a sweep tx collecting expired tree outputs; sweep tasks are DB-backed and survive restarts. "If a user's VTXO is still active when the batch expires and they have not renewed it, the operator can claim those funds" ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]]). This is the "use it or lose it" liveness mechanism.

## The exit-window race (mass-exit concern)

A VTXO is only safely exitable while "current height + exit confirmation time" still leaves room before `expiry_height`; "once the expiry leaves become spendable the server can race the exit" ([[../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md|instagibbs]]). Users must therefore start exits well before expiry, and a **mass exit** under fee-market congestion erodes that safety margin — see [[../topics/clark-limitations-and-trust.md|limitations]]. Exit can even cost more than a small VTXO is worth (a dust-like economic constraint).

## The covenantless storage burden

Because there is no covenant, the user must **persist all data needed to reconstruct the exit chain** ("the full VTXO encoding suffices") independently of the server — lose it and unilateral exit is impossible ([[../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md|instagibbs]]). CTV variants remove this burden. See [[../topics/clark-vs-covenant-ark.md|clArk vs covenant Ark]].

## The cooperative alternative

The unilateral exit is the **fallback**, not the default. When the server is responsive, users should instead **offboard** — a single cooperative transaction — rather than pay the multi-step on-chain unroll. See [[offboarding-and-onchain-payments.md|offboarding and on-chain payments]].

## See also

- [[n-of-n-batch-output.md|The n-of-n batch output]]
- [[forfeit-and-connectors.md|Forfeit transactions and connectors]]
- [[checkpoint-transactions.md|Checkpoint transactions]]
- [[dropout-and-round-abort.md|Dropout and round abort]]
- [[offboarding-and-onchain-payments.md|Offboarding and on-chain payments]]
- [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[../topics/clark-limitations-and-trust.md|Limitations and trust model]]

## Sources

- [Roose — hArk / Erk](../../raw/articles/2026-07-16-evolution-roose-hark-erk.md) — the two-clock timelock model
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — leaf-VTXO exit, two-stage checkpoint exit, second-based timelocks
- [arkd Go source](../../raw/repos/2026-07-16-implementations-arkd-go-source.md) — sweeper, `GetSweepableRounds`, expiry propagation
- [instagibbs / boats exit spec](../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md) — TRUC/v3 chain-order broadcast, P2A CPFP, 124 vB, O(log t), exit-window race, storage burden
- [Arkade docs](../../raw/articles/2026-07-16-implementations-arkade-os-docs.md) — operator expiry sweep, "use it or lose it"
- [Ark emergency exits (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-exit.md) — unilaterality by VTXO type, ordered broadcast, cancellability
- [Ark VTXOs (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-vtxo.md) — CSV `<144>` (~1 day) exit timelock
- [VTXO lifetime (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-lifetime.md) — sweep at expiry, concurrent exit rights
