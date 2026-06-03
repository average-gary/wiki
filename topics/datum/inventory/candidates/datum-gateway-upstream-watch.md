---
title: "OCEAN-xyz/datum_gateway master — track for protocol-version bumps"
kind: watch
status: active
priority: p2
created: 2026-06-01
updated: 2026-06-01
last_checked: 2026-06-01
next_action: "Watch OCEAN-xyz/datum_gateway commits for: (1) protocol-version string changes (currently \"v0.4.1-beta\" on master); (2) datum_protocol.c wire-format changes; (3) datum_conf.c hardcoded OCEAN pubkey changes; (4) coinbaser blob format changes."
sources:
  - output/plan-bootstrap-datum-rs-2026-06-01.md
  - wiki/concepts/datum-protocol-rust-implementation.md
  - https://github.com/OCEAN-xyz/datum_gateway
tags: [datum-rs, datum-protocol, ocean, upstream, watch, version-drift]
confidence: high
summary: "datum-rs targets byte-exact compat with the C reference. Upstream protocol-version bumps, wire-format changes, or coinbaser blob format changes propagate directly into the Rust port. Path 1 already observed a 2025-12-17 triple-bump (0.2.6 / 0.3.3 / 0.4.1 maintenance branches) — drift is a known pattern."
---

# OCEAN-xyz/datum_gateway upstream

## Why Track This

The DATUM Prime wire-protocol spec is the C source. Any change in `datum_protocol.c`, `datum_conf.c`'s hardcoded OCEAN pubkey, or `datum_coinbaser.c`'s V2 blob format propagates directly into Rust port byte-exact compat tests.

This is the highest-severity engineering risk for the project ([drop-in-rust-datum-gateway § risks](../../wiki/topics/drop-in-rust-datum-gateway.md#risks--open-questions)) — protocol drift mid-development can invalidate work in `datum-protocol`, `datum-coinbaser`, and the live OCEAN handshake.

## Current State

Master HEAD is `v0.4.1-beta` (Jan 2026). Path 1 finding: 2025-12-17 triple-bump across 0.2.6 / 0.3.3 / 0.4.1 maintenance branches — drift is observed behavior, not hypothetical.

## Watch Triggers

Bump-worthy events:
- Version string changes (`v0.4.1-beta` → anything else).
- Commits touching `datum_protocol.c` (especially wire format, opcodes, frame layout).
- Commits touching `datum_conf.c` (especially OCEAN pool pubkey or default endpoints).
- Commits touching `datum_coinbaser.c` (V2 blob format, coinbase output ordering).
- New release tags.
- New maintenance branches (signal of fork-point preserved older versions).

## Notes

- `~/repos/datum_gateway/` is the local clone reference; pull periodically.
- Coordinate with OCEAN engineering when feasible; the project's [OCEAN SV2 stance](../../wiki/concepts/ocean-sv2-stance-and-prior-art.md) suggests low cooperation likelihood but the watch is independent of cooperation.
