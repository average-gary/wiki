---
title: Freeciv-web
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-freeciv-web.md
  - raw/articles/2026-06-18-wikipedia-freeciv-history.md
  - raw/papers/2026-06-18-civrealm-iclr-2024.md
  - raw/papers/2026-06-18-forecastbench-sim-freeciv.md
---

# Freeciv-web

[freeciv/freeciv-web](https://github.com/freeciv/freeciv-web) — browser-
playable [Freeciv](../topics/landscape.md#1-freeciv-lineage-1996). Hosted
at `play.freecivweb.org` and other community deployments.

Most importantly, it is **not a reimplementation**: it keeps the patched C
Freeciv server and bridges it to a Three.js HTML5 client via a Python
WebSocket↔socket shim.

## Five-component architecture

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

`Publite2` is a Python launcher that manages multiple game-server
instances. Backend Java webapp on **Tomcat 10 with Maven**.

Language mix: JavaScript 73.5%, Python 6.8%, CSS 6.0%, plus Java/C from
the upstream Freeciv server.

## Licensing — dual

- **Freeciv C server: GPL** (inherited from upstream)
- **Freeciv-web client: AGPL-3.0+**

The AGPL choice is unusual in OSS games — it is driven by the **hosted-
service posture**: AGPL closes the SaaS loophole that lets a hoster modify
a GPL client without releasing the modifications. Most OSS game projects
don't think about this because they don't host their own clients. Freeciv-
web does.

## The proxy pattern

Freeciv-web's most reusable lesson is the
[WebSocket bridge pattern](../concepts/websocket-bridge-pattern.md): rather
than rewriting the simulation in JavaScript, keep the C server, patch it
to speak WebSocket/JSON, and bridge through a small Python proxy.

Any project with a legacy C/native game server considering web playability
has a working reference here. The cost is two extra processes per game
(nginx, freeciv-proxy) and the latency of two protocol hops.

## Deployment

- **Vagrant/VirtualBox** or **Docker Compose** on Ubuntu
- CI via GitHub Actions
- Includes a **PBEM (play-by-email) module**

## Server outage history

The original `play.freeciv.org` server was **shut down in March 2018** and
later "revived by volunteers." A multi-month outage of the canonical
multiplayer host. The current Freeciv-web deployments operate as a
volunteer-maintained mesh of community-hosted instances.

## Research significance

Freeciv-web is the engine underneath
[CivRealm](research-testbeds.md#civrealm-iclr-2024) (Qi et al., ICLR
2024) — the canonical academic 4X testbed. It also underlies
[ForecastBench-Sim](research-testbeds.md#forecastbench-sim-freeciv-2026)
(Lee et al., 2026), which uses Freeciv as a substrate for forecasting
evaluation. The research utility of Freeciv-web extends far beyond
gameplay.

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
- [Freeciv21](freeciv21.md) — the desktop modernization fork
- [WebSocket bridge pattern](../concepts/websocket-bridge-pattern.md)
- [Civ-likes as AI research testbeds](research-testbeds.md)
