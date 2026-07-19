---
title: Radpool
category: concept
created: 2026-05-26
confidence: medium
tags: [radpool, jungly, dlc, frost, decentralized-fpps, novel-accounting]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-24-jungly-delvingbitcoin-p2share.md"
  - "raw/articles/2026-05-26-radpool-delvingbitcoin.md"
---

# Radpool

A 2024 proposal by **Kulpreet Singh (jungly)** — also p2poolv2 lead — to decentralize FPPS without inventing a sharechain. Project at [radpool.xyz](https://radpool.xyz); reference code in [`pool2win/frost-federation`](https://github.com/pool2win/frost-federation). Originally posted to Delving Bitcoin in November 2024.

## Mechanism

- **Mining Service Providers (MSPs)** front capital and pay miners FPPS-style.
- Settlement happens via **DLCs (Discreet Log Contracts)** signed by a **FROST threshold federation** of the MSPs.
- MSPs **build their own block templates** — decentralizes template construction without forcing a single consensus mechanism over template choice.
- Miners can **unilaterally exit** an MSP relationship (no lock-in).
- MSPs earn yield in exchange for capital lockup (the variance they absorb).

## Why it's distinct

Among schemes the wiki tracks:

- **vs FPPS** ([[fpps]]): same payout shape, but no single custodian — MSP federation absorbs variance collectively.
- **vs p2pool / p2poolv2** ([[p2pool-share-chain]]): no sharechain. Avoids the p2pool latency and propagation costs.
- **vs TIDES** ([[tides]]): non-custodial in a different sense — TIDES splits coinbase outputs; Radpool settles off-chain via DLC.
- **vs eHash** ([[ehash]]): no Cashu mint. Variance is not tokenized.
- **vs PPLNS-JD / SLICE** ([[pplns-jd]]): both decentralize template construction, but Radpool keeps FPPS variance behavior on the miner side.

Adds a new axis to the taxonomy: **covenant/contract-based settlement layer** rather than reward-formula or share-window mechanics.

## Critical engagement (Bob McElrath, Braidpool)

McElrath disputes the "no consensus required" framing, arguing that **accurate reward distribution still requires consensus** over which miner contributed what — and that the FROST federation effectively *is* the consensus, just relabeled. The Radpool ↔ Braidpool thread is the canonical design dispute on this point.

## Status (May 2026)

- Proposal stage. `frost-federation` repo exists and is active under jungly's `pool2win` org.
- No production deployment known.
- Same author shipping p2poolv2 in parallel.

## Open questions

- DLC oracle design: what data does the oracle attest? Pool block-found events? Per-miner share counts?
- FROST federation governance: how are MSPs admitted/expelled? Threshold parameters?
- Failure mode if a miner's MSP equivocates or goes offline mid-settlement.
- How template construction is reconciled across MSPs that build different templates for the same height.

## Sources

- [[../../raw/articles/2026-05-26-radpool-delvingbitcoin|Radpool delvingbitcoin thread (Nov 2024)]]
- [[../../raw/articles/2026-05-24-jungly-delvingbitcoin-p2share|Jungly's adjacent p2poolv2 design summary]]

## See also

- [[fpps]] — what Radpool decentralizes
- [[p2pool-share-chain]] — same author's parallel project
- [[parasite-pool]] — alternative novel scheme with very different design philosophy (custodial LN vs DLC federation)
- [[payout-schema-taxonomy]]
