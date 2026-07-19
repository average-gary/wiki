---
title: "ACINQ Rust footprint (none)"
source: https://github.com/ACINQ
type: analysis
tags: [acinq, eclair, scala, kotlin, non-rust]
ingested: 2026-06-22
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: no
agent: gap-closing path C
---

# ACINQ Rust Footprint — Effectively None

ACINQ is a deliberate Scala/Kotlin shop, not a Rust contributor.

## Confirmed Rust components

- **`ACINQ/txread`** — https://github.com/ACINQ/txread
  - 100% Rust, "very basic bitcoin transaction parser"
  - Last meaningful activity ~2015
  - 9 total commits, 6 stars
  - Not published to crates.io
  - **Dormant experiment, not production**

## Production stack (all non-Rust)

- **eclair** (Scala) — flagship Lightning node
- **phoenix** (Kotlin 53.5% / Swift 46.2%) — mobile wallet
- **phoenixd** (Kotlin) — headless Phoenix daemon
- **lightning-kmp** (Kotlin) — multiplatform Lightning
- **bitcoin-kmp**, **secp256k1-kmp**, **bitcoin-lib** — Kotlin/Scala
- secp256k1 bindings via JNI to C library, not via Rust crates

## 2025-2026 Rust activity

None detected. All recently active repos (June 2026 commits) are Scala or Kotlin.

## TWiR fit

**No.** ACINQ does not ship Rust in production. Nothing from ACINQ would warrant inclusion in TWiR. If TWiR ever covers ACINQ-adjacent material, it would be via third-party Rust LN implementations (LDK, lightning-rs ecosystem) interoperating with eclair over the wire — not via ACINQ's own code.

## Implication for ecosystem coverage

ACINQ is excluded from the "Rust Bitcoin ecosystem" Lightning-side analysis. Lightning-Rust = LDK + ldk-node + ldk-server + downstream users (Cash App, Mutiny, Lexe, Lightspark, Fedimint Gateway, Foundation Passport Prime). Not ACINQ.
