---
title: "p2poolv2 TLA+ ShareChain Specification"
source_url: https://github.com/p2poolv2/p2poolv2/tree/main/spec
type: formal-spec
ingested: 2026-05-22
quality: 4
confidence: high
tags: [p2poolv2, tla-plus, formal-methods, share-chain]
---

# p2poolv2 TLA+ ShareChain Specification

A single TLA+ file at `spec/ShareChain.tla` formally specifies p2poolv2's core consensus mechanics. Verifiable with the VSCode TLA+ extension or the TLA+ Toolbox, supports CLI model checking.

## Specification covers
- Share generation
- Share validation
- Longest-share-chain rule (chain-with-uncles, *not* a DAG/braid like Braidpool)
- Uncle-share organization on receipt of new shares

## What it does NOT cover (research gap)
- Payout semantics (direct coinbase to top-N miners, atomic-swap edges)
- Network protocol (libp2p gossip mechanics)
- **SV2 integration** — the share-chain semantics are not formally tied to SV2 share-accounting semantics anywhere

## Relevance for SV2 integration
The longest-chain + uncles model from this TLA+ spec defines the consensus rules a JDS-style p2poolv2 backend must respect when validating declared jobs. Any `JobValidationEngine` implementation needs to map SV2's `SubmitSharesExtended` semantics onto these rules — a non-trivial mapping that should be a follow-up formal-methods exercise.
