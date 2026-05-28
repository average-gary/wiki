---
title: Decentralized Text Distribution
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [decentralized, ipfs, libp2p, iroh, bittorrent, atproto, hypercore, cdn]
sources:
  - "[[raw/articles/2026-05-27-infra-text-iroh-blobs-protocol]]"
  - "[[raw/articles/2026-05-27-infra-text-ipfs-content-addressing]]"
  - "[[raw/articles/2026-05-27-infra-text-ipfs-real-world-limits]]"
  - "[[raw/articles/2026-05-27-infra-text-bittorrent-v2-merkle]]"
  - "[[raw/articles/2026-05-27-infra-text-atproto-blob-spec]]"
  - "[[raw/articles/2026-05-27-infra-text-hypercore-pears]]"
---

# Decentralized Text Distribution

For shipping the digital library (texts, lexicons, commentaries) — mostly static, mostly immutable, occasionally updated — to clients. Honest evaluation of the candidates.

## Per-candidate evaluation

### Iroh blobs (recommended)

**What**: BLAKE3-verified streaming over QUIC. HashSeq collections as the natural unit for a Bible package.

**Why for this use case**:
- **Range requests are first-class** — fetch only Genesis 1 + the LSJ entry for "λόγος" without pulling 2 GB
- BLAKE3 hashing is fast (1-3 GB/s on modern hardware) and the verified-streaming property means partial fetches still detect tampering
- HashSeq lets you publish a *collection* (a Bible package: text + morphology + lexicons + commentary set) as one address
- Production-ready protocol; iroh-blobs 0.35 baseline

**Caveats**:
- Pre-1.0 (still moving)
- Requires UDP — fails on UDP-blocking corporate firewalls
- Hub already has deep coverage in [[../../../iroh-transport-stratum-v2/wiki/_index|iroh-transport-stratum-v2]]; reuse that knowledge

### IPFS

**What**: content addressing via CID/multihash; DAG-CBOR; IPNS for mutable refs.

**Why partial**:
- Real shadow-library deployments (Anna's Archive, LibGen, Wikipedia mirrors)
- Specs are mature

**Caveats (significant)**:
- **CIDs change with chunker/DAG-layout differences** — breaks the "same content = same CID" pitch
- **Brave dropped IPFS in 2024** — production browser support is dead
- **In practice everyone consumes via HTTP gateway** — at that point it's "CDN with hashes," not P2P
- IPNS for mutable refs is slow and unreliable

**Verdict**: opt-in mirror only.

### BitTorrent v2

**What**: Merkle trees + per-file SHA-256 roots, mature swarm software.

**Why partial**:
- Production-ready protocol
- Per-file hashes enable selective downloads

**Caveats**:
- **No production WebTorrent v2** — browsers can't participate
- Adoption thin five years after spec ratification
- Power-user fallback only

**Verdict**: opt-in mirror only.

### ATProto blobs

**What**: CIDv1+raw+sha-256 addressing, hosted by user's PDS.

**Why it doesn't fit**:
- PDS-hosted, account-bound, CDN-served — **not P2P**
- Account suspension nukes blobs
- ~1 MiB cap on bsky.social
- Wrong shape for GB corpora

**Verdict**: out for library distribution.

### Hypercore / Pears

**What**: append-only signed log + Hyperdrive filesystem.

**Why partial**:
- Fits "one publisher, many readers, occasional updates" perfectly
- Production apps exist (Keet chat, PearPass)

**Caveats**:
- **JS/Bare-only ecosystem** — weak Rust/Go story
- Locks you into Pear runtime
- Smaller community than IPFS or libp2p

**Verdict**: out — wrong language ecosystem for a Rust core.

## The honest critique

Every candidate fails the "browser-only consumer with no node" test except IPFS via gateway, which is just a CDN with extra steps. The decentralization space overpromises here.

**At GB scale with passive readers, you need someone running seeders, period.**

That can be:
- The OSS project itself (still needs hosting; just spreads the cost)
- Universities, churches, foundations donating mirror capacity
- Power users opting in to seed
- Commercial CDN as fallback

There is no magic in IPFS, libp2p, or BitTorrent that eliminates the seeder problem. Choose your distribution stack to make seeding *cheap and verifiable*, not to eliminate it.

## Recommended hybrid stack

### Layer 1 — Trust anchor: BLAKE3 hashes over plain HTTPS

Publish a signed manifest (project key) listing every package's BLAKE3 root hash over **plain HTTPS** (DNSLink, GitHub releases, mirror site).

This gives you:
- Tamper detection without depending on any P2P network's liveness
- A version control point — clients check the manifest, see new hash, fetch new package
- Compatibility with corporate firewalls

### Layer 2 — Content-addressed packages: Iroh-blobs HashSeq

Each Bible package (text + morphology + lexicons + commentary set) is a HashSeq collection addressed by its BLAKE3 root.

- Fetch full package OR specific blobs
- BLAKE3 verified streaming
- Range requests
- P2P when peers available

### Layer 3 — Boring HTTP mirrors

For users behind UDP-blocking firewalls or who can't run an Iroh node:

- HTTP range-request mirrors on Cloudflare R2, S3, university hosting
- Mirror serves the same BLAKE3-addressed blobs
- Client verifies BLAKE3 on download — same trust model as P2P fetch

### Layer 4 — Opt-in mirrors

- **IPFS gateway** for users who want it
- **BitTorrent v2** for power users
- **GitHub releases** as the simplest fallback

## Why this beats "just use a CDN"

A pure-CDN model:
- Vendors a single cloud provider
- Has no tamper-detection layer (TLS is hop-by-hop, not content)
- Doesn't enable community mirrors at low cost
- Locks you into the project's hosting forever

The hybrid model:
- Project can shut down — the content keeps flowing as long as anyone mirrors
- Universities, churches, denominational orgs can run Iroh nodes or HTTP mirrors trivially
- Tamper detection is content-addressed
- Migration between mirrors is invisible to users

## See Also

- [[../topics/engineering-playbook|Engineering playbook]]
- [[../reference/decentralized-infra-candidates|Decentralized infra candidates]]
- [[../decisions/library-distribution|Library distribution decision]]
- [[../../../iroh-transport-stratum-v2/wiki/_index|iroh-transport-stratum-v2]]
