---
title: "Tailscale Serve, HTTPS certs & MagicDNS — internal-only service exposure"
source: https://tailscale.com/kb/1242/tailscale-serve
extra_sources:
  - https://tailscale.com/kb/1153/enabling-https
  - https://tailscale.com/kb/1081/magicdns
  - https://tailscale.com/kb/1019/subnets
  - https://tailscale.com/blog/docker-tailscale-guide
type: article
tags: [tailscale, vpn, tls, magicdns, reverse-proxy, subnet-router, docker]
confidence: high
ingested: 2026-07-23
summary: "Tailscale-first pattern for 'reachable only over VPN': Serve terminates HTTPS at the daemon (backend stays ws://localhost), auto Let's Encrypt cert on *.ts.net names, MagicDNS/split-DNS resolution, subnet router for datastores, Docker sidecar recipe."
---

# Tailscale: internal-only exposure (Serve + HTTPS + MagicDNS + subnets)

- **Tailscale Serve** (`tailscale serve 3000` / `tailscale serve localhost:3000`) proxies a local backend and publishes it at the device's MagicDNS name `https://<device>.<tailnet>.ts.net` — reachable **only inside the tailnet**, never public. The daemon **terminates HTTPS**, so the backend relay can stay plain `ws://localhost:3000` (no relay code change).
- **Serve vs Funnel** is the private/public switch: Serve = tailnet-only; Funnel = public internet. They can't share a port; last command wins. Keep `"AllowFunnel": false`.
- **HTTPS certs:** Tailscale provisions **real Let's Encrypt certs for `{machine}.{tailnet}.ts.net`** via DNS-01 (needs MagicDNS + HTTPS enabled). Browser/OS-trusted — no self-signed root to distribute. Certs expire every 90 days (Serve/Caddy auto-renew; `tailscale cert` is manual). Names land in public CT logs.
- **MagicDNS + Split DNS:** `.ts.net` names resolve on every enrolled device incl. mobile — `BUZZ_RELAY_URL=wss://buzz-relay.<tailnet>.ts.net` resolves identically on desktop/CLI/agents/phones. Split DNS routes a custom domain (e.g. `relay.internal`) to a private nameserver for non-`.ts.net` internal hostnames. Caveat: some macOS CLI tools (`host`,`nslookup`) bypass MagicDNS.
- **Subnet routers** (`tailscale set --advertise-routes=CIDR`): bridge a subnet into the tailnet so you reach **Postgres/Redis/managed RDS without installing Tailscale on them or exposing them publicly**. Routes need approval; clients use `--accept-routes`. ACL grants restrict which users/groups reach which subnets. `--snat-subnet-routes=false` preserves source IPs.
- **Docker sidecar pattern:** run a `tailscale` container, attach the app via `network_mode: service:ts-sidecar` (merged netns); app binds `127.0.0.1` only ⇒ inaccessible except through the Tailscale interface. State via `TS_STATE_DIR=/var/lib/tailscale` volume. Auth keys (90-day) vs OAuth clients (non-expiring, tag-owned). ~<20MB RAM per sidecar; one per service (port constraint).
- **ACLs apply to Serve** — device/user grants transitively gate the proxied backend.
- Gotcha to verify: Serve is an HTTP reverse proxy; confirm WebSocket upgrade passes through for the relay's long-lived NIP-01 socket.
