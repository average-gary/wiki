---
title: "job_declaration_sv2 (sv2/subprotocols/job-declaration/README.md)"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/job-declaration/README.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, subprotocols, subprotocol-job-declaration]
summary: "`job_declaration_sv2` is a Rust `#![no-std]` crate that contains the messages defined in the Job Declaration Protocol of Stratum V2. This protocol runs between the Job Declarator Server(JDS) and Job Declarator Client(JDC). and can be provided as a trusted 3rd party service for mining farms."
collection: "stratum-sri"
adapter: git
upstream_id: "sv2/subprotocols/job-declaration/README.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "55dfdeca728219469098b730a11a34be61c1a9b7"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/sv2/subprotocols/job-declaration/README.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

# job_declaration_sv2

[![crates.io](https://img.shields.io/crates/v/job_declaration_sv2.svg)](https://crates.io/crates/job_declaration_sv2)
[![docs.rs](https://docs.rs/job_declaration_sv2/badge.svg)](https://docs.rs/job_declaration_sv2)
[![rustc+](https://img.shields.io/badge/rustc-1.75.0%2B-lightgrey.svg)](https://blog.rust-lang.org/2023/12/28/Rust-1.75.0.html)
[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/stratum-mining/stratum/blob/main/LICENSE.md)
[![codecov](https://codecov.io/gh/stratum-mining/stratum/branch/main/graph/badge.svg)](https://app.codecov.io/gh/stratum-mining/stratum/tree/main/protocols%2Fv2%2Fjob_declaration_sv2)

`job_declaration_sv2` is a Rust `#![no-std]` crate that contains the messages defined in the Job Declaration Protocol of Stratum V2.
This protocol runs between the Job Declarator Server(JDS) and Job Declarator Client(JDC). and can be
provided as a trusted 3rd party service for mining farms.

For further information about the messages, please refer to [Stratum V2 documentation - Job Distribution](https://stratumprotocol.org/specification/06-Job-Declaration-Protocol/).

## Usage

To include this crate in your project, run:

```bash
$ cargo add job_declaration_sv2
```
