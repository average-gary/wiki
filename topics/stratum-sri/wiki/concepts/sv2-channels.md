---
title: "SV2 Channels"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-channels-sv2-readme.md
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, channels-sv2, channels, share-accounting, mining-server, mining-client, no-std]
aliases: ["channels_sv2", "Sv2 channel", "standard channel", "extended channel", "group channel"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "`channels_sv2` is the channel-management layer for SV2 mining: standard, extended, and group channel state, share accounting on the server side, and a `client` module that compiles `no_std` for embedded mining clients via `hashbrown`+`core`+`alloc`."
---

# SV2 Channels

> Mining work in SV2 flows over **channels**. `channels_sv2` provides the state machines and primitives both clients (mining devices, proxies) and servers (pools, JD-Servers) use to open, route, and account for those channels.

## Channel kinds

The README states the crate "implements the core channel management functionality for both mining clients and servers, including standard, extended and group channels, and share accounting mechanisms." These three kinds correspond to the SV2 [[sv2-mining-subprotocol|mining subprotocol]] ([mining subprotocol](../topics/sv2-mining-subprotocol.md))'s `OpenStandardMiningChannel` / `OpenExtendedMiningChannel` paths and the group abstraction proxies use to fan work out:

- **Standard channel** — one mining device, fixed-difficulty work, shares submitted as `SubmitSharesStandard`.
- **Extended channel** — one logical work source that can issue work to many devices, often used by translation proxies that aggregate downstream SV1 miners.
- **Group channel** — server-side grouping of standard channels for fanout/efficiency.

## Module shape

The crate has two top-level concerns:

- `client` module — channel state suitable for the mining-client side (downstream).
- Server-side state — including `channels_sv2::server::share_accounting` (introduced in PR #2149, `5e1b025f`, which made the rejected-shares counter explicit alongside the accepted-shares one).

The server side is also where the [[sri-pull-request-themes|PR #2156 / `cc3977e5`]] ([PR #2156 / `cc3977e5`](../references/sri-pull-request-themes.md)) panic fix landed: `validate_share` could panic after `on_set_new_prev_hash` in custom-work mode. That fix is a load-bearing reason this crate is currently classified `volatility: warm` rather than `cold`.

## `no_std` for clients

The `client` module is `no_std`-compatible. Building with the `no_std` feature swaps the standard-library collections for `hashbrown`, plus `core` and `alloc`, so the channel state machine can run in embedded firmware without `std`:

```bash
cargo build --features no_std
```

This is the foundation that lets a low-power mining device speak SV2 directly without a translator.

## Share accounting

Share accounting is the server-side bookkeeping that decides which submitted shares count for payout. The recent PR series (#2149, #2156, #2162) made the surface area more explicit:

- `channels_sv2::server::share_accounting` tracks both **accepted** and **rejected** shares (PR #2149).
- `validate_share` survives `on_set_new_prev_hash` in custom-work mode without panicking (PR #2156).
- A new error code `ERROR_CODE_OPEN_MINING_CHANNEL_EXTENDED_CHANNELS_NOT_SUPPORTED_FOR_STANDARD_JOBS` distinguishes a misconfigured channel-mode request from generic open-channel failures (PR #2162).

See [[sri-pull-request-themes|SRI PR themes]] ([SRI PR themes](../references/sri-pull-request-themes.md)) for the specific commits.

## See Also

- [[sv2-mining-subprotocol|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](../topics/sv2-mining-subprotocol.md)) — message set that drives channel lifecycle
- [[sv2-message-handlers|SV2 Message Handlers]] ([SV2 Message Handlers](sv2-message-handlers.md)) — dispatches channel messages to user code
- [[sri-pull-request-themes|SRI Pull Request Themes]] ([SRI Pull Request Themes](../references/sri-pull-request-themes.md)) — recent share-accounting work
- [[sv2-job-declaration-subprotocol|SV2 Job Declaration Subprotocol]] ([SV2 Job Declaration Subprotocol](../topics/sv2-job-declaration-subprotocol.md)) — drives the custom-work mode `validate_share` fix landed in
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `channels_sv2`

## Sources

- [channels_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-channels-sv2-readme.md) — channel kinds, `no_std` client mode, share accounting
- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — recent commits/PR themes touching `channels_sv2`
