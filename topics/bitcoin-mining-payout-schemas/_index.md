---
title: Bitcoin Mining Payout & Accounting Schemas
type: topic-index
created: 2026-05-23
updated: 2026-07-17
compiled: 2026-07-17
lint: 2026-07-15
status: active
summary: Payout and share-accounting schemas for Bitcoin mining pools — PPLNS, FPPS, PPS+, PPLNS-JD, hashpool.dev (Cashu ecash mints), btc++ event payout/accounting tracks, p2pool / p2poolv2 share-chain accounting, Parasite Pool (lottery + decay-EMA hybrid), Radpool (DLC+FROST decentralized FPPS).
---

# Bitcoin Mining Payout & Accounting Schemas

Survey of how Bitcoin mining pools account for hashrate contributions and pay miners. Centralized variance-smoothing schemes (FPPS, PPS+) versus risk-sharing schemes (PPLNS), versus Stratum-V2-job-declared variants (PPLNS-JD), versus decentralized share-chain accounting (p2pool / p2poolv2), versus ecash-redemption mints (hashpool.dev).

## Top-level questions

1. What are the canonical payout schemas (PPS, PPLNS, FPPS, PPS+, SOLO) and what risks does each one shift to whom?
2. How does Stratum V2 Job Declaration change accounting — what is "PPLNS-JD" and which pools claim to run it?
3. How does hashpool.dev use Cashu ecash mints to redenominate shares as bearer tokens, and what trust assumptions does that introduce?
4. How does p2pool / p2poolv2 do payout via a coinbase-output share-chain — what are PPLNS window semantics in a decentralized chain?
5. What was discussed in the btc++ payout/accounting tracks (Riga, Austin, Salvador) about decentralizing or improving pool accounting?
6. Cross-cutting: how do payout schemes interact with custody (custodial vs non-custodial), variance, fee policy, and SV2 negotiated job submission?

## Sections

- [[wiki/concepts/_index|Concepts]] — schema definitions (PPLNS, FPPS, PPS+, share difficulty, variance, hashrate luck)
- [[wiki/topics/_index|Topics]] — synthesis articles comparing schemes, mapping the design space
- [[wiki/reference/_index|Reference]] — pools, projects, repos, specs, conference talks
- [[wiki/decisions/_index|Decisions]] — design tradeoffs and ADRs
- [[wiki/theses/_index|Theses]] — testable claims about payout schemes

## Sources

- [[raw/_index|Raw sources]]

## Related wikis

- [[../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — JDS share-chain integration with SV2 reference apps (narrower scope)
- [[../coinbase-rotation-bitcoin/_index|coinbase-rotation-bitcoin]] — coinbase rotation / payout-output handling (older, narrower)

## Recent Changes

- 2026-07-17: Compiled vnprc/coinbase-playground collection (6 sources) → new concept [[wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]]; integrated flat/layered-tree numbers into payout-schema-taxonomy and ark-for-mining-payouts. Last compiled: 2026-07-17.
- 2026-07-15: Compiled demand-share-accounting-ext → [[wiki/concepts/sv2-share-accounting-ext|SV2 Share Accounting Extension]].

## Log

See [[log]].
