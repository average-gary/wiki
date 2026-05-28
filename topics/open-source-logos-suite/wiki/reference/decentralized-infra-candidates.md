---
title: Decentralized Infra Candidates
type: reference
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [decentralized, ipfs, libp2p, iroh, atproto, nostr, hypercore, reference]
sources:
  - "[[raw/articles/2026-05-27-infra-text-iroh-blobs-protocol]]"
  - "[[raw/articles/2026-05-27-infra-text-ipfs-content-addressing]]"
  - "[[raw/articles/2026-05-27-infra-text-ipfs-real-world-limits]]"
  - "[[raw/articles/2026-05-27-infra-text-bittorrent-v2-merkle]]"
  - "[[raw/articles/2026-05-27-infra-text-atproto-blob-spec]]"
  - "[[raw/articles/2026-05-27-infra-text-hypercore-pears]]"
  - "[[raw/articles/2026-05-27-infra-sync-atproto-pds]]"
  - "[[raw/articles/2026-05-27-infra-sync-nostr-nip51]]"
  - "[[raw/articles/2026-05-27-infra-sync-automerge-repo]]"
---

# Decentralized Infra Candidates

Reference matrix of decentralized infrastructure for an OSS Logos suite. Honest evaluation: where each candidate fits, where it fails, what to use it for.

## Library / text distribution

For shipping mostly-static, mostly-immutable corpora (Bible texts, lexicons, commentaries) to clients.

| Candidate | Maturity | Browser support | Range fetch | Mobile fit | Recommendation |
|-----------|----------|-----------------|-------------|------------|----------------|
| **Iroh blobs** | Pre-1.0 (0.35 baseline), production-track | No (UDP) | ✅ First-class | OK on Wi-Fi/LTE | ✅ **Primary** for content-addressed packages |
| **HTTPS mirrors** | Mature | ✅ | ✅ HTTP Range | ✅ | ✅ **Primary fallback** |
| **IPFS** | Mature | ⚠️ Brave dropped 2024; gateways only | ✅ via gateway | OK via gateway | Opt-in mirror only |
| **BitTorrent v2** | Mature | ❌ No WebTorrent v2 | ✅ Per-file | ❌ Mobile awkward | Opt-in for power users |
| **ATProto blobs** | Beta | ✅ via PDS | ❌ | ✅ via PDS | ❌ Wrong shape (account-bound, ~1MB cap) |
| **Hypercore** | Mature in JS | ❌ | ✅ | OK in JS apps | ❌ JS-only ecosystem |

**Recommended stack**: Iroh blobs HashSeq + BLAKE3 root hashes published over HTTPS + HTTP range mirrors. See [[../concepts/decentralized-text-distribution|Decentralized text distribution]].

## User identity

| Candidate | Recovery for non-tech users | Self-host | Real adoption | Recommendation |
|-----------|---------------------------|-----------|---------------|----------------|
| **ATProto did:plc** | ✅ Email reset; rotation keys for upgrade | ✅ Self-host PDS | Bluesky millions | ✅ **Primary** |
| **did:web** | ⚠️ DNS-anchored | ✅ | Limited | Power users w/ stable domain |
| **did:key** | ❌ Lose key = identity dead | N/A | Limited | Ephemeral identities only |
| **Nostr (npub/nsec)** | ❌ Lose nsec = identity dead | ✅ Run own relay | Damus, Amethyst, Primal | Power users / public broadcasts |
| **Solid (WebID)** | Limited | Yes | Near-zero consumer | ❌ Skip |

**Recommendation**: ATProto did:plc with project-run hosted PDS as default; rotation keys + self-host PDS as upgrade paths. See [[../concepts/identity-and-recovery|Identity and recovery]].

## User data CRDT / sync

| Candidate | Production track record | Rust port | Pluggable providers | Recommendation |
|-----------|------------------------|-----------|---------------------|----------------|
| **Yjs / yrs** | ✅ Linear, JupyterLab, AFFiNE, Evernote | ✅ yrs | ✅ y-indexeddb / y-websocket / Hocuspocus | ✅ **Primary** |
| **Automerge / automerge-repo** | ⚠️ Smaller production set | ✅ | ✅ | ✅ Strong alternative |
| **Hypercore / Hyperdrive** | ✅ in JS | ⚠️ | ⚠️ | ❌ Wrong language ecosystem |
| **Custom OT** | N/A | DIY | DIY | ❌ Don't reinvent |

**Recommendation**: Yjs/yrs for the primary user-data CRDT. Automerge if richer history-querying matters more than text-merge perf. Pick one and commit.

## Lightweight social / public broadcast

For optional features (public reading plans, shared highlights, group sermons).

| Candidate | Real adoption | Use case fit | Recommendation |
|-----------|---------------|--------------|----------------|
| **Nostr (NIP-51)** | Damus, Primal, Amethyst | Lightweight events, replaceable lists | ✅ Plugin layer |
| **ATProto records** | Bluesky | Federated social | ⚠️ App-bound to ATProto domain |
| **ActivityPub** | Mastodon | Federated social | ❌ Heavy; wrong fit |

**Recommendation**: Nostr as an optional plugin. Don't make it required.

## Why this matrix is unusual

Most "decentralized app" advice in 2026 is over-prescribed: pick one stack (ATProto OR Nostr OR IPFS) and commit. That advice fails for a Bible-study app because:

- **Library distribution** wants content addressing + mirrors → Iroh + HTTPS
- **Identity** wants graceful recovery → ATProto did:plc
- **User data** wants rich CRDT semantics → Yjs/Automerge
- **Public sharing** wants lightweight signed events → Nostr

These have different shapes and different solutions. Don't force one stack onto all of them.

## What to NOT pick

| Stack | Why not |
|-------|---------|
| **Pure IPFS** | Brave dropped support 2024; production usage is HTTP gateways |
| **Pure libp2p** | Reinvents identity, sync, distribution from scratch — too low-level |
| **Hypercore for everything** | Locks into Pear runtime; JS-only |
| **Solid PODs** | 10 years of hype; no consumer adoption |
| **Pure self-host required** | ❌ Excludes 99% of users |
| **Pure P2P required** | ❌ NAT traversal still unsolved at scale |

## Cross-reference: existing hub research

The hub already has deep coverage of:
- **Iroh** — see [[../../../iroh-transport-stratum-v2/wiki/_index|iroh-transport-stratum-v2 topic]]
- **Rust UI frameworks** — see [[../../../rust-multi-platform/wiki/_index|rust-multi-platform topic]]
- **ATProto / Nostr** (in passing) — referenced in [[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] and elsewhere

This article doesn't duplicate that work; it specializes the recommendations for an OSS Logos suite.

## See Also

- [[../concepts/decentralized-text-distribution|Decentralized text distribution]]
- [[../concepts/decentralized-sync|Decentralized sync]]
- [[../concepts/identity-and-recovery|Identity and recovery]]
- [[../decisions/library-distribution|Library distribution decision]]
- [[../topics/engineering-playbook|Engineering playbook]]
