---
title: "DATUM handshake interop: pool pubkey distribution and key persistence (2026-06-01)"
source: "datum_protocol.c, datum_conf.h, datum_conf.c at OCEAN-xyz/datum_gateway master HEAD"
type: articles
tags: [datum, handshake, libsodium, ocean-pubkey, key-persistence, ed25519, x25519, dropin-q2]
summary: "How the OCEAN pool's long-term public key is distributed (config string with hardcoded default in datum_conf.c, NOT compiled-in to datum_protocol.c), how the gateway's own keys are managed (ephemeral, regenerated every startup — there is NO persistence), and how the handshake state machine evolves. Default pool pubkey, hostname, and port quoted verbatim from master HEAD."
confidence: high
ingested: 2026-06-01
ingested_by: dropin-q2
quality_score: 5
---

# DATUM handshake interop notes

## OCEAN pool's long-term public key — where it lives

**The pool pubkey is config-supplied with a hardcoded default in `datum_conf.c`.** It is not embedded in `datum_protocol.c`.

Default values (verbatim from `datum_conf.c` option-parsing tables on master HEAD):

| Field | Default |
|---|---|
| `datum_pool_host` | `"datum-beta1.mine.ocean.xyz"` |
| `datum_pool_port` | `28915` |
| `datum_pool_pubkey` | `"f21f2f0ef0aa1970468f22bad9bb7f4535146f8e4a8f646bebc93da3d89b1406"` `"f40d032f09a417d94dc068055df654937922d2c89522e3e8f6f0e649de473003"` (concatenated 128-char hex) |

The pubkey is parsed by `datum_pubkey_to_struct()`:

```c
for(i=0;i<32;i++) key->pk_ed25519[i] = hex2bin_uchar(&input[i<<1]);          // bytes 0..32
for(i=0;i<32;i++) key->pk_x25519[i]  = hex2bin_uchar(&input[64+(i<<1)]);     // bytes 32..64
```

So the 128-hex-char string is **first 64 chars = Ed25519 pubkey, last 64 chars = X25519 pubkey**, in that order.

For the Rust port:

- Ship the same default as a compile-time constant.
- Parse with the same Ed25519-first-then-X25519 byte order.
- Allow override via `--datum-pool-pubkey` config (matches existing operator workflow).

## Client's own keys — NO persistence

This is a critical and somewhat surprising finding. The C source contains:

- No `fopen` related to key files.
- No `chmod`, no key-file path strings.
- `datum_encrypt_generate_keys()` is invoked at startup and produces fresh Ed25519 + X25519 keypairs every time the daemon launches.

```c
i = crypto_sign_keypair(keys->pk_ed25519, keys->sk_ed25519);
i = crypto_box_keypair(keys->pk_x25519, keys->sk_x25519);
```

**Every gateway restart presents a new identity to the pool.** This is unusual for a "long-term" key — in practice, OCEAN's "long-term" identity for a given gateway lives only as long as the process. For OCEAN-side share accounting, identity must be re-established by other means (presumably the Bitcoin payout address declared at config time, which the README confirms is the actual identity hook).

Implication for the Rust port: **no persistence required, but worth offering as a future enhancement.** Persisting the long-term keypair would let DATUM Prime's logs show stable client identities across restarts, which is operationally useful. But for byte-compat with the C gateway, regenerate on every startup.

If we add persistence later:

- File path: e.g. `~/.local/share/datum-gateway-rs/keys.bin` or `--key-file` flag.
- Permissions: `0600` (owner read/write only). Use `tokio::fs::OpenOptions` + `unix::OpenOptionsExt::mode(0o600)`.
- Format: concatenated raw bytes is simplest. 32 (Ed25519 pk) + 64 (Ed25519 sk) + 32 (X25519 pk) + 32 (X25519 sk) = 160 bytes total.

## Handshake state machine

| `datum_state` | Meaning |
|---|---|
| 0 | Initialization (pre-connect) |
| 1 | Handshake in flight |
| 2 | Encrypted session established |
| 3 | Configured, ready to mine (after `0x99` client-config) |

Step 1 — Client hello (signed + sealed):

```text
hello_msg layout:
  [pk_ed25519_long_term  | 32B]
  [pk_x25519_long_term   | 32B]
  [pk_ed25519_session    | 32B]
  [pk_x25519_session     | 32B]
  [version               | "v0.4.1-beta" + "/" + GIT_COMMIT_HASH]
  [random_nonce_seed     | for header XOR seed]
  [Ed25519 detached sig  | over the above, 64B]

then crypto_box_seal(hello_msg, server_pubkey_x25519)
```

Step 2 — Server response:

