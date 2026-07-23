---
title: "Prior art — coinbase & pool-transparency tooling"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [miningpool-observer, stratum.work, datum, job-declaration, 0xB10C, transparency, prior-art]
---

# Prior art — coinbase & pool-transparency tooling

What already exists, what each verifies, and the gap this daemon fills.

## Landscape

| Tool | Verifies | Vantage | Coinbase payout check? |
|------|----------|---------|------------------------|
| **miningpool.observer** (0xB10C) | Template↔block tx selection; missing/extra/sanctioned txs | External observer (own Core node) | **No — coinbase explicitly excluded** |
| **stratum.work** | Live decode of V1 `mining.notify`: coinbase, outputs, merkle branches, pool ID | External observer (V1 subscriber) | Decodes outputs, but doesn't assert vs an expectation |
| **DATUM** (OCEAN) | Miner *builds* & submits its own template/coinbase | Downstream miner | By construction, not audit |
| **SV2 Job Declaration** (JDC/JDS) | Miner declares coinbase prefix/suffix + tx set; JDS validates first-output pool payout & value | Downstream miner (JDC) vs pool (JDS) | Yes, inside the SV2 negotiation |
| **SV2 Template Distribution / TP** | Provides `coinbase_tx_value_remaining` (subsidy+fees) + outputs | Miner-side + node | Provides the *expected* value inputs |
| **0xB10C observations** | Pool attribution & misbehavior via coinbase tags + merkle branches | External observer | No |

— [[raw/repos/2026-07-21-miningpool-observer-0xb10c]],
[[raw/articles/2026-07-21-stratum-work-and-datum-coinbase-prior-art]],
[[raw/articles/2026-07-21-sv2-spec-job-declaration-protocol]],
[[raw/articles/2026-07-21-sv2-spec-template-distribution-protocol]]

## The gap

No existing tool does exactly *"connect as a downstream miner to a Stratum V2 pool and
assert the coinbase output pays an expected address/value."*
- miningpool.observer diffs templates↔blocks but **deliberately ignores the coinbase**.
- stratum.work decodes coinbase outputs live but doesn't assert per-miner expectations,
  and it's V1.
- SV2 JD does the check but only when the miner runs full Job Declaration (most pools
  don't offer it) — and it inverts the trust model (miner constructs the coinbase).

I found **no dedicated public "pool-skimming detector."** The niche is real and largely
unoccupied.

## What to reuse

- **`stratum-mining/stratum-sniffer`** (Rust) for V1/V2 wire parsing.
- SRI protocol libs ([[wiki/concepts/sri-client-crate-stack]]) for decoding
  `NewExtendedMiningJob` / coinbase prefix+suffix.
- The coinbase-output-decoding pattern proven by stratum.work; coinbase-tag attribution
  from 0xB10C's method.
- "Expected value" derivation mirrors SV2 TP's `coinbase_tx_value_remaining` minus
  declared pool splits.

## See also

- [[wiki/concepts/coinbase-verification-trust-model-limits]]
- [[wiki/topics/what-the-daemon-can-and-cannot-prove]]
- [[../datum/_index|datum]]
- [[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]]
