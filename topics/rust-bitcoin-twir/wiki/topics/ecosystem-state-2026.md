---
title: Rust Bitcoin Ecosystem State — 2026-06
type: topic-synthesis
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: hot
confidence: high
sources:
  - "[[../../raw/data/2026-06-22-crates-io-bitcoin-stack|crates.io]]"
  - "[[../../raw/data/2026-06-22-github-bitcoin-rust-repo-activity|GitHub]]"
  - "[[../../raw/repos/2026-06-19-rust-bitcoin-units-0-5-0|rust-bitcoin releases]]"
  - "[[../../raw/repos/2026-06-18-foundation-keyos-v1-2-1|KeyOS]]"
  - "[[../../raw/articles/2026-06-18-ldk-v0-2-3-loupe-release|LDK 0.2.3]]"
---

# Rust Bitcoin Ecosystem State — June 2026

A snapshot of where the major Rust-Bitcoin projects stand on 2026-06-22.

## Activity uniformly high

All eight tracked GitHub repos pushed within the last 4 days. All eight released a new version in 2026.

## Recent releases (last 30 days)

| Project | Version | Date | TWiR-relevant? |
|---|---|---|---|
| `bitcoin_hashes` | 1.0.0 | 2026-06-01 | yes — COTW candidate |
| `bitcoin-network-kind` | 1.0.0 | 2026-06-12 | yes |
| `bitcoin-key-expression` | 0.1.0 | 2026-06-12 | yes |
| P2Poolv2 | 0.12.0 | 2026-06-12 | yes |
| CDK (Cashu) | 0.17.1 | 2026-06-16 | yes |
| ngwallet (Foundation) | 3.6.1 | 2026-06-16 | yes |
| LDK | 0.2.3 / 0.1.10 | 2026-06-18 (Loupe security) | yes |
| Foundation KeyOS | 1.2.1 | 2026-06-18 | yes |
| `bitcoin-units` | 0.5.0 | 2026-06-19 | yes |
| rust-bitcoin Kani PR | #6393 (open) | 2026-06-18 | yes — Research |

That's **10 TWiR-relevant items in the last 21 days alone.** Issue 657 has 12 Project/Tooling Updates slots — one issue could absorb most of these comfortably (with multi-contributor coordination).

## Recent posts / case studies (last 6 months)

- **2026-06-10**: Lexe SGX + LDK ([[../../raw/articles/2026-06-10-lexe-ldk-sgx-enclaves|Lexe]])
- **2026-04-20**: BDK 2026 Q1 update ([[../../raw/articles/2026-04-20-bdk-2026-q1-update|BDK Q1]])
- **2026-02-04**: rust-nostr SDK overhaul (21 PRs) ([[../../raw/articles/2026-02-04-rust-nostr-architecture-overhaul|rust-nostr]])
- **2026-01-21**: BDK 2025 Q4 update — MetaMask Bitcoin snap on bdk-wasm ([[../../raw/articles/2026-01-21-bdk-2025-q4-update|BDK Q4]])

## Funding / institutional posture

- **Spiral** (Block subsidiary): funds rust-bitcoin, LDK, BDK, BTCPay, ZeroSync. Staff includes Matt Corallo, Wilmer Paulino. Open grants: grants@spiral.xyz.
- **Kraken**: funds tcharding (rust-bitcoin maintainer) since 2022 via Tamás Blummer fund.
- **Foundation Devices**: ships Rust-heavy hardware (KeyOS + ngwallet on Passport Prime).
- **Lightspark**, **Lexe**, **Block**, **Coinbase**: production LDK users.
- **HRF**: funds Fedimint-adjacent BitSacco project in Kenya.

## Cross-references to hub topics

The Rust-Bitcoin ecosystem is sufficiently large that several of the user's hub topics already cover slices in depth:

- [[../../../stratum-sri/_index|stratum-sri]] — SV2 SRI Rust crate suite
- [[../../../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — p2poolv2 + sv2-apps
- [[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — mining-side context (PPLNS, FPPS, etc.)
- [[../../../ldk-server/_index|ldk-server]] — LDK Server gRPC binary
- [[../../../cdk-ldk-lnurl/_index|cdk-ldk-lnurl]] — CDK + LDK Node mint
- [[../../../fedimint/_index|fedimint]] — Fedimint federated ecash
- [[../../../iroh-transport-stratum-v2/_index|iroh-transport-stratum-v2]] — Iroh + SV2
- [[../../../sv2-coinbase-identity/_index|sv2-coinbase-identity]] — coinbase miner-tagging
- [[../../../sv1-upstream-reverse-translator/_index|sv1-upstream-reverse-translator]] — reverse Stratum translator
- [[../../../datum/_index|datum]] — DATUM gateway / SV2-front proxy
- [[../../../clink-protocol/_index|clink-protocol]] — Nostr-native Lightning standards
- [[../../../nixos-reproducible-builds-bitcoin/_index|nixos-reproducible-builds-bitcoin]] — reproducible builds
- [[../../../rust-multi-platform/_index|rust-multi-platform]] — Rust mobile/desktop/WASM (consumer-side)

## Gaps / open questions (status: many resolved in gap-closing round)

1. **[RESOLVED]** rust-bitcoin Kani / Miri work in TWiR Research section: refined-grep confirms **zero** appearances; PRs #5579, #5955, #6393, #6243 are uncovered submission opportunities.
2. **[STANDING]** Spiral / Lightning Labs blog cadence — ~monthly architectural posts, not weekly. Sufficient for one Project/Tooling submission per month.
3. **[RESOLVED — negative]** SV2 SRI v1.10.0 wrap-up: **no substantive blog post exists** as of 2026-06-22 (3 weeks post-release). Best existing content is the [[../../raw/articles/2026-05-07-stratum-v2-wg-new-members|2026-05-07 Working Group expansion]] post, which is a governance announcement not a release wrap. Do not submit v1.10.0 to TWiR until a write-up exists.
4. **[RESOLVED — confirmed minimal]** ACINQ Rust footprint: [[../../raw/articles/2026-06-22-acinq-rust-footprint|effectively none]]. Only `ACINQ/txread` (dormant since 2015). ACINQ is a Scala/Kotlin shop. Excluded from Rust-Bitcoin Lightning-side analysis.
5. **[STANDING]** Per-conference Rust talk counts at btc++ events require scraping individual program pages.

## See also

- [[twir-rust-bitcoin-coverage-gap|TWiR Coverage Gap]]
- [[submission-playbook|Submission Playbook]]
- [[../concepts/rust-bitcoin-crate-stack|Rust Bitcoin Crate Stack]]
