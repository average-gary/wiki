---
title: "SRI master (stratum-mining/stratum) — track for breaking changes during Phase 3"
kind: watch
status: active
priority: p2
created: 2026-06-01
updated: 2026-06-01
last_checked: 2026-06-01
next_action: "During Phase 3, monitor stratum-mining/stratum master for breaking changes to channels_sv2::server::ExtendedChannel, JobFactory, JobStore, ExtranonceAllocator, or the handlers async traits. Pin version in datum-rs/Cargo.toml; bump deliberately."
sources:
  - output/plan-bootstrap-datum-rs-2026-06-01.md
  - wiki/concepts/sv2-downstream-architecture.md
  - https://github.com/stratum-mining/stratum
tags: [datum-rs, phase-3, sri, sv2, dependency-tracking, watch]
confidence: high
summary: "datum-rs Phase 3 reuses ~9600 LOC from SRI's channels_sv2 + handlers_sv2 + framing/codec/noise crates (6:1 reuse ratio per sv2-downstream-architecture). SRI master moves; breaking changes during Phase 3 SV2 server work are a tracked risk."
---

# SRI master (stratum-mining/stratum)

## Why Track This

[sv2-downstream-architecture](../../wiki/concepts/sv2-downstream-architecture.md) maps datum-rs's SV2 downstream onto SRI's `ExtendedChannel::new_for_pool` + `JobFactory::new_extended_job` + `DefaultJobStore<ExtendedJob>`. This reuse is 6:1 (~9600 LOC reused vs ~1500 LOC written), so SRI breakage during Phase 3 stalls the whole SV2 path.

## Current State

Repo is active (`stratum-mining/stratum`); the [stratum-sri wiki](../../../stratum-sri/_index.md) tracks workspace layout and PR history.

## Watch Triggers

Bump-worthy events:
- Breaking changes to `channels_sv2::server::ExtendedChannel` API surface (especially `new_for_pool`).
- Breaking changes to `JobFactory::new_extended_job` signature or `additional_coinbase_outputs` semantics.
- Changes to `DefaultJobStore<ExtendedJob>` or the `JobStore` trait.
- Changes to `ExtranonceAllocator` or the 12-byte total-extranonce-len contract.
- Changes to `HandleMiningMessagesFromClientAsync` async trait shape.
- New SRI release tags (predictable upgrade points).

## Notes

- Cargo.toml strategy: pin a specific git rev or version during Phase 3; track upstream via a TODO comment in Cargo.toml.
- Cross-reference with [stratum-sri wiki](../../../stratum-sri/_index.md) for workspace context.
