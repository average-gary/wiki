---
title: Identity and Recovery
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [identity, recovery, did-plc, did-key, did-web, atproto, nostr]
sources:
  - "[[raw/articles/2026-05-27-infra-sync-atproto-pds]]"
  - "[[raw/articles/2026-05-27-infra-sync-atproto-account-migration]]"
  - "[[raw/articles/2026-05-27-infra-sync-nostr-nip51]]"
---

# Identity and Recovery

The hardest single sub-problem in a decentralized app for non-technical users. Pure-cryptographic identity (Nostr nsec, raw seed phrase) breaks every time a user loses their phone. The solution that works at consumer scale is **custodial by default with explicit graduation to self-custody.**

## DID method comparison

The relevant DID methods for this domain:

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

### `did:plc` (recommended for consumer apps)
- Identifier is opaque — `did:plc:ewvi7nxzyoun6zhxrhs64oiz`
- PLC directory maintains a key-rotation log
- Users can rotate keys (compromise recovery)
- Users can migrate PDS hosts while keeping handle and history
- **Soft-centralized**: PLC is run by Bluesky PBC; protocol allows alternatives
- Use case: ATProto / Bluesky and any consumer-grade decentralized app

### Nostr (`npub` / `nsec`)
- Pure secp256k1 keypair
- No infrastructure required
- **Cannot rotate** — nsec leak = identity compromised forever
- Use case: power users, public broadcasting, where simplicity > recovery

## The recovery problem

Every cryptographic identity scheme runs into the same wall: **non-technical users will lose their keys**. They will:

- Not write down the seed phrase
- Lose the phone
- Forget which password manager has the key
- Reset the device thinking it'll restore from iCloud
- Email "I forgot my password" to a help desk that has no power to help

For a Bible-study app where the user might be a 70-year-old pastor with valuable sermon archives, this is not acceptable.

## Recovery options ranked

| Approach | Mechanism | UX | Real-world success |
|----------|-----------|-----|-------------------|
| **Custodial-default + self-custody upgrade** | Hosted account with email recovery; rotation keys for power users | ✅ Email reset works | ATProto/Bluesky — millions of users |
| **Remote signers (bunkers)** | Key in a bunker app; clients request signatures | ⚠️ Setup complexity | Nostr NIP-46 (Amber, nsec.app) — emerging |
| **Social recovery / Shamir splits** | k-of-n trustees reconstruct the key | ⚠️ Trustee coordination | Anytype, some wallets — limited adoption |
| **Pure seed phrase** | 12-24 word backup | ❌ Users lose them | All crypto wallets — fails at consumer scale |
| **No recovery (`did:key`)** | Lose key = identity dead | ❌ Unacceptable for users with data | Used only for ephemeral cases |

The only approach that works at consumer scale is custodial-default. ATProto's `did:plc` is the cleanest implementation in 2026.

## Recommended model

### Default: custodial PDS / sync server

User signs up with email + password. Project (or partner) runs a free PDS:

- Email-based password reset
- 2FA optional
- Account-level encryption-at-rest
- Backup managed by the host

99% of users live here forever. **This is fine.**

### Upgrade path 1: rotation keys (self-custody upgrade)

Power user adds a rotation key (stored in a hardware token, password manager, or printed-and-locked-in-a-safe):

- Rotation key signs `did:plc` updates
- If account is compromised, user can rotate signing keys
- If hosted PDS goes evil, user can change PDS without losing identity
- This is the "credible exit" mechanism

User now has **explicit cryptographic sovereignty** over their identity. Project still hosts data; user controls identity.

### Upgrade path 2: self-host PDS

Truly committed user runs their own PDS:

- All data on their server
- Project's services interoperate via ATProto
- User pays nothing to project; pays only their own hosting

This is rare (probably <1%) but the path must be real and documented.

### Optional: Nostr identity (parallel)

For users who want public-broadcast features (shared reading plans, public highlights):

- Nostr keypair separate from ATProto identity
- Used only for public/social features
- nsec on its own is power-user territory; pair with NIP-46 bunker for non-technical users

This is a *plugin*, not the default.

## What NOT to do

### Don't make seed phrases the default
Don't ship a "write down these 24 words" flow to a pastor. They will lose them. They will email you angrily six months later.

### Don't conflate identity and data
Identity is whose account this is. Data is the notes/sermons/highlights. These can have different recovery models:
- Identity → ATProto (recovery via email)
- Data → Yjs document (recovery via any synced device + server backup)

If the user loses the phone but the sync server has their data, they recover via email login.

### Don't require self-host
Self-host is a feature for the 1%. Don't put it in the onboarding flow.

### Don't punish self-host
Self-hosters should get the same UX as hosted users — same plugins work, same sync, same plugin marketplace. The project's hosted service competes on convenience, not features.

## Implementation sketch

```
On signup:
  1. User enters email + password
  2. Project creates did:plc on PLC directory
  3. Project's PDS becomes the user's default home
  4. Project sends email confirmation
  5. User is logged in; can use the app immediately

On "I forgot my password":
  1. Email reset flow at the PDS host (project)
  2. Reset issues new password; account intact
  3. did:plc unchanged

On "I want self-custody":
  1. Settings → Generate rotation key
  2. User saves key to password manager / hardware token
  3. PLC directory updated; user can now sign their own did:plc updates

On "I want self-host":
  1. Settings → Migrate PDS
  2. User points at their PDS URL
  3. ATProto migration flow runs (~24 hours)
  4. Done; project's PDS no longer hosts user data
```

## See Also

- [[decentralized-sync|Decentralized sync]]
- [[credible-exit|Credible exit principle]]
- [[../topics/engineering-playbook|Engineering playbook]]
