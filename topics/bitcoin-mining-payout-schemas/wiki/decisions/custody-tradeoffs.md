---
title: Custody Tradeoffs across Payout Schemes
type: decision
created: 2026-05-23
confidence: high
tags: [custody, FPPS, TIDES, eHash, Fedimint, decision]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-23-dmnd-demand-pool.md"
  - "raw/articles/2026-05-23-ocean-tides-spec.md"
  - "raw/repos/2026-05-23-cashu-nuts.md"
  - "raw/repos/2026-05-23-hashpool-vnprc.md"
  - "raw/repos/2026-05-23-p2pool-and-p2poolv2.md"
---

# Custody Tradeoffs

Five distinct custody models map onto the modern payout schemes. Each shifts risk to a different actor.

## The five custody models

### 1. Pool custody (FPPS, PPS+, traditional PPLNS)

- Pool holds miner BTC between block-find / payout cycles.
- Risk: pool insolvency, exit scam, regulatory seizure, KYC requirement, withdrawal refusal.
- Examples: Foundry, AntPool, F2Pool, ViaBTC, Binance Pool.
- Audit: depends on operator transparency. Most pools publish nothing.

### 2. No custody — coinbase-output payout (TIDES, SLICE)

- Pool never holds miner BTC. Coinbase generation tx splits directly to miner addresses.
- Risk: none at the custody layer. Fee can still be high; share-counting can still be cheated.
- Examples: OCEAN (TIDES), DMND (SLICE).
- Audit: trivial — every block's coinbase outputs are publicly verifiable on-chain.

### 3. Mint custody — single operator (eHash / hashpool)

- Pool runs a Cashu mint. Miner gets bearer token; redeems at mint for BTC.
- Risk: mint operator exit-scam, refusal to redeem, mint-inflation (issuing tokens unbacked by shares).
- Mint blindness gives privacy but does not give solvency proof.
- Project's own admission: *"absolutely true"* that it's custodial.
- Audit: DLEQ proofs (NUT-12) prove the mint signed with its advertised key. No solvency proof in current spec.

### 4. Mint custody — federated (Fedimint-as-mining-pool, theoretical)

- Mint custody is split across N guardians. Rugpull requires t-of-n collusion.
- Risk: still custodial, but materially reduced. Single-guardian exit-scam doesn't lose tokens.
- Examples: not yet deployed for mining; concept is well-established in Fedimint generally.
- Audit: federation publishes consensus-signed solvency periodically; better than single-mint hashpool.

### 5. No operator (p2poolv2)

- Share-chain consensus + on-chain coinbase outputs to top-N miners + atomic-swap support transactions for small miners.
- Risk: protocol bugs, share-chain attacks. No custody layer to attack.
- Examples: p2pool (2011-2017 historical), p2poolv2 (2024+ revival).
- Audit: full share-chain is publicly verifiable.

## Decision matrix

| Use case | Recommended custody model |
|---|---|
| Industrial-scale miner, FX-managed cashflow | Pool custody (FPPS) — accept the trust premium |
| Sovereign miner, long-term holder | No custody (TIDES + DATUM, SLICE) |
| Privacy-conscious miner | Federated mint (when production-ready) |
| Variance-hedging miner | eHash with secondary market (when production) |
| Cypherpunk / decentralization-maximalist | p2poolv2 |
| Small / hobbyist miner | TIDES (best UX of non-custodial), or pool with Lightning payout |

## Why "non-custodial" is not free

The mining-payout ecosystem treats non-custodial as the default goal. But:

- **Non-custodial coinbase payouts** require small minimums (OCEAN: 0.01 BTC standard, 0.0007 BTC discretionary, Lightning fallback). Below threshold, miner accumulates dust outputs that are uneconomic to spend.
- **Non-custodial requires miner to handle payout addresses** correctly — a misconfigured payout address means lost funds with no operator to fix it.
- **No-operator (p2poolv2)** means no support, no dispute resolution, no UX team.

The "custodial pool" abstracts these problems away at the cost of trust. The 2024-2026 wave is, in effect, replacing custodial trust with **better protocols + Lightning + atomic swaps** to handle the operational burden non-custodially.

## Sources

- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN TIDES non-custodial design]]
- [[../../raw/repos/2026-05-23-hashpool-vnprc|hashpool — admitted custodial mint]]
- [[../../raw/repos/2026-05-23-cashu-nuts|Cashu NUTs — DLEQ, P2PK]]
- [[../../raw/repos/2026-05-23-p2pool-and-p2poolv2|p2pool / p2poolv2 — no operator]]
- [[../../raw/articles/2026-05-23-dmnd-demand-pool|DMND / SLICE]]

## See also

- [[../concepts/payout-schema-taxonomy]]
- [[../topics/payout-design-space]]
- [[../topics/why-fpps-dominates-but-is-fragile]]
