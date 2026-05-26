---
title: "Radpool: Decentralised Mining Pool With Futures Contracts For Payouts (Delving Bitcoin)"
author: Kulpreet Singh (jungly)
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/radpool-decentralised-mining-pool-with-futures-contracts-for-payouts/1262
project_site: https://radpool.xyz
code: https://github.com/pool2win/frost-federation
date: 2024-12-07
type: article
ingested: 2026-05-26
quality: 4
credibility: high
confidence: high
tags: [radpool, dlc, frost, decentralized-fpps, jungly, novel-accounting, primary]
---

# Radpool — Decentralized FPPS via DLCs and FROST

Proposal by Kulpreet Singh (jungly, also p2poolv2 lead) to decentralize FPPS without inventing a new consensus protocol.

## Mechanism

- **Mining Service Providers (MSPs)** front capital and pay miners FPPS-style.
- Settlement happens via **DLCs (Discreet Log Contracts)** signed by a **FROST threshold federation**.
- MSPs **build their own block templates** — decentralizes template construction without forcing a single consensus mechanism over template choice.
- Miners can **unilaterally exit** an MSP relationship.
- MSPs earn yield in exchange for capital lockup (the variance they absorb).

## Critical engagement (Bob McElrath, Braidpool)

- McElrath disputes the "no consensus" framing: argues that **accurate reward distribution still requires consensus** over which miner contributed what, and the FROST federation effectively is the consensus.
- This thread is the canonical Radpool ↔ Braidpool design dispute.

## Why ingestion-worthy

First serious attempt at **DLC-settled non-custodial FPPS**. Adjacent to but distinct from p2pool/p2poolv2 (no sharechain), TIDES (no on-chain coinbase splitting), and eHash (no Cashu mint). Adds a new axis to the wiki taxonomy: "covenant/contract-based settlement layer."

## See also

- [[2026-05-24-jungly-delvingbitcoin-p2share]] — same author's p2poolv2 design summary
- [[../../wiki/concepts/fpps]] — the centralized scheme this attempts to decentralize
