---
title: "Stratum V2 spec — 07 Template Distribution Protocol + sv2-tp Template Provider"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/07-Template-Distribution-Protocol.md
source_url_2: https://github.com/stratum-mining/sv2-tp
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "prior-art agent"
tags: [stratum-v2, template-distribution, NewTemplate, coinbase_tx_value_remaining, CoinbaseOutputConstraints, sv2-tp, template-provider]
summary: "SV2 Template Distribution Protocol — push-based getblocktemplate replacement. NewTemplate carries coinbase_prefix, coinbase_tx_outputs, coinbase_tx_value_remaining (subsidy+fees), so a miner can compute the EXPECTED coinbase value. Template Provider ships as Bitcoin Core or the standalone C++ sv2-tp binary."
---

# SV2 spec — 07 Template Distribution Protocol

Push-based replacement for `getblocktemplate` between a Bitcoin node and the job
declarator / miner.

## Template Provider (TP)

- The **Template Provider** is Bitcoin Core (Sjors's SV2 TP work) or the standalone
  **`sv2-tp`** C++ binary. It proactively sends `NewTemplate` when fees rise or a new
  block appears.

## NewTemplate coinbase fields (how to compute "expected value")

- **`coinbase_prefix`** — ≤8 bytes at the start of the coinbase input field.
- **`coinbase_tx_outputs`** — serialized pool payout outputs.
- **`coinbase_tx_value_remaining`** — satoshis available to coinbase outputs =
  **subsidy + fees**. This is the ground-truth "expected total value" number.
- **`coinbase_tx_outputs_count`**.

## CoinbaseOutputConstraints

The client first sends **`CoinbaseOutputConstraints`**
(`coinbase_output_max_additional_size`, `coinbase_output_max_additional_sigops`) so
the TP reserves blockspace/sigops and can't be tricked into building a
consensus-invalid oversized block.

## Assembly + submission

Coinbase = `coinbase_prefix` + TP-provided outputs + pool/miner outputs within the
constraints. `SubmitSolution` returns the **full serialized coinbase tx** so the TP
builds and propagates the block.

## Relevance

`coinbase_tx_value_remaining` (subsidy+fees) minus declared pool splits is exactly
the number a verify-daemon compares an observed coinbase output value against. Also
notes **`stratum-sniffer`** (SRI org) as reusable V1/V2 wire-monitoring infra.
