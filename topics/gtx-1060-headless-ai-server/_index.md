---
title: "GTX 1060 6GB Headless AI Server (Ubuntu 22.04)"
type: topic
created: 2026-05-21
updated: 2026-06-01
status: active
---

# GTX 1060 6GB Headless AI Server — Ubuntu 22.04 LTS

## Driving Case

Repurpose an MSI GS63VR laptop (Pascal GTX 1060 6GB mobile, i7-7700HQ/6700HQ, 16GB RAM) as a headless Ubuntu 22.04 LTS box reachable over SSH on the LAN. Two workloads:

1. **Audio**: ffmpeg + faster-whisper or WhisperX + pyannote.audio for transcription with speaker diarization.
2. **Vision**: open-source models for farm-related tasks (herd counting, livestock detection, aerial/CCTV imagery).

Hardware constraint: Pascal sm_61, 6GB VRAM, ~10 TFLOPS FP32, no native FP16/INT8 acceleration → driver, CUDA, and model-size choices must respect compute capability 6.1.

## Sub-questions (research paths)

1. Headless Ubuntu 22.04 install + SSH-over-LAN baseline for an MSI laptop (Optimus, lid-close, fan, BIOS quirks)
2. Latest open-source NVIDIA driver path for Pascal on 22.04 (open kernel modules vs proprietary, 535 vs 550 vs 570; CUDA 11.x vs 12.x trade-off)
3. faster-whisper on GTX 1060 6GB — int8/float16 picks, ctranslate2 build, RTF benchmarks, model-size ceiling
4. WhisperX vs faster-whisper + pyannote.audio integration — alignment, diarization, HF token, version pinning
5. pyannote.audio 3.x on Pascal — model compat, speaker-diarization-3.1 GPU memory, known issues
6. Vision models for herd/livestock counting on 6GB VRAM — YOLOv8/v11, RT-DETR, SAM, density-estimation, drone-imagery datasets
7. Headless GPU benchmark + smoke-test suite (nvidia-smi, gpu-burn, faster-whisper bench, YOLO bench, MLPerf-tiny)
8. Operational concerns — thermals, power capping, persistence-mode, systemd services, log rotation, remote model loading

## Theses

(none yet)

## Topic Articles (synthesis)

- [gtx-1060-headless-ai-server-synthesis](wiki/topics/gtx-1060-headless-ai-server-synthesis.md) — actionable single-page summary
- [iroh-application-patterns-2026-synthesis](wiki/topics/iroh-application-patterns-2026-synthesis.md) — five Iroh-native patterns: multi-ALPN, MoQ, iroh-blobs, iroh-ssh, QR pairing

## Concept Articles

### Hardware / AI stack
- [pascal-driver-cuda-pinning](wiki/concepts/pascal-driver-cuda-pinning.md)
- [ctranslate2-quantization-on-pascal](wiki/concepts/ctranslate2-quantization-on-pascal.md)
- [faster-whisper-on-gtx-1060](wiki/concepts/faster-whisper-on-gtx-1060.md)
- [whisperx-vs-manual-pyannote-integration](wiki/concepts/whisperx-vs-manual-pyannote-integration.md)
- [whisperx-known-broken-installs](wiki/concepts/whisperx-known-broken-installs.md)
- [pyannote-audio-3.x-on-pascal](wiki/concepts/pyannote-audio-3.x-on-pascal.md)
- [farm-vision-on-gtx-1060](wiki/concepts/farm-vision-on-gtx-1060.md)
- [headless-ubuntu-laptop-baseline](wiki/concepts/headless-ubuntu-laptop-baseline.md)
- [gpu-bench-and-smoke-tests](wiki/concepts/gpu-bench-and-smoke-tests.md)
- [gpu-thermals-and-ops](wiki/concepts/gpu-thermals-and-ops.md)

### Iroh application patterns 2026 (added 2026-06-01)
- [multi-alpn-router-pattern](wiki/concepts/multi-alpn-router-pattern.md)
- [moq-over-iroh-pattern](wiki/concepts/moq-over-iroh-pattern.md)
- [iroh-blobs-resumable-uploads](wiki/concepts/iroh-blobs-resumable-uploads.md)
- [iroh-as-ssh-transport](wiki/concepts/iroh-as-ssh-transport.md)
- [iroh-tickets-and-qr-pairing](wiki/concepts/iroh-tickets-and-qr-pairing.md)

### Iroh app token wrapper — Rust implementation (added 2026-06-01, R3)
- [iroh-app-token-design](wiki/concepts/iroh-app-token-design.md) — token format choice + Rust crate matrix
- [iroh-app-token-seed-rotation](wiki/concepts/iroh-app-token-seed-rotation.md) — Wesh-style revocation algorithm
- [iroh-app-token-integration](wiki/concepts/iroh-app-token-integration.md) — AccessLimit + auth-hook + AppTicket bech32

## Sources

- [raw/_index.md](raw/_index.md) — 92 sources

## Output

- [output/playbook-gtx-1060-headless-ai-server-2026-05-21.md](output/playbook-gtx-1060-headless-ai-server-2026-05-21.md) — end-to-end setup runbook
- [output/plan-gs63vr-headless-server-2026-05-21.md](output/plan-gs63vr-headless-server-2026-05-21.md) — implementation plan (parallel-track roadmap, Iroh p2p, Android v1 / iOS v2)
- [output/assess-herd-scout-2026-06-01.md](output/assess-herd-scout-2026-06-01.md) — repo↔wiki↔market gap analysis for the herd-scout livestock-CV product
- [output/design-iroh-app-token-wrapper-2026-06-01.md](output/design-iroh-app-token-wrapper-2026-06-01.md) — design doc for `iroh-app-token` Rust crate (filling the empty crates.io slot)

## Stats

- Articles: 20 (2 topic syntheses + 18 concept)
- Sources ingested: 92 (43 articles, 28 repos, 18 papers, 2 guides, 1 data)
- Playbooks: 1
- Plans: 1
- Designs: 1 (iroh-app-token wrapper)
- Research dates:
  - 2026-05-21 (Round 1, 8-agent --deep, question mode) — 30 sources, 11 articles
  - 2026-05-21 (plan + 2-probe gap research)
  - 2026-06-01 (Round 2, 8-agent --deep, "Iroh application patterns 2026") — 36 sources, 6 articles
  - **2026-06-01 (Round 3, 5-agent standard, "iroh app token wrapper Rust impl") — 26 sources, 3 concept articles + 1 design doc**

## Logs

- [log.md](log.md)
