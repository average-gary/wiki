---
title: "Playbook: Running block/buzz for a Team with VPN-Only Data Access"
type: playbook
status: active
tags: [buzz, self-hosting, vpn, tailscale, wireguard, deployment, agents, playbook]
confidence: high
created: 2026-07-23
updated: 2026-07-23
---

# Playbook: Running block/buzz for a Team, Data Reachable Only Over the VPN

**The question:** *How do I run [block/buzz](https://github.com/block/buzz) for my team so that
the deployment — the relay and all its data — is accessible only over the VPN?*

**The short answer:** buzz's production Docker Compose stack already publishes **only the relay
port (3000)** to the host; Postgres, Redis, and MinIO are internal-only. So "VPN-only" reduces to
**(a)** not exposing that one relay port to the public internet, **(b)** giving clients a way to
reach it over the tunnel with working TLS, and **(c)** — because a VPN is *not* authentication —
keeping buzz's own auth turned on. The lowest-effort path is **Tailscale in front of the relay**
(it solves TLS certs and internal DNS for free); the no-third-party path is **WireGuard**.

> ⚠️ **Maturity reality check first.** buzz is ~4.5 months old, pre-1.0 (v0.4.x), only `main` is
> supported, backups are DIY, one upgrade path can brick a long-lived DB (#2472), and authorization
> is just "channel membership." It's great for a **pilot**; don't build a compliance program on it
> yet. See [Operations, Security & Maturity](../concepts/operations-security-maturity.md).

---

## Decisions to make before you start

| Decision | Options | Recommendation |
|----------|---------|----------------|
| **VPN technology** | Tailscale · WireGuard · OpenVPN/IPsec · existing corp VPN | **Tailscale** if you can (free TLS + DNS); **WireGuard** if no 3rd-party dependency allowed |
| **Where the relay runs** | Cloud VM · on-prem box · k8s | A single small VM/box is fine for a team pilot |
| **Who's a member** | open relay · closed relay | **Closed** (`REQUIRE_AUTH_TOKEN` + `REQUIRE_RELAY_MEMBERSHIP` + owner pubkey) |
| **Where agents run** | co-located inside private net · across the tunnel | **Co-locate** with the relay (stdio MCP, no tunnel dependency) |
| **TLS** | Tailscale-issued · internal CA · Caddy/Let's Encrypt | **Tailscale-issued** cert, else internal CA |

---

## Step 1 — Stand up buzz (production compose)

You do **not** build from source. Pull the prebuilt image and use the `deploy/compose/` bundle.

```bash
# On the host (needs Docker + Docker Compose v2.24.4+)
git clone https://github.com/block/buzz
cd buzz/deploy/compose
cp .env.example .env
```

Edit `.env` — set every `CHANGE_ME`:

```dotenv
# Point clients at your INTERNAL hostname (see Step 3 for how it resolves)
BUZZ_DOMAIN=buzz.internal
RELAY_URL=wss://buzz-relay.<your-tailnet>.ts.net     # or wss://relay.internal
BUZZ_MEDIA_BASE_URL=https://buzz-relay.<your-tailnet>.ts.net/media

# Secrets — generate real values; keep the two "stable" ones stable forever
POSTGRES_PASSWORD=...            REDIS_PASSWORD=...
BUZZ_S3_ACCESS_KEY=...           BUZZ_S3_SECRET_KEY=...
BUZZ_S3_BUCKET=buzz-media        TYPESENSE_API_KEY=...
RELAY_OWNER_PUBKEY=<your 64-hex nostr pubkey>     # NOTE: not BUZZ_-prefixed
BUZZ_RELAY_PRIVATE_KEY=<64-hex>                    # MUST stay stable across restarts
BUZZ_GIT_HOOK_HMAC_SECRET=<random>                 # MUST stay stable across restarts

# CLOSED RELAY — set all three or the relay is effectively open
BUZZ_REQUIRE_AUTH_TOKEN=true
BUZZ_REQUIRE_RELAY_MEMBERSHIP=true
# RELAY_OWNER_PUBKEY already set above

# Pin the image (default tracks :main)
BUZZ_IMAGE=ghcr.io/block/buzz:sha-<7chars>
```

Start it:

```bash
./run.sh config          # validate
./run.sh start           # docker compose up -d --wait
curl -fsS http://127.0.0.1:3000/_liveness   # expect OK
./run.sh status
```

This brings up relay + `postgres:17` + `redis:7` + MinIO (+ init). **Only port 3000 is published**;
the datastores stay on the internal Docker network. Full details:
[Deployment & Topology](../reference/deployment-guide.md).

---

## Step 2 — Make sure the data really can't leak to the internet

The compose stack is already good (datastores unpublished), but *verify and lock the last mile*:

1. **Don't publish 3000 on the public NIC.** Either bind it to the VPN/loopback interface, or leave
   it published only to localhost and put the VPN/proxy in front (Step 3). In `.env`,
   `BUZZ_HTTP_PORT` maps to the host — front it, don't expose it.
2. **Firewall default-deny.** Allow only the VPN (e.g. WireGuard `udp/51820`, or *nothing* inbound
   for Tailscale's NAT-traversed connections) and admin SSH from a fixed IP.
3. **Confirm datastores never bind `0.0.0.0`.** They don't in the stock compose (no published ports),
   but if you customize, keep Postgres/Redis/MinIO on the internal network only.
4. **Verify from outside.** From a host *off* the VPN:
   ```bash
   nmap -Pn -p 3000,5432,6379,9000 <public-ip>   # expect all closed/filtered
   ```
   If anything answers, fix it before onboarding anyone. (Real-world: an exposed passwordless Redis
   gets attacked within a week.)

See the full checklist in [VPN-Gating Patterns](../concepts/vpn-gating-patterns.md).

---

## Step 3 — Put the relay behind the VPN (pick a track)

### Track A — Tailscale (recommended: TLS + DNS solved for free)

1. Install Tailscale on the relay host (or run it as a **sidecar container** with
   `network_mode: service:ts-sidecar`, app bound to `127.0.0.1`).
2. Enable **MagicDNS** and **HTTPS certificates** in the tailnet admin console.
3. Expose the relay tailnet-only:
   ```bash
   tailscale serve 3000       # publishes https://buzz-relay.<tailnet>.ts.net, TLS auto-issued
   # keep Funnel OFF (tailnet-only): AllowFunnel: false
   ```
   The daemon terminates HTTPS and issues a **real, auto-renewing Let's Encrypt cert** for the
   `.ts.net` name — so clients get `wss://` with a trusted cert and the backend relay stays plain
   `ws://localhost:3000`. No self-signed trust to distribute.
4. Lock down access with **tailnet ACLs** (which users/devices may reach the relay).
5. If your datastores live on a separate box, use a **subnet router** to reach them over the tailnet
   without exposing them.

`RELAY_URL` / clients' `BUZZ_RELAY_URL` = `wss://buzz-relay.<tailnet>.ts.net`. MagicDNS resolves it on
every enrolled device including phones.

### Track B — WireGuard (no third-party dependency)

1. Stand up a WireGuard interface (`wg0`); add each teammate/device as a peer (public keys exchanged
   out-of-band). Cryptokey Routing means only configured peers can reach anything.
2. **Split-tunnel** client configs so only the internal subnet routes through the VPN:
   ```ini
   [Peer]
   AllowedIPs = 10.0.0.0/24        # the buzz/internal subnet only
   ```
   Server-side, scope each peer's `AllowedIPs` (a `/32` pins a peer to one host).
3. Bind the relay to the `wg0` interface IP (or `127.0.0.1` behind a reverse proxy on `wg0`).
4. **TLS is now on you.** Either run an **internal CA** and push the root to every device, or front
   the relay with **Caddy/nginx** terminating TLS. If you use nginx, you *must* pass the WebSocket
   upgrade headers or the socket drops:
   ```nginx
   location / {
     proxy_pass http://127.0.0.1:3000;
     proxy_http_version 1.1;
     proxy_set_header Upgrade $http_upgrade;
     proxy_set_header Connection "upgrade";
     proxy_read_timeout 7d;        # buzz keeps ONE long-lived socket; default 60s kills it
     proxy_buffering off;
   }
   ```
5. **Private DNS:** run a split-horizon resolver so `relay.internal` resolves only inside the tunnel.

Details + tradeoffs: [VPN-Gating Patterns](../concepts/vpn-gating-patterns.md) and
[Connecting Clients & Agents Over a VPN](../concepts/connecting-over-vpn.md).

---

## Step 4 — Connect the team's clients

For every client, connecting is just repointing one env var (NIP-01 adds no discovery/handshake):

```bash
export BUZZ_RELAY_URL=wss://buzz-relay.<tailnet>.ts.net   # or wss://relay.internal
export BUZZ_PRIVATE_KEY=<per-user 64-hex nsec>            # CLI/agents
```

- **Desktop (Tauri):** set `BUZZ_RELAY_URL` before launch, or switch relay in-app. Teammates need the
  VPN client connected.
- **Mobile (Flutter):** same URL, but it's the **weakest link** — depends on the mobile VPN app
  (Tailscale/WireGuard) staying connected (consider always-on / per-app VPN), *and* mobile is still
  "being wired up" upstream.
- **CLI (`buzz-cli`):** `BUZZ_RELAY_URL` + `BUZZ_PRIVATE_KEY`.
- **Media:** make sure `BUZZ_MEDIA_BASE_URL` also resolves over the VPN, or attachments fail even when
  chat works.

Add members to the closed relay: `./run.sh add-member <pubkey>` (also `list-members` / `remove-member`).

---

## Step 5 — Agents (the AI-first part, and its gotcha)

Agents are first-class members with their own keypairs (each tied to a human owner via a NIP-OA
attestation). Two rules keep them robust and contained:

1. **Co-locate agents inside the private network with the relay.** Use **stdio MCP** (the agent
   launches its MCP server as a local subprocess — *no network*), so the agent never depends on
   reaching the relay/MCP endpoint *across* the tunnel. An agent that reaches across the tunnel
   **silently** fails if its VPN session, DNS, or an HTTP/SSE MCP endpoint is down — and there's no
   human to click "reconnect."
2. **Treat agent keys as least-privilege secrets.** The agent's signing key is supplied via
   `BUZZ_PRIVATE_KEY` (an env var that overrides the OS keyring). An agent is a full read/write member
   of every channel it's in — there is *no* finer-grained permission (channel membership is the only
   ACL). Put each agent only in the channels it needs; be aware of the persona-drift bug (#2287) in
   multi-agent threads.

---

## Step 6 — Day-2 operations (do these before you rely on it)

- **Pin the image** (`BUZZ_IMAGE=ghcr.io/block/buzz:sha-<7>`) — never run `:main` in prod.
- **Test every upgrade on a copy of prod data first.** Issue #2472 shows an upgrade can refuse to
  start on a long-lived DB (migration-checksum mismatch, "no forward path"). `./run.sh upgrade` = pull
  + restart; migrations run at container init (`BUZZ_AUTO_MIGRATE=true`).
- **Back up yourself** (there is no coordinated backup — `./run.sh backup-hint` is just a checklist):
  in one maintenance window, snapshot **Postgres** (`pg_dump` or quiesced volume), the **MinIO/S3**
  bucket, the **`buzz-git-data`** volume, Typesense, and your **`.env` secrets**.
- **Watch the partition time-bomb** (#2396): events partitions need rolling forward before
  **2027-01-01**.
- **Keep buzz auth ON even behind the VPN** — closed-relay + membership enforcement, TLS terminated.
  The VPN is a network control, not authentication.

---

## Recommended stack (opinionated)

- **VPN:** Tailscale (Serve in front of the relay; MagicDNS; ACLs). WireGuard if a third-party
  coordination plane is disallowed.
- **Relay host:** one small VM/box; `deploy/compose/` with a pinned image; closed relay.
- **TLS:** Tailscale-issued `.ts.net` cert (zero cert ops), else internal CA + Caddy.
- **Agents:** co-located inside the private network, stdio MCP, scoped to minimal channels.
- **Ops:** pinned image, tested upgrades, self-managed same-window backups.

---

## Key findings (per sub-question)

- **What is buzz?** A self-hostable Nostr-relay "hive mind" workspace (Rust relay + Postgres/Redis/
  S3-MinIO) where humans and AI agents are peers; every action is a signed event in one append-only
  log. — [What buzz Is](../concepts/what-is-buzz.md)
- **How do you self-host it?** Prebuilt image + `deploy/compose/` (5 services), `.env` config,
  `./run.sh start`; only relay:3000 is published. — [Deployment & Topology](../reference/deployment-guide.md)
- **How do you gate it behind a VPN?** Don't expose 3000 publicly; front it with Tailscale (TLS+DNS
  free) or WireGuard; bind datastores private; firewall default-deny; verify externally. —
  [VPN-Gating Patterns](../concepts/vpn-gating-patterns.md)
- **How do clients/agents connect over the VPN?** Repoint `BUZZ_RELAY_URL` at the internal name; solve
  WSS-for-internal-hostname via a VPN-issued or internal-CA cert; co-locate agents (stdio MCP). —
  [Connecting Over a VPN](../concepts/connecting-over-vpn.md)
- **What are the gotchas?** Pre-1.0 maturity, DIY backups, upgrade-bricking migration bug,
  membership-only authz, tamper-evident-not-resistant audit, agent-key blast radius — and "VPN ≠
  auth." — [Operations, Security & Maturity](../concepts/operations-security-maturity.md)

## Sources

See [raw/_index.md](../raw/_index.md) — buzz repo files (README, deploy/compose, SECURITY.md,
multi-tenant spec, NIPs, issues), Tailscale/WireGuard/nginx/Nostr/Let's Encrypt docs, SiliconAngle
launch coverage.
