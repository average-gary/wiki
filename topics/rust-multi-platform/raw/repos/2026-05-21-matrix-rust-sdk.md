---
title: "matrix-org/matrix-rust-sdk — non-Mozilla UniFFI validator at scale"
source: https://github.com/matrix-org/matrix-rust-sdk
type: repo
tags: [matrix, uniffi, e2ee, swift, kotlin, element-x]
date: 2026-05-21
quality: 4
confidence: high
agent: 1
summary: "Powers Element X iOS + Android. Async, E2EE crypto, network-heavy SDK shipped via UniFFI. Bindings dir under bindings/ for Swift, Kotlin, JS, Node.js. Independent validation that UniFFI scales beyond Mozilla."
---

# matrix-rust-sdk

## Why it matters

- Production E2EE messaging at scale (Element X iOS + Element X Android)
- Confirms UniFFI handles async, complex error types, real-time networking, and crypto primitives
- Repo has dedicated `/uniffi-bindgen` and `/bindings` directories

## Bindings layout

> "The higher-level crates of the Matrix Rust SDK can be embedded in other environments such as Swift, Kotlin, JavaScript, and Node.js. Check out the bindings/ directory to learn more about how to integrate the SDK into your language of choice."

## Distribution pattern

- `matrix-rust-components-swift` (separate package) ships the binary xcframework
- Element X iOS consumes `matrix-rust-components-swift` via SPM
- Same split-package pattern as YSwift / y-uniffi (binary distribution + idiomatic overlay)

## Cross-references

- [[mozilla/uniffi-rs]]
- [[mozilla/application-services]]
