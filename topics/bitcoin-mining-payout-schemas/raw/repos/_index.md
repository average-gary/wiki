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
- [[2026-07-27-blitzpool-server-rust-github|warioishere/blitzpool-server-rust — non-custodial in-coinbase payout pool]] — Solo/PPLNS/Group-Solo/Blockparty, 37-crate Rust, AGPL; multi-output PPLNS coinbase, signed pending ledger, coinbase weight-budget autoscaler
- [[2026-07-27-blitzpool-finder-bonus-code-read|Blitzpool finder-bonus mechanics — code-level read @ 7815884]] — verified from a local clone, not the README: the bonus carve-out math, why per-finder coinbase construction is already the architecture, measured per-connection cost, and the missing duplicate-address merge in the PPLNS ledger apply
- [[2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read|xpub/wildcard-descriptor coinbase rotation in sv2-apps @ e2930150]] — unmerged `feat/coinbase-rotation` branch: reusable `XpubDerivator` primitive (miniscript `has_wildcard()` gate, `AtomicU32` index, flat-file persistence), reverses upstream's deliberate no-wildcards decision, rotates on `SubmitSolution` in both Pool and JDC; pool-single-address only, not per-miner xpub usernames

## Attribution privacy round (2026-07-29)

- [[2026-07-29-pool-identity-vs-payout-script-conflation-code-read|Identity-vs-payout-script conflation — ckpool, public-pool, DATUM, TIDES, share-accounting-ext]] — ckpool's `username[128]` *is* the scriptPubKey via `address_to_txn()`; public-pool's `varchar(62)` primary key; DATUM's firmware ceilings (Avalon 63, Whatsminer overflow past 127, ~380–530 outputs); PPLNS-JD's positional ledger with zero identity fields; SV2 #697/#1652/#1720 on wildcards
- [[2026-07-29-bip352-silent-payments-coinbase-incompatibility|BIP 352 Silent Payments — structural incompatibility with coinbase outputs]] — a coinbase has no input private key, so `a = 0` → fail; zero occurrences of "coinbase" in BIP 352; BIP 380 wildcards and the BIP 44 gap limit of 20 as the workable alternative
- [[2026-07-29-mining-privacy-prior-art-survey|Attribution privacy across existing mining designs]] — hashpool/eHash, Braidpool (payout_address **and miner IP** in the PoW), Radpool, p2poolv2, SV2 ext 0x0002, Cashu NUT PR #293 (closed 2026-03-09); confirmed: no BIP, no SV2 extension, no ZK/MPC design for share accounting

## coinbase-playground collection (git, ingested 2026-07-17)

Manifest: [[2026-07-17-collection-coinbase-playground-manifest|Collection: vnprc/coinbase-playground @ 0ac7ed25]] (CTV+CSFS coinbase payout playground; deepens the 2026-05-26 snapshot above)

- [[2026-07-17-coinbase-playground-readme|README — non-custodial coinbase payouts (flat/layered trees, MuSig endgame)]]
- [[2026-07-17-coinbase-playground-mine-ctv-coinbase|mine_ctv_coinbase.rs — flat CTV payout tree (CTV-hash, 330-sat anchor, TRUC)]]
- [[2026-07-17-coinbase-playground-mine-layered-ctv-coinbase|mine_layered_ctv_coinbase.rs — 2-level binary CTV tree / unroll]]
- [[2026-07-17-coinbase-playground-parse-witness|parse_witness.rs — CTV witness/OP_NOP4 parser]]
- [[2026-07-17-coinbase-playground-mine-and-send|mine_and_send.rs — regtest bootstrap]]
