---
title: "CLINK vs LNURL / BOLT12 / NWC / Zaps / Lightning Address"
type: topic
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-comparison-clink-offers-spec.md
  - raw/repos/2026-06-09-comparison-nip47-nwc-spec.md
  - raw/repos/2026-06-09-comparison-nip57-zaps-spec.md
  - raw/repos/2026-06-09-comparison-bolt12-offers-spec.md
---

# CLINK vs LNURL / BOLT12 / NWC / Zaps / Lightning Address

CLINK's pitch is best understood as a triple critique: **LNURL is too HTTPS-coupled, BOLT12 is too node-online-coupled, NWC is too pre-shared-secret-coupled.** Nostr-native ephemeral events are the substrate ShockNet bets can subsume LNURL's deployed-base advantage without paying BOLT12's online-ness tax or NWC's connection-secret tax.

This page is the load-bearing comparison reference. For per-primitive specs see [[../concepts/clink-offers.md]], [[../concepts/clink-debits.md]], [[../concepts/clink-manage.md]].

## TL;DR axis-by-axis

| Axis | LNURL-pay | LN-Address | BOLT12 | NWC | NIP-57 zaps | CLINK |
|------|-----------|-----------|--------|-----|------------|-------|
| Layer | App (HTTP) | App (HTTP) | LN protocol | App (Nostr) | App (Nostr+HTTP) | App (Nostr) |
| Static code | `lnurl1...` | `user@host` | `lno1...` | `nostr+walletconnect://` | (uses LN-Addr) | `noffer1...` / `ndebit1...` / `nmanage1...` |
| Identity root | TLS cert / DNS | DNS | Offer signing key | Per-app shared secret | DNS via LN-Addr | Nostr pubkey |
| Transport | HTTPS | HTTPS | Onion messages | Nostr relays | Nostr+HTTP | Nostr relays |
| Recipient must be online | Web server | Web server | LN node (hard) | Wallet daemon | Web server | Relay sub |
| Encryption | TLS (terminates at server) | TLS | LN onion | NIP-44 | None on 9734 | NIP-44 (E2E) |
| Pre-shared secret? | No | No | No | **Yes** (per app) | No | No |
| Hides recipient identity | No | No | **Yes** (blinded paths) | No | No | Partial (relay sees pubkey) |
| Hides payer identity | TLS only | TLS only | **Yes** (onion route) | App-key | No (9734 public) | NIP-44 + ephemeral keys |
| Receipt = proof of payment? | Out of band | Out of band | LN HTLC | NWC response | **No** (per spec) | Stronger (issued by funds-holder) |
| Web infra needed | Yes | Yes | No | No | Yes (LN-Addr) | No |
| Mobile/web friendly | Strong | Strong | Weak | Strong | Strong | Strong |
| Custody pressure | High | High | Low | Medium | High | Low |
| Deployed base (2026) | Huge | Huge | Growing | Large | Huge (Nostr) | Small |
| Standardization | LNURL/LUDs | LUD-16 | IETF/BOLT | NIP repo | NIP repo | informal (clinkme.dev) |

Sourced from CLINK Offers spec, NIP-47, NIP-57, BOLT12, plus the comparison-path agent's analysis.

## CLINK vs LNURL-pay

CLINK Offers self-positions as a **"Nostr-native successor to LNURL-Pay"** (direct quote from the Offers spec). Not "complement" — *replacement*.

The structural critique:
> "Current Lightning payment flows either require maintaining HTTP endpoints, leading to unnecessary complexity and centralization risks in self-hosted scenarios, or depend on slow and unreliable P2P transport mechanisms."

Read closely: the LNURL critique is that **HTTPS-endpoint requirements are the cause of LN-Address centralization** on a few custodians (WoS, Alby, Coinos, etc.). Self-hosting an LNURL endpoint is technically possible but operationally hard enough that most users don't, and they end up custodial.

