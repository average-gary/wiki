---
title: "CLINK Issue #6 — CLINK over Namecoin: NIP-05 discovery without HTTPS"
source: https://github.com/shocknet/CLINK/issues/6
type: article
ingested: 2026-06-09
path: spec-primitives
quality: 3
credibility: medium
tags: [clink, nostr, nip-05, namecoin, discovery, transport, issue]
---

## Source overview

GitHub issue #6 (opened 2026-05-18 by `mstrofnone`) proposes resolving the right-hand side of a NIP-05 identifier via Namecoin/ElectrumX rather than HTTPS, leaving CLINK's payload structures unchanged. It is the only open issue on the CLINK repository as of 2026-06-09 and surfaces a real ambiguity about how CLINK pointers are discovered when no central web server exists.

## Key findings

- The issue proposes a discovery alternative: instead of fetching `https://<host>/.well-known/nostr.json` to resolve `name@host`, the host portion is treated as a Namecoin name resolved via ElectrumX queries.
- The author argues this requires **zero spec changes** because CLINK reuses NIP-05's JSON shape — only the *transport for fetching that JSON* changes.
- Claimed benefits:
  - Censorship resistance (no CA/DNS dependency)
  - Composability with existing Nostr relay transports
  - Author claims **9+ clients already support this Namecoin pattern in production**.
- Author requests: validation of framing, guidance on whether docs would accept this, discussion of any spec robustness changes needed.
- No labels, milestone, or assignee — issue is a discussion proposal, not a tracked work item.
- Reveals that NIP-05 resolution is the assumed default discovery path for CLINK pointers (`clink_offer` mapping in well-known JSON, single-string `clink_offer` in kind 0 metadata).

## Cited identifiers/keys

- NIP-05 well-known JSON: `https://<host>/.well-known/nostr.json`
- Namecoin namespace mentioned: `nostr` (Namecoin name namespace for nostr records)
- ElectrumX (Namecoin name resolver protocol)
- CLINK NIP-05 fields: `clink_offer` (object map and single-string variant)

## Direct quotes

- "the right-hand side of a NIP-05 identifier is resolved by reading a Namecoin name via ElectrumX instead of by fetching `https://<host>/.well-known/nostr.json`"
- (paraphrased) "9+ clients already support this pattern in production"
- (paraphrased) "Existing CLINK JSON structures map directly to Namecoin's nostr namespace"

## Open questions surfaced

- Does ShockNet plan to formalize alternate discovery transports (Namecoin, IPFS, blossom, Webfinger over Tor) in the spec?
- How does a wallet decide which transport to use for a given identifier (suffix sniff? user config? both attempted?)
- Is `clink_offer` the only NIP-05 field CLINK relies on, or does Manage also have a discovery path through NIP-05?
- Does the open status with no maintainer response mean the proposal is welcome, dormant, or politely-deferred?

## Why this source matters for the topic

This issue exposes a thinly-documented but load-bearing assumption in the CLINK spec — that NIP-05 (and therefore HTTPS+DNS) is the default discovery path for static pointers. Any compilation discussing CLINK's "operating entirely over Nostr" claim must reconcile that the *bootstrap* still typically requires HTTPS. The issue also reveals that a sub-community is exploring Namecoin-based bootstrap, which could become a meaningful divergence point.
