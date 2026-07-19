---
title: covenantless-ark — concepts
type: concepts-index
---

# covenantless-ark — concepts

Atomic concept articles. Each focuses on a single primitive, mechanism, or surface.

- [[clark-overview.md]] — what covenantless Ark is; the covenant substitution; two implementations
- [[clark-round-lifecycle.md]] — the round / batch-swap ceremony, phase by phase
- [[n-of-n-batch-output.md]] — the pooled on-chain output (sweep + unroll paths)
- [[vtxo-and-vtxo-tree.md]] — VTXOs, the virtual transaction tree, per-branch signing
- [[tree-presigning-musig2.md]] — the MuSig2 pseudo-covenant + ephemeral-key deletion
- [[forfeit-and-connectors.md]] — forfeit txs, connectors, hash-locks, forfeit-vs-exit
- [[dropout-and-round-abort.md]] — dropout, atomic abort, freeze, receiver-DoS griefing
- [[unilateral-exit-and-timeouts.md]] — unilateral exit, the two-clock timelock model, refund/sweep
- [[checkpoint-transactions.md]] — anti-griefing checkpoints, partial-exit + neighbour-exit attacks, two-output design
- [[boarding.md]] — bringing on-chain funds into a board VTXO
- [[out-of-round-payments.md]] — OOR / arkoor instant P2P payments
- [[offboarding-and-onchain-payments.md]] — cooperative single-tx exits; live-hArk immediate broadcast; connector swaps
- [[lightning-integration.md]] — the Ark server as Lightning gateway (HTLC send/receive)
- [[vtxo-lifetime-and-expiry.md]] — VTXO lifetimes, sweep, and the liquidity-cost formula
- [[ark-addresses-and-delivery.md]] — bech32m Ark addresses (BOAT-001), VTXO delivery, Unified Mailbox
