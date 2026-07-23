---
title: Self-Hosting block/buzz
type: topic-index
created: 2026-07-23
updated: 2026-07-23
tags: [buzz, block, nostr, self-hosting, vpn, ai-agents, rust, docker, relay]
sources: 11
articles: 6
---

# Self-Hosting block/buzz

Running [**block/buzz**](https://github.com/block/buzz) — a self-hostable "hive mind" workspace
where humans and AI agents collaborate in shared rooms (a Nostr NIP-01 relay at its core) — for a
team, with the deployment's **data reachable only over a VPN**.

## Scope

- What buzz is and how it is architected (Rust relay + Postgres/Redis/S3; agents as first-class members).
- Self-hosting / deployment: Docker Compose topology, dependencies, configuration, operations.
- Operating a service whose data is reachable **only over a VPN** — as *generic, employer-agnostic patterns*.

> Employer-specific VPN topology, internal DNS, CIDRs, account IDs, and team names do **not** belong
> here — see a repo-local `.wiki/` per hub conventions.

## Start here

- **[Team-over-VPN Playbook](output/playbook-self-hosting-block-buzz-2026-07-23.md)** — the actionable
  answer: decision table + 6-step build (stand up → lock down → VPN track → clients → agents → ops) +
  recommended stack.

## Concepts

- [What buzz Is & How It's Architected](concepts/what-is-buzz.md) — the Nostr-relay-as-workspace model, the crate/dependency stack, clients, agents-as-members, and why the topology is VPN-friendly.
- [Data Model & Agents](concepts/data-model-and-agents.md) — the custom NIPs (agent identity/auth/metrics, channel windowing), git-on-object-storage, and the ACP/MCP + MeshLLM runtime.
- [VPN-Gating Patterns](concepts/vpn-gating-patterns.md) — generic patterns for "reachable only over VPN": Tailscale-first, WireGuard-DIY, private reverse proxy, plus the hardening checklist that actually enforces it.
- [Connecting Clients & Agents Over a VPN](concepts/connecting-over-vpn.md) — repointing `BUZZ_RELAY_URL`, the WSS-for-internal-hostname problem, private DNS, and the agent/MCP reachability gotcha.
- [Operations, Security & Maturity](concepts/operations-security-maturity.md) — the skeptic's view: pre-1.0 maturity, DIY backups, the upgrade-bricking migration bug, membership-only authz, and "VPN ≠ auth."

## Reference

- [Deployment & Topology](reference/deployment-guide.md) — the concrete facts: 5-service compose stack, pinned images, ports, volumes, `.env` keys, `run.sh` ops, and where the VPN gate goes.

## Outputs

- **[Team-over-VPN Playbook](output/playbook-self-hosting-block-buzz-2026-07-23.md)** — *active*.

## Key findings

- **The topology is already VPN-friendly.** buzz's production compose publishes **only the relay port
  (3000)**; Postgres/Redis/MinIO are internal-only. "VPN-only" reduces to not exposing that one port
  and giving clients a tunnel path to it with working TLS.
- **Connecting is one env var.** NIP-01 has no discovery/handshake — every client (desktop, mobile,
  CLI, agent) just points `BUZZ_RELAY_URL` at the internal hostname. The VPN problem is *reachability
  + TLS*, not protocol.
- **The dominant technical gotcha is WSS/TLS for an internal hostname.** Public CAs can't issue for
  internal names; self-signed is a trust-distribution nightmare. Cleanest fix: let **Tailscale issue
  the cert** (auto Let's Encrypt on `.ts.net`, backend stays plain `ws://`), else an internal CA +
  reverse proxy (remember the WebSocket `Upgrade` headers + long read timeout).
- **Recommended stack:** Tailscale (Serve + MagicDNS + ACLs) in front of the relay; WireGuard if no
  third-party coordination plane is allowed; agents **co-located** inside the private net (stdio MCP).
- **⚠️ A VPN is a network control, not authentication.** Keep buzz's closed-relay + NIP-42/NIP-98 auth
  ON even inside the tunnel; treat agent keys (env-var `BUZZ_PRIVATE_KEY`) as least-privilege secrets.
- **⚠️ Maturity:** ~4.5-month-old, pre-1.0 (v0.4.x), only `main` supported, **DIY backups**, an
  upgrade path that can **brick a long-lived DB** (#2472), a partition time-bomb (2027-01-01, #2396),
  and **channel-membership is the only access control**. Fine for a **pilot**; not for regulated
  production yet.

## Sources

See [raw/_index.md](raw/_index.md) — **11 sources** (repos 5, articles 5, data 1), consolidating
buzz repo files (README, deploy/compose, SECURITY.md, multi-tenant spec, NIPs, open issues) and
Tailscale/WireGuard/nginx/Nostr/Let's Encrypt official docs + SiliconAngle launch coverage.
