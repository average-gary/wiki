---
title: "DATUM Rust port: known unknowns and byte-exact-compat risks (2026-06-01)"
source: "Q2 synthesis"
type: articles
tags: [datum, rust, risks, unknowns, byte-compat, dropin-q2]
summary: "Catalog of remaining unknowns and byte-exact compatibility hazards for a Rust port of the DATUM upstream client. Top-level risks: bitfield ordering of the 32-bit header, easy-vs-detached MAC layout, XSalsa20Poly1305 (NOT ChaCha20-Poly1305), nonce-segment width, sub-opcode-under-0x50 dispatch ambiguity, version pinning to a moving target."
confidence: high
ingested: 2026-06-01
ingested_by: dropin-q2
quality_score: 5
---

# DATUM Rust port — known unknowns and risks

## Known unknowns (need code-anchored answers before coding)

1. **Header bitfield byte order.** C bitfields within a word are implementation-defined. Need a byte-vector from a real C-built gateway packet (e.g. one PING) to anchor the Rust pack/unpack against. Without this, `cmd_len`, `proto_cmd`, and the encryption-flag bits could land in the wrong nibble.

2. **24-byte nonce segment width.** Path 1 noted "monotonic increment with overflow handling" but the segment width (4-byte u32 vs 8-byte u64 vs 12-byte+12-byte split) requires reading `datum_increment_session_nonce()` directly. Off-by-one in carry breaks decrypt at the segment boundary (2^32 packets if u32; 2^64 if u64).

3. **OCEAN's *current* server version.** Master is `v0.4.1-beta`; OCEAN runs older versions in production (Path 1: triple version bump on 2025-12-17). Need to either (a) test against `datum-beta1.mine.ocean.xyz:28915` and observe what comes back, or (b) ask OCEAN directly. If production is on `v0.2.6` or `v0.3.3` and master has wire-incompatible changes, the Rust port targeting master breaks against production. Mitigation: test against live, fall back to a maintenance-branch wire format if needed.

4. **Share-submit ack ordering under load.** The C code appears to dispatch ack responses in arrival order. If the pool ever sends them out-of-order (e.g. parallel validation pipeline), our pending-share map needs to handle that. Need to inspect `datum_protocol.c`'s ack-correlation logic — does it match by share-id, by submission order, or by `(job_id, nonce)` tuple? Affects our `PendingShare` design.

5. **Coinbaser refresh trigger.** When does the gateway re-fetch the coinbaser blob? On block-notify (`0xF9`)? On a timer? On every share submission? Path 1 mentions a 5-second `pthread_mutex_timedlock` on coinbaser; that's lock acquisition timing, not refresh policy. Need to read `datum_coinbaser.c` carefully.

6. **Block-notify (`0xF9`) flow direction.** Pool → client (when a block is found) and/or client → pool (when our gateway built a block)? Affects which side initiates and what payload follows. Probably both directions but unclear from the header file alone.

7. **Per-miner unique-identifier delivery.** README says "the protocol gives you a unique identifier you must include." Path 1 says it's 16-bit (max 65,536 miners). Delivered via `0x99` client-config? Per-miner via the `pool_pass_full_users` username? Unclear whether one identifier covers the whole gateway or whether each downstream miner gets a distinct ID. Affects how we map SV2 channels to DATUM identities.

## Byte-exact compatibility risks

### Cipher selection

**RISK (high):** earlier wiki note said "ChaCha20-Poly1305" — that's wrong. libsodium's `crypto_box_easy_afternm` is **XSalsa20Poly1305**. Confirmed via doc.libsodium.org: "Encryption: XSalsa20, Authentication: Poly1305." dryoc and crypto_box (RustCrypto) both default to XSalsa20Poly1305 for the equivalent API, so this is auto-correct as long as we don't manually opt into the ChaCha variant. **Mitigation:** assert in tests that ciphertext from our Rust client decrypts under a libsodium-FFI-linked C peer.

### Header pack/unpack endianness

**RISK (high):** the 32-bit header is a packed C struct. Field order on the wire depends on bitfield endianness within the word, which is **compiler/platform defined** (typically LSB-first on x86/ARM, MSB-first on PowerPC). The C gateway is built with gcc/clang on Linux, so LSB-first is overwhelmingly likely, but NOT guaranteed.

Mitigation: capture a known PING packet from the C gateway, emit hex, derive the bit layout empirically, and pin a unit test against it. Don't ship without that vector.

### `_easy` vs `_detached` MAC layout

