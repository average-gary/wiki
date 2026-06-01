---
title: "Coinbase ownership: Pool vs JDC (SV2)"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [stratum-v2, JDC, JDS, JobDeclaration, coinbase, decentralization, SetCustomMiningJob]
---

# Coinbase ownership: Pool-built vs JDC-built

In SV2 there are **two** authoritative coinbase-construction paths, sharply separated:

## 1. Pool-built coinbase (no JD)
- Pool receives `NewTemplate` from its own Template Provider (bitcoind).
- Pool's `JobFactory::new_for_pool` finalizes the coinbase scriptSig as `/pool_tag//` (empty miner slot) plus extranonce.
- Pool emits `NewMiningJob` (merkle_root only) or `NewExtendedMiningJob` (coinbase prefix/suffix) per channel.
- Miners cannot influence coinbase content.
- Spec frames this as: *"Pools are unilaterally imposing work on miners"* — [[raw/articles/2026-05-28-sv2-spec-job-declaration-protocol]].

## 2. JDC-built coinbase (Job Declaration path)
- JDC (downstream) selects mempool transactions, builds its own block template, and supplies `coinbase_tx_prefix` / `coinbase_tx_suffix` to the Pool via `DeclareMiningJob` (to JDS).
- Pool publishes via `SetCustomMiningJob`, which embeds the coinbase bytes signed off by JDS.
- JDC may add 0-value or non-0-value outputs and reorder outputs — full coinbase agency.
- This is the spec's answer to the "pool unilaterally imposes work" problem.

## Where `user_identity` fits
- In **both** paths, `user_identity` is supplied at channel-open time and is conventionally treated as auth/identification metadata for the Pool.
- In path 1, the Pool *could* unilaterally fold a function of `user_identity` into its own coinbase bytes (the [[thesis|theses/sv2-coinbase-identity]] case) — nothing in the spec forbids it; the SRI reference simply doesn't.
- In path 2, the JDC builds the coinbase, so a per-miner tag is naturally a JDC concern. SRI's `new_for_job_declaration_client` constructor takes a `miner_tag_string` and feeds it into `JobFactory`.

## Trust property
- Pool-side tagging (path 1, charitable thesis): the miner trusts the Pool to actually emit the agreed-upon `user_identity`-derived bytes. **Trusting attribution.**
- JDC-side tagging (path 2): the miner builds its own coinbase, so the tag is **non-custodial / verifiable**.

This is the substantive difference between the thesis form and the JD form.

## See also
- [[wiki/concepts/job-factory-and-coinbase-construction]]
- [[wiki/concepts/sv2-coinbase-scriptsig-layout]]
- [[raw/articles/2026-05-28-sv2-spec-job-declaration-protocol]]
- [[raw/articles/2026-05-28-ocean-datum-gateway-coinbase-tagging]] — DATUM = production exemplar of path 2
