---
title: "ATProto Blob Specification — PDS-Hosted, CDN-Served"
source_url: "https://atproto.com/specs/blob"
type: article
path: infra-text
date_ingested: 2026-05-27
date_published: unknown
tags: [decentralized, atproto, content-distribution, content-addressing]
quality: 3
confidence: high
summary: "ATProto blobs are SHA-256 / CIDv1-raw addressed, but authoritatively hosted by the user's PDS and re-served via per-app CDNs. Not a peer-to-peer distribution network — closer to 'signed content on someone else's S3'."
---

# ATProto Blob Specification — PDS-Hosted, CDN-Served

## Key findings

- Blobs use **CIDv1, codec=raw, sha-256**, base32 string form. So the addressing primitive is sound and compatible with IPFS-style content addressing (no DAG/chunker quirks because raw bytes).
- **Authority is centralized at the PDS**. "Blobs are authoritatively stored by the account's PDS instance, but views are commonly served by CDNs associated with individual applications." This is the crux: there is no swarming, no DHT lookup, no peer fetch. If the PDS goes away, the blob goes away (modulo CDN caches and consumer-app mirrors).
- **Account-bound**: every blob is "managed in the context of an individual account (DID)". Account suspension or deletion makes blobs inaccessible. This is wildly unsuitable for a publisher-of-record model where the SBL/Tyndale House publishes a critical text once and expects it to outlive their AT account.
- **No size cap in the spec**, but PDS operators set per-account quotas. Bluesky's bsky.social PDS limits blobs to ~1 MiB images today. Self-hosted PDSes can lift this, but the moment you require self-hosted PDS you've lost the "free distribution via the network" pitch.
- **Third-party distribution is not a designed-for use case**. The spec assumes the blob is referenced by a record signed by the DID that uploaded it.

## Notable quotes / specifics

- "Blobs are authoritatively stored by the account's PDS instance, but views are commonly served by CDNs associated with individual applications."
- "Servers may have their own generic limits... they might implement account-wide quotas on data storage; maximum blob sizes."
- "All blobs are managed in the context of an individual account (DID)."

## Source notes

ATProto is built for social-graph content (avatars, posts, video clips), not GB-scale corpus distribution. The shared CID-with-raw-codec primitive means an ATProto blob ref *could* point to data also pinned on IPFS or served via Iroh, which is mildly interesting for cross-system addressing. But ATProto on its own is the wrong tool for shipping a digital library — it's signed-content-on-someone-else's-S3 with replication guarantees no stronger than the PDS operator.
