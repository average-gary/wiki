---
title: "SV2 Message Handlers"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-handlers-sv2-readme.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, handlers-sv2, traits, sync, async, message-dispatch]
aliases: ["handlers_sv2", "Sv2 handler", "Sv2 server handler", "Sv2 client handler"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "`handlers_sv2` defines the trait surface for handling decoded SV2 messages. Server vs client variants per role, and per-subprotocol opt-in (Mining, TemplateDistribution, Common, JobDeclaration, Extensions). Both sync and async versions ship, so the same trait set works in tokio and embedded contexts."
---

# SV2 Message Handlers

> Once the [[sv2-codec|codec]] ([codec](sv2-codec.md)) and [[sv2-binary-encoding|parsers]] ([parsers](sv2-binary-encoding.md)) have produced a typed Rust message, something has to dispatch on it. `handlers_sv2` is that dispatch surface — a set of traits an SV2 role implements to take action on messages it cares about.

## Role and subprotocol opt-in

The README describes two perpendicular splits:

- **Role** — separate trait variants for **servers** (Pool, JDS, etc.) and **clients** (mining device, JDC, etc.).
- **Subprotocol** — implementors pick the message families they support: `Mining`, `TemplateDistribution`, `Common`, `JobDeclaration`, or `Extensions`.

A Pool typically implements server-side `Mining` + `Common` (+ `JobDeclaration` if it accepts JDC-declared jobs). A mining device implements client-side `Mining` + `Common`. A Job Declarator Server implements server-side `JobDeclaration` + `TemplateDistribution`. The opt-in shape lets each role compile only the trait impls it uses.

## Sync and async variants

Both synchronous and asynchronous trait flavors exist. Async lets handlers integrate with `tokio` or any executor; sync keeps the path open for embedded or single-threaded code that doesn't want a runtime — and works alongside the `no_std` `client` module from [[sv2-channels|`channels_sv2`]] ([channels_sv2](sv2-channels.md)).

## Where it sits

```
   bytes ──► codec_sv2 ──► parsers_sv2 ──► typed message
                                                │
                              handlers_sv2 trait dispatch
                                                │
                                          role-specific code
                                          (Pool, JDS, miner…)
```

`handlers_sv2` is the boundary between the protocol library and application code: above it, you get typed messages; below it, you build an SV2 role.

## See Also

- [[sv2-codec|SV2 Codec]] ([SV2 Codec](sv2-codec.md)) — produces the bytes the handlers ultimately receive
- [[sv2-binary-encoding|SV2 Binary Encoding]] ([SV2 Binary Encoding](sv2-binary-encoding.md)) — typed message construction by `parsers_sv2`
- [[sv2-channels|SV2 Channels]] ([SV2 Channels](sv2-channels.md)) — channel state the mining handlers operate on
- [[sv2-extensions|SV2 Extensions]] ([SV2 Extensions](sv2-extensions.md)) — extension messages dispatched via the `Extensions` handler
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `handlers_sv2`

## Sources

- [handlers_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-handlers-sv2-readme.md) — role × subprotocol trait shape, sync/async variants
