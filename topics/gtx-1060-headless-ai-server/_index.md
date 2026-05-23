---
title: "GTX 1060 6GB Headless AI Server (Ubuntu 22.04)"
type: topic
created: 2026-05-21
updated: 2026-05-21
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

## Concept Articles

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

## Sources

- [raw/_index.md](raw/_index.md) — 30 sources

## Output

- [output/playbook-gtx-1060-headless-ai-server-2026-05-21.md](output/playbook-gtx-1060-headless-ai-server-2026-05-21.md) — end-to-end setup runbook
- [output/plan-gs63vr-headless-server-2026-05-21.md](output/plan-gs63vr-headless-server-2026-05-21.md) — implementation plan (parallel-track roadmap, Iroh p2p, Android v1 / iOS v2)

## Stats

- Articles: 11 (1 topic synthesis + 10 concept)
- Sources ingested: 30 (13 articles, 12 repos, 2 papers, 2 guides, 1 data)
- Playbooks: 1
- Plans: 1 (roadmap, parallel-track Iroh-everywhere; iOS deferred to v2)
- Research dates: 2026-05-21 (Round 1, 8-agent --deep, question mode); 2026-05-21 (plan + 2-probe gap research)

## Logs

- [log.md](log.md)
