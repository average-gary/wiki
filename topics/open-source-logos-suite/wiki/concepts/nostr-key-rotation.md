---
title: "Nostr key-rotation: 2026 state of the art"
type: concept
created: 2026-06-02
updated: 2026-06-02
verified: 2026-06-02
volatility: warm
confidence: high
sources:
  - raw/articles/2026-06-02-nip-26-delegated-event-signing.md
  - raw/articles/2026-06-02-nip-06-mnemonic-key-derivation.md
  - raw/articles/2026-06-02-nips-readme-unrecommended-list.md
  - raw/articles/2026-06-02-nips-pr-2137-key-migration.md
  - raw/articles/2026-06-02-nips-pr-2114-d8-key-rotation.md
  - raw/articles/2026-06-02-nips-pr-1056-key-revocation.md
  - raw/articles/2026-06-02-nips-pr-1452-key-migration-revocation.md
  - raw/articles/2026-06-02-nips-pr-1906-moved-to-tag-closed.md
  - raw/articles/2026-06-02-nip-46-remote-signing.md
  - raw/articles/2026-06-02-did-plc-spec-rotation-keys.md
  - raw/articles/2026-06-02-atproto-account-migration-guide.md
  - raw/articles/2026-06-02-nostr-how-key-safety-guidance.md
---

# Nostr key-rotation: 2026 state of the art

## TL;DR

