---
title: "stratum-core Umbrella Crate"
category: topic
sources:
  - raw/articles/2026-05-28-stratum-sri-stratum-core-readme.md
  - raw/articles/2026-05-28-stratum-sri-readme.md
  - raw/articles/2026-05-28-stratum-sri-license.md
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [stratum-core, sri, sv2, sv1, workspace, re-export, translation, msrv]
aliases: ["stratum-core", "stratum_core"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "`stratum-core` is the single workspace member in the `stratum-mining/stratum` repo and the Cargo entry point downstream code uses to depend on the SV2 stack. It re-exports binary/codec/framing/noise/parsers/handlers/channels/extensions and the four subprotocol crates, with optional `sv1` and `translation` features for the V1↔V2 path."
---

# stratum-core Umbrella Crate

> Most consumers of the SRI stack do not want to manage 12 individual crate dependencies. `stratum-core` is the umbrella — it re-exports the entire low-level surface through one crate. It is also the only `members:` entry in the workspace `Cargo.toml`; everything else (`sv1/`, `sv2/*`, `protocols/`, `roles/storage`, `benches/`, `fuzz/`) is present in the tree but managed as path/version dependencies.

## What it re-exports

From `stratum-core/Cargo.toml` at HEAD `65c9688c`, the dependency surface is:

| Re-export | Path | Version |
|-----------|------|---------|
| `buffer_sv2` | `../sv2/buffer-sv2` | `^3.0.0` |
| `binary_sv2` | `../sv2/binary-sv2` | `^5.0.0` |
| `codec_sv2` | `../sv2/codec-sv2` (with `noise_sv2`) | `^5.0.0` |
| `extensions_sv2` | `../sv2/extensions-sv2` | `^0.1.0` |
| `framing_sv2` | `../sv2/framing-sv2` | `^6.0.0` |
| `noise_sv2` | `../sv2/noise-sv2` | `^1.0.0` |
| `parsers_sv2` | `../sv2/parsers-sv2` | `^0.4.0` |
| `handlers_sv2` | `../sv2/handlers-sv2` | `^0.4.0` |
| `channels_sv2` | `../sv2/channels-sv2` | `^6.0.0` |
| `common_messages_sv2` | `../sv2/subprotocols/common-messages` | `^7.2.0` |
| `mining_sv2` | `../sv2/subprotocols/mining` | `^10.0.0` |
| `template_distribution_sv2` | `../sv2/subprotocols/template-distribution` | `^5.1.0` |
| `job_declaration_sv2` | `../sv2/subprotocols/job-declaration` | `^7.1.0` |

Optional, behind features:

| Re-export | Feature | Notes |
|-----------|---------|-------|
| `sv1_api` (`^4.0.0`) | `sv1` | The Stratum V1 crate at `../sv1` |
| `stratum_translation` (`^0.3.0`) | `translation` | Implies `sv1`. Lives at `stratum-core/stratum-translation/`. |

`bitcoin` is a regular `workspace` dependency.

## Feature flags

`stratum-core` exposes three flags, in addition to the per-subcrate ones:

- `with_buffer_pool` — propagates to `binary_sv2`, `framing_sv2`, and `codec_sv2`. This is the project-wide switch that turns on the [[sv2-buffer-pool|`BufferPool`]] ([`BufferPool`](../concepts/sv2-buffer-pool.md)) path; it is **not** automatic.
- `sv1` — pulls in `sv1_api`.
- `translation` — pulls in `stratum_translation` (and implies `sv1`).

## Usage shape

The README's "Basic usage" block:

```rust
use stratum_core::{
    binary_sv2,
    codec_sv2,
    framing_sv2,
    noise_sv2,
    mining_sv2,
    // … all protocol crates available
};
```

So the umbrella is a thin re-export layer; downstream code reaches into the same module names it would have if it depended on each crate directly.

## Workspace status

The repo's `Cargo.toml` has exactly:

```toml
[workspace]
resolver = "2"
members = ["stratum-core"]
exclude = ["integration-test-framework", "fuzz"]
```

Anything not under `stratum-core/` (the SV2 crate suite under `sv2/`, the SV1 crate under `sv1/`, top-level `protocols/`, `roles/`, `benches/`) is reachable only via the path/version dependencies above. `fuzz/` and the integration-test framework are explicitly excluded from the workspace graph.

## Versioning

Per [[sri-release-process|SRI release process]] ([SRI release process](../references/sri-release-process.md)), individual crates follow SemVer 2.0.0 and the **repository** follows X.Y.Z under the maintainers' subjective rule (`Z` for fix-only, `Y` for breaking-or-not, `X` for milestones). The latest tag at HEAD is `v1.9.0`. There was a brief attempt (PR #2158) to add a `stratum-core` versioning exception to `CONTRIBUTING.md`; it was reverted in PR #2160 (HEAD merge), so today there is no special case for `stratum-core`.

## License and MSRV

- **License**: Apache-2.0 OR MIT (per-file copyright preserved). `LICENSE.md` notes that any use must comply with one or both licenses.
- **MSRV**: Rust **1.75.0** (`rust-toolchain.toml` pins `channel = "1.75.0"` with `rustfmt`, `clippy`, `rust-analyzer` components).

## See Also

- [[sv2-binary-encoding|SV2 Binary Encoding]] ([SV2 Binary Encoding](../concepts/sv2-binary-encoding.md)) — re-exported via `binary_sv2`
- [[sv2-codec|SV2 Codec]] ([SV2 Codec](../concepts/sv2-codec.md)) — re-exported via `codec_sv2`
- [[sv2-framing|SV2 Framing]] ([SV2 Framing](../concepts/sv2-framing.md)) — re-exported via `framing_sv2`
- [[sv2-noise-handshake|SV2 Noise Handshake]] ([SV2 Noise Handshake](../concepts/sv2-noise-handshake.md)) — re-exported via `noise_sv2`
- [[sv2-buffer-pool|SV2 Buffer Pool]] ([SV2 Buffer Pool](../concepts/sv2-buffer-pool.md)) — backing for `with_buffer_pool`
- [[sv2-channels|SV2 Channels]] ([SV2 Channels](../concepts/sv2-channels.md)) — re-exported via `channels_sv2`
- [[sv2-message-handlers|SV2 Message Handlers]] ([SV2 Message Handlers](../concepts/sv2-message-handlers.md)) — re-exported via `handlers_sv2`
- [[sv2-extensions|SV2 Extensions]] ([SV2 Extensions](../concepts/sv2-extensions.md)) — re-exported via `extensions_sv2`
- [[sv2-mining-subprotocol|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](sv2-mining-subprotocol.md)) — re-exported via `mining_sv2`
- [[sv2-job-declaration-subprotocol|SV2 Job Declaration Subprotocol]] ([SV2 Job Declaration Subprotocol](sv2-job-declaration-subprotocol.md)) — re-exported via `job_declaration_sv2`
- [[sv2-template-distribution-subprotocol|SV2 Template Distribution Subprotocol]] ([SV2 Template Distribution Subprotocol](sv2-template-distribution-subprotocol.md)) — re-exported via `template_distribution_sv2`
- [[sri-crate-map|SRI Crate Map]] ([SRI Crate Map](../references/sri-crate-map.md)) — version/path/docs.rs table for every crate
- [[sri-release-process|SRI Release Process]] ([SRI Release Process](../references/sri-release-process.md)) — versioning rule and the #2158/#2160 churn
- [[sri-pull-request-themes|SRI Pull Request Themes]] ([SRI Pull Request Themes](../references/sri-pull-request-themes.md)) — context for the reverted versioning exception

## Sources

- [stratum-core README](../../raw/articles/2026-05-28-stratum-sri-stratum-core-readme.md) — purpose, usage, feature flags
- [Stratum repo README](../../raw/articles/2026-05-28-stratum-sri-readme.md) — repo-level scope: low-level crates only
- [LICENSE.md](../../raw/articles/2026-05-28-stratum-sri-license.md) — dual Apache-2.0/MIT licensing
- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — workspace declaration, crate versions, MSRV, recent PR churn
