---
title: "DATUM Protocol — Rust implementation outline"
category: concept
sources:
  - raw/articles/2026-06-01-dropinq2-rust-libsodium-crate-survey.md
  - raw/articles/2026-06-01-dropinq2-handshake-and-pubkey-discovery.md
  - raw/articles/2026-06-01-dropinq2-rust-implementation-outline.md
  - raw/articles/2026-06-01-dropinq2-known-unknowns-and-risks.md
created: 2026-06-01
updated: 2026-06-01
tags: [datum-protocol, rust, libsodium, dryoc, drop-in]
confidence: high
---

# DATUM Protocol — Rust implementation outline

How the encrypted DATUM upstream gets reimplemented in Rust for a drop-in replacement. From [[../../raw/articles/2026-06-01-dropinq2-rust-libsodium-crate-survey|Q2 crate survey]], [[../../raw/articles/2026-06-01-dropinq2-handshake-and-pubkey-discovery|Q2 handshake]], [[../../raw/articles/2026-06-01-dropinq2-rust-implementation-outline|Q2 outline]].

## Critical correction

Earlier wiki content described the steady-state cipher as ChaCha20-Poly1305. **This was wrong.** libsodium's `crypto_box_*_easy_afternm` is **XSalsa20Poly1305** (24-byte nonce). `dryoc` and RustCrypto's `crypto_box` both default to XSalsa20 — safe as long as nobody manually opts into the Chacha variant. See [[datum-protocol]] (corrected).

## Crate recommendation: `dryoc 0.8`

| Crate | Sealed box | Precomputed | Ed25519 detached | randombytes_buf | Pure Rust | Verdict |
|---|---|---|---|---|---|---|
| **`dryoc 0.8.0`** (May 2026) | yes | yes (`precalc` + `_detached_afternm`) | yes (`sign` module) | yes (`rng`) | yes | **PICK** |
| `crypto_box` (RustCrypto) | NO | NO | n/a | n/a | yes | insufficient — missing 2 of 4 needed primitives |
| `sodiumoxide` | yes | yes | yes | yes | FFI | **archived 2022-09-04 — DO NOT USE** |
| `libsodium-sys-stable` | yes | yes | yes | yes | FFI | fallback for byte-exact interop testing |

**Why `dryoc`**: complete primitive coverage, libsodium-compatible wire output, **musl-static-clean** (Q5 confirmed). Coordinates with the build/distribution decision (Q5) — `cargo build --target x86_64-unknown-linux-musl` produces a fully-static binary with no C toolchain dependency, opening `FROM scratch` Docker images that the C upstream can't reach.

**Architectural note**: isolate behind a `DatumCrypto` trait so we can swap to `libsodium-sys-stable` for cross-validation tests against the C reference.

## Wire format (corrected & expanded)

From [[datum-protocol]]:

- **Header**: 32-bit packed: `cmd_len (22 bits)`, `reserved (2 bits)`, `is_signed (1)`, `is_encrypted_pubkey (1)`, `is_encrypted_channel (1)`, `proto_cmd (5 bits)`.
- **Frame ceiling**: 4 MB per command; max 8 concurrent jobs.
- **Handshake**: client sends `crypto_box_seal()` to OCEAN's known long-term public key. Hello carries long-term + session Ed25519 + X25519 pubkeys, signed with long-term Ed25519.
- **Steady state**: `crypto_box_beforenm()` precomputation + `crypto_box_easy_afternm()` (**XSalsa20Poly1305**, 24-byte nonces).
- **Header obfuscation**: XOR-feedback chain seeded by client-chosen `nk`, evolved per packet via MurmurHash3-32 finalizer with init constant `0xb10cfeed`. PR #202 hardens this with `randombytes_buf`.

## OCEAN pool pubkey

