---
title: "iroh-examples — framed-messages and custom-router"
source_url: https://github.com/n0-computer/iroh-examples/tree/main/framed-messages
secondary_url: https://github.com/n0-computer/iroh-examples/tree/main/custom-router
type: repo
date: 2026-05-20
org: n0-computer
credibility: high
quality: 4
relevance: direct
tags: [iroh, example, framing, router, alpn, copy-pattern]
ingested: 2026-05-20
---

# iroh-examples: framed-messages + custom-router

Direct copyable scaffolding for an SV2 ALPN handler.

## framed-messages — closest analog to SV2 over iroh

Wraps iroh streams with `tokio_util::codec::FramedRead`/`FramedWrite` +
`LengthDelimitedCodec` (big-endian u32 length prefix), then layers postcard +
serde on top to serialize structs.

> "`SendStream` and `RecvStream` from `iroh::Connection::open_bi` implement the
> `AsyncWrite` and `AsyncRead` traits"

> the codec "prefixes our messages with a big-endian encoded u32 representing
> the length of the message that follows it."

For SV2: replace `LengthDelimitedCodec` with the SV2 frame parser
(`codec_sv2::StandardSv2Frame` decoder) — same wrapping shape, different framing.

## custom-router — runtime ALPN multiplexing

```rust
struct TestProtocol(u32);

impl ProtocolHandler for TestProtocol {
    async fn accept(&self, connection: Connection) -> Result<(), AcceptError> {
        let (mut send, mut recv) = connection.accept_bi().await?;
        // ... handle ...
        connection.close(self.0.into(), b"bye");
        Ok(())
    }
}

const ALPN_1: &[u8] = b"/iroh/test/1";

let router = Router::builder(server)
    .accept(ALPN_1, TestProtocol(1))
    .spawn();
```

Connect side:
```rust
let conn = send_ep.connect(addr, ChessMovesALPN).await?;
let mut stream = FramedBiStream::new(bi_stream);
```

## Why this matters

The Router pattern lets an SV2 process expose multiple ALPNs simultaneously:

```rust
let router = Router::builder(endpoint)
    .accept(b"sv2/0", Sv2MainHandler::new(...))
    .accept(b"sv2/admin/0", Sv2AdminHandler::new(...))
    .accept(b"sv2/metrics/0", Sv2MetricsHandler::new(...))
    .spawn();
```

This is structurally cleaner than running multiple TCP listeners on different
ports — one endpoint, one identity, multiple ALPN-distinguished services.

## Returns from add_protocol

Returns `AddProtocolOutcome::{Inserted, Replaced}` on dynamic registration —
useful for hot-reload of SV2 role handlers without dropping the iroh endpoint.

## Verbatim snippets

```rust
connection.close(self.0.into(), b"bye");
Router::builder(server).accept(ALPN_1, TestProtocol(1)).spawn();
let conn = send_ep.connect(addr, ChessMovesALPN).await?;
let mut stream = FramedBiStream::new(bi_stream);
```
