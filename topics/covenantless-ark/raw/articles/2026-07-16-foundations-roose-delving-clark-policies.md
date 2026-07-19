---
title: "Evolving the Ark protocol using CTV and CSFS (Delving Bitcoin #1602)"
source_url: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
type: article
authors: [Steven Roose, Erik De Smedt]
publisher: Delving Bitcoin
date: 2025-04-15
ingested: 2026-07-16
research_path: foundations
credibility: high
confidence: high
quality_score: 5
tags: [ark, clark, covenantless, node-policy, leaf-policy, exit-policy, forfeit, connector, ctv, csfs, rebindable-signatures, interactivity, griefing]
summary: Protocol author Steven Roose (bark/clArk lead) states the exact current clArk node/leaf/exit script policies, the round signing-session ordering, and names interactivity + synchronicity as the covenantless design's core defects motivating CTV/CSFS successors (Erk, hArk).
---

# Evolving the Ark protocol using CTV and CSFS (Delving Bitcoin #1602)

Steven Roose (author of the `bark`/clArk implementation) + Erik De Smedt, Apr 15–16 2025. The authoritative statement of what clArk is TODAY vs the CTV+CSFS successors.

## Exact clArk script policies (covenantless, in-production)
- **Node policy**: `(A + B + C + ... + S) or (S + T_exp)` — an intermediate tree node.
- **Leaf policy**: `(A + S) or (S + T_exp)`
- **Exit policy**: `(A + S) or (A + T_exp + Δt)`
- where A/B/C are user keys, S is the server (ASP) key, T_exp is the batch-expiry timelock.

## The n-of-n recursion is the covenant substitute
- "Each *node policy* contains a multisig with all the public keys of all the leaves below it."
- Because presigned transactions must commit to all descendant leaf keys, clArk "requires an extra phase in which all clients sign (their branch of) the tree." This recursive n-of-n presigning is what CTV/CSFS would eliminate.

## Forfeit + connector mechanics (current clArk)
- Forfeit tx takes two inputs: the exit-tx output and a **connector**, described as "a special-purpose descendant of the next round's funding tx."
- Effect: "the server can only enforce the forfeit if the next round successfully confirmed" — binding forfeiture to on-chain confirmation of the reissuing round.

## Round signing-session ordering
- "Once all users have signed forfeit txs for their input vtxos, the server can sign the funding tx and broadcast it to the network."
- I.e., users presign the VTXO tree and their forfeit txs FIRST; the operator broadcasts the on-chain funding (commitment/pool) tx LAST, once it holds all forfeits.

## Core criticism (designer self-critique)
- "users have to do something synchronously and the bad actions of certain users will affect all other users" — the canonical steelman of BOTH the liveness burden and the griefing surface (they are the same problem: a round is an all-or-nothing synchronous ceremony).
- clArk **cannot** do offline refresh; listed as a NEW property unlocked only by covenants: "offline refresh (server can refresh for a user)" and "perpetual offline refresh."

## What covenants would change
- CTV+CSFS enable "rebindable signatures" (APO-like semantics) so "signatures don't commit to the input utxos," allowing asynchronous single-user round signup (send a new pubkey A' + a signed refund tx) and perpetual offline refresh — removing the synchronized n-of-n signing session clArk requires.
- Even the Erk successor notes residual exit cost: to retaliate/exit the server "has to unroll the entire new vtxo's tx tree branch. This is particularly problematic for onboard vtxos."
