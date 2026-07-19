---
title: "SV2 Extensions Negotiation (0x0001)"
category: concept
sources:
  - raw/articles/2026-07-17-sv2-spec-extensions-negotiation.md
  - raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md
created: 2026-07-17
updated: 2026-07-17
tags: [sv2, sv2-spec, extensions-sv2, extension-negotiation, extension-0x0001, request-extensions, setup-connection]
aliases: ["Extensions Negotiation", "RequestExtensions", "extension 0x0001", "0x0001-extensions-negotiation"]
confidence: high
volatility: warm
verified: 2026-07-17
summary: "SV2 extension type 0x0001 defines the RequestExtensions / RequestExtensions.Success / RequestExtensions.Error handshake sent immediately after SetupConnection. It resolves sv2-spec issue #95 (how to handle unknown extensions) with a positive-ACK model — the client declares all desired extensions at once and the server ACKs supported ones — rather than the universal per-extension NACK originally debated."
---

# SV2 Extensions Negotiation (0x0001)

> SV2's core message types are versioned and stable, but optional capabilities ship as opt-in **extensions** that both peers must agree to before using. Extension type `0x0001` is the meta-extension that standardizes *how* that agreement happens: right after `SetupConnection`, the client sends `RequestExtensions` listing every extension it wants, and the server answers with a single `RequestExtensions.Success` or `RequestExtensions.Error`. This is the normative resolution of the long-running design debate in sv2-spec issue #95.

## Why a negotiation handshake exists

The SV2 protocol overview (`03-Protocol-Overview.md` §3.4) has always required that "extensions MUST require version negotiation with the recipient of the message to check that the extension is supported before sending non-version-negotiation messages for it." The stated goal is to avoid wasting bandwidth and risking performance degradation by sending extension messages a peer cannot understand. The problem, raised in sv2-spec issue #95 (see [The issue #95 design debate](#the-issue-95-design-debate) below), was that the spec mandated negotiation but never said *how* to do it. Extension type `0x0001` is the answer that was ultimately specified.

## The handshake

The negotiation is a single request/response round trip that sits between `SetupConnection.Success` and any protocol-specific (e.g. mining) messages:

1. **Client → Server: `RequestExtensions`** — carries a `request_id` (U16) to pair the response and a `requested_extensions` list (`SEQ0_64K[U16]`) of extension identifiers the client wants to use.
2. **Server → Client: `RequestExtensions.Success`** — echoes the `request_id` and returns `supported_extensions`, the subset of requested identifiers the server supports.
3. **Server → Client: `RequestExtensions.Error`** — echoes the `request_id` and returns two lists: `unsupported_extensions` (requested but not supported) and `required_extensions` (extensions the server itself requires that the client did not request).

After a successful `SetupConnection` the client **MUST** send `RequestExtensions`, and it **MUST NOT** use features from any extension the server has not confirmed. All three messages carry `extension_type = 0x0001` in the frame header — see [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)), which reserves that field.

### Message types

| Msg type (8-bit) | channel_msg bit | Name |
|---|---|---|
| 0x00 | 0 | `RequestExtensions` |
| 0x01 | 0 | `RequestExtensions.Success` |
| 0x02 | 0 | `RequestExtensions.Error` |

Because the `channel_msg` bit is 0, none of these messages are channel-scoped — they are interpreted by the immediate receiver, which fits their role as connection-level setup before any mining channel exists.

## Ordering, timeouts, and failover

The spec pins the handshake to a specific point in the connection lifecycle and gives concrete guidance for the case the design debate worried about most — a server that never answers:

- `RequestExtensions` **MUST** be sent immediately after `SetupConnection.Success` and before any protocol-specific messages; the client **MUST** receive the response before proceeding.
- A server that does not implement `0x0001` simply **ignores** `RequestExtensions` (the "assume unsupported / ignore" default). Clients therefore need a timeout rather than relying on a NACK.
- The suggested client strategy bounds that wait: wait 2× the initial connection time; if no response, reconnect and retry; if still nothing after 5×, reconnect once more and proceed without extensions; if total connection time exceeds roughly one second, consider switching to a fallback pool.
- If the server lists a `required_extensions` entry the client does not adopt on retry, **the server MUST disconnect the client**.

