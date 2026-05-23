---
title: "p2poolv2 wiki — Comparison with DATUM and SV2"
source_url: https://github.com/p2poolv2/p2poolv2/wiki/Comparison-with-DATUM-and-SV2
type: project-wiki
ingested: 2026-05-22
quality: 5
confidence: high
tags: [p2poolv2, datum, sv2, positioning, design-philosophy]
---

# p2poolv2 wiki — Comparison with DATUM and SV2

The single best source for understanding p2poolv2's positioning relative to SV2 / SRI / DATUM.

## Core thesis
DATUM and SV2 decentralize **template construction** but still route **payouts** through centralized servers.

> The pay out distribution is decided by the centralised pools, with the template builders having no visibility on the share accounting.

## p2poolv2's three differentiators
1. **Decentralized share accounting** — the share-chain itself is the ledger; no pool operator's database holds share counts.
2. **Native decentralized templates** — every node builds its own templates from its own bitcoind.
3. **Non-custodial payouts** — direct coinbase outputs (top-N miners) plus atomic swaps for smaller miners.

## Attack-surface framing
Centralized share accounting is presented as an attack surface for **selective payout exclusion** — a pool can simply refuse to credit shares from disfavored miners (geopolitical, sanctioned, controversial). SV2's JDP doesn't fix this because the pool still runs the share ledger.

## Governance philosophy
Invokes Satoshi's P2P-vs-centralized framing as the rationale for going further than SV2.

## Why this matters for integration design
This document is the *design intent* that shapes how p2poolv2 should integrate with SV2. The integration must preserve decentralized share accounting — meaning a `JobValidationEngine` adapter for JDS would have p2poolv2 nodes serving *as* the JDS, not the share-accounting being delegated to a centralized JDS.
