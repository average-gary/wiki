---
title: "LDK Server gRPC API surface"
type: concept
created: 2026-05-26
updated: 2026-05-26
confidence: high
tags: [grpc, api, hmac, authentication, hold-invoice, bolt12]
---

# LDK Server gRPC API surface

LDK Server exposes a single gRPC service `api.LightningNode` over HTTP/2 + TLS. There is **no REST API** other than `GET /metrics` (Prometheus). Compare with LND, which ships gRPC + a REST gateway out of the box.

## Wire and auth

| | |
|---|---|
| Service | `api.LightningNode` |
| Path | `/api.LightningNode/<Method>` |
| Encoding | `application/grpc+proto` |
| Transport | HTTP/2 + TLS (pinned self-signed ECDSA P-256 by default) |
| Default bind | `127.0.0.1:3536` |
| Auth header | `x-auth: HMAC <unix_ts>:<hmac_hex>` |
| Auth algo | `HMAC-SHA256(api_key, ts_be \|\| body)` |
| Clock skew | ±60 seconds |

The API key is a single 32-byte secret in `~/.ldk-server/api_key`. There is no granular auth (per-method, per-role) — issue [#140](https://github.com/lightningdevkit/ldk-server/issues/140) is open.

## Method groups (~40 RPCs)

### Node and wallet
`GetNodeInfo`, `GetBalances`, `OnchainSend`, `OnchainReceive`, `SignMessage`, `VerifySignature`.

### BOLT11 — including hold invoices
- Standard send/receive.
- **Hold (preimage-less)**: `Bolt11ReceiveForHash`, `Bolt11ClaimForHash`, `Bolt11FailForHash`.
- LSPS2 JIT channels supported on receive.

The hold-invoice surface was added upstream in LDK Node specifically to unblock the [[../../raw/articles/2026-05-26-fedimint-gateway-ldk-node-case-study.md|Fedimint Gateway integration]]. It's the canonical missing-feature-driven-by-real-user pattern in the LDK Server story.

### BOLT12 (Offers)
Send, receive, decode. LDK leads industry on BOLT12 maturity.

### Channels
`OpenChannel`, `CloseChannel`, `ForceCloseChannel`, `SpliceIn`, `SpliceOut` (experimental, via ldk-node v0.7.0), `UpdateChannelConfig`.

### Spontaneous / unified
Keysend, `UnifiedSend` (BIP21 / BIP353).

### Peers and graph
Connect/disconnect/list peers, graph queries, `ExportPathfindingScores`, `DecodeInvoice`, `DecodeOffer`.

### Payments
`ListPayments` with cursor pagination.

### Events
`SubscribeEvents` — server-streaming, 1024-slot broadcast channel, **slow consumers drop**. Events: `PaymentReceived`, `PaymentSuccessful`, `PaymentFailed`, `PaymentClaimable`, `PaymentForwarded`, `ChannelStateChanged`.

## Error model

Standard gRPC status: `INVALID_ARGUMENT`, `FAILED_PRECONDITION`, `INTERNAL`, `UNAUTHENTICATED`.

## Client story

- `ldk-server-client` Rust crate exists; docs lack code samples.
- `ldk-server-cli` is the canonical CLI, auto-discovers credentials when run on the same host.
- `ldk-server-mcp` ships an MCP (Model Context Protocol) bridge over the unary RPCs — agent/LLM integration baked in.
- Canonical `.proto` files: `ldk-server-grpc/src/proto/{api,types,events,error}.proto`. Generate clients in any gRPC-supported language.

## Compared to LND

| | LDK Server | LND |
|---|---|---|
| API | gRPC | gRPC + REST gateway |
| Auth | HMAC-SHA256 single key | macaroons (per-permission) |
| Status | pre-1.0, no tagged releases | mature, used in prod for years |
| Client SDKs | Rust client + MCP | Many (lnrpc compiled to N langs) |

## See also

- [[../../raw/articles/2026-05-26-ldk-server-api-guide.md|API guide source]]
- [[../../raw/articles/2026-05-26-ldk-server-operations.md|Operations: TLS/auth concerns]]
- [[ldk-vs-ldk-node-vs-ldk-server.md]]
