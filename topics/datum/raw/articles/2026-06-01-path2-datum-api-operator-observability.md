---
title: "DATUM Gateway datum_api.c — Operator Dashboard the SV2 Variant Must Match"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_api.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 7
tags: [datum, datum-gateway, observability, api, libmicrohttpd, dashboard]
related_concepts: [sv2-downstream-replacement, operator-experience, observability]
---

# datum_api.c — operator surface the SV2 variant must preserve or improve

The gateway's HTTP/HTML admin UI. Built on **libmicrohttpd**. Not a
metrics endpoint in the modern (Prometheus) sense — it's a hand-rolled
HTML dashboard plus a few JSON/plaintext endpoints. Documenting it
because **operator UX parity is a non-functional requirement** for any
serious replacement.

## Endpoints

| Path | Purpose |
|---|---|
| `/` | homepage — pool/stratum status overview |
| `/clients` | per-miner table (the canonical view) |
| `/threads` | per-thread aggregates |
| `/coinbaser` | available coinbase outputs / pool address allocation |
| `/config` | GET=form, POST=update — runtime config edit (gated by `api.modify_conf`) |
| `/cmd` | admin actions (kick client, empty thread) |
| `/assets/*` | CSS/SVG/favicon |
| `/NOTIFY` | trigger block-template refresh; returns `OK` |
| `/testnet_fastforward` | testnet time manipulation; returns `OK` |
| `/umbrel-api` | JSON for Umbrel widget |

## Per-miner statistics (the `/clients` view)

- last accepted share timestamp
- current vardiff
- `diff_accepted`, `diff_rejected`, rejection %
- username, remote IP, user-agent string
- coinbase-variant selection (which of the 6 fingerprint variants)
- estimated hashrate (Th/s) from share velocity
- subscription state, session ID
- connection age

## Per-thread aggregates (the `/threads` view)

- active client count
- subscribed client count
- estimated thread hashrate (sum of subscribed miners)

## Global metrics (homepage)

- active stratum threads, total connections, total subscriptions
- accepted/rejected share count + cumulative diff
- process uptime
- block height, coinbase value, network difficulty
- pool connectivity state (connected / error / initializing)

## Auth model

- **Admin password** — plaintext config compare via
  `datum_secure_strequals` (constant-time)
- **HTTP Digest Auth** (SHA-256 with MD5 fallback for Safari, gated by
  `api.allow_insecure_auth`)
- **CSRF token** in forms; validated on POST
- **No IP whitelist** — IP is logged but not used for filtering

## Response formats

Almost entirely **HTML**. Limited JSON (`/umbrel-api`, internal config-error
arrays). Two **plaintext** endpoints (`/NOTIFY`, `/testnet_fastforward`).

**No Prometheus exposition.** No native metrics export. Operators relying
on observability tooling currently scrape the HTML or roll their own
exporter — this is a known gap and a place where an SV2 variant could
strictly improve.

## SV2-downstream replacement notes

### Preserve

- All endpoints and data fields. Operators have built dashboards
  against this surface; breaking it is gratuitous.
- Auth model. Digest auth + CSRF + admin password is reasonable.
- Per-miner / per-thread / global hierarchy. Maps to SV2 cleanly:
  per-channel / per-connection / global.
- Admin actions: kick channel, empty connection.

### Adjust

- "stratum threads" → "channel-handler tasks" (terminology) but
  semantically similar.
- "subscription" → "channel open" — SV2 has explicit
  `OpenMiningChannel` rather than implicit `mining.subscribe`.
- "session ID" → "channel ID" or "connection ID" depending on context.
- "coinbase-variant selection" — likely disappears (SV2 TDP changes
  the coinbase model upstream).

### Add (improvements over status quo)

- **Prometheus `/metrics` endpoint** — long-overdue.
- **Per-channel target history** (vardiff sparkline).
- **Noise handshake state / authority pubkey** in the UI.

## libmicrohttpd consideration

The C gateway uses libmicrohttpd. A Rust SV2 variant would naturally
use `axum`, `warp`, or `actix-web` (or stay minimal with `hyper`).
Templating likely moves to `askama` or similar. This is a clean
rewrite — the auth/CSRF logic and the data presentation are simple
enough to reproduce without ceremony.

## Justification

The operator-facing API is part of the gateway's contract with users.
Documenting it ensures the SV2 variant either preserves or
deliberately versions every endpoint. Identifies the
no-Prometheus-today gap as an opportunity for the rewrite.
