---
title: "Loro vs y-crdt for Rust-native mobile CRDT sync (2026)"
type: concept
created: 2026-06-02
updated: 2026-06-02
verified: 2026-06-02
volatility: hot
confidence: medium
sources:
  - raw/articles/2026-06-02-loro-releases-1-12.md
  - raw/articles/2026-06-02-loro-readme.md
  - raw/articles/2026-06-02-loro-ffi.md
  - raw/articles/2026-06-02-loro-swift-releases.md
  - raw/articles/2026-06-02-loro-cargo-toml.md
  - raw/articles/2026-06-02-yrs-0-18-release.md
  - raw/articles/2026-06-02-y-crdt-readme.md
  - raw/articles/2026-06-02-yswift-uniffi.md
  - raw/articles/2026-06-02-yjs-v14-rc-status.md
  - raw/articles/2026-06-02-crdt-benchmarks-dmonad.md
  - raw/articles/2026-06-02-jahns-crdt-suitability.md
---

# Loro vs y-crdt for Rust-native mobile CRDT sync (2026)

## TL;DR

As of 2026-06, **Loro is the clearly more active Rust-native CRDT substrate**
(post-1.0, monthly releases, hardened atomic-import + malformed-blob handling
in v1.12, first-party `loro-swift` xcframework on a v1.10.x line) while
**y-crdt (yrs) remains pre-1.0** (v0.18 from 2025-03; no 2025 follow-up) and
its Swift binding `yswift` has not shipped since 0.2.1 in April 2024. The
single decisive advantage yrs retains is **Yjs v13 wire compatibility**;
Loro's encoding is intentionally not Yjs-compatible. The v0.4.x bet on yrs
is **defensible only if Yjs JS-ecosystem interop matters to christ-is-lord's
sermon-collaboration story** — and most plausible v0.5+ use cases (note sync
between christ-is-lord apps, not with arbitrary Yjs web clients) do not
require it.

## Evidence

**Release cadence and stability.** The Loro Rust crate is at v1.12.0 on main,
v1.12.1 in release tags ([[../../raw/articles/2026-06-02-loro-releases-1-12.md|loro releases]],
[[../../raw/articles/2026-06-02-loro-cargo-toml.md|Cargo.toml]]). Loro shipped
v1.0 in August 2024 and has tagged eight 1.x minor lines since, with v1.12.0
specifically calling out two mobile-relevant fixes: **atomic update imports
across oplog and document state** (rollback rather than divergence on apply
failure) and **`DecodeError` returns instead of panics** for malformed blobs
on unchecked import paths. By contrast, yrs is at v0.18 from 2025-03 with no
2025 follow-up release ([[../../raw/articles/2026-06-02-yrs-0-18-release.md|yrs 0.18]]).
v0.18 *is* a meaningful release — unified Observer API, logical-pointer
collection refs, `fastrand` swap for smaller WASM footprint — but it is the
sole 2025 release on a still-pre-1.0 crate.

**Mobile bindings.** Loro's `loro-ffi` is **UniFFI-based** — the same
framework christ-is-lord already uses for `logos_ffi`
([[../../raw/articles/2026-06-02-loro-ffi.md|loro-ffi]]) — and ships
Swift, Python, React Native, and community C# / Go. `loro-swift` reached
**v1.10.3 (2025-12-09)** with a pre-built `loroFFI.xcframework.zip` and
roughly monthly cadence
([[../../raw/articles/2026-06-02-loro-swift-releases.md|loro-swift releases]]).
On the y-crdt side, `yswift` is also UniFFI-based with a near-identical
two-package architecture (`yniffiFFI` xcframework + `YSwift` overlay), but
the latest tag is **v0.2.1 from April 2024**, the README still labels it WIP,
and "not all features and capabilities from Yrs or Yjs are exposed at this
time" ([[../../raw/articles/2026-06-02-yswift-uniffi.md|yswift]]). For
Android, **neither project ships a first-party Kotlin/JVM artifact**: yrs's
ecosystem points at `ykt`, Loro's points at `loro-react-native` (Android via
RN bridge). The `loro-kotlin` repo URL returns 404.

**Wire compatibility.** y-crdt's headline guarantee is **binary protocol
compatibility with Yjs** ([[../../raw/articles/2026-06-02-y-crdt-readme.md|y-crdt readme]]);
Loro's README explicitly says it adapted the Yjs *algorithm family* but does
not claim format compat ([[../../raw/articles/2026-06-02-loro-readme.md|loro readme]]).
The Yjs side of that compat story is itself stuck: **v14.0.0 has been an open
RC since 2024-05-26**; the production line is v13.6.x
([[../../raw/articles/2026-06-02-yjs-v14-rc-status.md|Yjs v14 RC]]). So the
yrs interop guarantee is "compat with Yjs v13," not with the future v14.

