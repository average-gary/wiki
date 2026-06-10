---
title: BOLT 12 — Offer Encoding for Lightning Payments
source: https://github.com/lightning/bolts/blob/master/12-offer-encoding.md
type: repo
ingested: 2026-06-09
path: comparison
quality: 5
credibility: high
tags: [bolt12, offers, onion-messages, blinded-paths, comparison, lightning-protocol]
---

## Source overview

The canonical BOLT 12 spec in `lightning/bolts`, defining offers (`lno...`), invoice requests, invoices, and the underlying TLV/Merkle/onion-message machinery. BOLT 12 is the "in-protocol" rival to LNURL/CLINK — it solves reusable payment codes natively at the Lightning layer rather than via an out-of-band transport (HTTPS for LNURL, Nostr for CLINK).

Quality 5 — official BOLT.

## Key findings (comparison axes)

### 1. Transport — the central architectural disagreement
- **BOLT 12**: invoice requests travel as **onion messages** through the Lightning network itself. The recipient publishes an offer; the payer's node sends an `invoice_request` over onion-routed messaging; the recipient's node responds with a signed `invoice` over the return path.
- **LNURL**: HTTPS GET to a callback URL.
- **CLINK Offers**: encrypted Nostr events on relays.

Each picks a different transport with different operational characteristics. The CLINK README's complaint that BOLT12 depends on "slow and unreliable onion messages that are impractical for web applications" is a direct critique of this choice — onion messages require the recipient's node to be online and reachable on the LN gossip graph at request time, which is a hard constraint for mobile wallets and SaaS apps.

### 2. Privacy
BOLT 12 has the strongest privacy story of the three:
- **Blinded paths** hide the recipient's node ID from the payer
- **Onion routing** hides the payer's location from the recipient
- The offer itself reveals only an offer-issuer pubkey (which can rotate)

LNURL leaks the recipient's domain (and thus often the recipient's identity) to the payer and TLS transcript watchers. CLINK leaks the recipient's Nostr pubkey + relay URL (still better than LNURL, weaker than BOLT12's blinded paths).

### 3. Identity / trust anchors
- **BOLT 12**: trust anchor is the offer's signing key; no DNS, no CA, no Nostr.
- **LNURL**: web PKI + DNS.
- **CLINK Offers**: Nostr pubkey + at-least-one available relay.

BOLT 12 is the only one of the three that doesn't depend on any naming system *or* any out-of-band overlay network.

### 4. Online-ness requirement
This is where BOLT 12 takes its biggest hit:
- BOLT 12: recipient's LN node must be online and routable to fulfill `invoice_request`.
- LNURL: recipient's LNURL server must be online.
- CLINK: recipient's wallet must be subscribed to the relay; relay must be reachable.

For non-custodial mobile wallets, BOLT 12's "node online" requirement is significantly harder than LNURL's "web server online" or CLINK's "subscribed to a relay" — which is exactly the structural advantage CLINK and LNURL share over BOLT 12 for mobile/web UX.

### 5. Invoice format and TLV/Merkle
BOLT 12 replaces BOLT 11's bech32 with TLV + Merkle-tree commitments, enabling:
- selective field disclosure
- recoverable amount-in-fiat semantics (ISO 4217 codes)
- forward-compatible parsing ("it's OK to be odd")
- per-user invoices (anti-payment-secret-probing)

CLINK Offers does *not* replace BOLT 11; it carries BOLT 11 invoices inside Nostr events. So CLINK inherits BOLT 11's limitations (no selective disclosure, no Merkle proof of fields, milli-sat precision).

### 6. Recurring payments / subscription
BOLT 12 has explicit recurring-offer fields. CLINK Debits is the analog (static authorization for recurring payment requests), but is shaped differently — pull rather than push.

## Comparison matrix data

| Axis | BOLT 12 | LNURL-pay | CLINK Offers |
|---|---|---|---|
| Layer | Lightning protocol | Application layer (HTTP) | Application layer (Nostr) |
| Static code | `lno1...` offer | `lnurl1...` | `noffer1...` |
| Transport | Onion messages | HTTPS | Nostr relays + NIP-44 |
| Recipient must be online | Yes (LN node) | Yes (web server) | Yes (relay sub) |
| Trust anchor | Offer signing key | TLS / DNS | Nostr pubkey |
| Privacy: hides recipient | Strong (blinded paths) | None | Partial (relay sees pubkey) |
| Privacy: hides payer | Strong (onion route) | TLS only | NIP-44 ciphertext |
| Invoice format | TLV / Merkle | BOLT 11 | BOLT 11 |
| Mobile/web friendly | Weak | Strong | Strong |
| Custody-pressure | Low | High (drives custodial LN-Addresses) | Low |
| Standardization | IETF/BOLT | LNURL/LUD | informal (clinkme.dev) |

## Direct quotes

> "An offer is much longer-lived than a particular `invoice_request`."

> "if `offer_paths` is set: MUST send the onion message via any path in `offer_paths` to the final `blinded_node_id` in that path."

> BOLT 12 resolves eight key BOLT 11 weaknesses: encoding flexibility (TLV), selective disclosure (Merkle), backward compatibility, satoshi-based amounts, blinded paths replacing limited probing prevention, per-user invoices preventing dangerous multi-attempt scenarios.

(From CLINK Offers spec, the implicit BOLT 12 critique:)
> "Current Lightning payment flows either require maintaining HTTP endpoints…or depend on slow and unreliable P2P transport mechanisms"

## Open questions surfaced

- Could CLINK Offers carry BOLT 12 invoices instead of BOLT 11, getting selective disclosure + Merkle commitments + the 9-step BOLT 11 fixes "for free"? Why hasn't the spec gone there?
- BOLT 12 is being rolled out gradually (CLN, LDK shipping; LND lagging). What's the practical 2026 baseline of LN nodes that can respond to `invoice_request`?
- How does CLINK's "recipient must be subscribed to a relay" requirement compare empirically to BOLT 12's "node must be reachable on LN" — which fails more often, for which user populations?
- BOLT 12 blinded paths are a much stronger privacy story than NIP-44. Does CLINK Offers have a path to closing this gap (e.g. blinded relay paths, mixnets)?

## Why this matters for understanding CLINK's positioning

BOLT 12 is the "in-protocol purist" rival, and it is the protocol CLINK most loudly avoids naming directly while critiquing. Understanding the trade is essential:

- **BOLT 12 wins** on cleanliness (no overlay), privacy (blinded paths), trust anchors (no DNS/Nostr), and richness of invoice format (TLV/Merkle).
- **CLINK wins** on mobile/web friendliness, integration with existing Nostr identity & messaging, removal of the "node must be online" constraint via persistent relay subscription, and ability to leverage the already-deployed Nostr social graph for identity.
- **LNURL loses on both axes** — it's neither in-protocol clean nor identity-native — but has won deployed-base because it ships in any web stack.

CLINK's bet is that the Nostr substrate is "good enough" to subsume LNURL's deployed-base advantage while not paying BOLT 12's online-ness tax. Whether that bet holds is a real empirical question about how reliable Nostr relay infrastructure is in 2026.
