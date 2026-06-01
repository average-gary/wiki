---
title: "Articles"
type: index
updated: 2026-06-01
---

# Articles (43)

## Drivers / CUDA
- [2026-05-21-nvidia-driver-535-supportedchips](2026-05-21-nvidia-driver-535-supportedchips.md) — GTX 1060 supported in 535 LTS through 580
- [2026-05-21-cuda-toolkit-pascal-removal](2026-05-21-cuda-toolkit-pascal-removal.md) — CUDA 13 dropped sm_61; pin to 12.x
- [2026-05-21-ubuntu-server-nvidia-install](2026-05-21-ubuntu-server-nvidia-install.md) — `ubuntu-drivers install --gpgpu`
- [2026-05-21-ctranslate2-quantization-pascal](2026-05-21-ctranslate2-quantization-pascal.md) — fp16 silent fallback; use int8

## Audio stack
- [2026-05-21-distil-large-v3-card](2026-05-21-distil-large-v3-card.md) — sweet-spot Whisper for 6GB
- [2026-05-21-whisperx-known-broken](2026-05-21-whisperx-known-broken.md) — issues #1412 / #1406
- [2026-05-21-pyannote-speaker-diarization-3.1](2026-05-21-pyannote-speaker-diarization-3.1.md) — DER table + HF gating

## Vision
- [2026-05-21-yolov8-yolo11-specs](2026-05-21-yolov8-yolo11-specs.md) — model specs comparison

## Linux laptop ops
- [2026-05-21-logind-conf-lid-switch](2026-05-21-logind-conf-lid-switch.md)
- [2026-05-21-netplan-static-ip](2026-05-21-netplan-static-ip.md)
- [2026-05-21-systemd-journald-config](2026-05-21-systemd-journald-config.md)
- [2026-05-21-unattended-upgrades-pin-nvidia](2026-05-21-unattended-upgrades-pin-nvidia.md)
- [2026-05-21-nvidia-smi-power-cap-persistence](2026-05-21-nvidia-smi-power-cap-persistence.md)

## Iroh application patterns — practitioner posts and case studies (added 2026-06-01)

### MoQ
- [2026-06-01-moq-cloudflare-cdn-blog](2026-06-01-moq-cloudflare-cdn-blog.md) — first MoQ CDN, Wink/MediaMTX 200-300ms latency anchor

### Iroh case studies & demos
- [2026-06-01-iroh-paycode-case-study](2026-06-01-iroh-paycode-case-study.md) — production iroh + QR pairing at toll booths
- [2026-06-01-iroh-secure-video-everywhere-blog](2026-06-01-iroh-secure-video-everywhere-blog.md) — iroh + MoQ on a Pi camera

### Iroh release/version history
- [2026-06-01-iroh-1-0-0-rc-1](2026-06-01-iroh-1-0-0-rc-1.md) — final RC, hard-NAT holepunching, AccessControl trait
- [2026-06-01-iroh-changelog-0-91-to-1-0-rc-1](2026-06-01-iroh-changelog-0-91-to-1-0-rc-1.md) — full version history
- [2026-06-01-iroh-post-quantum-handshakes](2026-06-01-iroh-post-quantum-handshakes.md) — ML-KEM-768 hybrid KEM
- [2026-06-01-iroh-blobs-0-95-features-blog](2026-06-01-iroh-blobs-0-95-features-blog.md) — ConnectionPool, abstract stream traits

### Failure modes / contrarian
- [2026-06-01-iroh-blobs-poisoned-store-issue-233](2026-06-01-iroh-blobs-poisoned-store-issue-233.md) — partial-upload + crash bricks the store
- [2026-06-01-iroh-memory-leak-issues](2026-06-01-iroh-memory-leak-issues.md) — long-running daemon footguns
- [2026-06-01-iroh-tickets-security-model](2026-06-01-iroh-tickets-security-model.md) — first-party "tickets are not auth"
- [2026-06-01-masque-connect-udp-warning](2026-06-01-masque-connect-udp-warning.md) — IETF guidance: don't tunnel QUIC reliably over QUIC

### Numbers / benchmarks
- [2026-06-01-iroh-0rtt-handshake-blog](2026-06-01-iroh-0rtt-handshake-blog.md) — handshake latency
- [2026-06-01-iroh-relay-fallback-rate](2026-06-01-iroh-relay-fallback-rate.md) — ~10% relay fallback
- [2026-06-01-blake3-bench-data](2026-06-01-blake3-bench-data.md) — 14.2x SHA-256 with AVX-512; ~3-4 GiB/s estimate on i7-7700HQ

### Adjacent patterns
- [2026-06-01-tus-resumable-upload-protocol](2026-06-01-tus-resumable-upload-protocol.md) — HTTP foil to BLAKE3-Bao
- [2026-06-01-tailscale-auth-keys](2026-06-01-tailscale-auth-keys.md) — bearer-token flag schema reference
- [2026-06-01-cloudflared-aws-ssm-proxycommand](2026-06-01-cloudflared-aws-ssm-proxycommand.md) — universal SSH ProxyCommand pattern
- [2026-06-01-wesh-berty-rendezvous](2026-06-01-wesh-berty-rendezvous.md) — time-rotated rendezvous, seed-rotation = revocation

## App token wrapper — design references (added 2026-06-01, R2)
- [2026-06-01-fly-api-tokens-survey](2026-06-01-fly-api-tokens-survey.md) — tptacek's contrarian survey; "boring random tokens"
- [2026-06-01-paragon-jwt-bad-standard](2026-06-01-paragon-jwt-bad-standard.md) — PASETO authors' rationale
- [2026-06-01-langley-no-revcheck](2026-06-01-langley-no-revcheck.md) — short-lived + reissue beats revocation lists
- [2026-06-01-iroh-docs-namespace-doctickets](2026-06-01-iroh-docs-namespace-doctickets.md) — what iroh-docs has and lacks
- [2026-06-01-fedimint-invite-code](2026-06-01-fedimint-invite-code.md) — bech32 ticket pattern (prior art)
- [2026-06-01-lnurl-auth-derivation](2026-06-01-lnurl-auth-derivation.md) — per-domain HD derivation
- [2026-06-01-bolt-12-offer-encoding](2026-06-01-bolt-12-offer-encoding.md) — transient subkeys via tweaks
- [2026-06-01-tor-onion-v3-client-auth](2026-06-01-tor-onion-v3-client-auth.md) — file-based allowlist pattern
- [2026-06-01-w3c-bitstring-status-list](2026-06-01-w3c-bitstring-status-list.md) — what proper revocation infra costs (contrast)
- [2026-06-01-bloom-filter-consumed-tokens](2026-06-01-bloom-filter-consumed-tokens.md) — filter sizing for consumed-set
- [2026-06-01-signal-sealed-sender](2026-06-01-signal-sealed-sender.md) — rotate derivation key = revoke
