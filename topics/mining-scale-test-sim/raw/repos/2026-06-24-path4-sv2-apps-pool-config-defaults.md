---
title: sv2-apps Pool — share_batch_size and shares_per_minute defaults
source_type: repos
source_url: https://github.com/marafoundation/sv2-apps/blob/mara/pool-apps/pool/config-examples/mainnet/pool-config-bitcoin-core-ipc-example.toml
fetched: 2026-06-24
path: 4
tags: [sv2-apps, pool, configuration, shares-per-minute, batch-size]
---

# sv2-apps Pool — production-style config defaults

Mara's `sv2-apps` (the integration product on top of SRI) ships
example configs that bake in operational defaults Mara is using.

## Mainnet Pool example (verbatim excerpt)

```toml
# SRI Pool config
authority_public_key = "9auqWEzQDVyd2oe1JVGFLMLHZtCo2FFqZwtKA5gd9xbuEu7PH72"
listen_address = "0.0.0.0:3333"
...

# How many shares we expect to receive in a minute (determines difficulty targets)
shares_per_minute = 6.0
# How many shares do we want to acknowledge in a batch
share_batch_size = 10

# Monitoring HTTP server address for exposing channel data (optional)
monitoring_address = "127.0.0.1:9090"
monitoring_cache_refresh_secs = 15
```

## Implications

- **shares_per_minute = 6.0** ⇒ vardiff target is 1 share / 10 s per
  channel. This is the value passed into
  `StandardChannel::new_for_pool(...)` and used to compute
  `hash_rate_to_target(nominal_hashrate, 6.0)`. (Confirmed in
  `pool-apps/pool/src/lib/channel_manager/mining_message_handler.rs:174`
  where the `share_batch_size` and `shares_per_minute` are threaded
  into channel construction.)
- **share_batch_size = 10** ⇒ Pool sends 1 SubmitShares.Success per 10
  accepted shares. This is purely a wire optimization; the validation
  itself happens per-share.
- **monitoring_cache_refresh_secs = 15** ⇒ Prometheus scrape interval
  for `shares_accepted`, `shares_rejected_by_reason`,
  `share_work_sum`, `best_diff`, `last_batch_accepted` (see
  `pool-apps/pool/src/lib/monitoring.rs`). Per-channel metrics are
  emitted, so the monitoring path scales O(channels) per refresh.

## Share rate math at SV2 defaults

| Connections (N) | Aggregate shares/sec | Aggregate shares/min |
|---|---|---|
| 1,000 | 100 | 6,000 |
| 10,000 | 1,000 | 60,000 |
| 100,000 | 10,000 | 600,000 |
| 1,000,000 | 100,000 | 6,000,000 |

At 6 SPM (higher than ckpool's ~3.33 s vardiff target ratio in the
common case but still vardiff-clamped), N=100k channels generates
**10,000 shares/sec aggregate**. At ~10–20 µs/share on one core, that
saturates roughly **0.1–0.2 cores worth of pure validation work** — so
~5–10 modern x86 cores would handle the validation cost for **1
million simultaneous SV2 connections**.

## Sibling configs

The same directory also has `pool-jds-config-bitcoin-core-ipc-example.toml`
which enables the embedded Job Declaration Server. The JDS config does
not change `shares_per_minute` or `share_batch_size`; those are still
in the pool-side config block. So JD-mode pools observe the same
per-share validation cost (the JD validates **once per template
declaration**, not per share — see
`/raw/repos/2026-06-24-path4-jds-template-validation-amortized.md`).
