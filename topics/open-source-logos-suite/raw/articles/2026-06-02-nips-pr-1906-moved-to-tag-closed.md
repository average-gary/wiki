---
title: "PR #1906 — NIP-24 'moved_to' tag (closed, half-measure rejected)"
url: https://github.com/nostr-protocol/nips/pull/1906
retrieved: 2026-06-02
type: pr
---

Closed PR (closed 2025-05-07) that proposed adding a `moved_to` tag to NIP-24 metadata events so users could signal a migration to a new pubkey, letting clients update follower lists. It was deliberately the simplest possible migration design.

Rejected on the explicit grounds that it is a half-measure. Reviewer staab argued that "half-measures only make things worse": an attacker who steals an nsec can publish a `moved_to` tag pointing at their own pubkey, and the legitimate user has no way to undo the signal. The community reached rough consensus that any acceptable rotation NIP must include either cryptographic proof of new-key ownership tied to the old key, OR a robust web-of-trust attestation flow — a simple tag is not enough. The PR explicitly references prior failed attempts (#829, #1737) and points future work toward more comprehensive specs (#1056, #1452, eventually #2137). Useful as a primary-source confirmation that the Nostr maintainers know the gap exists and have rejected the obvious naive fix.
