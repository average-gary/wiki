---
title: Connecting Clients & Agents Over a VPN
type: concept
tags: [buzz, vpn, websocket, wss, tls, magicdns, mcp, agents, mobile, clients]
confidence: high
created: 2026-07-23
updated: 2026-07-23
---

# Connecting Clients & Agents Over a VPN

How buzz's desktop, mobile, CLI, and **agent** clients reach the relay when it lives on a VPN — and
the two things that actually break (WSS-for-an-internal-hostname, and agent network reachability).

## The connection model is trivial — it's one env var

Every buzz client is a plain Nostr relay client. Per NIP-01, a relay just "exposes a WebSocket
endpoint"; the client opens **one long-lived WebSocket** and multiplexes subscriptions. There is **no
discovery or handshake beyond the WebSocket upgrade** — so putting clients "on a VPN" is fundamentally
just **repointing `BUZZ_RELAY_URL`** at an internal, tunnel-only hostname:

```
BUZZ_RELAY_URL=wss://buzz-relay.<tailnet>.ts.net      # or wss://relay.internal
```

The VPN problem reduces to **reachability + TLS**, not protocol.

| Client | How it connects over the VPN |
|--------|------------------------------|
| **Desktop** (Tauri) | Set `BUZZ_RELAY_URL` (or switch relay in-app) to the internal URL; connects once the tunnel is up. |
| **CLI** (`buzz-cli`) | `BUZZ_RELAY_URL` + `BUZZ_PRIVATE_KEY`. |
| **Mobile** (Flutter) | Same URL, but depends on a **mobile VPN client** (Tailscale/WireGuard app) staying connected — the weakest link. Also still "being wired up" in the repo. |
| **Agents** (ACP/MCP) | Same as any client at the network layer (WS + REST) — but see the MCP subtlety below. |

## The dominant gotcha: WSS/TLS for an internal hostname

Browsers and most WebSocket clients demand a **trusted** cert, but:

- **Public CAs cannot issue for internal-only hostnames** ("nobody uniquely owns it").
- **Self-signed** = a trust-distribution nightmare: every desktop, phone, container, and agent host
  must install and trust the root, one device at a time.

Two clean ways out:

1. **Let the VPN issue the cert (recommended).** Tailscale Serve terminates HTTPS at the daemon and
   exposes `wss://buzz-relay.<tailnet>.ts.net` with a **real, auto-renewing Let's Encrypt cert**,
   while the backend relay stays plain `ws://localhost:3000` — no relay code change, no self-signed
   trust.
2. **Internal CA + reverse proxy.** Run your own CA, push the root to every device, and terminate TLS
   at nginx/Caddy. If you do this, you **must** forward the hop-by-hop WebSocket headers or the socket
   connects and immediately drops:
   ```nginx
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade";
   proxy_read_timeout 7d;      # buzz keeps ONE long-lived NIP-01 socket; default 60s kills it
   proxy_buffering off;
   ```

## Private DNS

The internal relay hostname must resolve **only inside the tunnel**:

- **MagicDNS** — `*.ts.net` names resolve on every enrolled device (incl. mobile) automatically.
- **Split DNS** — route a custom domain (e.g. `relay.internal`) to a private nameserver inside the
  tunnel. Caveat: some macOS CLI tools (`host`, `nslookup`) bypass MagicDNS — a debugging trap.

## Don't forget the media layer

buzz media/attachments live on a **separate Blossom/S3 endpoint** (`BUZZ_MEDIA_BASE_URL`). It must
*independently* be reachable/resolvable over the VPN, or **attachments fail even when chat works**.

## The agent-specific gotcha (biggest for AI workloads)

An agent is the same as a human client on the network — but with **no human to click "switch relay"**
when something is unreachable. Two things determine robustness:

- **MCP transport.** *stdio* MCP (the client launches the MCP server as a local subprocess over
  stdin/stdout) needs **no network at all**. *Streamable HTTP / SSE* MCP is an HTTP endpoint that
  **must be reachable over the tunnel**.
- **Where the agent runs.** An agent running as a **headless service inside the private network**
  (stdio MCP, co-located with the relay) avoids VPN reachability entirely. An agent reaching *across*
  the tunnel makes its VPN session, MagicDNS resolution, and the relay/MCP endpoints hard network
  dependencies — and if any is down it **silently** can't reach the relay.

**Recommendation:** co-locate agents inside the private network with the relay wherever possible.

## See Also

- [VPN-Gating Patterns](vpn-gating-patterns.md)
- [Data Model & Agents](data-model-and-agents.md)
- [Deployment & Topology](../reference/deployment-guide.md)
