---
title: "rust-bitcoin Issues #3166 & #3172 — API churn critiques"
source: https://github.com/rust-bitcoin/rust-bitcoin/issues/3166
type: design-critique
tags: [rust-bitcoin, api-churn, darosior, matt-corallo, breaking-changes, ldk]
ingested: 2026-06-22
date: 2024-08-15
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: no (raw issues, not narrative)
twir-section: Observations background only
agent: contrarian
---

# rust-bitcoin API Churn Critiques

Two open issues from senior Bitcoin Rust contributors (2024-08).

## Issue #3166 — "API breaks are not for free" (darosior, 2024-08-14)
- Argues that since ~2022 rust-bitcoin's frequent breaking changes induce **large** downstream refactors, increasing bug risk in critical Bitcoin infrastructure.
- **Hard data point**: "**72% of rust-bitcoin downloads at crates.io this month are for releases older than 5 versions back**" — i.e., users are stuck on old versions, missing fixes.
- Lists 12+ specific PRs deemed needlessly breaking (renames, module reshuffles, "idiomatic" or vague-"safety" rewrites).
- Argues maintainers' churn applies opportunity cost to downstreams that should be doing security work; users patch with "the simplest patch that compiles," masking bugs.

## Issue #3172 — "BufRead requirement is paternalistic and impractical" (TheBlueMatt / Matt Corallo, 2024-08-15)
- "While its true that reading rust-bitcoin types directly without a buffer is gonna be slow, sadly the Rust world uses the `Read` type everywhere, not `BufRead`. As a result, in many cases, you end up with a `Read` that you have to read bitcoin data out of...which you can't."
- "The `BufRead` requirement was a cool idea in that it forced people to do a more efficient thing, but the less efficient thing isn't actually wrong, just slower, so should just be dropped."
- LDK lead engineer publicly critiquing rust-bitcoin API choices — cross-project signal.

## Issue #5248 (related)
- "We released a bunch of crates with TBD in them" — release-quality post-mortem; rust-bitcoin shipped `hashes`, `units`, `primitives` to crates.io with literal "TBD" placeholders in `#[deprecated]` attributes.

## TWiR fit
- **Not a fit alone** (raw GitHub issues, no narrative).
- Strong material for a **future Observations/Thoughts piece** comparing library-design philosophies.
- LDK README codifies the **opposite philosophy**: explicitly *not* providing on-disk storage, blockchain access, UTXO management, networking, or key management.
