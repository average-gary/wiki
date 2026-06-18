---
title: "Configure my own multiplayer lobby (0 A.D. forum thread)"
source: https://wildfiregames.com/forum/topic/89559-configure-my-own-multiplayer-lobby/
type: article
ingested: 2026-06-18
quality: 4
confidence: high
tags: [0ad, multiplayer, self-hosting, ejabberd, xmpp, lobby-bots]
---

# Configure my own multiplayer lobby (0 A.D. forum thread)

The only practitioner-grade walkthrough for hosting a self-hosted 0 A.D.
lobby. Multi-post thread on the official Wildfire Games forum with developer
participation; cross-references official infra repos.

## Three-component architecture

1. **ejabberd** — XMPP server for auth/chat
2. **Lobby bots**:
   - `XpartaMuPP` — game hosting
   - `EcheLOn` — rating
3. **SQLite** — ratings/stats

Network: UDP port 3478 plus STUN settings needed for hosting actual
matches.

## Client-side config (`default.cfg`)

```
server = "your-server-address"
tls    = false
room   = "arena"
```

## Critical gotchas

- **MUC room must be pre-created** and not anonymous
  (`anonymous: false`) — otherwise bots cannot track players.
- **ACL syntax for bot admin must be multi-line allow blocks**, not
  comma-separated.

## Authoritative pointers

- https://github.com/0ad/lobby-bots — bot code & README
- https://github.com/0ad/lobby-infrastructure — Ansible playbooks for
  production-grade deployment

## Why this matters

Covers the actual infra, client wiring, and the specific config pitfalls
that show up in real deployments. Most relevant for anyone building a
private 0 A.D. league or research environment.
