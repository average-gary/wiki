---
title: "mozilla/application-services — the canonical UniFFI shipper (Firefox shared core)"
source: https://github.com/mozilla/application-services
type: repo
tags: [uniffi, mozilla, firefox, megazord, reference-architecture]
date: 2026-05-21
quality: 5
confidence: high
agent: 1
summary: "Reference architecture for 'Rust core, two mobile frontends.' fxa-client, logins, places, sync15, nimbus, autofill, tabs, push, remote-settings — all shipped via UniFFI to Firefox iOS+Android. Megazord pattern bundles components into one platform artifact (single AAR, single xcframework) to avoid per-component runtime duplication."
---

# mozilla/application-services

## Architecture (canonical)

> "Each component is built using a core of shared code written in Rust, wrapped with native language bindings for different platforms."

Codebase composition: 88.8% Rust, 5.8% Kotlin, 0.5% Swift — bindings layer is thin; logic lives in Rust core.

## Components shipped via this pipeline

`fxa-client`, `logins`, `places`, `sync15`, `nimbus`, `autofill`, `tabs`, `push`, `remote-settings` — all into Firefox iOS and Firefox Android (Fenix).

## Megazord pattern (the key insight)

`/megazords` directory bundles **multiple Rust components into one platform artifact**:
- single AAR for Android
- single xcframework for iOS

Avoids duplicating the Rust runtime / libstd / shared dependencies across per-component artifacts. Without megazords, every UniFFI'd component would carry its own ~5MB Rust runtime tax.

## Cross-references

- [[mozilla/uniffi-rs]] — the binding generator this repo demonstrates
- [[matrix-org/matrix-rust-sdk]] — independent validator at scale
- [[bitwarden/sdk-internal]] — same pattern, smaller
