# Long-poll → async Rust translation pattern

**Fetched:** 2026-06-01

The DATUM C code uses signal-handler + 1Hz `getbestblockhash` polling instead of GBT's native long-poll. The Rust port can use long-poll natively and delete both fallbacks.

## How bitcoind's GBT long-poll works

1. Client issues `getblocktemplate {"rules":["segwit"]}` and receives a `GetBlockTemplate` response containing a `longpollid: String` (opaque cookie tied to template state — typically `"<prevhash><counter>"`).
2. Client immediately re-issues `getblocktemplate {"rules":["segwit"], "longpollid":"<that string>"}`.
3. bitcoind holds the connection open until **either** the chain tip changes **or** mempool drift warrants a fresh template **or** ~60s pass.
4. On return, client receives a fresh `GetBlockTemplate` (with a new `longpollid`); loop.

This collapses the C code's dual-notification mess into one stateful loop.

## Async Rust skeleton

```rust
use std::time::Duration;
use tokio::sync::watch;

pub struct GbtClient {
    http: reqwest::Client,
    url:  reqwest::Url,
    auth: Auth,             // UserPass | CookieFile
}

impl GbtClient {
    /// Returns a watch channel that emits every fresh template.
    /// One spawned task per node. Cancel by dropping the receiver
    /// and calling cancel_token.cancel().
    pub fn spawn(self, cancel: tokio_util::sync::CancellationToken)
        -> watch::Receiver<Option<GetBlockTemplate>>
    {
        let (tx, rx) = watch::channel(None);
        tokio::spawn(async move {
            let mut longpollid: Option<String> = None;
            loop {
                if cancel.is_cancelled() { break; }

                let params = match &longpollid {
                    None    => serde_json::json!([{ "rules": ["segwit"] }]),
                    Some(l) => serde_json::json!([{ "rules": ["segwit"], "longpollid": l }]),
                };

                // Generous timeout for the long-poll variant; short for the first call.
                let timeout = if longpollid.is_some() {
                    Duration::from_secs(75)
                } else {
                    Duration::from_secs(10)
                };

                match self.call::<GetBlockTemplate>("getblocktemplate", &params, timeout).await {
                    Ok(tpl) => {
                        longpollid = Some(tpl.longpollid.clone());
                        let _ = tx.send(Some(tpl)); // last-writer-wins
                    }
                    Err(e) => {
                        tracing::warn!(?e, "GBT failed; backing off");
                        tokio::time::sleep(Duration::from_secs(2)).await;
                        // Don't reuse a stale longpollid after a failure — bitcoind
                        // restart would have invalidated it; force a fresh fetch.
                        longpollid = None;
                    }
                }
            }
        });
        rx
    }
}
```

## Why this is strictly better than the C path

| Concern                           | C dual-notification                                      | Rust long-poll loop                          |
| --------------------------------- | -------------------------------------------------------- | -------------------------------------------- |
| Latency to new template after tip | ≤1s (poll) or signal latency                             | <100ms (bitcoind returns immediately on tip) |
| RPC load on bitcoind              | 1 `getbestblockhash`/sec **per gateway**                 | One held connection per gateway              |
| Mempool drift template refresh    | Periodic timer only (`bitcoind_work_update_seconds`)     | Native — bitcoind decides                    |
| Operator setup                    | Must wire `-blocknotify=kill -USR1` *and* enable poller  | Zero config beyond URL/auth                  |
| Process boundary coupling         | Signal-based; brittle under containerisation             | Pure HTTP                                    |
| Code complexity                   | Signal handler + poller thread + atomic flag + main loop | One async fn + one watch channel             |

## Auth helper sketch

```rust
pub enum Auth {
    UserPass { user: String, pass: String },
    CookieFile(std::path::PathBuf),
}

impl Auth {
    async fn apply(&self, rb: reqwest::RequestBuilder)
        -> reqwest::Result<reqwest::RequestBuilder>
    {
        match self {
            Auth::UserPass { user, pass } => Ok(rb.basic_auth(user, Some(pass))),
            Auth::CookieFile(path) => {
                let raw = tokio::fs::read_to_string(path).await
                    .map_err(reqwest::Error::from /* wrap */ )?;
                let (u, p) = raw.trim().split_once(':').unwrap_or(("", ""));
                Ok(rb.basic_auth(u, Some(p)))
            }
        }
    }
}
```

On HTTP 401, drop and re-read the cookie file (handles bitcoind-restart-rotates-cookie case). One retry, then fail upward.

## Long-poll caveat — first-call vs subsequent

The very first GBT call has no `longpollid` and should use a short timeout (template is returned immediately). Only the *re-issue with longpollid* should use the long timeout. Mixing these causes either premature timeouts on real-block waits or pointless 75s waits for the first fetch.

## Submit-block in the same client

```rust
pub async fn submit_block(&self, raw_hex: &str) -> Result<()> {
    // bitcoind returns either null (success) or a string error like "rejected: bad-prevblk"
    let v: serde_json::Value = self.call("submitblock",
        &serde_json::json!([raw_hex]),
        Duration::from_secs(30)).await?;
    if v.is_null() { Ok(()) }
    else { Err(SubmitErr::Rejected(v.to_string())) }
}
```

`submitblock` is a one-shot, not part of the long-poll loop. Block found → call this, log result, move on. The C code's separate path can fold into the same client.

## Knots compatibility

Bitcoin Knots tracks Core's RPC surface 1:1 for `getblocktemplate`, `submitblock`, `getblockchaininfo`, `getmininginfo`. `corepc-types::v29::mining::GetBlockTemplate` deserializes Knots responses identically. The only Knots-specific divergences are policy-layer fields (e.g. additional mempool filters), none of which appear in the GBT response shape.
