---
title: "Reference — specs, repos, tools"
type: reference
created: 2026-07-21
updated: 2026-07-21
tags: [stratum-v2, SRI, bips, reference]
---

# Reference — specs, repos, tools

## Specs (normative)

- SV2 spec — [05 Mining Protocol](https://github.com/stratum-mining/sv2-spec/blob/main/05-Mining-Protocol.md) (channels, jobs, coinbase split)
- SV2 spec — [02 Design Goals](https://github.com/stratum-mining/sv2-spec/blob/main/02-Design-Goals.md), [03 Protocol Overview](https://github.com/stratum-mining/sv2-spec/blob/main/03-Protocol-Overview.md), [04 Protocol Security](https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md) (Noise_NX)
- SV2 spec — [06 Job Declaration](https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md), [07 Template Distribution](https://github.com/stratum-mining/sv2-spec/blob/main/07-Template-Distribution-Protocol.md)
- [BIP34](https://github.com/bitcoin/bips/blob/master/bip-0034.mediawiki) (height in coinbase), [BIP141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki) (witness commitment)

## Rust / SRI repos

- [`stratum-mining/stratum`](https://github.com/stratum-mining/stratum) — low-level crates; `stratum-core` re-export hub
  - `sv2/channels-sv2/src/client/extended.rs` — `ExtendedChannel`, `validate_share`
  - `sv2/channels-sv2/src/merkle_root.rs` — `merkle_root_from_path`
  - `sv2/channels-sv2/src/server/jobs/factory.rs` — `JobFactory`
  - `sv2/subprotocols/mining/src/*` — `mining_sv2` message structs
  - `sv2/parsers-sv2`, `sv2/handlers-sv2`
- [`stratum-mining/sv2-apps`](https://github.com/stratum-mining/sv2-apps) — roles/apps
  - `integration-tests/lib/mining_device/mod.rs` + `bin/mining_device.rs` — reference client
  - `stratum-apps/src/network_helpers/` — `Connection` (Noise)
  - `stratum-apps/src/key_utils/` — `Secp256k1PublicKey`
- [`stratum-mining/sv2-tp`](https://github.com/stratum-mining/sv2-tp) — C++ Template Provider
- `stratum-mining/stratum-sniffer` — V1/V2 wire monitoring (reusable parsing)
- `demand-easy-sv2` — ergonomic SRI wrapper; Braiins `ii-stratum` — alt Rust stack

## Prior-art tools

- [miningpool.observer](https://miningpool.observer/) + [source](https://github.com/0xB10C/miningpool-observer) — template↔block observer (coinbase excluded)
- [stratum.work](https://stratum.work/) — live V1 coinbase decoder
- [DATUM Gateway](https://github.com/OCEAN-xyz/datum_gateway) (OCEAN) — miner-built coinbase
- [0xB10C observations](https://b10c.me/observations/) — coinbase-tag / merkle-branch pool analysis
- [Bitcoin Optech — Pooled Mining](https://bitcoinops.org/en/topics/pooled-mining/)

## Related wiki topics

- [[../stratum-sri/_index|stratum-sri]] · [[../sv2-coinbase-identity/_index|sv2-coinbase-identity]] ·
  [[../datum/_index|datum]] · [[../sv2-p2pool-integration/_index|sv2-p2pool-integration]] ·
  [[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] ·
  [[../mining-scale-test-sim/_index|mining-scale-test-sim]]
