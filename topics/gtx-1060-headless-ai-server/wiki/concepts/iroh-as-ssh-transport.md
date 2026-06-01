---
title: "Iroh as SSH transport — ProxyCommand + allowlist gating"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-rfc-7301-alpn.md
  - raw/repos/2026-06-01-dumbpipe-binary.md
  - raw/repos/2026-06-01-iroh-ssh-rustonbsd.md
  - raw/repos/2026-06-01-iroh-router-protocolhandler-docs.md
  - raw/articles/2026-06-01-cloudflared-aws-ssm-proxycommand.md
  - raw/articles/2026-06-01-iroh-tickets-security-model.md
tags: [iroh, ssh, proxycommand, dumbpipe, allowlist, accesslimit]
---

# Iroh as SSH transport

Replace Tailscale-SSH / public-IP port-22 / cloudflared-access with an iroh QUIC tunnel. SSH itself stays unchanged.

## The pattern (universal across vendors)

Per OpenSSH `ssh_config(5)`:

> ProxyCommand "should read from its standard input and write to its standard output" and "should eventually connect to an sshd server."

Anything that produces a reliable ordered byte stream qualifies. Cloudflare, AWS SSM, and tailscale all use this:

| Vendor | ProxyCommand |
|--------|--------------|
| Cloudflare | `cloudflared access ssh --hostname %h` |
| AWS SSM | `aws ssm start-session --target %h --document-name AWS-StartSSHSession` |
| Tailscale | (built-in `tailscale ssh`) |
| **Iroh** | `dumbpipe connect <ticket>` or `iroh-ssh proxy %h` |

See [[cloudflared-aws-ssm-proxycommand]].

## Server side — dumbpipe

```bash
# On the GTX 1060 server:
IROH_SECRET=<persisted-secret> dumbpipe listen-tcp --host localhost:22

# Prints a ticket on stdout; share with allowed peers.
```

dumbpipe 0.38.0 wire constants:

```rust
pub const ALPN: &[u8] = b"DUMBPIPEV0";
pub const HANDSHAKE: [u8; 5] = *b"hello";
pub use iroh_tickets::endpoint::EndpointTicket;
```

dumbpipe builds an `Endpoint` directly (no Router) — single ALPN, single handler. See [[2026-06-01-dumbpipe-binary]].

## Client side

```
# ~/.ssh/config
Host server.iroh
    ProxyCommand dumbpipe connect <ticket>

# Then:
ssh user@server.iroh
```

SSH sees a stdio pipe; iroh handles NAT traversal, encryption, identity.

## The allowlist gap

**Out of the box, dumbpipe accepts any peer that completes handshake.** Same for `rustonbsd/iroh-ssh`:

> "anyone with the EndpointId can reach your SSH port; rely on standard SSH auth (keys/certs) for security"
> — iroh-ssh README

→ Defense-in-depth via SSH's pubkey auth, **not** an allowlist of EndpointIDs.

This is structurally weaker than Tailscale (which enforces tailnet membership) and weaker than cloudflared (which enforces IdP). For a homelab box exposed to the open internet via iroh, you want **both**:

1. SSH pubkey auth (existing)
2. **EndpointID allowlist BEFORE the SSH bytes flow**

## Production-hardened recipe

Use `iroh::protocol::AccessLimit<P>` to wrap the SSH-tunnel handler:

```rust
use iroh::protocol::{Router, AccessLimit};

let allowed: HashSet<EndpointId> = read_allowlist("/etc/iroh-ssh/allowed");

let ssh_handler = SshTunnelHandler::new("localhost:22");
let gated = AccessLimit::new(ssh_handler,
    move |id| allowed.contains(&id));

let router = Router::builder(endpoint)
    .accept(b"DUMBPIPEV0", gated)
    .spawn();
```

This rejects connections from unknown EndpointIDs **before** any TCP forwarding happens — meaningfully better than relying solely on SSH auth.

This is **NOT** what dumbpipe ships. To deploy, either:

1. Fork dumbpipe to use `Router` instead of bare `Endpoint::accept`
2. Write a thin replacement (40 lines) using iroh + `AccessLimit` + a `tokio::io::copy_bidirectional` to localhost:22
3. Submit a PR adding `--allowed-node-ids <file>` to dumbpipe upstream

Recipe (3) is the right long-term move; the iroh maintainer discussion #3168 explicitly tracks "auth as a missing piece" — see [[iroh-tickets-security-model]].

## The full SSH config UX

```
# ~/.ssh/config
Host *.iroh
    ProxyCommand iroh-ssh access %h
    User farmer
    IdentityFile ~/.ssh/id_ed25519

# Then:
ssh server.iroh           # → ProxyCommand resolves "server.iroh" to an EndpointID
ssh other-box.iroh        # → uses ~/.iroh-ssh/known_endpoints
```

`iroh-ssh access` resolves the magic hostname to an EndpointID (lookup in `~/.iroh-ssh/known_endpoints` keyed by hostname), establishes a QUIC stream, pipes stdio. Same UX shape as cloudflared.

## Logging caveats (shared with all ProxyCommand approaches)

Cannot see inside the SSH stream (TLS-in-TLS). Visibility:

| Visible | Not visible |
|---------|-------------|
| Connection establishment (peer EndpointID) | SSH command issued |
| Bytes-on-wire counts | Files transferred |
| Connection lifetime | Inner SSH multiplexed sessions |

For audit logging of SSH commands, you still need OpenSSH's `LogLevel VERBOSE` and process-level logging on the server.

## Use cases on the GTX 1060 server

| Scenario | Why iroh-ssh fits |
|----------|-------------------|
| SSH from phone over LTE without VPN | NAT traversal automatic |
| Friend admins your AI server | Hand them an EndpointID; allowlist; no router config |
| Replace Tailscale SSH | Decentralized, no control plane |
| Emergency access when home internet is broken | iroh's relay fallback works as long as outbound :443 works |
| Multi-hop SSH (jumpbox via iroh) | Standard SSH `ProxyJump` chains over iroh transport |

## Comparison to alternatives

| Solution | Allowlist | Setup | Decentralized | Cost |
|----------|-----------|-------|---------------|------|
| Public IP + sshd | iptables / fail2ban | router config | Yes | Free |
| Tailscale SSH | Tailnet ACL | account, install | No (control plane) | Free tier |
| cloudflared access | IdP gating | Cloudflare account | No | Free tier |
| **iroh-ssh + allowlist (this doc)** | EndpointID set | dumbpipe + SSH config | **Yes** | Free |
| **dumbpipe / rustonbsd-iroh-ssh** | None | dumbpipe + SSH config | Yes | Free |

## See also

- [[multi-alpn-router-pattern]] — host SSH alongside moq + blobs
- [[iroh-tickets-and-qr-pairing]] — how the EndpointID gets to clients
- [[cloudflared-aws-ssm-proxycommand]] — pattern reference
- [[iroh-application-patterns-2026-synthesis]]
