---
title: "iroh examples/auth-hook.rs and irpc-iroh/examples/auth.rs — token-handshake patterns"
source: https://github.com/n0-computer/iroh/blob/main/iroh/examples/auth-hook.rs, https://github.com/n0-computer/irpc/blob/main/irpc-iroh/examples/auth.rs
type: repo
tags: [iroh, auth-hook, irpc, example, token, handshake, alpn]
date: 2026-06-01
quality: 5
confidence: high
agent: technical
summary: "Two canonical token-handshake patterns. auth-hook.rs: a separate `auth::ALPN` ProtocolHandler does a pre-handshake, then Endpoint::builder(...).hooks(auth_hook) lets later opens-by-EndpointId be allowed; protected protocols (Echo) need NO auth knowledge. Split: `auth::incoming(token) -> (hook, protocol)` on accept side, `auth::outgoing(token) -> (hook, task)` on connect side. Token is Vec<u8>. irpc-iroh/auth.rs: alternative — in-protocol Auth { token: String } RPC inside the same ALPN, gated by per-connection state in a Mutex<HashSet<...>>."
---

# iroh's two token-handshake patterns

Pattern A (auth-hook): **separate ALPN for auth** + register allow-list in `Endpoint::hooks`. Pattern B (irpc): **in-protocol auth RPC** + per-connection allow state.

## Pattern A — auth-hook.rs (recommended)

```rust
// At server startup:
let token = b"shared-secret-or-derived".to_vec();
let (auth_hook, auth_proto) = auth::incoming(token);

let endpoint = Endpoint::builder()
    .hooks(auth_hook)        // gate future-opened streams
    .bind()
    .await?;

let router = Router::builder(endpoint)
    .accept(auth::ALPN, auth_proto)  // dedicated auth ALPN
    .accept(b"echo/0", EchoHandler)  // protected protocol — knows nothing about auth
    .spawn();

// Client side:
let token = b"shared-secret-or-derived".to_vec();
let (auth_hook, auth_task) = auth::outgoing(token);

let endpoint = Endpoint::builder()
    .hooks(auth_hook)
    .bind()
    .await?;

// Connect to auth ALPN first to authenticate:
let conn = endpoint.connect(addr, auth::ALPN).await?;
auth_task.run(conn).await?;

// Now subsequent connects to other ALPNs succeed:
let echo_conn = endpoint.connect(addr, b"echo/0").await?;
```

**Key insight**: Pattern A separates concerns cleanly:

- Auth handler knows about tokens
- Protected handlers know nothing
- Allow-set is cached in `hooks` after auth succeeds

This is the **recommended pattern** for the iroh app token wrapper.

## Pattern B — irpc auth example

```rust
// In-protocol message variant:
enum Request {
    Auth { token: String },
    DoThing,
}

// Per-connection allow state:
let allowed: Arc<Mutex<HashSet<ConnectionId>>> = Arc::new(Mutex::new(HashSet::new()));

handle_request(req, conn_id) -> Result {
    match req {
        Request::Auth { token } => {
            if validate(token) {
                allowed.lock().insert(conn_id);
                Ok(())
            } else { Err(Unauthorized) }
        }
        Request::DoThing => {
            if !allowed.lock().contains(&conn_id) { return Err(Unauthorized); }
            // ...
        }
    }
}
```

Pros: single ALPN, simpler routing.
Cons: every protected handler must check the allow-set; auth state per-connection (lost on reconnect).

## Token is `Vec<u8>` in both patterns

Iroh provides the **transport** for the token; it does NOT define the token format.

→ The iroh app token wrapper crate's job is to define the format (PASETO/Biscuit/random-opaque) and slot into `auth::incoming(...)` / `auth::outgoing(...)`.

## What the wrapper crate adds on top

Pattern A handles the wire mechanics. The wrapper adds:

1. **Token format** (PASETO v4 with footer carrying flags + epoch)
2. **Single-use enforcement** — after `validate(token)` passes, mark consumed in redb
3. **Seed rotation** — server-side seed rotates weekly; tokens issued under old seed silently fail validation
4. **Capability binding** — token's payload includes the capability (which ALPNs this token authorizes)
5. **Tailscale-style flags** — single-use / reusable / ephemeral / pre-approved / tag

## See also

- [[2026-06-01-iroh-pr-3157-accesslimit]]
- [[2026-06-01-iroh-pr-4205-relay-auth-tokens]]
- [[2026-06-01-iroh-tickets-security-model]]
