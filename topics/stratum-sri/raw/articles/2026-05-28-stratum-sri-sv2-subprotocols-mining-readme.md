---
title: "mining_sv2 (sv2/subprotocols/mining/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/mining/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, subprotocols, subprotocol-mining]
summary: "`mining_sv2` is a Rust `#![no_std]` crate that implements a set of messages defined in the Mining protocol of Stratum V2. The Mining protocol enables: - distribution of work to mining devices - submission of proof of work from mining devices - notification of custom work to pool (in conjunction with Job Declaration Subprotocol)"
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/subprotocols/mining/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "008facedc29103a31bc8e6f3019d23101ffa5718"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/mining/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# mining_sv2

[![crates.io](https://img.shields.io/crates/v/mining_sv2.svg)](https://crates.io/crates/mining_sv2)
[![docs.rs](https://docs.rs/mining_sv2/badge.svg)](https://docs.rs/mining_sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)
[![codecov](https://codecov.io/gh/stratum-mining/stratum/branch/main/graph/badge.svg)](https://app.codecov.io/gh/stratum-mining/stratum/tree/main/protocols%2Fv2%2Fmining_sv2)

`mining_sv2` is a Rust `#![no_std]` crate that implements a set of  messages defined in the Mining protocol of Stratum V2.
The Mining protocol enables:
- distribution of work to mining devices
- submission of proof of work from mining devices
- notification of custom work to pool (in conjunction with Job Declaration Subprotocol) 

For further information about the messages, please refer to [Stratum V2 documentation - Mining](https://stratumprotocol.org/specification/05-Mining-Protocol/).

## Usage

To include this crate in your project, run:

```bash
$ cargo add mining_sv2
```