**Wins for CLINK Offers vs LNURL**:
- No web server required by the recipient.
- Identity root is a Nostr keypair (no DNS, no CA chain).
- End-to-end encryption to the recipient (NIP-44), not TLS-to-some-server.
- Ephemeral payer keys are first-class.

**LNURL still wins on**:
- Deployed base — every web-stack already speaks HTTPS.
- Wallet UX maturity — the LNURL parser is in nearly every wallet shipping today.
- Discoverability — `name@domain` is universally understood social-layer identifier; `noffer1...` is not.

The **CLINK discovery caveat**: human-readable lookup still uses NIP-05 → HTTPS by default. See [[../concepts/clink-discovery-and-nip05.md]].

## CLINK vs BOLT12

The CLINK README's "slow and unreliable P2P transport mechanisms" line is a swipe at BOLT12's onion-message dependence — without naming BOLT12. It is the central architectural disagreement.

| Property | BOLT12 | CLINK Offers |
|----------|--------|--------------|
| Layer | Lightning protocol | Nostr overlay |
| Transport | Onion messages | NIP-44 events on relays |
| Recipient online requirement | LN node reachable on gossip graph | Subscribed to a relay |
| Privacy: hides recipient | **Yes (blinded paths)** | No (relay sees pubkey) |
| Privacy: hides payer | Yes (onion routing) | NIP-44 + ephemeral keys |
| Invoice format | TLV / Merkle | BOLT11 (inherits all BOLT11 limits) |
| Selective field disclosure | Yes | No |
| Standardization | BOLT / IETF-flavored | informal single-vendor |

**BOLT12 wins on**:
- Cleanliness (no overlay network).
- Privacy (blinded paths hide recipient node identity from payer).
- Trust anchors (no DNS, no Nostr).
- Richer invoice format (TLV / Merkle / per-user invoices / selective disclosure).

**CLINK wins on**:
- Mobile/web friendliness (relay subscription is cheaper than LN-node-online).
- Integration with existing Nostr identity & messaging.
- Removal of the "node must be online" constraint via persistent relay sub.
- Leverage of the already-deployed Nostr social graph.

CLINK's bet is that the Nostr substrate is "good enough" to subsume LNURL's deployed-base advantage while not paying BOLT12's online-ness tax. Whether that bet holds is a real empirical question about Nostr relay reliability in 2026.

**Open question**: Could CLINK Offers carry BOLT12 invoices instead of BOLT11, picking up TLV/Merkle/selective-disclosure for free? The spec hasn't gone there. ShockWallet `v0.0.22-beta` (2025-10-10) shipped "Blinded path offers" — coexistence rather than convergence.

## CLINK vs NWC (NIP-47)

NWC is the **closest functional competitor**. The CLINK README defines itself directly against NWC:

> "While NWC also utilizes Nostr for transport, it specifically targets wallet remote control modeled after the RPC pioneered by Lightning.Pub… Where NWC is deferential to LNURL and scoped for a specific task, CLINK is fundamentally committed to Nostr as the foundation for the next generation of decentralized Lightning applications."

Three structural rejections:

| NWC trait | CLINK rejects via |
|-----------|-------------------|
| RPC-shaped wallet remote-control (~12 methods) | Single primitive: "may I have this payment?" (Debits) |
| Persistent connection URI with **per-app shared secret** | Stateless ephemeral events; auth = signed Nostr event |
| "Deferential to LNURL" | Replaces (not wraps) LNURL |

Direct comparison (NWC vs Debits, both targeted at app-driven payment):

| Axis | NWC | CLINK Debits |
|------|-----|--------------|
| Shape | RPC | Authorization |
| Connection | Persistent URI | Stateless events |
| Pre-shared secret | Yes | No |
| Method surface | ~12 | 1 |
| Encryption | NIP-44 (NIP-04 deprecated) | NIP-44 only (no NIP-04 history) |
| Caller proves intent | By knowing secret | By signing event |
| Wallet's policy | App-budget + method allowlist | Per-pointer rules + optional user prompt |
| Revocation | Rotate connection URI | Invalidate `ndebit` pointer (out-of-band) |
| Notifications | Yes (kind 23196/23197) | No (out of scope) |

