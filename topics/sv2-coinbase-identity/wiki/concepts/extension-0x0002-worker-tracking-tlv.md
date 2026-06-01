---
title: "SV2 extension 0x0002 — Worker-Specific Hashrate Tracking TLV"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [stratum-v2, extension-0x0002, TLV, SubmitSharesExtended, user_identity, worker-tracking]
---

# Extension 0x0002 — Worker-Specific Hashrate Tracking

Merged into the SV2 spec via [PR #113](https://github.com/stratum-mining/sv2-spec/pull/113), Jun 2025.

## What it does
Adds an optional TLV (Type `0x0002`, Field `0x01 = user_identity`, ≤32 bytes) appended to every `SubmitSharesExtended` message once negotiated.

## Why it exists
Extended channels aggregate many downstream workers behind a single SV2 channel (typical proxy / JDC topology). Per-share, the Pool needs to know *which worker* submitted *which share* — but the channel-open `user_identity` is per-channel, not per-share.

The closed predecessor PR #110 tried to add `user_identity` directly into `SubmitSharesExtended`. Reviewer pushback (jakubtrnka, Braiins): "Why would you choose to use extended channel but pass the downstream user_identities with it? It's very confusing to me." That PR was abandoned in favor of #113's TLV approach.

## Reading on the thesis
- This extension is the SV2 working group's chosen *upstream* per-worker identity mechanism.
- It solves **share-level** attribution; it does not touch coinbase.
- The thesis (Pool-side coinbase tag from `user_identity`) is **orthogonal** — a Pool can implement both:
  - Use ext-0x0002 to attribute shares per worker.
  - Use channel-open `user_identity` (or the per-share TLV value) to derive a `miner_tag` for `JobFactory`.

The existence of ext-0x0002 demonstrates the working group considers per-worker identity flow a valid concern — but does **not** indicate any consensus blessing for coinbase tagging.

## See also
- [[wiki/concepts/user_identity-field]]
- [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]
- [[raw/articles/2026-05-28-sv2-spec-pr-113-worker-specific-hashrate-tracking]]
