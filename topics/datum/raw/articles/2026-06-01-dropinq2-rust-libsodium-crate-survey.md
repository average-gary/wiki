---
title: "Rust libsodium crate survey for DATUM gateway port (2026-06-01)"
source: "synthesis from crates.io / docs.rs / GitHub for dryoc, sodiumoxide, crypto_box (RustCrypto), libsodium-sys"
type: articles
tags: [datum, rust, libsodium, dryoc, crypto_box, sodiumoxide, crypto-survey, dropin-q2]
summary: "Survey of Rust crates that could provide the libsodium primitives required by DATUM Gateway: crypto_box_seal, crypto_box_beforenm/_afternm, Ed25519 detached signatures, randombytes_buf. Recommendation: dryoc (pure Rust, complete coverage). RustCrypto crypto_box is INSUFFICIENT — it has no sealed-box and no precomputed-shared-secret API. sodiumoxide is archived (2022). FFI fallback: libsodium-sys-stable."
confidence: high
ingested: 2026-06-01
ingested_by: dropin-q2
quality_score: 5
---

# Rust libsodium crate survey

## What we need

DATUM's `datum_protocol.c` uses these libsodium primitives (verbatim from the C source):

- `crypto_sign_keypair` / `crypto_box_keypair` (Ed25519 + X25519 keygen)
- `crypto_box_seal()` — sealed-box anonymous-sender for the handshake hello
- `crypto_box_seal_open()` — sealed-box decrypt for server-side replies
- `crypto_box_beforenm()` — shared-secret precomputation
- `crypto_box_easy_afternm()` / `crypto_box_open_easy_afternm()` — authenticated session encryption (XSalsa20Poly1305, 24-byte nonce)
- `crypto_sign_detached` / `crypto_sign_verify_detached` — Ed25519 detached signatures over the hello payload
- `randombytes_buf()` — used by PR #202 to seed the header XOR feedback

Cipher confirmation (from doc.libsodium.org): `crypto_box_easy_afternm` is **XSalsa20 + Poly1305** with a 24-byte nonce. **The earlier wiki claim that this is ChaCha20-Poly1305 is incorrect.** This matters: the Rust port must use XSalsa20Poly1305, not ChaCha20Poly1305. Mis-selecting will produce ciphertext that won't decrypt on the pool side.

## Crate evaluation

| Crate | Status | Sealed box | Precomputed | Ed25519 detached | randombytes_buf | Pure Rust | License | Notes |
|---|---|---|---|---|---|---|---|---|
| `dryoc` 0.8.0 (May 2026) | maintained | ✓ (`DryocBox::seal`, `crypto_box_seal`) | ✓ (`crypto_box_beforenm` + `crypto_box_detached_afternm`) | ✓ (sign module) | ✓ (rng module) | yes | MIT | Active, single-maintainer (brndnmtthws), 334 stars |
| `crypto_box` (RustCrypto) | maintained | ✗ NOT supported | ✗ NOT supported | n/a (separate `ed25519-dalek`) | n/a (`rand_core`) | yes | Apache/MIT | Audited by Cure53. **Insufficient for DATUM.** |
| `sodiumoxide` | ARCHIVED 2022-09-04 | ✓ | ✓ | ✓ | ✓ | no (FFI) | Apache/MIT | Read-only repo; "reached end of development." Do not adopt. |
| `libsodium-sys` (raw FFI) | maintained | ✓ (everything libsodium has) | ✓ | ✓ | ✓ | no (FFI) | ISC (libsodium core) | Bare FFI; you write the safe wrappers. |
| `libsodium-sys-stable` | maintained alt | ✓ | ✓ | ✓ | ✓ | no (FFI) | ISC | Stable-pinned FFI variant; useful escape hatch. |

## Recommendation: dryoc

Rationale:

1. **Complete primitive coverage** for what DATUM needs. The classic API exposes `crypto_box_seal`, `crypto_box_seal_open`, `crypto_box_beforenm`. Precomputation is supported via the `precalc` module and `crypto_box_detached_afternm` family — slightly different naming than libsodium's `_easy_afternm` but equivalent (detached output gives separated MAC; easy output appends MAC; both are 16-byte Poly1305 tags. Wrap accordingly.)
2. **Pure Rust, no system libsodium dependency.** Simplifies cross-compilation, container builds, and Windows targets. No `pkg-config` headache.
3. **Same wire format as libsodium.** dryoc explicitly targets libsodium compatibility, not novel cryptography. A DATUM Prime built against libsodium will accept dryoc-generated ciphertexts byte-for-byte (assuming we drive the right primitive).
4. **MIT license** compatible with the gateway's own MIT licensing.
5. **Maintained**, latest release 2026-05-15.

Caveats:

