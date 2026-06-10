---
title: CLINK Offers Specification (clink-offers.md)
source: https://raw.githubusercontent.com/shocknet/clink/main/specs/clink-offers.md
type: article
ingested: 2026-06-09
path: security
quality: 5
credibility: high
tags: [clink, security, nostr, offers, noffer, nip-44, nip-05, blinded-paths, privacy, ephemeral-keys]
---

## Source overview

`clink-offers.md` defines the CLINK Offers primitive — a `noffer1...` static payment code that resolves to a recipient via Nostr pubkey rather than a Lightning Address over HTTPS. Event kind is `21001` (ephemeral). This is the primitive most often compared against LNURL-pay and BOLT12: same use case (payment requests), different trust root (Nostr identity vs HTTPS to a random LNURL host).

## Key findings

- **NIP-44 mandatory for all content encryption.** Same posture as Debits — no fallback to NIP-04.
- **Privacy property: payer can use ephemeral keys.** "Payer wallets can use ephemeral keys for requests to avoid linking payments to a primary Nostr identity." This is the core privacy delta vs LNURL — under LNURL the payer's IP is exposed to whatever HTTPS server hosts the LNURL endpoint, and there's no concept of an ephemeral payer identity at the protocol layer. Under Offers the payer identity is a Nostr key, which can be rotated per-payment.
- **NIP-59 gift-wrap is suggested but optional for metadata privacy.** "Consider using gift-wrapped events (NIP-59) for routing requests/responses through additional relays if metadata privacy is a high concern, though this adds complexity." This is the closest analog CLINK has to BOLT12 onion-message route blinding — it hides the request/response association from any single relay, but it is *opt-in* and adds round-trips.
- **NIP-05 advertisement of offers is supported via a `clink_offer` field** in the `.well-known/nostr.json` response, enabling Lightning-Address-style human-readable lookup. This inherits NIP-05's HTTPS+DNS trust root — see the Namecoin issue (#6) for ongoing work to remove that dependency.
- **The recipient is identified solely by Nostr pubkey embedded in the noffer string.** "The 32-byte public key of the receiving service (hex encoded)." There is no certificate, attestation, or proof-of-control mechanism in the spec — trust in the noffer string is trust in the channel through which the noffer was delivered (QR, copy/paste, NIP-05 lookup).
- **Replay protection is implicit via `e`-tag binding** of response to request event id, plus standard Nostr signed-event semantics. The Offers spec does NOT specify a 30s `created_at` delta the way Debits does — this is consistent with Offers being a request/response payment flow rather than an authorized spend.
- **Custody is silent in the spec.** Offers describes invoice generation and payment but says nothing about who controls funds post-settlement.

## Threat model components

| Asset | Threat | Mitigation in spec |
|---|---|---|
| Payer's payment-graph privacy | Linking payments to a Nostr identity | Ephemeral keys per request (recommended) |
| Payer-recipient association metadata | Relay correlation | NIP-59 gift-wrap (optional) |
| Recipient identity authenticity | Spoofed `noffer` string | Reliance on out-of-band delivery; NIP-05 + DNS for human-readable form |
| Recipient relay availability | DoS on listening relay | "Receiving services should be mindful of potential rate-limiting or abuse vectors on their listening relay" |
| Bolt11 invoice integrity | Recipient sends invoice with mismatched amount | Inherited from Lightning — payer wallet is expected to verify |
| Nostr key compromise of recipient | Attacker generates valid `noffer` responses | Not addressed — see Open Questions |

## Direct quotes

1. "Use NIP-44 for all content encryption."
2. "Payer wallets can use ephemeral keys for requests to avoid linking payments to a primary Nostr identity."
3. "Consider using gift-wrapped events (NIP-59) for routing requests/responses through additional relays if metadata privacy is a high concern, though this adds complexity."
4. "Receiving services should be mindful of potential rate-limiting or abuse vectors on their listening relay."
5. NIP-05 advertisement form: `"clink_offer": {"bob": "noffer1..."}`.

## Open questions

- **Recipient key rotation has no protocol expression.** A `noffer1` string contains a pubkey. If the recipient's key is compromised or rotated, every published noffer is now wrong. There's no on-protocol "this pubkey supersedes that pubkey" event. NIP-05 advertisement could re-point on the DNS side, but raw noffer strings printed on stickers/QR codes/invoices remain dangling.
- **NIP-05 trust root is HTTPS+DNS** — the same trust root LNURL relies on. Issue #6 (Namecoin/ElectrumX) explicitly argues this and proposes a non-HTTPS alternative. So the "Nostr-native, HTTPS-free" framing in marketing has a discovery-layer caveat that the spec acknowledges.
- **Ephemeral payer keys are recommended but not required**, and many wallets default to a single primary identity. Without sender-key hygiene the privacy delta vs LNURL collapses.
- **Privacy from the recipient itself is not improved over LNURL.** The recipient sees the paying Nostr key (or ephemeral key) and the Lightning htlc. BOLT12 blinded paths arguably go further by hiding the recipient *node* — Offers does not.
- **No threat-model treatment of relay coercion / tracing.** A relay or relay-set sees the request/response pair. NIP-59 is the answer but is optional.

## Why this matters

Offers is the primitive being directly pitched against LNURL and BOLT12. Its security story has two real wins (Nostr-key trust root replaces TLS-to-random-host; ephemeral payer keys are first-class) and two real gaps (recipient-key rotation, NIP-05/HTTPS dependency for human-readable discovery). The privacy delta vs BOLT12 is more nuanced than the marketing implies: BOLT12 hides the recipient via blinded paths in the Lightning layer, while CLINK Offers hides the *payer* via ephemeral Nostr keys but does not blind the recipient.
