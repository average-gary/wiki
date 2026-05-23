---
title: "pyannote.audio 3.x / 4.x on Pascal — VRAM, gating, DER"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-21-pyannote-speaker-diarization-3.1.md
  - raw/papers/2026-05-21-plaquet-bredin-powerset-bce.md
  - raw/repos/2026-05-21-pyannote-audio.md
---

# pyannote.audio on Pascal GTX 1060

## What pyannote/speaker-diarization-3.1 actually is

Pipeline composition ([[model card|raw/articles/2026-05-21-pyannote-speaker-diarization-3.1]]):
1. **Segmentation**: `pyannote/segmentation-3.0` — PyAnNet-style backbone, **powerset BCE**-trained ([[Plaquet & Bredin 2023|raw/papers/2026-05-21-plaquet-bredin-powerset-bce]]), 10s chunks at 16 kHz, ≤3 speakers per chunk + 2 simultaneous
2. **Embedding**: `wespeaker/wespeaker-voxceleb-resnet34-LM` — ResNet34 x-vector
3. **Clustering**: agglomerative hierarchical (3.1) → **VBx in 4.x community-1**

Pure PyTorch (3.0's onnxruntime dep was removed in 3.1). License: MIT (3.1) / CC-BY-4.0 (community-1).

## Pascal compatibility

- **No documented Pascal blockers**. Architecture is standard PyTorch (Conv1d/SincNet + ResNet34) with no fp16 requirement.
- Pipeline runs **fp32 by default** — no autocast/`.half()` calls. This is correct for Pascal (weak fp16 throughput at 1:64 ratio).
- VRAM: no first-party number, but community reports place steady-state usage at **~1.5–3 GB** at default batch sizes — comfortable on 6GB.
- Reduce `pipeline.segmentation_batch_size` and `pipeline.embedding_batch_size` if you hit OOM. (confidence: medium — community reports, no canonical bench)

## DER benchmarks (lower is better)

From [[updated 4.x table|raw/repos/2026-05-21-pyannote-audio]]:

| Dataset | 3.1 (legacy) | community-1 (4.x default) | precision-2 (paid) |
|---------|--------------|---------------------------|--------------------|
| AISHELL-4 | 12.2 | 11.7 | 11.4 |
| AliMeeting | 24.5 | 20.3 | 15.2 |
| AMI (IHM) | 18.8 | **17.0** | 12.9 |
| DIHARD 3 | 21.4 | 20.2 | 14.7 |
| VoxConverse v0.3 | 11.2 | 11.2 | 8.5 |

**Issue #1370 caveat**: ~12% relative DER drift between CUDA 11.6 → 11.7 due to embedding+clustering non-determinism. Expect small drift on a 1060 vs published numbers — not a Pascal bug.

## HuggingFace gated-model workflow

**Do this in the browser BEFORE any pip install** (pipeline 401s at runtime if you skip):

1. Create read token at https://huggingface.co/settings/tokens
2. Accept user conditions on:
   - https://huggingface.co/pyannote/segmentation-3.0
   - https://huggingface.co/pyannote/speaker-diarization-3.1 (or community-1 for 4.x)
3. Either pass `use_auth_token="hf_..."` (3.x) or `token="hf_..."` (4.x), OR run `huggingface-cli login`, OR set `HF_TOKEN` env

## Tuning knobs

```python
diarization = pipeline("audio.wav", num_speakers=2)              # hard
diarization = pipeline("audio.wav", min_speakers=2, max_speakers=5)  # range

# Long-audio progress hook
from pyannote.audio.pipelines.utils.hook import ProgressHook
with ProgressHook() as hook:
    diarization = pipeline("audio.wav", hook=hook)

# Low-VRAM (if needed)
pipeline.segmentation_batch_size = 4
pipeline.embedding_batch_size = 4
```

## Coexistence with faster-whisper on 6GB

| Whisper config | Whisper VRAM | Free for pyannote | Coexist? |
|----------------|--------------|-------------------|----------|
| large-v3 fp32 | ~4.5 GB | ~1.4 GB | ❌ likely OOM |
| large-v3 **int8** | ~3.0 GB | ~3.0 GB | ✓ comfortable |
| distil-large-v3 int8 | ~1.5–2 GB | ~4 GB | ✓ very comfortable (recommended) |
| large-v3-turbo int8 | ~1.5 GB | ~4.5 GB | ✓ very comfortable |

Or: **sequence model loads** — transcribe with Whisper, free VRAM, then diarize. WhisperX does the latter implicitly.

## See also

- [[whisperx-vs-manual-pyannote-integration]]
- [[whisperx-known-broken-installs]] — `use_auth_token` vs `token` kwarg (4.x mismatch)
- [[faster-whisper-on-gtx-1060]] — Whisper VRAM table
