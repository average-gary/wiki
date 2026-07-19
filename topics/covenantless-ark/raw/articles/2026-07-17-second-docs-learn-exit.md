---
title: "Ark emergency exits (Second/Bark docs)"
source: "https://second.tech/docs/learn/exit.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, emergency-exit, unilateral, csv, tree-depth, cancellable]
summary: "Bark's emergency-exit reference — board/refresh VTXOs exit truly unilaterally; spend VTXOs conditional on no sender+server collusion; sequential root→leaf broadcast with per-tx confirmation; cost scales with tree depth; exit cancellable until the leaf confirms."
---

# Ark emergency exits (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

## Unilaterality by VTXO type
- **Board & refresh VTXOs**: truly unilateral — "users can always exit without any possibility of prevention by the server or other parties."
- **Spend VTXOs**: conditional — "the exit can be prevented if the sender and Ark server collude to double-spend. As long as either the sender or server acts honestly, the exit will succeed."

## Broadcast sequence (ordered tree traversal)
1. Broadcast first branch tx from VTXO root
2. Wait for confirmation
3. Broadcast next branch tx in sequence
4. Repeat until reaching the leaf
5. Broadcast final exit tx (leaf)
- "Each transaction in this sequence must confirm before the next can be broadcast, making this a multi-step process."

## Timelock
- Relative timelock on the claim tx: "This timelock countdown begins when the exit transaction confirms, giving the Ark server and other users time to respond to any malicious exit attempts." (No numeric CSV value on this page; see [[2026-07-17-second-docs-learn-vtxo.md|VTXO page]]: `<144>` CSV.)

## Fees
- Cost depends on "their refresh VTXO's transaction tree depth... plus the length of any additional spend VTXO chain." No explicit CPFP detail here. "early exits reduce costs for later exiters" via shared tree branches.

## Exit-window / cancellability
- A partially-completed exit remains cancellable until "the final exit transaction (leaf) of the transaction tree is broadcast and confirmed on-chain."
