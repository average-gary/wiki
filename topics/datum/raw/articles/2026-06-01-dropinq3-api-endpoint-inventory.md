---
title: "Drop-In Q3: datum_api.c Endpoint Inventory — full surface for axum port"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_api.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: dropinq3
research_path: dropin-q3-non-stratum-concerns
quality_score: 8
tags: [datum, datum-gateway, api, dashboard, libmicrohttpd, axum, endpoint-inventory]
related_concepts: [phase2-drop-in-replacement, operator-observability, csrf-auth]
---

# datum_api.c — full endpoint inventory for a Rust replacement

This is the operator-facing HTTP surface a drop-in Rust replacement must
serve. ~2,100 LOC in C; estimated 800–1,200 LOC in Rust with `axum`
and `askama` (or `maud`).

The bare endpoint list is in `gateway-internals-c-architecture.md` /
`raw/articles/2026-06-01-path2-datum-api-operator-observability.md`.
This article goes deeper: HTTP method, content-type, auth requirement,
response data structure, and Rust port notes for each.

## Full endpoint table

| Method | Path | Content-Type | Auth | Notes |
|---|---|---|---|---|
| GET | `/` | text/html | none | homepage / overview |
| GET | `/clients` | text/html | **HTTP Digest** | per-miner table |
| GET | `/threads` | text/html | none | per-thread aggregates |
| GET | `/coinbaser` | text/html | none | available coinbase outputs |
| GET | `/config` | text/html | **HTTP Digest** | runtime config form |
| POST | `/config` | text/html | **HTTP Digest + CSRF** | runtime config update |
| POST | `/cmd` | application/json | **password OR Digest, + CSRF** | admin actions (kick / empty thread) |
| GET | `/assets/style.css` | text/css | none | embedded asset, ETag |
| GET | `/assets/icons/datum_logo.svg` | image/svg+xml | none | embedded asset, ETag |
| GET | `/assets/icons/favicon.ico` | image/x-icon | none | embedded asset, ETag |
| GET | `/favicon.ico` | image/x-icon | none | redirects to /assets/icons/favicon.ico |
| GET | `/NOTIFY` | text/plain | none | triggers GBT refresh; returns "OK" |
| GET | `/testnet_fastforward` | text/plain | **password (query string)** | testnet time manipulation; returns "OK" |
| GET | `/umbrel-api` | application/json | none | Umbrel widget JSON |

**14 routes total**, plus a default 404 handler for everything else.

## Response data per endpoint

### `/` (homepage)

Inline HTML rendering of:
- Share counts: accepted, rejected, with cumulative diff
- Connection status pill (color-coded SVG): connected / error / initializing
- Pool host:port (the upstream DATUM endpoint)
- Pool/miner coinbase tags (text)
- Current vardiff (the lowest among connected miners? or median? — confirm in port)
- Process uptime
- Active threads, total connections, total subscriptions
- Estimated total hashrate
- Current job: ID, height, coinbasevalue, target, prevblockhash,
  default_witness_commitment, difficulty, version, bits, mintime,
  curtime, sizelimit, weightlimit, sigoplimit, txn_count

### `/clients` (per-miner table)

Auth: HTTP Digest. Response: HTML table, one row per connected miner,
columns:
- TID/CID (thread ID + client ID composite — operator-recognizable from logs)
- Remote host (IP:port)
- Username (with modifier suffix preserved)
- Subscription state (subscribed / unsubscribed / authorized)
- Diff accepted (cumulative)
- Diff rejected (cumulative)
- Reject %
- Estimated hashrate (Th/s, with age timestamp showing when the
  velocity was last measured)
- Coinbase variant selection (which of the 6 fingerprint variants —
  drops away under SV2)
- User-agent string (raw, from `mining.subscribe`)

### `/threads` (per-thread aggregates)

No auth. Per-thread row:
- Thread ID
- Connected client count
- Subscribed client count
- Estimated thread hashrate (sum of subscribed miners on this thread)

### `/coinbaser`

No auth. Lists:
- Each coinbase output the upstream pool currently allocates: BTC value, address
- Residual share to the operator's pool address (after pool-supplied
  outputs)

### `/config` GET / POST

GET: HTML form with editable fields for: mining address, coinbase
tags, pool settings, bitcoind RPC URL/auth, etc.
POST: parses the form, writes the updated values to the JSON config
file, displays success/error page. Some changes (pool/bitcoind) require
process restart, acknowledged in the response.

Auth: HTTP Digest (GET and POST), plus CSRF token on POST.
Gated by `api.modify_conf` config flag (default false).

### `/cmd`

POST application/json. Admin actions:
- `empty_thread`: disconnect all clients on a thread
- `kill_client`: disconnect a specific client by TID/CID

Auth: admin password OR HTTP Digest, plus CSRF token. Inline JS
(`www_assets_post_js`) submits without page reload.

### `/NOTIFY`

GET. No auth. Triggers `datum_blocktemplates_notifynew_sighandler()`
(same flag as SIGUSR1). Returns `"OK"` plaintext.

Used in `bitcoin.conf`:
```
blocknotify=curl -s http://127.0.0.1:7152/NOTIFY
```
as an alternative to a SIGUSR1 script.

