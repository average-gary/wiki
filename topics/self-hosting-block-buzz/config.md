---
title: Config — Self-Hosting block/buzz
type: config
created: 2026-07-23
---

# Config

- **Slug:** self-hosting-block-buzz
- **Sensitivity:** public (publishable hub topic)
- **Subject:** [block/buzz](https://github.com/block/buzz) — self-hosted "hive mind" workspace (Nostr relay) for humans + AI agents
- **Scope (in):** what buzz is + architecture; self-hosting / deployment (Docker Compose, the Rust relay, Postgres/Redis/S3 dependencies); operating a service whose data is reachable **only over a VPN** — as *generic, employer-agnostic* deployment patterns (WireGuard/Tailscale/OpenVPN, split-tunnel, reverse-proxy + private DNS, WebSocket-over-VPN, agent/CLI access over the tunnel).
- **Scope (out):** any specific employer's VPN topology, internal DNS, CIDRs, account IDs, or team names. Those belong in a repo-local `.wiki/` per hub conventions, not here.
