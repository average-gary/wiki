---
title: Credible Exit Principle
type: concept
created: 2026-05-27
updated: 2026-06-02
verified: 2026-06-02
volatility: cold
status: active
confidence: high
tags: [decentralized, design-principle, atproto, bluesky, nostr]
sources:
  - "[[raw/articles/2026-05-27-case-bluesky-not-decentralized]]"
  - "[[raw/articles/2026-05-27-case-anytype-any-sync]]"
  - "[[raw/articles/2026-05-27-case-nostr-protocol]]"
  - "[[raw/articles/2026-05-27-case-file-over-app]]"
  - "[[raw/articles/2026-06-02-nostr-how-key-safety-guidance]]"
---

# Credible Exit Principle

The honest framing for "decentralized" apps in 2026: **users don't want decentralization, they want their data not held hostage.** Bluesky's PR struggle to defend the "decentralized" label produced this term; it's the right design target.

## The empirical evidence

| App | Decentralization claim | Reality | Adoption |
|-----|----------------------|---------|----------|
| **Bluesky** | Federated PDSes | 99.9% of users on bsky.social; relay storage 1TB→5TB in 4 months | Millions |
| **Anytype** | P2P encrypted | Most users on hosted relays | Modest |
| **Nostr** | Pure P2P relays | De-facto centralization on a few big relays | Niche, growing |
| **Obsidian** | Not decentralized | Files on disk; user-managed sync; closed-source client | Massive |
| **Logseq** | Not decentralized | Same as Obsidian | Smaller than Obsidian |

The "actually federated" apps don't have meaningfully more decentralization in practice than the file-on-disk apps. What they all share — and what users actually care about — is **a credible exit**.

## The principle

A user has a credible exit when:

1. Their data is in a portable, open format
2. They can move to a competing app without re-entering their data
3. They can take their data offline
4. They can migrate hosting providers
5. They can keep using the app even if the original provider shuts down

Crucially, **a credible exit does not require federation, P2P, or self-hosting**. It requires that the path away from the current host is real and known.

## How Bluesky/ATProto delivers credible exit (well)

- `did:plc` is portable — switch PDS, keep handle and history
- Account migration is documented and works (users have done it)
- Self-hosting PDS is real and supported
- Records use a shared lexicon — competing apps see the same data

How Bluesky fails to be "decentralized":
- 99.9% of users have never moved off bsky.social
- The PLC directory is run by Bluesky PBC
- DMs are fully centralized
- Relay storage is 1TB+ — running your own is impractical

But the credible exit is *real*, even if rarely exercised. That's enough.

## How Obsidian delivers credible exit (better, with no decentralization)

- Files on disk in markdown
- User picks any sync mechanism
- App is replaceable with any text editor
- No vendor lock-in — period

No federation, no P2P, no decentralized identity. Just open files. And it's the highest-adoption knowledge app in the space.

## How Logos fails credible exit

- Books in proprietary `.logos` format
- No way to take a library to a competitor
- Account-bound to Faithlife
- Sync only works through Faithlife servers

This is the gap an OSS suite should exploit: don't try to clone Logos's library; **deliver a credible exit *from* it that Logos can't match.**

## Implications for an OSS Logos suite

### Marketing frame

Don't pitch as "decentralized Bible software." Pitch as:
- "Your library is yours, in plain files."
- "Your notes outlive any app."
- "Sync your way: ours, git, your own server, or none."
- "Walk away anytime — without losing anything."

### Architecture implication

Build for credible exit at every layer:

| Layer | Credible exit |
|-------|---------------|
| **Library** | USFM/JSON files; content-addressed packages users can keep offline |
| **User data** | Plain markdown + JSONL files |
| **Sync** | Multiple options (file-based, hosted CRDT, self-host) |
| **Identity** | Nostr nsec — portable, signer-pluggable (NIP-07, NIP-46 bunker), works against any relay; nsec backup IS the credible exit. (See [[identity-and-recovery]] for the corrected position; the original 2026-05-27 did:plc recommendation has been superseded.) |
| **Plugins** | Sandboxed but open API; plugin output written to user files |
| **Walled translations** | BYO API key — license travels with user, not project |

### What credible exit is NOT

- **Not "fully decentralized"** — the Bluesky/Anytype evidence shows full P2P doesn't drive adoption
- **Not "self-hosting required"** — that's a power-user feature, not a default
- **Not "no servers"** — projects can run servers; users just need to be able to leave them

### When decentralization actually helps

Use decentralized infrastructure where it solves a real problem:

- **Library distribution** — content addressing prevents bit-rot, enables community mirrors, survives the project shutting down. ✅ Use Iroh + HTTPS.
- **Identity portability** — Nostr `nsec` is portable across relays and signer apps; the keypair IS the identity, no host or directory required. ✅ Use Nostr (NIP-22242 + NIP-07). Be honest about the trade-off: rotation is unsolved at the protocol level (see [[nostr-key-rotation]]); the credible-exit story is "your nsec backup is your identity" + a kind:0 social-layer migration convention if compromised.
- **Tamper detection** — BLAKE3 hashes signed by project key. ✅ Free.

Don't use it where it creates friction without solving anything:

- **Personal notes sync** — ❌ files-on-disk + Yjs hosted is fine
- **App identity recovery for non-technical users** — recommend NIP-46 bunker as the hot path; users who lose nsec without backup retain their on-disk data but lose authorship attribution under that pubkey. (See [[identity-and-recovery]] for the full recovery model.)
- **Plugin distribution** — ❌ HTTPS + signature is fine

## The frame for users

> Your Bible study, your data, your way. Pick our hosted sync or self-host or just keep files on disk. The app is open source; the data is open formats; the texts are open licenses. Walk away whenever — your work comes with you.

That's the pitch. Decentralization is mechanism, not message.

## See Also

- [[file-over-app|File over app]]
- [[decentralized-sync|Decentralized sync]]
- [[decentralized-text-distribution|Decentralized text distribution]]
- [[identity-and-recovery|Identity and recovery]] — corrected 2026-06-02; Nostr is the recommended identity model
- [[nostr-key-rotation|Nostr key-rotation: 2026 state of the art]] — the rotation gap is real; document it
- [[../topics/engineering-playbook|Engineering playbook]]
