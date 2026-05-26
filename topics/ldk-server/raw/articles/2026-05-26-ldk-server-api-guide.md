---
title: "LDK Server — API Guide (gRPC surface, auth, methods)"
source_url: https://github.com/lightningdevkit/ldk-server/blob/main/docs/api-guide.md
type: article
ingested: 2026-05-26
tags: [ldk-server, grpc, api, authentication, hmac]
quality: 5
confidence: high
summary: Authoritative API contract for LDK Server. gRPC over HTTP/2+TLS at 127.0.0.1:3536, HMAC-SHA256 auth in x-auth metadata, ~40 RPCs covering on-chain, BOLT11 (incl. hodl), BOLT12, channels (incl. splicing), peers, payments, graph, server-streaming SubscribeEvents.
---

# LDK Server — API Guide

## Wire format

- **Service**: `api.LightningNode`
- **Path**: `/api.LightningNode/<Method>`
- **Encoding**: `application/grpc+proto` over HTTP/2 + TLS
- **TLS**: pinned self-signed ECDSA P-256 cert (replaceable with ACME-issued cert in production)
- **Default bind**: `127.0.0.1:3536`

## Authentication

- Header: `x-auth: HMAC <unix_ts>:<hmac_hex>`
- `HMAC-SHA256(api_key, ts_be || body)` where `ts_be` is the big-endian timestamp.
- ±60 second clock skew tolerance.
- API key is a 32-byte secret on disk (`api_key`).

## Method catalog (~40 RPCs)

### Node info / wallet
- `GetNodeInfo`, `GetBalances`
- `OnchainSend`, `OnchainReceive`
- `SignMessage`, `VerifySignature`

### BOLT11
- Standard send/receive
- Hodl (preimage-less): `Bolt11ReceiveForHash`, `Bolt11ClaimForHash`, `Bolt11FailForHash`
  - Added explicitly to unblock Fedimint Gateway (see [[2026-05-26-fedimint-gateway-ldk-node-case-study.md]]).
- LSPS2 JIT channels supported on receive

### BOLT12 (Offers)
- Send, receive, decode
- LDK leads industry on BOLT12 maturity

### Spontaneous / unified
- Keysend
- `UnifiedSend` (BIP21, BIP353)

### Channels
- `OpenChannel`, `CloseChannel`, `ForceCloseChannel`
- `SpliceIn`, `SpliceOut` (experimental, via ldk-node v0.7.0)
- `UpdateChannelConfig`

### Peers / graph
- Connect/disconnect/list peers
- Graph queries
- `ExportPathfindingScores`
- `DecodeInvoice`, `DecodeOffer`

### Payments
- `ListPayments` with cursor pagination

### Events
- `SubscribeEvents` — server-streaming. 1024-slot broadcast channel; slow consumers drop.
- Events: `PaymentReceived`, `PaymentSuccessful`, `PaymentFailed`, `PaymentClaimable`, `PaymentForwarded`, `ChannelStateChanged`.

## Error model

Standard gRPC status codes:
- `INVALID_ARGUMENT` — bad input
- `FAILED_PRECONDITION` — node not in valid state for op
- `INTERNAL` — bug / unexpected
- `UNAUTHENTICATED` — bad/missing HMAC

## Notes

- `ldk-server-client` Rust crate exists but the docs lack client code samples.
- Canonical proto definitions live in `ldk-server-grpc/src/proto/` (`api.proto`, `types.proto`, `events.proto`, `error.proto`).

## See also

- [[2026-05-26-ldk-server-readme.md]] — repo overview
- [[2026-05-26-ldk-server-operations.md]] — TLS/auth operational concerns
- [[wiki/concepts/grpc-api-surface.md|gRPC API surface]]
