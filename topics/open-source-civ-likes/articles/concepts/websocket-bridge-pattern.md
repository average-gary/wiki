---
title: WebSocket Bridge Pattern (Freeciv-web)
type: concept
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-freeciv-web.md
---

# WebSocket Bridge Pattern (Freeciv-web)

[Freeciv-web](../topics/freeciv-web.md) is the canonical example of how
to bring a **legacy native game server to the browser without rewriting
the simulation**.

## The five-component stack

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

- **Browser ↔ nginx**: HTTP / WebSocket upgrade
- **nginx ↔ freeciv-proxy**: WebSocket
- **freeciv-proxy ↔ Freeciv C server**: native socket
- **Freeciv server ↔ MariaDB**: SQL

`Publite2` (Python) launches and supervises multiple game-server
instances. A Java Tomcat webapp serves static auth/account pages.

## Why the bridge is the right call

The C Freeciv server has **decades of game-rule code** — cities,
diplomacy, AI, scenarios. Rewriting that in JavaScript would be:

- Years of work
- A rebalance event (subtle behavioral diffs from C-vs-JS arithmetic)
- A maintenance fork (every upstream bugfix needs porting)

The bridge avoids all three. The patched C server speaks WebSocket/JSON
through a lightweight protocol shim; the proxy translates between
WebSocket frames and native sockets; the simulation is untouched.

## Cost

Two extra processes per game (nginx, freeciv-proxy) and the latency of
two protocol hops (browser↔nginx↔proxy↔server). For turn-based games
this is invisible — a 50 ms round trip on a one-turn-per-day game is
nothing. For real-time games this would matter.

## Reusability

The pattern generalizes to any project considering "should we rewrite
our native game in WebAssembly / JavaScript / etc.?". The bridge answer
is:

- Patch your native server to speak a transport-friendly protocol
  (WebSocket + JSON, or gRPC-Web, or QUIC)
- Build a thin proxy if your transport doesn't already speak the
  game's protocol
- Keep the simulation in its native language

For OSS civ-likes, this matters because:

- The Freeciv lineage codebase is C-heavy. Wholesale rewrite is a
  multi-year effort that's been attempted (Fciv.net, freecivx.net) and
  hasn't caught on.
- A Bevy / Godot / web-stack civ-like *could* take the inverse
  approach: build natively for the web from day one, skip the bridge.

## Licensing implication

Freeciv-web's client is **AGPL-3.0+** (vs. Freeciv server GPL).
Hosted-service-mode licensing matters: AGPL closes the SaaS loophole
that lets a hoster modify a GPL client without releasing modifications.

Any project building a hosted-multiplayer civ-like via the bridge
pattern has to think about this. The bridge architecture *invites*
hosted-service deployment; the license should match.

## See Also

- [Freeciv-web](../topics/freeciv-web.md)
- [Open Source Civ-Like Games — Landscape](../topics/landscape.md)
- [hub: iroh-transport-stratum-v2](../../../iroh-transport-stratum-v2/_index.md)
  — alternative transport (QUIC + raw-public-key TLS) that could replace
  the WebSocket leg of the bridge in a P2P civ-like
