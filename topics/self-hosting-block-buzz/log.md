# Log — Self-Hosting block/buzz

## [2026-07-23] init | topic wiki created

New hub topic for researching how to self-host [block/buzz](https://github.com/block/buzz)
(a self-hosted Nostr-relay "hive mind" workspace for humans + AI agents) for a team, where
the deployment's data is reachable **only over a VPN**. Employer-agnostic per hub conventions:
buzz internals + generic VPN-gated-service deployment patterns; no team/employer-specific config.

## [2026-07-23] research (question mode) | "run block/buzz for a team, data only over VPN" → 11 sources ingested, 6 articles compiled + 1 playbook

5 parallel agents, one per sub-question (what-is-buzz / self-host / VPN-gating patterns / clients+agents
over VPN / ops-security-maturity). Heavy primary-source grounding: buzz repo files cross-verified by 2–3
agents each. Compiled 5 concept articles + 1 reference (Deployment & Topology) + the Team-over-VPN Playbook.

Key verdict: buzz's prod compose already publishes ONLY relay:3000 (datastores internal-only), so "VPN-only"
= don't expose that port + give clients a tunnel path with working TLS. Connecting is one env var
(BUZZ_RELAY_URL); NIP-01 has no discovery, so the VPN problem is reachability+TLS. Dominant gotcha =
WSS-for-internal-hostname → Tailscale-issued cert is the clean fix (backend stays ws://), else internal CA
+ reverse proxy (WS Upgrade headers + long read timeout). Recommended: Tailscale Serve + MagicDNS + ACLs;
WireGuard if no 3rd-party plane; co-locate agents (stdio MCP). ⚠️ VPN ≠ auth (keep closed-relay + NIP-42/98
on); ⚠️ pre-1.0 maturity — DIY backups, upgrade can brick a long-lived DB (#2472), partition time-bomb
2027-01-01 (#2396), membership-only authz. Fine for a pilot, not regulated prod. Progress score ~90 (strong).
Resolved a cross-agent contradiction: multi-tenant per-community RLS is a DRAFT spec, not shipping — today
the relay PROCESS is the security boundary (run one relay per trust domain).
