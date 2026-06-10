---
title: CLINK Manage (kind 21003 / nmanage)
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-spec-primitives-clink-manage-spec.md
  - raw/articles/2026-06-09-security-clink-manage-spec.md
---

# CLINK Manage (kind 21003 / nmanage)

Delegated CRUD over wallet-server resources via Nostr ephemeral event kind **21003**. The newest CLINK primitive (PR #4 merged 2025-07-31, by `boufni95`). Currently defines exactly one resource type: `offer`. The spec is extensible — future resources will reuse the same kind/pointer with a new `resource` value.

Manage is the most distinctive CLINK primitive — neither NWC, LNURL, nor BOLT12 expose a comparable resource-management surface. It enables a marketplace pattern (apps creating offers in the user's name) that's hard to express otherwise without server callbacks or pre-shared API keys.

## Pointer encoding

Bech32 HRP `nmanage`. TLV payload:

| TLV | Field | Required | Notes |
|-----|-------|----------|-------|
| 0 | Wallet server pubkey | yes | 32 bytes hex |
| 1 | Recommended relay URL | yes | string |
| 2 | Pointer ID | optional | multi-account support |

## Wire flow

NIP-44-encrypted JSON in kind 21003 events with tags `["p", <wallet_server_pubkey>]`, `["clink_version", "1"]`. Responses additionally include `["e", <request_event_id>]`.

### Five offer actions

| Action | Idempotent? | Notes |
|--------|-------------|-------|
| `create` | No | Server generates the offer ID |
| `update` | Yes | Errors if `id` absent |
| `get` | Yes | Errors if `id` absent |
| `list` | Yes | Filtered to requesting app's offers by default |
| `delete` | Yes | Returns success if already deleted |

### Create example

```json
{
  "resource": "offer",
  "pointer": "<pointer_id>",
  "action": "create",
  "offer": {
    "label": "Product X",
    "price_sats": 12345,
    "callback_url": "https://example-marketplace.app/callback/123",
    "payer_data": ["email", "shipping_address"]
  }
}
```

Success response:

```json
{
  "res": "ok",
  "resource": "offer",
  "details": {
    "id": "<server_generated>",
    "label": "...",
    "price_sats": ...,
    "callback_url": "...",
    "payer_data": [...],
    "noffer": "<bech32 offer pointer>"
  }
}
```

The response includes the server-minted `noffer1...` pointer — the same offer is now usable through the [[clink-offers.md|Offers]] flow.

### Update example

```json
{
  "resource": "offer",
  "action": "update",
  "offer": {
    "id": "<offer_id>",
    "fields": {"label": "...", "price_sats": 23456}
  }
}
```

Only existing fields may be supplied in the `fields` object.

## Authorization invariants

- **Wallet server generates offer IDs**; clients cannot supply them on `create`.
- Wallet server **MUST** track which app created each offer (per-pubkey).
- Apps can only modify offers they themselves created, unless user policy explicitly permits otherwise.
- `list` queries are filtered to the requesting app's offers by default.
- Offer IDs MUST be unique per wallet server.

## Error envelope

Same GFY shape as Debits, with the same six codes. Replay protection: 30-second `created_at` delta (MUST per Manage spec — stricter than Debits' SHOULD).

## Direct quotes

> "delegated management of wallet resources… specific, auditable rights"

> "The wallet server MUST track which app created each offer and MUST reject modification or deletion requests from other apps."

> "Apps should not be able to modify or delete offers they did not create, unless explicitly permitted."

> "All requests are signed and auditable."

> "New managed resources can be proposed and added using the same pointer and event kind, with a new resource value in the payload."

## Critical gap: revocation model

Manage's biggest spec hole is that it **defines no protocol-level revocation**. There is:

- No `revoke` event (CLINK or otherwise).
- No time-bound on a delegation.
- No expiration window.
- No NIP-26 adoption (CLINK chooses not to use NIP-26's delegated-signing model — but doesn't justify the choice).

The implicit model is "wallet server administers permissions out-of-band." This is the **single biggest open security/trust question** in the whole CLINK protocol — see [[../topics/clink-security-and-trust.md#manage-revocation-gap|security analysis]].

Compare to NIP-26: even though it is `unrecommended`, NIP-26 at least encodes a **time-bound** in the delegation token. CLINK Manage has even less.

## Adoption status

- **Spec text**: complete.
- **Reference wallet (ShockWallet / wallet2)**: ships Manage as of `v0.0.20-beta` (2025-08-11) with "clink manage auth and list" by boufni95.
- **Reference server (Lightning.Pub)**: not confirmed to ship Manage. README mentions Offers and Debits explicitly; Manage is absent from the ecosystem-table description.
- **Third-party adoption**: zero confirmed. Stacker News uses Offers + Debits but no Manage. The CLINK SDK (npm `@shocknet/clink-sdk`) doesn't advertise Manage in its README ecosystem entry.

Manage is the **least-shipped of the three primitives** despite being client-side ready in ShockWallet.

## Open questions

- Why does Manage exist as a separate primitive rather than being an extension of NWC's command set?
- How are app permissions revoked in practice? Spec mentions auditability but not a revocation/listing/UI flow.
- Does Lightning.Pub expose user-facing UI for reviewing app-created offers?
- For `list` / `get`, are there pagination or query/filter parameters? Spec example shows none.
- Will future resources include: debit policies, account info, channel/peer state, routing config, custom records?
- How does an app discover the user's `nmanage1...` pointer initially (NIP-05? user paste? deep link?)
- **Why didn't CLINK adopt NIP-26?** Spec doesn't say. Possible reasons: NIP-26 is `unrecommended`; resource-scoped delegation at the wallet-server layer is a better fit; CLINK didn't want to depend on a draft spec. None of this is in the spec text.
- Could a malicious app with Manage permission **shadow another app's offers** in some UX (without modifying them)? Not explicitly addressed.

## See also

- [[clink-overview.md]]
- [[clink-offers.md]]
- [[clink-debits.md]]
- [[../topics/clink-security-and-trust.md]]
- [[../topics/clink-roadmap-signals.md]] — Sanctum + Manage convergence
