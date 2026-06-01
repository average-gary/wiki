---
title: "user_identity (SV2 channel field)"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [stratum-v2, OpenMiningChannel, user_identity, Str0_255]
---

# user_identity

`user_identity` is a `Str0_255` field on both `OpenStandardMiningChannel` and `OpenExtendedMiningChannel` in the SV2 [[Mining Protocol|wiki/concepts/sv2-mining-protocol-overview]].

## Spec text
> "Unconstrained sequence of bytes. Whatever is needed by upstream node to identify/authenticate the client, e.g. 'braiinstest.worker1'. Additional restrictions can be imposed by the upstream role (e.g. a pool). It is highly recommended to use UTF-8 encoding."

— [[raw/articles/2026-05-28-sv2-spec-mining-protocol]]

## Where it lives in the SRI reference impl
Stored as `String` on both `StandardChannel` (`/Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/standard.rs:92`) and `ExtendedChannel` (`/Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/extended.rs:96`). Exposed via a `get_user_identity()` getter only.

It is **not currently passed into [[JobFactory|wiki/concepts/job-factory-and-coinbase-construction]]** in the non-JD `new_for_pool` constructor — the `miner_tag` slot in `JobFactory::new(...)` is hard-coded to `None` in that path.

— [[raw/repos/2026-05-28-sri-channels-sv2-job-factory-and-channel-constructors]]

## Spec stance vs. coinbase
The spec **does not** prescribe `user_identity` as input to coinbase construction, and **does not** forbid it. Per-miner coinbase content is normally the JD path's responsibility (see [[Coinbase ownership: Pool vs JDC|wiki/concepts/coinbase-ownership-pool-vs-jdc]]).

The SV2 working group's chosen mechanism for *upstream* per-worker identity flow on extended channels is the [[Worker-Specific Hashrate Tracking extension (0x0002)|wiki/concepts/extension-0x0002-worker-tracking-tlv]], appended to `SubmitSharesExtended`. That extension solves *share-level* attribution, not *coinbase-level* tagging — they are orthogonal.

## See also
- [[wiki/concepts/sv2-coinbase-scriptsig-layout]]
- [[wiki/concepts/job-factory-and-coinbase-construction]]
- [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]
- [[wiki/concepts/extension-0x0002-worker-tracking-tlv]]
- [[theses/sv2-coinbase-identity]]
