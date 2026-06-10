---
title: CLINK Offers (kind 21001 / noffer)
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-spec-primitives-clink-offers-spec.md
  - raw/articles/2026-06-09-comparison-clink-offers-spec.md
  - raw/articles/2026-06-09-security-clink-offers-spec.md
---

# CLINK Offers (kind 21001 / noffer)

Static, reusable Lightning payment codes encoded as bech32 strings (`noffer1...`) and exchanged over Nostr ephemeral event kind **21001**. Closest analogs: LNURL-pay (LUD-06) and BOLT12 offers (`lno1...`).

## Pointer encoding

Bech32 HRP `noffer`. TLV payload:

| TLV | Field | Required | Notes |
|-----|-------|----------|-------|
| 0 | Service public key | yes | 32 bytes hex |
| 1 | Relay URL | recommended | string |
| 2 | Offer identifier | yes | opaque service-defined |
| 3 | Pricing type | optional | `0`=Fixed, `1`=Variable, `2`=Spontaneous |
| 4 | Price | optional | sats |
| 5 | Currency | optional | ISO 4217 (e.g. "USD"); requires TLV 3 = 1 (Variable) |

If neither TLV 3 nor TLV 4 is present, the offer SHOULD be treated as type `2` (Spontaneous — payer chooses amount).

## Wire flow

**Request** (kind 21001):

```json
{
  "offer": "<offer_id_string>",
  "amount_sats": <integer>,
  "payer_data": {<arbitrary_json>},
  "zap": "<stringified_kind_9734_event>",   // optional, NIP-57 integration
  "expires_in_seconds": <integer>,
  "description": "<string_max_100_chars>"
}
```

Tags: `["p", <recipient_pubkey>]`, `["clink_version", "1"]`. Encrypted under NIP-44 to the service pubkey.

**Response** (kind 21001):

- Success: `{"bolt11": "<BOLT11_invoice>"}`
- Error: `{"error": "<msg>", "code": <1-5>, "range": {"min": ..., "max": ...}}`

Tags: `["p", <payer_pubkey>]`, `["e", <request_event_id>]`, `["clink_version", "1"]`.

### Error codes

1. Invalid Offer
2. Temporary Failure
3. Expired or Moved Offer (response MAY include `"latest"` field with a replacement noffer for auto-retry)
4. Unsupported Feature
5. Invalid Amount (response includes `range`)

## Discovery

Offers can be advertised in two NIP-05 surfaces:

- `.well-known/nostr.json` — `clink_offer` field as an object map: `"clink_offer": {"bob": "noffer1..."}`
- Kind 0 metadata `content.clink_offer` — single noffer string for primary offer.

This means CLINK Offers' default human-readable-discovery story still depends on **HTTPS + DNS** for the NIP-05 lookup hop. Issue [#6](https://github.com/shocknet/CLINK/issues/6) proposes Namecoin-backed resolution; ShockNet's own [NymRank](https://github.com/shocknet/NymRank) (Web-of-Trust namespace, Oct 2025) is the more likely in-house answer. See [[clink-discovery-and-nip05.md|discovery]].

## NIP-57 zap integration

The Offers spec replaces the LNURL-callback hop in the NIP-57 zap flow:

- Sender embeds the standard kind 9734 zap-request event in the `zap` field of the kind 21001 request payload.
- Service issues a BOLT11 invoice with the standard NIP-57 description-hash binding.
- Service marks zap-supporting offer IDs with the prefix `zap` (e.g. `zap_default`).
- Optional kind 21001 receipt response is issued by the same pubkey that holds funds — narrower trust than NIP-57's kind 9735 receipt, which the spec admits "is not a proof of payment" and only proves "some nostr user fetched an invoice."

See [[../topics/clink-vs-alternatives.md#nip-57-zaps|comparison vs NIP-57]].

## Privacy properties

- **Payer privacy**: payers MAY use ephemeral keys per request. Spec recommends but does not require.
- **Relay metadata privacy**: NIP-59 gift-wrap is suggested as an opt-in for hiding request/response association from any single relay. Adds round-trips.
- **Recipient privacy**: weaker than BOLT12. CLINK Offers exposes the recipient's Nostr pubkey + relay URL on the wire; BOLT12 blinded paths additionally hide the recipient's LN node identity.

## Direct quotes

> "An offer QR is not a BOLT11 invoice. Invoices are generated dynamically after a kind 21001 request and MUST NOT be substituted for the static offer code."

> "If neither price (TLV 4) nor pricing type (TLV 3) is present, the offer SHOULD be treated as type 2 (Spontaneous payment)."

> "This specification defines CLINK Offers… It serves as a Nostr-native successor to LNURL-Pay."

## Open questions

- **Recipient key rotation has no protocol expression.** A `noffer1` string contains a pubkey. Compromised/rotated keys leave printed QRs and stickers dangling.
- **TLV 1 ambiguity**: rated "recommended" but practical resolution requires *some* relay; not list-formatted.
- **Description-hash semantics**: LNURL-pay's `metadata` array is part of the BOLT11 description-hash chain. How does Offers preserve this binding when metadata is supplied via Nostr? (Spec is silent.)
- **TLV 3 = Fixed without TLV 4**: spec doesn't define behavior when pricing type is "Fixed" but no price is supplied.

See [[../topics/clink-security-and-trust.md|security and trust]] for the broader threat model.

## See also

- [[clink-overview.md]] — primitive index
- [[clink-debits.md]] — sibling primitive
- [[clink-wire-format.md]] — universal wire-format reference
- [[clink-discovery-and-nip05.md]] — how clients find an noffer
- [[../topics/clink-vs-alternatives.md]] — vs LNURL / BOLT12 / NIP-57
