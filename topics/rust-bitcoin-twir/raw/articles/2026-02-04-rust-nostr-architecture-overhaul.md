---
title: "rust-nostr SDK Architecture Overhaul (Feb 2026)"
source: https://nostrcompass.org/en/newsletters/2026-02-04-newsletter/
type: newsletter-summary
tags: [rust-nostr, nostr-sdk, api-redesign, builder-pattern, signer]
ingested: 2026-06-22
date: 2026-02-04
verified: 2026-06-22
volatility: warm
credibility: medium
twir-fit: maybe-back-fill
twir-section: Project/Tooling Updates
agent: adjacent
---

# rust-nostr SDK Architecture Overhaul (Feb 2026)

Newsletter summary of 21 merged PRs reshaping core APIs in rust-nostr/nostr-sdk.

## Notable PRs
- #1245 redesigns notification APIs.
- #1244 replaces `RelayNotification::Shutdown` with `RelayStatus::Shutdown`.
- #1243 aligns signer APIs.
- #1242 cleans up client/relay method signatures.
- #1241 introduces a builder pattern for client options.
- #1240 redesigns message-sending APIs.
- #1239 redesigns REQ unsubscription.
- #1229 reworks relay removal.
- #1246 (open) adds blocking API support.

## Release context
- Tagged: v0.42.0 (May 20 2025), v0.43.0 (Jul 28 2025), v0.44.0 (Nov 6 2025).
- Bitcoin/Lightning relevance: NWC (NIP-47), Zaps, NIP-87 mint discovery for Cashu/Fedimint.

## TWiR fit
- **Section**: Project/Tooling Updates.
- Strong "Crate of the Week" candidate when next release lands.
- Aged for direct submission; better as anchor for a forward-looking release submission.
