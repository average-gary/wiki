---
title: NIP-47 — Nostr Wallet Connect (NWC)
source: https://github.com/nostr-protocol/nips/blob/master/47.md
type: repo
ingested: 2026-06-09
path: comparison
quality: 5
credibility: high
tags: [nwc, nip-47, nip-44, kind-23194, kind-23195, kind-13194, wallet-rpc, comparison]
---

## Source overview

The canonical NIP-47 specification in `nostr-protocol/nips`. Defines Nostr Wallet Connect: an RPC-style protocol that lets a Nostr application drive a remote Lightning wallet via signed, encrypted Nostr events. Important reference because (a) it's the closest analog to CLINK Debits and (b) the CLINK README explicitly differentiates against NWC as its primary "cousin standard." Quality 5 — official spec.

## Key findings (comparison axes vs CLINK)

### 1. Scope and design intent
NWC is **wallet remote control**, modeled after the JSON-RPC API pioneered by Lightning.Pub. It exposes wallet methods (pay, invoice, balance) over Nostr transport. The CLINK README explicitly names this scope distinction:
> "While NWC also utilizes Nostr for transport, it specifically targets wallet remote control modeled after the RPC pioneered by Lightning.Pub… Where NWC is deferential to LNURL and scoped for a specific task, CLINK is fundamentally committed to Nostr as the foundation for the next generation of decentralized Lightning applications."

CLINK Debits, by contrast, is **interactive payment authorization** — a third party requests a payment, the wallet evaluates rules, and the wallet either authorizes or refuses. Different shape: NWC is "do this for me," CLINK Debits is "may I have this from you?"

### 2. Connection model
- **NWC**: persistent connection bound to a `nostr+walletconnect://` URI containing `(wallet_pubkey, relay, secret)`. Pre-shared secret per app. Per-app keypairs allow revocation and budgets.
- **CLINK Debits**: `ndebit1...` static authorization pointer. Stateless, ephemeral kind 21002 events. No pre-shared secret per session — auth is a Nostr signature plus user-defined rules.

This is the structural difference behind CLINK's complaint about "pre-shared secrets" in the README. NWC's per-app secret in the connection URI **is** the pre-shared secret CLINK is critiquing.

### 3. Methods exposed
NWC method surface (from the spec):
- `pay_invoice`, `pay_keysend`, `multi_pay_invoice`, `multi_pay_keysend`
- `make_invoice`, `lookup_invoice`, `list_transactions`
- `get_balance`, `get_info`
- `make_hold_invoice`, `settle_hold_invoice`, `cancel_hold_invoice`

CLINK Debits has effectively one operation: "request that the wallet pay this invoice on my behalf, here's why." The narrower surface is itself an opinion — fewer commands, fewer ways to abuse a leaked secret.

### 4. Event kinds
- 13194: replaceable info event (wallet capabilities + supported encryptions)
- 23194: client request (encrypted)
- 23195: wallet response (encrypted)
- 23196 / 23197: notifications (NIP-04 / NIP-44)

These are in the *replaceable* and *regular* ranges. CLINK uses ephemeral 21001/21002/21003 — stronger non-retention guarantee from honest relays.

### 5. Encryption migration
NWC initially used NIP-04, now mandates NIP-44:
> "The initial version of NWC used NIP-04 for encryption which has been deprecated and replaced by NIP-44. NIP-44 should always be preferred for encryption."

CLINK ships NIP-44 from day one — no legacy NIP-04 surface.

### 6. Trust / custody
NWC is fundamentally a custody model where the wallet runs on someone's infrastructure (often Alby Hub, MutinyNet, or the user's own node) and the app is a "remote" against it. It does not by itself solve self-hosting; it just provides a uniform RPC over Nostr.

CLINK Debits + Offers + Manage is positioned as the substrate for a fully Nostr-native wallet ↔ app relationship where the *wallet doesn't have to expose any HTTP surface at all*.

## Comparison matrix data

| Axis | NWC (NIP-47) | CLINK Debits (kind 21002) |
|---|---|---|
| Shape | RPC (commands) | Authorization request |
| Connection | Persistent URI w/ shared secret | Stateless ephemeral events |
| Pre-shared secret | Yes (per app) | No |
| Event kinds | 13194 / 23194 / 23195 / 23196-7 | 21002 (ephemeral) |
| Method surface | ~12 methods | 1 (authorize this payment) |
| Encryption | NIP-44 (NIP-04 deprecated) | NIP-44 |
| Caller proves intent how? | Knowing the secret | Signed Nostr event from caller pubkey |
| Wallet's policy | App-budget + method allowlist | Per-pointer rules + optional user prompt |
| Revocation | Rotate connection URI | Invalidate `ndebit` pointer |

## Direct quotes

> "The initial version of NWC used NIP-04 for encryption which has been deprecated and replaced by NIP-44. NIP-44 should always be preferred for encryption."

> "The user can have different keys for different applications. Keys can be revoked and created at will and have arbitrary constraints (eg. budgets)."

> Relays "do not close connections on inactivity to not drop events, and ideally retain the events until they are either consumed or become stale."

(From CLINK README, contextualizing the comparison:)
> "Where NWC is deferential to LNURL and scoped for a specific task, CLINK is fundamentally committed to Nostr as the foundation for the next generation of decentralized Lightning applications."

## Open questions surfaced

- Is CLINK Debits a strict superset of NWC `pay_invoice`, or is there functionality (hold invoices, keysend, multi-pay) only NWC supports?
- NWC supports notifications (kind 23196/23197) for incoming-payment alerts. Does CLINK Manage cover this surface, or is it considered out of scope?
- NWC's per-app secret enables budgets in a stateless way; how does CLINK express budget rules without a connection-bound secret?
- Coexistence: many wallets (Alby, Mutiny, Coinos, ZBD) ship NWC. What's CLINK's adoption story — replace NWC, sit alongside, or wrap NWC?

## Why this matters for understanding CLINK's positioning

NWC is the closest competitor and the protocol CLINK most directly defines itself against. The README's NWC paragraph is the single clearest "what is CLINK *not*" statement: NWC is RPC-shaped wallet remote-control with pre-shared secrets and is "deferential to LNURL." CLINK rejects all three properties — it's identity-shaped, secret-less, and *replaces* (not wraps) LNURL.

Anyone evaluating CLINK adoption needs to know whether the NWC ecosystem (Alby, Mutiny clients, Damus zap delegation) is on the migration path or whether CLINK is asking the world to throw away that integration surface.
