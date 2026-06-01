# Async Bitcoin RPC alternatives — survey

**Fetched:** 2026-06-01

## `bitcoind-async-client` (alpenlabs)

- Repo: https://github.com/alpenlabs/bitcoind-async-client
- Crate: https://crates.io/crates/bitcoind-async-client (latest 0.10.7, 2026-05-25)
- License: **Dual Apache-2.0 / MIT**
- Async (tokio), built on `bitreq`.
- Targets Bitcoin Core 29.0+.
- **Wallet/PSBT-focused.** README: "PSBT and wallet RPC methods for advanced transaction handling."
- Trait surface (per docs.rs):
  - `Broadcaster` — broadcasting txs
  - `Reader` — basic chain reads
  - `Signer` — signing (with private keys)
  - `Wallet` — wallet methods (without private keys)
- **No mining methods exposed** — no `get_block_template`, no `submit_block`, no `get_mining_info` in any of the four traits. Confirmed by docs.rs traits index.
- Constructor takes user/pass directly (`Client::new(url, user, pass, ...)`). No cookie-file mode visible in the public example.

**Verdict:** unsuitable as-is. Mining RPCs would have to be added; at that point you've reproduced most of the work of a hand-rolled client.

## `dpc/rust-bitcoincore-rpc-async` (community fork)

- URL: https://github.com/dpc/rust-bitcoincore-rpc-async — **404 / repo gone** as of 2026-06-01.
- Other community async forks of the archived crate are similarly stale; nothing on crates.io with meaningful download volume claims to be a maintained async port of `bitcoincore-rpc`.

## `jsonrpsee` (Parity Technologies)

- Crate: https://crates.io/crates/jsonrpsee (latest 0.26.0)
- License: **MIT**.
- Generic, high-quality JSON-RPC framework. Supports HTTP and WebSocket clients, async (tokio), TLS via opt-in features.
- No bitcoin-specific knowledge — types and method names would have to be wired manually. Possible to combine `jsonrpsee::http_client` with `corepc-types` structs, but the framework is heavier than needed for ~10 RPC methods. It targets bidirectional pub/sub, which bitcoind doesn't provide.

**Verdict:** overkill. `reqwest` is lighter and idiomatic for one-shot HTTP POSTs.

## `reqwest` + `serde_json` + `corepc-types` — hand-rolled

- `reqwest` (latest 0.12.x) — async HTTP client with optional TLS (`rustls-tls` or `native-tls` features). Supports basic auth via `RequestBuilder::basic_auth(user, Some(pass))`.
- `serde` / `serde_json` — already in any Rust project.
- `corepc-types` — production-blessed Core types (see separate article).
- Cookie auth = read `~/.bitcoin/.cookie` (or configured path), split on `:`, feed user/pass into `basic_auth`. Same logic the C `update_rpc_cookie` does.
- TLS = enable `reqwest`'s `rustls-tls` feature; `Url` parsing handles `https://` automatically.
- Long-polling = same POST, just with `longpollid` in params; `reqwest` supports per-request timeouts so you can give the long-poll call a generous timeout (e.g. 70s, longer than bitcoind's GBT long-poll deadline).

This is the path the `corepc` maintainers explicitly recommend ("write your own JSON-RPC client").

## Cross-crate scoreboard

| Crate                        | Maintainer      | Last commit      | License           | Async | Mining RPCs   | Cookie auth | Long-poll | Knots-OK | Verdict for DATUM       |
| ---------------------------- | --------------- | ---------------- | ----------------- | ----- | ------------- | ----------- | --------- | -------- | ----------------------- |
| `bitcoincore-rpc` 0.19.0     | rust-bitcoin    | 2025-11-25 (archived) | CC0-1.0      | No    | Full GBT/submit/info | Yes (`Auth::CookieFile`) | Via raw `Client::call` | Yes (RPC shape) | **Reject — archived**   |
| `corepc-client` 0.15.0       | rust-bitcoin    | 2026 active      | CC0-1.0           | No    | Full          | Yes         | Via raw call | Yes      | **Reject — "do not use in production"** |
| `corepc-types` 0.14.0        | rust-bitcoin    | 2026 active      | CC0-1.0           | n/a   | Types only    | n/a         | n/a       | v17–v31 covered | **Use as type layer**   |
| `bitcoind-async-client` 0.10.7 | alpenlabs    | 2026-05-25       | Apache-2.0/MIT    | Yes   | **None**      | Not in example API | n/a | Core 29.0+ only | **Reject — wallet-only**|
| `jsonrpsee` 0.26.0           | Parity          | active           | MIT               | Yes   | n/a (generic) | Manual      | Manual    | n/a      | Overkill                |
| `reqwest` + `corepc-types` (hand-rolled) | self | self           | (you pick)        | Yes   | Whatever you wire | Trivial | Trivial | All     | **Recommended**         |

## Hand-rolled fallback estimate

Replacing `datum_jsonrpc.c` (~235 LOC of libcurl C) plus `datum_blocktemplates.c` (template fetch + dual-notification path):

- HTTP/auth/transport: ~80 LOC of Rust (`reqwest::Client::new()` builder, `basic_auth`, JSON-RPC envelope helper, error mapping).
- Cookie reload on 401: ~25 LOC (read file, split `:`, retry once).
- Long-poll loop: ~40 LOC (extract `longpollid` from previous response, re-POST with extended timeout, restart on hash change).
- Block-found `submitblock`: ~15 LOC.
- Telemetry (`getblockchaininfo`, `getmininginfo`): ~10 LOC each (deserialize into `corepc_types::v29::blockchain::GetBlockchainInfo` / `mining::GetMiningInfo`).

**Total: ~200 LOC of focused Rust** — slightly *less* than the C it replaces, because `reqwest` + `serde` + `corepc-types` collapse the manual JSON parsing the C code does with `json-c`.

### Dependencies

```toml
[dependencies]
reqwest         = { version = "0.12", default-features = false, features = ["json", "rustls-tls"] }
serde           = { version = "1",   features = ["derive"] }
serde_json      = "1"
corepc-types    = "0.14"
tokio           = { version = "1",   features = ["macros", "rt-multi-thread", "time", "fs"] }
hex             = "0.4"   # for submitblock hex serialization
thiserror       = "2"     # error enum
tracing         = "0.1"   # logging
```

`base64` is not needed (`reqwest::RequestBuilder::basic_auth` handles header encoding internally).
