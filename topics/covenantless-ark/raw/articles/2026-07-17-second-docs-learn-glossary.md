---
title: "Ark protocol glossary (Second/Bark docs)"
source: "https://second.tech/docs/learn/glossary.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, hark, bark, glossary, terminology, arkoor, connector, sweep]
summary: "Bark's authoritative Ark glossary — definitions for Ark server, arkoor, board tx, branch, chain anchor, clArk, connector, delegated refresh, forfeit, hArk, in-round, leaf, root, round, sweep, transaction tree, VTXO, etc. Confirms clArk = recursive multisigs vs CTV; hArk = Jan 2026 hash-lock enhancement."
---

# Ark protocol glossary (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]]. Verbatim definitions.

- **Ark server**: "A central server that coordinates rounds, helps with boarding and off-boarding, deploys liquidity, and enables users to transact over the Lightning Network."
- **Arkoor**: "Short for 'Ark out-of-round'—the method used for Ark payments" (creates spend VTXOs).
- **Board transaction**: "The on-chain funding transaction created when a user boards onto Ark. Once confirmed, it serves as the chain anchor for the resulting VTXO."
- **Boarding**: "The process of getting bitcoin onto an Ark" (co-signing a special funding tx).
- **Branch**: "A series of interdependent, off-chain transactions that break up the round transaction into successively smaller chunks."
- **Chain anchor**: "The on-chain transaction output that a VTXO's validity depends on."
- **clArk**: "Short for 'covenant-less Ark'—an implementation variant that uses **recursive multisigs instead of CTV covenants**."
- **Connector**: "A mechanism that ensures forfeit transactions are only valid if a specific on-chain payment is broadcast."
- **Delegated refresh**: "Refreshing VTXOs by having designated co-signers sign on the user's behalf" (for mobile devices).
- **Exit transaction**: "A transaction that releases a user's bitcoin on-chain, at the leaf of a transaction tree."
- **Lifetime**: "The time limit set on VTXOs that requires users to spend or refresh their VTXOs before they expire."
- **Forfeit transaction**: "A transaction that allows a user to give up ownership of their VTXO."
- **hArk**: "Short for 'Hash-lock Ark'—a protocol enhancement introduced in **January 2026**."
- **In-round**: "A term used for VTXOs that are included in the transaction tree embedded in the round transaction."
- **Leaf**: "The final transaction in a branch, releasing a user's bitcoin on-chain."
- **Lightning gateway**: "A Lightning node connected to the Ark server that enables users to transact with the broader Lightning Network."
- **Malicious exit**: "An attempt by a user to broadcast VTXO transactions on-chain after forfeiting them."
- **Movement**: "A wallet-level operation that changes the state of one or more VTXOs."
- **Off-boarding**: "The standard, cooperative process of withdrawing bitcoin from Ark."
- **Refresh**: "The process of forfeiting old VTXOs for new ones during an Ark round."
- **Root**: "The single on-chain transaction that all associated branch and leaf transactions emanate from."
- **Round**: "A periodic event initiated by the Ark server where users can refresh their VTXOs."
- **Round transaction**: "The root transaction of a transaction tree that is broadcast on-chain during an Ark round."
- **Sweep**: "The process by which the Ark server transfers all forfeited bitcoin from an expired round."
- **Transaction tree**: "A hierarchical structure of transactions that enables UTXO-sharing."
- **Transaction tree depth**: "The number of transactions a user must broadcast to complete an emergency exit."
- **Emergency exit**: "The non-cooperative process of withdrawing bitcoin from Ark."
- **VTXO**: "Short for 'virtual unspent transaction output' or 'virtual UTXO'."
