---
title: "SV2 Mining Subprotocol"
category: topic
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-mining-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-common-messages-readme.md
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, mining-sv2, subprotocol, mining-protocol, common-messages-sv2, no-std]
aliases: ["mining_sv2", "Mining Protocol", "Sv2 mining"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "The SV2 Mining subprotocol — work distribution, share submission, and (with JDP) custom-work notification. Implemented by `mining_sv2` (a `no_std` crate) plus shared `common_messages_sv2` like SetupConnection."
---

# SV2 Mining Subprotocol

> The Mining subprotocol is what most people mean when they say "Stratum V2": the path between mining devices/proxies and pools that distributes work, accepts shares, and notifies of new prev hashes. SRI ships it as the `mining_sv2` crate.

## Scope

Per the README, `mining_sv2` enables:

- **Distribution of work** to mining devices.
- **Submission of proof of work** from mining devices.
- **Notification of custom work to pool**, in conjunction with the [[sv2-job-declaration-subprotocol|Job Declaration Subprotocol]] ([Job Declaration Subprotocol](sv2-job-declaration-subprotocol.md)).

The crate is `#![no_std]`. The normative spec lives at [stratumprotocol.org § 05 Mining Protocol](https://stratumprotocol.org/specification/05-Mining-Protocol/).

## Common-messages relationship

`common_messages_sv2` is a separate `#![no-std]` crate of messages "shared across all Stratum V2 subprotocols" — `SetupConnection`, capability/auth handshake, etc. It compiles without `std` and supports `quickcheck`-based property testing via the `quickcheck` feature. Mining roles always pull both crates because the mining subprotocol does not redefine setup/handshake.

## Channel model

Mining messages flow over the channel kinds described in [[sv2-channels|SV2 channels]] ([SV2 channels](../concepts/sv2-channels.md)):

- **Standard channels** for direct miner-to-pool work (`OpenStandardMiningChannel`, `SubmitSharesStandard`).
- **Extended channels** for proxies/translators (`OpenExtendedMiningChannel`, `SubmitSharesExtended` — also where [[sv2-extensions|Worker-Specific Hashrate Tracking TLVs]] ([Worker-Specific Hashrate Tracking TLVs](../concepts/sv2-extensions.md)) live).
- **Group channels** for server-side fanout.

Channel and share-state machines live in `channels_sv2`, not `mining_sv2`. `mining_sv2` is the message-type crate; the state machine that interprets those messages is its consumer.

## Recent change surface

Recent PRs touching the mining subprotocol's behavior, observed at HEAD:

- **#2162 / `df4e764d`** — adds `ERROR_CODE_OPEN_MINING_CHANNEL_EXTENDED_CHANNELS_NOT_SUPPORTED_FOR_STANDARD_JOBS`, distinguishing standard-job channel requests against extended-channels-only servers.
- **#2156 / `cc3977e5`** — fixes a `validate_share` panic after `on_set_new_prev_hash` in custom-work mode (custom-work is the JDP path).
- **#2149 / `5e1b025f`** — `channels_sv2::server::share_accounting` now tracks rejected shares alongside accepted ones.

These are wire-protocol-adjacent changes; they reshape what error/state cases roles must handle, even though the message-type definitions move slowly. See [[sri-pull-request-themes|SRI PR themes]] ([SRI PR themes](../references/sri-pull-request-themes.md)) for context.

## See Also

- [[sv2-channels|SV2 Channels]] ([SV2 Channels](../concepts/sv2-channels.md)) — channel kinds and share accounting
- [[sv2-job-declaration-subprotocol|SV2 Job Declaration Subprotocol]] ([SV2 Job Declaration Subprotocol](sv2-job-declaration-subprotocol.md)) — custom-work declaration that drives the JDP-path mining flow
- [[sv2-template-distribution-subprotocol|SV2 Template Distribution Subprotocol]] ([SV2 Template Distribution Subprotocol](sv2-template-distribution-subprotocol.md)) — where templates come from when JDP is in use
- [[sv2-extensions|SV2 Extensions]] ([SV2 Extensions](../concepts/sv2-extensions.md)) — Worker-Specific Hashrate Tracking TLVs in `SubmitSharesExtended`
- [[sri-pull-request-themes|SRI Pull Request Themes]] ([SRI Pull Request Themes](../references/sri-pull-request-themes.md)) — recent share-accounting and error-code changes
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](stratum-core-umbrella.md)) — re-exports `mining_sv2`

## Sources

- [mining_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-mining-readme.md) — scope, no_std, link to spec
- [common_messages_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-common-messages-readme.md) — shared setup/handshake messages
- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — recent commits #2162/#2156/#2149 touching mining behavior