**Hardcoded** in `datum_conf.c`, not `datum_protocol.c`. Default: `datum-beta1.mine.ocean.xyz:28915` with 128-hex-char string. First 64 hex = Ed25519 pubkey, last 64 = X25519 pubkey. Parsed by `datum_pubkey_to_struct()`. The Rust drop-in inherits the same `datum.pool_pubkey` config field.

## Rust module layout

```
crates/datum-protocol/src/
├── frame.rs          # 32-bit packed header pack/unpack
├── obfuscation.rs    # MurmurHash3-32 finalizer + 0xb10cfeed init (~15 LOC)
├── crypto.rs         # DatumCrypto trait + dryoc-backed default impl
├── handshake.rs      # state machine (states 0..3)
├── opcodes.rs        # ProtoCmd + MiningSub enums
├── messages/
│   ├── coinbaser.rs       # 0x10/0x11
│   ├── share.rs           # 0x27 + 0x8F response
│   ├── job_validation.rs  # 0x50
│   ├── client_config.rs   # 0x99
│   └── block_notify.rs    # 0xF9
├── client.rs         # Tokio async I/O top level
└── mock_pool.rs      # server-side reference for hermetic tests
```

Dependencies: `tokio`, `dryoc`, `bytes`, `byteorder`, `thiserror`, `tracing`. **No** `serde`, `bitvec`, or `murmur3` crate (the MurmurHash3-32 finalizer is ~15 LOC inline).

## Test strategy

Two harnesses, both required:

1. **Mock pool** (in-tree) — exercises the wire format from the gateway side. Hermetic, fast, runs in CI.
2. **Live OCEAN** — release-gate smoke test. Required because DATUM Prime is closed-source ([[ocean-sv2-stance-and-prior-art|OCEAN SV2 stance]]); no offline test target.

## Production version drift

Master HEAD is `v0.4.1-beta`; OCEAN production runs older versions (Path 1 finding: triple version bump on 2025-12-17 across 0.2.6 / 0.3.3 / 0.4.1 maintenance branches).

**Mitigation**: the C gateway sends a literal version string with no server-side validation per Q2 reading. Rust drop-in v1.0 sends `"v0.4.1-beta"` to inherit the master feature set. If OCEAN's production server rejects, fall back to the version string production currently accepts.

## Known unknowns (gating)

| Unknown | Mitigation |
|---|---|
| Header bitfield byte ordering (implementation-defined in C) | Capture a real C-emitted PING; pin via test before coding the Rust pack/unpack |
| Nonce segment width / carry propagation | Same — capture-and-pin |
| OCEAN production server version | Live-integration test |
| Coinbaser refresh trigger | Re-read `datum_coinbaser.c` |
| Per-miner unique-identifier delivery (16-bit ID — one per gateway? per miner?) | Affects SV2 channel mapping; runtime observation |

## Risks (byte-exact compat hazards)

| Risk | Severity | Mitigation |
|---|---|---|
| Header bitfield byte ordering | **High** | Capture-and-pin |
| Cipher selection (XSalsa20 vs ChaCha20-Poly1305) | High | Asserted via test; both `dryoc` and `crypto_box` default to XSalsa20 |
| `_easy` vs `_detached` MAC layout (libsodium prepends 16-byte MAC; dryoc returns separately — must concatenate `mac \|\| ct`) | Medium | Concatenation wrapper in `crypto.rs` |
| MurmurHash3-32 variant (finalizer-as-RNG, not full hash) | Medium | Inline implementation matches C's `mm3_fmix32` exactly |
| OCEAN production version drift | Medium | Configurable version string |
| Sub-sub-opcode 3-level dispatch under `0x50` | Low | Enum-of-enums in `opcodes.rs` |

## See also

- [[datum-protocol]] — corrected wire format reference
- [[drop-in-rust-port-architecture]] — where this module fits in the workspace
- [[../../raw/articles/2026-06-01-path1-datum-protocol-h|datum_protocol.h source]]
- [[../../raw/articles/2026-06-01-path1-datum-protocol-c|datum_protocol.c source]]
