---
title: "Rust Platform Support — Android"
source: https://doc.rust-lang.org/nightly/rustc/platform-support/android.html
type: article
tags: [rust, android, platform-support, tier-2, ndk]
date: 2026-05-21
quality: 6
confidence: high
agent: 2
summary: "Canonical reference for Android Rust targets. Tier 2: aarch64-linux-android, armv7-linux-androideabi, i686-linux-android, x86_64-linux-android. Builds against most recent LTS Android NDK; ELF binaries linked against Bionic libc."
---

# Rust on Android

## Supported target triples

| Target | Use |
|--------|-----|
| `aarch64-linux-android` | **Primary modern device** (arm64-v8a) |
| `armv7-linux-androideabi` | Older 32-bit devices still on Play (armeabi-v7a) |
| `i686-linux-android` | x86 32-bit, mainly emulator |
| `x86_64-linux-android` | x86_64, emulator + Chromebook |
| `arm-linux-androideabi` | ARM 32-bit legacy |
| `thumbv7neon-linux-androideabi` | Niche |

Tier 3: `riscv64-linux-android`.

## NDK policy

- Rust supports the **most recent LTS Android NDK**
- All API levels supported by the NDK are supported by default
- 2025/2026: NDK r27 is current LTS line

## Google Play Store rules

- Requires 64-bit binaries since 2019
- Now expects 64-bit primaries
- Most projects ship 4 ABIs: `aarch64`, `armv7`, `x86_64`, `i686`
- Place `.so` files at `src/main/jniLibs/<abi>/lib<crate>.so` inside an Android library module

## Toolchain summary

- Android NDK provides cross-compilation toolchain
- `cargo-ndk` is the standard wrapper (auto-configures linker, sysroot, ANDROID_PLATFORM)
- Output `.so`s feed into a Gradle library module (`apply plugin: 'com.android.library'`)
- `./gradlew :android-lib:assembleRelease` produces the AAR

## Cross-references

- [[bbqsrc/cargo-ndk]]
- [[Rust Apple iOS platform support]]
