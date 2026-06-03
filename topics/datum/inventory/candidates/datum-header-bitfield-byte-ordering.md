---
title: "DATUM header bitfield byte ordering captured from real C-emitted PING frame"
kind: question
status: active
priority: p1
created: 2026-06-01
updated: 2026-06-01
last_checked: 2026-06-01
next_action: "Run the C datum_gateway against a local mock OCEAN-style listener; capture a real PING frame; commit the captured bytes as a test fixture under crates/datum-protocol/tests/fixtures/; pin frame::pack/unpack against it before coding the rest of frame.rs."
sources:
  - output/plan-bootstrap-datum-rs-2026-06-01.md
  - wiki/concepts/datum-protocol-rust-implementation.md
tags: [datum-rs, phase-2, datum-protocol, frame-layout, capture-and-pin, test-fixture]
confidence: medium
summary: "DATUM frame header is a 32-bit packed bitfield (cmd_len 22b, reserved 2b, is_signed 1b, is_encrypted_pubkey 1b, is_encrypted_channel 1b, proto_cmd 5b). C bitfield byte ordering is implementation-defined; mismatches in Rust's pack/unpack are a high-severity byte-exact-compat hazard. Mitigation: capture-and-pin a real C-emitted PING."
---

# DATUM header bitfield byte ordering

## Why Track This

[datum-protocol-rust-implementation § known unknowns](../../wiki/concepts/datum-protocol-rust-implementation.md#known-unknowns-gating) flags header bitfield byte ordering as a **high-severity** byte-exact compat hazard. C bitfield ordering is compiler+ABI-dependent, so reading the spec is insufficient — we need an empirical fixture.

This is the first concrete test fixture for `crates/datum-protocol/`, so it gates the entire frame.rs/obfuscation.rs/crypto.rs chain.

## Current State

Unknown until a real PING is captured. The wiki documents the bitfield layout but not the on-the-wire byte order.

## Close-out Condition

A captured C-emitted PING frame is committed as a test fixture; `frame::pack` and `frame::unpack` round-trip cleanly against it; CI green.

## Notes

- 32-bit header packing: `cmd_len (22 bits)`, `reserved (2 bits)`, `is_signed (1)`, `is_encrypted_pubkey (1)`, `is_encrypted_channel (1)`, `proto_cmd (5 bits)`.
- Capture method: run the C gateway, point it at a TCP listener that logs raw bytes, observe the first PING.
- Related unknown: nonce segment width / carry propagation — same capture-and-pin technique.
