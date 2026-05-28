---
title: "AT Protocol: Account Migration & Recovery"
source_url: "https://atproto.com/guides/account-migration"
type: article
path: infra-sync
date_ingested: 2026-05-27
date_published: 2024-08-01
tags: [decentralized, identity, sync, did, atproto, recovery, key-rotation]
quality: 5
confidence: high
summary: "ATProto's account migration spec defines the only mature, documented PDS-to-PDS portability path among decentralized social protocols, including did:plc rotation-key recovery."
---

# AT Protocol: Account Migration & Recovery

## Key findings

- **4-stage migration**: (1) create deactivated account on new PDS using a service-auth JWT signed with current signing key; (2) export repo as CAR + re-upload blobs + copy app-specific preferences; (3) update DID identity (PLC operation for `did:plc`, direct DNS/well-known for `did:web`); (4) activate new, deactivate old.
- **did:plc vs did:web**:
  - `did:plc` — DID document lives in PLC directory (a centralized but auditable log run by Bluesky PBC). Rotation keys can be PDS-held, user-held, or both. PDS-held = good UX, low sovereignty. User-held = real sovereignty but you can lose it.
  - `did:web` — DID doc served from a domain you control. Self-sovereign but requires you to keep a domain alive; if domain expires the identity dies.
- **Recovery within 72-hour window**: Old PDS can still assist with PLC recovery if account isn't fully deleted. After window, only rotation-key holders can recover.
- **Implication for non-technical users**: The default ATProto UX (Bluesky.social PDS, no self-custody rotation keys) is "trust your PDS"; that's strictly better than centralized SaaS (you can leave) but not crypto-grade self-sovereign.

## Notable quotes / specifics

- "The user proves identity control by obtaining a service auth token (JWT) signed with their current atproto signing key."
- "Self-controlled rotation keys are recommended for users who can securely manage cryptographic keypairs."
- 72-hour window is the practical safety net.

## Source notes

Strongest argument FOR ATProto in a Bible-app context: a graceful spectrum from "we host you" -> "you host yourself" -> "you control rotation keys directly," and migration is a real, working path, not aspirational. Weakness: PLC directory is a soft centralization; pure self-sovereign requires `did:web` + domain ownership.
