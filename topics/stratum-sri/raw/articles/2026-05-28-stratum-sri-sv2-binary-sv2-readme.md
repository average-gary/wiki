---
title: "binary-sv2 (sv2/binary-sv2/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/binary-sv2/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, binary-sv2]
summary: "`binary-sv2` is a Rust `no-std` crate that helps encode and decode binary data into Stratum V2 messages"
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/binary-sv2/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "58e67914056889156955bfda9a262e8c707be0c1"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/binary-sv2/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# binary-sv2

[![crates.io](https://img.shields.io/crates/v/binary-sv2.svg)](https://crates.io/crates/binary-sv2)
[![docs.rs](https://docs.rs/binary-sv2/badge.svg)](https://docs.rs/binary-sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)

`binary-sv2` is a Rust `no-std` crate that helps encode and decode binary data into Stratum V2 messages

## Key Capabilities

- **Protocol-Specific Types**: Supports fixed and dynamically-sized SV2 types.
- **Optimized Memory Use**: Supports buffer pooling to enhance memory efficiency.

## Sv2 Type Mapping

The crate supports the following mappings between Rust and SV2 types

| Rust Type   | Sv2 Type       |  
|-------------|----------------|  
| `bool`      | `BOOL`         |  
| `u8`        | `U8`           |  
| `u16`       | `U16`          |  
| `U24`       | `U24`          |  
| `u32`       | `U32`          |  
| `u64`       | `U64`          |  
| `f32`       | `F32`          |  
| `Str0255`   | `STRO_255`     |  
| `Signature` | `SIGNATURE`    |  
| `[u8]`      | `BYTES`        |  
| `Seq0255`   | `SEQ0_255[T]`  |  
| `Seq064K`   | `SEQ0_64K[T]`  | 


## Features

- **prop_test**: Adds property testing support.
- **with_buffer_pool**: Optimizes memory usage during encoding.

## Usage

To include this crate in your project, run:

```sh
cargo add binary-sv2
```