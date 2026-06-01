---
title: "rustonbsd/iroh-ssh — community SSH-over-iroh"
source: https://github.com/rustonbsd/iroh-ssh
type: repo
tags: [iroh, ssh, proxycommand, dumbpipe, allowlist-gap, community]
date: 2026-06-01
publication_date: 2026-05-20
quality: 4
confidence: high
agent: 2
summary: "Created 2025-06-24, latest push 2026-05-20 (v0.2.11), 180 stars, 13 releases. Wraps SSH via OpenSSH ProxyCommand: client runs iroh-ssh proxy, server proxies to local sshd port 22 over QUIC. Persistent server identity ~/.ssh/iroh_ssh_ed25519. Auth model: 'anyone with the EndpointId can reach your SSH port; rely on standard SSH auth.' NO ALLOWLIST of NodeIds — explicit non-feature. N0 has not shipped a first-party iroh ssh."
---

# rustonbsd/iroh-ssh

The closest existing iroh-as-SSH practitioner project. Production-grade enough for a homelab but missing allowlist gating.

## Server side

```bash
iroh-ssh server --persist
# prints:
# iroh-ssh user@<ENDPOINT_ID>
```

- Stores keypair at `~/.ssh/iroh_ssh_ed25519` for stable EndpointID across restarts
- Listens for any peer that completes handshake → forwards to `localhost:22`

## Client side

```bash
iroh-ssh -i ~/.ssh/id_rsa_cert user@<ENDPOINT_ID>
```

Or via SSH ProxyCommand:

```
# ~/.ssh/config
Host *.iroh
    ProxyCommand iroh-ssh proxy %h %p
```

## Auth model — explicit non-feature

The README states explicitly:

> "anyone with the EndpointId can reach your SSH port; rely on standard SSH auth (keys/certs) for security"

→ defense-in-depth via SSH's pubkey auth, **not** an allowlist of EndpointIds.

This is a **notable contrast to a production design** that wants:
- `~/.ssh/iroh_allowed_node_ids` enforced before SSH bytes flow
- Rate-limiting per-EndpointId
- Per-EndpointId logging

The `iroh::protocol::AccessLimit<P>` wrapper (see [[2026-06-01-iroh-router-protocolhandler-docs]]) is the seam to add this — a downstream production fork should wrap the SSH-tunnel handler.

## Use cases listed in README

- VNC/RDP over iroh
- VS Code remote SSH
- Cloud instance access without exposed ports
- IoT admin
- Bypassing restrictive corporate networks

## Companion project

`futpib/iroh-ssh-android` — Android SSH client over iroh.

## N0 first-party absence

No N0 blog post about either iroh-ssh or do-ssh. Multiple independent SSH-over-iroh projects exist (`iroh-ssh`, `do-ssh`, `Datum`, `Malai`) per [[2026-06-01-awesome-iroh]]; pattern is real, ecosystem is community-driven. Missing the official iroh ssh would be the unblocker for "first-class" status.

## See also

- [[2026-06-01-dumbpipe-binary]] — the simpler primitive iroh-ssh wraps
- [[2026-06-01-cloudflared-aws-ssm-proxycommand]] — pattern reference
- [[2026-06-01-iroh-tickets-security-model]] — why allowlists matter
