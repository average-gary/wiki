---
title: "extensions_sv2 (sv2/extensions-sv2/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/extensions-sv2/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, extensions-sv2]
summary: "The `extensions_sv2` crate provides message types and utilities for Stratum V2 protocol extensions. It includes support for Extensions Negotiation (0x0001) and Worker-Specific Hashrate Tracking (0x0002), along with generic TLV (Type-Length-Value) encoding/decoding utilities that can be used by any extension requiring structured optional data fields."
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/extensions-sv2/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "3568c3b9e9428b5da4d60ba75c5afd7243c90710"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/extensions-sv2/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# extensions_sv2

[![crates.io](https://img.shields.io/crates/v/extensions_sv2.svg)](https://crates.io/crates/extensions_sv2)
[![docs.rs](https://docs.rs/extensions_sv2/badge.svg)](https://docs.rs/extensions_sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)
[![codecov](https://codecov.io/gh/stratum-mining/stratum/branch/main/graph/badge.svg?flag=extensions_sv2-coverage)](https://codecov.io/gh/stratum-mining/stratum)

The `extensions_sv2` crate provides message types and utilities for Stratum V2 protocol extensions. It includes support for Extensions Negotiation (0x0001) and Worker-Specific Hashrate Tracking (0x0002), along with generic TLV (Type-Length-Value) encoding/decoding utilities that can be used by any extension requiring structured optional data fields.

## Usage
To include this crate in your project, run:

```bash
cargo add extensions_sv2
```

## Supported Extensions

- **Extensions Negotiation (0x0001)**: Negotiate which optional extensions are supported during connection setup
- **Worker-Specific Hashrate Tracking (0x0002)**: Track individual worker hashrates using TLV fields in `SubmitSharesExtended` messages

For detailed specifications, see:
- [extensions-negotiation.md](https://github.com/stratum-mining/sv2-spec/blob/main/extensions/extensions-negotiation.md)
- [worker-specific-hashrate-tracking.md](https://github.com/stratum-mining/sv2-spec/blob/main/extensions/worker-specific-hashrate-tracking.md)