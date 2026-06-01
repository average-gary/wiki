---
title: "BitTorrent v2 — BEP 52 (Per-File Merkle Trees)"
source: https://www.bittorrent.org/beps/bep_0052.html
type: paper
tags: [bittorrent, bep-52, merkle, sha-256, resumable, content-addressed]
date: 2026-06-01
quality: 5
confidence: high
agent: 7
summary: "Per-file SHA-256 Merkle tree over 16 KiB blocks, branching factor 2 → any block independently verifiable. New peer-wire messages `hash request` / `hashes` for on-demand subtree fetch — peers don't have to ship the whole hash list up front. Resume is implicit: identical content → identical root, partial state on disk is self-validating. Infohash = hash of bencoded info dict; spec requires byte-exact handling."
---

# BitTorrent v2 — direct precedent for verified-streaming resumable transfer

Same shape as BLAKE3/Bao but with SHA-256 and a different chunk size. Useful reference for the pattern.

## Tree shape

- **16 KiB blocks** (matches `IROH_BLOCK_SIZE` constant in iroh-blobs)
- Per-file Merkle tree (not per-torrent — files within a torrent are independently verifiable)
- Branching factor 2; SHA-256 at every node
- Root hash is the file's identity; root + length = `info.files[i]`

## On-demand hash fetch

New wire messages:

- `hash request` — ask peer for a specific subtree
- `hashes` — response carrying just the requested nodes

Peers don't ship the entire hash list up front (unlike BitTorrent v1 piece-hash list). Lazy verification scales to multi-TB torrents.

## Resume = "send me what I'm missing"

- No offset bookkeeping (compare to [[2026-06-01-tus-resumable-upload-protocol]])
- Partial state on disk is self-validating against the root
- Identical content → identical root → swap-friendly

## Patterns inherited by iroh-blobs

| BEP 52              | iroh-blobs / Bao   |
|---------------------|--------------------|
| SHA-256 Merkle      | BLAKE3 chunked tree |
| 16 KiB blocks       | 16 KiB `IROH_BLOCK_SIZE` |
| `hash request`/`hashes` on demand | Bao slice format omits nodes off the path |
| Infohash = root + length | `Hash` (32 bytes) is the address |

## Why this matters for an Iroh AI server

When uploading model weights or training data: **content addressing eliminates offset negotiation.** A crashed upload resumes by asking the receiver "what hashes do you have?" rather than "what byte offset are you at?" — the iroh-blobs `Downloader` does this natively.

See also: [[2026-06-01-blake3-specs-bao]], [[2026-06-01-tus-resumable-upload-protocol]].
