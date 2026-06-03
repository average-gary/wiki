---
title: "OCEAN production server protocol version verified via live handshake probe"
kind: question
status: blocked
priority: p0
created: 2026-06-01
updated: 2026-06-02
last_checked: 2026-06-02
next_action: "Probe ran against datum-beta1.mine.ocean.xyz:28915 (commit d66fc64). All four version fall-backs (v0.4.1-beta, v0.3.3, v0.2.6, v0.4.1, v0.4.0-beta) result in recv_len=0 — pool drops connection cleanly without responding. Wire format reaches OCEAN but is rejected silently. Next step: capture a real C-emitted PING from a local datum_gateway pointed at `nc -l` and compare byte-for-byte with our framed hello. Most likely causes: header bitfield byte ordering, sealed-box pubkey rotation, or inner Ed25519 signature failure."
sources:
  - output/plan-bootstrap-datum-rs-2026-06-01.md
  - wiki/concepts/datum-protocol-rust-implementation.md
tags: [datum-rs, phase-1, phase-2, blocker, datum-protocol, ocean, version-drift]
confidence: medium
summary: "Phase 2 gating question: does OCEAN's production DATUM Prime endpoint accept a Rust client speaking master-version v0.4.1-beta? Path 1 finding (2025-12-17 triple-bump across 0.2.6 / 0.3.3 / 0.4.1 maintenance branches) suggests production may run an older version. Blocker for Phase 3 if the probe fails and no fall-back string works."
---

# OCEAN production server protocol version

## Why Track This

Phase 2 of the datum-rs Phase 1 plan ([plan-bootstrap-datum-rs-2026-06-01.md](../../output/plan-bootstrap-datum-rs-2026-06-01.md)) gates further Phase 3 work on a successful live handshake against production OCEAN DATUM Prime. The wiki's known-unknowns table flags this as a high-severity unknown ([datum-protocol-rust-implementation § production version drift](../../wiki/concepts/datum-protocol-rust-implementation.md#production-version-drift)).

If production rejects `v0.4.1-beta`, fall-back candidates from the 2025-12-17 triple-bump are `v0.3.3` and `v0.2.6`. If none works, this becomes a Phase 3 blocker requiring escalation to OCEAN engineering or revisiting project assumptions.

## Current State

**Probe ran 2026-06-02 (commit d66fc64). Outcome: recv_len=0 across every version string tried.**

Run summary:
```
./target/release/handshake_probe --timeout-secs 30 --save-capture /tmp/datum-rs-probe-capture.bin
  → TCP connect to datum-beta1.mine.ocean.xyz:28915: success
  → 421 bytes sent (4-byte XOR'd header + 417-byte sealed payload)
  → 0 bytes received before clean connection close
  → FAILED: response cmd_len 0 exceeds 1MB sanity cap
```

Tried `v0.4.1-beta`, `v0.3.3`, `v0.2.6`, `v0.4.1`, `v0.4.0-beta` — all produce identical `recv_len=0`.

This is *not* a connectivity issue (TCP is fine) and *not* a version drift issue (all variants fail identically). The pool processes our hello and silently rejects it. Three plausible root causes ranked by probability:

1. **Header bitfield byte-ordering**: our `frame::pack()` produces the 4-byte header as little-endian; the C struct may serialize differently because C bitfield ordering is implementation-defined. The pool de-XORs the header, gets gibberish, hangs up.
2. **Sealed-box pubkey rotation**: the 128-hex pubkey hardcoded in `datum_conf.c` may have been rotated since 2026-01; `crypto_box_seal` to a stale pubkey produces ciphertext OCEAN cannot decrypt.
3. **Inner Ed25519 signature verification fails on the pool side**: our hello signature is over fields 1-9 of the plaintext; if the C reference computes the signature over a slightly different range (e.g. excluding padding, or pre-trailing-padding), pool verification fails.

Next step is **capture-and-pin** — block the inventory candidate `datum-header-bitfield-byte-ordering` rather than this one until we have a real C-emitted PING fixture to diff against.

## Close-out Condition

Hello-world Rust client (datum-protocol handshake_probe binary) successfully completes the libsodium-box handshake against `datum-beta1.mine.ocean.xyz:28915` and the accepted version string is documented in MIGRATING.md.

## Notes

- Probe target: `datum-beta1.mine.ocean.xyz:28915` (testnet/beta endpoint).
- OCEAN long-term pubkey: hardcoded in datum_conf.c (default), 128 hex chars (Ed25519 + X25519).
- Fall-back order: `v0.4.1-beta` → `v0.3.3` → `v0.2.6` → escalate.
