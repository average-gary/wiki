---
title: "Stratum V2 Specification — 07-Template-Distribution-Protocol.md"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/07-Template-Distribution-Protocol.md
source_type: specification
ingested: 2026-05-28
credibility: high
confidence: high
tags: [stratum-v2, template-distribution, NewTemplate, BIP34, coinbase_prefix]
---

# 07 — Template Distribution Protocol

## Why this matters
Defines the upstream-of-Pool coinbase skeleton (from bitcoind / Template Provider). Establishes the bytes *the Pool starts with* before it adds its own bytes.

## Key claims (with quotes)
- `NewTemplate` carries: `template_id, future_template, version, coinbase_tx_version, coinbase_prefix (B0_255 — "Up to 8 bytes... placed at the beginning of the coinbase field"; this is BIP-34 height), coinbase_tx_input_sequence, coinbase_tx_value_remaining, coinbase_tx_outputs_count, coinbase_tx_outputs, coinbase_tx_locktime, merkle_path`.
- The Template Provider supplies a *skeleton* — the Pool finishes the coinbase before pushing to miners.

## Reading on the thesis
- TP gives Pool ~8 bytes of mandatory BIP-34 height plus outputs/locktime/version. Everything between BIP-34 height and `extranonce` is **Pool-controllable scriptSig real estate** (subject to the 100-byte total scriptSig limit).
- This is the byte budget where a Pool would put `/pool_tag/miner_tag/` — confirmed by SRI's reference implementation (see ingested SRI code notes).
