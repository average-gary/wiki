---
title: Rust-Bitcoin Maintainers and Funding Orgs
type: reference
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: warm
confidence: high
sources:
  - "[[../../raw/articles/2022-02-08-kraken-funds-bitcoin-rust-maintainer|Kraken funding]]"
  - "[[../../raw/articles/2020-01-21-spiral-announcing-ldk|Spiral LDK]]"
  - "[[../../raw/articles/2026-06-10-lexe-ldk-sgx-enclaves|Lexe]]"
---

# Rust-Bitcoin Maintainers and Funding Orgs

Useful for Jobs section submissions and contextualizing Project/Tooling Updates.

## Maintainers (named individuals)

### Andrew Poelstra (`apoelstra`)
- Blockstream Director of Research.
- Co-steward of rust-bitcoin.
- Rust New Contributor as of 2014-08 — first ecosystem anchor in TWiR archive.

### Tobin Harding (`tcharding`)
- Full-time rust-bitcoin maintainer since Feb 2022.
- Funded by Kraken via the Tamás Blummer memorial fund.
- Co-steward of rust-bitcoin alongside apoelstra.

### Matt Corallo (`TheBlueMatt`)
- Lead of rust-lightning / LDK.
- On staff at Spiral / Block.
- Authors LDK technical deep-dives (e.g., Pathfinding 2025-02-10).

### Wilmer Paulino, Steve Lee (PM lead)
- Spiral team members.

### Vincenzo Palazzo
- Spiral grantee on BOLT12.

### Eric Sirion
- Fedimint founder; led MiniMint prototype Dec 2021 → Fedimint v0.7.

### Yuki Kishimoto (`yukibtc`)
- rust-nostr maintainer.

### thunderbiscuit
- BDK contributor; authors quarterly recaps.

### Justin Moeller
- Fedimint contributor; LDK Node integration writeup (2025-01-30).

### Max Fang
- Lexe; LDK + SGX enclaves writeup (2026-06-10).

### darosior
- Senior rust-miniscript / rust-bitcoin contributor; raised API-churn issue #3166.

### Luis Schwab
- BDK grantee on Floresta integration.

### nymius
- BDK contributor on Silent Payments.

## Funding orgs

### Spiral
- URL: https://spiral.xyz/
- Block subsidiary (formerly Square Crypto).
- Funds: rust-bitcoin, LDK, BDK, BTCPay, ZeroSync.
- Grant inquiries: grants@spiral.xyz.
- Roughly a dozen staff across eng/design/PM.

### Kraken
- Funds tcharding via Tamás Blummer memorial fund (since Sept 2021).

### Lightspark
- Coinbase-adjacent; production LDK user (Sparknodes).

### Foundation Devices
- Ships Passport Prime hardware wallet running KeyOS (Rust) + ngwallet (BDK).

### HRF (Human Rights Foundation)
- Funds Fedimint-adjacent BitSacco project in Kenya.

## Project orgs

| Org | GitHub | Flagship project |
|---|---|---|
| rust-bitcoin | github.com/rust-bitcoin | rust-bitcoin, rust-secp256k1, rust-miniscript, bitcoin_hashes |
| Bitcoin Dev Kit | github.com/bitcoindevkit | bdk_wallet, bdk-cli, bdk-ffi, bdk-wasm |
| Lightning Dev Kit | github.com/lightningdevkit | rust-lightning, ldk-node, ldk-server, vss-rust-client |
| Fedimint | github.com/fedimint | fedimint-core, fedimintd |
| Cashu | github.com/cashubtc | cdk |
| rust-nostr | github.com/rust-nostr | nostr, nostr-sdk |
| Stratum Mining | github.com/stratum-mining | stratum (SV2 SRI), sv2-spec |
| P2Poolv2 | github.com/p2poolv2 | p2poolv2 |
| Foundation Devices | github.com/Foundation-Devices | keyos, ngwallet, xous |
| p2pderivatives | github.com/p2pderivatives | rust-dlc |

## See also

- [[../concepts/rust-bitcoin-crate-stack|Rust Bitcoin Crate Stack]]
- [[release-cadences|Release Cadences]]
