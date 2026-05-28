---
title: Decision — Library Distribution
type: decision
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: cold
status: active
confidence: high
tags: [decision, distribution, iroh, ipfs, content-addressing]
sources:
  - "[[raw/articles/2026-05-27-infra-text-iroh-blobs-protocol]]"
  - "[[raw/articles/2026-05-27-infra-text-ipfs-content-addressing]]"
  - "[[raw/articles/2026-05-27-infra-text-ipfs-real-world-limits]]"
  - "[[raw/articles/2026-05-27-infra-text-bittorrent-v2-merkle]]"
---

# Decision — Library Distribution

## Context

The Bible-text + lexicon + commentary library is mostly static, mostly immutable, occasionally updated. Default install is ~1 GB; advanced installs may be 10+ GB with all PD commentaries. Users install once, fetch updates rarely. Most users are passive consumers — they read, they don't host.

How do we ship the library?

## Options considered

### Option A — Centralized HTTPS / CDN (rejected as primary)

Single project-run CDN serves all packages.

**Pros**:
- Simplest
- Lowest latency
- Mature operations

**Cons**:
- Project shutdown = library unreachable
- No tamper-detection layer (TLS is hop-by-hop, not content-bound)
- Locks into single cloud vendor forever
- Can't be community-mirrored cheaply
- No cryptographic provenance

### Option B — Pure IPFS (rejected)

Project pins all packages on IPFS; users fetch via IPFS clients.

**Pros**:
- Content addressing
- Multi-vendor (any IPFS node can mirror)

**Cons**:
- **Brave dropped IPFS support in 2024** — production browser support is dead
- CIDs change with chunker/DAG-layout differences (the dedupe pitch is leaky)
- IPNS for mutable refs is slow and unreliable
- In practice everyone uses HTTP gateways → it's "CDN with hashes"
- Mobile IPFS clients are heavy

### Option C — Pure BitTorrent v2 (rejected)

Project seeds packages via BitTorrent v2.

**Pros**:
- Mature swarm software
- Per-file SHA-256 roots enable selective downloads

**Cons**:
- No production WebTorrent v2 — browsers can't participate
- Adoption thin; few users have torrent clients
- Mobile awkward
- Right for power users; wrong as primary

### Option D — Iroh blobs (rejected as sole option, accepted as primary)

BLAKE3-verified streaming over QUIC. HashSeq collections as the package unit.

**Pros**:
- Range requests are first-class — fetch only what's needed
- BLAKE3 verified streaming detects tampering on partial fetches
- HashSeq groups a Bible package as one address
- Hub already has deep Iroh expertise

**Cons**:
- Pre-1.0 (0.35 baseline)
- UDP — fails on UDP-blocking firewalls
- No browser support (mobile + desktop only)

### Option E — Hybrid: Iroh blobs + HTTPS mirrors + opt-in IPFS/BitTorrent (chosen)

Layer Iroh-blobs as the canonical content-addressed package format, with HTTPS mirrors for fallback and IPFS/BitTorrent as opt-in additional channels.

**Pros**:
- Iroh handles the happy path (range requests, BLAKE3 verification, P2P when peers available)
- HTTPS mirrors handle UDP-blocked users and zero-setup access
- Tamper detection via BLAKE3 hashes published in a project-signed manifest over HTTPS
- Universities, churches, denominational orgs can run Iroh nodes OR HTTP mirrors trivially
- Project shutdown ≠ content unreachable as long as anyone mirrors
- IPFS/BitTorrent as additional channels for power users

**Cons**:
- More moving parts than a single-stack approach
- Multiple package format / addressing schemes to maintain (BLAKE3 root for Iroh, may differ from IPFS CID, may differ from BTv2 hash)

## Decision

**Adopt Option E — hybrid with Iroh blobs as primary content-addressed format + HTTPS mirrors as boring fallback.**

### Architecture

```
1. Trust anchor: project-signed manifest over HTTPS
   - Lists each package's metadata (name, version, BLAKE3 root, license, size)
   - Signed by project key; published at multiple URLs (DNSLink, GitHub releases, project mirror)

2. Canonical packages: Iroh-blobs HashSeq collections
   - Each package addressed by BLAKE3 root
   - HashSeq groups: text + morphology + lexicons + commentary set as one collection
   - Range-fetch supported

3. Boring fallback: HTTP range-request mirrors
   - Cloudflare R2, S3, university hosting
   - Same BLAKE3-addressed blobs; client verifies on download
   - For users behind UDP-blocking firewalls

4. Opt-in mirrors:
   - IPFS gateway (for users who want it)
   - BitTorrent v2 (for power users)
   - GitHub releases (simplest possible fallback)

5. Plugin distribution: HTTPS only
   - Plugins are tiny; no need for content addressing
   - Signed manifests, marketplace verification
```

### Update flow

1. Client periodically fetches signed manifest from HTTPS
2. Compares package BLAKE3 hashes against installed
3. New version detected → fetch via Iroh (if available) or HTTPS mirror
4. Verify BLAKE3 of fetched blob matches manifest entry
5. Atomic install (write to temp, fsync, rename)

### Mirror operator setup

We provide tooling for community mirrors:

- `bible-suite-mirror` — Iroh + HTTP server combined; serves BLAKE3 blobs from a content store
- `bible-suite-publish` — for the project itself; pushes a new version, generates signed manifest
- Mirror operators get a feed of new packages; choose which to mirror

A church running a small server, a university running a campus mirror, a denominational org running a regional mirror — all can participate trivially.

### Why not pure HTTPS

A pure-HTTPS / CDN model:
- Vendors a single cloud provider
- Has no tamper-detection layer
- Can't be community-mirrored cheaply
- Locks into project's hosting forever

The hybrid model:
- Project can shut down — content keeps flowing as long as anyone mirrors
- Tamper detection is content-addressed (BLAKE3)
- Migration between mirrors is invisible to users

## Implications

- Need an Iroh-blobs publishing pipeline + signed manifest tooling
- Need community-mirror documentation + operator tools
- Need HTTPS mirror infrastructure (small project; CF R2 + S3 origin)
- Need IPFS / BitTorrent gateways for opt-in users (light operational lift)
- Manifest format becomes the project's primary versioning surface — design carefully

## See Also

- [[../concepts/decentralized-text-distribution|Decentralized text distribution]]
- [[../reference/decentralized-infra-candidates|Decentralized infra candidates]]
- [[../topics/engineering-playbook|Engineering playbook]]
- [[../../../iroh-transport-stratum-v2/wiki/_index|iroh-transport-stratum-v2 topic]]
