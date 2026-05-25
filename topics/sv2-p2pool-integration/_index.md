---
title: SV2 ↔ P2Pool Integration
type: topic-index
created: 2026-05-22
updated: 2026-05-22
status: active
summary: How to integrate p2poolv2 (decentralized share-chain pool) with sv2-apps (Stratum V2 reference implementation). Architecture surface, share-accounting, JDS job-validation, and operational paths.
---

# SV2 ↔ P2Pool Integration

Topic wiki investigating how [p2poolv2](https://github.com/p2poolv2/p2poolv2) — a decentralized share-chain pool protocol — would integrate with the Stratum V2 application stack at [stratum-mining/sv2-apps](https://github.com/stratum-mining/sv2-apps).

## Anchors
- **sv2-apps repo**: `/Users/garykrause/repos/sv2-apps`
- **p2poolv2 repo**: https://github.com/p2poolv2/p2poolv2
- **SV2 spec**: https://github.com/stratum-mining/sv2-spec

## Top-level questions
1. What is the architecture of p2poolv2 today, and where does its share-chain consensus live?
2. What surfaces in sv2-apps are pluggable (JobValidationEngine, TemplateProviderType, channel_manager, downstream)?
3. Is p2pool best implemented as: (a) a JDS validation engine, (b) a custom SV2 Template Provider, (c) a peer of the Pool role, or (d) a wholly new role?
4. How does SV2 share accounting (shares_rejected_total, payout identity) interact with p2pool's PPLNS / share-chain accounting?
5. What spec/coordination work is needed (sv2-spec extensions, p2poolv2 stratum integration)?

## Sections
- [[wiki/concepts/_index|Concepts]] — protocol pieces and definitions
- [[wiki/topics/_index|Topics]] — synthesized integration discussions
- [[wiki/reference/_index|Reference]] — code, specs, repos, datasets
- [[wiki/decisions/_index|Decisions]] — architectural decisions
- [[wiki/theses/_index|Theses]] — testable claims about integration paths

## Sources
- [[raw/_index|Raw sources]]

## Outputs
- [[output/plan-sv2-p2pool-repo-2026-05-22|Spec: sv2-p2pool repo (2026-05-22)]] — vendoring plan, full pool replacement, capnp IPC Phase 2
- [[output/plan-swarm-issues-2026-05-25|Roadmap: agentic swarm closing 9 issues (2026-05-25)]] — DAG, aggressive autonomy on impl, ADRs for design

## Log
See [[log]].
