---
title: "Checkpoint transactions"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-implementations-arkade-os-docs.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/articles/2026-07-17-bark-repo-checkpoints-01-partial-exit-attack.md
  - raw/articles/2026-07-17-bark-repo-checkpoints-02-neighbour-exit.md
  - raw/articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md
tags: [ark, arkade, bark, checkpoint, anti-griefing, offchain, csv, exit, two-stage, partial-exit-attack, neighbour-exit]
aliases: [checkpoint transaction, checkpoint tx, partial-exit attack, neighbour exit]
summary: "Checkpoint transactions insert an extra two-output tx (policy A+S or S+T) into each off-chain spend so the server can defend against a griefing exit with a single on-chain tx and one user's exit cannot drag a neighbour's change VTXO on-chain. Present in both arkd/Arkade and bark; motivated by the partial-exit attack and the neighbour-exit problem."
---

# Checkpoint transactions

**Checkpoint transactions** sit between off-chain state transitions to bound the cost of defending against a griefing unilateral exit ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]]). They were originally documented as an arkd/Arkade construct, but the **bark** design docs describe the same mechanism (same `A + S or S + T` two-output checkpoint), so this is now understood as a **shared clArk primitive** rather than an arkd-only one ([[../../raw/articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md|bark checkpoints/03]]).

## Structure

A checkpoint tx has a Taproot two-path script:
- **A + S** — collaborative (user + operator);
- **S + CSV** (i.e. `S + T`) — server unilateral claim after a timelock.

It is "essentially a self-send of the user, but removing the exit script path from the VTXO script leaf, transferring it to the server." In the off-chain environment "no forfeit transaction is signed, but only once a VTXO is batch swapped." bark's docs describe the identical shift: the exit script path moves to the **server** after timeout `T`.

## The design — a two-output checkpoint per arkoor spend

bark's resolution ([[../../raw/articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md|checkpoints/03]]): "when making an arkoor-transaction we will add an extra checkpoint transaction" between the original VTXO and the new VTXOs. The script policies along the chain:

- **Original VTXO**: `A + S or A + delta`
- **Checkpoint outputs**: `A + S or S + T` (exit path shifts to the server after timeout)
- **New VTXOs**: `B + S or S + delta` / `A + S or S + delta`

The checkpoint deliberately has **two outputs**, and that shape solves both attacks:

- **Solves the neighbour-exit problem**: if Bob exits only *his* checkpoint output, "Alice's VTXOs would be unaffected — Alice can still use her change VTXO and the server can sweep the checkpoint after expiry." Each party's exit is isolated.
- **Solves the partial-exit attack**: against any attacker-built tree "the server just has to broadcast **a single exit transaction**," so the defensive cost no longer scales with the tree size.

**Caveat**: a checkpoint with a huge number of outputs would itself be expensive to broadcast, so "the server should limit the number of outputs in the checkpoint transaction."

## Purpose — anti-griefing

Checkpoints let the operator respond to a misbehaving unilateral exit with "one single onchain transaction" instead of broadcasting entire off-chain transaction chains. This caps the operator's on-chain cost when defending against [[dropout-and-round-abort.md|griefing]].

## Two motivating attacks (bark checkpoints trilogy)

bark's design docs give two concrete problems that exist *without* checkpoints, and both stem from the fact that the [[forfeit-and-connectors.md|forfeit]]-based penalty forces the server to broadcast off-chain transactions to enforce fraud claims.

### 1. The partial-exit attack

An attacker can make the server's defensive broadcast cost arbitrarily large ([[../../raw/articles/2026-07-17-bark-repo-checkpoints-01-partial-exit-attack.md|checkpoints/01]]):

1. Alice starts with one 1 BTC VTXO and spends it out-of-round into a transaction with **4 outputs**, repeating for each output. Doing this **5 times** yields **4⁵ = 1024 VTXOs** (a 4-ary [[out-of-round-payments.md|arkoor]] tree).
2. She **refreshes** all 1024 VTXOs in a round, receiving a **single** VTXO in return — so all 1024 leaves are now forfeited.
3. She performs a **malicious partial exit**, bringing only the **original** VTXO on-chain and claiming its funds after `exit_delta` blocks.

The server now faces a dilemma: **publish the full tree (>1000 txs)** to enforce the forfeits and pay the on-chain cost, or **lose the funds**. "Alice can make this attack exponentially more effective by splitting the tree one level more." The forfeit penalty is thus economically defeatable, because the defensive cost scales with the *attacker-chosen* tree size.

### 2. The neighbour-exit problem

Because an arkoor payment's **change VTXO shares a transaction** with the recipient's VTXO, one user's unilateral exit can drag an innocent third party's funds on-chain ([[../../raw/articles/2026-07-17-bark-repo-checkpoints-02-neighbour-exit.md|checkpoints/02]]). If Bob exits, he broadcasts the shared transaction, forcing **Alice's change VTXO** on-chain too — imposing unexpected on-chain cost on Alice "through no action of her own." Ark users "want predictability," and having your funds hit the chain because of someone else's exit violates that.

## Role in unilateral exit

For **preconfirmed (out-of-round) VTXOs**, checkpoints make the [[unilateral-exit-and-timeouts.md|unilateral exit]] a **two-stage** process ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]):
1. Broadcast the checkpoint transaction(s), gated by `checkpointExitDelay` CSV (default 86400 s / 24 h).
2. Broadcast the ark transaction spending the checkpoint output, gated by `unilateralExitDelay` CSV (default 86400 s / 24 h).

## Offchain execution flow

Checkpoints appear in arkd's 3-step offchain protocol: the client sends `SubmitTxRequest` with a signed Arkade tx + **unsigned checkpoint txs**; the server returns the fully-signed Arkade tx + **partially-signed checkpoints**; the client sends `FinalizeTxRequest` with fully-signed checkpoints, and the spend is **preconfirmed** ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]]).

## See also

- [[unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]]
- [[forfeit-and-connectors.md|Forfeit transactions and connectors]]
- [[out-of-round-payments.md|Out-of-round payments]]
- [[dropout-and-round-abort.md|Dropout, round abort, and griefing]]

## Sources

- [Arkade docs](../../raw/articles/2026-07-16-implementations-arkade-os-docs.md) — checkpoint structure, "self-send removing the exit path," anti-griefing purpose
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — two-stage OOR exit via checkpointExitDelay + unilateralExitDelay
- [Partial exit attack (bark checkpoints/01)](../../raw/articles/2026-07-17-bark-repo-checkpoints-01-partial-exit-attack.md) — the 4⁵ = 1024-VTXO forfeit-broadcast DoS
- [Neighbour exit (bark checkpoints/02)](../../raw/articles/2026-07-17-bark-repo-checkpoints-02-neighbour-exit.md) — shared-tx change VTXO dragged on-chain
- [Designing checkpoints (bark checkpoints/03)](../../raw/articles/2026-07-17-bark-repo-checkpoints-03-designing-checkpoints.md) — the two-output checkpoint construction and script policies
