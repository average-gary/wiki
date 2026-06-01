---
title: "SV2 Spec PR #113 — Worker-Specific Hashrate Tracking Extension (merged Jun 2025)"
source_url: https://github.com/stratum-mining/sv2-spec/pull/113
source_type: spec-pr
ingested: 2026-05-28
credibility: high
confidence: high
tags: [stratum-v2, extension-0x0002, SubmitSharesExtended, user_identity, TLV, worker-tracking]
---

# Worker-Specific Hashrate Tracking Extension (Type 0x0002)

## Why this matters
The SV2 working group's *chosen* solution for "we need per-worker identity to flow upstream past extended-channel aggregation." The fact that this exists as a separate extension is itself evidence that the base mining protocol's channel-open `user_identity` was not sufficient — and that the chosen solution does **not** route through coinbase.

## Key claims
- Adds optional TLV (Type `0x0002`, Field `0x01 = user_identity`, ≤32 bytes) appended to `SubmitSharesExtended` messages.
- Quote: "limited to a maximum of 32 bytes-length to not increase too much the additional bandwidth consumption for extended shares submissions."
- "Once negotiated, the client MUST append the TLV containing user_identity to every SubmitSharesExtended message."
- Authors / reviewers: GitGab19 (SRI), TheBlueMatt, Fi3 (Filippo Merli), Shourya742, jbesraa.
- Predecessor PR #110 (closed Nov 2024, https://github.com/stratum-mining/sv2-spec/pull/110) tried to add `user_identity` directly into `SubmitSharesExtended` via a flag; pushback from jakubtrnka (Braiins): "Why would you choose to use extended channel but pass the downstream user_identities with it? It's very confusing to me." That PR was abandoned in favor of #113's TLV approach.

## Reading on the thesis
**Strongly opposes the *prescribed* form of the thesis** — but **nuances rather than contradicts the *charitable* form**:
- The community's preferred solution for per-worker identity attribution is share-submission TLV, not coinbase tagging.
- This shows the SV2 working group considered (and rejected) extending `user_identity`'s role in ways that flow it further into the protocol pipeline.
- However, the TLV addresses *upstream identity flow* — the Pool *does* need per-worker `user_identity` for accounting. Once the Pool has that data, what it does with it on the *coinbase* side is unconstrained.
- A Pool that wants both share-attribution (PR #113 TLV) and coinbase-tagging (the thesis) can do both — they're orthogonal.
