---
title: "CLINK Debits Specification (clink-debits.md)"
source: https://github.com/shocknet/CLINK/blob/master/specs/clink-debits.md
type: article
ingested: 2026-06-09
path: spec-primitives
quality: 5
credibility: high
tags: [clink, nostr, lightning, debits, ndebit, spec, kind-21002, nip-44, k1, lnurl-withdraw]
---

## Source overview

The CLINK Debits spec defines authorization pointers (`ndebit1...`) that let third-party apps initiate Lightning payments from a user's node service over Nostr event kind 21002. It supports both static long-lived authorizations (subscriptions, recurring) and one-shot session pointers (LNURL-withdraw equivalence).

## Key findings

- Bech32 HRP `ndebit` encodes a TLV pointer:
  - **TLV 0** — Node service pubkey (32 bytes hex, required)
  - **TLV 1** — Relay URL (string, required)
  - **TLV 2** — Pointer ID (opaque, optional — routes to budget/account/app)
  - **TLV 3** — Session identifier `k1` (32 bytes random, optional — single-use sessions)
- **Static pointer** = TLV 0–2 only; long-lived; publishable in NIP-05 / kind 0 metadata.
- **Session ndebit** = static pointer + TLV 3; per-interaction, single-use; minted by application operator per QR.
- Wire protocol: ephemeral Nostr event kind **21002**, NIP-44 encrypted JSON content.
- Required tags: `["p", "<node_service_pubkey>"]`, `["clink_version", "1"]` on requests; response adds `["e", "<request_event_id>"]`.
- Three request payload variants:
  - **Direct payment**: `{"pointer": "...", "amount_sats": N, "bolt11": "lnbc...", "description": "...", "k1": "<64-hex>"}`
  - **Budget request**: `{"pointer": "...", "amount_sats": N, "frequency": {"number": N, "unit": "day"|"week"|"month"}, "description": "..."}`
  - **Implicit (no terms)**: `{"pointer": "..."}` — requests unrestricted access, subject to user policy.
- Response payloads:
  - Success direct (Lightning settled): `{"res": "ok", "preimage": "<32-byte hex>"}`
  - Success direct (internal settlement): `{"res": "ok"}` (no preimage)
  - Success budget approval: `{"res": "ok"}`
  - Failure: `{"res": "GFY", "code": <n>, "error": "<msg>"}` (+ context fields per code)
- **GFY = "General Failure to Yield"** — standardized error envelope with 6 codes:
  1. Request Denied (user/rule rejected)
  2. Temporary Failure (infrastructure)
  3. Expired Request (>30s timestamp delta) — adds `delta: {max_delta_ms: 30000, actual_delta_ms: ...}`
  4. Rate Limited — adds `retry_after: <unix_ts>`
  5. Invalid Amount — adds `range: {min, max}`
  6. Invalid Request (malformed, missing fields, duplicate k1) — adds `: <reason>`
- Frequency unit values: `"day"`, `"week"`, `"month"`. Omitting `frequency` → one-time budget. Multiplier supports e.g. 2-week intervals.
- Updated budget requests (e.g., fiat fluctuation) exceeding prior auto-approval thresholds **require new user confirmation**.
- `k1` rules:
  - 32 bytes; CSPRNG-generated; encoded as 64-char lowercase hex in JSON.
  - If TLV 3 present in pointer, wallet **MUST** include `k1` matching it; if absent, wallet **MUST NOT** invent one.
  - Node service SHOULD treat each `k1` as single-use within target pointer scope.
  - `k1` consumed only on accepted request; structural/validation errors do **not** consume it.
  - Duplicate `k1` while session pending → GFY code 6 ("K1 already processed").
- Session ndebit mirrors LNURL-withdraw flow: app mints fresh TLV 3 per QR; user wallet scans, generates a BOLT11 invoice for itself, sends kind 21002 with matching `k1`; node service pays the user's invoice.

## Cited identifiers/keys

- Bech32 HRP: `ndebit` → `ndebit1<data>`
- Nostr event kind: **21002**
- Encryption: NIP-44
- Tags: `["p", ...]`, `["e", ...]`, `["clink_version", "1"]`
- Failure envelope: `{"res": "GFY", "code": <1-6>, "error": "..."}`
- Success envelope: `{"res": "ok", ["preimage": "..."]}`
- Timestamp tolerance: 30 seconds (max_delta_ms: 30000)
- k1 encoding: 64-character lowercase hex (32 bytes)
- Frequency units: `day` | `week` | `month`

## Direct quotes

- "GFY" / "General Failure to Yield" — the spec's standardized error envelope.
- "Static pointer contains TLV items 0–2 only."
- "Session ndebit is static pointer plus session identifier in TLV 3."
- "Updated requests exceeding prior auto-approval limits require new user confirmation."
- "k1 correlates a kind 21002 debit request with specific session."
- "Implementations MUST include this tag in both request and response" (re: clink_version).

## Open questions surfaced

- PR #8 "revise debit k1" was merged 2026-06-09 — does the current spec language reflect the revision, and do existing wallets need to be updated?
- For session ndebits, does the wallet generate the BOLT11 invoice (LNURL-withdraw style) or does the app supply one? Spec implies wallet generates.
- What is the relationship between budget request approval and subsequent direct payments — does an approved budget produce a separate ndebit, or are subsequent payments attributed via `pointer` + node policy lookup?
- How are budget resets timestamped (UTC midnight? rolling window from approval)?
- What is the boundary between Debits' "implicit request" and NWC's `pay_invoice` capability — is implicit-mode ndebit effectively a NWC connection string?

## Why this source matters for the topic

Debits is the most ambitious CLINK primitive — it directly competes with NWC, LNURL-withdraw, and Lightning Address-derived withdrawal flows. The k1 session model and budget/frequency rules are the spec's sharpest design decisions and the place where compatibility with existing patterns is most contested. Captures the wire-level detail needed for any implementation or comparison.
