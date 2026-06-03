---
title: YSwift — Yjs-compatible Swift bindings via UniFFI
url: https://github.com/y-crdt/yswift
retrieved: 2026-06-02
type: repo
---

YSwift exposes y-crdt to Swift "with seamless interoperability with other
Yjs implementations." Architecture matches christ-is-lord's existing
`logos_ffi` pattern almost exactly: it ships **two packages — `yniffiFFI`
(compiled Rust as an XCFramework) and `YSwift` (an idiomatic Swift overlay)**
— built with **Mozilla UniFFI**. The repository is honest about status:
explicitly labeled **WIP**, "not all features and capabilities from Yrs or
Yjs are exposed at this time." Latest release **0.2.1 (April 2024)** — no
2025 release at retrieval, only 3 total releases, 89 stars / 14 forks. By
contrast `loro-swift` reached v1.10.3 with monthly cadence in the same window.
For christ-is-lord this is the central practical point: a Yjs-compat Swift
path exists, but it is dormant and incomplete; the Loro-Swift path is active.
