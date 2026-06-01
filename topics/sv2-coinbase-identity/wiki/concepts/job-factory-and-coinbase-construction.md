---
title: "JobFactory and coinbase construction (SRI)"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [SRI, JobFactory, coinbase, NewMiningJob, NewExtendedMiningJob, merkle-root]
---

# JobFactory — where SV2 coinbase bytes are assembled

`JobFactory` is owned per-channel and is the unit that turns a `NewTemplate` into a `NewMiningJob` (Standard) or `NewExtendedMiningJob` (Extended).

Constructor signature: `JobFactory::new(version_rolling_allowed: bool, pool_tag: Option<String>, miner_tag: Option<String>)` — `factory.rs:80-94`.

## Standard vs Extended job emission

### Standard channel
- `NewMiningJob` carries only `merkle_root`, not coinbase bytes.
- `JobFactory::new_standard_job` (factory.rs:144-218) computes:
  ```
  coinbase_tx_prefix = ... + /pool_tag/miner_tag/ + OP_PUSHBYTES + (zero-padded extranonce)
  coinbase_tx_suffix = ... (rest of coinbase tx)
  merkle_root = merkle_root_from_path(coinbase_tx_prefix, coinbase_tx_suffix, extranonce_prefix, merkle_path)
  ```
- The Pool can compute a **per-channel merkle_root** with a per-channel coinbase. Each Standard channel's miner sees only the merkle_root and cannot inspect the coinbase bytes.

### Extended channel
- `NewExtendedMiningJob` carries `coinbase_tx_prefix` and `coinbase_tx_suffix` directly — the miner sees the bytes.
- `JobFactory::new_extended_job` is called per-channel from `ExtendedChannel::on_new_template` (extended.rs:472).
- Group-channel broadcast is the *opt-in* alternate path (extended.rs:530, `on_group_channel_job`); per-channel emission is the default.

## The Pool / JDC asymmetry
| Path | `pool_tag` | `miner_tag` | Source of `miner_tag` |
|---|---|---|---|
| `new_for_pool` (non-JD) | `Some(...)` from pool config | **`None`** (hard-coded) | n/a |
| `new_for_job_declaration_client` | `Option<String>` from JDC config | `Some(...)` from JDC config | JDC (downstream) |

The thesis observes that `user_identity` is *already on the channel* in both paths — only the non-JD `new_for_pool` constructor chooses to discard it before reaching `JobFactory`.

## See also
- [[wiki/concepts/sv2-coinbase-scriptsig-layout]]
- [[wiki/concepts/coinbase-ownership-pool-vs-jdc]]
- [[wiki/concepts/user_identity-field]]
- [[raw/repos/2026-05-28-sri-channels-sv2-job-factory-and-channel-constructors]]