As of 2026-06-02, Nostr has **no merged protocol primitive for key rotation, revocation, or compromise recovery**. The two NIPs that historically gestured at the problem — NIP-06 (mnemonic seed derivation) and NIP-26 (delegated event signing) — are both explicitly flagged "unrecommended" in the canonical NIPs repo. Multiple proposals (#1056, #1452, #2114, #2137, #2237) have been open for one to two years without consensus, all blocked on the same structural problem: Nostr has no consistent source of truth, so any rotation scheme is vulnerable to an attacker who holds the leaked nsec selectively broadcasting forged migrations. By contrast, ATProto's `did:plc` ships a working priority-ordered rotation-key system with a 72-hour recovery window. The assess report's claim that Nostr key-rotation is a real, unsolved gap **holds**; christ-is-lord must document the threat model and ship a narrow social-layer migration convention rather than wait for a protocol fix.

## Evidence

### NIP-26 and NIP-06 are still officially discouraged

The canonical [`nostr-protocol/nips`](https://github.com/nostr-protocol/nips) repository's README maintains an explicit "unrecommended" section that, as of 2026-06-02, still lists both NIP-26 and NIP-06 (see [[../../raw/articles/2026-06-02-nips-readme-unrecommended-list.md|NIPs README index]]). The flags read verbatim:

- NIP-26 — `"unrecommended": adds unnecessary burden for little gain` ([[../../raw/articles/2026-06-02-nip-26-delegated-event-signing.md|NIP-26 spec]])
- NIP-06 — `"unrecommended": prefer a single nsec` ([[../../raw/articles/2026-06-02-nip-06-mnemonic-key-derivation.md|NIP-06 spec]])

The discouragement is not stylistic. NIP-26's delegation tag was the obvious "use a hot key authorized by a cold root key" design, and the community concluded over multiple years that it forces relays and clients into delegation lookups for every new pubkey, makes reliable relays a hard requirement, and still doesn't solve compromise recovery. NIP-06's mnemonic derivation was deprecated because it gave users false Bitcoin-wallet-style intuitions about recovery without any actual recovery semantics on Nostr.

### No merged rotation NIP; multiple proposals stuck

Fetching `https://github.com/nostr-protocol/nips/blob/master/41.md` returns 404 — there is no NIP-41 "key revocation" merged into the spec, despite informal references in old discussions. The actual state of in-flight work:

- **PR #2137 — "Key migration"** by staab, opened 2025-11-25, open with 33+ comments. Defines kind:360 (precommit timestamped via OpenTimestamps), kind:361 (migration signed by an intermediate single-use migration key), and kind:362 (encrypted recovery shards via NIP-59). Reviewers flag that it requires a "central group of trusted relays" to retain precommit events, and explicitly drops historical messages and mentions ([[../../raw/articles/2026-06-02-nips-pr-2137-key-migration.md|PR #2137 summary]]).
- **PR #2114 — "NIP D8 Key Rotation"** by staab, closed 2025-12-20 in favor of #2137. fiatjaf rejected it as inheriting NIP-26's flaws; vitorpamplona called it too complex; the author conceded that "any key rotation scheme on nostr is going to come with some hefty assumptions" ([[../../raw/articles/2026-06-02-nips-pr-2114-d8-key-rotation.md|PR #2114]]).
- **PR #1056 — "Key Revocation"** by vitorpamplona, draft since 2024-02-16. Pure web-of-trust approach using kind:18; blocked on the core attack of an attacker selectively broadcasting forged migrations to relays the legitimate user does not read ([[../../raw/articles/2026-06-02-nips-pr-1056-key-revocation.md|PR #1056]]).
- **PR #1452 — "Key Migration and Revocation"** by braydonf, open since 2024-08-28, stalled on relay data-retention guarantees and social-verification ambiguity ([[../../raw/articles/2026-06-02-nips-pr-1452-key-migration-revocation.md|PR #1452]]).
- **PR #1906 — `moved_to` tag**, closed 2025-05-07. Rejected explicitly because "half-measures only make things worse": an attacker with the nsec can publish their own `moved_to` ([[../../raw/articles/2026-06-02-nips-pr-1906-moved-to-tag-closed.md|PR #1906]]).
- **Issue #2237 — "Key Commitment and Theft-Proof Rotation"**, closed as not planned 2026-02. Used argon2id-hashed memorized secrets as a commitment; closed without a successor.

The pattern is consistent: every two years a new design appears, runs into the absence of a consistent Nostr-wide source of truth, and either gets closed or stalls.

### NIP-46 is the strongest deployed mitigation, but is not rotation

[NIP-46 remote signing / "bunkers"](https://github.com/nostr-protocol/nips/blob/master/46.md) (Amber on Android, nsec.app, hardware-backed signers) is the strongest defense Nostr ships in 2026 ([[../../raw/articles/2026-06-02-nip-46-remote-signing.md|NIP-46 spec]]). It explicitly aims to keep nsec out of clients. But the spec is a *prevention* mechanism — if the bunker leaks or the user backs up insecurely, the underlying secp256k1 key is still un-rotatable. Nostr clients (Damus, Amethyst, Primal) increasingly support NIP-46; none of them ships a rotation UX, and the official end-user guide at nostr.how flatly states private keys "cannot be reset if lost" ([[../../raw/articles/2026-06-02-nostr-how-key-safety-guidance.md|nostr.how key safety]]).

### Contrast: did:plc actually solves this

ATProto's `did:plc` method specifies 1–5 priority-ordered rotation keys per identity, NOT included in the public DID document, with a 72-hour recovery window during which a higher-authority rotation key can rewrite history and invalidate operations signed by a compromised lower-authority key ([[../../raw/articles/2026-06-02-did-plc-spec-rotation-keys.md|did:plc spec]]). The deployed migration flow is documented in the [ATProto account-migration guide](https://atproto.com/guides/account-migration), runs in production for millions of Bluesky accounts, and is referenced in this wiki at [[identity-and-recovery|identity-and-recovery]] as the recommended consumer-grade primitive ([[../../raw/articles/2026-06-02-atproto-account-migration-guide.md|ATProto migration guide]]). The contrast is structural, not aesthetic: did:plc has a directory; Nostr deliberately does not.

## Implications for christ-is-lord

1. **The assess gap is real and current.** The 2026-06-02 assess report's flag that "Nostr key-rotation is a real, unsolved gap" holds. As of 2026-06-02 there is no merged NIP for rotation, no consensus on which open PR will land, and the deployed clients (Damus, Amethyst, Primal) do not implement migration UX. christ-is-lord cannot ship Nostr-rooted identity assuming this will be fixed upstream on any timeline.

2. **Add `docs/security/threat-model.md` documenting the asymmetry.** The threat model must state plainly that christ-is-lord uses Nostr keys (NIP-22242 + NIP-07) for *signing public artefacts* (manifests, capability requests) and NOT as the recovery anchor for user data. The Yjs/Hocuspocus document store and the Iroh-blobs library distribution layer must each be recoverable without the user's nsec — by re-fetching from the sync server or re-resolving via R2 fallback respectively. Document the failure modes: leaked nsec means an attacker can sign artefacts as the user until the user manually announces a new pubkey via the social-layer convention below.

3. **Do NOT lean on NIP-26 for any internal feature.** The repo flag is unambiguous; relying on delegation for plugin signing, multi-device signing, or a "hot key authorized by a cold key" pattern would put christ-is-lord on the wrong side of community consensus and would not survive a future audit. If multi-device signing is needed, prefer NIP-46 bunker patterns or a christ-is-lord-internal capability token signed once per device — never NIP-26 delegation tags.

4. **Ship a narrow social-layer migration convention.** In the absence of a protocol primitive, define and document one specific behavior: when a user rotates, christ-is-lord publishes a kind:0 (metadata) event from the *old* nsec announcing the new pubkey via a `migrated_to` tag, simultaneously publishes a kind:0 from the *new* nsec with a `migrated_from` tag pointing back, and the desktop / mobile clients render a yellow "this account moved" badge when both events are present and signed by the expected keys. This is explicitly weaker than PR #2137 — it does not survive the case where the attacker holds the nsec — but it covers the routine case (lost device, voluntary rotation) and gives a clear migration path the moment a real NIP lands. Document its limits in the threat model.

5. **Make NIP-46 the recommended hot path and design for it.** The strongest 2026 mitigation is keeping nsec out of christ-is-lord clients entirely. The Tauri 2 desktop should treat NIP-07 (browser extension) and NIP-46 (bunker) as the primary signing flows; the SwiftUI / Jetpack Compose mobile shells should integrate Amber on Android and the equivalent iOS bunker apps. Direct nsec entry should be available but discouraged in onboarding, mirroring the ATProto pattern of "custodial-default with explicit graduation to self-custody" already documented in [[identity-and-recovery|identity-and-recovery]].

6. **Track PR #2137 explicitly in the wiki refresh queue.** Of all the in-flight proposals, #2137 is the one with momentum (33+ comments, replaced #2114, has working code sketches). Add it to the librarian's refresh list with a 90-day cadence; if it merges, the social-layer convention from implication #4 should be revisited and either kept as a transition tool or replaced with the canonical events.

## See also

- [[identity-and-recovery|Identity and recovery]] — the broader recovery story; this article is the Nostr-specific deep-dive that the recovery comparison table summarizes.
- [[credible-exit|Credible exit]] — why a working rotation primitive is itself a credible-exit feature.
- [[../topics/open-source-logos-suite/_index|Topic index]] — for surrounding context.
