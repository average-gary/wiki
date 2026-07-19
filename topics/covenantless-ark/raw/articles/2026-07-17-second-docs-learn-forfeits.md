---
title: "Ark forfeits (Second/Bark docs)"
source: "https://second.tech/docs/learn/forfeits.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, forfeit, hashlock, preimage, connector, csv, exit-delta, atomicity]
summary: "Bark's forfeit reference — two exit-tx spend paths (2-of-2 server-controlled no-timelock vs user-only CSV exit_delta); rounds use hash-lock/preimage atomicity, on-chain payments use connectors."
---

# Ark forfeits (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

## Purpose
- Forfeits are "pre-signed transactions used in refreshes and on-chain payments to grant the Ark server control over the VTXOs being spent."

## Exit transaction — two spend paths
- **Path 1 (server-controlled)**: 2-of-2 multisig user+server, **no timelock**. User pre-signs this as the forfeit, letting the server broadcast immediately if the exit appears on-chain.
- **Path 2 (user emergency exit)**: "Controlled solely by the user... relative timelock of `{{ ark.vtxo_exit_delta }}` blocks... implemented using **OP_CHECKSEQUENCEVERIFY (CSV)**."

## Hash-lock mechanism (rounds)
- Refreshes use "**hash-locks instead of connectors**." Server generates a **preimage** per new VTXO and shares its hash. Both the new VTXO and the forfeit carry hash-lock conditions — neither executes on-chain without the preimage.
- Atomicity: if the server withholds the preimage, the user can still exit their old VTXO ("the hash-locked forfeit cannot be executed without it"). Server revealing the preimage on-chain simultaneously grants the user access to their new VTXO.

## Connector mechanism (on-chain payments)
- Payments/offboards use **connectors**: "connectors ensure that a user's forfeit is only valid if the corresponding on-chain payment is confirmed." Payment tx includes destination + connector outputs; forfeit depends on the connector's existence.
- "either the payment completes and the forfeit is valid, or neither happens."
