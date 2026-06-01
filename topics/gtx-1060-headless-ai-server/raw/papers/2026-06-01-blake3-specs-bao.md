---
title: "BLAKE3 Specs + Bao verified streaming"
source: https://github.com/BLAKE3-team/BLAKE3-specs, https://github.com/oconnor663/bao
type: paper
tags: [blake3, bao, verified-streaming, hashing, merkle, iroh-blobs]
date: 2026-06-01
publication_date: 2020-01
quality: 5
confidence: high
agent: 1
summary: "BLAKE3 paper distributed as blake3.pdf (LaTeX source in repo). Chunked tree hashing with implicit 1024-byte chunks. Bao implements §6.4 verified-streaming construction: encoding interleaves file bytes with hash-tree nodes so any byte range can be verified against a 32-byte root hash without reading the whole file. Two encoding variants (combined / outboard sidecar). Domain separation between chunk and parent nodes prevents ambiguity attacks. Random-access verification — fundamentally impossible with serial SHA-256."
---

# BLAKE3 verified streaming

The cryptographic primitive that lets iroh-blobs stream blobs out-of-order over QUIC and still authenticate every chunk against a 32-byte root.

## Tree structure

- 1024-byte implicit chunks (or 16 KiB block size in iroh-blobs — see [[2026-06-01-iroh-blobs-1-0-rc]])
- Binary Merkle tree; each parent = chaining-value hash of two children
- Domain separation between chunk-node and parent-node hashing prevents ambiguity

## Bao encoding

§6.4 of the BLAKE3 spec, reference impl by Jack O'Connor (`oconnor663/bao`):

- **Combined**: pre-order interleaving — chunks + parents in a single byte stream, prefixed with 8-byte little-endian length
- **Outboard**: parents-only sidecar; chunks read from original file
- **Slice**: omits nodes not on the path to the requested range — minimal proof for range fetch

Decoder validates final chunk before exposing length, defeating length-manipulation attacks.

## Performance

Single-threaded throughput on AWS c5.metal (Cascade Lake-SP, AVX-512), 16 KiB input:

| Hash         | MiB/s |
|--------------|------:|
| **BLAKE3**   | 6,866 |
| BLAKE2b      | 1,312 |
| SHA-1        | 1,027 |
| SHA-256      |   484 |
| SHA3-256     |   394 |

→ ~14.2× faster than SHA-256 with AVX-512.

**Caveat (cf. BLAKE3 issue #315):** on M2 Max single-thread, BLAKE3 ran ~37% *slower* than OpenSSL's hardware-accelerated SHA-256 (2.58s vs 1.71s on a 4 GB file). Pre-AVX2 hosts get the SSE4.1 path — worst-case profile. **Pascal-era hosts (i7-7700HQ has AVX2 but not AVX-512) likely see ~3–4 GiB/s single-thread BLAKE3** by cpb extrapolation.

## Iroh relevance

iroh-blobs builds its request-response protocol directly on Bao's verified-streaming construction. The 0.90 (2025-07-08) ground-up rewrite reuses Bao's chunk-group encoding while restructuring the wire protocol. `bao-tree = "0.16"` is the engine.

Bao note: "Bao is beta cryptography software. It has not been formally audited."

See also: [[2026-06-01-bittorrent-v2-bep-52]] (parallel design), [[2026-06-01-iroh-blobs-1-0-rc]].
