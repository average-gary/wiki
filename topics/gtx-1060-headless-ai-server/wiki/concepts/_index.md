---
title: "Concepts"
type: index
updated: 2026-06-01
---

# Concept Articles (15)

## Driver / CUDA / runtime
- [[pascal-driver-cuda-pinning]] — proprietary NVIDIA driver + CUDA 12.x ceiling
- [[ctranslate2-quantization-on-pascal]] — fp16 silently demotes to fp32; pick int8

## Audio stack
- [[faster-whisper-on-gtx-1060]] — model VRAM matrix, RTFx, version pins
- [[whisperx-vs-manual-pyannote-integration]] — pick WhisperX
- [[whisperx-known-broken-installs]] — issues #1412 / #1406
- [[pyannote-audio-3.x-on-pascal]] — gated-model workflow + DER table

## Vision stack
- [[farm-vision-on-gtx-1060]] — YOLO11 + supervision for herd counting

## Ubuntu baseline + ops
- [[headless-ubuntu-laptop-baseline]] — Ubuntu Server 22.04 + SSH on GS63VR
- [[gpu-bench-and-smoke-tests]] — 5-layer verification stack
- [[gpu-thermals-and-ops]] — 24/7 ops (msi-ec unimplemented finding)

## Iroh application patterns 2026 (added 2026-06-01)
- [[multi-alpn-router-pattern]] — one Endpoint, many ALPNs, AccessLimit allowlist
- [[moq-over-iroh-pattern]] — moq-lite + moq-relay over iroh transport (default-on feature)
- [[iroh-blobs-resumable-uploads]] — BLAKE3 verified streaming, content-addressed, multi-receiver
- [[iroh-as-ssh-transport]] — ProxyCommand + AccessLimit allowlist hardening
- [[iroh-tickets-and-qr-pairing]] — Tailscale invite + Wesh seed-rotation + Noise IK semantics

## Iroh app token wrapper — Rust implementation (added 2026-06-01, R2)
- [[iroh-app-token-design]] — token format choice (random+redb default; PASETO upgrade path; Biscuit for attenuation; not JWT)
- [[iroh-app-token-seed-rotation]] — BLAKE3 keyed_hash + week-bucket; family-revocation on stale-tag detection
- [[iroh-app-token-integration]] — AccessLimit + auth-hook + file-based allowlist; AppTicket bech32 format
