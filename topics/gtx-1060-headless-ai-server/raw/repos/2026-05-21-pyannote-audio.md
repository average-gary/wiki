---
title: "pyannote/pyannote-audio — README + 4.x roadmap"
source: https://github.com/pyannote/pyannote-audio
type: repo
tags: [pyannote, diarization, version-comparison, community-1, vbx]
date: 2026-05-21
quality: 5
confidence: high
agent: 5
summary: "4.0.0 released Sept 2024, 4.0.4 latest patch Feb 2026. Default pipeline is now speaker-diarization-community-1 (VBx clustering). Updated DER table: AMI IHM 18.8 (3.1) → 17.0 (community-1) → 12.9 (precision-2 paid)."
---

# pyannote-audio — current state (2026)

## Install

```bash
uv add pyannote.audio   # recommended
# or
pip install pyannote.audio
```

Requires `ffmpeg` system-wide (used by `torchcodec` decoding backend in 4.x). Built on PyTorch + pytorch-lightning.

## Updated DER table (Sept 2025)

| Dataset | Legacy 3.1 | community-1 (4.x default) | precision-2 (paid) |
|---------|------------|---------------------------|--------------------|
| AISHELL-4 | 12.2 | 11.7 | 11.4 |
| AliMeeting (ch.1) | 24.5 | 20.3 | 15.2 |
| AMI (IHM) | 18.8 | **17.0** | 12.9 |
| DIHARD 3 | 21.4 | 20.2 | 14.7 |
| VoxConverse v0.3 | 11.2 | 11.2 | 8.5 |

## Speed (NVIDIA H100 80GB, self-hosted)

- community-1: 31–37 s per hour of audio
- precision-2: 14 s per hour of audio (2.2–2.6× faster, paid)

## 4.0.0 (Sept 29, 2024) — major changes

- New default pipeline: `speaker-diarization-community-1`
- **VBx clustering** replaces agglomerative hierarchical
- "Exclusive" speaker diarization output (no overlap between speaker turns) — useful for Whisper word-level reconciliation
- K-means clustering option, PixIT speech separation
- Backend swap: `sox`/`soundfile` → `ffmpeg`/`torchcodec`
- Drops Python <3.10
- 15× faster training (metadata caching, optimized loaders)
- Speaker counting on DIHARD: 61% → 75%; ~50% reduction in speaker confusion
- Offline usage + telemetry
- Latest patch **4.0.4** (Feb 7, 2026)

## community-1 model

- Compatible with pyannote-audio 4.x (uses `token=` kwarg, NOT `use_auth_token=`)
- License: **CC-BY-4.0** (3.1 was MIT)
- Must accept user conditions at https://huggingface.co/pyannote/speaker-diarization-community-1

## Pinned-version recommendation for GTX 1060 stack (2026)

If WhisperX 3.8.5 issue #1406 bites you (use_auth_token vs token kwarg mismatch on pyannote 4.x), downgrade pyannote to 3.1:

```bash
pip install "pyannote.audio>=3.1,<3.3" --no-deps
pip install pytorch-lightning asteroid-filterbanks einops omegaconf
```

Otherwise prefer pyannote 4.x + community-1 for the better DER and license clarity.
