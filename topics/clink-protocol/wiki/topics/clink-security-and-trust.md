---
title: CLINK security and trust model
type: topic
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-security-clink-debits-spec.md
  - raw/articles/2026-06-09-security-clink-offers-spec.md
  - raw/articles/2026-06-09-security-clink-manage-spec.md
  - raw/articles/2026-06-09-security-nip44-encryption-foundation.md
---

# CLINK security and trust model

CLINK gets the foundational crypto right: NIP-44 mandatory across all primitives, signed Nostr events for authentication, single-use `k1` for sessions, 30-second timestamp deltas for replay protection on Debits and Manage. **The gaps live above the crypto layer**: revocation, key rotation, and node-service-compromise response.

## Threat model in three rows

| Asset | Mitigated | Not mitigated |
|-------|-----------|---------------|
| **Channel confidentiality** | NIP-44 (Cure53-audited Dec 2023). End-to-end to service pubkey. | Quantum adversaries; metadata leakage to relays (timing, `created_at`, approximate size). |
| **Authentication** | Schnorr-signed Nostr events bind requests to sender pubkey. | Key rotation / recovery (none defined at NIP or CLINK layer). |
| **Authorization** | Per-pointer rules; budgets; per-app pubkey scoping; "MUST verify invoice amount." | Revocation (no on-protocol primitive in any CLINK spec); cross-app collusion; node-service compromise. |

## What's solid

### NIP-44 inheritance (the channel itself)

NIP-44 v2: secp256k1 ECDH → HKDF (salt `'nip44-v2'`) → ChaCha20 + HMAC-SHA256 + custom padding scheme. Outer Schnorr signature on the Nostr event. **Cure53-audited December 2023** — the only Nostr cryptographic primitive with a published professional audit, and CLINK uses it for everything.

ChaCha20 over AES "because it's faster and has better security against multi-key attacks." HMAC-SHA256 over Poly1305 "because polynomial MACs are much easier to forge." NIP-04 is deprecated; CLINK ships only NIP-44 from day one — no legacy attack surface.

### Replay protection

- **Debits**: 30-second `created_at` delta (SHOULD) + single-use `k1` (SHOULD).
- **Manage**: 30-second delta (MUST — stricter than Debits).
- **Offers**: implicit via `["e", request_event_id]` binding + Nostr's signed-event uniqueness; no specified delta.

### Per-pointer / per-app scoping

Manage explicitly: "wallet servers MUST track which app created each offer and MUST reject modification or deletion requests from other apps." This is a stronger isolation model than NIP-26's signing-key delegation.

### Amount-inflation guard

Debits spec: "node service MAY require `amount_sats` even for direct payments… MUST verify the invoice amount upon payment." Blocks a malicious service from crafting a different bolt11 than the user expected.

### Atomicity on budget ops

Debits spec: "Node services should ensure payment processing and budget deduction are atomic to prevent race conditions or overspending." Unusual to see in a spec body — reflects awareness that budget pointers are exactly where double-spend bugs land.

### Privacy primitives (Offers)

- Ephemeral payer keys recommended — payers MAY use a fresh keypair per request to break payment-graph linkability.
- NIP-59 gift-wrap suggested as opt-in for hiding request/response association from any single relay.

## Where the spec is silent or weak

### 1. Manage revocation gap (the biggest single hole)

CLINK Manage delegates administrative authority over wallet resources but defines **no protocol-level revocation**:
- No `revoke` event.
- No time-bound on a delegation.
- No expiration window.
- No NIP-26 adoption (and no justification for the rejection).

The implicit model is that the wallet server administers permissions out-of-band. This is the security pattern that has historically caused the most pain in OAuth-style ecosystems. CLINK Manage has even less than NIP-26, which at least encodes a time-bound in its delegation token.

**Thesis target**: what should CLINK Manage's revocation model look like, and why was the question deferred?

### 2. Key rotation / compromise blast radius

NIP-44 has six explicitly enumerated non-properties — all inherited by CLINK:

1. No deniability (events are signed).
2. **No forward secrecy** — past messages decryptable on key compromise.
3. **No post-compromise security** — future messages decryptable on key compromise.
4. No post-quantum security.
5. IP address leak to relays.
6. `created_at` date leak.

Combined: **a single Nostr-key compromise reveals all past and future CLINK exchanges under that key.** Nostr has no canonical key-rotation NIP. CLINK has no rotation primitive of its own. The CLINK Offers spec contains an `noffer1...` string with the recipient's pubkey embedded — printed QRs and stickers become **dangling** on rotation.

This is the **second-biggest open security question** in CLINK.

### 3. Persistent / unrestricted Debits (highest-risk shape, lightest spec text)

From clink-debits.md:
> "request with no `bolt11`, no `amount_sats`, and no `frequency` is implicitly a request for unrestricted access."

