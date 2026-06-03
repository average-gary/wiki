---
title: Identity and Recovery
type: concept
created: 2026-05-27
updated: 2026-06-02
verified: 2026-06-02
volatility: warm
status: active
confidence: high
tags: [identity, recovery, nostr, did-plc, did-key, did-web, atproto, key-rotation]
sources:
  - "[[raw/articles/2026-05-27-infra-sync-atproto-pds]]"
  - "[[raw/articles/2026-05-27-infra-sync-atproto-account-migration]]"
  - "[[raw/articles/2026-05-27-infra-sync-nostr-nip51]]"
  - "[[raw/articles/2026-06-02-nip-26-delegated-event-signing]]"
  - "[[raw/articles/2026-06-02-nip-46-remote-signing]]"
  - "[[raw/articles/2026-06-02-did-plc-spec-rotation-keys]]"
  - "[[raw/articles/2026-06-02-nostr-how-key-safety-guidance]]"
---

# Identity and Recovery

> **Corrected 2026-06-02.** This article previously recommended ATProto `did:plc` as the default identity model. After the v1.0 implementation shipped Nostr (NIP-22242) and the round-2 research at [[nostr-key-rotation|Nostr key-rotation: 2026 state of the art]] confirmed both (a) Nostr's structural advantages for a Bible-study app and (b) the genuine rotation gap, the recommendation has flipped: **Nostr is the right identity layer for content-authorship apps, despite having worse rotation than did:plc.** The DID method comparison below is preserved as reference; the recommendation section is rewritten.

## The right question

Which identity model fits a Bible-study app, where the user's identity *is* their authorship of sermons, notes, and highlights — and where compromise of that identity has authorship-attribution consequences, not just account-takeover consequences?

This is a different question from "which identity model works for consumer apps in general." For a generic consumer app, did:plc's clean rotation primitive is decisive. For a content-authorship app, the structural property that **the pubkey IS the identity** outweighs rotation, because there is no way to "rotate" who wrote a thing.

## DID method comparison (reference)

The DID landscape relevant to this domain. **None of these is the recommendation; they exist for context.**

### `did:key`
- Identifier IS the key — `did:key:z6MkHa...`
- Pure cryptographic, no infrastructure
- **Cannot rotate keys** — if compromised, identity is dead
- Use case: ephemeral identities, local-only apps

### `did:web`
- DID is hosted at a web URL — `did:web:example.com:user:alice`
- DNS+HTTPS is the trust anchor
- Self-sovereign if you own the domain
- **Single point of failure**: lose the domain, lose the identity
- Use case: organizations or technical users with stable domains

### `did:plc`
- Identifier is opaque — `did:plc:ewvi7nxzyoun6zhxrhs64oiz`
- PLC directory maintains a hash-chained, priority-ordered key-rotation log
- Users can rotate keys (compromise recovery) with a 72-hour window
- Users can migrate PDS hosts while keeping handle and history
- **Soft-centralized**: PLC is run by Bluesky PBC; protocol allows alternatives
- Real-world: deployed for ~12M+ Bluesky users; rotation works

### Nostr (`npub` / `nsec`)
- Pure secp256k1 keypair, BIP-340 Schnorr signatures
- No infrastructure required; pubkey IS the identity
- **No native rotation primitive** — see [[nostr-key-rotation]] for the 2026-06 state
- Real-world: Damus, Amethyst, Primal, Yakihonne, Highlighter; large NIP-07 client ecosystem

## Why Nostr wins for a Bible-study app

The trade-off looks like this:

| Property | did:plc | Nostr |
|----------|---------|-------|
| Pubkey IS identity | ❌ DID is opaque, points at a key | ✅ npub IS the identity |
| Offline verification | ⚠️ requires PLC directory lookup | ✅ BIP-340 Schnorr, fully offline |
| Host-coupling | ⚠️ PDS-coupled (hosted-default) | ✅ relay-pluggable; nsec works against any relay |
| Native rotation | ✅ rotation log + 72hr window | ❌ no merged NIP; PR #2137 stalled (see [[nostr-key-rotation]]) |
| Recovery for non-technical users | ✅ email-reset on hosted PDS | ⚠️ NIP-46 bunker is the emerging answer |
| Existing ecosystem for content authorship | ⚠️ lexicon-specific apps | ✅ NIP-23 long-form (Yakihonne, Habla, highlighter.com) |
| Cryptographic-attribution model | hash-chained, mutable identity | immutable: every signed event is permanently attributable to the pubkey at signing time |

