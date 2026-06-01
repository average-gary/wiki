---
title: "template_distribution_sv2 (sv2/subprotocols/template-distribution/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/template-distribution/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, subprotocols, subprotocol-template-distribution]
summary: "`template_distribution_sv2` is a Rust `#![no_std]` crate that implements a set of messages defined in the Template Distribution Protocol of Stratum V2. The Template Distribution protocol can be used to receive updates of the block templates to use in mining."
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/subprotocols/template-distribution/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "22d4d7c4f5cd261ddda987d90c1dc27ec1eab7ec"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/template-distribution/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# template_distribution_sv2

[![crates.io](https://img.shields.io/crates/v/template_distribution_sv2.svg)](https://crates.io/crates/template_distribution_sv2)
[![docs.rs](https://docs.rs/template_distribution_sv2/badge.svg)](https://docs.rs/template_distribution_sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)
[![codecov](https://codecov.io/gh/stratum-mining/stratum/branch/main/graph/badge.svg)](https://app.codecov.io/gh/stratum-mining/stratum/tree/main/protocols%2Fv2%2Ftemplate_distribution_sv2)

`template_distribution_sv2` is a Rust `#![no_std]` crate that implements a set of messages defined in the
Template Distribution Protocol of Stratum V2. The Template Distribution protocol can be used to
receive updates of the block templates to use in mining.

For further information about the messages, please refer to [Stratum V2 documentation - Job Distribution](https://stratumprotocol.org/specification/07-Template-Distribution-Protocol/).

## Build Options

This crate can be built with the following features:
- `prop_test`: Enables support for property testing.

## Usage

To include this crate in your project, run:

```bash
$ cargo add template_distribution_sv2
```
