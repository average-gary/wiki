---
title: CLINK Manage Specification (clink-manage.md)
source: https://raw.githubusercontent.com/shocknet/clink/main/specs/clink-manage.md
type: article
ingested: 2026-06-09
path: security
quality: 5
credibility: high
tags: [clink, security, nostr, manage, nmanage, delegation, nip-26, revocation, threat-model]
---

## Source overview

`clink-manage.md` defines the CLINK Manage primitive — `nmanage1...` pointers that let an application create, update, list, get, and delete offer resources on a user's wallet server. Manage is the *delegated administration* primitive: the app does not move money, but it does shape the user's payment endpoints. Compare against NIP-26 (Nostr's existing "delegated event signing" standard, which is itself flagged `unrecommended`).

## Key findings

- **Permissions are scoped per-app and per-resource.** "Apps should not be able to modify or delete offers they did not create, unless explicitly permitted." Wallet servers MUST track which app created which offer. This is a stronger isolation model than NIP-26, which is just a signing-key delegation with kind/time conditions and no resource scoping.
- **NIP-44 mandatory; replay protection via 30s `created_at` delta** (same posture as Debits). "wallet servers MUST enforce a maximum time delta between the server's clock and the event's `created_at` timestamp."
- **All requests are signed and auditable.** "All requests are signed and auditable" is stated as a security property. This means the wallet server has a signed log of which app made which change, useful for forensics.
- **Critical gap: revocation model is not specified.** The spec contains no mechanism to revoke an app's permission, no time-bound on a delegation, no expiration window, no explicit revoke event. The implicit model is that the wallet server administers permissions out-of-band, but the protocol itself is silent.
- **NIP-26 comparison is absent from the spec.** Manage chooses a fundamentally different delegation model from NIP-26 (resource-scoped at the wallet server vs. signing-key delegation with conditions in event tags) but does not justify the choice or analyze the tradeoff.
- **Custody is out of scope.** Manage doesn't touch funds — it touches offer metadata. But because offer metadata can include payment routing/destinations, a malicious app with Manage permission could plausibly redirect future payments by editing or replacing offers. The spec's "apps cannot modify offers they did not create" guard is the only stated mitigation.

## Threat model components

| Asset | Threat | Mitigation in spec |
|---|---|---|
| Offer resource integrity | App modifies/deletes another app's offer | Wallet server MUST track creator pubkey and reject cross-app modification |
| Replay of admin operations | Replayed `delete` or `update` event | 30s `created_at` delta + signed events |
| Confidentiality of admin payload | Eavesdropping on operations | NIP-44 encryption between app and wallet server |
| Auditability | Disputed change history | Signed events provide a log |
| Compromised app key | Attacker uses app key to manipulate offers | **Not addressed in spec** — no revocation primitive |
| Permission scope creep | App granted broad permissions persists indefinitely | **Not addressed** — no time-bound, no expiry |

## Direct quotes

1. "All requests are signed and auditable."
2. "Apps should not be able to modify or delete offers they did not create, unless explicitly permitted."
3. "The wallet server MUST track which app created each offer and MUST reject modification or deletion requests from other apps."
4. "Content: NIP-44 encrypted JSON payload."
5. "wallet servers MUST enforce a maximum time delta between the server's clock and the event's `created_at` timestamp" (>30s rejected as GFY code 3 Expired Request).

## Open questions

- **The biggest single security gap in CLINK as a whole**: Manage delegates administrative authority but gives no protocol-level revocation, no expiry, no time-bound. NIP-26 — which CLINK does not adopt — at least has time conditions in delegation tokens. CLINK Manage has even less.
- **Why didn't CLINK adopt NIP-26?** The spec doesn't say. Possibilities: NIP-26 is `unrecommended` in the NIP repo; resource-scoped delegation at the wallet-server layer is a better fit for the actual ops; CLINK didn't want to depend on a draft spec. None of this is in the spec text.
- **Compromised app key recovery story is undefined.** If an app's key is stolen, every wallet server the user has authorized that app at must individually de-list the key. There's no broadcast revocation, no kid-list, no "this key is dead" event.
- **Content tampering vs offer-replacement is a real attack.** A malicious app with Manage permission cannot edit offers it didn't create — but can it create *new* offers that shadow another app's offers in some UX? Not explicitly addressed.
- **Wallet-server compromise is the failure mode never analyzed.** The wallet server is the trust anchor for the entire delegation model. If it is breached, all offers and Manage permissions across all the user's apps fall.

## Why this matters

Manage is where the gap between CLINK's marketing ("self-custodial", "Nostr-native security") and the spec is widest. Delegation without revocation is the security pattern that has historically caused the most pain in OAuth-style ecosystems, and CLINK has chosen a delegation model that doesn't even match what Nostr's own NIP-26 offers. This is the clearest security thesis target on the whole protocol: **what should CLINK Manage's revocation model look like, and why was the question deferred?**
