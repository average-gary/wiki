---
title: Rust Bitcoin Crate Stack
type: concept
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: warm
confidence: high
sources:
  - "[[../../raw/data/2026-06-22-crates-io-bitcoin-stack|crates.io snapshot]]"
  - "[[../../raw/data/2026-06-22-github-bitcoin-rust-repo-activity|GitHub activity]]"
---

# Rust Bitcoin Crate Stack

Map of the active Rust Bitcoin crates as of 2026-06-22, ordered by dependency depth and download volume.

## Foundation primitives

### `secp256k1` (60.9M total DLs / 14.2M last 90d)
- Rust bindings to libsecp256k1.
- Among the most downloaded cryptographic crates on crates.io.
- Used far beyond Bitcoin itself (Substrate, Solana ecosystem, etc.).
- Latest: 0.32.0-beta.2 (2025-10).
- Repo: rust-bitcoin/rust-secp256k1.

### `bitcoin_hashes` (1.0.0 — 2026-06-01)
- Foundational hashing crate (SHA-256, RIPEMD-160, etc.).
- 1.0.0 is **first stable major** — milestone.
- Used widely beyond rust-bitcoin.
- COTW candidate.

## Core protocol

### `bitcoin` (11.9M total / 2.06M last 90d)
- Serialization, parsing, scripts, BIP-32, PSBT v0.
- Stewards: apoelstra, tcharding.
- MSRV 1.74. Licensed CC0.
- Explicitly **not** for consensus-validating use.
- Latest: 0.32.10 (2026-05).

### `miniscript` (3.2M / 650k)
- Miniscript / Output Descriptors.
- Latest: 13.1.0 (2026-06).

### `bitcoin-units`, `bitcoin-network-kind`, `bitcoin-key-expression`
- Modular split-outs from rust-bitcoin workspace.
- Reflects ongoing modularization strategy.

## Wallet stack

### `bdk_wallet` (936k total / 326k last 90d, fastest grower)
- Bitcoin Dev Kit — wallet abstraction over rust-bitcoin.
- Funded by Spiral.
- Bindings: bdk-ffi (Swift/Kotlin/Python), bdk-dart, bdk-rn, bdk-wasm.
- Latest: 3.1.0 (2026-06).
- Adopted by: MetaMask Bitcoin snap, Eigenwallet, Satsigner, SatGo, Foundation ngwallet.

### `bdk-cli`
- Reference CLI; PayJoin integrated in 3.0.

### `bdk_chain`, `bdk_esplora`, `rust-electrum-client`
- Chain source backends.
- Kyoto crate adds compact block filter (CBF) support.

## Lightning stack

### `lightning` (1.7M / 252k)
- LDK — Lightning Dev Kit.
- Funded by Spiral; lead Matt Corallo.
- Latest: 0.2.3 (2026-06-18, "Loupe" security release).
- Production users: Cash App, Mutiny, Lexe, Lightspark Sparknodes, Fedimint Gateway.
- Companion crates: `ldk-node`, `ldk-server`, `lightning-transaction-sync`.

### LDK design philosophy
- Explicitly **does not** provide on-disk storage, blockchain access, UTXO management, networking, or key management — all delegated via traits (`Persist`, `Confirm`, `KeyValueStore`, etc.).
- "Do not add new dependencies. Really do not add new non-optional/non-test/non-library dependencies."

## Ecash / federated custody

### `cdk` (37k / 6k)
- Cashu Dev Kit — Rust implementation of Cashu protocol (NUTs spec).
- 97% Rust, alpha.
- Backends: SQLite, PostgreSQL, Redb, Supabase.
- Lightning backends: CLN, LND, **LDK Node**, LNbits.
- Latest: 0.17.1 (2026-06-16).

### `fedimint-core` (107k / 5.5k)
- Fedimint — federated Chaumian e-cash.
- v0.7 ships beta Iroh networking + LDK Node Lightning Gateway.
- 689 stars, 328 open issues (high triage volume).

## Nostr (frequently paired with Lightning/ecash)

### `nostr` / `nostr-sdk` (1.0M / 452k)
- rust-nostr — Yuki Kishimoto.
- Latest: 0.45.0-alpha.2 (2026-06).
- 0.42→0.44 cadence: ~quarterly; 21-PR architecture overhaul Feb 2026.
- Bitcoin/Lightning adjacency: NWC (NIP-47), Zaps (NIP-57), NIP-87 mint discovery.

## Mining

### Stratum V2 SRI
- `stratum-mining/stratum` repo: binary-sv2, codec-sv2, framing-sv2, noise-sv2, channels-sv2, handlers-sv2, parsers-sv2, extensions-sv2, subprotocols.
- MSRV 1.75, dual MIT/Apache, latest v1.10.0 (2026-06-03).
- Cross-reference: [[../../../stratum-sri/_index|stratum-sri]] hub topic.

### `p2poolv2` (mining pool)
- 43.4% Rust, AGPL-3.0.
- Atomic-swap-based decentralized payout.
- Latest: v0.12.0 (2026-06-12).

## Hardware wallets

### Foundation KeyOS / ngwallet
- KeyOS: ~46.7% Rust, on Xous kernel (also Rust), Slint UI.
- ngwallet: 99.9% Rust, BDK-based.
- Powers Passport Prime hardware wallet.
- Latest: KeyOS v1.2.1 (2026-06-18), ngwallet v3.6.1 (2026-06-16).

### `rust-cktap`
- SATSCARD interactions.
- Adopted by SatsBuddy iOS app.

### `libtropic`
- Rust driver crate for TROPIC01 secure element (Tropic Square).

## DLCs (Discreet Log Contracts)

### `rust-dlc`
- Workspace: dlc, dlc-manager, dlc-messages, dlc-trie, bitcoin-rpc-provider, p2pd-oracle-client, dlc-sled-storage-provider.
- v0.8.0 release prep merged 2025-12-13.
- Self-described as not mainnet-recommended.

## See also

- [[../topics/twir-rust-bitcoin-coverage-gap|TWiR Coverage Gap]]
- [[../reference/maintainer-orgs|Maintainer Orgs]]
- [[../reference/release-cadences|Release Cadences]]
