# corepc — the rust-bitcoin successor to bitcoincore-rpc

**Source:** https://github.com/rust-bitcoin/corepc
**Fetched:** 2026-06-01
**Docs:** https://docs.rs/corepc-client, https://docs.rs/corepc-types

## Repo shape

The `corepc` repo publishes several crates; the production-relevant ones for DATUM are:

| Crate           | Purpose                                              | Latest  | Production-OK?           |
| --------------- | ---------------------------------------------------- | ------- | ------------------------ |
| `corepc-types`  | Pure data types for every Core RPC across versions   | 0.14.0  | **Yes — explicit**       |
| `corepc-client` | Blocking JSON-RPC client wrapping `bitreq`           | 0.15.0  | **No — explicit warning**|
| `bitreq`        | Minimal HTTP client (sync + optional async + TLS)    | n/a     | Building block           |
| `jsonrpc`       | Reused JSON-RPC primitives                           | n/a     | Building block           |
| `bitcoind`      | Test harness (spawn regtest bitcoind)                | n/a     | Test only                |

Maintainer: rust-bitcoin org. License: **CC0-1.0**. Active (1,270 commits on master, 73 tags, recent CI activity in 2026).

## Production-readiness statement (verbatim)

From the repo README:
> Please do not use `corepc-client` in production and raise bugs, issues, or feature requests.
> Provide the `corepc-types` crate for use in production software.

→ The maintainers' explicit guidance is: **roll your own thin async JSON-RPC client and depend on `corepc-types` for the response/request structs.**

## Supported Bitcoin Core versions

`corepc-types` declares modules `v17` through `v31` (15 versions). DATUM targets Core 25–29 + Knots; all are covered. Each version module re-derives types when the response shape changes between releases.

## Mining types in `corepc-types::v29::mining`

- `GetBlockTemplate` — "Result of the JSON-RPC method `getblocktemplate`."
- `GetMiningInfo` — "Result of the JSON-RPC method `getmininginfo`."
- `GetPrioritisedTransactions`
- `BlockTemplateTransaction` — per-tx struct (txid, hash, data, fee, sigops, weight).
- Methods covered: `getblocktemplate`, `getmininginfo`, `getnetworkhashps`, `getprioritisedtransactions`, `prioritisetransaction`, `submitblock`, `submitheader`.

## `corepc-client` API (sync only — for reference)

`corepc-client` exposes `get_block_template`, `submit_block`, `get_blockchain_info`, `get_mining_info`. Auth via `Auth { None | UserPass | CookieFile }` (same enum design as the archived crate). It is **blocking** (no tokio); the underlying `bitreq` HTTP client has an optional async feature but `corepc-client` itself is described as "blocking JSON-RPC client".

## Verdict for DATUM

- **Use `corepc-types` for the request/response structs.** Production-blessed, covers v17–v31, owns the type evolution problem (Knots tracks Core's RPC shape, so Knots is implicitly compatible per-version).
- **Do not use `corepc-client`.** Sync-only and the maintainers explicitly mark it "do not use in production."
- The "right answer" for the DATUM port is therefore: **hand-rolled async client (reqwest + serde) wrapping `corepc-types::v29::mining` (and `v29::blockchain`) types.** This is exactly the path the rust-bitcoin maintainers recommend.