For a Bible-study app, the bolded properties matter:
- **Pubkey IS identity** — when a pastor's sermon outline is signed and published, the cryptographic chain is "this content → this pubkey," not "this content → this pubkey-at-time-T which may have rotated to a different pubkey." The latter is a recipe for argument over which "version" of the pastor authored what.
- **Offline verify** — works in environments without a directory lookup (rural churches, missions field, intermittent connectivity).
- **Existing ecosystem for content authorship** — sermon outlines on NIP-23 and reading-plan curation on NIP-51 are deployed patterns; ATProto lexicons for the same use case do not yet exist outside the Bluesky firehose.

The trade-off paid: **rotation is harder.** [[nostr-key-rotation]] documents that no merged Nostr key-rotation NIP exists in 2026-06; NIP-26 (delegated events) and NIP-06 (mnemonic seed derivation) are flagged "unrecommended" in the canonical NIPs README; PR #2137 is the most active rotation proposal but lacks consensus. There is no protocol-level rotation primitive comparable to did:plc's hash-chained log.

The implementation has accepted this trade-off and chosen Nostr.

## The recovery problem (modified)

Every cryptographic identity scheme runs into the same wall: **non-technical users will lose their keys**. They will:

- Not write down the seed phrase
- Lose the phone
- Forget which password manager has the key
- Reset the device thinking it'll restore from iCloud
- Email "I forgot my password" to a help desk that has no power to help

For a Bible-study app where the user might be a 70-year-old pastor with valuable sermon archives, this is real — *but it is a different problem from cryptographic rotation*. The two get conflated. They shouldn't.

- **Recovery (UX problem)**: I lost access to my key — how do I get back in? → Solved by hot-key UX (NIP-46 bunkers, password-managed nsec storage, multi-device sync of nsec via E2EE channel) and by separating identity recovery from data recovery.
- **Rotation (cryptographic problem)**: my key was compromised — how do I move authorship attribution to a new key without losing history? → **Currently unsolved at the Nostr protocol level.** Best available answer: kind:0 social-layer migration convention (see [[nostr-key-rotation]] §"Concrete recommendations").

Recovery without rotation is sufficient for the 99% case. Rotation matters only when the key is *known* to be compromised (leaked nsec, stolen device with hot-key access). For that scenario, the kind:0 social-layer convention is best-effort but real.

## Recommendation

### Default: Nostr nsec, NIP-07 signer

User generates (or imports) an nsec on first run. The app uses the standard NIP-07 (`window.nostr`) protocol so any of the deployed signer extensions/apps work — Alby, nos2x, Amber on Android, nsec.app on iOS, primal on mobile. Users who already have a Nostr identity from another client just bring it.

This is what [christ-is-lord](../../../../) v1.0 ships, with NIP-22242 challenge/verify for sync-server auth.

### Recovery hot path: NIP-46 bunker (remote signer)

For non-technical users — and increasingly for security-conscious technical users — the [[../raw/articles/2026-06-02-nip-46-remote-signing|NIP-46]] bunker pattern is the recommended hot path. The user's nsec lives in a bunker app (Amber on Android, nsec.app web, nostrify, etc.). Other clients request signatures over a secure channel without ever holding the raw nsec.

Bible-study app integration:
- First-run flow offers "use a bunker" as an option alongside "paste nsec" / "generate new"
- Bunker URI scheme: `bunker://<pubkey>?relay=...&secret=...`
- App stores only the bunker URI, not the nsec
- All signing operations go through the bunker

This dramatically narrows the blast radius of a phone loss or laptop theft.

### Compromise path: kind:0 social-layer migration

If a user's nsec is leaked or believed compromised:

1. User generates a new keypair on a clean device.
2. While the old key is still controlled by the user (i.e., before the attacker uses it), publish a `kind:0` (replaceable metadata) event from BOTH keys with `migrated_to: <new_npub>` / `migrated_from: <old_npub>` fields.
3. Continue signing new content with the new key.
4. Existing content under the old key remains attributable to the old pubkey (cryptographically immutable); the kind:0 chain is the social-layer breadcrumb that says "this person is the same person."

**This is best-effort, not a protocol primitive.** Relays and clients are not obligated to honor `migrated_to` / `migrated_from`. A determined attacker with the leaked nsec can publish their own kind:0 events claiming the original is fake. Document this honestly in the threat model rather than pretending it's solved.

