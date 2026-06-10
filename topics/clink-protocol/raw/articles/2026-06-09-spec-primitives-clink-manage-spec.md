---
title: "CLINK Manage Specification (clink-manage.md)"
source: https://github.com/shocknet/CLINK/blob/master/specs/clink-manage.md
type: article
ingested: 2026-06-09
path: spec-primitives
quality: 5
credibility: high
tags: [clink, nostr, lightning, manage, nmanage, spec, kind-21003, nip-44, delegation]
---

## Source overview

The CLINK Manage spec defines delegated wallet-resource management over Nostr event kind 21003. Pointers prefixed `nmanage1...` let an external application (e.g., a marketplace) create, update, get, list, or delete resources (currently only `offer`) on the user's wallet server with auditable, signed events. Spec was merged via PR #4 on 2025-07-31 with revisions by contributor boufni95.

## Key findings

- Bech32 HRP `nmanage` encodes a TLV pointer:
  - **TLV 0** — Wallet server pubkey (32 bytes hex, required)
  - **TLV 1** — Recommended relay URL (required)
  - **TLV 2** — Pointer ID (optional, multi-account support)
- Wire protocol: ephemeral Nostr event kind **21003**, NIP-44 encrypted JSON content.
- Required tags: `["p", "<wallet_server_pubkey>"]`, `["clink_version", "1"]`. Responses additionally include `["e", "<request_event_id>"]`.
- Currently only one resource type defined: `offer`. Spec is extensible — "New managed resources can be proposed and added using the same pointer and event kind, with a new resource value in the payload."
- Five offer actions: `create`, `update`, `get`, `list`, `delete`.
- Idempotency rules:
  - **Create**: not idempotent
  - **Update**: idempotent (returns error if id absent)
  - **Get**: idempotent (returns error if id absent)
  - **List**: idempotent
  - **Delete**: idempotent (returns success if already deleted)
- Create request example:
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
- Update request uses `offer.id` + `offer.fields`:
  ```json
  {"resource": "offer", "action": "update",
   "offer": {"id": "<offer_id>", "fields": {"label": "...", "price_sats": 23456, ...}}}
  ```
- Success response (create/update/get) includes server-generated id and the corresponding `noffer` bech32 string:
  ```json
  {"res": "ok", "resource": "offer",
   "details": {"id": "<server_generated>", "label": "...", "price_sats": ...,
               "callback_url": "...", "payer_data": [...],
               "noffer": "<bech32 offer pointer>"}}
  ```
- Success (list) returns array of offer objects in `details`.
- Success (delete) returns `{"res": "ok", "resource": "offer"}`.
- Error envelope mirrors Debits: `{"res": "GFY", "code": <n>, "error": "<msg>"}`.
- GFY codes (same numbering as Debits):
  1. Request Denied
  2. Temporary Failure
  3. Expired Request (>30s delta recommended)
  4. Rate Limited
  5. Invalid Field/Value
  6. Invalid Request
- Authorization invariants:
  - **Wallet server generates offer IDs**; clients cannot supply them on create.
  - **Wallet server MUST track which app created each offer**.
  - Apps can only modify offers they themselves created (unless user policy permits otherwise).
  - List queries are filtered to the requesting app's offers by default.
  - Offer IDs MUST be unique per wallet server.
- All requests are signed Nostr events → naturally auditable and replay-attack-resistant via timestamp delta.

## Cited identifiers/keys

- Bech32 HRP: `nmanage` → `nmanage1<data>`
- Nostr event kind: **21003** (CLINK Management Delegation)
- Encryption: NIP-44
- Tags: `["p", ...]`, `["e", ...]`, `["clink_version", "1"]`
- Resource type strings: `"offer"` (only currently defined)
- Action strings: `"create"`, `"update"`, `"get"`, `"list"`, `"delete"`
- Response details may include `noffer` field with full bech32 pointer

## Direct quotes

- "delegated management of wallet resources"
- "specific, auditable rights"
- "secure, extensible, and Nostr-native"
- "The wallet server MUST track which app created each offer"
- "Only existing fields on an offer may be included in the fields object for an update"
- "Offer IDs MUST be unique per wallet server"
- "New managed resources can be proposed and added using the same pointer and event kind, with a new resource value in the payload."

## Open questions surfaced

- Why does Manage exist as a separate kind/primitive rather than being an extension of NWC's command set?
- How are app permissions revoked? Spec mentions auditability but not a revocation/listing/UI flow.
- Does the wallet server expose user-facing UI for reviewing app-created offers? (Lightning.Pub presumably does — needs verification.)
- For list/get, are there pagination or query/filter parameters? Spec example shows no params.
- Will future resources include: debit policies, account info, channel/peer state, routing config, custom records?
- How does an app discover the user's nmanage pointer initially (NIP-05? user paste? deep link?)

## Why this source matters for the topic

Manage is CLINK's most distinctive primitive — neither NWC, LNURL, nor BOLT12 expose a comparable resource-management surface. It enables a marketplace pattern (apps creating offers in the user's name) that is hard to express otherwise without server callbacks or pre-shared API keys. Captures the design that differentiates CLINK from the alternatives.
