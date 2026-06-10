---
title: CLINK wire format reference
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-spec-primitives-clink-offers-spec.md
  - raw/articles/2026-06-09-spec-primitives-clink-debits-spec.md
  - raw/articles/2026-06-09-spec-primitives-clink-manage-spec.md
---

# CLINK wire format reference

Universal wire-format reference for all three CLINK primitives. Use this when implementing or auditing a CLINK client/server.

## Universal invariants

| Property | Value | Source |
|----------|-------|--------|
| Encoding | NIP-19 bech32 with TLV payload | All specs |
| Encryption | **NIP-44** (mandatory; NIP-04 not used) | All specs |
| Event range | Ephemeral (20000–29999) | All specs |
| Mandatory tag | `["clink_version", "1"]` (request and response) | All specs |
| Request tag | `["p", <recipient_pubkey>]` | All specs |
| Response tag | `["e", <request_event_id>]` | All specs |
| Tag posture | Pubkey of the *signer* is implicit (Nostr) | NIP-01 |

## Per-primitive event kinds and HRPs

| Primitive | Kind | Bech32 HRP |
|-----------|------|-----------|
| Offers | 21001 | `noffer` |
| Debits | 21002 | `ndebit` |
| Manage | 21003 | `nmanage` |

## TLV catalog

### Offers (`noffer1...`)

| TLV | Field | Required | Notes |
|-----|-------|----------|-------|
| 0 | Service pubkey (32 bytes) | yes | |
| 1 | Relay URL | recommended | string |
| 2 | Offer ID | yes | opaque |
| 3 | Pricing type | optional | `0`=Fixed, `1`=Variable, `2`=Spontaneous (default if absent) |
| 4 | Price (sats) | optional | |
| 5 | Currency code | optional | requires TLV 3 = 1 |

### Debits (`ndebit1...`)

| TLV | Field | Required | Notes |
|-----|-------|----------|-------|
| 0 | Node service pubkey (32 bytes) | yes | |
| 1 | Relay URL | yes | |
| 2 | Pointer ID | optional | routes to budget/account/app |
| 3 | Session `k1` (32 bytes) | optional | presence ⇒ single-use session |

### Manage (`nmanage1...`)

| TLV | Field | Required | Notes |
|-----|-------|----------|-------|
| 0 | Wallet server pubkey (32 bytes) | yes | |
| 1 | Relay URL | yes | |
| 2 | Pointer ID | optional | multi-account |

## Replay protection (per primitive)

| Primitive | Mechanism | Strength |
|-----------|-----------|----------|
| Offers | `["e", request_event_id]` binding only | Implicit via signed event uniqueness |
| Debits | 30s `created_at` delta (SHOULD) + single-use `k1` (SHOULD) | App-layer |
| Manage | 30s `created_at` delta (MUST) + signed events | App-layer, stricter |

## Universal GFY error envelope (Debits and Manage)

```json
{"res": "GFY", "code": <1-6>, "error": "<msg>"}
```

Codes:

| Code | Name | Used by |
|------|------|---------|
| 1 | Request Denied | Debits, Manage |
| 2 | Temporary Failure | Debits, Manage |
| 3 | Expired Request (>30s delta) | Debits, Manage |
| 4 | Rate Limited | Debits, Manage |
| 5 | Invalid Amount / Field | Debits, Manage |
| 6 | Invalid Request | Debits, Manage |

Offers uses a different (and shorter) numbered error code list — see [[clink-offers.md#error-codes|Offers error codes]].

## Discovery surfaces

CLINK piggybacks on **NIP-05** for human-readable lookup:

- `.well-known/nostr.json` — `clink_offer` field as object map
- Kind 0 metadata `content.clink_offer` — single-string variant for primary offer

This means human-readable CLINK discovery still depends on **HTTPS + DNS** by default (issue [#6](https://github.com/shocknet/CLINK/issues/6) proposes Namecoin; ShockNet's [NymRank](https://github.com/shocknet/NymRank) is the in-house alternative). See [[clink-discovery-and-nip05.md]].

## Implementer checklist (minimal viable client)

1. Generate ephemeral payer keypair (per CLINK Offers privacy recommendation)
2. Decode `noffer1...` / `ndebit1...` / `nmanage1...` bech32 → extract TLVs
3. Build kind 21001/21002/21003 ephemeral event:
   - Tag `["p", <service_pubkey>]`, `["clink_version", "1"]`
   - NIP-44-encrypt the JSON payload to the service pubkey
   - Set `created_at` to current Unix time (within 30s of expected receipt)
4. Sign with payer (or app) Nostr key
5. Publish to the relay specified in TLV 1
6. Subscribe to responses tagged `["e", <my_request_event_id>]`
7. Decrypt response, validate signer matches expected pubkey, parse JSON

## Open spec ambiguities

- Does TLV 1 encode a list of relays or a single relay? Spec is silent.
- TLV 1 with TLS hint (wss vs ws): silent.
- Are responses on the same event kind as the request, or is there a separate response kind? Practically inferred to be same kind, but not unambiguously stated.
- Per-relay rate-limiting: spec mentions "should be mindful" but no mechanism.

## See also

- [[clink-offers.md]]
- [[clink-debits.md]]
- [[clink-manage.md]]
- [[clink-discovery-and-nip05.md]]
- [[../reference/specs-and-repos.md]]
