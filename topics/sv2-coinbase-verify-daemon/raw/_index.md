---
title: Raw sources
type: index
updated: 2026-07-21
---

# Raw sources — sv2-coinbase-verify-daemon

## articles
- [[raw/articles/2026-07-21-sv2-spec-mining-protocol-channels-jobs]] — SV2 spec 05 (channels, jobs, coinbase split). **Decisive: which job exposes the coinbase.** High.
- [[raw/articles/2026-07-21-sv2-spec-design-goals-and-security]] — SV2 spec 02 (HOM is a goal) + 04 (Noise_NX transport; auth ≠ honesty). High.
- [[raw/articles/2026-07-21-sv2-spec-job-declaration-protocol]] — SV2 spec 06 (JDC/JDS; miner-declared coinbase = real trust-min). High.
- [[raw/articles/2026-07-21-sv2-spec-template-distribution-protocol]] — SV2 spec 07 (NewTemplate coinbase_tx_value_remaining = expected value; sv2-tp). High.
- [[raw/articles/2026-07-21-coinbase-structure-merkle-reconstruction-refs]] — Coinbase wire format, extranonce, merkle fold, header endianness, 0xfabe6d6d (Mastering Bitcoin ch12 + Bitcoin wiki). High.
- [[raw/articles/2026-07-21-stratum-work-and-datum-coinbase-prior-art]] — stratum.work live V1 coinbase decode + DATUM miner-built coinbase. Medium.
- [[raw/articles/2026-07-21-optech-pooled-mining-trust-model]] — Optech pooled-mining trust boundary + block withholding; Braiins SV2 framing. High.
- [[raw/articles/2026-07-21-block-withholding-and-deviation-detection]] — **Round 2.** Job-diff heuristic + on-chain correlation loop + block-withholding undetectability (Optech, APoW arXiv, mempool/Esplora API). High.

## repos
- [[raw/repos/2026-07-21-sri-mining-device-reference-client]] — SRI reference downstream client (connect/handshake/loop skeleton; uses standard channel). High.
- [[raw/repos/2026-07-21-sri-channels-sv2-client-extended-validate-share]] — **ExtendedChannel::validate_share + merkle_root_from_path + JobFactory: the reusable coinbase-check engine.** High.
- [[raw/repos/2026-07-21-sri-stratum-core-crate-deps-and-handlers]] — stratum-core crate graph + versions; roles_logic_sv2→parsers/handlers/channels split; network_helpers location. High.
- [[raw/repos/2026-07-21-miningpool-observer-0xb10c]] — Template↔block observer (Rust); coinbase EXCLUDED; 0xB10C coinbase-tag/merkle-branch method. High.
- [[raw/repos/2026-07-21-sri-current-api-versions-and-signatures]] — **Round 2.** Source-verified crate versions + exact struct/fn signatures + frame idioms + UNVERIFIED list. High.
- [[raw/repos/2026-07-21-stratum-sniffer-mitm-architecture]] — **Round 2.** stratum-sniffer = active MITM (own hardcoded keypair), not a passive tap → be your own SV2 client. High.

## papers
- [[raw/papers/2026-07-21-bip34-height-in-coinbase]] — Height push = first scriptSig item (checkable). High.
- [[raw/papers/2026-07-21-bip141-segwit-witness-commitment]] — Witness commitment output layout; txid-vs-wtxid (reserved value not in SV2 prefix/suffix). High.
- [[raw/papers/2026-07-21-block-subsidy-and-consensus-value-ceiling]] — **Round 2.** GetBlockSubsidy formula + bad-cb-amount ceiling + 3.125 BTC current epoch. High.

## data
- [[raw/data/2026-07-21-mining-pools-attribution-dataset]] — **Round 2.** bitcoin-data/mempool mining-pools datasets (coinbase tags + payout addresses) = the daemon's address book. High.
