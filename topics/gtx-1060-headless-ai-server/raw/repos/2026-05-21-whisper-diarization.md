---
title: "MahmoudAshraf97/whisper-diarization — alternative to WhisperX (NeMo backend)"
source: https://github.com/MahmoudAshraf97/whisper-diarization
type: repo
tags: [whisper, diarization, nemo, msdd, alternative, no-hf-gating]
date: 2026-05-21
quality: 4
confidence: medium
agent: 4
summary: "Uses NVIDIA NeMo (MarbleNet VAD + TitaNet speaker embeddings) for diarization instead of pyannote. No HuggingFace gated models — easier install. But >=10GB VRAM recommended for parallel mode; sequential mode required on 6GB."
---

# whisper-diarization (NeMo-based)

## Differences vs WhisperX

| Aspect | WhisperX | whisper-diarization |
|--------|----------|---------------------|
| Diarization backend | pyannote (gated) | NeMo MarbleNet/TitaNet (NOT gated) |
| HF token required | YES | NO |
| Recommended VRAM | <8 GB (large-v2 fp16) | **>=10 GB** for `diarize_parallel.py` |
| Output formats | SRT, JSON, VTT, TSV | SRT only |
| Long-audio | VAD-chunked | NeMo VAD + `--batch-size 0` |

## Install

```bash
pip install cython
pip install -c constraints.txt -r requirements.txt
python diarize.py -a AUDIO_FILE
```

## When to pick this over WhisperX

- You want to **avoid HF gated models** entirely (no tokens, no acceptance forms)
- pyannote 4.x is breaking your stack (WhisperX issue #1406 bite)
- You're OK with SRT-only output

## When to AVOID on GTX 1060 6GB

- `diarize_parallel.py` recommended ≥10 GB — won't fit. Use sequential `diarize.py` only.
