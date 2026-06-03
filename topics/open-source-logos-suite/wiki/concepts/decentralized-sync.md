---
title: Decentralized Sync
type: concept
created: 2026-05-27
updated: 2026-06-02
verified: 2026-06-02
volatility: warm
status: active
confidence: high
tags: [decentralized, sync, identity, atproto, nostr, automerge, yjs, did]
sources:
  - "[[raw/articles/2026-05-27-infra-sync-atproto-pds]]"
  - "[[raw/articles/2026-05-27-infra-sync-atproto-account-migration]]"
  - "[[raw/articles/2026-05-27-infra-sync-nostr-nip51]]"
  - "[[raw/articles/2026-05-27-infra-sync-automerge-repo]]"
  - "[[raw/articles/2026-05-27-infra-sync-local-first-essay]]"
  - "[[raw/articles/2026-05-27-case-bluesky-not-decentralized]]"
---

# Decentralized Sync

For user notes, highlights, reading plans, and sermon drafts that need to travel between devices. Honest evaluation of the candidates and the recommended hybrid model.

> **Identity recommendation corrected 2026-06-02.** This article previously recommended ATProto `did:plc` as the primary identity model. Subsequent research at [[nostr-key-rotation]] and the v1.0 implementation choice confirmed Nostr (NIP-22242 + NIP-07) as the right identity layer for a Bible-study app, despite the unsolved rotation gap. **The CRDT-substrate analysis below remains valid; the identity recommendation has flipped.** See [[identity-and-recovery]] for the corrected model.

## Per-candidate evaluation

### ATProto / PDS (recommended for identity, not sync data)

**Identity**: `did:plc` (PLC directory) or `did:web` (self-sovereign).
**Ownership**: signed Merkle repo, content-addressed.
**Recovery**: documented PDS-to-PDS migration; 72hr window; optional self-custody rotation keys.
**Real apps**: Bluesky (millions of users), Whitewind (blogs), Smoke Signal (events).

**Why for identity**:
- The only model that **degrades gracefully** for non-technical users
- Default: hosted PDS with email recovery — 99% of users live here
- Optional: self-custody rotation keys for the 1% who want true sovereignty
- Optional: self-host PDS for the truly committed

**Caveats**:
- PLC directory is **soft-centralized** (run by Bluesky PBC; protocols allow alternatives but none deployed)
- Self-host PDS is real but ops-heavy
- PDS data model (records, lexicons) is a poor fit for rich notes/sermons → use it for identity, not the user-data CRDT

### Nostr (NIP-51)

**Identity**: raw secp256k1 nsec/npub.
**Ownership**: signed events on user-chosen relays.
**Recovery**: nsec backup IS recovery; NIP-46 bunkers (Amber, nsec.app) are the emerging UX fix.
**Real apps**: Damus, Amethyst, Primal, Highlighter.

**Why partial**:
- True "credible exit" — nsec works against any relay
- Dumb-relay model is robust

**Caveats**:
- **Lose nsec = lose identity forever** (no recovery model for non-technical users)
- Coarse data model for rich documents
- De-facto centralization on a few large relays
- Discovery across relays still unsolved

**Use case**: lightweight social signals (public reading plans, highlights shared with small groups, encrypted DMs). Not for the primary user-data sync.

### Automerge / automerge-repo (recommended for user data)

**Identity**: none built-in (DocumentIds + app-supplied auth).
**Ownership**: CRDT replicated across peers.
**Recovery**: any peer with the doc is a backup.
**Real apps**: Ink & Switch prototypes, Tonk, Patchwork.

**Why for user data**:
- Rich CRDT semantics (text, JSON, history) fit notes and sermon drafts perfectly
- Pluggable storage and network adapters
- Apps own identity/auth model (good — pair with ATProto for identity)
- Strong history/branching for sermon-draft workflow

**Caveats**:
- Auth and E2E encryption are DIY — pair with ATProto identity or Nostr signing
- Smaller production set than Yjs

### Yjs / yrs (alternative for user data)

**Identity**: app-supplied.
**Ownership**: CRDT replicated.
**Recovery**: any peer.
**Real apps**: Linear, JupyterLab RTC, AFFiNE, Evernote — large production set.

**Why a strong alternative**:
- Most production-validated CRDT in 2026
- Pluggable providers: `y-indexeddb` → `y-websocket` → `Hocuspocus`
- Y.XmlElement maps to Cascadia-style annotations

**vs Automerge**: Yjs has better text-merge perf and a larger ecosystem; Automerge has richer history queries. Pick one and commit.

### Hypercore / Hyperdrive

**Identity**: per-feed Ed25519 key.
**Ownership**: append-only signed log.
**Real apps**: Pears (Holepunch), Keet (chat), Beaker (defunct).

**Caveats**:
- Small ecosystem
- Multi-writer (Autobase) still maturing
- JS/Bare-only — wrong fit for Rust core

**Verdict**: skip.

### Solid (PODs / WebID)