**RISK (medium):** libsodium "easy" output is `MAC (16B) || ciphertext (N-16B)` concatenated. dryoc's classic API exposes `_detached_afternm` which returns MAC and ciphertext separately. Wrapper must concatenate to match the C peer's "easy" expectation. Trivial bug: getting the order wrong (`ct || mac` instead of `mac || ct`) — libsodium puts MAC first.

Mitigation: dedicated unit test against an FFI-libsodium output for a known plaintext.

### MurmurHash3 variant

**RISK (medium):** "MurmurHash3" comes in 32-bit, 128-bit-x86, 128-bit-x64 variants. DATUM uses the **32-bit finalizer only**, with init `0xb10cfeed`. The `murmur3` Rust crate implements the full 32-bit MurmurHash3 (init = seed parameter, fed input bytes); we don't want that — we want the finalizer-as-RNG. Inline ~15 lines instead.

Mitigation: dedicated test producing N=20 sequential states from a known seed and comparing against C output.

### Ed25519 vs X25519 keypair derivation

**RISK (medium-low):** the C source calls `crypto_sign_keypair` AND `crypto_box_keypair` independently — they are NOT derived one-from-the-other. Some libsodium-using protocols do the conversion (Ed25519↔X25519 via `crypto_sign_ed25519_sk_to_curve25519`); DATUM does not. Don't optimize "we only need to store one" — store both.

Mitigation: comment in `crypto.rs` calling out this design choice. Test that we generate two distinct keypairs.

### Header obfuscation seed source (PR #202)

**RISK (low):** PR #202 (open) replaces the initial `nk` seed source with `randombytes_buf()`. If we implement only the post-PR-202 behavior, current OCEAN servers might desync. If we implement only pre-PR-202, future servers might. Best: implement post-PR-202 (it's the safer default) and cross-fingers the seed source isn't part of the wire-checked state — it's just our internal randomness, the chain itself is what matters on the wire. Verify by reading the merged version of PR #202 once it lands.

### `proto_cmd=5` sub-sub dispatch under `0x50`

**RISK (low):** the job-validation opcodes (`0x10` short-tx-list, `0x11` requested-tx, `0x12` full-block) are sub-sub-opcodes nested under `proto_cmd=5, subcmd=0x50`. Dispatch is 3 levels deep. Easy to mis-thread by treating the sub-opcode as a top-level command. Mitigation: explicit `enum` for each level, with `match` exhaustiveness.

### Random padding in share submit

The C share-submit format ends with `0xFE` end-marker + random padding. **The padding is for traffic-analysis resistance**, NOT semantic content. The pool ignores it after the `0xFE`. Risk: our parser must skip it on receive; our encoder must produce *something* — likely matching the C distribution (random 0-N bytes from `randombytes_buf`). If the C peer expects a specific padding distribution we'd need to match, but most likely any random length is fine.

### Connection timeout vs share-ack timeout

Two distinct timeouts in the C code:
- `datum_protocol_global_timeout_ms` (configurable, default unknown — read `datum_conf.c`).
- 30000ms hard-coded share-ack silence timeout.

These are independent. The Rust port must implement both, with the share-ack timeout being **per-share** (or against the oldest pending share's age), not against last-share-ack-overall, otherwise a steady stream of acks for new shares masks a stuck old share.

## Summary risk matrix

| Risk | Severity | Mitigation |
|---|---|---|
| Header bitfield byte order | High | Capture C-emitted PING, byte-pin in tests |
| Cipher confusion (X vs ChaCha) | High | dryoc default is correct; assertion test against C peer |
| Easy-vs-detached MAC layout | Medium | Wrapper + FFI cross-test |
| MurmurHash3 variant confusion | Medium | Inline finalizer + sequence vector test |
| OCEAN production version drift | Medium | Live smoke test against beta1 endpoint; capture wire vectors |
| Nonce segment width | Medium | Read C source; vector test |
| Sub-sub-opcode 3-level dispatch | Low | Explicit enums |
| Share-ack ordering | Low | Match by `(job_id, nonce)` tuple |
| PR #202 seed change | Low | Implement post-PR-202; the chain is what matters |
| Random padding distribution | Low | Match approximate C distribution; verify pool tolerates |

## Sources

- `datum_protocol.c`, `datum_protocol.h`, `datum_conf.c` master HEAD
- doc.libsodium.org/public-key_cryptography/authenticated_encryption (XSalsa20Poly1305 confirmation)
- dryoc 0.8 docs (precalc, sign modules)
- PR #202 (open, header XOR seed change)
- Path 1 wiki articles in `raw/repos/`
