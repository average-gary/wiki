# bitcoincore-rpc (rust-bitcoin) — ARCHIVED 2025-11-25

**Source:** https://github.com/rust-bitcoin/rust-bitcoincore-rpc
**Fetched:** 2026-06-01
**Crate:** https://docs.rs/bitcoincore-rpc/0.19.0
**JSON types crate:** https://docs.rs/bitcoincore-rpc-json/0.19.0

## Status (load-bearing for DATUM port)

- **ARCHIVED & UNMAINTAINED** as of 2025-11-25 — repo is read-only.
- Maintainers' redirect note: "switch to `corepc-client`" or pursue an async alternative via the rust-bitcoin discussion thread.
- Last published version: **0.19.0**.
- 384 stars, 289 forks, 50 open issues at archive time.
- Maintainer: stevenroose (rust-bitcoin org).
- License: **CC0-1.0**.
- Supported Bitcoin Core versions per README: 0.18.0 – 0.21.0 (very stale; v22+ added new RPCs the crate doesn't expose). It works against modern Core for the methods DATUM needs because GBT/submitblock are stable, but no formal compatibility statement exists for Core 25–29 / Knots equivalents.

## API surface DATUM cares about

Sync-only client (`reqwest::blocking` underneath). All methods return `Result<T, bitcoincore_rpc::Error>`.

```rust
fn get_block_template(
    &self,
    mode: json::GetBlockTemplateModes,
    rules: &[json::GetBlockTemplateRules],
    capabilities: &[json::GetBlockTemplateCapabilities],
) -> Result<json::GetBlockTemplateResult>

fn submit_block(&self, block: &Block) -> Result<()>
fn submit_block_bytes(&self, block_bytes: &[u8]) -> Result<()>
fn submit_block_hex(&self, block_hex: &str) -> Result<()>

fn get_blockchain_info(&self) -> Result<GetBlockchainInfoResult>
fn get_mining_info(&self)     -> Result<GetMiningInfoResult>
```

### `GetBlockTemplateResult` field richness (from `bitcoincore-rpc-json` 0.19.0)

All fields DATUM consumes are present, *plus* the long-poll id and the fields the C code drops on the floor:

| Field                        | Type                                     | DATUM C consumes? |
| ---------------------------- | ---------------------------------------- | ----------------- |
| `bits`                       | `Vec<u8>`                                | yes               |
| `previous_block_hash`        | `BlockHash`                              | yes               |
| `current_time`               | `u64`                                    | yes (`curtime`)   |
| `height`                     | `u64`                                    | yes               |
| `sigop_limit`                | `u32`                                    | yes               |
| `size_limit`                 | `u32`                                    | yes               |
| `weight_limit`               | `u32`                                    | yes               |
| `version`                    | `u32`                                    | yes               |
| `rules`                      | `Vec<GetBlockTemplateResultRules>`       | implicit          |
| `capabilities`               | `Vec<GetBlockTemplateResultCapabilities>`| no                |
| `version_bits_available`     | `HashMap<String, u32>`                   | no                |
| `version_bits_required`      | `u32`                                    | no                |
| **`longpollid`**             | **`String`**                             | **NO — gap**      |
| `transactions`               | `Vec<GetBlockTemplateResultTransaction>` | yes               |
| `signet_challenge`           | `ScriptBuf`                              | n/a               |
| `default_witness_commitment` | `ScriptBuf`                              | yes               |
| `coinbaseaux`                | `HashMap<String, String>`                | NO (C drops)      |
| `coinbase_value`             | `Amount`                                 | yes               |
| `target`                     | `Vec<u8>`                                | yes               |
| `min_time`                   | `u64`                                    | yes (`mintime`)   |
| `mutable`                    | `Vec<GetBlockTemplateResulMutations>`    | NO (C drops)      |
| `nonce_range`                | `Vec<u8>`                                | NO (C drops)      |

`GetBlockTemplateResultTransaction` exposes `txid`, `hash`, `data`, `fee`, `sigops`, `weight` — exact match for the C parser.

### Auth modes

```rust
pub enum Auth {
    None,
    UserPass(String, String),
    CookieFile(PathBuf),
}
```

Both modes DATUM needs are first-class. Cookie-file refresh on 401 is *not* automatic; caller must reload + reconnect (the C code's `update_rpc_cookie` retry path).

### Long-polling

`GetBlockTemplateResult` deserializes `longpollid` but `get_block_template()` itself does **not** accept a `longpollid` parameter — the second-call long-poll handshake (re-issue GBT with `longpollid` until bitcoind blocks-then-responds) requires a custom `Client::call("getblocktemplate", &[json!({"rules":["segwit"], "longpollid": id})])` invocation. The crate exposes `Client::call` for arbitrary RPCs.

### TLS

`bitcoincore-rpc-json` doesn't touch transport. The transport (`jsonrpc` crate, simple-http feature) speaks plaintext HTTP only out of the box. TLS is **not** supported by the default transport. (Bitcoin Core itself doesn't speak TLS on RPC; users wanting TLS run a reverse proxy. The C `datum_jsonrpc.c` likewise doesn't configure TLS.)

## Verdict for DATUM

- API is essentially perfect for the GBT field set.
- **Sync-only** is a deal-breaker if the Rust port goes async (which is the obvious choice for a stratum gateway).
- **Archived** — must not be a long-term dependency.
- Useful only as a reference for trait shape and as the source of `bitcoincore-rpc-json` types until corepc-types stabilizes.
