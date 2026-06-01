---
title: "dumbpipe 0.38.0 — netcat-like QUIC pipe over iroh"
source: https://github.com/n0-computer/dumbpipe
type: repo
tags: [dumbpipe, iroh, ssh, proxycommand, alpn, ticket]
date: 2026-06-01
publication_date: 2026-05-27
quality: 5
confidence: high
agent: 2
summary: "v0.38.0 (2026-05-27). Pinned: iroh = '=1.0.0-rc.1', iroh-tickets = '=1.0.0-rc.1'. ALPN constant: pub const ALPN: &[u8] = b'DUMBPIPEV0'. Handshake: pub const HANDSHAKE: [u8; 5] = *b'hello'. Re-exports EndpointTicket from iroh_tickets::endpoint. Subcommands: listen / connect / listen-tcp / connect-tcp / listen-unix / connect-unix; arbitrary ALPN via --custom-alpn. Builds Endpoint directly (no Router — single handler). NO ALLOWLIST in main.rs — listen accepts any peer that completes handshake."
---

# dumbpipe 0.38.0

The reference implementation for "iroh-as-stdio-pipe" patterns including SSH ProxyCommand.

## Wire constants

```rust
// src/lib.rs
pub const ALPN: &[u8] = b"DUMBPIPEV0";
pub const HANDSHAKE: [u8; 5] = *b"hello";

// re-exports
pub use iroh_tickets::endpoint::EndpointTicket;
```

## Critical rename in 1.0-rc

- `NodeTicket` → `EndpointTicket`
- `NodeAddr` → `EndpointAddr`
- `iroh-tickets` is now its own crate (split from iroh-base at 0.94)

dumbpipe uses the new names. Older code/docs are stale.

## Subcommands

```
dumbpipe listen
dumbpipe connect <ticket>

dumbpipe listen-tcp --host localhost:PORT
dumbpipe connect-tcp --addr 0.0.0.0:PORT <ticket>

dumbpipe listen-unix --socket-path PATH
dumbpipe connect-unix --socket-path PATH <ticket>

# arbitrary ALPN:
dumbpipe listen --custom-alpn utf8:/protocol-name
```

## Endpoint construction (main.rs)

```rust
let endpoint = Endpoint::builder(presets::N0)
    .secret_key(secret_key)
    .alpns(alpns)
    .bind_addr(...)
    .bind()
    .await?;
```

Secret key from `IROH_SECRET` env var via `get_or_create_secret()`. Builds Endpoint directly — **no Router**, single ALPN, single handler.

## SSH ProxyCommand pattern (community recipe; not in dumbpipe README)

```
# ~/.ssh/config
Host server-via-iroh
    HostName localhost
    Port 22
    ProxyCommand dumbpipe connect <ticket>
```

Where the server runs `dumbpipe listen-tcp --host localhost:22`.

## Allowlist gap

**Production gating must be added by the operator.** Options:

1. Wrap the dumbpipe ALPN handler in `iroh::protocol::AccessLimit<P>` (requires forking dumbpipe to use Router instead of bare Endpoint::accept)
2. App-layer auth on the bidi stream (e.g., consume an HMAC of the ticket as the first 32 bytes)
3. Run `dumbpipe listen` only on allowed peer connections via custom code

Compare to [[2026-06-01-iroh-ssh-rustonbsd]] which has the same gap.

## Tickets

`EndpointTicket::new(addr)` — the standard form (~140-char base32-ish). Carries:

- EndpointId (32-byte Ed25519)
- Relay URLs
- Direct address hints

`EndpointTicket` has a "short" variant that trims direct addresses (smaller QR).
