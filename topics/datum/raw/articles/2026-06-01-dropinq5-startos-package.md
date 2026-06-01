# DATUM Gateway: StartOS (Embassy / Start9) Package

**Source:** `OCEAN-xyz/datum-gateway-startos` repo (manifest.yaml, Dockerfile, docker_entrypoint.sh).
**Fetched:** 2026-06-01.

## Why this matters

StartOS (Start9 Labs' Embassy OS) is a popular self-hosted Bitcoin node OS. The `datum-gateway-startos` repo wraps the C `datum_gateway` as an `.s9pk` service. **A drop-in Rust port can replace the upstream C submodule and inherit this distribution channel for free** — StartOS users get the Rust binary via a manifest version bump and a rebuild.

The repo uses **`datum_gateway @ 5b06123` as a Git submodule**, so the Rust port slots in by:
1. Forking `datum-gateway-startos`
2. Replacing the submodule URL with the Rust port repo
3. Adjusting the Dockerfile build steps from `cmake . && make` to `cargo build --release --locked`
4. Bumping the manifest version

## manifest.yaml — extracted contents

```yaml
id: datum
title: "Datum Gateway"
version: "0.4.1.1"
description:
  short: "Make block templates and issue work to your miners"
  long: "Allows miners to generate templates and issue work while sharing pool rewards or solo mining."
build: ["make"]
main:
  type: docker
  image: main
  entrypoint: "docker_entrypoint.sh"
  mounts:
    main: /root
volumes:
  main:
    type: data
hardware-requirements:
  arch: [x86_64, aarch64]
  gpu: false
dependencies:
  bitcoind:
    version: ">=0.21.1.2"
    requirement: { type: required }
interfaces:
  main:    # Web UI dashboard
    tor-config: { ... }
    lan-config: { 7152: { ssl: false }, 443: { ssl: true } }
    protocols: [tcp, http]
  mining:  # ASIC stratum
    tor-config: { ... }
    lan-config: { 23335: { ssl: false } }   # NOTE: 23335 not 23334
    protocols: [tcp, stratum, http]
```

**Key shape items:**
- **Volume:** `main` mounts at `/root`, type `data` → persistent.
- **Mining port:** **`23335`** in StartOS (different from the bare Docker `23334` — there's a port-shift, the entrypoint or config likely binds the C process to 23335 inside the container).
- **Hardware arches:** `x86_64` + `aarch64` — matches Launchpad PPA arches and Debian package arch.
- **Build:** literal `make` (the Makefile in the startos repo orchestrates `s9pk` packaging).

## Dockerfile (startos variant)

```dockerfile
FROM debian:bookworm-slim AS build
RUN apt install build-essential cmake curl libmicrohttpd-dev libjansson-dev \
    libcurl4-openssl-dev libgcrypt20-dev libsodium-dev netcat-traditional \
    pkg-config git
COPY ./datum_gateway /parent_dir/datum_gateway   # the submodule
WORKDIR /parent_dir/datum_gateway
RUN cmake . && make

FROM debian:bookworm-slim AS final
RUN apt install curl netcat-traditional libmicrohttpd12 libjansson4 \
    libsodium23 jq
# yq downloaded with SHA256 verification
COPY --from=build /parent_dir/datum_gateway/datum_gateway /usr/local/bin/datum_gateway
COPY docker_entrypoint.sh /usr/local/bin/
COPY scripts/check-*.sh /usr/local/bin/
WORKDIR /root
```

## docker_entrypoint.sh

```sh
#!/bin/sh
# ... templating: read /root/start9/config.yaml via yq
# ... validate bitcoind blocknotify field
# ... apply conditional filters on .datum.reward_sharing (require/prefer/never)
# ... transform username modifiers (addresses + splits)
# ... write /root/data/datum_gateway_config.json
exec datum_gateway -c /root/data/datum_gateway_config.json
```

The StartOS UI gathers config in YAML; this entrypoint *generates* the JSON the C binary expects, then `exec`s it. **The Rust port must accept the identical `-c <FILE>` flag and identical config JSON schema** for the entrypoint script to work unchanged.

## Drop-in recipe for the Rust port via StartOS

1. **Rust binary contract** (must match exactly):
   - Binary on PATH as `datum_gateway` (underscore).
   - Accepts `-c /path/to/file.json`.
   - Reads the same JSON schema OCEAN's C parses (Q3/Q4 territory: config keys + tide/payout knobs).
2. **Modify `datum-gateway-startos/Dockerfile`:**
   ```dockerfile
   FROM rust:1-bookworm AS build
   COPY ./datum_gateway_rs /src
   WORKDIR /src
   RUN cargo build --release --locked --bin datum_gateway

   FROM debian:bookworm-slim AS final
   RUN apt install curl netcat-traditional jq
   # NO libsodium23 / libjansson4 / libmicrohttpd12 needed if pure-Rust deps
   COPY --from=build /src/target/release/datum_gateway /usr/local/bin/
   COPY docker_entrypoint.sh /usr/local/bin/
   ```
3. **manifest.yaml:** bump `version`, update Git submodule URL → `OCEAN-xyz/datum_gateway_rs` (or wherever the Rust port lives). Everything else (volumes, ports, interfaces) stays identical.
4. **Submit to Start9 marketplace** as a separate package id (e.g., `datum-rs`) OR as a parallel manifest contributed back to OCEAN. Operators install via Start9's UI.

This is genuinely **free distribution** to a meaningful slice of solo-mining home-node operators.

## What's NOT in the manifest

- No env vars (config is YAML→JSON templated).
- No GPU.
- No notify-style restart hooks (StartOS handles supervision externally).
- No reproducible-build attestation.
