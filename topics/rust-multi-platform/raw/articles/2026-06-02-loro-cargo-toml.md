---
title: loro crate Cargo.toml — v1.12.0 dependencies
url: https://github.com/loro-dev/loro/blob/main/crates/loro/Cargo.toml
retrieved: 2026-06-02
type: repo
---

Verifies the headline crate version: the `loro` Rust crate is at **1.12.0**
on main. Dependency surface at this version: `loro-internal` 1.12.0,
`loro-common` 1.12.0 (with `serde_json` feature), `loro-kv-store` 1.12.0,
`loro-delta` 1.9.1, `generic-btree` ^0.10.7, plus workspace
`enum-as-inner`, `tracing`, `rustc-hash`. License MIT. Description: "Loro
is a high-performance CRDTs framework. Make your app collaborative
effortlessly." Confirms three useful properties for christ-is-lord's
substrate evaluation: (1) the crate is maintained on a tight 1.x semver
line, (2) the dependency footprint is small enough to be a realistic
addition to `logos_core` without a heavy transitive blast radius, and
(3) the workspace structure (`loro-internal` / `loro-common` /
`loro-kv-store` / `loro-delta`) is clean enough that an FFI consumer only
sees the single `loro` re-export crate.
