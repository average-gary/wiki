---
title: clink-protocol — theses
type: theses-index
---

# clink-protocol — theses

Testable claims surfaced during this research session. Each is a candidate for a `/wiki:research --mode thesis` follow-up.

## Suggested theses (not yet investigated)

1. **Manage revocation gap is materially worse than NIP-26.** CLINK Manage delegates administrative authority but defines no protocol-level revocation, time-bound, or expiry. NIP-26 — despite being `unrecommended` — at least encodes time-bounds in delegation tokens. A thesis run would steel-man both sides.
2. **A single Nostr-key compromise discloses all past and future CLINK exchanges under that key.** Direct consequence of NIP-44's lack of forward secrecy + lack of post-compromise security + CLINK's lack of a key-rotation primitive. A thesis run would survey existing key-rotation NIP proposals and any in-flight CLINK rotation work.
3. **CLINK Offers' privacy is materially better than LNURL but materially worse than BOLT12 for the recipient.** Three-way comparison; BOLT12 blinded paths hide the recipient node identity, CLINK does not.
4. **CLINK's `name@host` discovery dependency on HTTPS materially weakens its "Nostr-native" privacy claim.** Verdict question: does NymRank close the gap?
5. **CLINK and NWC are complementary, not competing, in deployed reality.** Despite the README's pointed framing, the ecosystems serve different shapes (RPC vs authorization) and likely persist together.
