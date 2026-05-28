---
title: "Iroh Blobs Protocol — BLAKE3 Verified Streaming and Collections"
source_url: "https://docs.iroh.computer/protocols/blobs"
type: article
path: infra-text
date_ingested: 2026-05-27
date_published: unknown
tags: [decentralized, iroh, content-distribution, blake3, content-addressing]
quality: 5
confidence: high
summary: "Iroh's blob protocol uses BLAKE3 verified streaming over QUIC with a 'collection' concept (HashSeq) for grouping blobs. Strong fit for shipping read-only text corpora; ergonomics dramatically better than IPFS Bitswap."
---

# Iroh Blobs Protocol — BLAKE3 Verified Streaming and Collections

## Key findings

- **Verified streaming during transfer**, not after. BLAKE3's tree hash means each chunk is verifiable as it arrives; corruption is caught at the chunk boundary, not at the end. This is the same property BitTorrent v2 gives you, but Iroh runs over QUIC streams with a much simpler request/response API.
- **Collections = HashSeq**: an ordered sequence of 32-byte BLAKE3 hashes inside a blob. By convention, the first element is a metadata blob describing the rest. This is the natural unit to ship a Bible package: one HashSeq containing {ESV.usfx, BHS.osis, LSJ.json, BDAG.json, ...}.
- **Range requests are first-class** because BLAKE3 trees naturally support partial verification of byte ranges. So a client can fetch only Genesis 1 + the LSJ entry for "λόγος" without downloading the whole 2 GB collection. This is the killer feature for a lexicon-heavy reading app.
- **Default chunk size is 1 KiB** with ~6% Merkle-tree overhead. Tunable without changing the root hash, which is a meaningful fix for the IPFS chunker-incompatibility problem.
- **No graph-of-graphs**: collections cannot be nested-as-graphs. Fine for a flat library; not an IPLD replacement.

## Notable quotes / specifics

- "The provider answers with the requested data, encoded as BLAKE3 verified streams, on the same QUIC stream."
- HashSeq is "a blob containing sequences of links (multiples of 32 bytes)" — this is the entire collection format.
- Caveat from the iroh-blobs README: "this version of iroh-blobs is not yet considered production quality. For now, if you need production quality, use iroh-blobs 0.35." Maturity is real but the API surface is still moving.

## Source notes

The hub already has a full topic wiki on `iroh-transport-stratum-v2` covering raw-public-key TLS, QUIC, relay-fallback, dumbpipe and sendme — so this article focuses only on the blob/collection layer relevant to text distribution. The model is essentially "Bittorrent v2 with BLAKE3 instead of SHA-256, QUIC instead of TCP, and a sane Rust API".
