---
title: "Rust Platform Support — Apple iOS / iPadOS"
source: https://doc.rust-lang.org/nightly/rustc/platform-support/apple-ios.html
type: article
tags: [rust, ios, apple, platform-support, tier-2]
date: 2026-05-21
quality: 6
confidence: high
agent: 2
summary: "Canonical reference for iOS Rust targets. Tier 2 (prebuilt rustup): aarch64-apple-ios, aarch64-apple-ios-sim, x86_64-apple-ios. Tier 3: armv7s-apple-ios, i386-apple-ios. Min iOS 10.0; Xcode 12+ for ARM64."
---

# Rust on Apple iOS

## Tier 2 targets (prebuilt via rustup)

- `aarch64-apple-ios` — ARM64 devices (real iPhones/iPads)
- `aarch64-apple-ios-sim` — ARM64 simulator on Apple Silicon Macs
- `x86_64-apple-ios` — Intel simulator (still relevant for Intel CI runners)

## Tier 3 targets

- `armv7s-apple-ios`, `i386-apple-ios` — needs `cargo +nightly build -Zbuild-std --target ...`

## Setup

```bash
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios
```

## Requirements

- iPhoneOS.sdk or iPhoneSimulator.sdk from Xcode
- Xcode 12+ for ARM64 targets
- Min deployment target: iOS 10.0 (override via `IPHONEOS_DEPLOYMENT_TARGET`)

## Sim-vs-device cfg

```rust
#[cfg(all(target_vendor = "apple", target_env = "sim"))]
fn on_simulator() { ... }
```

## Testing

- Real devices or Xcode simulator
- Recommended tooling: `cargo-dinghy`

## Why this matters for the xcframework pipeline

A submission-ready xcframework needs **three** slices:
1. `aarch64-apple-ios` — device (the production payload)
2. `aarch64-apple-ios-sim` — simulator on Apple Silicon Macs (dev ergonomics)
3. `x86_64-apple-ios` — simulator on Intel CI runners (still required for many Bitrise/CircleCI builds)

The simulator slices are merged via `lipo -create`, then `xcodebuild -create-xcframework` packages device + unified-simulator as two separate folders inside the `.xcframework` bundle.

## Bitcode

**Not required since Xcode 14 (2022).** Rust static libs no longer need `embed-bitcode` flags.

## Cross-references

- [[Rust Android platform support]]
- [[bbqsrc/cargo-ndk]]
- [[UniFFI Swift Xcode integration]]
