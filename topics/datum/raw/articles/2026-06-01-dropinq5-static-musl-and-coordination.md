# Static Linking, musl, and the libsodium Coordination Point

**Author:** Q5 (drop-in build/distribution).
**Coordination with:** Q2 (libsodium binding choice).
**Date:** 2026-06-01.

## The constraint

A "literal drop-in replacement" needs to land on the same boxes the C `datum_gateway` lands on:

- Debian / Ubuntu (PPA covers it — `Architecture: amd64 arm64`)
- Alpine (the C build matrix tests it)
- Raspberry Pi-class boards (aarch64)
- StartOS containers (Debian-based)
- Bitcoin Knots / RaspiBolt / MyNode-style appliances

The most demanding target is **Alpine + static binary**. If the Rust port can produce a single static `datum_gateway` for `x86_64-unknown-linux-musl` and `aarch64-unknown-linux-musl`, it will run literally anywhere — including inside FROM-scratch and FROM-alpine containers, with no shared-library worries.

## The libsodium problem

The C binary requires `libsodium-dev` at build time and `libsodium23` at runtime. The Dockerfile installs `libsodium23` in the final image; the StartOS Dockerfile does the same.

For the Rust port, there are two options (this is **Q2's call** but Q5 has a hard recommendation here):

### Option A — `libsodium-sys-stable` / `sodiumoxide` (FFI bindings)

- **Pro:** thinnest wrapper around battle-tested C code, byte-identical crypto, easy to argue equivalence.
- **Con for static musl:** requires linking `libsodium.a`. On musl, this means either:
  - Building libsodium from source inside CI with `--host x86_64-linux-musl` (extra build complexity), or
  - Using `libsodium-sys-stable` with its `fetch-latest` / vendored feature, which downloads + builds libsodium during `cargo build`.
- **Con:** historically Cargo's interaction with `*-sys` crates and musl cross-compile is fiddly. Doable but adds a build-time dependency on `cc`, `make`, `autoconf`.

### Option B — `dryoc` (pure-Rust libsodium-compatible)

- **Pro:** `cargo build --target x86_64-unknown-linux-musl --release --locked` Just Works. No C toolchain, no vendored libsodium, no `-sys` crate. Single `cargo install` produces a static binary.
- **Pro:** API designed to mirror libsodium primitives. Auditable in pure Rust.
- **Con:** smaller community than libsodium itself; not a literal byte-for-byte port.
- **Con:** for protocols like Noise/ECDH where consensus matters with the C peer, must verify cross-implementation test vectors.

## Q5's recommendation (coordination with Q2)

**Use `dryoc`.** Reasons:

1. **Static musl builds become trivial** → opens Alpine, distroless, FROM-scratch Docker images. The C binary cannot do this without statically linking libsodium itself, which the upstream Dockerfile chose not to do (it dynamic-links to `libsodium23`).
2. **The Rust port leapfrogs distribution.** A 6-MB static binary that runs on any Linux is a competitive advantage over an OS-package-manager-dependent C binary.
3. **CI matrix simplifies:** no `cc-rs` / no `bindgen` / no system libsodium pinning across distro versions.
4. **Reproducibility:** pure-Rust + `Cargo.lock` + `--locked` flag → builds reproduce. C + libsodium-from-distro builds depend on which `libsodium23` ABI the distro shipped that day.

**If `dryoc` lacks a primitive that DATUM's protocol needs** (Q2 verifies what crypto ops `protocol.c` actually uses — ed25519 sign/verify, X25519, ChaCha20-Poly1305 are common), the fallback is `RustCrypto/ed25519-dalek` + `RustCrypto/chacha20poly1305` + `x25519-dalek`. All pure-Rust, all musl-static-friendly. Mix and match.

**Hard "no":** do NOT pick `sodiumoxide` (looks pure-Rust by name, is FFI). Do NOT pick `libsodium-sys` without vendoring + static-feature flag, because that breaks the Alpine story.

## Validation step (cheap)

```sh
# In the Rust port repo:
rustup target add x86_64-unknown-linux-musl
cargo build --release --locked --target x86_64-unknown-linux-musl
file target/x86_64-unknown-linux-musl/release/datum_gateway
# Expect: "ELF 64-bit LSB executable, x86-64, … statically linked, …"
ldd target/x86_64-unknown-linux-musl/release/datum_gateway
# Expect: "not a dynamic executable"
```

If both checks pass, the binary drops into:
- `FROM scratch` Docker images (~6-15 MB final image, vs C's ~100 MB Debian-based)
- Alpine without `apk add libsodium`
- Any glibc system (musl-static is glibc-compat for static binaries)

## Reproducible builds

The C upstream has **no reproducible-build infrastructure** (no `SOURCE_DATE_EPOCH` handling, no signed releases beyond the PPA's GPG key). The Rust port should at minimum:

- Commit `Cargo.lock` to the repo.
- Always build with `cargo build --locked` in CI and in release scripts.
- For real reproducibility, add `SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)` and `RUSTFLAGS="--remap-path-prefix=…"` to strip absolute paths from debug info.
- Publish SHA256 sums of release artifacts (`shasum -a 256 datum_gateway-x86_64-musl > SHA256SUMS`) and sign them with the same workflow Bitcoin Core uses — minisign or GPG.

This is a free credibility win over upstream and matches Bitcoin-ecosystem norms (Core, Knots, BTCPay all do reproducible-ish builds).

## Cross-reference

- Upstream PPA / Debian packaging: `2026-06-01-dropinq5-debian-packaging.md`
- StartOS package mechanics: `2026-06-01-dropinq5-startos-package.md`
- CMake + Dockerfile + CI gap analysis: `2026-06-01-dropinq5-cmake-and-dockerfile.md`
