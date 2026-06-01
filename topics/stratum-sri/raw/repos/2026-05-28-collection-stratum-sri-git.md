---
title: "Collection: stratum-sri (git)"
source: "https://github.com/stratum-mining/stratum"
type: repos
ingested: 2026-05-28
tags: [collection, collection-manifest, git, sri, stratum-v2, sv2, rust]
summary: "Manifest for a collection ingest of stratum-mining/stratum at HEAD 65c9688c on main: 26 text-like child sources captured (root docs + per-crate READMEs/BENCHES across sv1, sv2/*, stratum-core, fuzz)."
collection: "stratum-sri"
adapter: git
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
canonical_url: "https://github.com/stratum-mining/stratum/tree/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
license: "Apache-2.0 OR MIT"
---

# Collection: stratum-sri (git)

Bounded git collection ingest of `stratum-mining/stratum` at HEAD commit `65c9688ca0e9cdcf213b32a6f51e9309fb75bbab` on `main`, taken from the local checkout at `/Users/garykrause/repos/stratum`.

## Scope

Included file extensions: `.md`, `.mediawiki`, `.wiki`, `.rst`, `.txt`, `.adoc`.

Excluded by default: `.git/`, `.github/`, generated assets, binaries, images, archives, vendored deps, scripts, test vectors. Local-only directories without HEAD content (`sv2_test_client/`, `roles/storage/`, `protocols/`) contributed nothing at this revision.

## Inventory (26 files, HEAD blob SHAs)

| upstream_id | blob sha |
|---|---|
| README.md | 14861222bf2c6f6855289743e7c3811a496521e9 |
| RELEASE.md | 1d84b0ad7cc41e90f0e24271fda74ac0a2ffb80b |
| CONTRIBUTING.md | c607dad687fcaf3aa7da6791f8004037a9fd6638 |
| SECURITY.md | a3497a26c698b0e88cd2969213c7052d28307cb4 |
| LICENSE.md | c3f44cabda20f1754eadb77366dfc0d5e1454ea9 |
| stratum-core/README.md | 300ff0a30cc34b3b7145eed6f2479740f9fd3c7b |
| sv1/README.md | f090b0d53c6e9878b7bf77f1a1f2910482d0d100 |
| sv2/binary-sv2/README.md | 58e67914056889156955bfda9a262e8c707be0c1 |
| sv2/binary-sv2/derive_codec/README.md | 7ed3d2a14cab5efbfbc10bbc2edae08c556066db |
| sv2/buffer-sv2/README.md | a47b30fda2ad01ab8c28b524093872004713527d |
| sv2/buffer-sv2/BENCHES.md | 099d2cb8ebf341749697a7af86fe48734fb57c60 |
| sv2/codec-sv2/README.md | 438f14ca24d9eb3605a5b3a318b15c7330c1dbcc |
| sv2/codec-sv2/BENCHES.md | 31067374685f6ad761087e8082bf9aeab4fb0177 |
| sv2/extensions-sv2/README.md | 3568c3b9e9428b5da4d60ba75c5afd7243c90710 |
| sv2/framing-sv2/README.md | 3c922585c2ce7691339aca23512b4f81323b0fa7 |
| sv2/framing-sv2/BENCHES.md | 569db4ddf5cdc1ea146318aa2f44789fe35c8449 |
| sv2/handlers-sv2/README.md | df12d860d98cb72dd3348a76620eac3a923878f3 |
| sv2/noise-sv2/README.md | e796c0688e9407b4081ad087fe806d8a7e41aa60 |
| sv2/noise-sv2/BENCHES.md | db8d28b6e6cdc3151646583d7dd3e927de1f5eb1 |
| sv2/parsers-sv2/README.md | b23206baccdd37dd71661fc53a6be304b647796c |
| sv2/channels-sv2/README.md | e4aa86fe5c5796fb0bda9e4213c5e74c00ff0d6a |
| sv2/subprotocols/common-messages/README.md | c31c0ca999460dc2696d5d4745767dd892b59459 |
| sv2/subprotocols/job-declaration/README.md | 55dfdeca728219469098b730a11a34be61c1a9b7 |
| sv2/subprotocols/mining/README.md | 008facedc29103a31bc8e6f3019d23101ffa5718 |
| sv2/subprotocols/template-distribution/README.md | 22d4d7c4f5cd261ddda987d90c1dc27ec1eab7ec |
| fuzz/README.md | bbdb917e8d3f5467d1424555fbec1db2b0534d8a |

## Provenance & dedup

Dedup key: `collection: stratum-sri` + `upstream_id: <repo-relative path>` + `sha: <blob sha>`. If an upstream file changes in a later ingest, a new immutable raw source is written; old ones are not overwritten.

## Companion source

A repo-level metadata snapshot lives at [`raw/repos/2026-05-28-stratum-sri.md`](2026-05-28-stratum-sri.md). It captures workspace layout, MSRV, license, recent commit themes, and remote topology — facts that don't live in any single file in the tree.
