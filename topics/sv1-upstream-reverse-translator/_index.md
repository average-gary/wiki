---
title: "SV1-Upstream Reverse Translator"
type: topic-wiki
status: active
created: 2026-05-28
updated: 2026-05-28
summary: "A reverse-translator role that lets a Stratum V2 client (miner / proxy / pool-front) speak to a Stratum V1 upstream pool. Inverse of the SRI translator-proxy. Enables mining with the underlying SV2 stack while submitting work upstream to legacy SV1 pools."
---

# SV1-Upstream Reverse Translator

Knowledge base for a **reverse-direction Stratum translator**: SV2 downstream/internal stack → SV1 upstream pool.

The canonical SRI translator-proxy goes SV1 miner → SV2 pool. This topic explores the *opposite* direction: SV2 stack on the operator side talking to a still-SV1 pool. Useful for migration paths, pool inertia, and hashrate-broker patterns where the operator wants SV2's local benefits without forcing the upstream pool to upgrade.

## Master Indexes

- [[wiki/_index.md]] — compiled articles
- [[raw/_index.md]] — source material
- [[output/_index.md]] — generated artifacts (plans, playbooks)
- [[theses/_index.md]] — testable claims
- [[log.md]] — session log

## Related Wikis

- [[../sv2-p2pool-integration/_index.md]] — SV2 pool deployment surface (forward-direction)
- [[../iroh-transport-stratum-v2/_index.md]] — SV2 transport alternatives (parallel concern)
- [[../bitcoin-mining-payout-schemas/_index.md]] — payout context the upstream pool dictates
