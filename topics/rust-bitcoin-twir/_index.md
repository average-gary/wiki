---
title: Rust Bitcoin Ecosystem & TWiR Submissions
type: topic-index
created: 2026-06-22
updated: 2026-06-22
status: active
summary: Survey of the Rust Bitcoin ecosystem (rust-bitcoin/BDK/LDK/Stratum SRI/Fedimint/Cashu/Nostr crates) framed around finding submission-worthy items for This Week in Rust. Covers active crates, recent releases, blogposts, talks, jobs, and CFPs that pass TWiR's submission rules (no paywalls, no LLM-only, project updates require Rust-specific framing).
---

# Rust Bitcoin Ecosystem & TWiR Submissions

The intersection of two streams: (a) what Rust crates and projects in the Bitcoin/Lightning/ecash space are actively shipping, releasing, or writing about themselves; (b) what fits the editorial criteria of [This Week in Rust](https://this-week-in-rust.org/). The output is a steady pipeline of PR-able items: Project/Tooling Updates, Crate of the Week candidates, Rust Walkthroughs, Calls for Participation, and Observations/Thoughts.

## Top-level questions

1. Which Rust Bitcoin crates and projects are actively releasing and writing tutorial-grade or release-note content TWiR will accept?
2. What are the editorial rules TWiR applies to project updates, COTW, and walkthroughs — and how do Bitcoin-Rust projects typically miss them?
3. Where is the historical TWiR coverage of rust-bitcoin / BDK / LDK / Stratum SRI / Fedimint / Cashu — frequency, framing, who PRs?
4. Who are the maintainers/orgs (Spiral, BDK, LDK lab, Stratum WG, Fedimint, CDK, hashpool.dev, BraidPool, p2poolv2, OCEAN/DATUM, sv2-apps) and what release/blog cadence do they keep?
5. What CFPs, Rust-Bitcoin meetups, conferences (btc++, Bitcoin Optech-adjacent Rust talks) and CFP-Events fit TWiR's CFP section?
6. Which crates are CoTW candidates given crates.io activity and recent changelog quality?
7. What are common rejection patterns (bare GitHub link, paywalled Medium, thin update) and how to write a TWiR-ready entry?
8. What's the contribution workflow — PR template, draft file location, deadline cadence — and how does the editor team triage?

## Sections

- [[wiki/concepts/_index|Concepts]] — TWiR submission rules, Rust Bitcoin crate primitives, COTW criteria
- [[wiki/topics/_index|Topics]] — synthesis articles: state of Rust Bitcoin, sub-ecosystems, submission playbooks
- [[wiki/reference/_index|Reference]] — crates, orgs, maintainers, prior TWiR mentions, CFPs
- [[wiki/decisions/_index|Decisions]] — submission-fit ADRs (which items make it, which don't)
- [[wiki/theses/_index|Theses]] — testable claims about ecosystem coverage gaps

## Sources

- [[raw/_index|Raw sources]]

## Related wikis

- [[../stratum-sri/_index|stratum-sri]] — SV2 Rust crate suite (`stratum-mining/stratum`)
- [[../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — p2poolv2 + sv2-apps integration
- [[../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — payout schemes (mining-side context)
- [[../ldk-server/_index|ldk-server]] — LDK Server gRPC binary
- [[../cdk-ldk-lnurl/_index|cdk-ldk-lnurl]] — CDK + LDK Node mint
- [[../fedimint/_index|fedimint]] — Federated Chaumian e-cash protocol
- [[../iroh-transport-stratum-v2/_index|iroh-transport-stratum-v2]] — Iroh as SV2 transport
- [[../sv2-coinbase-identity/_index|sv2-coinbase-identity]] — coinbase miner-tagging thesis
- [[../sv1-upstream-reverse-translator/_index|sv1-upstream-reverse-translator]] — reverse Stratum translator
- [[../datum/_index|datum]] — DATUM gateway / SV2-front proxy
- [[../clink-protocol/_index|clink-protocol]] — Nostr-native Lightning standards
- [[../nixos-reproducible-builds-bitcoin/_index|nixos-reproducible-builds-bitcoin]] — Nix builds for Bitcoin Rust projects
- [[../rust-multi-platform/_index|rust-multi-platform]] — Rust mobile/desktop/WASM surfaces (consumer-side)

## Log

See [[log]].
