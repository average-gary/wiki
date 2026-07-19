---
title: Rust-Bitcoin Project Release Cadences
type: reference
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: warm
confidence: medium
sources:
  - "[[../../raw/articles/2026-04-20-bdk-2026-q1-update|BDK Q1]]"
  - "[[../../raw/articles/2026-01-21-bdk-2025-q4-update|BDK Q4]]"
  - "[[../../raw/articles/2025-11-06-bdk-2025-q3-update|BDK Q3]]"
  - "[[../../raw/repos/2026-06-19-rust-bitcoin-units-0-5-0|rust-bitcoin releases]]"
---

# Rust-Bitcoin Project Release Cadences

Useful for predicting when to watch for TWiR-submittable releases.

## BDK
- **Cadence**: quarterly recap blog post.
- **Pattern**: Q3 2025 (Nov), Q4 2025 (Jan 2026), Q1 2026 (Apr 2026) → Q2 2026 expected ~July 2026.
- **Crate releases**: ~monthly minor versions, ~quarterly major.
- **Author**: thunderbiscuit (consistent across all four observed quarterly posts).

## LDK
- **Cadence**: ~monthly architectural blog post on lightningdevkit.org.
- **Crate releases**: ~quarterly minor (0.2.0 Dec 2025, 0.2.2 Feb 2026, 0.2.3 Jun 2026).
- **Pattern**: parallel v0.1.x maintenance line + v0.2.x release line.
- **Recent posts**: Pathfinding (2025-02), VSS (2025-03), Fedimint Gateway (2025-01), Lightspark Sparknodes (2025-02), Lexe SGX (2026-06).

## rust-bitcoin
- **Cadence**: weekly merges; modular crate releases as components mature.
- **Recent**: bitcoin_hashes 1.0.0 (Jun 1), bitcoin-network-kind 1.0.0 (Jun 12), bitcoin-key-expression 0.1.0 (Jun 12), bitcoin-units 0.5.0 (Jun 19).
- **Pattern**: workspace modularization is ongoing — expect more 1.0 stable splits in 2026-2027.

## Fedimint
- **Cadence**: ~half-yearly milestone reviews (e.g., H1 2025 review on 2025-06-30).
- **Versions**: v0.5 (2024), v0.6 ("On-Chain for Everyone"), v0.7 (Iroh + LDK Node integration).

## CDK (Cashu)
- **Cadence**: ~monthly minor versions.
- **Latest**: 0.17.1 (2026-06-16); created 2024-04 → ~17 minor releases in 2 years = ~one every ~6 weeks.

## rust-nostr
- **Cadence**: ~quarterly major (0.42 May 2025, 0.43 Jul, 0.44 Nov, 0.45 alpha Jun 2026).
- **Pattern**: 21-PR architecture overhaul rounds (Feb 2026 example) → next overhaul likely H2 2026.

## P2Poolv2
- **Cadence**: ~biweekly releases (20 releases since project start).
- **Latest**: v0.12.0 (2026-06-12).

## Foundation KeyOS / ngwallet
- **Cadence**: KeyOS public since v1.2.0 (Mar 2026); v1.2.1 (Jun 18) suggests ~quarterly.
- **ngwallet**: 51 releases → frequent point releases.

## Stratum V2 SRI
- **Cadence**: ~monthly minor versions; latest v1.10.0 (2026-06-03).

## rust-dlc
- **Cadence**: irregular; v0.8.0 release prep merged Dec 2025 — release imminent or stalled.
- **Action**: watch repo tags.

## Conference cadence (bitcoin++)
- 2026 schedule: Nairobi (Jun 17-19, just concluded), Toronto (Jul 22-24), Berlin (Oct 1-3), Seoul (Nov 5-6).
- ~7 events per year; quarterly-plus cadence for Bitcoin-Rust talk recordings.

## Implications for TWiR submission scheduling

- **Every issue can have at least one Bitcoin-Rust item** if submitters track these cadences.
- **Quarterly recap posts (BDK)** should be auto-submitted ~1 week after publication.
- **Monthly architectural posts (LDK)** should be auto-submitted ~1 week after publication.
- **Security releases (LDK Loupe)** should be submitted same week — the freshness multiplies relevance.
- **Conference recordings** should be queued for submission as they publish (typically 4-8 weeks after event).