See [[nostr-key-rotation]] §"Concrete recommendations" for the full rationale.

### Data recovery: separate from identity recovery

Per [[file-over-app]] and [[credible-exit]]: notes are markdown files on disk; highlights are JSONL on disk; library packages are content-addressed under `~/.christ-is-lord/library/`. **Losing the nsec doesn't lose the data**, because the data was never inside the identity layer.

If the user loses the device but has sync running (Yjs/Hocuspocus), the data is on the sync server. They sign in on a new device with their nsec → app pulls down the synced state. If they also lose the nsec, they can still recover the data file-system-wise from any device that previously had it, even if they cannot prove authorship of new posts going forward.

### Org / shared identity (optional)

Churches, denominational orgs, and seminaries that want a *shared* identity for institutional content (e.g., an "official" sermon series from a particular church) should provision a separate Nostr keypair for that purpose, kept in a bunker held by whoever has institutional sign-off authority. This is the same pattern as managing a shared Twitter/X account, but with cryptographic attribution. **Don't share an individual's nsec across people; use a separate institutional nsec.**

### What about did:plc?

Still useful as a *secondary* identity for users who want to mirror their identity onto Bluesky for cross-protocol social discovery. Treat it as an optional plugin, not the default. The original 2026-05-27 recommendation that did:plc be the primary identity model is **rejected** as of 2026-06-02 for the reasons above.

## What NOT to do

### Don't make seed phrases the *forced* default UX

A "write down these 24 words" flow shipped to a pastor who doesn't understand what BIP-39 is will fail at consumer scale. The correct UX is: bunker-by-default for users who want it; clearly-labeled nsec export for users who insist on self-custody; never a forced seed-phrase flow.

### Don't conflate identity and data

Identity is *whose pubkey signed this*. Data is the notes, sermons, highlights. These have different recovery models:
- Identity → Nostr nsec (recoverable via bunker if backed up; non-recoverable if lost without backup)
- Data → file-system (recoverable from any device that had it; recoverable from sync server)

The two failure modes are independent. Plan for them independently.

### Don't pretend Nostr rotation is solved

It's not. [[nostr-key-rotation]] is explicit. Marketing copy that says "your identity is fully sovereign and rotatable" misrepresents the protocol state. Marketing copy that says "your pubkey is your identity; protect it carefully; here's how to recover from common loss scenarios" is honest.

### Don't lean on NIP-26

NIP-26 (delegated event signing) is flagged "unrecommended" in the canonical NIPs README. Don't build features that depend on it.

### Don't require self-host for sovereignty

Self-hosting a Nostr relay is a power-user feature, not a sovereignty floor. The default Nostr architecture — nsec + NIP-07 signer + multiple public relays — already gives users credible exit (any relay works; nsec is portable). Self-hosting is for the 1% who want to control which relays see their content.

## Implementation sketch

```
On first run:
  1. App offers three options: (a) "Generate a new Nostr identity", (b) "Use a NIP-46 bunker", (c) "Import an existing nsec"
  2. (a) → app generates nsec, prompts user to back it up to password manager / printed-and-locked
  3. (b) → user pastes bunker URI; app stores URI only, never nsec
  4. (c) → user pastes nsec; app stores in OS keychain
  5. App identity = the resulting npub; sync-server signup uses NIP-22242 challenge/verify

On suspected key compromise:
  1. Settings → "Rotate identity"
  2. App generates new keypair on this device
  3. App publishes kind:0 from both old and new keys with migrated_to / migrated_from
  4. App switches default signing key to the new one
  5. Display: "Your old pubkey: <npub>. Existing content remains under that key.
     New content will be signed by your new pubkey: <npub>. Tell people you trust."

On device loss:
  1. User logs into a new device with their nsec (or bunker)
  2. App pulls synced state from Hocuspocus
  3. Done

On total identity loss (no nsec backup, no bunker):
  1. User cannot sign new content under the lost pubkey
  2. Existing content on disk and on sync server is still readable and exportable
     (file-over-app guarantees this)
  3. User generates a new identity and starts publishing under the new pubkey
  4. There is no cryptographic link from old to new in this case
```

## See Also

- [[nostr-key-rotation|Nostr key-rotation: 2026 state of the art]] — the round-2 research that drove the corrected recommendation here
- [[decentralized-sync|Decentralized sync]]
- [[credible-exit|Credible exit principle]]
- [[file-over-app|File over app]]
- [[../topics/engineering-playbook|Engineering playbook]]
