---
title: Decentralized Sync
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
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

## Recommended hybrid model

### Identity: ATProto (`did:plc`)

- User signs up; project runs free PDS (or partners with one)
- Email recovery flow built-in
- Power users add rotation keys → self-custody
- Power users self-host PDS → full sovereignty
- Identity portable: did:plc lets users migrate PDS, keep handle and history

### User data CRDT: Yjs OR Automerge

Pick one. Recommendation: **Yjs** for production-track-record + Rust port (`yrs`).

- Local: `y-indexeddb` (browser) or sled-backed (desktop)
- Hosted: project-run `y-websocket` or `Hocuspocus`
- Self-host: same Hocuspocus, deployed by user

### Lightweight social: Nostr (NIP-51)

Optional opt-in feature for users who want public/group sharing:
- Public reading plans → Nostr replaceable events
- Shared highlights → Nostr text events
- Small-group DMs about sermons → encrypted Nostr DMs

This is a *plugin*, not a core dependency.

### Result

- 99% of users: free hosted account, sync just works, ATProto identity, no keys to manage
- Power users: self-custody rotation keys + Nostr identity (separate from ATProto)
- Sovereignty users: self-host PDS + Hocuspocus + Nostr relay
- Project can shut down: data on disk + ATProto migration + self-host docs = users don't lose anything

## What to NOT do

- **Don't make decentralization the marketing pitch.** "Credible exit" is the honest framing (per [[credible-exit|Credible exit principle]]).
- **Don't ship pure-P2P sync as the default** — NAT traversal, peer discovery, and offline merging are still unsolved at scale in 2026
- **Don't require self-hosting** to use the app — that's a moat for power users, not an entry barrier
- **Don't pick more than one CRDT** — pick Yjs or Automerge, not both

## See Also

- [[../topics/engineering-playbook|Engineering playbook]]
- [[identity-and-recovery|Identity and recovery]]
- [[credible-exit|Credible exit principle]]
- [[file-over-app|File over app]]
