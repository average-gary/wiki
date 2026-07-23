---
title: Operations, Security & Maturity (The Skeptic's View)
type: concept
tags: [buzz, security, operations, maturity, backups, migrations, agents, auth, risk]
confidence: high
created: 2026-07-23
updated: 2026-07-23
---

# Operations, Security & Maturity

The clear-eyed view. buzz is genuinely interesting and worth piloting — but it is **early**, and
several sharp edges matter *before* you put a team on it.

## Maturity verdict: pre-1.0, honest about it

- Repo created **2026-03-06** (~4.5 months old as of 2026-07-23), Apache-2.0, ~6.3k stars.
- Latest release **~v0.4.23** (launched at v0.4.22); **no v1.0**; near-daily releases.
- **Only `main` is supported; no LTS branches.** Security fixes land on `main` first.
- The README's own maturity traffic-light: "works today" (relay, channels, DMs, media, audit,
  desktop, CLI, workflows) / "being wired up" (mobile, **workflow approval gates**, huddles) /
  "pending code" (web-of-trust, push). Explicit caveat: **"Please do not plan your compliance program
  around the [pending] column yet."**

**Bottom line:** credible for pilots and internal experimentation; **not** for regulated or
high-stakes production yet.

## Top operational burdens

1. **Upgrades are risky.** Issue **#2472**: shipped migration files were edited in place, breaking
   sqlx checksums; the newer relay **refuses to start** (`migration 1 … has been modified`) with "no
   forward path" short of hand-editing `_sqlx_migrations` or dropping the schema — confirmed against a
   real Cloud SQL DB. **Pin an image tag and test upgrades on a copy of prod data first.**
2. **A dated partition time-bomb.** Issue **#2396**: `events` partitions end at 2026-06 + a catch-all
   and nothing rolls them forward (recurs **2027-01-01**); **#2474** logs ERROR on a fresh schema.
3. **Backups are entirely DIY.** There is only a `./run.sh backup-hint` text checklist — no
   coordinated/consistent snapshot across the **4+ stateful stores** (Postgres, MinIO/S3, git volume,
   Typesense). You must quiesce and snapshot **the same maintenance window** yourself.
4. **Secrets live in a plaintext `.env`** with `CHANGE_ME` values; the bootstrap secret-generator is
   unfinished. The default image tracks `:main` — pin `:sha-<7>`/semver.
5. **No published resource-sizing, monitoring, or DR runbook** (a Prometheus port exists only in the
   dev compose). Ongoing production panics: **#2348** (reaction-ingest panic), **#2552**
   (`draft-create` rustls panic).

## Top security concerns

- **Authorization is deliberately coarse.** SECURITY.md: *"Channel membership is the only access
  control mechanism. There are no separate ACL lists or capability taxonomies."* Member ⇒ full
  read+write; there is **no RBAC / least-privilege within a channel** (issue **#2282**: capability
  plumbing exists but nothing consumes it — cosmetic today).
- **The audit log is tamper-EVIDENT, not tamper-RESISTANT.** Keyless SHA-256 hash chain; SECURITY.md
  admits *"an attacker with database write access can recompute the entire chain after editing"* —
  despite SOX/eDiscovery positioning.
- **Agent-keypair blast radius is the sharpest risk.** Agents are full members; their signing key is
  supplied via the **`BUZZ_PRIVATE_KEY` env var** (process environment, overriding the OS keyring),
  and they hold MCP/tool access. A shared-room **prompt-injection / persona-drift bug (#2287)** shows
  an agent can be steered or confused in multi-agent threads. A compromised or manipulated agent
  signs and acts as a first-class member with no finer containment than "which channels it's in."
- **Relay auth is sound where enabled, but hardening is opt-in.** NIP-42 (WS) + NIP-98 (REST) Schnorr
  auth are good. But closed-relay mode requires setting **all** of `BUZZ_REQUIRE_AUTH_TOKEN=true`,
  `BUZZ_REQUIRE_RELAY_MEMBERSHIP=true`, and `RELAY_OWNER_PUBKEY` — forget them and the relay is
  effectively open. **The relay does not enforce TLS** ("intentional… behind proxies").
- **Multi-tenant isolation is a draft spec, not shipping.** The TLA+/Tamarin multi-tenant relay
  design (per-community Postgres RLS, community-prefixed Redis) is a **proposed** design; today *"a
  Buzz relay process is the security boundary."* → **Run one relay per trust domain**, not many teams
  on one relay. (Per-owner community cap is hardcoded to 3, #2600.)

## The "only over VPN" caveat (the crux for this topic)

There is **no VPN/Tailscale guidance in the buzz docs** — a VPN posture is entirely the deployer's own
network choice layered on top. And critically:

> **A VPN is a network control, not an authentication control.**

Behind a VPN the relay is still reachable by every device/user/agent on that network. A stolen VPN
credential, a compromised endpoint, lateral movement, or a malicious insider walks straight past the
network perimeter — at which point the coarse channel-membership model and the env-var-resident agent
keys are all that stand between an attacker and read/write access.

**Defense in depth is mandatory even inside the VPN:** keep NIP-42/NIP-98 auth on, enable closed-relay
+ membership enforcement, terminate TLS, and treat agent keys as least-privilege secrets.

## See Also

- [What buzz Is](what-is-buzz.md)
- [VPN-Gating Patterns](vpn-gating-patterns.md)
- [Deployment & Topology](../reference/deployment-guide.md)
