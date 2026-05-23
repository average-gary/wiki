---
title: "Dioxus 0.6 — first-class mobile, but ecosystem is nascent"
source: https://dioxuslabs.com/blog/release-060/
type: article
tags: [dioxus, ui-framework, mobile, hot-reload]
date: 2026-05-21
quality: 5
confidence: high
agent: 5
summary: "Dec 2024 release. dx serve --platform ios/android with hot-reload. 'less than 30 seconds away from a production-ready mobile app.' BUT: 'Rust mobile ecosystem is nascent', 'no great Rust/Java interop story', 'no great way of configuring platform-specific build flags'."
---

# Dioxus 0.6 — first-class mobile (with honest caveats)

## Headline claim

> "first-class iOS and Android support" through unified `dx serve` CLI
>
> "Dioxus is also the only Rust framework that supports `main.rs` for every platform"
>
> "less than 30 seconds away from a production-ready mobile app" (with Android NDK or iOS Simulator installed)

## What works on mobile

- Hot-reloading
- Fast rebuilds
- Asset bundling
- Logging

## What's openly admitted as missing

> "The Rust mobile ecosystem is nascent"
>
> "we don't have great ways of configuring the many platform-specific build flags"
>
> "there isn't a particularly great Rust/Java interop story"

The Java/Kotlin interop gap is structural for Android. Anything requiring real native-API access (push notifications, in-app billing, MapKit equivalents, native auth flows) becomes painful.

## Hot reload

> "Almost feels like magic"

Supports formatted strings, nested RSX blocks, component properties, Rust literals — all without rebuild.

## Production users (per Dioxus marketing)

Airbus, ESA, Cognition, Y Combinator, FutureWei.

## License

MIT/Apache 2.0

## See also

- [[dioxus-mobile crate webview reality]] — the architectural reality
- [[Tauri 2.0 release]] — same wry/webview stack underneath
