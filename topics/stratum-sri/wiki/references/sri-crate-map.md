---
title: "SRI Crate Map"
category: reference
sources:
  - raw/articles/2026-05-28-stratum-sri-stratum-core-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-binary-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-binary-sv2-derive-codec-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-buffer-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-extensions-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-framing-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-handlers-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-noise-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-parsers-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-channels-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-common-messages-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-job-declaration-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-mining-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-subprotocols-template-distribution-readme.md
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [sri, sv2, sv1, crates, reference, version-map, msrv]
aliases: ["SRI crates", "SV2 crate map"]
confidence: high
volatility: hot
verified: 2026-05-28
summary: "Single-page crate map for the SRI low-level repo at HEAD 65c9688c: repo path, crates.io name, version per `stratum-core/Cargo.toml`, docs.rs link, no_std status, and a one-line role description."
---

# SRI Crate Map

> Reference table covering every crate exposed through `stratum-core` at HEAD `65c9688c` (`v1.9.0` is the most recent tag). Versions are taken from `stratum-core/Cargo.toml` path/version dependency declarations, which is the closest thing the repo has to a single-source-of-truth version manifest.

This article is **`volatility: hot`** because every release bumps versions; expect quick decay. See [SRI release process](sri-release-process.md) for the cadence.

## Top-level

