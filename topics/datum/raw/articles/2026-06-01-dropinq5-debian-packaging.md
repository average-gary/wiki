# DATUM Gateway: Debian Packaging & Ubuntu PPA

**Source:** GitHub `OCEAN-xyz/datum_gateway/debian/` and Launchpad PPA `ppa:ocean-xyz/datum-gateway`.
**Fetched:** 2026-06-01 by Q5 (drop-in build/distribution research).

## debian/control (verbatim)

```
Source: datum-gateway
Maintainer: Luke Dashjr <luke+datum@ocean.xyz>
Section: net
Priority: optional
Standards-Version: 4.5.0
Homepage: https://ocean.xyz
Vcs-Git: https://github.com/OCEAN-xyz/datum_gateway.git
Vcs-Browser: https://github.com/OCEAN-xyz/datum_gateway
Build-Depends: debhelper,
 cmake,
 pkg-config,
 libjansson-dev,
 libmicrohttpd-dev,
 libsodium-dev,
 libcurl-dev

Package: datum-gateway
Architecture: amd64 arm64
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: Decentralized Alternative Templates for Universal Mining
 The DATUM Gateway is a server providing solo mining capabilities for Bitcoin
 miners, including both non-pooled and pooled solo mining using the new DATUM
 protocol.
```

## debian/rules (verbatim)

```make
#!/usr/bin/make -f
export DH_VERBOSE = 1

%:
	dh $@

override_dh_auto_configure:
	dh_auto_configure -- \
	-DCMAKE_INSTALL_DOCDIR=share/doc/datum-gateway
```

Plain debhelper-driven CMake build. Nothing fancy. The package name is **`datum-gateway`** (hyphen), but the binary inside ships as **`datum_gateway`** (underscore — see CMakeLists.txt `add_executable(datum_gateway ...)`).

## Ubuntu PPA — `ppa:ocean-xyz/datum-gateway`

- **URL:** https://launchpad.net/~ocean-xyz/+archive/ubuntu/datum-gateway
- **Series supported:** jammy (22.04), noble (24.04), oracular (24.10), plucky (25.04), questing (25.10), resolute (26.04)
- **Latest version:** `0.4.1~beta` (oracular still on 0.3.1~beta)
- **Signing key fingerprint:** `ECE41043E8C70D01E97CB2AD3DB747AAD648B174`
- **Add via:** `sudo add-apt-repository ppa:ocean-xyz/datum-gateway`
- **Apt source line:** `deb https://ppa.launchpadcontent.net/ocean-xyz/datum-gateway/ubuntu <SERIES> main`
- **Notable dep:** PPA pulls Bitcoin Knots PPA as a dependency.

## Drop-in implications for the Rust port

1. **Binary name:** Rust port MUST emit `datum_gateway` (underscore). In `Cargo.toml`:

   ```toml
   [[bin]]
   name = "datum_gateway"
   path = "src/main.rs"
   ```

   Verify with `cargo install --path . --root /usr/local` → produces `/usr/local/bin/datum_gateway`. This matches the C install path from `install(TARGETS datum_gateway DESTINATION bin)`.

2. **`.deb` takeover via Replaces/Conflicts:** since OCEAN ships `Package: datum-gateway`, the Rust port can ship a `.deb` with:

   ```
   Package: datum-gateway-rust
   Provides: datum-gateway
   Replaces: datum-gateway
   Conflicts: datum-gateway
   ```

   This lets `apt install datum-gateway-rust` cleanly replace the C package while preserving the `/usr/local/bin/datum_gateway` path. Alternatively, fork the same `Package: datum-gateway` name and ship a competing PPA — but Replaces/Conflicts is cleaner for coexistence in a single archive.

3. **Build mechanism:** [`cargo-deb`](https://github.com/kornelski/cargo-deb) is the most pragmatic choice — it reads `[package.metadata.deb]` from `Cargo.toml` and produces a `.deb` directly, no `debian/` directory needed. Mature, widely used (ripgrep, fd, etc. ship via it). Can specify `Replaces:`/`Conflicts:` in the metadata table.

4. **Dependencies shrink:** Rust port likely doesn't need `libjansson-dev`, `libcurl-dev`, `libmicrohttpd-dev` (these are C-library replacements pure Rust avoids). Only `libsodium` is contested — see Q2 coordination point in dropinq5-static-musl note.

## Cross-reference

- Build system: see `2026-06-01-dropinq5-cmake-and-dockerfile.md`
- Launchpad PPA confirms amd64 + arm64 are the target arches → matches StartOS hardware-requirements.
