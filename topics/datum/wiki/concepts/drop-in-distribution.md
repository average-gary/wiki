---
title: "Drop-in distribution mechanics — packaging and binary swap"
category: concept
sources:
  - raw/articles/2026-06-01-dropinq5-debian-packaging.md
  - raw/articles/2026-06-01-dropinq5-cmake-and-dockerfile.md
  - raw/articles/2026-06-01-dropinq5-startos-package.md
  - raw/articles/2026-06-01-dropinq5-static-musl-and-coordination.md
created: 2026-06-01
updated: 2026-06-01
tags: [packaging, distribution, debian, ppa, docker, startos, musl]
confidence: high
---

# Drop-in distribution mechanics

How a Rust binary becomes a literal `apt install`-shaped, `cargo install`-shaped, Docker-image-shaped drop-in for `datum_gateway`. From [[../../raw/articles/2026-06-01-dropinq5-debian-packaging|Q5 .deb]], [[../../raw/articles/2026-06-01-dropinq5-cmake-and-dockerfile|Q5 build]], [[../../raw/articles/2026-06-01-dropinq5-startos-package|Q5 StartOS]], [[../../raw/articles/2026-06-01-dropinq5-static-musl-and-coordination|Q5 static musl]].

## What `datum_gateway` actually ships through

| Channel | URL | State | Drop-in surface |
|---|---|---|---|
| **Source** | [github.com/OCEAN-xyz/datum_gateway](https://github.com/OCEAN-xyz/datum_gateway) | Active. CMake build. v0.4.1beta (Jan 2026). | `cmake . && make` produces `./datum_gateway` |
| **Ubuntu PPA** | [launchpad.net/~ocean-xyz/+archive/ubuntu/datum-gateway](https://launchpad.net/~ocean-xyz/+archive/ubuntu/datum-gateway) | Active. jammy → resolute. amd64 + arm64. Pulls Bitcoin Knots PPA. | Package `datum-gateway`, binary `/usr/bin/datum_gateway` |
| **Debian source pkg** | `debian/` in repo | `Architecture: amd64 arm64`, debhelper + cmake. No `.deb` outside the PPA. | Package `datum-gateway` (hyphen), binary `datum_gateway` (underscore) |
| **StartOS / Embassy** | [github.com/OCEAN-xyz/datum-gateway-startos](https://github.com/OCEAN-xyz/datum-gateway-startos) | Active. Wraps C binary as `.s9pk`. Submodule pinned at `5b06123`. | YAML→JSON config templating; entrypoint `exec datum_gateway -c /root/data/datum_gateway_config.json` |
| **Docker** | (none) | **No official image on Docker Hub or ghcr.io.** Dockerfile in repo is BYO-build. | EXPOSE 23334 + 7152, VOLUME `/app/config`, ENTRYPOINT `/app/datum_gateway --config /app/config/config.json` |
| **GitHub Releases** | [datum_gateway/releases](https://github.com/OCEAN-xyz/datum_gateway/releases) | 13 releases. **No pre-built binaries** — release notes say "use git, don't use Source code zips". | Empty surface; opportunity for Rust port |

## Per-channel drop-in recipe

### Cargo binary name

```toml
[[bin]]
name = "datum_gateway"  # underscore — matches C binary name on disk
path = "src/main.rs"
```

`cargo install --path crates/datum-bin --root /usr/local` produces `/usr/local/bin/datum_gateway`. Symlinks, PATH-based scripts, and `bitcoin.conf` `blocknotify=killall -USR1 datum_gateway` recipes keep working.

### `.deb` via `cargo-deb`

```toml
[package.metadata.deb]
name = "datum-gateway-rust"
provides = "datum-gateway"
replaces = "datum-gateway"
conflicts = "datum-gateway"
```

Or fork the PPA namespace and ship competing `datum-gateway` directly. Drops the C build deps (`libjansson-dev`, `libcurl-dev`, `libmicrohttpd-dev`, `libsodium-dev`).

### Docker — biggest free win

Upstream has no official image. The Rust port can publish:

```
ghcr.io/<author>/datum-gateway:<version>
```

with identical surface:

- `EXPOSE 23334 7152`
- `VOLUME /app/config`
- `ENTRYPOINT ["datum_gateway", "--config", "/app/config/config.json"]`

`docker buildx build --platform linux/amd64,linux/arm64`. With pure-Rust crypto (`dryoc` from [[datum-protocol-rust-implementation]]) the final image can be `FROM scratch` or `FROM alpine` — **~10 MB vs upstream's ~100 MB Debian-based**.

### StartOS — high-leverage submodule swap

Fork [`OCEAN-xyz/datum-gateway-startos`](https://github.com/OCEAN-xyz/datum-gateway-startos):

1. Replace the C submodule pin with the Rust port.
2. Replace `cmake . && make` with `cargo build --release --locked --bin datum_gateway` in the build script.
3. Drop runtime libs (`libsodium23`, `libjansson4`, `libmicrohttpd12`) from the final stage.
4. Keep `docker_entrypoint.sh` byte-identical (it just `exec`s `datum_gateway -c <file>`).
5. `manifest.yaml` stays the same; bump version.

Start9 marketplace users get the Rust port via a manifest update — single distribution channel, thousands of self-hosted Bitcoin nodes.

**Gotcha**: StartOS uses port **23335** for stratum (not 23334 as in the bare Dockerfile) — preserve in the port-handling.

## Static musl — coordination point with Q2

Q2's pure-Rust `dryoc` recommendation makes `cargo build --release --locked --target x86_64-unknown-linux-musl` produce a fully-static binary with no C toolchain dependency. This:

- Opens distroless / Alpine / `FROM scratch` container targets.
- Eliminates `-sys` crate fiddliness in CI.
- Makes the GitHub Releases binary actually downloadable-and-runnable on any modern Linux without library-version dance.

**Hard avoid**: `sodiumoxide` (archived) or `libsodium-sys` without vendored static feature — both break the musl story.

## CI/CD outline

Upstream's `.github/workflows/build.yaml` is build-verification-only — no artifact publishing. The Rust port leapfrogs with one workflow:

| Job | Output |
|---|---|
| `cargo build --target {amd64,aarch64}-unknown-linux-{gnu,musl}` | 4 release binaries → SHA256SUMS → GitHub Release attachment |
| `cargo deb` for amd64 + arm64 | 2 `.deb` artifacts attached to release |
| `docker buildx` | `ghcr.io/<author>/datum-gateway:{tag, latest}` multi-arch |
| StartOS bump | manual; bump `manifest.yaml` version + git submodule |

Reproducibility: `cargo build --locked`, commit `Cargo.lock`, `SOURCE_DATE_EPOCH` from git, `--remap-path-prefix` in `RUSTFLAGS`, signed `SHA256SUMS`. Bitcoin-adjacent operators care about reproducible builds; the C port has no infra for this — credibility win.

## Binary-name + signal coordination

The drop-in MUST be named `datum_gateway` (underscore) on disk **AND** treat SIGUSR1 as a blocknotify trigger, because every operator's `bitcoin.conf` contains:

```
blocknotify=killall -USR1 datum_gateway
```

Or some variation thereof. See [[drop-in-surface-inventory]].

## See also

- [[drop-in-surface-inventory]] — operator-facing surface inventory
- [[datum-protocol-rust-implementation]] — `dryoc` choice that enables musl-static
- [[switch-day-runbook]] — operator-facing migration procedure
