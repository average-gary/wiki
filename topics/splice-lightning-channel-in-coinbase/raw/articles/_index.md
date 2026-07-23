---
title: splice-lightning-channel-in-coinbase — raw articles index
type: raw-index
---

# Raw: articles (14)

- [[2026-07-23-bitcoin-dev-reference-coinbase]] — Canonical dev reference: coinbase input structure + 100-block maturity. **[canonical-docs, high]** A/B.
- [[2026-07-23-optech-splicing]] — Optech splicing topic page: definition + implementation timeline; no coinbase topic exists. **[aggregator, high]** B/C.
- [[2026-07-23-optech-zero-conf-channels]] — Optech zero-conf channels: closes the "treat it as zero-conf" loophole for Reading B. **[aggregator, medium]** B.
- [[2026-07-23-jamesob-noncustodial-payouts-ctv]] — Delving #1753: CTV coinbase-fanout payouts; presign-a-coinbase-spend pattern + maturity handling. **[primary-thread, high]** B.
- [[2026-07-23-implementation-splice-in-docs]] — Phoenix/ACINQ + CLN `splicein`: splice any confirmed wallet UTXO (incl. matured coinbase). **[impl-docs, high]** Reading C, deployable today.
- [[2026-07-23-mining-payout-to-lightning-designs]] — OCEAN/NiceHash/Braidpool: all route around the naive claim (off-chain payout or matured-fund settlement). **[project-docs, medium]** context.
- [[2026-07-23-stackexchange-coinbase-open-channel]] — SE #115588: the exact question, answered "possible but impractical (maturity)." **[community-qa, low]** B.
- [[2026-07-23-ocean-bolt12-lightning-payouts]] — OCEAN: TIDES non-custodial coinbase payout + live BOLT12 (0.0105 BTC on-chain fallback); the comparator. **[project-docs, med-high]** Follow-up #3.
- [[2026-07-23-inbound-liquidity-provisioning-lsp-liquidity-ads]] — Dual funding / liquidity ads / LSPS1 / LSPS2-JIT: the actual inbound mechanisms (all counterparty-funded). **[aggregator-spec, high-med]** Follow-up #3.
- [[2026-07-23-splice-in-liquidity-refill-economics]] — Splice-in zero-downtime / 1-UTXO self-custody / one-tx refill; but one on-chain fee per splice. **[impl-docs, med-high]** Follow-up #3.
- [[2026-07-23-payout-rail-economics-dust-ecash-braidpool]] — Dust floor, ecash micro-payouts (hashpool), Braidpool one-way channels; revealed preference. **[aggregator-project, med-high]** Follow-up #3.
- [[2026-07-23-eclair-2861-phoenix-on-the-fly-deployed]] — eclair #2861 (merged 2024-09-25) + Phoenix: on-the-fly funding (splice OR dual-fund toward client) DEPLOYED — but as a wallet-LSP, not a pool. **[impl-docs, high-med]** Follow-up #3 (thesis 3).
- [[2026-07-23-batched-channel-opens-scale]] — Batched opens & multi-channel splices: interactive-tx multi-open, LSPS1 batch, LND `BatchOpenChannel`, CLN multi-splice. **[spec+impl, high-med]** Follow-up #3 — the scale axis (strongest pro).
- [[2026-07-23-no-pool-does-this-negative-result]] — Negative result: NO mining pool acts as an inbound-provisioning LSP; OCEAN does the opposite; custody/fee/maturity conditions. **[project-docs, med-high]** Follow-up #3 — the deployment gap + conditions map.
