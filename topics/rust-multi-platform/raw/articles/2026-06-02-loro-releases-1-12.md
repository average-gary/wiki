---
title: Loro releases — v1.12.x line (April 2026)
url: https://github.com/loro-dev/loro/releases
retrieved: 2026-06-02
type: repo
---

GitHub releases page for the loro-dev/loro repository. As of April 2026 the
current line is **loro-crdt 1.12.1** (April 29 2026), with 1.12.0 (April 26)
introducing two robustness wins material to mobile use: (1) update imports are
now **atomic across oplog and document state application** — a state-application
failure rolls back rather than diverging, and (2) several decoding paths now
return `DecodeError` instead of panicking on **malformed import blobs**, closing
the unchecked-blob panic surface. v1.11.0 disabled WebAssembly reference-types
in the wasm build to keep iOS 16 compatible. The release line shows an active,
hardened post-1.0 cadence (v1.0 shipped 2024-08; the project has tagged eight
1.x minor lines since). No release note publishes binary-size or footprint
numbers directly.
