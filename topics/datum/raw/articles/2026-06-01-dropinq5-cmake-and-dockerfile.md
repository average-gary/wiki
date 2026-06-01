# DATUM Gateway: CMake Build + Dockerfile

**Sources:**
- `OCEAN-xyz/datum_gateway/CMakeLists.txt`
- `OCEAN-xyz/datum_gateway/Dockerfile`
- `OCEAN-xyz/datum_gateway/.github/workflows/build.yaml`
- `src/datum_gateway.c` (CLI flags, signal handling)

**Fetched:** 2026-06-01.

## CMakeLists.txt — key facts

```cmake
project(DATUM VERSION 0.4.1 LANGUAGES C)
add_executable(datum_gateway ...)
install(TARGETS datum_gateway DESTINATION bin)
install(FILES README.md DESTINATION ${CMAKE_INSTALL_DOCDIR})
```

**Dependencies:**
- `libcurl` (required) — for bitcoind RPC
- `jansson` (required) — JSON parsing
- `libsodium` (required) — crypto (signing, encryption)
- `libmicrohttpd` (required if `ENABLE_API` is ON) — embedded HTTP for dashboard
- `epoll-shim` (non-Linux only)
- `libargp` (if argp_parse missing)

Standard `GNUInstallDirs`. **No CPack rules**, **no systemd unit install**.

## Binary CLI surface (from `src/datum_gateway.c`)

`argp_parse()`-based; flags are minimal:

| Flag | Long form | Purpose |
|------|-----------|---------|
| `-c FILE` | `--config FILE` | Config JSON path |
| | `--example-conf` | Print sample config |
| | `--test` | Run tests then exit |
| `-?` | `--help` | Help |

**Default config path:** hardcoded to `datum_gateway_config.json` in the working directory — **no `/etc/datum/` lookup**. (StartOS supplies `/root/data/datum_gateway_config.json`; Docker volume `/app/config/config.json`.)

**Signal handling:** only `SIGUSR1` (block notifications from `bitcoind blocknotify`) and `SIG_IGN` for `SIGPIPE`. **No SIGTERM/SIGHUP handler**, **no `sd_notify()` calls**, **no systemd notify integration**. The Rust port can match this trivially with `tokio::signal::unix::signal(SignalKind::user_defined1())`.

## Dockerfile — verbatim shape

Two-stage Debian Bookworm build:

```dockerfile
# Builder
FROM debian:bookworm-slim
RUN apt-get install build-essential cmake gcc pkg-config \
    libjansson-dev libmicrohttpd-dev libsodium-dev \
    libcurl4-openssl-dev git
WORKDIR /build
RUN cmake -DCMAKE_BUILD_TYPE=Release . && make -j$(nproc)

# Runtime
FROM debian:bookworm-slim
RUN useradd -r -s /bin/false datumuser
COPY --from=builder /build/datum_gateway /app/datum_gateway
COPY --from=builder /build/www /app/www/
COPY doc/example_config.json /app/config/config.json
EXPOSE 23334/tcp 7152/tcp
VOLUME /app/config
HEALTHCHECK --interval=30s --timeout=5s \
  CMD nc -z localhost 23334
ENTRYPOINT ["/app/datum_gateway", "--config", "/app/config/config.json"]
```

**Ports:** `23334` (Stratum), `7152` (dashboard / API).
**Volume:** `/app/config` for persistent JSON config.
**User:** non-root `datumuser` (UID system-assigned).

## GitHub Actions `build.yaml` — what it actually does

**Triggers:** push / PR (build verification only).

**Matrix:** Ubuntu, Debian, AlmaLinux, Amazon Linux, Fedora, Oracle Linux, Alpine, Arch, Gentoo + FreeBSD 14.4 (incl. aarch64 via `vmactions`). Both GCC and Clang. ENABLE_API on/off. Sanitizers (ASan, UBSan).

**What it does NOT do:**
- No Docker registry push (no `ghcr.io` / no Docker Hub).
- No `.deb` build/publish (PPA is built on Launchpad, separately).
- No GitHub Release artifact upload.
- No multi-arch cross-compile from CI (FreeBSD aarch64 is via VM, not cross).

**Conclusion:** the project's CI is pure compile-test-on-many-distros. All actual artifact distribution is out-of-band:
- `.deb` → Launchpad PPA (uploaded by maintainer)
- StartOS `.s9pk` → built from the `datum-gateway-startos` repo
- Docker → there is **no official published image**; Dockerfile is BYO-build
- Source → `git clone` + `cmake . && make`

## Drop-in mapping for the Rust port

| C concern | Rust port equivalent |
|-----------|----------------------|
| `add_executable(datum_gateway)` | `[[bin]] name = "datum_gateway"` |
| `install(TARGETS … DESTINATION bin)` | `cargo install --path . --root /usr/local` |
| `argp_parse` `-c FILE` | `clap` derive with `#[arg(short, long)]` |
| `--example-conf` | print embedded `include_str!("example_config.json")` |
| `--test` | `cargo test` plus a `--test` runtime harness |
| `SIGUSR1` block notify | `tokio::signal::unix` SIGUSR1 stream |
| `EXPOSE 23334 7152` | identical Dockerfile EXPOSE directives |
| `ENTRYPOINT [".../datum_gateway", "--config", ...]` | identical |
| Default config = `./datum_gateway_config.json` | identical (cwd-relative) |
| `libsodium` (required) | see Q2: pure-Rust `dryoc` recommended for musl static builds |

## CI/CD outline for the Rust port (recommended)

GitHub Actions matrix to ship a true drop-in:

```yaml
jobs:
  build:
    strategy:
      matrix:
        target:
          - x86_64-unknown-linux-gnu
          - x86_64-unknown-linux-musl    # static, Alpine-friendly
          - aarch64-unknown-linux-gnu    # Pi-class
          - aarch64-unknown-linux-musl
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with: { targets: ${{ matrix.target }} }
      - run: cargo build --release --locked --target ${{ matrix.target }}
      - uses: softprops/action-gh-release@v2
        with:
          files: target/${{ matrix.target }}/release/datum_gateway

  deb:
    runs-on: ubuntu-latest
    steps:
      - run: cargo install cargo-deb
      - run: cargo deb --target x86_64-unknown-linux-gnu
      - run: cargo deb --target aarch64-unknown-linux-gnu
      # upload .deb artifacts to release

  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: docker/setup-qemu-action@v3
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with: { registry: ghcr.io, username: ${{ github.actor }}, password: ${{ secrets.GITHUB_TOKEN }} }
      - uses: docker/build-push-action@v5
        with:
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            ghcr.io/<author>/datum-gateway:${{ github.ref_name }}
            ghcr.io/<author>/datum-gateway:latest
```

This is exactly what the C project does *not* do — and it's the lowest-effort way for a Rust port to leapfrog the upstream's distribution story.
