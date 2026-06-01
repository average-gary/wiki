# DATUM C source baseline — what we're replacing

**Source:** https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_jsonrpc.c
**Source:** https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_blocktemplates.c
**Fetched:** 2026-06-01

## `datum_jsonrpc.c` — HTTP/auth layer

- ~235 LOC, libcurl-based.
- Auth precedence: if `bitcoind_rpcuser` set, use user/pass; else if `bitcoind_rpccookiefile` set, read cookie file. Both feed `CURLOPT_USERPWD` with `CURLAUTH_BASIC`.
- Cookie refresh: on `HTTP 401`, call `update_rpc_cookie(cfg)`, retry once via recursive `json_rpc_call(...)`.
- No TLS configuration evident — plaintext HTTP only (matches Bitcoin Core's own RPC server defaults).
- No exponential backoff. No connection pooling beyond curl's defaults.
- Generic envelope: `json_rpc_call()` and `bitcoind_json_rpc_call()` take a pre-built `rpc_req` string and return parsed `json_t*`.

## `datum_blocktemplates.c` — GBT + notification

### GBT request (verbatim from source)

```c
"{\"method\":\"getblocktemplate\",\"params\":[{\"rules\":[\"segwit\"]}],\"id\":%"PRIu64"}"
```

- **No `longpollid` is ever sent.** Path 1 finding (prior session) confirmed in source.
- Hard-coded `["segwit"]` rules; no `signet`, `taproot` (taproot is implicit since Core 23 anyway).

### GBT response fields consumed

Extracted via `json_object_get()`:
- `height`, `coinbasevalue`, `mintime`, `curtime`
- `sigoplimit`, `sizelimit`, `weightlimit`
- `version`, `bits`, `previousblockhash`, `target`
- `default_witness_commitment`
- `transactions[]` with `txid`, `hash`, `fee`, `sigops`, `weight`, `data`

**Dropped:** `mutable`, `coinbaseaux`, `noncerange`, `longpollid`, `capabilities`, `rules` echo, `vbavailable`, `vbrequired`. The Rust port can choose to honour or continue ignoring these. Notably, dropping `mutable` is questionable for any pool that wants to be conservative about which fields it edits.

### Notification strategy ("blocknotify dance")

**Dual notification:**

1. **Primary:** OS signal handler sets an atomic flag.
   ```c
   void datum_blocktemplates_notifynew_sighandler() { new_notify = 1; }
   ```
   Operator wires `bitcoind -blocknotify="kill -USR1 <datum_pid>"` (or similar).

2. **Fallback:** dedicated thread polls `getbestblockhash` once a second, compares to last-known hash, sets the same flag on change. Enabled by config `bitcoind_notify_fallback`.

3. **Periodic refresh:** main loop sleeps in 2500 µs increments, re-fetches GBT every `bitcoind_work_update_seconds` regardless of notification.

### `submitblock` — not in `datum_blocktemplates.c`

The fetch + notification module is template-only. `submitblock` lives elsewhere in DATUM (likely the share/block-found pipeline). The Rust port should still expose it on the same client.

## Implications for the Rust port

1. **Drop the dual-notification pattern.** Replace both the signal handler *and* the fallback poller with a single async long-poll loop using `longpollid`. This is the canonical Bitcoin Core mechanism — bitcoind holds the connection until either (a) a new block arrives, (b) the mempool changes enough to warrant a fresh template (controlled by `-blockmaxweight` cadence), or (c) ~60s timeout. The C code reinvents this in two layers because libcurl long-poll handling is unpleasant.

2. **Honour `mutable`.** `corepc-types::v29::mining::GetBlockTemplate` deserializes it; the pool logic should at minimum verify `coinbase/append`, `coinbase` and `transactions/add` permissions before mutating coinbaseaux or pruning fee txs.

3. **Add TLS as an option.** Enable `reqwest`'s `rustls-tls` feature; gate it behind a config flag (`bitcoind_use_tls = true`). This costs nothing when disabled and unblocks operators running bitcoind behind an stunnel/nginx terminator.

4. **Cookie-refresh path is identical.** On 401, re-read the cookie file and retry once. Same logic as C, ~25 LOC of Rust.
