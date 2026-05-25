---
title: SV2 Job Declaration ↔ Payout Decoupling
type: topic
created: 2026-05-23
confidence: high
tags: [SV2, JD, Stratum-V2, decoupling, payout, template]
---

# SV2 Job Declaration ↔ Payout Decoupling

Why **Job Declaration** is the protocol-level prerequisite for the 2024-2026 payout-scheme reform.

## The bundling problem in Stratum V1

Under Stratum V1, the pool sends `mining.notify` containing the full block template. The miner runs nonce-extranonce search inside that template. This bundles two services into one connection:

1. **Block template construction** (which transactions to include)
2. **Share accounting** (counting hashes contributed)

A V1 pool that wants to count shares MUST also choose the block content. There's no protocol mechanism to separate the two.

## SV2 Job Declaration unbundles

SV2 introduces two roles:
- **Job Declarator Server (JDS)** — runs pool-side; receives template declarations, allocates payout tokens.
- **Job Declarator Client (JDC)** — runs miner-side; selects transactions, builds template, declares to JDS.

Two modes:
- **Coinbase-only mode**: JDS only sees the coinbase output. Miner template content is private.
- **Full-template mode**: JDC sends txids; JDS may request full txs via `ProvideMissingTransactions`.

The spec text in SV2-spec §6 is explicit:

> *"Pools…are only responsible for accounting shares and distributing rewards."*

The pool counts shares; the miner picks the block content.

## Why this enables every modern payout scheme

| Scheme | Uses JD | How |
|---|---|---|
| FPPS | No | Pool builds template, owns variance, owns custody |
| TIDES | Optional (DATUM) | TIDES is the share-counting; DATUM is the JD-equivalent for OCEAN |
| TIDES + DATUM | Yes (DATUM) | Miner picks template; pool counts shares per TIDES |
| SLICE / PPLNS-JD | Yes (mandatory) | Shares are bound to JD-declared jobs; pool only counts |
| eHash / hashpool | Yes (SV2-native) | Pool issues blind sigs per share; share is the bearer token |
| p2poolv2 | Yes (SV2 + share-chain) | Miner picks template; share-chain (not pool) counts |

## The latency win

SV2 binary encrypted framing reduces job-switch latency from ~200-300 ms (V1) to **1-3 ms**. Stale-share rate drops from 0.5-2% to **0.0151%** at DMND.

This matters for PPLNS-class schemes specifically: high stale rates make miners' variance worse without compensating fee reduction. Low stale rates are what makes PPLNS-class schemes economically competitive with FPPS at small scale.

## The encryption win

SV2 Noise-over-TCP (or alternative transports like Iroh/QUIC) eliminates the SV1 plaintext attack surface. DMND reports zero hash-hijack incidents since launch. For payout schemes, this matters because:
- Miners can't have their declared jobs intercepted and rewritten by a hostile relay.
- Pool can't be MITM'd to credit shares to a different miner.
- The integrity of the share→payout chain is cryptographic, not network-trust.

## Implication for the wiki

Without SV2 + JD, payout-scheme reform is rearranging accounting in custodial pools. With SV2 + JD, the pool is reduced to a **share-counter and possibly a custodian** — both removable in principle. This is the structural reason the 2024-2026 wave clusters around the SRI v1.0 release in March 2024.

## Sources

- [[../../raw/repos/2026-05-23-stratum-v2-spec|Stratum V2 Specification (sv2-spec) — §5 Mining, §6 JD]]
- [[../../raw/articles/2026-05-23-dmnd-demand-pool|DMND — SLICE / PPLNS-JD operational claims]]
- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN — TIDES + DATUM]]
- [[../../raw/repos/2026-05-23-hashpool-vnprc|hashpool — SV2 + Cashu integration]]

## See also

- [[payout-design-space]]
- [[../concepts/pplns-jd|SLICE / PPLNS-JD]]
- Sister wiki: [[../../../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — JDS share-chain integration
- Sister wiki: [[../../../iroh-transport-stratum-v2/_index|iroh-transport-stratum-v2]] — alternative SV2 transport
