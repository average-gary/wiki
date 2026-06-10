---
title: NIP-57 — Lightning Zaps
source: https://github.com/nostr-protocol/nips/blob/master/57.md
type: repo
ingested: 2026-06-09
path: comparison
quality: 5
credibility: high
tags: [zaps, nip-57, kind-9734, kind-9735, lnurl, lightning-address, comparison, trust-model]
---

## Source overview

Canonical NIP-57 specification defining Lightning zaps on Nostr. Defines the dual-event flow: kind 9734 (zap request) created by the sender and kind 9735 (zap receipt) published by the recipient's LNURL server after invoice settlement. Critical reference for CLINK because zaps are the most successful existing Nostr↔Lightning bridge, and CLINK Offers is explicitly designed to subsume their function while removing the trusted-LNURL-server hop.

Quality 5 — official NIP.

## Key findings (comparison axes)

### 1. Trust model — the core weakness CLINK targets
NIP-57's most cited limitation is on-the-record:
> "The zap receipt is not a proof of payment, all it proves is that some nostr user fetched an invoice."

> "There is no real way to prove that the invoice is real or has been paid. You are trusting the author of the zap receipt for the legitimacy of the payment."

This is the *exact* trust hop CLINK Offers is designed to eliminate. Today's zaps require an LNURL server (often a custodian like WoS or Alby) to be honest. CLINK Offers replaces the LNURL server with an end-to-end NIP-44 conversation between sender and recipient pubkey, so the receipt becomes a direct response from the same pubkey that holds funds — not a trusted third party.

### 2. Three-party flow vs two-party
- **NIP-57**: sender → recipient's LNURL server → recipient's wallet → relays → sender's client. Four hops, three trusted parties.
- **CLINK Offers (zap-flavored)**: sender → recipient (Nostr pubkey) → relays → sender. Two hops, two parties — the recipient *is* the wallet operator.

### 3. Discovery
NIP-57 piggybacks on existing LNURL/LN-Address discovery: the recipient publishes `lud06` or `lud16` on their kind 0 metadata. So zaps inherit all of LUD-16's failure modes (DNS dependence, custodial concentration of LN-Addresses).

CLINK Offers replaces the lud06/lud16 metadata field with a `noffer1...` code, breaking the dependence on `.well-known/lnurlp/`.

### 4. Identity binding
NIP-57 has a clever trick: the BOLT11 invoice's description-hash commits to the kind 9734 zap request, which is signed by the sender. This binds the payment to the sender's Nostr identity *cryptographically*, modulo the LNURL server's honesty.

CLINK Offers preserves this property because the sender still creates the zap-request payload; the difference is that the description-hash binding now lives inside an end-to-end-encrypted Nostr request rather than an HTTPS callback.

### 5. Receipt event (9735) trust
Per the spec, anyone receiving a 9735 must verify:
- the receipt's `pubkey` matches the recipient's announced `nostrPubkey`
- the `bolt11` field is present
- the description-hash matches a 9734 in the `description` tag

Even with all checks, the receipt-publisher could lie about settlement. This is the "you are trusting the author" caveat above.

CLINK Offers' optional kind 21001 receipt is from the *same pubkey that issued the invoice*, narrowing the trust to a single party (the recipient/wallet operator).

## Comparison matrix data

| Axis | NIP-57 zaps | CLINK Offers (zap-equiv) |
|---|---|---|
| Sender-side event kind | 9734 (zap request) | 21001 request payload |
| Receipt event kind | 9735 | 21001 response (optional) |
| Discovery field | `lud06` / `lud16` on kind 0 | `noffer1...` on profile/event |
| Trusted parties | sender, recipient, LNURL server, relay | sender, recipient, relay |
| Description-hash binding | Yes (via LNURL callback) | Yes (via Nostr request) |
| Encryption sender→recipient | None (zap request is public) | NIP-44 |
| Receipt = proof of payment? | No (per spec) | Stronger — issued by funds holder |
| Web infra needed | Yes (LNURL server) | No |

## Direct quotes

> "The zap receipt is not a proof of payment, all it proves is that some nostr user fetched an invoice."

> "There is no real way to prove that the invoice is real or has been paid. You are trusting the author of the zap receipt for the legitimacy of the payment."

> NIP-57 flow: "Sender creates and signs a `9734` zap request event, sends it (unsigned) to recipient's callback URL… Recipient's lnurl server validates the request and generates a Lightning invoice with the zap request as description… Upon payment confirmation, the server creates a `9735` zap receipt event"

(Sender-side discovery happens via `lud06`/`lud16` fields on kind 0 metadata — i.e. zaps **require** the recipient to have an LNURL or Lightning Address.)

## Open questions surfaced

- If CLINK Offers replaces lud06/lud16 in kind 0 metadata, what's the migration plan for existing zap clients (Damus, Amethyst, Primal)? Do they detect `noffer1...` and route to 21001, or fall back?
- Does CLINK Offers preserve the public 9734 zap request semantics (publicly-readable "X zapped Y this much for note Z") or does NIP-44 encryption make zaps private by default — and what does that do to social proof / leaderboards?
- Backwards compatibility: can a CLINK-aware wallet still emit a 9735 receipt for clients that only know NIP-57?
- Public zap visibility is part of why zaps work as social signal. Does CLINK push zap-equivalents toward private-tip semantics?

## Why this matters for understanding CLINK's positioning

Zaps are the success story for Nostr↔Lightning UX, *and* they have a candidly documented trust problem. CLINK Offers' design choices line up with surgical removal of that trust hop while preserving zap-style social binding.

But zaps' public visibility is also a feature, not just a bug — leaderboards, "top zaps on this note," etc. CLINK's NIP-44 encryption flips the default to private, which is a real product question, not just a security upgrade. Any CLINK adoption analysis has to grapple with what social-payment UX looks like when receipts are end-to-end encrypted.
