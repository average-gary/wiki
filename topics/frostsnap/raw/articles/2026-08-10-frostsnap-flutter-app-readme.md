---
title: "Frostsnap Flutter App Build (frostsnapp)"
source: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnapp/README.md"
type: articles
ingested: 2026-08-10
tags: [frostsnap, flutter, flutter-rust-bridge, coordinator-app, cross-platform-build, android-adb, dart-rust-ffi]
summary: "Build setup for the cross-platform Flutter wallet app that acts as the FROST coordinator, calling into native Rust via flutter_rust_bridge. Covers installing the Flutter SDK and cargo binaries (including flutter_rust_bridge_codegen), fetching a RISC-V C compiler, generating bindings with 'just gen', and building/running for Linux and Android APK targets. Retains the file's origin as a flutter_rust_bridge project template and its candid note that the instructions are incomplete."
collection: "frostsnap"
adapter: git
upstream_id: "frostsnapp/README.md"
upstream_type: git-file
revision: "c319850a77cf077febbd9bccd9dffdf7b666b009"
sha: "3d9df3b9374b1499b04c475a3df995974ab61c6d"
canonical_url: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnapp/README.md"
content_format: markdown
license: "MIT"
fetched: 2026-08-10
---

# Frostsnap

This repository serves as a template for Flutter projects calling into native Rust
libraries via `flutter_rust_bridge`.

## Steps to build

###  Install the flutter SDK

https://docs.flutter.dev/get-started/install

### Install flutter rust bridge

Run `just install-cargo-bins` which will install all the necessary cargo binaries included `flutter_rust_bridge_codegen`.

Make a test app with `flutter_rust_bridge_codegen create testapp`

And make sure you can run the app for the platform you want to build on.

See the [`flutter_rust_bridge`](https://cjycode.com/flutter_rust_bridge/) website for up to date information on how set up your environment


### Get a RISCV c compiler


```
just fetch-riscv
```

And add the downloaded riscv toolchain to your path.


### Generate the bindings


```sh
just gen
```

## build



```
just build linux
just build apk
```

Or run it:

```
just run
```

Flutter will give you an option of running on an android device if one is connected (in [debug mode](https://www.lifewire.com/enable-usb-debugging-android-46L90927)). If you can not see your device you may need to check `adb devices` ([android debug bridge](https://wiki.archlinux.org/title/Android_Debug_Bridge)) shows your device.

## Build

When this doesn't work figure out why and fix these instructions please. If you want to run on android it may help to open the project in android studio.

---

## Ingest note

This README still carries boilerplate from the `flutter_rust_bridge` project
template ("This repository serves as a template for...") and ends with an
explicit admission that the instructions are incomplete. Treat it as
lower-confidence build guidance than `PROVISIONING.md`, which documents the
`just build linux` path with env-specific key embedding. The Rust side of the app
is the `frostsnapp/rust` workspace member; desktop camera capture for QR scanning
lives in `frostsnapp/desktop_camera`.
