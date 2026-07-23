---
title: "WireGuard: Cryptokey Routing, AllowedIPs, split-tunnel (private by construction)"
source: https://www.wireguard.com/
extra_sources:
  - https://defguard.net/blog/allowedips-explained/
type: article
tags: [wireguard, vpn, allowedips, split-tunnel, cryptokey-routing, access-control]
confidence: high
ingested: 2026-07-23
summary: "WireGuard-DIY pattern: public keys bound to allowed tunnel IPs = cryptographic authorization with no PKI/firewall; AllowedIPs is routing (outbound) + ACL (inbound); split vs full tunnel; per-peer /32 pinning."
---

# WireGuard: private by construction

- **Cryptokey Routing:** public keys are bound to a list of allowed tunnel IPs — cryptographic identity *is* the network authorization. Unauthenticated packets are dropped, so isolation is enforced cryptographically **without firewall rules or PKI/certs** (peers exchanged out-of-band, SSH-style). Behaves as a normal virtual interface (`wg0`).
- **AllowedIPs has a dual role:** outbound it is a routing table (which dest IPs go through the peer); inbound it is an **ACL** (source IP must match or the packet is dropped).
- **Split tunnel** (`AllowedIPs = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16`) routes only internal ranges through the tunnel; **full tunnel** (`0.0.0.0/0, ::/0`) routes everything (breaks LAN/printer/NAS access).
- Server-side per-client `AllowedIPs` answers "what source IPs may this client claim"; a `/32` (e.g. `10.0.0.50/32`) pins a peer to exactly one internal host — a `/24` scopes it to the internal service subnet.
- **Pitfalls:** overlapping CIDRs cause routing ambiguity; source-IP mismatch **silently drops** packets (top cause of "connected but nothing works").
