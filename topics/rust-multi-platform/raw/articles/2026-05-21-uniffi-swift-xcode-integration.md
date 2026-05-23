---
title: "UniFFI manual — Swift / Xcode integration"
source: https://github.com/mozilla/uniffi-rs/blob/main/docs/manual/src/swift/xcode.md
type: article
tags: [uniffi, swift, xcode, ios, integration, build-rule]
date: 2026-05-21
quality: 5
confidence: high
agent: 2
summary: "Three-step Xcode integration: (1) compile Rust crate as staticlib + Link Binary phase, (2) Xcode Build Rule running uniffi-bindgen on .udl files, (3) include FFI.h via Public bridging header. Don't add generated .swift to Compile Sources manually."
---

# UniFFI — Swift / Xcode integration

## Three-step integration

### 1. Compile the Rust crate

- `crate-type = ["staticlib"]` in Cargo.toml
- Add an Xcode build phase that runs `cargo build`
- Link the resulting `.a` via "Link Binary with Libraries"
- Repo's `xc-universal-binary.sh` is the historical blueprint; modern projects replace with `xcodebuild -create-xcframework`

### 2. Generate bindings via Build Rule

```
$HOME/.cargo/bin/uniffi-bindgen generate $INPUT_FILE_PATH \
  --language swift --out-dir <dir>
```

Outputs:
- `<base>.swift` — the public Swift API
- `<base>FFI.h` — C header

Add `.udl` to "Compile Sources" so Xcode runs the rule automatically.

### 3. Include the bridging header

- In your module's bridging header: `#include "exampleFFI.h"`
- Mark this header as **Public** in "Headers" build phase to avoid Xcode errors

## Critical gotcha

**Do NOT manually add the generated `.swift` to "Compile Sources"** — Xcode handles that via the build rule. Adding it manually causes duplicate-symbol errors.

## End-to-end iOS xcframework flow

```bash
# 1. Build all 3 slices
cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target x86_64-apple-ios

# 2. Merge simulator slices
lipo -create \
  target/aarch64-apple-ios-sim/release/libcore.a \
  target/x86_64-apple-ios/release/libcore.a \
  -output target/sim/libcore.a

# 3. Generate Swift bindings
uniffi-bindgen generate src/core.udl --language swift --out-dir generated/

# 4. Package as xcframework
xcodebuild -create-xcframework \
  -library target/aarch64-apple-ios/release/libcore.a -headers generated/ \
  -library target/sim/libcore.a -headers generated/ \
  -output MyCore.xcframework

# 5. Distribute via SPM
# Package.swift: .binaryTarget(name:, path: "MyCore.xcframework")
# + Swift target re-exporting core.swift
```

## SPM remote distribution

```swift
.binaryTarget(
    name: "MyCore",
    url: "https://github.com/.../MyCore.xcframework.zip",
    checksum: "..."  // swift package compute-checksum
)
```

## Async support (UniFFI Swift)

- Rust `async fn` → Swift `async`/`await`
- Sendable mostly implemented (Swift 6 partial support)
- Async still tracked in [#2448](https://github.com/mozilla/uniffi-rs/issues/2448)

## Cross-references

- [[mozilla/uniffi-rs]]
- [[Rust Apple iOS platform support]]
