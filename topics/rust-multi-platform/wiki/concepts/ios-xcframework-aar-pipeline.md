---
title: "iOS xcframework + Android AAR shipping pipeline"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-21-application-services.md
  - raw/articles/2026-05-21-rust-apple-ios-platform-support.md
  - raw/articles/2026-05-21-rust-android-platform-support.md
  - raw/articles/2026-05-21-uniffi-swift-xcode-integration.md
  - raw/repos/2026-05-21-cargo-ndk.md
---

# Mobile shipping pipeline: xcframework + AAR

## TL;DR

UniFFI generates the binding code; **packaging is your job**. Two parallel pipelines you'll maintain in CI:
- **iOS**: 3 Rust target slices → `lipo` merge sims → `xcodebuild -create-xcframework` → SPM binaryTarget
- **Android**: 4 Rust target slices via `cargo-ndk` → Gradle library module → `.aar` → Maven publish

Use the **Mozilla megazord pattern** ([application-services](../../raw/repos/2026-05-21-application-services.md)) when you ship multiple Rust components — bundle into one AAR + one xcframework to avoid runtime duplication.

## iOS pipeline

### Setup

```bash
rustup target add aarch64-apple-ios          # device
rustup target add aarch64-apple-ios-sim      # sim on Apple Silicon
rustup target add x86_64-apple-ios           # sim on Intel CI runners
```

[Tier 2 in Rust](../../raw/articles/2026-05-21-rust-apple-ios-platform-support.md). Min iOS 10.0; Xcode 12+.

### End-to-end build

```bash
# 1. Build all 3 slices
cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target x86_64-apple-ios

# 2. Merge simulator slices via lipo
lipo -create \
  target/aarch64-apple-ios-sim/release/libcore.a \
  target/x86_64-apple-ios/release/libcore.a \
  -output target/sim/libcore.a

# 3. Generate Swift bindings (UniFFI)
uniffi-bindgen generate src/core.udl --language swift --out-dir generated/

# 4. Package as xcframework
xcodebuild -create-xcframework \
  -library target/aarch64-apple-ios/release/libcore.a -headers generated/ \
  -library target/sim/libcore.a -headers generated/ \
  -output MyCore.xcframework

# 5. Distribute via SPM (Package.swift)
#    .binaryTarget(name: "MyCore", path: "MyCore.xcframework")
#    + Swift target re-exporting core.swift
```

### SPM remote distribution

```swift
.binaryTarget(
    name: "MyCore",
    url: "https://github.com/.../MyCore.xcframework.zip",
    checksum: "..."  // swift package compute-checksum
)
```

### Bitcode

**Not required since Xcode 14 (2022).** Rust static libs no longer need `embed-bitcode` flags.

### Code signing

The static `.a` linked into your app needs no separate signing — it's just code. The host app gets signed normally via Apple Developer Program. App Store Connect upload via `xcodebuild archive` + Transporter.

## Android pipeline

### Setup

```bash
rustup target add \
  aarch64-linux-android \
  armv7-linux-androideabi \
  x86_64-linux-android \
  i686-linux-android

cargo install cargo-ndk
```

[Tier 2 in Rust](../../raw/articles/2026-05-21-rust-android-platform-support.md). NDK r27 LTS as of 2026.

### End-to-end build

```bash
# 1. Build 4 ABIs into jniLibs (cargo-ndk does the heavy lifting)
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -t x86 \
  -o ./android-lib/src/main/jniLibs build --release

# 2. Generate Kotlin bindings (UniFFI)
uniffi-bindgen generate src/core.udl --language kotlin \
  --out-dir android-lib/src/main/java/

# 3. Build the AAR
./gradlew :android-lib:assembleRelease

# 4. Publish
./gradlew :android-lib:publishToMavenLocal       # local dev
# Or publishToMavenCentral via Vanniktech plugin
# Or push to private Maven (Artifactory / GitHub Packages)
```

### Gradle library module

```kotlin
// android-lib/build.gradle.kts
plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    namespace = "com.example.mycore"
    compileSdk = 35
    defaultConfig { minSdk = 24 }
    sourceSets["main"].jniLibs.srcDirs("src/main/jniLibs")
}
```

Play Store submission consumes the AAR from the app module's Gradle deps. AAB built normally; Play splits per-ABI APKs at install time.

## Size optimization (consistent across sources)

```toml
# Cargo.toml
[profile.release]
panic = "abort"
lto = true
codegen-units = 1
opt-level = "z"
strip = "symbols"
```

A naive Rust mobile core often starts at 8-15 MB per ABI; with these flags it commonly drops to 2-5 MB.

## CI architecture

Single Rust core SemVer (`Cargo.toml` version) is the source of truth. Release script bumps `Package.swift` (iOS) and `gradle.properties` version (Android) simultaneously.

```yaml
# Pseudo-pipeline
- macOS runner: build all 3 iOS slices + xcframework + zip + checksum
- Ubuntu runner: build 4 Android ABIs + AAR
- Release runner: tag, push to GitHub Releases (xcframework zip), publish to Maven (AAR)
```

## The version-pinning lesson

A real production Rust + mobile project has **three sets of version pins**:
- `Cargo.toml` workspace
- `gradle/libs.versions.toml` (Android)
- `Package.swift` (iOS) or Podfile

They don't auto-sync. Either:
- (a) write a release script that bumps all three from a single source-of-truth file (Matrix Rust SDK pattern, Firefox pattern), OR
- (b) accept manual sync (Yral pattern)

Putting the Rust SemVer in the binary itself via `env!("CARGO_PKG_VERSION")` lets you verify at runtime that an old AAR wasn't accidentally shipped against a new app.

## Cross-references

- [[mobile-ffi-decision-tree]]
- [[Rust Apple iOS platform support]]
- [[Rust Android platform support]]
- [[UniFFI Swift Xcode integration]]
- [[bbqsrc/cargo-ndk]]
