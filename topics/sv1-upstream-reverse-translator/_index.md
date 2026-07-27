---
title: "SV1-Upstream Reverse Translator"
type: topic-wiki
status: active
created: 2026-05-28
updated: 2026-07-27
compiled: 2026-07-27
summary: "A reverse-translator role that lets a Stratum V2 client (miner / proxy / pool-front) speak to a Stratum V1 upstream pool. Inverse of the SRI translator-proxy. Enables mining with the underlying SV2 stack while submitting work upstream to legacy SV1 pools. As of 2026-07-27 the code-side gap is closed: warioishere/blitzpool-rental-proxy is a deployed bidirectional implementation, though the spec-side gap (SV2 spec §10.4.5 blank, sv2-spec issue #102 open) remains."
---

# SV1-Upstream Reverse Translator

Knowledge base for a **reverse-direction Stratum translator**: SV2 downstream/internal stack → SV1 upstream pool.

The canonical SRI translator-proxy goes SV1 miner → SV2 pool. This topic explores the *opposite* direction: SV2 stack on the operator side talking to a still-SV1 pool. Useful for migration paths, pool inertia, and hashrate-broker patterns where the operator wants SV2's local benefits without forcing the upstream pool to upgrade.

## Master Indexes

- [[wiki/_index.md]] — compiled articles (8 articles; last compiled 2026-07-27)
- [[raw/_index.md]] — source material
- [[output/_index.md]] — generated artifacts (plans, playbooks)
- [[theses/_index.md]] — testable claims
- [[log.md]] — session log

## Recent Changes

- **2026-07-27 (compile): the "greenfield" conclusion retired across the wiki.** New article [[wiki/concepts/prior-art-blitzpool-rental-proxy|prior-art-blitzpool-rental-proxy]]; all 7 existing articles updated. Key changes: issue-102 now separates the still-open *spec* gap from the closed *code* gap; the `stratum_translation` estimate moved from ~150 LOC to a 500–1000 LOC budget; upstream switching gained a cause-based strategy (reconnect for operator-initiated, in-place for failover); the pdiff-vs-bdiff difficulty convention is flagged as an unresolved internal contradiction leaning bdiff; the authority-key loss is now shown structural; the hashrate-broker segment moved to supported-at-small-scale; the playbook opens with a read-the-prior-art step and records that SRI's crates.io releases don't compile together.
- **2026-07-27 (ingest):** [[raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator|warioishere/blitzpool-rental-proxy]] — a deployed (beta, v0.3.1) Rust hashrate-rental proxy that hand-authors the SV2-miner→SV1-pool leg in `src/proto/translate.rs`, exactly because `stratum_translation` ships only the SV1→SV2 leg. Confirms this wiki's Path-1 finding.
- 2026-05-28: Topic created; 34 sources across 5 research paths → 7 compiled articles.

## Related Wikis

- [[../sv2-p2pool-integration/_index.md]] — SV2 pool deployment surface (forward-direction)
- [[../iroh-transport-stratum-v2/_index.md]] — SV2 transport alternatives (parallel concern)
- [[../bitcoin-mining-payout-schemas/_index.md]] — payout context the upstream pool dictates
