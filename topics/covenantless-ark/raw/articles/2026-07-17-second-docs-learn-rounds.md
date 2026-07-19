---
title: "Ark rounds (Second/Bark docs)"
source: "https://second.tech/docs/learn/rounds.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, round, musig2, taproot, hashlock, forfeit, cadence]
summary: "Bark's five-phase round lifecycle, the Taproot/MuSig single-sig-appearance of the tree, per-branch user signing, hash-locked forfeit atomicity, and a stated 1-2h round cadence. Shared expiry across all VTXOs in a round."
---

# Ark rounds (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

## Round lifecycle — five phases
1. **Submit intent** — "Wallet app comes online during round and submits VTXOs to refresh"
2. **Tree construction** — "Server constructs transaction tree; wallet app signs exit branches"
3. **Funding** — "Server broadcasts round transaction on-chain"
4. **Forfeit** — "Wallet app signs forfeit to complete refresh"
5. **Claim** — "New VTXO immediately accessible"

## Round transaction & tree
- Rounds produce a hierarchical tree with a single on-chain root, the **"round transaction."**
- Protocol uses "**Taproot and MuSig** to make this complex script appear on-chain as a simple single-signature transaction."
- Users participate in collaborative signing where they "sign its own branches in the transaction tree." Server constructs the full tree before users sign their exit branches.

## Forfeit & atomicity (hash-lock)
- Atomicity relies on "**hash-locked forfeit transactions**."
- "the server cannot claim the old VTXO without also revealing the preimage—which in turn gives the user access to their new VTXO."

## Timing & cadence
- "Second's Ark server is expected to conduct rounds **every 1-2 hours**, though this may vary based on demand and server policy."
- All VTXOs created in a round "share the same expiry time."

## Dropout/abort
- The page does NOT explicitly define dropout/abort behavior. It notes that **delegated refreshes fail if a required co-signer is unavailable**, but no protocol-level abort mechanics are detailed here. (See arkd's explicit "any participant fails → round aborted" in [[../repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]].)
