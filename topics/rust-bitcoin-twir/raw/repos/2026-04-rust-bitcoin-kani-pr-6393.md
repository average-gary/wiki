---
title: "rust-bitcoin PR #6393 — core::cmp for Kani in Amount verification"
source: https://github.com/rust-bitcoin/rust-bitcoin/pull/6393
type: pr
tags: [rust-bitcoin, kani, formal-verification, amount, units, no-std]
ingested: 2026-06-22
date: 2026-06-18
verified: 2026-06-22
volatility: hot
credibility: high
twir-fit: yes-strong
twir-section: Research / Project/Tooling Updates
agent: academic
---

# rust-bitcoin PR #6393 — core::cmp for Kani

Open PR (mpbagot, 2026-06-18, four days before today). Swaps `std::cmp` for `core::cmp` because Kani occasionally chokes on the lack of `std`.

## Background: Kani in rust-bitcoin
- **PR #5579 (Feb 2 2026)** — Adds Kani harness in `bitcoin/src/consensus/verification.rs` symbolically proving:
  - `decode(encode(n)) == n` for all `n <= MAX_COMPACT_SIZE`
  - Any `n > MAX_COMPACT_SIZE` is rejected with `ParseError::OversizedCompactSize`
  - Driven by a real bug surfaced via differential fuzzing in PSBT parsing (PR #5697).
- **PR #5955 (Apr 2026)** — Updates the Kani proof to track new range-check semantics.
- **`u_amount_homomorphic` and `s_amount_homomorphic` proofs** — assert that satoshi-level arithmetic equals `Amount`/`SignedAmount` arithmetic when no overflow occurs (with checked-arithmetic preconditions); unwind = 4.
- **Issue #2561** (Kixunil) — Explores **Creusot** as a complement to Kani for invariant-style verification of `U256` and similar.

## Companion PR
- **PR #6243 (May 27 2026)** — Move Miri CI to a daily cron job. rust-bitcoin runs Miri (UB detector) regularly alongside Kani and fuzzing — layered formal/dynamic-analysis stack.

## TWiR fit
- **Section**: Research (strong) — concrete, recent, primary-source formal-methods work in a mainstream Rust crate.
- Could be wrapped with the broader "rust-bitcoin verification stack" theme: Kani harnesses + Miri cron + differential fuzzing.
- Submission framing: "rust-bitcoin's Kani-verified consensus encoding (PRs #5579, #5955, #6393)".

## Author chain
- Alkamal01 (#5579), reviewed by apoelstra and tcharding.
- mpbagot (#6393).