### Worked examples

- Request `[0x0002, 0x0003]` → `Success [0x0002]`: extension `0x0003` is unsupported, so the client adapts and uses only `0x0002`.
- Request `[0x0002]` where it is unsupported → `Error {unsupported: [0x0002], required: []}`: the client MAY continue without extensions.
- Request `[0x0002, 0x0003]` where the server requires `0x0005` → `Error {unsupported: [0x0003], required: [0x0005]}`: the client MAY retry including `0x0005`; if it does not, the server must disconnect it.

### A spec inconsistency worth flagging

The §4 error-handling prose says that when a server requires extensions the client did not request, it lists them in "the `requested_extensions` field," while the §2 message table names that field `required_extensions`. This is a minor naming inconsistency in the upstream spec; the message-table name (`required_extensions`) is the one that matches the field's role.

## The issue #95 design debate

Extension `0x0001` is best understood against the alternatives that were argued and rejected in [sv2-spec #95](<../../raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md>), opened by Fi3 in August 2024. That thread never merged a spec change itself, but it framed every design axis the eventual extension had to settle:

- **Universal per-extension NACK (Fi3's original proposal).** Any implementation receiving a message for an unknown extension would answer with a universal error frame (`msg_type: 0xff`, empty payload), scoped per extension. The argument: a NACK is faster most of the time, because without it you must always wait a full timeout before concluding non-support.
- **Positive-ACK only (jakubtrnka).** Since the spec already mandates negotiation, a peer should simply "assume the peer doesn't support my extension unless it receives a positive acknowledgement." He argued for minimizing protocol states (a "pending" state awaiting an ACK that never arrives is a bug magnet) and noted that on a single async connection you always defer handling anyway, so a NACK buys little. His tentative recommendation reserved `message_id == 0` as a per-extension negotiation message and `message_id == 255` as an ACK, treating any non-ACK response as a NACK.
- **Explicit but richer NACK (rrybarczyk).** Argued the clarity of an explicit ACK/NACK outweighs the latency (extension setup is infrequent), that a timeout is needed *either way* because messages can be delayed by connection prioritization, and that a NACK could carry an `error_code` and `reason_string` so a sender could retry with a different version. Also raised extension-lifecycle questions (override, add-mid-session, stop-all).

The merged `0x0001` design lands between these: it is a **positive-ACK model** — the client learns support from `RequestExtensions.Success`, matching jakubtrnka's "assume unsupported until ACK" and "ignore if not implemented" defaults — but it keeps an explicit **error** message (rrybarczyk's clarity argument) that additionally reports server-*required* extensions. It does **not** adopt the universal per-extension `0xff` NACK frame, and it replaces per-extension probing with a single batched request declared up front. The unresolved lifecycle questions from the issue (stopping or overriding an active extension) are left to individual extensions, consistent with Fi3's preference for per-extension stop mechanisms.

## Significance for SRI

Extension `0x0001` is the wire contract implemented by the SRI [[sv2-extensions|`extensions_sv2`]] ([`extensions_sv2`](sv2-extensions.md)) crate, and its messages are dispatched through the `Extensions` variant of [[sv2-message-handlers|`handlers_sv2`]] ([`handlers_sv2`](sv2-message-handlers.md)). Worker-Specific Hashrate Tracking (`0x0002`) is the first concrete extension that a client would negotiate through this mechanism before emitting its TLV fields.

## See Also

- [[sv2-extensions|SV2 Extensions]] ([SV2 Extensions](sv2-extensions.md)) — the `extensions_sv2` crate that implements this negotiation plus the TLV utilities extensions reuse
- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — the `extension_type` frame field that carries `0x0001`
- [[sv2-message-handlers|SV2 Message Handlers]] ([SV2 Message Handlers](sv2-message-handlers.md)) — the `Extensions` handler that dispatches these messages

## Sources

- [SV2 Extension 0x0001: Extensions Negotiation (sv2-spec)](../../raw/articles/2026-07-17-sv2-spec-extensions-negotiation.md) — normative RequestExtensions/.Success/.Error handshake, message tables, ordering, timeout/failover guidance
- [sv2-spec #95 — Handle unknown extensions](../../raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md) — the NACK-vs-ACK design debate the spec resolves
