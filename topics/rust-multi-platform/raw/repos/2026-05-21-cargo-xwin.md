---
title: "rust-cross/cargo-xwin — Linux/macOS → Windows MSVC cross-compile"
source: https://github.com/rust-cross/cargo-xwin
type: repo
tags: [cross-compile, windows, msvc, xwin, microsoft-sdk]
date: 2026-05-21
quality: 4
confidence: high
agent: 3
summary: "Cross-compile to Windows MSVC from Linux/macOS without installing Microsoft toolchain. Auto-downloads CRT + Windows SDK. Supports x86, x86_64, aarch64-pc-windows-msvc. Users must accept MS license."
---

# cargo-xwin

## What it does

Cross-compile Rust to Windows MSVC targets from Linux or macOS without installing Visual Studio or the Windows SDK. Uses `xwin` or `windows-msvc-sysroot` to download required Microsoft components.

## What gets auto-downloaded

- Microsoft C Runtime (CRT)
- Windows SDK (platform headers and libraries)
- Optional: ATL, debug libraries, debug symbols

## Targets

- `x86_64-pc-windows-msvc`
- `i686-pc-windows-msvc`
- `aarch64-pc-windows-msvc` — covers Windows-on-ARM
- `arm-pc-windows-msvc`

## Licensing

> "Users must accept Microsoft's license available at the official Microsoft endpoint before using this tool."

## Usage

```bash
cargo install --locked cargo-xwin

cargo xwin build --target x86_64-pc-windows-msvc
cargo xwin build --target aarch64-pc-windows-msvc
cargo xwin test --target x86_64-pc-windows-msvc
cargo xwin run --target x86_64-pc-windows-msvc
```

## Pre-cache for offline / CI

```bash
cargo xwin cache xwin
cargo xwin cache windows-msvc-sysroot
```

## Requirements

- Clang (`brew install llvm` on macOS, `apt install clang` on Linux)
- `rustup component add llvm-tools`
- Optionally Ninja for CMake

## Cross-references

- [[cross-rs/cross]] — for non-MSVC Windows (MinGW)
- [[rust-cross/cargo-zigbuild]] — for Linux + Apple
