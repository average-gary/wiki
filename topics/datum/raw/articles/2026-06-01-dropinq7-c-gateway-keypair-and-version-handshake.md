---
title: "C Gateway Keypair Handling and Version-Mismatch Behavior — Two Hard Constraints for Drop-In"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_protocol.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: dropinq7
research_path: dropinq7-switch-day-runbook
quality_score: 9
tags: [datum, datum-gateway, drop-in, migration, keypair, libsodium, protocol-version, handshake]
related_concepts: [drop-in-replacement, switch-day-runbook, rollback, migrating-md]
---

# C Gateway Keypair Handling and Version-Mismatch Behavior

Two findings from `src/datum_protocol.c` (master) that materially shape the
operator switch-day procedure for a Rust drop-in replacement.

## Finding 1 — Keypairs are ephemeral, generated each run

`datum_protocol_init()` (around line 1778) calls
`datum_encrypt_generate_keys()` (lines ~1821–1832), which produces fresh
**Ed25519** signing keys and **X25519** Noise/handshake keys via libsodium.

There is **no file I/O** in this path. The keys live only in process memory.
Each `systemctl restart datum-gateway` (or container restart) generates a
brand-new keypair.

Implication for the migration: there is **no on-disk keypair file the
operator has to back up**. The "back up the keypair" item in the original
question is a non-task. The Rust drop-in inherits a free hand: it can
either (a) preserve the ephemeral model exactly, or (b) introduce a
persistent keypair file as a *new* feature with no backwards-compat
constraint to honor.

The pool's public key, by contrast, **is** in the config file:
`datum.pool_pubkey` (64-char hex). That belongs to the config-backup
workflow, not a separate keypair-backup workflow.

## Finding 2 — Version-mismatch behavior is hard-close, not graceful

The protocol carries a config-version byte. `datum_protocol.c` checks it
and, on mismatch, logs and tears down the connection without negotiation:

- Line ~913: `"Bad configuration version from server. Is this client up to date?"`
- Line ~1019: `"Unknown protocol command from server 0x%2.2x. It this client up to date???"` (sic — typo "It this" preserved)
- The handler returns `0` (failure); the main loop sees the failure and
  closes the TCP connection.

There is no version-renegotiation, no fallback, no operator-friendly
"server speaks v2, you speak v1, please upgrade" message. The operator
sees: connection drops, log line "Is this client up to date?", and the
gateway cycles through reconnects.

Implication for the migration:

1. The Rust drop-in must implement the same on-wire version byte
   exactly. Any drift breaks every existing operator's handshake against
   DATUM Prime.
2. The Rust drop-in is also free to **strictly improve** the operator
   experience here: emit a structured error line on version mismatch
   (e.g. JSON with `our_version`, `their_version`, fix-it URL) without
   breaking the wire protocol. This costs nothing on-wire and is a
   visible operator win.
3. During a switchover, if the Rust drop-in's protocol version differs
   from the C gateway's, the symptom is identical to today: connection
   loops, log spam. That's the most likely class of bug an operator
   will hit on day one.

## Switch-day implications

| Pre-switch task | Status |
|---|---|
| Backup keypair file | **N/A — no file exists** |
| Backup config | Required (contains `datum.pool_pubkey`, RPC creds, miner config) |
| Note authentication state | N/A — re-handshake on every connect; the auth state is non-persistent |
| Note protocol version | Required — must match between C gateway version and Rust drop-in |

| Failure mode | Symptom | Recovery |
|---|---|---|
| Wire-version mismatch | `"Bad configuration version from server"` log loop | Roll back to C binary, file issue with both versions |
| Pool-pubkey mismatch | Handshake never completes | Verify `datum.pool_pubkey` unchanged in copied config |
| Ephemeral-key regen | None — expected behavior | None |

## Justification

The keypair-backup question dissolves once you read the source: there is
nothing to back up. The version-handshake question is the real risk axis.
This article anchors the switch-day runbook's pre-switch checklist on the
C gateway's actual behavior rather than assumed behavior.

## Sources

- [`datum_gateway/src/datum_protocol.c`](https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_protocol.c)
  — keypair generation around lines 1778–1832; version-mismatch logging
  around lines 913 and 1019.
