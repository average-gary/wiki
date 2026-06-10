---
title: CLINK Debits (kind 21002 / ndebit)
type: concept
created: 2026-06-09
updated: 2026-06-09
confidence: high
sources:
  - raw/articles/2026-06-09-spec-primitives-clink-debits-spec.md
  - raw/articles/2026-06-09-security-clink-debits-spec.md
---

# CLINK Debits (kind 21002 / ndebit)

Authorization pointers (`ndebit1...`) that let third-party apps pull payments from a user's wallet/node service over Nostr ephemeral event kind **21002**. Supports one-shot, recurring (budgeted), and unrestricted (persistent) authorization shapes. Closest analogs: NWC `pay_invoice` (NIP-47) and LNURL-withdraw.

PR #8 ("revise debit k1") merged 2026-06-09 — wallet implementations may need updates to track the latest k1 wording.

## Pointer encoding

Bech32 HRP `ndebit`. TLV payload:

| TLV | Field | Required | Notes |
|-----|-------|----------|-------|
| 0 | Node service pubkey | yes | 32 bytes hex |
| 1 | Relay URL | yes | string |
| 2 | Pointer ID | optional | opaque; routes to budget/account/app |
| 3 | Session identifier `k1` | optional | 32 bytes random; presence = single-use session |

- **Static pointer** = TLV 0-2 only; long-lived; publishable in NIP-05.
- **Session ndebit** = static + TLV 3; minted per QR by the application operator (LNURL-withdraw analog).

## Wire flow — three request shapes

All requests are NIP-44-encrypted JSON in kind 21002 events with tags `["p", <node_service_pubkey>]`, `["clink_version", "1"]`.

### 1. Direct payment

```json
{
  "pointer": "<ndebit_pointer>",
  "amount_sats": <N>,
  "bolt11": "lnbc...",
  "description": "<string>",
  "k1": "<64-hex>"     // required iff pointer carries TLV 3
}
```

Service pays the supplied BOLT11 invoice on the user's behalf, subject to user-defined rules.

**Critical security guard**: "node service…MUST verify the invoice amount upon payment" — blocks amount-inflation by a service crafting a bolt11 different from what the user expected.

### 2. Budget request

```json
{
  "pointer": "<ndebit_pointer>",
  "amount_sats": <N>,
  "frequency": {"number": <N>, "unit": "day"|"week"|"month"},
  "description": "<string>"
}
```

Authorizes recurring spend up to `amount_sats` per `frequency`. Omitting `frequency` → one-time budget. Multiplier supports e.g. 2-week intervals. Updates exceeding prior auto-approval thresholds **require new user confirmation**.

### 3. Implicit / unrestricted

```json
{"pointer": "<ndebit_pointer>"}
```

Per spec: "request with no `bolt11`, no `amount_sats`, and no `frequency` is implicitly a request for unrestricted access." This is the highest-blast-radius shape and the lightest spec text — see [[../topics/clink-security-and-trust.md|security]].

## Response shape — GFY error envelope

- Success direct (Lightning settled): `{"res": "ok", "preimage": "<32-byte hex>"}`
- Success direct (internal settlement): `{"res": "ok"}`
- Success budget approval: `{"res": "ok"}`
- Failure: `{"res": "GFY", "code": <1-6>, "error": "<msg>"}` (+ context fields)

**GFY = "General Failure to Yield"** — CLINK's standardized error envelope. Codes:

| # | Name | Context fields |
|---|------|---------------|
| 1 | Request Denied | — |
| 2 | Temporary Failure | — |
| 3 | Expired Request | `delta: {max_delta_ms: 30000, actual_delta_ms: ...}` |
| 4 | Rate Limited | `retry_after: <unix_ts>` |
| 5 | Invalid Amount | `range: {min, max}` |
| 6 | Invalid Request | `: <reason>` (incl. duplicate k1) |

## k1 session rules

- 32 bytes; CSPRNG-generated; encoded as 64-char lowercase hex in JSON.
- If TLV 3 present in pointer, wallet **MUST** include matching `k1`; if absent, wallet **MUST NOT** invent one.
- Single-use within target pointer scope.
- Consumed only on accepted requests; structural/validation errors do **not** consume a k1.
- Duplicate `k1` while session pending → GFY code 6.

### Session ndebit flow (LNURL-withdraw analog)

1. App mints fresh TLV 3 per QR; encodes as `ndebit1...` static+session.
2. User wallet scans, generates a BOLT11 invoice for itself.
3. Wallet sends kind 21002 with matching `k1` and the self-generated bolt11 in the `bolt11` field.
4. Node service pays the user's invoice (effectively cashing out a withdrawal).

## Replay protection

- 30-second `created_at` delta (recommended SHOULD, not MUST).
- Single-use `k1` per session pointer.

Both controls are at the application layer — NIP-44 itself provides no replay protection.

## Direct quotes

> "All `content` payloads MUST use NIP-44 encryption between the requestor and node service."

> "The node service SHOULD treat each `k1` as single-use within the scope of the target `pointer`."

> "request with no `bolt11`, no `amount_sats`, and no `frequency` is implicitly a request for unrestricted access."

> "Node services MUST implement strong authorization logic. Permissions should be granular (per-app pubkey, per-pointer ID if used) and constrained by user-approved budgets/rules."

> "Node services should ensure payment processing and budget deduction are atomic to prevent race conditions or overspending."

## Direct comparison vs NWC

| Axis | NWC (NIP-47) | CLINK Debits |
|------|--------------|--------------|
| Shape | RPC (commands like `pay_invoice`) | Authorization request ("may I have this?") |
| Connection | Persistent URI w/ shared secret per app | Stateless ephemeral events |
| Pre-shared secret | Yes (per app) | No |
| Method surface | ~12 methods | 1 (authorize this payment) |
| Encryption | NIP-44 (NIP-04 deprecated) | NIP-44 only |

CLINK Debits explicitly rejects NWC's connection-URI-with-secret model; it is the source of CLINK's "no pre-shared secrets" claim. See [[../topics/clink-vs-alternatives.md#nwc|comparison vs NWC]].

## Open questions

- **PR #8 fallout**: what changed in "revise debit k1" merged 2026-06-09 and which wallets need updates?
- **No revocation primitive.** If an app key is exfiltrated, the only remedy is out-of-band instruction to the node service. There is no on-Nostr revoke event.
- **The 30-second window is a SHOULD, not a MUST.** Implementations diverging on the delta create interop holes.
- **Persistent/unrestricted-access pointers** are the highest-risk shape with the lightest spec text — no required UX warnings, no required expiry, no required spend-velocity caps.
- **Cross-app collusion**: two authorized apps could coordinate timing to drain a shared budget if budgets aren't scoped per-app pubkey (only a SHOULD).
- Node service compromise = single point of failure; spec doesn't analyze the breach response.

## See also

- [[clink-overview.md]]
- [[clink-offers.md]]
- [[clink-manage.md]]
- [[clink-wire-format.md]]
- [[../topics/clink-vs-alternatives.md]]
- [[../topics/clink-security-and-trust.md]]