- **Single-maintainer.** Bus-factor risk. Mitigation: keep `libsodium-sys-stable` as a documented fallback; the Rust code should isolate crypto behind a trait so we can swap implementations.
- **`_easy_afternm` not 1:1.** dryoc exposes `_detached_afternm`. Wrap to produce libsodium's "easy" layout (`MAC || ciphertext` concatenation).
- **Detached Ed25519 signatures** — dryoc's `sign` module documents single-part and incremental signing but the docs.rs index does not explicitly enumerate `sign_detached`. Need to check source — `crypto_sign_detached` is part of the libsodium classic API and dryoc's classic API mirrors libsodium one-to-one, so this is almost certainly there under `dryoc::classic::crypto_sign`. **Verify before committing.**

## Rejected alternatives

- **`sodiumoxide`** — archived. Last commit 2022. README explicitly says "end of development." Adopting a dead crypto library is malpractice.
- **RustCrypto `crypto_box`** — surprising omission of sealed-box and precomputed-key APIs. Useful for SV2 (Noise IK uses `crypto_box`-style key agreement) but does not cover DATUM's handshake. Pairing with `ed25519-dalek` for signing would still leave us building sealed-box from primitives ourselves. Not worth it.
- **Bare `libsodium-sys`** — last resort. Wraps the C library directly. Cross-compilation toolchain pain, but the safest from a "does the protocol interop" angle since the C gateway is itself libsodium-linked.

## Risks (byte-exact-compat hazards)

1. **XSalsa20Poly1305 vs ChaCha20Poly1305 confusion.** libsodium's `crypto_box_easy_afternm` is XSalsa20Poly1305. The earlier session note stating "ChaCha20-Poly1305" was wrong. Must use the X-variant. Both `dryoc::dryocbox` and the classic API correctly use XSalsa20Poly1305 — confirmed via dryoc docs ("X25519 for key derivation, the XSalsa20 stream cipher, and Poly1305").
2. **Easy vs detached layout.** libsodium "easy" returns ciphertext with the MAC prepended (16-byte tag at front). "Detached" returns MAC and ciphertext separately. The C code uses `_easy_afternm`; dryoc exposes `_detached_afternm`. Our wrapper must produce the on-wire concatenation: `mac (16) || ct (cmd_len-16)`. **Test against a libsodium-linked C peer before assuming layout.**
3. **Ed25519 vs X25519 split in the pubkey config string.** Confirmed from C source: first 32 bytes are Ed25519 pubkey, last 32 bytes are X25519 pubkey, hex-encoded as a 128-char string. Both are derived independently (`crypto_sign_keypair` + `crypto_box_keypair`), NOT derived one-from-the-other via Ed25519↔X25519 conversion. Do not be tempted to "compute one from the other"; the C code stores both independently.
4. **Nonce increment semantics.** From C: `datum_increment_session_nonce` walks the 24-byte nonce as 6×4-byte little-endian counters and increments with carry. Re-implement that exact logic. Off-by-one in carry propagation breaks decrypt at packet 2^32.
5. **Server's reply also uses sealed-box.** Confirmed: `crypto_box_seal_open` is called on the client side too (server sends some replies sealed under the client's session X25519 pubkey). Both directions of the seal flow must work.

## Path 2 / fallback

Build the gateway crypto layer behind a trait:

```rust
trait DatumCrypto {
    fn seal(&self, plaintext: &[u8], recipient_pk: &X25519Pub) -> Vec<u8>;
    fn seal_open(&self, sealed: &[u8], my_kp: &X25519Keypair) -> Result<Vec<u8>>;
    fn beforenm(&self, their_pk: &X25519Pub, my_sk: &X25519Sec) -> SharedSecret;
    fn box_easy_afternm(&self, pt: &[u8], nonce: &[u8; 24], k: &SharedSecret) -> Vec<u8>;
    fn box_open_easy_afternm(&self, ct: &[u8], nonce: &[u8; 24], k: &SharedSecret) -> Result<Vec<u8>>;
    fn sign_detached(&self, msg: &[u8], sk: &Ed25519Sec) -> [u8; 64];
    fn sign_verify_detached(&self, sig: &[u8; 64], msg: &[u8], pk: &Ed25519Pub) -> bool;
    fn random_bytes(&self, buf: &mut [u8]);
}
```

Default impl: `dryoc`. Fallback impl: `libsodium-sys-stable` for byte-exact interop testing against the C peer. This trait costs ~20 lines and buys a clean swap route.

## Sources

- dryoc 0.8.0 (May 2026) — https://github.com/brndnmtthws/dryoc, https://docs.rs/dryoc/latest/dryoc/
- sodiumoxide archived — https://github.com/sodiumoxide/sodiumoxide
- RustCrypto crypto_box — https://docs.rs/crypto_box/latest/crypto_box/
- libsodium docs — https://doc.libsodium.org/public-key_cryptography/authenticated_encryption
