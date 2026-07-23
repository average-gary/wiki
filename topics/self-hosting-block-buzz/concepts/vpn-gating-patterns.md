---
title: VPN-Gating Patterns — Making a Service Reachable Only Over a VPN
type: concept
tags: [vpn, tailscale, wireguard, reverse-proxy, private-dns, hardening, generic-patterns]
confidence: high
created: 2026-07-23
updated: 2026-07-23
---

# VPN-Gating Patterns

**Generic, employer-agnostic patterns** for making a self-hosted service (and its data) reachable
*only* over a VPN — never on the public internet. buzz-specific application is in the
[Deployment Guide](../reference/deployment-guide.md); this article is the reusable substrate.

> ⚠️ **A VPN is a network control, not an authentication control.** Everything here restricts
> *who can reach the port*. It does not replace app-level auth. See
> [Operations, Security & Maturity](operations-security-maturity.md) for why defense-in-depth is
> mandatory even inside the tunnel.

## Pattern A — Tailscale-first (simplest)

Run the service with a **Tailscale sidecar** (`network_mode: service:ts-sidecar`), bind the app to
`127.0.0.1` only, and expose it with **`tailscale serve`** at its `*.ts.net` MagicDNS name.

- **TLS handled for you** — Tailscale provisions a real, auto-renewing Let's Encrypt cert for the
  `{machine}.{tailnet}.ts.net` name; the daemon terminates HTTPS while the backend stays plaintext.
  This *solves the internal-hostname cert problem for free* (see [WSS/TLS](connecting-over-vpn.md)).
- **Serve = tailnet-only; Funnel = public.** Keep `"AllowFunnel": false`.
- **MagicDNS** gives split-horizon resolution that only works inside the tailnet, on every device
  including mobile.
- **Datastores** that can't run the Tailscale client sit behind a **subnet router** — advertise the
  DB subnet's CIDR so tailnet members reach Postgres/Redis without installing anything on them or
  exposing them publicly. ACL grants limit *which* users/groups reach that subnet.
- **Tradeoff:** dependency on Tailscale's coordination plane and one sidecar per service; near-zero
  cert/DNS/firewall work.

## Pattern B — WireGuard DIY (most control, no third party)

Stand up a WireGuard interface (`wg0`); **Cryptokey Routing** means only peers whose public keys are
configured can reach anything — enforced cryptographically, no PKI, no certs.

- **`AllowedIPs` is dual-purpose:** outbound a routing table, inbound an **ACL** (source IP must
  match or the packet is dropped). Server-side per-peer `AllowedIPs` = "what source IPs may this
  client claim"; a `/32` pins a peer to one host, a `/24` scopes it to the internal subnet.
- **Split tunnel** (`AllowedIPs = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16`) routes only internal
  ranges; full tunnel (`0.0.0.0/0`) routes everything (and breaks LAN/printer access).
- Bind the service + datastores to the `wg0` interface IP (or `127.0.0.1` behind a proxy on `wg0`).
- **Tradeoff:** you own key distribution, DNS, and certs. `AllowedIPs` mistakes (overlaps,
  source-IP mismatch) **fail silently** — the #1 "connected but nothing works" cause.

## Pattern C — private reverse proxy on the VPN network (best for TLS/WSS + many services)

Put **nginx / Caddy / Traefik** listening *only* on the VPN/private interface, terminating TLS for a
private DNS name and proxying to backends over an internal Docker network (`internal: true`, no
published ports). This is where the [WebSocket specifics](connecting-over-vpn.md) live. Combine with
A or B for transport. Caddy or Tailscale Serve can supply the cert. Tradeoff: one more moving part,
but it centralizes TLS, WSS upgrade handling, and multi-service routing.

## Hardening that actually enforces "data only over VPN" (all patterns)

This is the checklist that turns "I put it behind a VPN" into an enforced guarantee:

1. **Bind to private/loopback/VPN interface — never `0.0.0.0`.** Postgres
   `listen_addresses='127.0.0.1,<private-ip>'`; Redis `bind 127.0.0.1 <private-ip>` +
   `protected-mode yes` + `requirepass`.
2. **In Docker, don't publish DB ports.** Keep datastores on an `internal: true` network so only the
   proxy/VPN reaches them. (buzz already does this — only relay:3000 is published.)
3. **Default-deny public ingress** at the firewall (ufw/nftables/security groups): allow only the VPN
   port (e.g. WireGuard UDP 51820, or nothing at all for Tailscale's NAT-traversed connections) and
   admin SSH from a fixed IP; scope DB ports to the private CIDR.
4. **Split-horizon / private DNS** so the internal hostname resolves *only* inside the tunnel
   (MagicDNS, `.internal`, or a split resolver).
5. **Verify externally.** `nmap` / `ss -tlnp` from outside to confirm no service or DB port answers
   on the public interface. A real-world cautionary tale: a Redis left on `0.0.0.0` with no password
   was scanned and attacked within a week.

## Choosing

| If you want… | Use |
|---|---|
| Least effort, TLS + DNS solved, mixed desktop/mobile/agent clients | **A (Tailscale)** |
| No third-party dependency, full control, willing to run your own DNS/CA | **B (WireGuard)** |
| Central TLS/WSS termination and many services behind one name | **C (reverse proxy)** + A or B |

## See Also

- [Connecting Clients & Agents Over a VPN](connecting-over-vpn.md)
- [Deployment & Topology](../reference/deployment-guide.md)
- [Operations, Security & Maturity](operations-security-maturity.md)
