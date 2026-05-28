---
title: "BitTorrent v2 — Merkle Hash Trees and Per-File Hashes"
source_url: "https://blog.libtorrent.org/2020/09/bittorrent-v2/"
type: article
path: infra-text
date_ingested: 2026-05-27
date_published: 2020-09-07
tags: [decentralized, bittorrent, content-distribution, content-addressing]
quality: 4
confidence: high
summary: "BitTorrent v2 (BEP 52) replaces SHA-1 piece hashes with per-file SHA-256 Merkle trees. Mature swarms, but browser story is still WebTorrent (no v2) and adoption remains thin five years on."
---

# BitTorrent v2 — Merkle Hash Trees and Per-File Hashes

## Key findings

- **SHA-1 → SHA-256 + Merkle trees**. Each file gets its own Merkle root with 16 KiB leaf blocks. This means corrupt blocks cost only 16 KiB to re-fetch, not a whole piece, and identical files dedupe across torrents because they share the file root hash.
- **Magnet links are smaller** because piece hashes don't need to be embedded — only the root. Lower startup latency for large torrents, which matters if a Bible/lexicon "torrent" is a few GB across hundreds of files.
- **Hybrid v1+v2 torrents** are supported, so legacy clients still work. This is the only reason v2 isn't dead.
- **Browser reality (the gap this source omits)**: WebTorrent only speaks BTv1 over WebRTC. There is no production WebTorrent-v2 client, and browsers cannot do raw TCP/UTP swarms. So for a browser-first Bible reader, BTv2's improvements don't reach the consumer.
- **Adoption is thin**: as of 2024–2025, most public trackers and indexers still issue v1 torrents. The crypto property gain is real but the network effect didn't materialize.

## Notable quotes / specifics

- "If a peer sends corrupt data, it can be discovered immediately and only 16 kiB need to be re-downloaded."
- Per-file Merkle roots enable identification of identical files across different swarms without rehashing — the analog of CID-level dedupe in IPFS, but without the chunker incompatibility problem.

## Source notes

Foundational reference for BTv2. The honest take for the Logos suite use case: BTv2 is a strictly better content-addressing protocol than v1, but its real-world deployment is dominated by piracy swarms and its browser support is non-existent. Iroh-blobs gives you the same Merkle-tree property with QUIC + a Rust SDK that you can actually embed in a desktop/mobile app. Treat BTv2 as a "fallback distribution channel for power users" rather than a primary transport.
