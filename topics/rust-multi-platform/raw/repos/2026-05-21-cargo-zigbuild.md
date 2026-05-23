---
title: "rust-cross/cargo-zigbuild — Zig-as-linker for Rust cross-compile"
source: https://github.com/rust-cross/cargo-zigbuild
type: repo
tags: [cross-compile, zig, linker, glibc-versioning, apple-darwin, universal2]
date: 2026-05-21
quality: 5
confidence: high
agent: 3
summary: "Uses 'zig cc' as drop-in replacement for platform linkers. Solves glibc-version targeting (cargo zigbuild --target aarch64-unknown-linux-gnu.2.17). Supports universal2-apple-darwin. Linux + macOS targets only — no Windows MSVC."
---

# cargo-zigbuild

## What it does

Cross-compiles Rust by using **`zig cc` as the C compiler/linker**. Zig ships glibc stubs for many versions, enabling precise libc-version targeting.

## Supported targets

- Linux GNU + musl
- macOS (x86_64 and aarch64)
- **`universal2-apple-darwin`** for macOS universal binaries (Rust 1.64.0+)
- **NOT Windows MSVC** (use cargo-xwin)

## glibc version pinning

```bash
cargo zigbuild --target aarch64-unknown-linux-gnu.2.17
```

The `.2.17` suffix instructs zig cc to link against glibc 2.17 ABI. Result: binaries that run on RHEL 7 / CentOS 7 / Ubuntu 18.04+ era systems.

**Why this matters**: Building on Ubuntu 24.04 (glibc 2.39) with stock linker bakes in references to symbols introduced in 2.39. On Ubuntu 20.04 (glibc 2.31) you get "symbol GLIBC_2.32 not found" errors. zigbuild fixes this without container builds.

## Universal macOS binary from Linux

```bash
rustup target add x86_64-apple-darwin
rustup target add aarch64-apple-darwin
cargo zigbuild --target universal2-apple-darwin
```

## Install

```bash
cargo install --locked cargo-zigbuild
# or pip auto-pulls ziglang
pip install cargo-zigbuild
```

## Limitations

- No Windows MSVC support
- Zig 0.15+ with bindgen requires clang 18+ compatibility
- `RUSTFLAGS="-C linker=..."` opts OUT of Zig usage
- Static glibc linking (`-C target-feature=+crt-static`) unsupported

## Default glibc

Versions 0.12-0.14 default to **glibc 2.28**.

## Why zigbuild beats osxcross for Apple

- Zig's macOS libc stubs are open-licensed
- osxcross requires Apple SDK extracted from Xcode (legally fraught — Xcode EULA limits use to Apple hardware)
- zigbuild is the modern Linux→macOS bridge

## Cross-references

- [[cross-rs/cross]] — Linux-Linux companion
- [[rust-cross/cargo-xwin]] — Windows MSVC companion
