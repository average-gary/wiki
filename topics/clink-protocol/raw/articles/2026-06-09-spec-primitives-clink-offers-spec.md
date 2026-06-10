---
title: "CLINK Offers Specification (clink-offers.md)"
source: https://github.com/shocknet/CLINK/blob/master/specs/clink-offers.md
type: article
ingested: 2026-06-09
path: spec-primitives
quality: 5
credibility: high
tags: [clink, nostr, lightning, offers, noffer, spec, kind-21001, nip-44, nip-57]
---

## Source overview

The CLINK Offers spec defines static, reusable Lightning payment codes encoded as bech32 strings (`noffer1...`) and exchanged over Nostr ephemeral event kind 21001. It is positioned as a Nostr-native replacement for LNURL-pay and BOLT12 offers.

## Key findings

- Offers are encoded as bech32 strings with HRP `noffer` (e.g., `noffer1qvq...`); no URI scheme prefix, no BIP-21 wrapper.
- TLV-encoded payload inside the bech32 data:
  - **Type 0** — Receiver public key (32 bytes hex, required)
  - **Type 1** — Relay URL (string, optional but recommended)
  - **Type 2** — Offer identifier (opaque service-defined string, required)
  - **Type 3** — Pricing type flag: `0`=Fixed, `1`=Variable, `2`=Spontaneous (optional)
  - **Type 4** — Price in sats (optional)
  - **Type 5** — Currency code like "USD"/"EUR" (optional, requires type 1=variable)
- If neither price (TLV 4) nor type (TLV 3) is present, offer SHOULD be treated as type 2 Spontaneous.
- Wire protocol uses ephemeral Nostr event kind **21001** with NIP-44 encrypted JSON content.
- Required event tags on **request**: `["p", "<recipient_pubkey>"]`, `["clink_version", "1"]`.
- Required event tags on **response**: `["p", "<payer_pubkey>"]`, `["e", "<request_event_id>"]`, `["clink_version", "1"]`.
- Request payload schema (JSON inside encrypted content):
  ```json
  {
    "offer": "<offer_id_string>",
    "amount_sats": <integer>,
    "payer_data": {<arbitrary_json>},
    "zap": "<stringified_kind_9734_event>",
    "expires_in_seconds": <integer>,
    "description": "<string_max_100_chars>"
  }
  ```
- Success response: `{"bolt11": "<BOLT11_invoice_string>"}`
- Error response: `{"error": "<msg>", "code": <n>, "range": {"min": <sats>, "max": <sats>}}`
- Numbered error codes:
  1. Invalid Offer
  2. Temporary Failure
  3. Expired or Moved Offer (may include `"latest"` field with replacement noffer string for auto-retry)
  4. Unsupported Feature
  5. Invalid Amount (includes `range` object)
- Payers MAY use ephemeral keys for privacy.
- Payment receipt may include 64-char hex Lightning preimage, or `{"res": "ok"}` for internal (non-Lightning) settlement.
- NIP-57 zap integration: CLINK Offers replace LNURL-pay callbacks; zap-supporting services should use offer IDs prefixed with `zap` (e.g., `zap_default`).
- NIP-05 discovery: well-known JSON may include a `clink_offer` map keyed by name pointing to noffer strings; users can also advertise primary offer in kind 0 metadata via `clink_offer` content field.

## Cited identifiers/keys

- Bech32 HRP: `noffer` → encoded `noffer1<bech32-data>`
- Nostr event kind: **21001** (ephemeral)
- Encryption: **NIP-44**
- Tags: `["p", "<pubkey>"]`, `["e", "<event_id>"]`, `["clink_version", "1"]`
- NIP-05 well-known field: `clink_offer` (object with name→noffer mapping)
- Kind 0 metadata content field: `clink_offer` (single noffer string)
- Zap event referenced: kind 9734 (NIP-57)
- Description max length: 100 characters
- Error 3 retry hint field: `latest` (replacement noffer string)

## Direct quotes

- "If neither price (TLV 4) nor pricing type (TLV 3) is present, the offer SHOULD be treated as type 2 (Spontaneous payment)."
- "Use NIP-44 for all content encryption."
- "An offer QR is not a BOLT11 invoice. Invoices are generated dynamically after a kind 21001 request and MUST NOT be substituted for the static offer code."
- "CLINK events utilize a mandatory `[\"clink_version\", \"1\"]` tag. This ensures disambiguation and version compatibility."

## Open questions surfaced

- Is TLV 1 (relay URL) actually optional? Spec rates it as recommended but practical resolution requires *some* relay.
- How is the relay URL formatted — list, single string, with TLS hint?
- What happens if a `noffer` carries pricing type 0 (Fixed) but no TLV 4 (price)? Conflicting required-fields scenario.
- Are responses also kind 21001 (same kind for both directions), or is there a separate response kind?
- How does NIP-05 `clink_offer` mapping interact with multiple offers per identity?

## Why this source matters for the topic

The Offers spec is the most-implemented CLINK primitive (ShockWallet, ZEUS, Stacker News, TakeMySats, Bridgelet) and the entry point for most users. It is the closest functional analog to LNURL-pay and BOLT12 — getting its details right is essential to any compilation comparing CLINK to alternatives.