### `/testnet_fastforward`

GET with password as query string. Testnet-only time manipulation
(advances `curtime` to allow miners to discover blocks faster on
testnet). Returns `"OK"`.

Password auth via query string is a security smell on its own (logs
in webserver access logs), but the endpoint is gated behind a config
flag and is testnet-only. Rust port should preserve as-is or
deliberately remove with a config-versioning bump.

### `/umbrel-api`

GET application/json. Umbrel Bitcoin Mining widget integration. JSON
shape:
```json
{
  "connections": <int>,
  "hashrate": "<value>",
  "refresh": "30s"
}
```
External integration — do not break this contract.

## Auth model details

### HTTP Digest

- SHA-256 primary
- MD5 fallback for Safari (gated by `api.allow_insecure_auth`, default false)
- Realm: "DATUM Gateway" (or similar — confirm in port)
- Server-generated nonces, tracked for replay prevention

Rust port: no off-the-shelf crate I'm aware of supports SHA-256 +
MD5-fallback Digest. Plan to implement in ~150 LOC using `axum`'s
`FromRequestParts` extractor pattern, leveraging `sha2` and `md5` crates.

### CSRF token

Computed once at config-load time:
```c
api_csrf_token = SHA256("DATUM Anti-CSRF Token" + listen_port + admin_password)
```
Hex-encoded, embedded as a hidden field in `/config` form and in the
inline JS `www_assets_post_js`. Validated on POST to `/cmd` and `/config`.

Rust port: same derivation, store as `&'static str` (or `Box<str>` if
config can change), middleware extractor checks the form field or
JSON body.

### Password (query string, testnet only)

Plaintext password compare via `datum_secure_strequals` (constant-time).
Only for `/testnet_fastforward`. Rust: `subtle::ConstantTimeEq` on the
password bytes.

## Embedded assets

All static assets are compiled into the binary as C string constants:

```c
extern const char www_home_html[];
extern const char www_clients_top_html[];
extern const char www_threads_top_html[];
extern const char www_coinbaser_top_html[];
extern const char www_config_html[];
extern const char www_config_errors_html[];
extern const char www_foot_html[];           // shared footer
extern const char www_assets_style_css[];
extern const char www_assets_post_js[];      // inline AJAX for /cmd
extern const unsigned char www_assets_icons_datum_logo_svg[];
extern const unsigned char www_assets_icons_favicon_ico[];
```

Generated at build time from a `www/` source directory by a
preprocessor. ETag headers on each asset for client-side caching.

Rust port options:
- `include_bytes!("../www/style.css")` per asset
- `tower-http::services::ServeDir` with a build script that
  copies into target dir
- `rust-embed` crate to walk a directory at build time

The HTML templates currently use simple `printf`-style substitution
(format strings with `%d`, `%s`). Rust port: use `askama` or `maud`
for type-safe templates that fail at compile time if a field is
missing or renamed.

## What the Rust port owes operators

### Preserve byte-compatible

- All endpoint paths
- `/umbrel-api` JSON shape (external integration)
- `/NOTIFY` plaintext "OK" response
- `/testnet_fastforward` plaintext "OK" response
- HTTP Digest auth (with SHA-256 + MD5 fallback)
- CSRF token derivation (`SHA256("DATUM Anti-CSRF Token" + port + pwd)`)

### Preserve semantically

- `/clients`, `/threads`, `/`, `/coinbaser` data fields (operators have
  scraping scripts; preserve column names and JSON-ifiable structure)
- Auth gating on `/clients` and `/config`

### Free to change

- HTML/CSS visual styling (operators don't typically scrape rendered HTML)
- The 6 fingerprint-variant column on `/clients` (collapses under SV2)
- libmicrohttpd-specific connection limits (Tokio/axum scales differently)

### Add (improvements)

- `/metrics` Prometheus exposition (zero today; the single biggest gap)
- WebSocket on `/clients` for live updates instead of polling
- Per-channel target-history sparkline on `/clients` (vardiff visualization)
- Noise handshake state and authority pubkey on `/` (SV2-specific)

## Scope dimensioning

| Component | Estimate |
|---|---|
| Endpoint routing (axum router) | ~50 LOC |
| HTTP Digest extractor | ~150 LOC |
| CSRF middleware | ~50 LOC |
| HTML templates (7 partials) | ~400 LOC of template + ~100 LOC of model |
| Embedded assets wiring | ~30 LOC + asset files |
| `/cmd` action handlers | ~100 LOC |
| `/config` form parse + write | ~150 LOC |
| `/umbrel-api` JSON | ~30 LOC |
| `/NOTIFY` + `/testnet_fastforward` | ~30 LOC |
| Prometheus `/metrics` (new) | ~50 LOC |
| Tests | ~200 LOC |
| **Total** | **~1,300 LOC** |

That's ~40% of the total non-stratum port budget concentrated in this
one module. **Plan accordingly. Do not underestimate.**

## Justification

Concrete endpoint-by-endpoint inventory with auth, response shape, and
port hazards. Forms the input to a Rust `axum` router specification
that maintains operator-visible compatibility while opening the door
to native Prometheus support.
