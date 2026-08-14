---
title: "Frostsnap Device Firmware Build (device crate)"
source: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/device/README.md"
type: articles
ingested: 2026-08-10
tags: [frostsnap, esp32c3, riscv32imc, embedded-rust, firmware-build, deterministic-builds, toolchain-setup]
summary: "Build instructions for the ESP32-C3 firmware written in Rust: install the stable toolchain with rust-src plus the riscv32imc-unknown-none-elf target, obtain a RISC-V GCC toolchain (distro package or the pinned 'just fetch-riscv' download), then 'just build-firmware' and 'just flash'. Also points at deterministic-build.sh for reproducible firmware builds."
collection: "frostsnap"
adapter: git
upstream_id: "device/README.md"
upstream_type: git-file
revision: "c319850a77cf077febbd9bccd9dffdf7b666b009"
sha: "63c7f92760a2db0e6856f1b4310a2599f8fe4e98"
canonical_url: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/device/README.md"
content_format: markdown
license: "MIT"
fetched: 2026-08-10
---

# Frostsnap Firmware

ESP32-C3 firmware built with Rust.

Requires RISC-V GCC toolchain for `riscv32imc-unknown-none-elf` target.

### Install Rust toolchain

```bash
rustup toolchain install stable --component rust-src
rustup target add riscv32imc-unknown-none-elf
```

### Install RISC-V GCC

- **Debian/Ubuntu**: `apt install gcc-riscv32-unknown-elf`
- **Arch**: Install `riscv-gnu-toolchain-bin` from AUR
- **Other**: Use `just fetch-riscv` to download pinned version

### Build and flash

```bash
just build-firmware
just flash
```

## Deterministic Builds

```bash
./deterministic-build.sh
```

---

## Ingest note

The repo pins the toolchain in `rust-toolchain.toml` to channel `1.88.0` with
components `rust-src`, `rustfmt`, `clippy` and target
`riscv32imc-unknown-none-elf` — more specific than the `stable` this README
suggests. The root `flake.nix` is described as "Frostsnap ESP32-C3 firmware with
deterministic builds" and pins `nixpkgs` to `nixos-25.05` with `rust-overlay`
(oxalica) and `flake-utils`.
