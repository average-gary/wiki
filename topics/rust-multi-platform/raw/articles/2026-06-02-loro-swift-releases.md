---
title: loro-swift releases — v1.10.3 (Dec 2025)
url: https://github.com/loro-dev/loro-swift/releases
retrieved: 2026-06-02
type: repo
---

`loro-swift` is the Swift Package Manager distribution of Loro for Apple
platforms. Latest tag at retrieval: **v1.10.3 (2025-12-09)**, with prior 1.8.1
(2025-09-23) and 1.6.1 (2025-09-07) — 25 total releases, suggesting a roughly
monthly cadence. Releases ship a **pre-built `loroFFI.xcframework.zip`**, the
key practical detail for iOS app integration: the consumer pulls a binary
xcframework rather than compiling Rust from source per-developer. SPM
integration is one line: `from: "1.10.3"`, target product `Loro`. The API
exposes Loro's full container set — text, list, map, tree, movable list,
counter — plus snapshot/update import-export and version checkout. The repo
itself is labeled "experimental" in its description but the release cadence
and 1.x line argue otherwise.