- Server echoes client keys, ships its own session keys + MOTD, signs the response.
- Client validates the signature with the server's *long-term Ed25519 pubkey* (from config).

Step 3 — Precomputation:

```c
crypto_box_beforenm(precomp, server_session_x25519_pk, client_session_x25519_sk)
```

Output is a 32-byte `precomp_remote` shared secret used with `crypto_box_easy_afternm` for all subsequent traffic. **Both directions use independent 24-byte nonces** (`session_nonce_sender`, `session_nonce_receiver`) that increment monotonically.

Step 4 — Header XOR seed:

```c
sending_header_key = client_chosen_nk;
// each subsequent header:
sending_header_key = datum_header_xor_feedback(sending_header_key);
header_word ^= sending_header_key;
```

`datum_header_xor_feedback` is MurmurHash3's 32-bit finalizer with `s = 0xb10cfeed` init. PR #202 (open) replaces the initial `nk` source with `randombytes_buf()`. Port both — original behavior for current OCEAN servers, PR-202 behavior for future servers.

## Server-version negotiation — there is none

The client sends its version (`DATUM_PROTOCOL_VERSION` = `"v0.4.1-beta"` plus `GIT_COMMIT_HASH`) but **does NOT validate the server's version**. The server's MOTD is logged via `DLOG_INFO("DATUM Server MOTD: %s", motd)` and that's it.

Implications:

- **The Rust port targets master's wire format and trusts OCEAN to maintain backward compatibility.** Per Path 1's finding (triple version bump 2025-12-17 across 0.2.6 / 0.3.3 / 0.4.1 maintenance branches), OCEAN runs older versions in production.
- **Test against the live `datum-beta1.mine.ocean.xyz:28915` endpoint** — that's the version-agnostic answer. Or against whichever version OCEAN Prime is running at the time.
- A future safety net: log the server's MOTD and emit a metric (`datum_server_motd`) for operators. Don't gate connection on version, but surface drift so we can react to a breaking change quickly.

## Reconnect & state recovery

Behavior on disconnect (from `datum_protocol.c`):

- Two timeout triggers: global server-silence (`datum_protocol_global_timeout_ms`, configurable) and share-acceptance silence (`>= 30000ms` hard).
- On either timeout, the protocol thread `break`s out of its main loop, cleans up, and waits for restart.
- **Shares queued in `pow_queue` persist in memory but are NOT replayed across reconnects.** A reconnect re-handshakes from scratch and resumes with no replay.
- **Coinbaser cache is NOT persisted across reconnects.** A new session must re-fetch coinbaser blobs (`0x10` request → `0x11` response).
- The gateway's overall behavior on prolonged disconnect: per the README, it **disconnects all stratum miners**, forcing them to fail over to backup pools. This is intentional — better to lose hashrate temporarily than to mine uncredited shares.

For the Rust port:

- Implement reconnect-with-backoff at the `client.rs` layer.
- On reconnect, redo the full handshake (state 0 → 3).
- Drop the in-memory share queue at reconnect time (mirror C behavior). Do NOT replay shares — DATUM Prime would see them as stale.
- Re-fetch coinbaser on reconnect. Idempotent.
- Surface a `datum_connected` metric / state to the SV2 downstream side; on disconnected, decide policy (mirror C: kick miners; or alternative: continue serving SV2 jobs with locally-built templates and queue shares pending DATUM reconnect — but that diverges from the C behavior).

## Mock vs live test harness

DATUM Prime is closed-source (Path 1 finding). Two options for testing:

1. **Live testing against `datum-beta1.mine.ocean.xyz:28915`.** Pros: real protocol, real pool. Cons: depends on OCEAN being up; introduces side effects (real share submission); requires a real Bitcoin payout address.
2. **Mock DATUM Prime in Rust.** Implement the server side from the same `datum_protocol.c` decoder, but only enough to handshake, ship a synthetic coinbaser blob, and ack shares. ~600-1000 lines. Pros: hermetic CI, fault injection, version pinning. Cons: drift risk from the real DATUM Prime.

**Recommendation: build both.** The mock is essential for CI (no flaky live-pool dependency, no real-money side effects). Live testing is a smoke-test gate before each release. Make the mock byte-compatible with `datum_protocol.c` so we can also use it as a reference/oracle when writing the client's parser.

## Sources

- `datum_protocol.c` master HEAD — handshake, state machine, encryption calls
- `datum_conf.h` master HEAD — config field names
- `datum_conf.c` master HEAD — default values for `datum_pool_host`, `datum_pool_port`, `datum_pool_pubkey`
- README excerpt: failover behavior on prolonged disconnect
