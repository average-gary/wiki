---
title: "common_messages_sv2 (sv2/subprotocols/common-messages/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/common-messages/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, subprotocols, subprotocol-common-messages]
summary: "`common_messages_sv2` is a Rust `#![no-std]` crate that implements a set of messages shared across all Stratum V2 subprotocols."
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/subprotocols/common-messages/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "c31c0ca999460dc2696d5d4745767dd892b59459"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/common-messages/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# common_messages_sv2

[![crates.io](https://img.shields.io/crates/v/common_messages_sv2.svg)](https://crates.io/crates/common_messages_sv2)
[![docs.rs](https://docs.rs/common_messages_sv2/badge.svg)](https://docs.rs/common_messages_sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)
[![codecov](https://codecov.io/gh/stratum-mining/stratum/branch/main/graph/badge.svg)](https://app.codecov.io/gh/stratum-mining/stratum/tree/main/protocols%2Fv2%2Fcommon_messages_sv2)

`common_messages_sv2` is a Rust `#![no-std]` crate that implements a set of messages shared across all Stratum V2 subprotocols.

For further information, please refer to [Stratum V2 documentation - Common Messages](https://stratumprotocol.org/specification/03-Protocol-Overview/#36-common-protocol-messages).

## Build Options

This crate can be built with the following features:
 - `quickcheck`: Enables support for property-based testing using QuickCheck.

## Usage

To include this crate in your project, run:

```bash
$ cargo add common_messages_sv2
```
