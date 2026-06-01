---
title: "Tailscale OAuth Clients"
source_url: https://tailscale.com/kb/1215/oauth-clients
type: docs
ingested: 2026-06-01
quality: 4
confidence: high
tags: [tailscale, oauth, workload-identity, key-rotation]
relevance: [single-slot-identity]
---

# Tailscale OAuth Clients

Modern, key-rotation-friendly path: OAuth client → ephemeral auth key → tagged device, replacing long-lived secrets in fleet provisioning.

## Mechanism

- OAuth clients with `auth_keys` scope dynamically mint fresh `tskey-auth-...` via `POST /api/v2/tailnet/:tailnet/keys`
- Eliminates static reusable keys (which max at 90-day expiry)
- OAuth client must declare tags at creation time; tags scope which devices it can register
- Access tokens **expire after 1 hour** (cannot be modified)
- URL-style flags: `--auth-key=<secret>?ephemeral=true` toggles ephemeral-vs-persistent at registration
- OAuth clients are tailnet-owned (not user-owned) — critical for unattended fleet automation

## Risk note (per contrarian-2)

OAuth client `client_id+secret` composes into auth keys via `tskey-client-[id]-[secret]`. **A leaked OAuth secret in CI yields unlimited new auth keys — far worse than a single leaked authkey.** Treat Trusted Keys as crown jewels.

## See also

- [[2026-06-01-tailscale-auth-keys]]
- [[2026-06-01-tailscale-changelog-2026]] — Workload Identity Federation GA replaces this in 2026
- [[2026-06-01-specterops-tailscale-keys]]
