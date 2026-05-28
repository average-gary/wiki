---
title: "Ark Protocol Introduction (Second.tech docs)"
publication: second.tech
url: https://second.tech/docs/learn/intro
mirror: https://docs.second.tech/protocol/intro/
authors: [Steven Roose, Erik De Smedt]
type: article
ingested: 2026-05-26
quality: 4
credibility: high
confidence: high
tags: [ark, second-tech, primary-spec, vtxo, transaction-tree, bark]
---

# Ark Protocol Intro — Second.tech

Authoritative living spec from Second.tech (the Steven Roose / Erik De Smedt camp; one of two major Ark implementations). The other camp is **Ark Labs / Arkade** (Burak's lineage).

## Identity

- **Company**: Second / SecondHQ (`second.tech`). Self-described as "building the Ark protocol."
- **CEO**: Steven Roose (formerly Bitcoin Core / rust-bitcoin / Blockstream)
- **CTO**: Erik De Smedt (ex-Blockstream)
- **CMO**: Neil Woodfine
- **Funding**: $5.1M from a private investor (announced via Bitcoin Magazine Apr 2026)
- **Status**: **Signet testnet only**. README: "The Ark protocol code is experimental and must not be used in production."
- **Repo**: `gitlab.com/ark-bitcoin/bark` (Rust client + barkd/arkd server, MIT)
- **Created**: bark Mar 2024

## Variant: clArk (covenantless)

- bark today implements **clArk** — covenantless Ark using **recursive multisigs** instead of CTV covenants.
- Works on Bitcoin today; no soft-fork required.
- Constraint: covenant-free Ark requires **the presence of the eventual owner** to issue a VTXO — preventing third-party issuance. **This is fatal for mining payouts**, where a pool needs to issue VTXOs to potentially-offline miners.

## Variant: hArk (hash-locked, Feb 2026)

- "Hash-lock Ark" — async forfeits, mobile-friendly delegated refreshes.
- Allows users (or miners) to be offline during rounds; cosigners pre-sign branch transactions during the round so the device collects them later.
- This is the closest the Ark stack has come to "intermittent miner" UX.
- Requires CTV + CSFS soft-fork activation.

## Round / spec mechanics

- Round structure (~hourly cadence; operator-set).
- VTXO **4-week expiry** (per Second docs); arkd default is **7 days** (per `arkd` README).
- Transaction-tree leaves = exit transactions.
- Distinguishes **batch outputs** (single onchain UTXO with tree of presigned virtual txs) from **commitment transactions** (root tx that broadcasts).

## Mining-payout positioning (the singular reference)

Per Bitcoin Magazine (Apr 2026, Juan Galt): Second's flagship use cases are "Employer payroll processing with instant finality" and **"Mining pool payout distribution at higher frequencies."**

Across Second.tech's homepage, blog (6 posts), docs, and gitlab, **this is the only public mention of Ark for mining payouts from anyone in the Ark dev community**. Not a roadmap item; not a worked spec; one phrase in a Bitcoin Magazine profile.

## Why ingestion-worthy

Authoritative running spec. The wiki needs Second's intro as the "what is Ark today" canonical reference rather than the older Burak post. Establishes that Second is the sole Ark vendor publicly naming mining payouts as a use case.

## See also

- [[../papers/2026-05-26-keer-maffei-ark-formal-arxiv]] — formal model
- [[2026-05-26-ark-burak-original-proposal-2023]] — historical proposal
- [[2026-05-26-bitcoinmag-second-bark-mining-payouts]] — the one news article naming mining payouts
- [[2026-05-26-ark-erik-de-smedt-ctv-csfs-delving]] — Erk/hArk technical thread
