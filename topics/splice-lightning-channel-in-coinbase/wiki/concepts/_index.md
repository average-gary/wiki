---
title: Concepts — index
type: wiki-index
---

# Concepts (7)

- [[three-readings]] — the three readings of the claim (A literal / B charitable / C narrow-true) + verdict table.
- [[coinbase-transaction-structure]] — the consensus object: single null-prevout input, coinbase field, maturity, reorg, unknowable txid.
- [[lightning-splice-mechanics]] — BOLT #2: a splice spends the existing funding output and creates a new one; presupposes a live channel.
- [[coinbase-maturity-vs-ln-enforceability]] — the fatal wall on Reading B: 100-block maturity makes the channel unenforceable; why Ark tolerates it and LN can't.
- [[presigning-unknown-coinbase-outpoint]] — the *removable* wall: unknown coinbase txid; post-block-found signing and APO.
- [[inbound-vs-outbound-liquidity]] — follow-up #3: splice-in yields outbound, receiving consumes inbound; only a counterparty funding the far side creates inbound. The category error at the heart of the splice-vs-BOLT12 thesis.
- [[pool-as-lsp-inbound-provisioning]] — thesis #3: a pool/LSP contributing on its side gives the miner inbound (spec'd, deployed as wallet-LSP); `push_msat` omitted from `open_channel2` → pure splice/dual-fund carries capacity not value; JIT/on-the-fly is the one genuine payout+provision fusion. Batching + conditions.