**Performance.** Kevin Jahns's `crdt-benchmarks` shows **Loro winning the
realistic editing workload** (B4 LaTeX trace, 259,778 ops): Loro 3,089ms vs
Yjs 5,714ms vs Automerge 14,326ms vs ywasm 28,675ms (ywasm is slower than
plain JS Yjs on this workload — a notable result for the "yrs is faster
because Rust" intuition) ([[../../raw/articles/2026-06-02-crdt-benchmarks-dmonad.md|crdt-benchmarks]]).
gzipped bundle sizes: Yjs 20KB, ywasm 214KB, Loro 399KB, Automerge 604KB —
yrs's lighter wasm bundle is the only clear footprint win in that table, and
its relevance is web-only (mobile bundle sizes are not published anywhere we
could find). Caveats: the suite is JS-side, authored by the Yjs maintainer,
and not refreshed for 2025-2026. Jahns's prior memory analysis
([[../../raw/articles/2026-06-02-jahns-crdt-suitability.md|Jahns on CRDTs]])
shows the Yjs algorithm family is tractable at sermon-note scales — 17pp
academic paper, 260k ops, 19.7MB, 20ms parse — so for christ-is-lord,
algorithmic suitability is not the deciding factor.

**Production users.** y-crdt's published sponsors and ecosystem claim cover
**NLNET, Ably, AppFlowy** ([[../../raw/articles/2026-06-02-y-crdt-readme.md|y-crdt readme]]) —
the strongest production-adjacent signal in the comparison. Loro's repo and
discussions mention small adopters and demos but no equivalently named
production deployments at the README level. Loro is the more active project,
yrs has the more visible production reference set.

## Implications for christ-is-lord

- **The v0.4.x yrs bet is defensible but no longer obviously right.** The
  CHANGELOG known-follow-up for "pure-Rust `yrs` on mobile" reflects a
  late-2024 ecosystem read in which yrs was the Rust-native default. As of
  2026-06 yrs has shipped one release in 14 months and `yswift` has shipped
  none in 26 months, while Loro's `loro-swift` has shipped on roughly a
  monthly cadence and the Rust crate is on a hardened 1.x line. The
  defensibility question is now contingent on whether **Yjs v13 wire
  compat** is required.

- **Yjs wire compat is not actually required for v0.5+ christ-is-lord
  use cases.** Concrete v0.5+ sync targets — note edits between
  christ-is-lord desktop and mobile, sermon-prep documents shared inside a
  small group, library-package metadata — are all "christ-is-lord ↔
  christ-is-lord" links. The only category where Yjs interop matters is the
  hypothetical "I want to collaborate on a sermon doc with someone using
  Tiptap or BlockNote in a browser" — and that is better delivered as a
  Hocuspocus bridge in the Node sync server (where Yjs v13 already runs)
  than by forcing the Rust core to speak Yjs.

- **Loro is mature enough to evaluate as the v0.5+ Rust-native mobile
  substrate.** It clears the engineering bars christ-is-lord cares about:
  UniFFI-based (matches `logos_ffi`), pre-built XCFramework on a v1.x
  release cadence, atomic-import-and-rollback semantics that match the
  "untrusted Iroh blob → parse → commit-or-discard" pattern in
  `wiki/concepts/append-only-audit-logs-edge-rpc.md`, MIT-licensed, small
  transitive dependency surface.

- **Decision criteria, in priority order.** (1) Does christ-is-lord need to
  read or write Yjs v13 wire format from non-app clients? If yes → yrs. If
  no → Loro is the better-positioned bet. (2) Does the Android/JVM path
  matter pre-RN? If yes → both projects are weak; yrs has `ykt` (community,
  but it exists) while Loro has only React Native. (3) Does the rich-text
  editor model matter? Loro's Fugue/Eg-walker text + moveable tree is
  better-fit for sermon-document outlines than yrs's Yjs-shape XML.

- **Concrete next experiment (v0.5 spike).** Define a `NoteSyncBackend`
  trait inside `logos_core` with the minimal four methods the existing Yjs
  binding uses (apply local op, decode remote update, snapshot, observe).
  Implement it twice — once over the existing Yjs/Hocuspocus path, once
  over Loro via `loro` 1.12 (Rust desktop) and `loro-swift` 1.10.x (iOS).
  Measure: (a) **iOS xcframework binary-size delta** — the missing public
  number in the comparison; (b) end-to-end sync RTT for a 200-op sermon-note
  trace; (c) memory under a 10k-op trace. Time-box the spike at 1 week per
  backend. Keep the trait so the choice is reversible after data, not vibes.

- **Do not retire the Yjs path on the desktop.** Yjs v13 on the web is
  stable and the Hocuspocus server is shipping. The decision under
  evaluation is the **mobile Rust-native substrate**, not the web
  collaboration layer. Whatever the experiment result, the desktop SolidJS
  client should keep using Yjs v13 unless and until the trait abstraction
  proves a Loro-only path is materially better.

- **Track Yjs v14 separately.** If Yjs v14 ever clears RC, the wire-format
  question reopens — yrs would have to choose whether to follow, and that
  choice would change yrs's competitive posture again. Until then, treat
  "Yjs interop" as "Yjs v13 interop" with full awareness of what that means.
