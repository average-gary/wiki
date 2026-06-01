---
title: "DATUM Gateway Wiki"
description: "OCEAN's DATUM Gateway — miner-side block template construction client, Stratum v1 server, and DATUM-Protocol bridge to DATUM Prime pools."
created: 2026-05-28
freshness_threshold: 70
---

# Wiki Configuration

## Scope

- The `datum_gateway` C codebase (OCEAN-xyz/datum_gateway) and the in-tree Rust port (`datum_gateway_rust/`).
- The DATUM Protocol surface as documented in this repo and OCEAN materials.
- Configuration, deployment, Stratum username semantics, and pool/node integration.
- Explicit out-of-scope: TIDES reward math (lives in `bitcoin-mining-payout-schemas`), SV2 alternatives (live in `stratum-sri`, `sv2-p2pool-integration`), Bitcoin Knots policy details beyond what DATUM directly requires.

## Conventions

- Default volatility: `warm` for protocol/config docs (still beta, evolving), `cold` for ASIC quirks documented in usernames.md, `hot` for any pool-side claims (DATUM Prime is closed-source; surface may shift).
- Cross-link DATUM concept article in `bitcoin-mining-payout-schemas` rather than re-defining DATUM from scratch.
