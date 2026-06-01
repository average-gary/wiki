---
title: "SV2 Template Distribution Subprotocol"
category: topic
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-template-distribution-readme.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, template-distribution, tdp, subprotocol, block-templates, bitcoin-core, no-std]
aliases: ["template_distribution_sv2", "TDP", "Template Distribution Protocol"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "The Template Distribution Protocol (TDP) ferries block-template updates between a Bitcoin node and an SV2 role that needs them — typically a Job Declarator Client. Implemented as the `template_distribution_sv2` `#![no_std]` crate."
---

# SV2 Template Distribution Subprotocol

> TDP is the boundary between Bitcoin's block-template engine and SV2's job pipeline. It lets an SV2 role subscribe to template updates, which it then turns into custom work via [[sv2-job-declaration-subprotocol|JDP]] ([JDP](sv2-job-declaration-subprotocol.md)) or routes directly into [[sv2-mining-subprotocol|mining]] ([mining](sv2-mining-subprotocol.md)) jobs.

## Scope

Per the README, `template_distribution_sv2` is a `#![no_std]` Rust crate that "implements a set of messages defined in the Template Distribution Protocol of Stratum V2. The Template Distribution protocol can be used to receive updates of the block templates to use in mining."

The normative spec lives at [stratumprotocol.org § 07 Template Distribution Protocol](https://stratumprotocol.org/specification/07-Template-Distribution-Protocol/).

## Build options

The crate has one feature flag:

- `prop_test` — enables property-test scaffolding.

## Position in the SV2 stack

```
   bitcoind  ──TDP──►  JDC  ──JDP──►  JDS  ──Mining──►  miners
                       │
                       └── (or directly into Mining if no JDP)
```

A Bitcoin node runs the SV2 TDP server side (in SRI's reference Bitcoin Core branch, or a separate adapter); the SV2 role consumes templates, optionally turns them into JDP-declared custom work, and ultimately the [[sv2-mining-subprotocol|Mining subprotocol]] ([Mining subprotocol](sv2-mining-subprotocol.md)) ships work to devices.

## Framing note

Like [[sv2-job-declaration-subprotocol|JDP]] ([JDP](sv2-job-declaration-subprotocol.md)), TDP frames always have `channel_msg = 0` per [[sv2-framing|SV2 framing]] ([SV2 framing](../concepts/sv2-framing.md)) — the TDP relationship is per-connection, not per mining-channel.

## See Also

- [[sv2-job-declaration-subprotocol|SV2 Job Declaration Subprotocol]] ([SV2 Job Declaration Subprotocol](sv2-job-declaration-subprotocol.md)) — typical downstream consumer of TDP
- [[sv2-mining-subprotocol|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](sv2-mining-subprotocol.md)) — eventual destination of the work the templates become
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](stratum-core-umbrella.md)) — re-exports `template_distribution_sv2`

## Sources

- [template_distribution_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-template-distribution-readme.md) — purpose, no_std, `prop_test` flag, link to spec
