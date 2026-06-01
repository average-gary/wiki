---
title: "iroh CHANGELOG — 0.91 (Jul 2025) through 1.0.0-rc.1 (May 2026)"
source: https://raw.githubusercontent.com/n0-computer/iroh/main/CHANGELOG.md
type: article
tags: [iroh, changelog, 1.0, history, breaking-changes]
date: 2026-06-01
quality: 5
confidence: high
agent: 4
summary: "Authoritative version timeline. 0.91 (2025-07-30): Stride protocol, new relay handshake. 0.94 (2025-10-21): NodeAddr→EndpointAddr rename, tickets moved to iroh-base. 0.95 (2025-11-04): error refactor. 0.96 (2026-01-28): multipath QUIC. 0.97 (2026-03-16): custom transports (Tor/Nym), embeddable relay. 0.98 (2026-04-17): pluggable crypto backends, iroh-relay-v2. 1.0.0-rc.0 (2026-05-07): RPK TLS, paths API redesign. 1.0.0-rc.1 (2026-05-27): configurable path selection, hard-NAT holepunching, AccessControl trait."
---

# Iroh changelog — 0.91 → 1.0.0-rc.1

Critical for refreshing wiki assumptions made against earlier (0.91-era) iroh.

## Version-by-version highlights

### 0.91 — 2025-07-30
- Stride protocol adoption
- New relay handshake

### 0.92 — 2025-09-18
- mDNS improvements
- Passive discovery

### 0.93 — 2025-10-09
- `Endpoint::online()`
- wasm32 support
- Watchable node addresses

### 0.94 — 2025-10-21 (large breaking changes)
- **`Node` → `Endpoint`** rename across the API
- **Tickets moved to dedicated crate** (`iroh-tickets`)
- Endpoint presets
- Dynamic RelayMap

### 0.95 — 2025-11-04
- Error refactor (snafu → n0-error)

### 0.96 — 2026-01-28
- Multipath QUIC
- Latency-based path updates
- Idle path pruning

### 0.97 — 2026-03-16
- **Custom transports** — Tor/Nym experiments live here
- Embeddable relay server
- Address filtering

### 0.98 — 2026-04-17
- **Pluggable crypto backends**
- iroh-relay-v2 protocol with Health frames

### 1.0.0-rc.0 — 2026-05-07
- **Raw public key TLS replaces x509**
- PQ key-exchange examples
- Auth tokens for relays
- Paths API redesign (`Connection::paths()` snapshot, `Connection::path_events()` stream)
- `Connection::to_info()` removed → `weak_handle()` returns `WeakConnectionHandle`
- New `IncomingLocalAddr`
- DHT/mDNS extracted to `iroh-address-lookups`
- `AccessLimit` moved to `iroh-util`
- Many types `#[non_exhaustive]`
- MSRV 1.91

### 1.0.0-rc.1 — 2026-05-27
- Configurable path selection (breaking)
- Hard-NAT holepunching
- `FourTuple` type
- Relay auth tokens
- `AccessControl` trait

## Stale-knowledge map for the existing wiki

The existing `iroh-transport-stratum-v2/wiki/concepts/iroh-endpoint-and-alpn.md` references `EndpointId`, which is current — the `Node` → `Endpoint` rename was already in by the time that article was written. But it does NOT reference the 1.0-rc.0 paths API redesign or the tickets-crate split. **Refresh trigger: yes.**
