---
title: "iroh PR #3157 — feat(iroh)!: allow for limiting incoming connections on the router (MERGED)"
source: https://github.com/n0-computer/iroh/pull/3157
type: repo
tags: [iroh, accesslimit, pr, merged, allowlist, protocolhandler]
date: 2026-06-01
publication_date: 2025-03-14
quality: 5
confidence: high
agent: technical
summary: "MERGED 2025-03-14. Author: dignifiedquire. This is the PR that landed AccessLimit and the breaking change to ProtocolHandler::accept (now takes Connection rather than Connecting). PR notes call out the API/example tradeoff explicitly: 'The new limiter could also just be part of the test code/an example, instead of giving users an API, unclear to me' — confirms upstream considers AccessLimit a minimal primitive."
---

# iroh PR #3157 — AccessLimit landed (merged 2025-03-14)

**Critical correction to prior wiki research**: the previous research session implied PR #3157 was an open WIP for "auth-wrapper for protocols." It was actually:

- **MERGED 2025-03-14**
- The PR that *introduced* `AccessLimit<P>`
- A minimal primitive — explicitly minimal, not a full auth layer

## What landed

```rust
pub struct AccessLimit<P: ProtocolHandler + Clone> { /* private */ }

impl<P: ProtocolHandler + Clone> AccessLimit<P> {
    pub fn new<F>(proto: P, limiter: F) -> Self
    where F: Fn(EndpointId) -> bool + Send + Sync + 'static
}
```

**Limitation**: the `F` closure only sees the `EndpointId`. It does NOT see:

- Token payloads from a separate auth handshake
- Connection-level metadata
- ALPN being negotiated

→ For a token-bearing wrapper, you need a **separate auth-handshake protocol** that runs before AccessLimit's predicate evaluates. The pattern is in iroh's own `auth-hook.rs` example (see [[2026-06-01-iroh-auth-hook-example]]).

## Companion change

PR #3157 also introduced the breaking change: `ProtocolHandler::accept` now takes `Connection` rather than `Connecting`. Older docs (and any pre-2025-03 code) need updating.

## Author note (verbatim)

> "The new limiter could also just be part of the test code/an example, instead of giving users an API, unclear to me"
> — dignifiedquire, PR #3157 description

→ **Upstream considers AccessLimit a minimal primitive.** Anything richer (token-bearing auth handshake, capability validation) is on the application to build.

## What the previous wiki research got wrong

Prior research note: "PR #3157 is the open work-in-progress to wrap protocols with a generic auth layer."

→ **Status: MERGED, NOT open.** And it's an EndpointID predicate, not a generic auth layer. Updating [[iroh-tickets-and-qr-pairing]] to correct.

## See also

- [[2026-06-01-iroh-auth-hook-example]] — the canonical token-handshake pattern
- [[2026-06-01-iroh-pr-4205-relay-auth-tokens]] — the relay-tier auth that landed in 2026-05
