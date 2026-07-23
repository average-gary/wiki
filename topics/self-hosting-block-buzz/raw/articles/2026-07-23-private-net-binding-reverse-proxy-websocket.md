---
title: "Private-network binding, reverse proxy & WebSocket-over-TLS hardening"
source: https://nginx.org/en/docs/http/websocket.html
extra_sources:
  - https://websocket.org/guides/infrastructure/nginx/
  - https://lumadock.com/tutorials/n8n-private-networking-vps
  - https://letsencrypt.org/docs/certificates-for-localhost/
type: article
tags: [reverse-proxy, nginx, websocket, wss, tls, private-network, postgres, redis, hardening]
confidence: high
ingested: 2026-07-23
summary: "The DIY hardening layer: bind services to private/loopback (never 0.0.0.0), Docker internal:true networks, UFW default-deny; nginx/Caddy WSS upgrade headers + timeouts; internal-CA vs self-signed trust nightmare for internal hostnames."
---

# Private binding + reverse proxy + WSS hardening

## Bind to private, never expose data stores (lumadock; medium-confidence tutorial, corroborated by official patterns)
- Three-layer defense-in-depth: private bind addresses + Docker `internal: true` networks + host firewall.
- Postgres: `listen_addresses = '127.0.0.1,<private-ip>'` + `pg_hba.conf host ... <private-cidr> scram-sha-256`. Redis: `bind 127.0.0.1 <private-ip>`, `protected-mode yes`, `requirepass`. **Never `0.0.0.0`.**
- Docker: only the reverse proxy joins both `public` and `private` networks; app + DB + Redis on `private` only (no published ports ⇒ no host mapping to the public NIC).
- UFW: allow only 80/443 + SSH-from-admin-IP; DB ports only `from <private-cidr>`. (Real-world: a Redis on `0.0.0.0` with no password was attacked within a week.)
- Verify with an external scan (`nmap`/`ss -tlnp`) that no service/DB port answers on the public interface.

## WebSocket over a reverse proxy (nginx official + websocket.org)
- `Upgrade` is a **hop-by-hop header not forwarded by default** — a naive proxy silently breaks the WS handshake.
- Fix (HTTP/1.1 + explicit headers): `proxy_http_version 1.1;` `proxy_set_header Upgrade $http_upgrade;` `proxy_set_header Connection "upgrade";` (use `map $http_upgrade $connection_upgrade` for mixed traffic).
- Default `proxy_read_timeout 60s` kills idle sockets — raise it (buzz keeps one long-lived NIP-01 socket) or use WS pings. `proxy_buffering off;`.
- Proxy terminates TLS: clients use `wss://`, backend stays `ws://`. Pin `ssl_protocols TLSv1.2 TLSv1.3`; redirect :80→:443.

## TLS for internal hostnames (Let's Encrypt docs)
- Public CAs **cannot issue for internal-only hostnames** ("nobody uniquely owns it").
- Self-signed = "trust distribution nightmare": every browser/WS client/mobile app/agent host must install and trust the root, one device at a time.
- Scalable alternatives: an **internal CA** whose root is pushed to every device, OR let the VPN issue the cert (Tailscale-issued `.ts.net` cert avoids the whole problem).
