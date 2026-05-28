---
title: "AT Protocol: Personal Data Repositories & Account Migration"
source_url: "https://atproto.com/guides/data-repos"
type: article
path: infra-sync
date_ingested: 2026-05-27
date_published: 2024-01-01
tags: [decentralized, identity, sync, did, atproto, pds, recovery]
quality: 5
confidence: high
summary: "ATProto stores user data in signed Merkle Search Tree repos addressed by a DID, with a documented account migration / recovery path between PDS hosts."
---

# AT Protocol: Personal Data Repositories & Account Migration

## Key findings

- **Identity model**: Each user is a DID (typically `did:plc`, also `did:web`). DID resolves to a keypair that signs the user's repo commits.
- **Data model**: A Personal Data Server (PDS) hosts a Merkle Search Tree repo: signed commit -> tree nodes -> records. Records use NSIDs (collection types) and rkeys (often TIDs, timestamp-based).
- **Sync**: Repo is content-addressed (CIDs); other servers / clients pull the signed CAR file and verify against the DID's signing key.
- **Recovery / migration**: 4-stage process — create account on new PDS via service-auth JWT signed by current key, export repo as CAR + reupload blobs, update DID document (PLC operation signed by old PDS for `did:plc`, or self-signed for `did:web`), activate new + deactivate old.
- **Key custody**: `did:plc` accounts are PDS-managed by default (rotation keys held by host) — users CAN add self-custody rotation keys. `did:web` is fully self-controlled.
- **Recovery window**: Old PDS can assist with PLC recovery for ~72 hours after deletion.

## Notable quotes / specifics

- "DIDs are a reference to a data repository."
- "For did:plc accounts managed by the old PDS, an additional security token (typically emailed) authorizes the identity change."
- Self-controlled rotation keys "recommended for users who can securely manage cryptographic keypairs" — implicit acknowledgment most users won't.

## Source notes

Strong. ATProto is the most production-proven option (Bluesky has millions of users) AND the only one with a documented PDS-to-PDS migration story. The default UX is "PDS is your identity custodian" which works for non-technical users but reintroduces a trusted host. Self-hosting a PDS is feasible but operationally heavy for a Bible-app user.
