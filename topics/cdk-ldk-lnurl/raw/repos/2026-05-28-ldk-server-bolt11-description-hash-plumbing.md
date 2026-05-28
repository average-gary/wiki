---
title: "ldk-server — Bolt11InvoiceDescription Hash plumbing (production proof)"
type: repo
source: https://github.com/lightningdevkit/ldk-server/blob/main/ldk-server/src/util/proto_adapter.rs
fetched: 2026-05-28
confidence: high
tags: [ldk-server, description-hash, grpc, production-evidence]
summary: ldk-server (the canonical LDK daemon) accepts a hash variant on its gRPC Bolt11InvoiceDescription, decodes hex to 32 bytes, constructs Bolt11InvoiceDescription::Hash, and passes it to ldk-node's bolt11_payment().receive(). Production proof the API works end-to-end.
---

# ldk-server description_hash plumbing

## Proto schema

`ldk-server-grpc/src/proto/types.proto`:

```protobuf
message Bolt11InvoiceDescription {
  oneof kind {
    string direct = 1;
    string hash = 2;   // hex-encoded 32-byte SHA-256
  }
}
```

`ldk-server-grpc/src/proto/api.proto` — both `Bolt11ReceiveRequest` and `Bolt11ReceiveForHashRequest` reference `types.Bolt11InvoiceDescription description = 2;`.

## Adapter (`ldk-server/src/util/proto_adapter.rs`)

`proto_to_bolt11_description(...)`:
- Matches the protobuf `oneof kind`
- For `hash` variant: decodes the hex string into `[u8; 32]`
- Constructs:
  ```rust
  Bolt11InvoiceDescription::Hash(Sha256(*sha256::Hash::from_bytes_ref(&hash_bytes)))
  ```
- Returns the `Bolt11InvoiceDescription` enum value

## Handler call sites

`ldk-server/src/api/bolt11_receive.rs` and `bolt11_receive_for_hash.rs` both:
1. Receive the gRPC request with the description oneof
2. Call the adapter to convert to `Bolt11InvoiceDescription`
3. Pass it to `node.bolt11_payment().receive(amount_msat, &description, expiry)` (or `receive_for_hash` variant)

## Why this is decisive evidence

ldk-server is **maintained by the same org as ldk-node** (lightningdevkit). It is the canonical daemon embedder. If ldk-server ships description_hash on its public gRPC API and routes it to `bolt11_payment().receive()`, the thesis is unambiguously true for current ldk-node.

## Other adjacent embedders

- **Alby Hub** (`getAlby/hub/lnclient/ldk/ldk.go`) — passes `ldk_node.Bolt11InvoiceDescriptionHash{Hash: descriptionHash}` to `node.Bolt11Payment().Receive(...)` via the Go UniFFI binding. Confirms the Hash variant is reachable from non-Rust embedders.
- **cdk-ldk-node** (`cashubtc/cdk/crates/cdk-ldk-node/src/lib.rs`) — currently uses only `Bolt11InvoiceDescription::Direct(Description::new(description)?)`. The capability is available (it's on the same enum) but **not yet wired through CDK's MintPayment trait or NUT-04 quote endpoint**. This is the cdk-side gap — see [[../../wiki/concepts/lnurl-cdk-design-tensions.md|design tensions]].

## See also

- [[2026-05-28-ldk-node-bolt11-payment-source.md|ldk-node source]]
- [[2026-05-28-ldk-node-pr-438-description-hash.md|PR #438]]
