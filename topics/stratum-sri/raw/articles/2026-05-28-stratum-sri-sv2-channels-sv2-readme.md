---
title: "`channels_sv2` (sv2/channels-sv2/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/channels-sv2/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, channels-sv2]
summary: "`channels_sv2` provides primitives and abstractions for Stratum V2 (Sv2) Channels."
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/channels-sv2/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "e4aa86fe5c5796fb0bda9e4213c5e74c00ff0d6a"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/channels-sv2/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# `channels_sv2`

[![crates.io](https://img.shields.io/crates/v/channels_sv2.svg)](https://crates.io/crates/channels_sv2)
[![docs.rs](https://docs.rs/channels_sv2/badge.svg)](https://docs.rs/channels_sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)
[![codecov](https://codecov.io/gh/stratum-mining/stratum/branch/main/graph/badge.svg?flag=channels_sv2-coverage)](https://codecov.io/gh/stratum-mining/stratum)

`channels_sv2` provides primitives and abstractions for Stratum V2 (Sv2) Channels.

This crate implements the core channel management functionality for both mining clients and servers, including standard, extended and group channels, and share accounting mechanisms.

The `client` module is compatible with `no_std` environments. To enable this mode, build the crate with the `no_std` feature. In this configuration, standard library collections are replaced with the `hashbrown` crate, together with `core` and `alloc`, allowing the module to be used in embedded or constrained contexts.

```bash
cargo build --features no_std
```
