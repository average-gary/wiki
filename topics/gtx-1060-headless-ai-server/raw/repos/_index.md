---
title: "Repos"
type: index
updated: 2026-06-01
---

# Repos (28)

## Drivers
- [2026-05-21-nvidia-open-gpu-kernel-modules](2026-05-21-nvidia-open-gpu-kernel-modules.md) — Pascal NOT supported

## Audio stack
- [2026-05-21-faster-whisper](2026-05-21-faster-whisper.md) — install + VRAM benchmarks
- [2026-05-21-whisperx](2026-05-21-whisperx.md) — VAD + alignment + diarization wrapper
- [2026-05-21-pyannote-audio](2026-05-21-pyannote-audio.md) — 4.0.4 + community-1
- [2026-05-21-whisper-diarization](2026-05-21-whisper-diarization.md) — NeMo alternative (no HF gating)

## Vision
- [2026-05-21-supervision](2026-05-21-supervision.md) — counting glue (MIT)

## Hardware-specific
- [2026-05-21-msi-gs63vr-config](2026-05-21-msi-gs63vr-config.md) — model-specific Linux notes
- [2026-05-21-msi-ec-gs63vr-unimplemented](2026-05-21-msi-ec-gs63vr-unimplemented.md) — CRITICAL: GS63VR is unimplemented
- [2026-05-21-nbfc-linux](2026-05-21-nbfc-linux.md) — fan control fallback
- [2026-05-21-throttled](2026-05-21-throttled.md) — i7-7700HQ undervolt + PL1/PL2

## Benchmarking + monitoring
- [2026-05-21-gpu-burn](2026-05-21-gpu-burn.md) — `make COMPUTE=6.1` for Pascal
- [2026-05-21-dcgm-exporter](2026-05-21-dcgm-exporter.md) — Prometheus GPU metrics

## Iroh application patterns — Rust crates and binaries (added 2026-06-01)

### MoQ stack
- [2026-06-01-moq-dev-moq-monorepo](2026-06-01-moq-dev-moq-monorepo.md) — canonical Rust MoQ workspace (moved from kixelated/moq-rs)
- [2026-06-01-moq-relay-cargo-features](2026-06-01-moq-relay-cargo-features.md) — `iroh` feature is **default-on** in moq-relay 0.12.5
- [2026-06-01-moq-net-crate](2026-06-01-moq-net-crate.md) — protocol/session layer; transport-agnostic via web-transport-trait

### Iroh core
- [2026-06-01-iroh-router-protocolhandler-docs](2026-06-01-iroh-router-protocolhandler-docs.md) — multi-ALPN Router + AccessLimit allowlist primitive
- [2026-06-01-iroh-examples-custom-router](2026-06-01-iroh-examples-custom-router.md) — canonical multi-ALPN example
- [2026-06-01-iroh-blobs-1-0-rc](2026-06-01-iroh-blobs-1-0-rc.md) — iroh-blobs 0.102.0 pinned to iroh 1.0.0-rc.1

### Iroh as SSH transport
- [2026-06-01-dumbpipe-binary](2026-06-01-dumbpipe-binary.md) — netcat-over-iroh; ALPN `DUMBPIPEV0`
- [2026-06-01-iroh-ssh-rustonbsd](2026-06-01-iroh-ssh-rustonbsd.md) — community SSH-over-iroh; missing allowlist

### Ecosystem
- [2026-06-01-awesome-iroh](2026-06-01-awesome-iroh.md) — curated list of shipping iroh apps

## App token wrapper — Rust crates and iroh PRs (added 2026-06-01, R2)
- [2026-06-01-iroh-pr-3157-accesslimit](2026-06-01-iroh-pr-3157-accesslimit.md) — **MERGED** PR introducing AccessLimit (correction!)
- [2026-06-01-iroh-pr-4205-relay-auth-tokens](2026-06-01-iroh-pr-4205-relay-auth-tokens.md) — relay-tier bearer-token auth
- [2026-06-01-iroh-auth-hook-example](2026-06-01-iroh-auth-hook-example.md) — canonical token-handshake pattern (auth-hook.rs)
- [2026-06-01-biscuit-auth-rust-crate](2026-06-01-biscuit-auth-rust-crate.md) — biscuit-auth 6.0.0 (Rust impl)
- [2026-06-01-rusty-paseto-crate](2026-06-01-rusty-paseto-crate.md) — rusty-paseto 0.10
- [2026-06-01-blake3-keyed-hash-rust](2026-06-01-blake3-keyed-hash-rust.md) — keyed_hash + derive_key for seed rotation
- [2026-06-01-redb-sled-token-persistence](2026-06-01-redb-sled-token-persistence.md) — embedded KV for consumed-set