The implicit/unrestricted shape:
- Has the highest blast radius.
- Has no required UX warnings.
- Has no required expiry.
- Has no required spend-velocity caps beyond what the node service implements.

Compare to NWC's per-app secret + budget + method allowlist, which at least has structured budget semantics enforced by the wallet daemon.

### 4. Recipient-side privacy (vs BOLT12)

CLINK Offers hides the **payer** (NIP-44 + ephemeral keys). It does not hide the **recipient** — the recipient's Nostr pubkey is in plain bech32 inside the noffer string, and the relay sees the recipient pubkey on every interaction.

BOLT12 blinded paths additionally hide the recipient *node*. Marketing that frames CLINK as "more private than LNURL" is correct (it is); marketing that implies parity with BOLT12 privacy is overclaiming.

### 5. Node-service compromise response

The spec does not analyze what happens if the node service is breached. All authorizations under that service become spendable by the attacker until the user revokes (out-of-band). This is the implicit trust the entire architecture rests on, and it is explicitly out of scope.

### 6. NIP-05 / HTTPS bootstrap caveat

CLINK's "Nostr-native" framing has a discovery-layer caveat: human-readable lookups still require HTTPS+DNS+CAs. Issue [#6](https://github.com/shocknet/CLINK/issues/6) (Namecoin/ElectrumX) explicitly proposes removing that dependency. ShockNet's [NymRank](https://github.com/shocknet/NymRank) is a more likely in-house answer. Today, the bootstrap step inherits LNURL's trust root. See [[../concepts/clink-discovery-and-nip05.md]].

### 7. The 30-second window is a SHOULD, not a MUST (Debits)

Implementations diverging on the delta create interop holes a malicious app could probe.

### 8. Cross-app collusion

Two apps the user has authorized could coordinate timing to drain a shared budget if budgets aren't scoped per-app pubkey (which is only a SHOULD).

### 9. No CLINK-specific cryptographic audit

The Cure53 audit covered NIP-44 v2 generically. **No public evidence of a CLINK-specific audit** was found by research. Spec correctness is one thing; correct implementation by ShockNet's apps and any third-party CLINK clients is another. ClinkSDK has been observed to ship with packaging issues (Stacker News opened an upstream PR for `rimraf` packaging in 2026-05-27) — quality posture is "actively maintained" rather than "audited."

### 10. No security disclosure address

clinkme.dev/contact.html lists a Nostr npub, Telegram group, X handle, GitHub Discussions — but no `security@` address or coordinated disclosure policy. Compare to BOLT12 / LDK which have explicit security contact protocols.

## Privacy delta vs LNURL — the honest version

LNURL-pay leaks:
- Recipient domain (DNS, TLS SNI).
- Payer IP to the LNURL server.
- Full request to the LNURL server (which is often a custodian).

CLINK Offers leaks:
- Recipient Nostr pubkey + relay URL (publicly).
- Payer Nostr key (mitigatable via ephemeral keys per request).
- Approximate request/response size (NIP-44 padding is power-of-two with 32-byte minimum).
- Request/response timing to relays.

**Net**: CLINK Offers is materially more private than LNURL for the *payer*, and breaks the LNURL-server's read-everything position. It is not as private as BOLT12 onion routing for the *recipient*.

## Direct quotes

> "All `content` payloads MUST use NIP-44 encryption between the requestor and node service." (Debits spec)

> "The wallet server MUST track which app created each offer and MUST reject modification or deletion requests from other apps." (Manage spec)

> "Node services should ensure payment processing and budget deduction are atomic to prevent race conditions or overspending." (Debits spec)

> "When applying this NIP to any use case, it's important to keep in mind your users' threat model and this NIP's limitations. For high-risk situations, users should chat in specialized E2EE messaging software." (NIP-44 spec — applies wholesale to CLINK)

> "No forward secrecy: when a key is compromised, it is possible to decrypt all previous conversations." (NIP-44 spec)

## Suggested theses (for follow-up `/wiki:research --mode thesis` runs)

1. **"CLINK Manage's lack of protocol-level revocation makes it materially worse than NIP-26 for delegated authority."** Strong negative thesis worth steel-manning.
2. **"A single Nostr-key compromise on a CLINK identity discloses every past and future CLINK exchange under that key."** Strong positive thesis based on NIP-44 inheritance.
3. **"CLINK Offers' privacy is materially better than LNURL but materially worse than BOLT12 for the recipient."** Three-way comparison thesis.
4. **"CLINK's `name@host` discovery dependency on HTTPS materially reduces its 'Nostr-native' privacy claim."** Verdict on whether NymRank closes the gap.

## See also

- [[../concepts/clink-overview.md]]
- [[../concepts/clink-offers.md]]
- [[../concepts/clink-debits.md]]
- [[../concepts/clink-manage.md]]
- [[../concepts/clink-discovery-and-nip05.md]]
- [[clink-vs-alternatives.md]]
