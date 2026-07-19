---
title: Repos
type: raw-index
---

# Repos

- [[2026-05-23-stratum-v2-spec|Stratum V2 Specification (sv2-spec)]] — wire-level mining + Job Declaration
- [[2026-05-23-hashpool-vnprc|hashpool / vnprc — Cashu eHash share mint]]
- [[2026-05-23-cashu-nuts|Cashu NUTs — protocol substrate]]
- [[2026-05-23-p2pool-and-p2poolv2|p2pool (2011) and p2poolv2 (2024+) share-chain]] — overview
- [[2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting modules (code-level)]] — `pplns_window.rs`, `payout.rs`, `payout_distribution.rs`
- [[2026-05-26-parasitepool-para-github|parasitepool/para — Rust + ckpool fork; reference impl for Parasite Pool]]
- [[2026-05-26-ocean-datum-gateway-github|OCEAN-xyz/datum_gateway — DATUM Gateway (C, MIT)]]
- [[2026-05-26-braidpool-github|braidpool/braidpool — DAG sharechain prototype]]
- [[2026-05-26-vnprc-coinbase-playground-github|vnprc/coinbase-playground — CTV-coinbase prototype]] — metadata snapshot (see 2026-07-17 collection for full capture)
- [[2026-07-14-demand-share-accounting-ext-github|demand-open-source/share-accounting-ext — SV2 extension for miner-verifiable PPLNS-JD payouts]]

## coinbase-playground collection (git, ingested 2026-07-17)

Manifest: [[2026-07-17-collection-coinbase-playground-manifest|Collection: vnprc/coinbase-playground @ 0ac7ed25]] (CTV+CSFS coinbase payout playground; deepens the 2026-05-26 snapshot above)

- [[2026-07-17-coinbase-playground-readme|README — non-custodial coinbase payouts (flat/layered trees, MuSig endgame)]]
- [[2026-07-17-coinbase-playground-mine-ctv-coinbase|mine_ctv_coinbase.rs — flat CTV payout tree (CTV-hash, 330-sat anchor, TRUC)]]
- [[2026-07-17-coinbase-playground-mine-layered-ctv-coinbase|mine_layered_ctv_coinbase.rs — 2-level binary CTV tree / unroll]]
- [[2026-07-17-coinbase-playground-parse-witness|parse_witness.rs — CTV witness/OP_NOP4 parser]]
- [[2026-07-17-coinbase-playground-mine-and-send|mine_and_send.rs — regtest bootstrap]]
