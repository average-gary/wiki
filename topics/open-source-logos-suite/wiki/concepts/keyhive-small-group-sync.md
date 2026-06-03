---
title: "Keyhive: small-group E2EE CRDT sync (Ink & Switch March 2025)"
type: concept
created: 2026-06-02
updated: 2026-06-02
verified: 2026-06-02
volatility: hot
confidence: medium
sources:
  - raw/articles/2026-06-02-keyhive-github-repo.md
  - raw/articles/2026-06-02-keyhive-releases-cadence.md
  - raw/articles/2026-06-02-keyhive-notebook-intro.md
  - raw/articles/2026-06-02-keyhive-notebook-overview.md
  - raw/articles/2026-06-02-keyhive-notebook-riblt.md
  - raw/articles/2026-06-02-riblt-paper.md
  - raw/articles/2026-06-02-secsync-yjs-e2ee.md
  - raw/articles/2026-06-02-anyproto-any-sync.md
  - raw/articles/2026-06-02-yjs-no-builtin-e2ee.md
---

# Keyhive: small-group E2EE CRDT sync (Ink & Switch March 2025)

## TL;DR

[Keyhive](https://github.com/inkandswitch/keyhive) is Ink & Switch's pre-alpha Rust workspace bundling three distinct primitives that together address the gap Yjs has always punted on: convergent capabilities for delegation, BeeKEM for continuous group key agreement (forward secrecy + post-compromise security without a central server), and Beelay sync over RIBLT for sub-second set reconciliation. After ~60 alpha cuts between September 2025 and May 2026 it is still tagged `0.0.0-alpha.*` with no security audit, so christ-is-lord should not adopt the full stack today — but the *shape* of the protocol fits a real christ-is-lord use case (a six-person home-Bible-study group sharing private notes) better than anything in our current Yjs/Hocuspocus path. The recommended posture is to prototype a `cil-keyhive` transport behind the same trait the Yjs binding already satisfies, watch for v0.1 + audit, and consider backporting RIBLT into the Hocuspocus path independently.

## Evidence

### Project state and license

Keyhive's GitHub repo ([[../../raw/articles/2026-06-02-keyhive-github-repo.md|repo]]) is Apache-2.0, opened in August 2024, public since the March 2025 "pre-alpha" announcement. The README is unambiguous: *"DO NOT use this release in production applications"* and the code *"has not been through a security audit at time of writing."* As of 2026-06-02 the latest commit was 2026-05-28 ("Fix Wasm API parameters") with 178+ commits and 208 stars. Release tags ([[../../raw/articles/2026-06-02-keyhive-releases-cadence.md|cadence]]) tell the same story from a different angle: 60+ pre-release cuts in eight months, all stuck at semver `0.0.0`. This is research-engineering velocity, not stabilisation.

The workspace contains three crates: `keyhive_core` (Rust, the signing/encryption/delegation core including `cgka.rs` for BeeKEM, plus `principal/`, `crypto/`, `ability.rs`, `access.rs`, `contact_card.rs`), `keyhive_wasm` (TypeScript bindings via wasm-bindgen, which is the surface most apps will integrate against today), and `beelay-core` ("auth-enabled sync over end-to-end encrypted data"). Funding and direction are entirely Ink & Switch — the same lab behind the [[./decentralized-sync.md|local-first essay and Automerge]].

### Three primitives bundled together

The [[../../raw/articles/2026-06-02-keyhive-notebook-overview.md|design notebook]] is structured around three layers, each independently interesting:

1. **Convergent Capabilities** ([[../../raw/articles/2026-06-02-keyhive-notebook-intro.md|notebook 01]]). A capability model midway between object-capabilities and certificate-capabilities, allowing *"stateless self-certification with a cryptographic proof."* Documents delegate control via public keys representing users, groups, or devices; "groups" are a thin abstraction over delegation chains. Crucially the threat model preserves Automerge-level partition tolerance: it tolerates ops that causally depend on later-discovered malicious content, concurrent revocation by multiple admins, and back-dated ops by malicious actors, all without consensus.

2. **BeeKEM Continuous Group Key Agreement.** A binary-tree CGKA (the bee-themed pun on TreeKEM/MLS) that gives forward secrecy + post-compromise security at logarithmic typical cost. Members rotate Diffie-Hellman keys via BLAKE3 KDF; removing a member blanks their leaf and path; concurrent updates preserve all contributions until a causally-subsequent op overwrites them. This is the part Yjs and Automerge straightforwardly do not have.

3. **Beelay sync** layered on **RIBLT** ([[../../raw/articles/2026-06-02-keyhive-notebook-riblt.md|notebook 05]], [[../../raw/articles/2026-06-02-riblt-paper.md|Yang/Gilad/Alizadeh SIGCOMM 2024]]). Three reconciliation passes — membership graph, document collection state, then per-doc BeeKEM ops + sedimentree chunk compression — completing in ~2 round trips in the common case. RIBLT is the headline efficiency win: bandwidth scales with the *difference* between two peers' sets, not the size of either set. Two billion-item sets differing in 5 elements reconcile in ~7.5 symbols (~240 bytes), with 1.35–1.7× overhead on the actual diff. SIGCOMM benchmarks on Ethereum mempool sync showed 5.6× lower completion time and 4.4× lower bandwidth versus the production system.

### What the alternatives do and don't offer

- **Yjs / yrs** ([[../../raw/articles/2026-06-02-yjs-no-builtin-e2ee.md|repo]]): zero built-in E2EE, no group keys, no auth. The README itself defers to external solutions (Serenity, Skiff, secsync). Christ-is-lord's [[./decentralized-sync.md|current Hocuspocus path]] inherits this: the relay sees plaintext document state.
- **Automerge with WebSocket sync**: same situation. Encryption-at-rest exists but no group-key-agreement story. Keyhive is in fact the Ink & Switch team's *answer* to that gap for Automerge.
- **Anytype any-sync** ([[../../raw/articles/2026-06-02-anyproto-any-sync.md|repo]]): MIT-licensed, deployed at scale, Curve25519 + DID identity, encrypted DAGs with cryptographically-signed CRDT changes. But the access-control model is bespoke and tied to Anytype's space concept, and any-sync is not designed as a generic substrate to drop under another app's data model.
- **secsync** ([[../../raw/articles/2026-06-02-secsync-yjs-e2ee.md|repo]]): the practical near-term option for Yjs E2EE today — XChaCha20-Poly1305 + Ed25519, snapshots + updates over a relay. But explicitly *no* CGKA: group key rotation is the application's problem.

No production-grade Keyhive deployment exists as of 2026-06-02. None could; the project is pre-alpha and unaudited.

## Implications for christ-is-lord

- **The use-case shape that fits Keyhive is a 6-person home-Bible-study group, not a 50k-pubkey publish-to-the-world feed.** Concretely: a small group shares sermon notes, highlights on shared verses, a reading plan, and prayer requests. Privacy matters (people share doubts and life situations); membership is small (~5–15) and changes occasionally (someone joins, someone moves away). This is exactly Keyhive's stated design centre — surprise parties, meeting notes — and it is *not* the shape of the existing Nostr publish path, which is firehose-style and pseudonymous.
- **Recommended posture: prototype-only, behind a trait.** Define a `GroupSyncTransport` trait in `logos_core` that the existing Yjs/Hocuspocus binding already satisfies, then add a `cil-keyhive` impl as a feature-gated crate. Defer any user-visible exposure until Keyhive ships v0.1 (or whatever the first non-`0.0.0` tag is) *and* a third-party security audit lands. This keeps optionality without committing to an unaudited dependency.
- **RIBLT is independently valuable and can be backported.** The set-reconciliation primitive is decoupled from BeeKEM and capabilities. The [[../../raw/articles/2026-06-02-riblt-paper.md|paper]] is public, the algorithm is straightforward to re-implement (or borrow `beelay-core`'s implementation directly), and our current Hocuspocus path could plausibly use it for awareness-set diffing or cross-relay catch-up. This is a small, auditable win even if Keyhive itself never makes it into christ-is-lord.
- **BeeKEM specifically targets a gap the Nostr identity layer doesn't fill.** [[./identity-and-recovery.md|NIP-22242 + NIP-07]] gives us per-user keys but no group-key abstraction with forward secrecy. If we ever want a small-group note channel where compromise of one member's device today doesn't expose last year's notes, BeeKEM (or MLS — RFC 9420 — as a more conservative alternative) is the right primitive.
- **Risks to flag now.** (1) Pre-alpha, no audit; the cryptographic surface is the worst place to take "move fast" risk. (2) n=1 funder — Ink & Switch is a research lab, not a foundation; if they pivot, Keyhive likely freezes. (3) Wire format unstable — 60 alpha cuts in 8 months means any storage we persist today is upgrade-debt. (4) Automerge-coupled by default — `keyhive_core` is generic but `beelay-core` is built around Automerge binary format, so a Yjs adapter is non-trivial work, not a config switch.
- **Decision rule.** Revisit when *both* (a) Keyhive ships any release that drops the `0.0.0-` prefix, and (b) a public security audit is published. Until then: track, prototype-on-a-branch, do not ship.

## Open questions

- Is there a Yjs adapter on the Keyhive roadmap or only Automerge? (Notebook hints Automerge-only at the encryption-at-rest layer.)
- What is the storage-format upgrade story across alpha tags — do clients on `alpha.30` interop with `alpha.58`?
- How does BeeKEM compare in concrete bytes-on-the-wire and CPU vs MLS (RFC 9420) for a 6-person group? MLS has the IETF maturity story and existing audits; BeeKEM has the local-first concurrent-revocation story.

## See Also

- [[decentralized-sync|Decentralized Sync]] — current Hocuspocus path; Keyhive is a candidate replacement / RIBLT backport target
- [[identity-and-recovery|Identity and Recovery]] — Nostr is the user-identity layer; Keyhive's CGKA is for *group-key* agreement, a different primitive
- [[nostr-key-rotation|Nostr key-rotation: 2026 state of the art]] — the rotation gap; BeeKEM's continuous-group-key-agreement is the related primitive at the group level
- [[~/wiki/topics/rust-multi-platform/wiki/concepts/loro-vs-y-crdt-mobile|Loro vs y-crdt for Rust-native mobile CRDT sync]] — sister substrate decision; Keyhive could layer over either
- [[credible-exit|Credible Exit Principle]]
- [[../topics/engineering-playbook|Engineering Playbook]]
