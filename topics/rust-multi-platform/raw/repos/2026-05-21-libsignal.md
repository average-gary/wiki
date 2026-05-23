---
title: "signalapp/libsignal — the UniFFI counter-example (hand-rolled FFI)"
source: https://github.com/signalapp/libsignal
type: repo
tags: [signal, ffi, jni, hand-rolled, abi-control, counter-example]
date: 2026-05-21
quality: 5
confidence: high
agent: 1
summary: "Signal's crypto core uses hand-rolled FFI/JNI, NOT UniFFI. Per-platform bridge layout: rust/bridge/jni/, equivalent for Swift, Node bridge. Custom Python codegen for Java declarations. Trade-off: tight ABI control, no extra serialization, custom error mapping — at cost of maintenance."
---

# signalapp/libsignal

## Why this is the decisive UniFFI counter-example

- Hand-rolled FFI/JNI per platform, **not UniFFI**
- 60.4% Rust core; bridge layer is significant maintained surface
- Demonstrates: when ABI control, perf, or unusual types matter (crypto primitives, opaque handles), sophisticated teams still hand-roll

## Bridge architecture

- `rust/bridge/jni/` — Android
- equivalent for Swift
- Node bridge for desktop / web tooling
- Custom Python codegen `gen_java_decl.py` produces Java declarations — bespoke tooling per language

## When to pick hand-rolled FFI over UniFFI

| Signal | Pick hand-rolled |
|--------|------------------|
| Wrapping a stable, curated surface | No → UniFFI |
| Wrapping a fast-evolving large API surface | YES → see [[iroh-ffi archived]] for the cautionary tale |
| Crypto primitives, opaque handles, fine ABI control | YES |
| Need to ship reasonable artifacts in months | Maybe → swift-bridge / UniFFI |

## Real cost of hand-rolling

- 3 bridges to maintain (JNI / Swift C-headers / Node-API)
- Custom codegen scripts
- Independent error-mapping per language
- Manual coordination on every API change

## Cross-references

- [[mozilla/uniffi-rs]] — the alternative
- iroh-ffi was UniFFI-based and was archived; n0 now recommends "wrap iroh behind your own daemon and call that" — a hand-rolled-narrow-FFI strategy aligned with libsignal's approach. See [[gtx-1060-headless-ai-server/concepts/whisperx-known-broken-installs]] cross-wiki for context.