| Crate | Repo path | crates.io | Version | docs.rs | Notes |
|-------|-----------|-----------|---------|---------|-------|
| `stratum-core` | `stratum-core/` | [stratum-core](https://crates.io/crates/stratum-core) | `0.4.0` (per its own `Cargo.toml`) | [docs](https://docs.rs/stratum-core) | Workspace umbrella; only `members:` entry. |
| `stratum_translation` | `stratum-core/stratum-translation/` | — | `^0.3.0` (gated by `translation` feature on `stratum-core`) | — | SV1↔SV2 translation. Implies `sv1` feature. |
| `sv1_api` | `sv1/` | [sv1_api](https://crates.io/crates/sv1_api) | `^4.0.0` (gated by `sv1` feature) | [docs](https://docs.rs/sv1_api) | Stratum V1 implementation. |

## SV2 stack — `sv2/`

| Crate | Repo path | crates.io | Version (per `stratum-core`) | docs.rs | `no_std` | Wiki article |
|-------|-----------|-----------|---|---------|----------|--------------|
| `binary_sv2` | `sv2/binary-sv2/` | [binary-sv2](https://crates.io/crates/binary-sv2) | `^5.0.0` | [docs](https://docs.rs/binary_sv2) | yes | [[sv2-binary-encoding\|SV2 Binary Encoding]] ([SV2 Binary Encoding](../concepts/sv2-binary-encoding.md)) |
| `derive-codec-sv2` | `sv2/binary-sv2/derive_codec/` | [derive-codec-sv2](https://crates.io/crates/derive-codec-sv2) | bundled w/ `binary_sv2` | [docs](https://docs.rs/derive-codec-sv2) | yes | same as above |
| `buffer_sv2` | `sv2/buffer-sv2/` | [buffer_sv2](https://crates.io/crates/buffer_sv2) | `^3.0.0` | [docs](https://docs.rs/buffer_sv2) | yes | [[sv2-buffer-pool\|SV2 Buffer Pool]] ([SV2 Buffer Pool](../concepts/sv2-buffer-pool.md)) |
| `codec_sv2` | `sv2/codec-sv2/` | [codec_sv2](https://crates.io/crates/codec_sv2) | `^5.0.0` (with `noise_sv2` feature) | [docs](https://docs.rs/codec_sv2) | yes (drop `std` feature) | [[sv2-codec\|SV2 Codec]] ([SV2 Codec](../concepts/sv2-codec.md)) |
| `extensions_sv2` | `sv2/extensions-sv2/` | [extensions_sv2](https://crates.io/crates/extensions_sv2) | `^0.1.0` | [docs](https://docs.rs/extensions_sv2) | — | [[sv2-extensions\|SV2 Extensions]] ([SV2 Extensions](../concepts/sv2-extensions.md)) |
| `framing_sv2` | `sv2/framing-sv2/` | [framing_sv2](https://crates.io/crates/framing_sv2) | `^6.0.0` | [docs](https://docs.rs/framing_sv2) | yes | [[sv2-framing\|SV2 Framing]] ([SV2 Framing](../concepts/sv2-framing.md)) |
| `handlers_sv2` | `sv2/handlers-sv2/` | [handlers_sv2](https://crates.io/crates/handlers_sv2) | `^0.4.0` | [docs](https://docs.rs/handlers_sv2) | yes | [[sv2-message-handlers\|SV2 Message Handlers]] ([SV2 Message Handlers](../concepts/sv2-message-handlers.md)) |
| `noise_sv2` | `sv2/noise-sv2/` | [noise_sv2](https://crates.io/crates/noise_sv2) | `^1.0.0` | [docs](https://docs.rs/noise_sv2) | yes (drop `std` feature) | [[sv2-noise-handshake\|SV2 Noise Handshake]] ([SV2 Noise Handshake](../concepts/sv2-noise-handshake.md)) |
| `parsers_sv2` | `sv2/parsers-sv2/` | [parsers_sv2](https://crates.io/crates/parsers_sv2) | `^0.4.0` | [docs](https://docs.rs/parsers_sv2) | yes | [[sv2-binary-encoding\|SV2 Binary Encoding]] ([SV2 Binary Encoding](../concepts/sv2-binary-encoding.md)) |
| `channels_sv2` | `sv2/channels-sv2/` | [channels_sv2](https://crates.io/crates/channels_sv2) | `^6.0.0` | [docs](https://docs.rs/channels_sv2) | client module yes (`no_std` feature) | [[sv2-channels\|SV2 Channels]] ([SV2 Channels](../concepts/sv2-channels.md)) |

## Subprotocols — `sv2/subprotocols/`

| Crate | Repo path | crates.io | Version (per `stratum-core`) | docs.rs | `no_std` | Wiki article |
|-------|-----------|-----------|---|---------|----------|--------------|
| `common_messages_sv2` | `sv2/subprotocols/common-messages/` | [common_messages_sv2](https://crates.io/crates/common_messages_sv2) | `^7.2.0` | [docs](https://docs.rs/common_messages_sv2) | yes | [[sv2-mining-subprotocol\|covered with mining]] ([covered with mining](../topics/sv2-mining-subprotocol.md)) |
| `mining_sv2` | `sv2/subprotocols/mining/` | [mining_sv2](https://crates.io/crates/mining_sv2) | `^10.0.0` | [docs](https://docs.rs/mining_sv2) | yes | [[sv2-mining-subprotocol\|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](../topics/sv2-mining-subprotocol.md)) |
| `template_distribution_sv2` | `sv2/subprotocols/template-distribution/` | [template_distribution_sv2](https://crates.io/crates/template_distribution_sv2) | `^5.1.0` | [docs](https://docs.rs/template_distribution_sv2) | yes | [[sv2-template-distribution-subprotocol\|SV2 Template Distribution Subprotocol]] ([SV2 Template Distribution Subprotocol](../topics/sv2-template-distribution-subprotocol.md)) |
| `job_declaration_sv2` | `sv2/subprotocols/job-declaration/` | [job_declaration_sv2](https://crates.io/crates/job_declaration_sv2) | `^7.1.0` | [docs](https://docs.rs/job_declaration_sv2) | yes | [[sv2-job-declaration-subprotocol\|SV2 Job Declaration Subprotocol]] ([SV2 Job Declaration Subprotocol](../topics/sv2-job-declaration-subprotocol.md)) |

## Out-of-workspace directories

The following live in the tree but are **not** workspace `members:` and are not re-exported by `stratum-core`. Use them only if you know why you need them.

- `protocols/` — at HEAD, contains only `protocols/fuzz-tests` (workspace-`exclude`d via `fuzz`). The body of crate code that historically lived here moved to `sv2/`.
- `roles/storage/` — empty at this HEAD on `main`; lives on the `feature/storage-role` branch.
- `benches/` — top-level bench harness for the SV2 crates (excluded from workspace; built ad hoc).
- `fuzz/` — `cargo-fuzz` targets, workspace-`exclude`d. See [Fuzzing README](../../raw/articles/2026-05-28-stratum-sri-fuzz-readme.md). Requires nightly + `cargo-fuzz` + LLVM tools.
- `sv2_test_client/` — empty at this HEAD on `main` (local checkout artifact).
- `integration-test-framework` — clone target of `scripts/run-integration-tests.sh`; not in repo.

## MSRV and toolchain

- **MSRV**: Rust **1.75.0** (per `rust-toolchain.toml`).
- **Components shipped via the pinned toolchain**: `rustfmt`, `clippy`, `rust-analyzer`.

## License

All crates dual-license under **Apache-2.0 OR MIT**. Per-file copyright preserved.

## See Also

- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — usage shape and feature flags
- [[sri-release-process|SRI Release Process]] ([SRI Release Process](sri-release-process.md)) — versioning rule and release branches
- [[sri-pull-request-themes|SRI Pull Request Themes]] ([SRI Pull Request Themes](sri-pull-request-themes.md)) — recent commit context

## Sources

- [stratum-core README](../../raw/articles/2026-05-28-stratum-sri-stratum-core-readme.md) — re-export list, feature flags
- Per-crate READMEs (linked in the wiki article column)
- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — workspace declaration, MSRV, license, recent tag
