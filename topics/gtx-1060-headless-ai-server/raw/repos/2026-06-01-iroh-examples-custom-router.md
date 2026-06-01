---
title: "iroh-examples / custom-router — multi-ALPN reference impl"
source: https://github.com/n0-computer/iroh-examples/tree/main/custom-router
type: repo
tags: [iroh, router, protocolhandler, alpn, examples]
date: 2026-06-01
quality: 5
confidence: high
agent: 2
summary: "Canonical example: two ALPNs (`/iroh/test/1`, `/iroh/test/2`) on one endpoint. Minimal handler closes the connection with a configured number. Setup: Router::builder(server).accept(ALPN_1, TestProtocol(1)).spawn(); then runtime add: router.accept(ALPN_2, TestProtocol(2)).await?. Other examples in the repo include browser-blobs, dumbpipe-web, iroh-gateway, iroh-automerge, framed-messages."
---

# custom-router example

Canonical, copy-pasteable code for any multi-protocol iroh server.

## Code shape

```rust
const ALPN_1: &[u8] = b"/iroh/test/1";
const ALPN_2: &[u8] = b"/iroh/test/2";

#[derive(Debug, Clone)]
struct TestProtocol(u32);

impl ProtocolHandler for TestProtocol {
    async fn accept(&self, connection: Connection)
        -> Result<(), AcceptError>
    {
        connection.close(self.0.into(), b"bye");
        Ok(())
    }
}

let router = Router::builder(server)
    .accept(ALPN_1, TestProtocol(1))
    .spawn();

// Runtime registration after spawn:
router.accept(ALPN_2, TestProtocol(2)).await?;
```

## Other relevant examples in the repo

| Example | Demonstrates |
|---------|--------------|
| `browser-blobs`     | iroh-blobs in WASM |
| `browser-chat`      | iroh-gossip in WASM |
| `browser-echo`      | minimal browser endpoint |
| `dumbpipe-web`      | HTTP-over-dumbpipe to share local dev server |
| `iroh-gateway`      | HTTP gateway in front of iroh-blobs |
| `iroh-automerge`    | CRDT over iroh |
| `iroh-automerge-repo` | Automerge document repo over iroh |
| `tauri-todos`       | desktop app pattern |
| `framed-messages`   | length-delimited codec on iroh streams |
| `extism`, `frosty`  | other patterns |

## Notable absence

There is **no standalone `multiple-alpns` example** — multi-ALPN is folded into `custom-router`. So this is the canonical reference for that pattern.

## What this enables for an Iroh AI server

A single `Endpoint` exposing:

- `iroh/blobs/0`        → model weights, datasets (iroh-blobs Store)
- `DUMBPIPEV0`          → ssh tunnel (with allowlist)
- `my/inference/1`      → JSON-RPC for inference requests
- `my/metrics/1`        → telemetry pull
- `my/admin/1`          → ops commands (allowlist-gated)
- `web-transport/moq-00` → moq-relay on the same node (via web-transport-iroh)

Each handler version-pinned independently; one identity, one NAT punch.