**Open ecosystem question**: NWC ships in Alby, Mutiny, Coinos, ZBD. CLINK's adoption story isn't yet "replace NWC" — it's "coexist." The two specs likely stay as **complementary, not competing**, per ShockNet's roadmap signals.

## CLINK Offers vs NIP-57 zaps

Zaps are the success story for Nostr↔Lightning UX, *and* they have a candidly documented trust problem. Per NIP-57:

> "The zap receipt is not a proof of payment, all it proves is that some nostr user fetched an invoice."

> "There is no real way to prove that the invoice is real or has been paid. You are trusting the author of the zap receipt for the legitimacy of the payment."

This is the **exact trust hop CLINK Offers is designed to eliminate.**

| Property | NIP-57 zaps | CLINK Offers (zap-equivalent) |
|----------|-------------|-------------------------------|
| Sender event | kind 9734 | kind 21001 request payload |
| Receipt event | kind 9735 (published by LNURL server) | kind 21001 response (optional) |
| Discovery | `lud06` / `lud16` on kind 0 | `noffer1...` on profile/event |
| Trusted parties | sender, recipient, LNURL server, relay | sender, recipient, relay |
| Description-hash binding | Yes (via LNURL callback) | Yes (via Nostr request) |
| Sender→recipient encryption | None (zap request is **public**) | NIP-44 |
| Receipt = proof of payment | No (per spec) | Stronger (issued by funds-holder) |
| Web infra needed | Yes | No |

**Trade-off**: CLINK's NIP-44 encryption flips the default to **private** — which is a real product question, not just a security upgrade. Zaps' public visibility powers leaderboards, "top zaps on this note," and social-payment UX. Any CLINK adoption analysis has to grapple with what social payments look like when receipts are end-to-end encrypted.

**Migration question**: if CLINK Offers replaces `lud06`/`lud16` in kind 0 metadata, do existing zap clients (Damus, Amethyst, Primal) detect `noffer1...` and route to 21001, or fall back?

## CLINK vs Lightning Address (LUD-16)

Lightning Address is the consumer-facing form of LNURL-pay (`name@domain` → `https://domain/.well-known/lnurlp/name`). It is also where LNURL-driven custodial concentration is most visible — most active LN-Addresses live on a handful of custodians.

CLINK Offers' replacement is `noffer1...` advertised through:
- NIP-05 well-known JSON `clink_offer` map
- Kind 0 metadata `content.clink_offer`

This produces **`name@domain` resolved to a noffer**, similar UX to LN-Address but with the recipient end being a Nostr pubkey instead of a custodial LNURL endpoint.

Caveat: the discovery hop still uses HTTPS (NIP-05). NymRank / Namecoin alternatives are in flight but not standardized in CLINK. See [[../concepts/clink-discovery-and-nip05.md]].

## Where CLINK lands

- **vs LNURL-pay**: clearly attempts replacement; succeeds on architecture (no web server, no DNS-rooted identity), still fights for deployed-base.
- **vs BOLT12**: positioned as more mobile-friendly cousin; concedes privacy and standardization purity; chosen route is the overlay-network bet.
- **vs NWC**: stronger conceptual rejection; effectively complementary in the deployed ecosystem (NWC for app-controlled wallet RPC, CLINK Debits for self-hosting / authorization-shaped flows).
- **vs Zaps**: surgical removal of the LNURL-server trust hop; complicated by the public-vs-private receipt UX question.
- **vs LN-Address**: same UX shape, different trust root; subject to the NIP-05 / HTTPS bootstrap caveat.

## See also

- [[../concepts/clink-overview.md]]
- [[../concepts/clink-offers.md]]
- [[../concepts/clink-debits.md]]
- [[../concepts/clink-discovery-and-nip05.md]]
- [[clink-security-and-trust.md]]
- [[../reference/specs-and-repos.md]]
