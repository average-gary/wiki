---
title: "tus.io Resumable Upload Protocol v1.0.0"
source: https://tus.io/protocols/resumable-upload
type: article
tags: [tus, resumable-upload, http, contrast-pattern]
date: 2026-06-01
quality: 5
confidence: high
agent: 7
summary: "State encoding is server-side, header-based: Upload-Offset, Upload-Length, Tus-Resumable, optional base64 Upload-Metadata. Resume protocol: HEAD to discover offset, then PATCH the rest. Mismatched offsets → 409 Conflict. Optional Upload-Checksum extension does per-PATCH integrity check (not whole-file), with 204/460/400 status codes. Pattern: server is the source of truth for offset; client never assumes; checksum is per-chunk, not per-file."
---

# tus.io — the centralized HTTP foil to BLAKE3-Bao

Direct contrast to verified-streaming. Useful when arguing why content-addressing makes offset bookkeeping unnecessary.

## How tus encodes state

| Header           | Role |
|------------------|------|
| `Upload-Offset`  | Server tells client: "I have N bytes" |
| `Upload-Length`  | Total expected size |
| `Tus-Resumable`  | Protocol version |
| `Upload-Metadata`| Optional base64 metadata (filename, etc.) |

## Resume flow

```
HEAD /uploads/abc → 200 with Upload-Offset: 1234567
PATCH /uploads/abc with Upload-Offset: 1234567 → server appends N more bytes
```

Mismatched offsets return **409 Conflict** — no silent re-upload.

## Optional integrity

`Upload-Checksum` extension does **per-PATCH** integrity check (not whole-file):
- 204 No Content — chunk verified, appended
- 460 Checksum Mismatch — drop the chunk
- 400 Bad Request — malformed

→ Client must track which chunks landed; whole-file integrity not guaranteed by the protocol.

## Why this is the foil to iroh-blobs / Bao

| Property | tus | iroh-blobs / Bao |
|----------|-----|-----------------|
| Source of truth for state | Server-side offset | Content hash |
| Resume protocol | "What offset are you at?" | "What hashes do you have?" |
| Whole-file integrity | Optional, end-of-stream | Mandatory, per-chunk against root |
| Upload identity | URL (assigned by server) | Hash (computed from content) |
| Multi-receiver | Re-upload to each | One root → many fetchers |
| Crash mid-upload | Server retains partial; client must remember offset | Receiver retains partial; resumes by hash diff |
| Checksum algorithm | SHA-1 / SHA-256 / MD5 (declared) | BLAKE3 (forced; see Bao) |

## Implication for iroh-app design

For an Iroh AI server pushing ML model weights to clients:

- **tus pattern**: client uploads, server tracks offset. If many clients push, server is the bottleneck. Resume requires server retaining partial state.
- **iroh-blobs pattern**: server *advertises* a content hash; clients fetch by hash. Multiple clients can fetch the same blob from each other (gossip). Resume is automatic — the receiver sees what hashes it has, requests the missing slice.

For one-shot upload from a phone to the server (e.g., upload a video for transcription), tus-style is simpler. For many-many distribution (model weights, datasets) iroh-blobs wins.

## See also

- [[2026-06-01-bittorrent-v2-bep-52]] — same shape as iroh-blobs but SHA-256
- [[2026-06-01-blake3-specs-bao]]