**Identity**: WebID URL.
**Ownership**: file-system-style POD.
**Real apps**: Inrupt enterprise pilots; near-zero consumer adoption.

**Verdict**: skip — 10 years of hype, no consumer traction.

### Anytype any-sync

Closed-ish, weak public docs.

**Verdict**: skip.

## The hardest sub-problem: identity recovery

Every option fails the non-technical user the same way: **lose all devices = lose data unless you wrote down a seed phrase you didn't understand**. Practical mitigations, ranked:

| Approach | Mechanism | Real-world success |
|----------|-----------|-------------------|
| **Custodial-default + self-custody-optional** | Hosted PDS with email recovery; rotation keys for power users | ATProto/Bluesky — ✅ works at consumer scale |
| **Remote signers** | Key in a bunker; devices request signatures | Nostr NIP-46 (Amber, nsec.app) — emerging |
| **Social recovery / Shamir splits** | k-of-n trustees | Anytype, some wallets — limited adoption |
| **Pure seed phrase** | 12-24 words | All crypto wallets — fails for grandma |

**Recommendation**: build on ATProto-style custodial-default. Run a free hosted sync server (or PDS) for the 99%. Document and support self-hosting for the 1%. **NEVER force users to manage keys to use the app.**

## Recommended hybrid model (corrected 2026-06-02)

### Identity: Nostr (NIP-22242 + NIP-07)

- User generates or imports an `nsec`; pubkey IS the identity
- NIP-07 (`window.nostr`) signer ecosystem: Alby, nos2x, Amber (Android), nsec.app (iOS/web)
- NIP-22242 challenge/verify against the sync server (BIP-340 Schnorr, ±10-min `created_at` skew, atomic challenge consume)
- Recovery hot path: NIP-46 bunker (the user's nsec lives in a bunker app; clients request signatures over a secure channel without holding the raw nsec)
- Compromise path: kind:0 social-layer migration convention (best-effort, not a protocol primitive — see [[nostr-key-rotation]] for the rotation-gap caveat)
- Optional: a secondary did:plc identity for users who want cross-protocol social discovery on Bluesky; treat as a plugin, not the default

### User data CRDT: Yjs / yrs (today); evaluate Loro for v0.5+

- Production-track-record: Linear, JupyterLab RTC, AFFiNE, Evernote
- Pluggable providers: `y-indexeddb` → `y-websocket` → `Hocuspocus`
- Y.XmlElement maps to Cascadia-style annotations
- **Trajectory note (2026-06)**: [[~/wiki/topics/rust-multi-platform/wiki/concepts/loro-vs-y-crdt-mobile|Loro v1.12 has overtaken yrs v0.18]] on the Rust-native-mobile axis (Loro post-1.0, monthly cadence, working UniFFI Swift xcframework; yswift dormant since April 2024; Yjs v14 still in RC). Yjs wire-compat is the only remaining yrs case. Re-evaluate at v0.5+.

### Lightweight social: Nostr public sharing (NIP-23 / NIP-51 / NIP-94)

Same identity layer as the primary — no separate Nostr account needed. Public sharing is opt-in per-event-kind:
- Sermon outlines → NIP-23 long-form (kind 30023)
- Reading plans + curated libraries → NIP-51 sets (kind 30004 / 30002)
- Library + plugin manifests → NIP-94 file-metadata (kind 1063)

The reader/publisher ecosystem already exists: Yakihonne and highlighter.com for long-form; standard NIP-51 set adoption across Damus/Amethyst/Primal.

### Result

- 99% of users: free hosted Hocuspocus account, sync just works, single Nostr identity for both auth and public sharing
- Power users: NIP-46 bunker + multiple relay sets they choose from
- Sovereignty users: self-host Hocuspocus + run their own Nostr relay
- Project can shut down: data on disk + Nostr nsec is portable to any other Nostr-aware app + content-addressed library packages survive = users don't lose anything

## What to NOT do

- **Don't make decentralization the marketing pitch.** "Credible exit" is the honest framing (per [[credible-exit|Credible exit principle]]).
- **Don't ship pure-P2P sync as the default** — NAT traversal, peer discovery, and offline merging are still unsolved at scale in 2026
- **Don't require self-hosting** to use the app — that's a moat for power users, not an entry barrier
- **Don't pick more than one CRDT** — pick Yjs or Automerge, not both

## See Also

- [[../topics/engineering-playbook|Engineering playbook]]
- [[identity-and-recovery|Identity and recovery]] — corrected 2026-06-02; Nostr is the recommended identity model
- [[nostr-key-rotation|Nostr key-rotation: 2026 state of the art]] — the rotation gap that drove the correction
- [[keyhive-small-group-sync|Keyhive: small-group E2EE CRDT sync]] — RIBLT reconciliation backportable into Hocuspocus path
- [[~/wiki/topics/rust-multi-platform/wiki/concepts/loro-vs-y-crdt-mobile|Loro vs y-crdt for Rust-native mobile CRDT sync]] — substrate trajectory for v0.5+
- [[credible-exit|Credible exit principle]]
- [[file-over-app|File over app]]
