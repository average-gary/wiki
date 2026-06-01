---
title: "vnprc/hashpool — Cashu mining mint (SRI fork, 76 stars)"
source: https://github.com/vnprc/hashpool
type: repos
tags: [hashpool, cashu, ehash, sri-fork, forward-translator]
summary: "Most active SRI fork (76 stars). 11 services, eHash/Cashu mint integrated. Translator component is FORWARD direction (SV1 miner → SV2 pool). Hashpool runs its own SV2 pool against bitcoind, not against an SV1 upstream. Refutes the 'hashpool already needs reverse translator' framing."
confidence: high
ingested: 2026-05-28
ingested_by: path2
quality_score: 4
---

# vnprc/hashpool

## What it is

Cashu mining mint architecture: shares are minted as Cashu eHash bearer tokens, pool semantics are PPLNS-flavored. 11 services in the docker-compose stack. Most active SRI derivative.

## Direction analysis

The `proxy/` component in hashpool is a **forward** translator: SV1 miner → SV2 pool. This is the exact existing SRI translator-proxy pattern.

The pool component speaks SV2 directly to bitcoind via Template Provider — there is no upstream pool to translate to.

## Why this matters for the reverse-translator thesis

- Hashpool is *not* a customer of a reverse translator in its current shape.
- A future "hashpool-as-a-front-end" topology where hashpool issues eHash backed by another pool's PPLNS payout *would* need a reverse translator. This is a hypothesized but unrealized variant — see Path 5's hypothesis #5.

## See also

- [[../../bitcoin-mining-payout-schemas/wiki/concepts/ehash.md]] — eHash concept
- [[2026-05-28-path5-hashpool-vnprc-pioneerhash]] — broader hashpool ecosystem
