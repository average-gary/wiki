---
title: "Freeciv-web — freeciv/freeciv-web"
source: https://github.com/freeciv/freeciv-web
type: repo
ingested: 2026-06-18
quality: 5
confidence: high
license: AGPL-3.0+ (client) / GPL (server)
language: JavaScript
tags: [freeciv-web, browser, agpl, websocket, three.js, AGPL-3.0, dual-license]
---

# Freeciv-web — freeciv/freeciv-web

Browser-playable Freeciv. **Five-component architecture**:

```
JS/HTML5 client (Three.js for WebGL 3D + 2D isometric pipeline)
    ↓
nginx
    ↓
Python `freeciv-proxy` (WebSocket↔socket bridge)
    ↓
Patched C Freeciv server (with WebSocket/JSON protocol shim)
    ↓
MariaDB (state, accounts, PBEM)
```

`Publite2` is a Python launcher that manages multiple game-server instances.

Backend Java webapp on **Tomcat 10 with Maven**.

Language mix: JavaScript 73.5%, Python 6.8%, CSS 6.0%, plus Java/C from the
upstream Freeciv server.

## Licensing

**Dual licensing**:
- Freeciv C server **GPL** (inherited from upstream)
- Freeciv-web client **AGPL-3.0+** (driven by hosted-game model — AGPL is
  unusual in the OSS game space and signals the project's hosted-service
  posture)

## Deployment

- **Vagrant/VirtualBox** or **Docker Compose** on Ubuntu
- CI via GitHub Actions
- Includes a **PBEM (play-by-email) module**

## Why this matters

Best example in the genre of bridging a legacy C codebase to the browser
**without rewriting**. The proxy pattern (`freeciv-proxy` translating
WebSocket↔socket) is reusable — any project with a C/legacy game server
considering web playability has a working reference here.

CivRealm (ICLR 2024) builds on this — see
[2026-06-18-civrealm-iclr-2024.md](../papers/2026-06-18-civrealm-iclr-2024.md).
