# Log — datum

## [2026-06-01] rename | topic 'datum-gateway' → 'datum'. Scope broadened from OCEAN gateway internals to include SV2-downstream proxy design. Filesystem moved $HOME/wiki/topics/datum-gateway → $HOME/wiki/topics/datum; wikis.json updated with renamed-from + renamed-on.

## [2026-06-01] research --plan --deep | datum · "DATUM-capable proxy: SV2 downstream + DATUM/OCEAN upstream" — 5 paths × 8 agents = ~40 parallel research workers. 32 new sources ingested (22 articles + 10 repo reads + 1 notes + 0 papers/data). 5 new articles compiled (4 concepts + 1 topic playbook), 1 existing article updated (`datum-protocol` confidence upgraded medium→high with full wire-format), 1 existing article corrected (`datum-gateway-overview` retracted bogus "in-tree Rust port" claim).

Headline findings:
- (a) DATUM Protocol wire format reconstructed from `src/datum_protocol.[ch]`: 32-bit packed header (22-bit length, 5-bit opcode, 3 encryption flags), libsodium ChaCha20-Poly1305 (NOT Noise, NOT TLS), header-obfuscation chain seeded by `0xb10cfeed` (PR #202 hardens), 8-job ring, 16-bit unique-identifier in scriptSig, 6 sub-opcodes under proto_cmd=5 (0x10/0x11/0x27/0x50/0x8F/0x99/0xF9).
- (b) Issue #146 (`OCEAN-xyz/datum_gateway#146`) by `electricalgrade` (2025-08-23) is the only public, named, sourced SV2-DATUM bridge proposal. Open 9 months with no Concept ACK; luke-jr soft-pushback toward pkg-config shared library.
- (c) OCEAN docs explicitly reject SV2; Luke Dashjr quote on bitcoin/bitcoin#31002: "GBT has worked for years and nothing additional is needed for DATUM." SRI repos have zero documented engagement with DATUM.
- (d) `electricalgrade/sv2` (the only adjacent code) is stalled since 2025-09-21 — Noise + SetupConnection only, no DATUM bridge.
- (e) Gateway has a clean producer/consumer **queue seam** (`datum_queue.c`, ~80 LOC rwlock dual-buffer) between SV1 server (`datum_stratum.c`) and DATUM client (`datum_protocol.c`) — the architectural finding that makes the SV2-downstream rewrite tractable.
- (f) Recommended architecture: separate Rust binary (Tokio), plain SV2 pool front (no JDS, no JDC), `ExtendedChannel::new_for_pool` + `DefaultJobStore`, `total_extranonce_len = 12` for the SV2-32B → DATUM-12B bridge. ~1500 LOC new + ~9600 LOC SRI reuse (6:1 ratio).
- (g) Phase 1: SV1 client upstream to local datum_gateway:23334; Phase 2: native DATUM-protocol speaker direct to OCEAN.
- (h) DATUM Prime (pool side) is closed-source — no offline test target; integration tests must hit live OCEAN.
- (i) Operator value is real but narrow: "OCEAN/TIDES connectivity for SV2 firmware fleets." Trust delta vs running plain DATUM Gateway alongside SV1 firmware: NEGATIVE on custody (proxy = tiny pool), NEUTRAL on censorship (DATUM already had it), POSITIVE on transport security + channel hygiene.
- (j) Retraction: previous wiki revision claimed an in-tree Rust port at `datum_gateway_rust/` anchored on commit a3da9e69. Path 2 verified this is FALSE: a3da9e69 is a CI-workflow-only merge containing zero `.rs` files; no Rust code exists upstream or in any of 56 forks.

## [2026-06-01] compile | 32 sources → 5 new articles, 2 updated. New: gateway-internals-c-architecture, sv2-downstream-architecture, ocean-sv2-stance-and-prior-art, operator-value-and-threat-model, datum-sv2-proxy-playbook (topic). Updated: datum-protocol (confidence high; full wire format), datum-gateway-overview (Rust-port retraction).

# Pre-rename history (when topic was 'datum-gateway')

## [2026-05-28] init | topic wiki created (anchored on OCEAN-xyz/datum_gateway @ a3da9e69)

## [2026-05-28] ingest-collection | datum-gateway via git: 2 new, 0 skipped, 2 total candidates (HEAD a3da9e6975984fd0ae584f37d76fe4afe2c75bac)

## [2026-05-28] ingest | OCEAN Documentation Index (raw/articles/2026-05-28-ocean-docs-index.md)
## [2026-05-28] ingest | Alternate Templates (raw/articles/2026-05-28-ocean-alternate-templates.md)
## [2026-05-28] ingest | DATUM Setup Guide (raw/articles/2026-05-28-ocean-datum-setup-guide.md)
## [2026-05-28] ingest | Lightning Payouts (raw/articles/2026-05-28-ocean-lightning-payouts.md)
## [2026-05-28] ingest | Core Antispam Node Policy (raw/articles/2026-05-28-ocean-core-antispam-policy.md)
## [2026-05-28] ingest | Core Node Policy (raw/articles/2026-05-28-ocean-core-policy.md)
## [2026-05-28] ingest | Data-Free Node Policy (raw/articles/2026-05-28-ocean-data-free-policy.md)
## [2026-05-28] ingest | OCEAN Node Policy (raw/articles/2026-05-28-ocean-node-policy.md)
## [2026-05-28] ingest | TIDES Technical Documentation (raw/articles/2026-05-28-ocean-tides-technical-documentation.md)
## [2026-05-28] ingest | The Origins of DATUM (raw/articles/2026-05-28-ocean-origins-of-datum.md)
## [2026-05-28] ingest | Introduction to the Lightning Network (raw/articles/2026-05-28-ocean-intro-to-lightning.md)
## [2026-05-28] ingest-collection | ocean-docs via web: 11 new (1 index + 10 sub-pages), 0 skipped (canonical_url=https://ocean.xyz/docs)

## [2026-05-28] compile | 3 sources → 5 new articles, 0 updated (datum-gateway-overview, datum-protocol, gateway-data-flow, stratum-usernames-and-modifiers, deployment-and-node-config)

## [2026-05-28] compile | 11 sources → 4 new articles, 3 updated (new: datum-history-and-motivation, tides-payout, lightning-payouts, node-policy-variants; updated: datum-gateway-overview, gateway-data-flow, deployment-and-node-config)
