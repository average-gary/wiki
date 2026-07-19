---
title: TWiR Sections — What Goes Where
type: concept
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: cold
confidence: high
sources:
  - "[[../../raw/data/2026-06-22-twir-issue-cadence-stats|TWiR cadence stats]]"
  - "[[../../raw/articles/2026-06-22-twir-readme-submission-rules|README]]"
---

# TWiR Sections — What Goes Where

The standard TWiR issue (per issue 656, 2026-06-17) has these content sections. This guide maps Rust-Bitcoin items to the right section.

## Updates from Rust Community

### Official
Anything from rust-lang/rust org or Rust Foundation. Rust-Bitcoin items rarely fit unless rust-lang publishes about Bitcoin (basically never).

### Foundation
Rust Foundation announcements. Same constraint.

### Newsletters
Cross-newsletter shoutouts. A bitcoin-Rust newsletter (e.g., a hypothetical "This Week in Rust Bitcoin") could fit here.

### Project/Tooling Updates (~12 slots/issue)
**The main slot for Rust-Bitcoin projects.** Requires:
- Rust-specific content beyond changelog
- Long-form or tutorial framing
- One per contributor per week

Best candidates:
- LDK quarterly recaps / security releases
- BDK quarterly recaps
- Fedimint, Cashu CDK releases
- Foundation KeyOS / ngwallet (embedded)
- P2Poolv2 (mining)
- rust-nostr SDK release announcements

### Observations/Thoughts (~7 slots/issue)
Reflective / opinion / architecture pieces. Best candidates:
- Lexe SGX + LDK case study ([[../../raw/articles/2026-06-10-lexe-ldk-sgx-enclaves|Lexe]])
- LDK Pathfinding deep-dive ([[../../raw/articles/2025-02-10-ldk-pathfinding-deep-dive|Pathfinding]])
- "Rust Bitcoin ecosystem by the numbers" (synthesis on data)
- "Bitcoin's quiet majority in Rust" (gap thesis vs State of Rust 2024)

### Rust Walkthroughs (~5 slots/issue)
Tutorial / how-to. Higher bar — needs explanatory pedagogy. Best candidates:
- BDK + WASM tutorials
- LDK Node mobile embedding
- Embedded Rust on Bitcoin signing devices

### Research (rare)
Formal methods, algorithmic, peer-reviewed. Best candidates:
- Kani / Miri proofs in rust-bitcoin (PRs #5579, #5955, #6393, #6243) ([[../../raw/repos/2026-04-rust-bitcoin-kani-pr-6393|PR #6393]])

### Miscellaneous
Catch-all. Historically where Bitcoin items have landed (Kraken/Tobin Harding 2022).

## Crate of the Week

Single COTW per issue. Rust-Bitcoin candidates by 2026-06-22:
- `bitcoin_hashes` 1.0.0 ([[../../raw/repos/2026-06-19-rust-bitcoin-units-0-5-0|release cluster]]) — first stable major
- `bdk_wallet` 3.0 (when RC ships)
- `cdk` (Cashu Dev Kit)
- `nostr-sdk` (rust-nostr)
- `lightning` 0.2.x (LDK)

## Calls for Testing
RFC-stage Rust features. Almost never Bitcoin-specific.

## Call for Participation
### CFP - Projects
Beginner-friendly issues in OSS projects. **Underused for Bitcoin Rust** — opportunity.

### CFP - Events
Conference CFPs. **bitcoin++ Toronto / Berlin / Seoul 2026** are clean fits ([[../../raw/articles/2026-06-btcplusplus-2026-schedule|bitcoin++]]).

## Updates from the Rust Project
Compiler, Library, Cargo, Rustdoc, Rustfmt, Clippy, Rust-Analyzer. Not Bitcoin-relevant.

## Rust Compiler Performance Triage
Not Bitcoin-relevant.

## Approved RFCs / Final Comment Period / New & Updated RFCs
Rust language RFC process. Not Bitcoin-relevant.

## Upcoming Events
Local meetups, conferences. **bitcoin++**, Bitcoin BitDevs Rust meetups fit here (already historical precedent: Triangle BitDevs, LA Bitcoin Devs).

## Jobs
Open Rust positions. Spiral (LDK / BDK), Lightspark, Lexe, Block, Foundation, Strike, Voltage, Mutiny would fit if hiring is current.

## Quote of the Week
Pithy quote — open submissions; editor's pick.

## See also

- [[twir-submission-rules|TWiR Submission Rules]]
- [[../topics/submission-playbook|Submission Playbook]]
