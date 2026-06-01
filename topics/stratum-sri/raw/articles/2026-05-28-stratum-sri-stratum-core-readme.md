---
title: "Stratum Core (stratum-core/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/stratum-core/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, stratum-core]
summary: "Central hub for the Stratum V2 ecosystem, providing a cohesive API for all low-level protocol functionality."
collection: "stratum-sri"
adapter: git
upstream_id: "stratum-core/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "300ff0a30cc34b3b7145eed6f2479740f9fd3c7b"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/stratum-core/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# Stratum Core

Central hub for the Stratum V2 ecosystem, providing a cohesive API for all low-level protocol functionality.

## Overview

`stratum-core` re-exports all the foundational Stratum protocol crates through a single entry point. This includes binary serialization, framing, message handling, cryptographic operations, and all Stratum V2 subprotocols.

## Usage

Add to your `Cargo.toml`:

```toml
[dependencies]
stratum-core = "0.1.0"
```

Basic usage:

```rust
use stratum_core::{
    binary_sv2,
    codec_sv2,
    framing_sv2,
    noise_sv2,
    mining_sv2,
    // ... all protocol crates available
};
```

## Features

- `with_buffer_pool` - Enable buffer pooling for improved memory management and performance
- `sv1` - Include Stratum V1 protocol support
- `translation` - Enable translation utilities between SV1 and SV2 (includes `sv1`)

