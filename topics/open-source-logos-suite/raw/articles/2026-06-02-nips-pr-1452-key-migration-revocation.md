---
title: "PR #1452 — Key Migration and Revocation (open, stalled)"
url: https://github.com/nostr-protocol/nips/pull/1452
retrieved: 2026-06-02
type: pr
---

Open PR by braydonf, opened 2024-08-28, still unmerged as of 2026-06-02 (40+ comments). Combined elements from earlier proposals #829, #637, and #1056 into a single specification that handled both revocation and migration, plus preservation of associated NIP-05 / metadata identifiers. Mechanisms include automatic relay/client rejection of events from revoked keys and identity recovery via attestations from trusted contacts.

It stalled on two issues common to all Nostr rotation proposals: (1) "data retention guarantees" — relays are not required to keep recovery attestation events long enough to be useful; (2) social-verification ambiguity — when an attacker forges a fraudulent recovery key first, users have no canonical way to tell which one is real. Author later announced the proposal would be split: revocation pushed into #1056, migration/metadata into separate NIPs. As of 2026-06 the split has not happened and the original PR remains open without a clear path forward.
