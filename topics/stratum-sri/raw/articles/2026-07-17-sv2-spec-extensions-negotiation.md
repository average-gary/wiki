---
title: "SV2 Extension 0x0001: Extensions Negotiation (sv2-spec)"
source: "https://github.com/stratum-mining/sv2-spec/blob/main/extensions/0x0001-extensions-negotiation.md"
type: articles
ingested: 2026-07-17
tags: [sv2, sv2-spec, extensions, extension-negotiation, RequestExtensions, extension-0x0001, setup-connection, extensions-sv2, normative-spec]
summary: "Normative SV2 spec (extension type 0x0001) defining the RequestExtensions / RequestExtensions.Success / RequestExtensions.Error handshake sent immediately after SetupConnection. This is the resolution of the design debate in sv2-spec issue #95: a positive-ACK negotiation with an explicit error message listing unsupported and server-required extensions — not the universal per-extension NACK originally floated."
canonical_url: "https://github.com/stratum-mining/sv2-spec/blob/main/extensions/0x0001-extensions-negotiation.md"
upstream_path: "extensions/0x0001-extensions-negotiation.md"
repo_revision: "d1099238e58db755cbb398255fbd3811381753db"
blob_sha: "3a7fcb4cef71a1e28e4cafa6c2cb96bdea1ec782"
content_format: markdown
license: "unknown (upstream sv2-spec)"
fetched: 2026-07-17
resolves: "sv2-spec#95 (see raw/notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md)"
---

# SV2 Extension 0x0001: Extensions Negotiation

Normative sv2-spec document (`extensions/0x0001-extensions-negotiation.md`), fetched at repo HEAD `d1099238`. NOTE: the requested path `extensions/extensions-negotiation.md` 404s; the actual file is prefixed with its hex extension type (`0x0001-`). Sibling: `0x0002-worker-specific-hashrate-tracking.md`.

## Relationship to issue #95 — this is the resolution

This spec answers the open design question in [[../notes/2026-07-17-sv2-spec-issue-95-unknown-extensions.md|sv2-spec #95]] ("how should a valid SV2 impl handle unknown extensions / do version negotiation?"). Notably, the merged design is **positive-ACK negotiation with an explicit error message** — *not* the universal per-extension NACK frame (`msg_type 0xff`) that Fi3 originally proposed nor the pure ACK-only model jakubtrnka argued for. Instead of per-extension probing, the client declares all desired extensions at once right after `SetupConnection`, and the server replies with a single Success or Error.

## Abstract

An SV2 extension to negotiate support for other protocol extensions between clients and servers. After `SetupConnection`, the client requests a list of extensions; the server responds with `RequestExtensions.Success` (supported list) or `RequestExtensions.Error` (unsupported list + extensions the receiver requires). RFC2119 keywords.

## Overview (§1)

- After a successful `SetupConnection` exchange, clients **MUST** send `RequestExtensions` to indicate desired extensions.
- Server responds `RequestExtensions.Success` (which are supported) or `RequestExtensions.Error` (unsupported + required).
- Clients **MUST NOT** use features from extensions not confirmed supported by the server.
- Handshake sits between `SetupConnection.Success` and any protocol-specific messages.

## Messages (§2)

**`RequestExtensions` (Client → Server)**
| Field | Type | Description |
|---|---|---|
| request_id | U16 | Unique id to pair the response |
| requested_extensions | SEQ0_64K[U16] | Requested extension identifiers |

**`RequestExtensions.Success` (Server → Client)**
| Field | Type | Description |
|---|---|---|
| request_id | U16 | Pairing id |
| supported_extensions | SEQ0_64K[U16] | Supported extension identifiers |

**`RequestExtensions.Error` (Server → Client)**
| Field | Type | Description |
|---|---|---|
| request_id | U16 | Pairing id |
| unsupported_extensions | SEQ0_64K[U16] | Requested-but-unsupported ids |
| required_extensions | SEQ0_64K[U16] | Ids the server requires but the client did not request |

## Message types (§3)

| Msg Type (8-bit) | channel_msg_bit | Name |
|---|---|---|
| 0x00 | 0 | RequestExtensions |
| 0x01 | 0 | RequestExtensions.Success |
| 0x02 | 0 | RequestExtensions.Error |

- **Framing**: all messages of this extension **MUST** carry `extension_type = 0x0001` in the frame header (this extension defined them). Ref: §3.4.1 Extension Type Field Usage in `03-Protocol-Overview.md`.

## Implementation notes (§4)

- **Error handling**: server **MUST** respond `RequestExtensions.Error` if none of the requested extensions are supported; if it **requires** extensions not requested, it **MUST** list them (spec body says the `requested_extensions` field — the message table calls this `required_extensions`; minor spec inconsistency worth flagging).
- **Ordering**: `RequestExtensions` **MUST** be sent immediately after `SetupConnection.Success` and before any protocol-specific messages; the response **MUST** be received before proceeding.
- **Backward compatibility**:
  - Servers that don't support this extension **ignore** `RequestExtensions` (matches jakubtrnka's "assume unsupported / ignore" default from #95).
  - Clients **MUST NOT** send extension-specific messages until they get `.Success`/`.Error`.
  - Clients **MAY** use a timeout/reconnection strategy: wait 2× initial-connection-time; if no response → reconnect + retry; if still none after 5× → reconnect once more and proceed without extensions; if total connection time exceeds ~1 second → consider switching to a fallback pool. (This is the concrete answer to the #95 "do we need a NACK to avoid waiting on a timeout?" debate: the spec keeps a timeout but bounds it and adds reconnect + pool-failover.)
- **Example use cases**:
  - Request `[0x0002, 0x0003]` → `.Success [0x0002]` ⇒ 0x0003 unsupported, adapt.
  - Request `[0x0002]`, unsupported → `.Error [unsupported: 0x0002, required: []]` ⇒ MAY continue without extensions.
  - Request `[0x0002, 0x0003]`, server requires `0x0005` → `.Error [unsupported: 0x0003, required: 0x0005]` ⇒ client MAY retry with 0x0005; **if it doesn't, the server MUST disconnect the client**.

## Significance for SRI

Defines the wire contract the SRI **`extensions-sv2`** crate implements (cf. [[2026-05-28-stratum-sri-sv2-extensions-sv2-readme.md|extensions-sv2 README]]). Extension `0x0002` (worker-specific hashrate tracking) is the first concrete consumer of this negotiation mechanism.
