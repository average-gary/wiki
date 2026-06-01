---
title: "moq-dev/moq — canonical MoQ Rust monorepo"
source: https://github.com/moq-dev/moq
type: repo
tags: [moq, moq-lite, moq-rs, kixelated, web-transport-iroh]
date: 2026-06-01
quality: 5
confidence: high
agent: 2
summary: "The canonical 'moq-rs' moved org from kixelated/moq-rs to moq-dev/moq (same maintainers). Now polyglot — Rust, TS, Go, Kotlin, Swift, Python. 17 Rust workspace members under rs/. moq-relay packaged for Debian/Ubuntu via apt.moq.dev and RPM via rpm.moq.dev. Relay is application-agnostic (does not parse codecs) and supports E2E encryption."
---

# moq-dev/moq

## Workspace layout (Rust)

17 crates under `rs/`:

| Crate              | Role |
|--------------------|------|
| `libmoq`           | Top-level umbrella |
| `moq-net`          | Protocol/session layer (the actual moq-lite + moq-transport state machine) |
| `moq-native`       | Transport adapters — features: `iroh`, `quinn`, `quiche`, `noq` |
| `moq-relay`        | Fan-out / clusterable server binary |
| `moq-cli`          | Publish/subscribe CLI |
| `moq-token`, `moq-token-cli` | Auth tokens |
| `moq-mux`          | Multiplexing |
| `moq-loc`          | Low-overhead container streaming format |
| `moq-msf`          | Media streaming format |
| `moq-audio`, `moq-video`, `moq-boy` | Codec adapters |
| `moq-gst`          | GStreamer plugin |
| `moq-ffi`          | C-FFI for non-Rust languages |
| `hang`             | Reference media app |
| `kio`              | I/O abstraction (custom executor support) |

## Distribution

- `apt.moq.dev` — Debian/Ubuntu repo with hardened systemd unit
- `rpm.moq.dev` — RPM-family repo
- `moq-ffi v0.2.17` released 2026-05-30; 1,412 commits, 59 releases
- Release cadence: every few days

## Multi-language SDKs

Rust, TypeScript, Go, Kotlin, Swift, Python — all in the same monorepo.

## moq-lite definition

> "moq-lite is a forwards-compatible subset of the IETF moq-transport draft (draft-14+); works with any moq-transport CDN."

Cloudflare's MoQ CDN is explicitly named as compatible. See [[2026-06-01-moq-cloudflare-cdn-blog]].

## Why this matters

For an Iroh AI server: `moq-relay 0.12.5` ships with `default = ["iroh", "quinn", "websocket"]`. iroh is **on by default**. See [[2026-06-01-moq-relay-cargo-features]].
