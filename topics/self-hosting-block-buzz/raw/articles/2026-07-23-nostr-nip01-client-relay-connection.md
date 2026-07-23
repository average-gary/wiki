---
title: "NIP-01: how a Nostr client connects to a relay (framing the VPN problem)"
source: https://github.com/nostr-protocol/nips/blob/master/01.md
type: article
tags: [nostr, nip-01, websocket, relay, client-connection]
confidence: high
ingested: 2026-07-23
summary: "NIP-01 basics: relays expose a WebSocket endpoint (ws:// or wss://); one long-lived socket per relay; no discovery/handshake beyond the WS upgrade — so 'connecting over a VPN' is purely reachability + TLS, not a protocol problem."
---

# NIP-01: client ↔ relay connection

- Relays "expose a websocket endpoint to which clients can connect." Both `ws://` and `wss://` supported (tag examples use `wss://`).
- Clients SHOULD open a **single** WebSocket per relay and multiplex all subscriptions — one long-lived socket, which matters for VPN keepalive/timeout tuning.
- Client→relay: `["EVENT", <event>]`, `["REQ", <sub_id>, <filters>]`, `["CLOSE", <sub_id>]`. Relay→client: `EVENT`, `OK`, `EOSE`, `CLOSED`, `NOTICE`.
- **No handshake negotiation beyond the WebSocket upgrade** — no relay discovery/addressing in NIP-01. The client is simply pointed at a URL.
- **Consequence:** pointing buzz clients at an internal, VPN-only relay URL is purely a config change (`BUZZ_RELAY_URL`). The VPN problem reduces to reachability + TLS, not protocol.
